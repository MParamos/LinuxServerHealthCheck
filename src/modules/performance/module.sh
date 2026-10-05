#!/bin/bash
# ==============================================================================
# @file      module.sh
# @brief     Main logic for the Performance module. Gathers data and exports HTML variables.
# @author Miguel Páramos (www.miguelparamos.com)
#
# This file belongs to the LinuxServerHealthCheck framework.
# ==============================================================================
echo "${L_CLI_PERF}" >&2

# ------------------------------------------------------------------------------
# @brief Executes the get_status_html routine.
# ------------------------------------------------------------------------------
get_status_html() {
    local temp=$1
    if [ "$temp" -gt 80 ]; then
        echo "<span style='color:#ff3366;'>${L_PERF_CAUTION}</span>"
    elif [ "$temp" -gt 65 ]; then
        echo "<span style='color:#ffcc00;'>${L_PERF_WARN}</span>"
    else
        echo "<span style='color:#00d2ff;'>${L_PERF_OK}</span>"
    fi
}

# ------------------------------------------------------------------------------
# @brief Executes the format_query routine.
# ------------------------------------------------------------------------------
format_query() {
    local row="$1"
    if [ -z "$row" ] || [ "$row" == "NULL" ]; then echo "N/A"; else
        local temp=$(echo "$row" | awk '{print $1}')
        local date_str=$(echo "$row" | cut -d' ' -f2-)
        local color="#00d2ff"
        if [ "$temp" -gt 80 ]; then color="#ff3366"; elif [ "$temp" -gt 65 ]; then color="#ffcc00"; fi
        local status=$(get_status_html "$temp")
        echo "<span style='color:${color};'>${temp}°C</span> ${status} <span style='color:#64748b; font-size:11px;'>(${date_str})</span>"
    fi
}

# ------------------------------------------------------------------------------
# @brief Executes the get_status routine.
# ------------------------------------------------------------------------------
get_status() {
    local temp=$1
    if [ -z "$temp" ] || [ "$temp" == "NULL" ]; then echo "N/A"; else
        local color="#00d2ff"
        if [ "$temp" -gt 80 ]; then color="#ff3366"; elif [ "$temp" -gt 65 ]; then color="#ffcc00"; fi
        local status=$(get_status_html "$temp")
        echo "<span style='color:${color};'>${temp}°C</span> ${status}"
    fi
}


# CPU
CPU_TEMP=$(sensors | awk '/Core 0/ {print $3}' | sed 's/+//;s/°C//' | awk '{printf "%d", $1}')
if [ -z "$CPU_TEMP" ]; then CPU_TEMP=$(cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null | awk '{print $1/1000}'); fi
if [ -z "$CPU_TEMP" ]; then CPU_TEMP=0; fi

export CPU_TEMP_HTML="<p><strong>${L_ACTUAL_CPU}:</strong> $(get_status "$CPU_TEMP")</p>"

# Historico CPU
MIN_ROW=$($MYSQL_CMD "SELECT cpu_temp, DATE_FORMAT(timestamp, '%Y-%m-%d ${L_AT} %H:%i') FROM mod_performance_metrics WHERE cpu_temp IS NOT NULL ORDER BY cpu_temp ASC LIMIT 1;")
MAX_ROW=$($MYSQL_CMD "SELECT cpu_temp, DATE_FORMAT(timestamp, '%Y-%m-%d ${L_AT} %H:%i') FROM mod_performance_metrics WHERE cpu_temp IS NOT NULL ORDER BY cpu_temp DESC LIMIT 1;")
AVG_TEMP=$($MYSQL_CMD "SELECT ROUND(AVG(cpu_temp)) FROM mod_performance_metrics WHERE cpu_temp IS NOT NULL;")


export HISTORY_HTML="<p><strong>${L_CPU_HIST}</strong><br><span style='color:#cbd5e1; font-size:14px;'>&nbsp;&nbsp;&nbsp;&nbsp;- Min: $(format_query "$MIN_ROW")<br>&nbsp;&nbsp;&nbsp;&nbsp;- Avg: $(get_status "$AVG_TEMP")<br>&nbsp;&nbsp;&nbsp;&nbsp;- Max: $(format_query "$MAX_ROW")<br></span></p>"

# GPU
GPU_INFO=""
if chroot /host command -v nvidia-smi &> /dev/null; then
    GPU_INFO=$(chroot /host nvidia-smi --query-gpu=name --format=csv,noheader 2>/dev/null | head -n 1)
elif chroot /host lspci 2>/dev/null | grep -i -E "vga|3d|display" | grep -i "amd" >/dev/null; then
    GPU_INFO=$(chroot /host lspci 2>/dev/null | grep -i -E "vga|3d|display" | grep -i "amd" | cut -d':' -f3- | xargs)
elif chroot /host lspci 2>/dev/null | grep -i -E "vga|3d|display" | grep -i "intel" >/dev/null; then
    GPU_INFO=$(chroot /host lspci 2>/dev/null | grep -i -E "vga|3d|display" | grep -i "intel" | cut -d':' -f3- | xargs)
fi

if [ -z "$GPU_INFO" ]; then
    export GPU_TEMP_HTML="<p><strong>${L_GPU}</strong> <span style='color:#64748b;'>${L_NO_GPU}</span></p>"
else
    MIN_GPU_ROW=$($MYSQL_CMD "SELECT gpu_temp, DATE_FORMAT(timestamp, '%Y-%m-%d ${L_AT} %H:%i') FROM mod_performance_metrics WHERE gpu_temp IS NOT NULL ORDER BY gpu_temp ASC LIMIT 1;")
    MAX_GPU_ROW=$($MYSQL_CMD "SELECT gpu_temp, DATE_FORMAT(timestamp, '%Y-%m-%d ${L_AT} %H:%i') FROM mod_performance_metrics WHERE gpu_temp IS NOT NULL ORDER BY gpu_temp DESC LIMIT 1;")
    AVG_GPU_TEMP=$($MYSQL_CMD "SELECT ROUND(AVG(gpu_temp)) FROM mod_performance_metrics WHERE gpu_temp IS NOT NULL;")

    GPU_TEMP="N/A"
    if chroot /host command -v nvidia-smi &> /dev/null; then
        GPU_TEMP=$(chroot /host nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader 2>/dev/null | awk '{printf "%d", $1}')
    elif echo "$GPU_INFO" | grep -i "amd" >/dev/null; then
        if sensors 2>/dev/null | grep -i "amdgpu" >/dev/null; then
            GPU_TEMP=$(sensors 2>/dev/null | grep -i -A 3 "amdgpu" | grep -i "edge" | awk '{print $2}' | tr -d '+C°' | awk '{printf "%d", $1}')
        fi
    elif echo "$GPU_INFO" | grep -i "intel" >/dev/null; then
        GPU_TEMP=$CPU_TEMP
    fi

    if [ -z "$GPU_TEMP" ] || [ "$GPU_TEMP" == "N/A" ]; then
        export GPU_TEMP_HTML="<p><strong>${L_GPU}</strong> <span style='color:#0ea5e9;'>$GPU_INFO</span></p><p><strong>${L_GPU_TEMP_CURR}</strong> N/A (${L_NO_DIRECT_SENSOR})</p>"
    else
        if [ "$AVG_GPU_TEMP" == "NULL" ] || [ -z "$AVG_GPU_TEMP" ]; then AVG_GPU_TEMP=$GPU_TEMP; fi
        
        GPU_CURR_HTML=$(get_status "$GPU_TEMP")
        export GPU_TEMP_HTML="<p><strong>${L_GPU}</strong> <span style='color:#0ea5e9;'>$GPU_INFO</span></p>"
        GPU_TEMP_HTML+="<p><strong>${L_GPU_TEMP_CURR}</strong> $GPU_CURR_HTML</p>"
        GPU_TEMP_HTML+="<p><strong>${L_GPU_HIST}</strong><br><span style='color:#cbd5e1; font-size:14px;'>&nbsp;&nbsp;&nbsp;&nbsp;- Min: $(format_query "$MIN_GPU_ROW")<br>&nbsp;&nbsp;&nbsp;&nbsp;- Avg: $(get_status "$AVG_GPU_TEMP")<br>&nbsp;&nbsp;&nbsp;&nbsp;- Max: $(format_query "$MAX_GPU_ROW")<br></span></p>"
    fi
fi

# Load & RAM
export CORES=$(nproc)
export LOAD_AVG=$(cat /proc/loadavg | awk '{print $1}')
LOAD_PERC=$(echo "$LOAD_AVG $CORES" | awk '{printf "%d", ($1/$2)*100}')

MIN_LOAD_ROW=$($MYSQL_CMD "SELECT load_perc, DATE_FORMAT(timestamp, '%Y-%m-%d ${L_AT} %H:%i') FROM mod_performance_metrics WHERE load_perc IS NOT NULL ORDER BY load_perc ASC LIMIT 1;")
MAX_LOAD_ROW=$($MYSQL_CMD "SELECT load_perc, DATE_FORMAT(timestamp, '%Y-%m-%d ${L_AT} %H:%i') FROM mod_performance_metrics WHERE load_perc IS NOT NULL ORDER BY load_perc DESC LIMIT 1;")
AVG_LOAD=$($MYSQL_CMD "SELECT ROUND(AVG(load_perc)) FROM mod_performance_metrics WHERE load_perc IS NOT NULL;")
if [ "$AVG_LOAD" == "NULL" ] || [ -z "$AVG_LOAD" ]; then AVG_LOAD=$LOAD_PERC; fi

# ------------------------------------------------------------------------------
# @brief Executes the format_load_query routine.
# ------------------------------------------------------------------------------
format_load_query() {
    local row="$1"
    if [ -z "$row" ] || [ "$row" == "NULL" ]; then echo "N/A"; else
        local val=$(echo "$row" | awk '{print $1}')
        local date_str=$(echo "$row" | cut -d' ' -f2-)
        local color="#00d2ff"
        if [ "$val" -gt 100 ]; then color="#ff3366"; elif [ "$val" -gt 80 ]; then color="#ffcc00"; fi
        echo "<span style='color:${color};'>${val}${L_CAPACITY_PERC}</span> <span style='color:#64748b; font-size:11px;'>(${date_str})</span>"
    fi
}
# ------------------------------------------------------------------------------
# @brief Executes the get_load_status routine.
# ------------------------------------------------------------------------------
get_load_status() {
    local val=$1
    if [ "$val" -gt 100 ]; then echo "<span style='color:#ff3366;'>${L_PERF_CAUTION} ${L_STRESS} (${val}${L_CAPACITY_PERC})</span>"; elif [ "$val" -gt 80 ]; then echo "<span style='color:#ffcc00;'>${L_PERF_CAUTION} ${L_ELEV_LOAD} (${val}${L_CAPACITY_PERC})</span>"; else echo "<span style='color:#00d2ff;'>${L_PERF_OK} (${val}${L_CAPACITY_PERC})</span>"; fi
}
export LOAD_HTML="<p><strong>${L_LOAD}:</strong> ${LOAD_AVG} (${CORES} Cores) $(get_load_status "$LOAD_PERC")</p><p><strong>${L_LOAD_HIST}</strong><br><span style='color:#cbd5e1; font-size:14px;'>&nbsp;&nbsp;&nbsp;&nbsp;- Min: $(format_load_query "$MIN_LOAD_ROW")<br>&nbsp;&nbsp;&nbsp;&nbsp;- Avg: $(get_load_status "${AVG_LOAD}")<br>&nbsp;&nbsp;&nbsp;&nbsp;- Max: $(format_load_query "$MAX_LOAD_ROW")<br></span></p>"

export RAM_TOTAL=$(free -m | awk '/^Mem:/{print $2}')
export RAM_USED=$(free -m | awk '/^Mem:/{print $3}')
MIN_RAM_ROW=$($MYSQL_CMD "SELECT ram_used, DATE_FORMAT(timestamp, '%Y-%m-%d ${L_AT} %H:%i') FROM mod_performance_metrics WHERE ram_used IS NOT NULL ORDER BY ram_used ASC LIMIT 1;")
MAX_RAM_ROW=$($MYSQL_CMD "SELECT ram_used, DATE_FORMAT(timestamp, '%Y-%m-%d ${L_AT} %H:%i') FROM mod_performance_metrics WHERE ram_used IS NOT NULL ORDER BY ram_used DESC LIMIT 1;")
AVG_RAM_VAL=$($MYSQL_CMD "SELECT ROUND(AVG(ram_used)) FROM mod_performance_metrics WHERE ram_used IS NOT NULL;")
if [ "$AVG_RAM_VAL" == "NULL" ] || [ -z "$AVG_RAM_VAL" ]; then AVG_RAM_VAL=$RAM_USED; fi

# ------------------------------------------------------------------------------
# @brief Executes the format_ram_query routine.
# ------------------------------------------------------------------------------
format_ram_query() {
    local row="$1"
    if [ -z "$row" ] || [ "$row" == "NULL" ]; then echo "N/A"; else
        local val=$(echo "$row" | awk '{print $1}')
        local date_str=$(echo "$row" | cut -d' ' -f2-)
        local perc=$((val * 100 / RAM_TOTAL))
        local color="#00d2ff"
        if [ "$perc" -gt 90 ]; then color="#ff3366"; elif [ "$perc" -gt 80 ]; then color="#ffcc00"; fi
        echo "<span style='color:${color};'>${val} MB (${perc}%)</span> <span style='color:#64748b; font-size:11px;'>(${date_str})</span>"
    fi
}
# ------------------------------------------------------------------------------
# @brief Executes the get_ram_status routine.
# ------------------------------------------------------------------------------
get_ram_status() {
    local val=$1
    local perc=$((val * 100 / RAM_TOTAL))
    if [ "$perc" -gt 90 ]; then echo "<span style='color:#ff3366;'>${L_PERF_CAUTION} ${L_STRESS} (${perc}%)</span>"; elif [ "$perc" -gt 80 ]; then echo "<span style='color:#ffcc00;'>${L_PERF_CAUTION} ${L_ELEV_LOAD} (${perc}%)</span>"; else echo "<span style='color:#00d2ff;'>${L_PERF_OK} (${perc}%)</span>"; fi
}
export RAM_HTML="<p><strong>${L_RAM}:</strong> ${RAM_USED} MB ${L_OF} ${RAM_TOTAL} MB $(get_ram_status "$RAM_USED")</p><p><strong>${L_RAM_HIST}</strong><br><span style='color:#cbd5e1; font-size:14px;'>&nbsp;&nbsp;&nbsp;&nbsp;- Min: $(format_ram_query "$MIN_RAM_ROW")<br>&nbsp;&nbsp;&nbsp;&nbsp;- Avg: ${AVG_RAM_VAL} MB $(get_ram_status "${AVG_RAM_VAL}")<br>&nbsp;&nbsp;&nbsp;&nbsp;- Max: $(format_ram_query "$MAX_RAM_ROW")<br></span></p>"

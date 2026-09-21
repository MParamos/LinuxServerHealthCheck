# ==============================================================================
# @file      collect.sh
# @brief     Cron-based data collection script for the Performance module.
# @author Miguel Páramos (www.miguelparamos.com)
#
# This file belongs to the LinuxServerHealthCheck framework.
# ==============================================================================
# Collect CPU and GPU temps, Load and RAM
CPU_TEMP=$(sensors | awk '/Core 0/ {print $3}' | sed 's/+//;s/°C//' | awk '{printf "%d", $1}')
if [ -z "$CPU_TEMP" ]; then
    CPU_TEMP=$(cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null | awk '{print $1/1000}')
fi
if [ -z "$CPU_TEMP" ]; then CPU_TEMP="NULL"; fi

GPU_TEMP="NULL"
if chroot /host command -v nvidia-smi &> /dev/null; then
    GPU_TEMP=$(chroot /host nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader 2>/dev/null | awk '{printf "%d", $1}')
elif chroot /host lspci 2>/dev/null | grep -i -E "vga|3d|display" | grep -i "amd" >/dev/null; then
    if sensors 2>/dev/null | grep -i "amdgpu" >/dev/null; then
        GPU_TEMP=$(sensors 2>/dev/null | grep -i -A 3 "amdgpu" | grep -i "edge" | awk '{print $2}' | tr -d '+C°' | awk '{printf "%d", $1}')
    fi
elif chroot /host lspci 2>/dev/null | grep -i -E "vga|3d|display" | grep -i "intel" >/dev/null; then
    GPU_TEMP=$CPU_TEMP
fi
if [ -z "$GPU_TEMP" ]; then GPU_TEMP="NULL"; fi

CORES=$(nproc)
LOAD_AVG=$(cat /proc/loadavg | awk '{print $1}')
LOAD_PERC=$(echo "$LOAD_AVG $CORES" | awk '{printf "%d", ($1/$2)*100}')

RAM_TOTAL=$(free -m | awk '/^Mem:/{print $2}')
RAM_USED=$(free -m | awk '/^Mem:/{print $3}')

mysql -h 127.0.0.1 -P 33060 -u root -p${DB_ROOT_PASSWORD:-supersecret123} healthcheck -e "INSERT INTO mod_performance_metrics (cpu_temp, gpu_temp, load_perc, ram_used) VALUES ($CPU_TEMP, $GPU_TEMP, $LOAD_PERC, $RAM_USED);"

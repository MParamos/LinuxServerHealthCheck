#!/bin/bash
# ==============================================================================
# @file      module.sh
# @brief     Main logic for the Hardware Health module. Gathers data and exports HTML variables.
# @author Miguel Páramos (www.miguelparamos.com)
#
# This file belongs to the LinuxServerHealthCheck framework.
# ==============================================================================
echo "${L_CLI_HW}" >&2

SMART_HTML=""
SPEED_HTML=""
for disk in $(lsblk -nd -o NAME | grep -E 'sd|nvme'); do
    DEV="/dev/$disk"
    SMART_STATUS=$(smartctl -H $DEV 2>/dev/null | grep "SMART overall-health" | awk '{print $6}')
    if [ -z "$SMART_STATUS" ]; then SMART_STATUS=$(smartctl -H $DEV 2>/dev/null | grep "test result" | awk '{print $4}'); fi
    if [ -z "$SMART_STATUS" ]; then SMART_STATUS="N/A"; fi

    EXTRA_SMART=""
    IS_NVME=$(echo "$DEV" | grep "nvme")
    if [ -n "$IS_NVME" ]; then
        PERC_USED=$(smartctl -A $DEV 2>/dev/null | grep "Percentage Used" | awk '{print $3}' | tr -d '%')
        if [ -n "$PERC_USED" ]; then
            REMAINING=$((100 - PERC_USED))
            if [ "$REMAINING" -lt 0 ]; then REMAINING=0; fi
            EXTRA_SMART="<span style='color:#64748b; font-size:12px;'> (Vida util rest.: ${REMAINING}%)</span>"
        fi
    else
        WEAR=$(smartctl -A $DEV 2>/dev/null | awk '/Media_Wearout_Indicator/ {print $4}')
        if [ -z "$WEAR" ]; then WEAR=$(smartctl -A $DEV 2>/dev/null | awk '/Wear_Leveling_Count/ {print $4}'); fi
        if [ -z "$WEAR" ]; then WEAR=$(smartctl -A $DEV 2>/dev/null | awk '/Percent_Lifetime_Remain/ {print $4}'); fi
        
        if [ -n "$WEAR" ]; then
            WEAR_DEC=$(echo "$WEAR" | sed 's/^0*//')
            if [ -z "$WEAR_DEC" ]; then WEAR_DEC="0"; fi
            EXTRA_SMART="<span style='color:#64748b; font-size:12px;'> (Vida util rest.: ${WEAR_DEC}%)</span>"
        else
            POH=$(smartctl -A $DEV 2>/dev/null | grep "Power_On_Hours" | awk '{print $10}')
            if [ -n "$POH" ]; then
                # Fallback genérico para HDD basado en ~5 años de vida útil teórica (43800 horas)
                PERC_USED=$((POH * 100 / 43800))
                REMAINING=$((100 - PERC_USED))
                if [ "$REMAINING" -lt 0 ]; then REMAINING=0; fi
                EXTRA_SMART="<span style='color:#64748b; font-size:12px;'> (Vida util rest. estimada: ~${REMAINING}%)</span>"
            fi
        fi
    fi

    MODEL=$(smartctl -i $DEV 2>/dev/null | grep -E "Device Model|Model Number" | cut -d':' -f2- | xargs)
    if [ -z "$MODEL" ]; then MODEL=$(smartctl -i $DEV 2>/dev/null | grep -E "Model Family" | cut -d':' -f2- | xargs); fi
    SERIAL=$(smartctl -i $DEV 2>/dev/null | grep -E "Serial Number" | cut -d':' -f2- | xargs)
    POH_ACTUAL=$(smartctl -A $DEV 2>/dev/null | grep -i "Power_On_Hours" | awk '{print $10}')
    if [ -z "$POH_ACTUAL" ]; then POH_ACTUAL=$(smartctl -A $DEV 2>/dev/null | grep -i "Power On Hours" | cut -d':' -f2- | xargs | tr -d ','); fi
    TEMP=$(smartctl -A $DEV 2>/dev/null | grep -i "Temperature_Celsius" | awk '{print $10}')
    if [ -z "$TEMP" ]; then TEMP=$(smartctl -A $DEV 2>/dev/null | grep -i "Temperature:" | head -n 1 | grep -Eo '[0-9]+' | head -n 1); fi
    if [ -n "$TEMP" ]; then TEMP="${TEMP}ºC"; else TEMP="N/A"; fi
    POWER_CYCLES=$(smartctl -A $DEV 2>/dev/null | grep -i "Power_Cycle_Count" | awk '{print $10}')
    if [ -z "$POWER_CYCLES" ]; then POWER_CYCLES=$(smartctl -A $DEV 2>/dev/null | grep -i "Power Cycles:" | cut -d':' -f2- | xargs | tr -d ','); fi

    ERRORS=$(smartctl -a $DEV 2>/dev/null | grep -i "ATA Error Count:" | awk '{print $4}')
    if [ -z "$ERRORS" ]; then 
        if smartctl -a $DEV 2>/dev/null | grep -qi "No Errors Logged"; then ERRORS="0"; fi
    fi
    if [ -z "$ERRORS" ]; then
        ERRORS=$(smartctl -a $DEV 2>/dev/null | grep -i "Error Information Log Entries:" | awk '{print $5}')
    fi

    SECTORS=$(smartctl -A $DEV 2>/dev/null | grep -i "Reallocated_Sector_Ct" | awk '{print $10}')
    if [ -z "$SECTORS" ]; then
        SECTORS=$(smartctl -A $DEV 2>/dev/null | grep -i "Media and Data Integrity Errors:" | awk '{print $6}')
    fi

    INFO_STR=""
    if [ -n "$MODEL" ]; then INFO_STR+="<li><strong>Modelo:</strong> <span style='color:#0ea5e9;'>$MODEL</span></li>"; fi
    if [ -n "$SERIAL" ]; then INFO_STR+="<li><strong>Número de Serie:</strong> <span style='color:#cbd5e1;'>$SERIAL</span></li>"; fi
    if [ -n "$POH_ACTUAL" ]; then INFO_STR+="<li><strong>Horas Encendido:</strong> <span style='color:#cbd5e1;'>$POH_ACTUAL h</span></li>"; fi
    if [ -n "$POWER_CYCLES" ]; then INFO_STR+="<li><strong>Ciclos Encendido:</strong> <span style='color:#cbd5e1;'>$POWER_CYCLES</span></li>"; fi
    if [ "$TEMP" != "N/A" ]; then
        TEMP_RAW=$(echo "$TEMP" | tr -d 'ºC')
        TEMP_STATUS=""
        if [ "$TEMP_RAW" -gt 60 ]; then
            TEMP_STATUS="<span style='color:#ff3366;'>${L_CAUTION}</span>"
        elif [ "$TEMP_RAW" -gt 50 ]; then
            TEMP_STATUS="<span style='color:#ffcc00;'>${L_WARN}</span>"
        else
            TEMP_STATUS="<span style='color:#00d2ff;'>${L_OK}</span>"
        fi
        INFO_STR+="<li><strong>Temperatura:</strong> <span style='color:#cbd5e1;'>${TEMP_RAW}ºC</span> ${TEMP_STATUS}</li>"
    fi
    if [ -n "$ERRORS" ]; then
        COLOR="#10b981"; if [ "$ERRORS" -gt 0 ] 2>/dev/null; then COLOR="#ff3366"; fi
        INFO_STR+="<li><strong>Errores de Log:</strong> <span style='color:$COLOR; font-weight:bold;'>$ERRORS</span></li>"
    fi
    if [ -n "$SECTORS" ]; then
        COLOR="#10b981"; if [ "$SECTORS" -gt 0 ] 2>/dev/null; then COLOR="#ff3366"; fi
        INFO_STR+="<li><strong>Sectores Defectuosos:</strong> <span style='color:$COLOR; font-weight:bold;'>$SECTORS</span></li>"
    fi
    
    if [ -n "$INFO_STR" ]; then
        EXTRA_SMART+="<ul style='list-style-type:none; padding-left:15px; margin-top:5px; margin-bottom:10px; font-size:12px; color:#cbd5e1;'>$INFO_STR</ul>"
    fi

    if [ "$SMART_STATUS" == "PASSED" ] || [ "$SMART_STATUS" == "OK" ]; then SMART_HTML+="<p style='margin-bottom:0;'><strong>$DEV:</strong> <span style='color:#10b981; font-weight:bold;'>PASSED</span>${EXTRA_SMART}</p>"
    elif [ "$SMART_STATUS" == "N/A" ]; then SMART_HTML+="<p style='margin-bottom:0;'><strong>$DEV:</strong> <span style='color:#cbd5e1;'>N/A (No soportado)</span></p>"
    else SMART_HTML+="<p style='margin-bottom:0;'><strong>$DEV:</strong> <span style='color:#ff3366; font-weight:bold;'>FAILED / WARNING</span></p>"; fi

    SPEED_RAW=$(hdparm -t $DEV 2>/dev/null | grep "MB/sec" | awk '{print $11}')
    if [ -n "$SPEED_RAW" ]; then
        SPEED_INT=$(echo $SPEED_RAW | awk '{print int($1)}')
        if [ "$SPEED_INT" -lt 100 ]; then SPEED_HTML+="<p style='margin-left:20px; margin-top:2px;'>- <strong>$DEV:</strong> <span style='color:#ff3366;'>${SPEED_RAW} MB/sec ${L_CAUTION} (Pobre)</span></p>"
        elif [ "$SPEED_INT" -lt 400 ]; then SPEED_HTML+="<p style='margin-left:20px; margin-top:2px;'>- <strong>$DEV:</strong> <span style='color:#ffcc00;'>${SPEED_RAW} MB/sec (SATA HDD / Slow SSD)</span></p>"
        else SPEED_HTML+="<p style='margin-left:20px; margin-top:2px;'>- <strong>$DEV:</strong> <span style='color:#00d2ff;'>${SPEED_RAW} MB/sec (SATA SSD / NVMe)</span></p>"; fi
    fi
done
if [ -z "$SMART_HTML" ]; then SMART_HTML="<p>No se encontraron discos físicos compatibles con SMART.</p>"; fi
if [ -z "$SPEED_HTML" ]; then SPEED_HTML="<p style='margin-left:20px;'>N/A</p>"; fi
export SMART_HTML
export SPEED_HTML

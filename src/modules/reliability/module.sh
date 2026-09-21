#!/bin/bash
# ==============================================================================
# @file      module.sh
# @brief     Main logic for the Reliability module. Gathers data and exports HTML variables.
# @author Miguel Páramos (www.miguelparamos.com)
#
# This file belongs to the LinuxServerHealthCheck framework.
# ==============================================================================
echo "${L_CLI_REL}" >&2

export UPTIME_RAW=$(uptime -p | sed 's/up //')
export BOOT_TIME=$(uptime -s)

LAST_SHUTDOWN_RAW=$(last -F -x shutdown -f /host/var/log/wtmp 2>/dev/null | head -n 1)
export SHUTDOWN_TIME=$(echo "$LAST_SHUTDOWN_RAW" | awk '{print $5, $6, $7, $8}')
if [ -z "$SHUTDOWN_TIME" ]; then export SHUTDOWN_TIME="${L_UNKNOWN}"; fi

# Deteccion crasheos
LAST_REBOOT_RAW=$(last -F -x reboot -f /host/var/log/wtmp 2>/dev/null | head -n 1)
if [ -n "$LAST_SHUTDOWN_RAW" ] && [ -n "$LAST_REBOOT_RAW" ]; then
    SHUTDOWN_EPOCH=$(date -d "$(echo "$LAST_SHUTDOWN_RAW" | awk '{print $5, $6, $7, $8}')" +%s 2>/dev/null)
    REBOOT_EPOCH=$(date -d "$(echo "$LAST_REBOOT_RAW" | awk '{print $5, $6, $7, $8}')" +%s 2>/dev/null)
    if [ -n "$SHUTDOWN_EPOCH" ] && [ -n "$REBOOT_EPOCH" ]; then
        if [ "$REBOOT_EPOCH" -gt "$SHUTDOWN_EPOCH" ]; then
            DIFF=$((REBOOT_EPOCH - SHUTDOWN_EPOCH))
            if [ "$DIFF" -gt 300 ]; then export CRASH_HTML="<br><span style='color:#ffcc00; font-size:12px;'>${L_CAUTION} Posible corte de energía o crash (El sistema arrancó sin registro de apagado previo cercano)</span>"
            else export CRASH_HTML=""; fi
        else export CRASH_HTML=""; fi
    else export CRASH_HTML=""; fi
else export CRASH_HTML=""; fi

NET_AVG=$($MYSQL_CMD "SELECT ROUND(AVG(net_status)*100, 2) FROM mod_reliability_net WHERE net_status IS NOT NULL;")
if [ -z "$NET_AVG" ] || [ "$NET_AVG" == "NULL" ]; then
    export NETWORK_AVAILABILITY="N/A"
else
    if awk "BEGIN {exit !($NET_AVG < 95.00)}"; then
        export NETWORK_AVAILABILITY="<span style='color:#ff3366;'>${NET_AVG}% ${L_WARN}</span>"
    else
        export NETWORK_AVAILABILITY="<span style='color:#00d2ff;'>${NET_AVG}% ${L_OK}</span>"
    fi
fi

#!/bin/bash
# ==============================================================================
# @file      module.sh
# @brief     Main logic for the Top Ram module. Gathers data and exports HTML variables.
# @author Miguel Páramos (www.miguelparamos.com)
#
# This file belongs to the LinuxServerHealthCheck framework.
# ==============================================================================
echo "${L_CLI_TOPRAM}" >&2
export TOP_RAM_HTML="<table style='width:100%; font-size:12px; color:#cbd5e1; border-collapse:collapse;'>"
TOP_RAM_HTML+="<tr style='background-color:#1a2a3a; color:#00d2ff; text-align:left;'><th style='padding:5px;'>PID</th><th style='padding:5px;'>USER</th><th style='padding:5px;'>%MEM</th><th style='padding:5px;'>COMMAND</th></tr>"
while read -r line; do
    pid=$(echo $line | awk '{print $1}')
    user=$(echo $line | awk '{print $2}')
    mem=$(echo $line | awk '{print $10}')
    cmd=$(echo $line | awk '{print $12}')
    TOP_RAM_HTML+="<tr><td style='padding:5px; border-bottom:1px solid #1a2a3a;'>$pid</td><td style='padding:5px; border-bottom:1px solid #1a2a3a;'>$user</td><td style='padding:5px; border-bottom:1px solid #1a2a3a; color:#ffcc00;'>$mem%</td><td style='padding:5px; border-bottom:1px solid #1a2a3a;'>$cmd</td></tr>"
done <<< "$(top -b -n 1 -o %MEM | head -n 12 | tail -n 5)"
TOP_RAM_HTML+="</table>"

#!/bin/bash
# ==============================================================================
# @file      module.sh
# @brief     Main logic for the Failed Services module. Gathers data and exports HTML variables.
# @author Miguel Páramos (www.miguelparamos.com)
#
# This file belongs to the LinuxServerHealthCheck framework.
# ==============================================================================
echo "${L_CLI_FAILED_SERVICES}" >&2

FAILED_RAW=$(chroot /host systemctl --failed --plain --no-legend 2>/dev/null)

export FAILED_SERVICES_HTML=""
if [ -z "$FAILED_RAW" ]; then
    FAILED_SERVICES_HTML="<p><span style='color:#10b981; font-weight:bold;'>0</span> <span style='color:#cbd5e1;'>${L_NO_FAILED_SERVICES}</span></p>"
else
    COUNT=$(echo "$FAILED_RAW" | wc -l)
    FAILED_SERVICES_HTML="<p><span style='color:#ff3366; font-weight:bold;'>$COUNT</span> <span style='color:#cbd5e1;'>${L_FAILED_SERVICES} ${L_FS_CAUTION}</span></p>"
    FAILED_SERVICES_HTML+="<ul style='list-style-type:none; padding-left:15px; margin-top:5px; margin-bottom:10px; font-size:12px; color:#cbd5e1;'>"
    while read -r line; do
        if [ -n "$line" ]; then
            SVC_NAME=$(echo "$line" | awk '{print $1}')
            FAILED_SERVICES_HTML+="<li>↳ <span style='color:#ffcc00;'>$SVC_NAME</span></li>"
        fi
    done <<< "$FAILED_RAW"
    FAILED_SERVICES_HTML+="</ul>"
fi

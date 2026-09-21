#!/bin/bash
# ==============================================================================
# @file      module.sh
# @brief     Main logic for the Docker Health module. Gathers data and exports HTML variables.
# @author Miguel Páramos (www.miguelparamos.com)
#
# This file belongs to the LinuxServerHealthCheck framework.
# ==============================================================================
echo "${L_CLI_DOCKER}" >&2

export DOCKER_HEALTH_HTML=""

if ! chroot /host docker info >/dev/null 2>&1; then
    DOCKER_HEALTH_HTML="<p style='color:#64748b;'>${L_DOCKER_NO_DAEMON}</p>"
else
    DOCKER_RAW=$(chroot /host docker ps -a --format "{{.Names}}|{{.State}}|{{.Status}}" 2>/dev/null)
    if [ -z "$DOCKER_RAW" ]; then
        DOCKER_HEALTH_HTML="<p style='color:#cbd5e1;'>${L_DOCKER_NO_CONTAINERS}</p>"
    else
        RUNNING=$(echo "$DOCKER_RAW" | grep -i "|running" | wc -l)
        EXITED=$(echo "$DOCKER_RAW" | grep -i -E "\|exited|\|created" | wc -l)
        RESTARTING=$(echo "$DOCKER_RAW" | grep -i "|restarting" | wc -l)
        DANGLING_VOLS=$(chroot /host docker volume ls -qf dangling=true 2>/dev/null | wc -l)
        
        DOCKER_HEALTH_HTML="<p style='margin-bottom:10px;'>"
        DOCKER_HEALTH_HTML+="<span style='color:#10b981; font-weight:bold;'>$RUNNING</span> <span style='color:#cbd5e1; font-size:13px;'>${L_DOCKER_RUNNING}</span> | "
        if [ "$EXITED" -gt 0 ]; then
            DOCKER_HEALTH_HTML+="<span style='color:#ffcc00; font-weight:bold;'>$EXITED</span> <span style='color:#cbd5e1; font-size:13px;'>${L_DOCKER_EXITED}</span> | "
        else
            DOCKER_HEALTH_HTML+="<span style='color:#64748b; font-weight:bold;'>$EXITED</span> <span style='color:#cbd5e1; font-size:13px;'>${L_DOCKER_EXITED}</span> | "
        fi
        if [ "$RESTARTING" -gt 0 ]; then
            DOCKER_HEALTH_HTML+="<span style='color:#ff3366; font-weight:bold;'>$RESTARTING</span> <span style='color:#cbd5e1; font-size:13px;'>${L_DOCKER_RESTARTING} ${L_CAUTION}</span>"
        else
            DOCKER_HEALTH_HTML+="<span style='color:#64748b; font-weight:bold;'>$RESTARTING</span> <span style='color:#cbd5e1; font-size:13px;'>${L_DOCKER_RESTARTING}</span>"
        fi
        DOCKER_HEALTH_HTML+="</p>"
        
        DETAILS_HTML=""
        if [ "$EXITED" -gt 0 ] || [ "$RESTARTING" -gt 0 ]; then
            DETAILS_HTML+="<ul style='list-style-type:none; padding-left:15px; margin:0; font-size:12px; color:#cbd5e1;'>"
            while read -r line; do
                if [ -z "$line" ]; then continue; fi
                NAME=$(echo "$line" | cut -d'|' -f1)
                STATE=$(echo "$line" | cut -d'|' -f2)
                STATUS=$(echo "$line" | cut -d'|' -f3)
                if [[ "${STATE,,}" == "restarting" ]]; then
                    DETAILS_HTML+="<li>↳ <span style='color:#ff3366; font-weight:bold;'>$NAME</span> <span style='color:#94a3b8;'>($STATUS)</span></li>"
                elif [[ "${STATE,,}" == "exited" || "${STATE,,}" == "created" ]]; then
                    DETAILS_HTML+="<li>↳ <span style='color:#ffcc00;'>$NAME</span> <span style='color:#94a3b8;'>($STATUS)</span></li>"
                fi
            done <<< "$DOCKER_RAW"
            DETAILS_HTML+="</ul>"
        fi
        
        if [ -n "$DETAILS_HTML" ]; then
            DOCKER_HEALTH_HTML+="$DETAILS_HTML"
        fi
        
        if [ "$DANGLING_VOLS" -gt 0 ]; then
            DOCKER_HEALTH_HTML+="<p style='margin-top:10px; margin-bottom:0;'><span style='color:#ffcc00; font-weight:bold;'>$DANGLING_VOLS</span> <span style='color:#cbd5e1; font-size:13px;'>${L_DOCKER_DANGLING}</span></p>"
        else
            DOCKER_HEALTH_HTML+="<p style='margin-top:10px; margin-bottom:0; color:#64748b; font-size:13px;'>0 ${L_DOCKER_DANGLING}</p>"
        fi
    fi
fi

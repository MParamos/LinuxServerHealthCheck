#!/bin/bash
# ==============================================================================
# @file      module.sh
# @brief     Main logic for the Os Health module. Gathers data and exports HTML variables.
# @author Miguel Páramos (www.miguelparamos.com)
#
# This file belongs to the LinuxServerHealthCheck framework.
# ==============================================================================
echo "${L_CLI_OS}" >&2
export HOST_OS=$(cat /etc/os-release | grep "PRETTY_NAME" | cut -d'"' -f2)

apt-get update > /dev/null 2>&1
UPDATES=$(apt-get -s upgrade | grep -P '^\d+ upgraded' | awk '{print $1}')
if [ -z "$UPDATES" ]; then UPDATES=0; fi
if [ "$UPDATES" -gt 0 ]; then export UPDATES_HTML="<span style='color:#ffcc00;'>$UPDATES disponibles</span>"
else export UPDATES_HTML="<span style='color:#00d2ff;'>Sistema al día</span>"; fi

ZOMBIES_LIST=$(ps -eo stat,pid,cmd | awk '$1 ~ /^Z/ {print "PID: " $2 " - " $3}')
ZOMBIES_COUNT=$(echo "$ZOMBIES_LIST" | grep -c "PID:")
if [ "$ZOMBIES_COUNT" -gt 0 ]; then
    ZOMBIES_HTML="<span style='color:#ff3366;'>$ZOMBIES_COUNT ${L_OS_CAUTION}</span>"
    while IFS= read -r z_line; do
        if [ -n "$z_line" ]; then
            ZOMBIES_HTML+="<br><span style='color:#ffcc00; font-size:12px;'>↳ $z_line</span>"
        fi
    done <<< "$ZOMBIES_LIST"
    export ZOMBIES_HTML
else
    export ZOMBIES_HTML="<span style='color:#00d2ff;'>0</span>"
fi

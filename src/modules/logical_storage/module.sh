#!/bin/bash
# ==============================================================================
# @file      module.sh
# @brief     Main logic for the Logical Storage module. Gathers data and exports HTML variables.
# @author Miguel Páramos (www.miguelparamos.com)
#
# This file belongs to the LinuxServerHealthCheck framework.
# ==============================================================================
echo "${L_CLI_STORAGE}" >&2
DISKS_USAGE_HTML=""
while read -r line; do
    USAGE=$(echo $line | awk '{print $5}' | sed 's/%//')
    MNT=$(echo $line | awk '{print $6}' | sed 's|^/host||')
    if [ -z "$MNT" ]; then MNT="/"; fi
    SIZE=$(echo $line | awk '{print $2}')
    USED=$(echo $line | awk '{print $3}')
    if [ "$USAGE" -gt 90 ]; then DISKS_USAGE_HTML+="<p><strong>$MNT:</strong> <span style='color:#ff3366;'>$USED / $SIZE ($USAGE%) ${L_LS_WARN}</span></p>"
    elif [ "$USAGE" -gt 75 ]; then DISKS_USAGE_HTML+="<p><strong>$MNT:</strong> <span style='color:#ffcc00;'>$USED / $SIZE ($USAGE%) ${L_LS_CAUTION}</span></p>"
    else DISKS_USAGE_HTML+="<p><strong>$MNT:</strong> $USED / $SIZE ($USAGE%) <span style='color:#00d2ff;'>${L_LS_OK}</span></p>"; fi
done <<< "$(df -h | grep '^/dev/')"
export DISKS_USAGE_HTML

echo "${L_CLI_FOLDERS}" >&2
export HEAVY_FOLDERS_HTML=""
TOP_FOLDERS=$(du -h --max-depth=1 --exclude=/host/proc --exclude=/host/sys --exclude=/host/dev /host 2>/dev/null | sort -hr | head -n 6 | tail -n 5)
while read -r line; do
    SIZE=$(echo "$line" | awk '{print $1}')
    PATH_STR=$(echo "$line" | awk '{print $2}' | sed 's|^/host||')
    if [ -z "$PATH_STR" ]; then PATH_STR="/"; fi
    HEAVY_FOLDERS_HTML+="<tr style='border-bottom:1px solid #334155;'><td style='padding:8px 0;'>$PATH_STR</td><td style='text-align:right; color:#ffcc00;'>$SIZE</td></tr>"
done <<< "$TOP_FOLDERS"

export HOME_FOLDERS_HTML=""
if [ -d "/host/home" ]; then
    for user_home in /host/home/*; do
        if [ -d "$user_home" ]; then
            USERNAME=$(basename "$user_home")
            HOME_FOLDERS_HTML+="<div style='margin-top:20px;'><h4 style='color:#cbd5e1; margin-bottom:10px;'>${L_HOME_FOLDERS} <span style='color:#0ea5e9;'>$USERNAME</span></h4>"
            HOME_FOLDERS_HTML+="<table style='width:100%; border-collapse:collapse; font-size:14px;'>"
            TOP_HOME=$(du -h --max-depth=1 --exclude="$user_home/.cache" "$user_home"/* 2>/dev/null | sort -hr | head -n 5)
            if [ -n "$TOP_HOME" ]; then
                while read -r line; do
                    SIZE=$(echo "$line" | awk '{print $1}')
                    PATH_STR=$(echo "$line" | awk '{print $2}' | sed 's|^/host||')
                    HOME_FOLDERS_HTML+="<tr style='border-bottom:1px solid #334155;'><td style='padding:8px 0;'>$PATH_STR</td><td style='text-align:right; color:#0ea5e9;'>$SIZE</td></tr>"
                done <<< "$TOP_HOME"
            else
                HOME_FOLDERS_HTML+="<tr><td colspan='2' style='padding:8px 0; color:#64748b;'>${L_EMPTY_DIR}</td></tr>"
            fi
            HOME_FOLDERS_HTML+="</table></div>"
        fi
    done
fi
if [ -z "$HOME_FOLDERS_HTML" ]; then
    HOME_FOLDERS_HTML="<div style='margin-top:20px;'><h4 style='color:#cbd5e1; margin-bottom:10px;'>${L_HOME_FOLDERS} N/A</h4><p style='color:#64748b;'>No /home directory found.</p></div>"
fi
echo "${L_CLI_FILES}" >&2
export HEAVY_FILES_HTML=""
TOP_FILES=$(find /host -path '*/proc' -prune -o -path '*/sys' -prune -o -path '*/dev' -prune -o -path '*/var/log*' -prune -o -path '*/var/cache*' -prune -o -path '*/tmp*' -prune -o -path '*/run*' -prune -o -name 'swap.img' -prune -o -type f -printf '%s %p\n' 2>/dev/null | sort -nr | head -n 5)
while read -r line; do
    BYTES=$(echo "$line" | awk '{print $1}')
    SIZE=$(numfmt --to=iec-i --suffix=B "$BYTES")
    PATH_STR=$(echo "$line" | cut -d' ' -f2- | sed 's|^/host||')
    HEAVY_FILES_HTML+="<tr style='border-bottom:1px solid #334155;'><td style='padding:8px 0; font-size:12px; word-break:break-all;'>$PATH_STR</td><td style='text-align:right; color:#ff3366; white-space:nowrap;'>$SIZE</td></tr>"
done <<< "$TOP_FILES"

CACHE_SIZE=$(du -shc /host/var/cache 2>/dev/null | grep total | awk '{print $1}')
if [ -z "$CACHE_SIZE" ]; then CACHE_SIZE="0B"; fi
TEMP_SIZE=$(du -shc /host/tmp /host/var/tmp 2>/dev/null | grep total | awk '{print $1}')
if [ -z "$TEMP_SIZE" ]; then TEMP_SIZE="0B"; fi

HEAVY_FILES_HTML+="<tr style='border-top:2px solid #0ea5e9; background:#1e293b;'><td style='padding:8px; font-weight:bold;'>${L_CACHE_FILES}</td><td style='text-align:right; font-weight:bold;'>$CACHE_SIZE</td></tr>"
HEAVY_FILES_HTML+="<tr style='background:#1e293b; border-bottom:1px solid #334155;'><td style='padding:8px; font-weight:bold;'>${L_TEMP_FILES}</td><td style='text-align:right; font-weight:bold;'>$TEMP_SIZE</td></tr>"

echo "${L_CLI_RECENT}" >&2
export RECENT_FILES_HTML=""
RECENT_FILES=$(find /host -path '*/proc' -prune -o -path '*/sys' -prune -o -path '*/dev' -prune -o -path '*/var/log*' -prune -o -path '*/var/cache*' -prune -o -path '*/tmp*' -prune -o -path '*/run*' -prune -o -path '*/var/lib/mysql*' -prune -o -path '*/var/lib/mariadb*' -prune -o -path '*/var/lib/docker*' -prune -o -path '*/.config/google-chrome*' -prune -o -path '*/.mozilla*' -prune -o -path '*/.vscode-server*' -prune -o -type f ! -name '*.log' ! -name '*.db' ! -name '*.sqlite' ! -name '*.ibd' ! -name '*.sql' ! -name '*.tmp' ! -name '*-journal' -printf '%T@ %s %p\n' 2>/dev/null | sort -n -r | head -n 5)
while read -r line; do
    EPOCH=$(echo "$line" | awk '{print $1}' | cut -d'.' -f1)
    BYTES=$(echo "$line" | awk '{print $2}')
    if [ -n "$BYTES" ]; then SIZE=$(numfmt --to=iec-i --suffix=B "$BYTES" 2>/dev/null || echo "$BYTES"); else SIZE="0B"; fi
    PATH_STR=$(echo "$line" | cut -d' ' -f3- | sed 's|^/host||')
    DATE=$(date -d "@$EPOCH" "+%Y-%m-%d %H:%M" 2>/dev/null)
    RECENT_FILES_HTML+="<tr style='border-bottom:1px solid #334155;'><td style='padding:8px 0; font-size:12px; word-break:break-all;'>$PATH_STR<br><span style='color:#64748b;'>$DATE - $SIZE</span></td></tr>"
done <<< "$RECENT_FILES"

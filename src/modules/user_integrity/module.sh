#!/bin/bash
# ==============================================================================
# @file      module.sh
# @brief     Main logic for the User Integrity module. Gathers data and exports HTML variables.
# @author Miguel Páramos (www.miguelparamos.com)
#
# This file belongs to the LinuxServerHealthCheck framework.
# ==============================================================================
echo "${L_CLI_USERS}" >&2
PASSWD_FILE="/host/etc/passwd"
if [ ! -f "$PASSWD_FILE" ]; then
    PASSWD_FILE="/etc/passwd"
fi

ROOT_USERS=$(awk -F: '$3 == 0 {print $1}' "$PASSWD_FILE")
ROOT_COUNT=$(echo "$ROOT_USERS" | wc -w)
ROOT_LIST=""
for u in $ROOT_USERS; do
    if [ "$u" != "root" ]; then
        ROOT_LIST+="<span style='color:#ff3366; font-weight:bold;'>$u (${L_INTRUDER})</span> "
    else
        ROOT_LIST+="<span style='color:#0ea5e9;'>$u</span> "
    fi
done

if [ "$ROOT_COUNT" -gt 1 ]; then
    export ROOT_HTML="<strong>${L_USERS_ROOT}:</strong> <span style='color:#ff3366;'>$ROOT_COUNT ${L_UI_WARN}</span><br>&nbsp;&nbsp;<span style='font-size:12px;'>↳ $ROOT_LIST</span>"
else
    export ROOT_HTML="<strong>${L_USERS_ROOT}:</strong> <span style='color:#10b981;'>1 ${L_UI_OK}</span><br>&nbsp;&nbsp;<span style='font-size:12px;'>↳ $ROOT_LIST</span>"
fi

INTERACTIVE_USERS=""
while read -r line; do
    user=$(echo "$line" | cut -d: -f1)
    shell=$(echo "$line" | cut -d: -f7)
    if [[ "$shell" == *"/bash"* || "$shell" == *"/sh"* || "$shell" == *"/zsh"* ]]; then
        if [ "$user" == "root" ]; then continue; fi
        LAST_LOGIN=$(chroot /host last -F -1 "$user" 2>/dev/null | head -n 1 | awk '{for(i=4;i<=NF;i++) printf $i" "; print ""}' | awk -F'- ' '{print $1}' | xargs)
        if [[ -z "$LAST_LOGIN" || "$LAST_LOGIN" == wtmp* ]]; then
            LAST_LOGIN="${L_NEVER_LOGGED}"
        fi
        INTERACTIVE_USERS+="<li style='margin-bottom:5px;'><span style='color:#00d2ff; font-weight:bold;'>$user</span> <span style='color:#64748b; font-size:12px;'>(Shell: $shell)</span><br>&nbsp;&nbsp;<span style='color:#94a3b8; font-size:11px;'>${L_LAST_LOGIN} <span style='color:#cbd5e1;'>$LAST_LOGIN</span></span></li>"
    fi
done < "$PASSWD_FILE"

SYSTEM_USERS_COUNT=$(awk -F: '$7 ~ /nologin|false|sync/ {print $1}' "$PASSWD_FILE" | wc -l)

export USERS_SHELL_HTML="
<div style='margin-top:15px;'>
    <h4 style='color:#cbd5e1; font-size:13px; margin-bottom:5px; border-bottom:1px solid #334155; padding-bottom:3px;'>${L_INTERACTIVE}</h4>
    <p style='color:#64748b; font-size:12px; margin-top:0; margin-bottom:8px;'>${L_INTERACTIVE_DESC}</p>
    <ul style='list-style-type:none; padding-left:10px; margin:0;'>
        $INTERACTIVE_USERS
    </ul>
</div>
<div style='margin-top:15px;'>
    <h4 style='color:#cbd5e1; font-size:13px; margin-bottom:5px; border-bottom:1px solid #334155; padding-bottom:3px;'>${L_SERVICE}</h4>
    <p style='color:#64748b; font-size:12px; margin-top:0;'><strong>$SYSTEM_USERS_COUNT</strong> ${L_SERVICE_DESC} <span style='color:#10b981;'>${L_UI_OK}</span></p>
</div>
"

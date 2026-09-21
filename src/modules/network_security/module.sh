#!/bin/bash
# ==============================================================================
# @file      module.sh
# @brief     Main logic for the Network Security module. Gathers data and exports HTML variables.
# @author Miguel Páramos (www.miguelparamos.com)
#
# This file belongs to the LinuxServerHealthCheck framework.
# ==============================================================================
echo "${L_CLI_NET}" >&2
ports=$(ss -tuln | awk 'NR>1 {print $5}' | awk -F':' '{print $NF}' | grep -Eo '^[0-9]+' | sort -un)

PORTS_HTML=""
for p in $ports; do
    is_allowed=false
    for ap in $ALLOWED_PORTS; do
        if [ "$p" == "$ap" ]; then is_allowed=true; break; fi
    done
    if [ "$is_allowed" = true ]; then
        PORTS_HTML+="<span style='color:#00d2ff;'>$p</span>, "
    else
        PORTS_HTML+="<span style='color:#ffcc00;'>$p[?]</span>, "
    fi
done
PORTS_HTML=$(echo "$PORTS_HTML" | sed 's/, $//')
export PORTS_HTML

AUTH_LOG="/var/log/host/auth.log"
if [ ! -f "$AUTH_LOG" ]; then AUTH_LOG="/var/log/host/secure"; fi

export SSH_FAILS_HTML=""
export SSH_SUCCESS_HTML=""

if [ -f "$AUTH_LOG" ]; then
    LAST_AUDIT_ISO=$(echo "$LAST_AUDIT_DATE" | tr ' ' 'T')
    RECENT_LOGS=$(awk -v limit="$LAST_AUDIT_ISO" '$1 >= limit' "$AUTH_LOG")
    
    FAILS_LOGS=$(echo "$RECENT_LOGS" | grep "Failed password")
    SUCCESS_LOGS=$(echo "$RECENT_LOGS" | grep -E "Accepted password|Accepted publickey")
    
    SSH_FAILS=$(echo "$FAILS_LOGS" | grep -c "Failed password")
    SSH_SUCCESS=$(echo "$SUCCESS_LOGS" | grep -c -E "Accepted password|Accepted publickey")
    
    SSH_FAILS_HTML="<p style='margin-bottom:2px; color:#cbd5e1; font-size:14px;'><span style='color:#ff3366; font-weight:bold; font-size:16px;'>$SSH_FAILS</span> ${L_SSH_FAILS}</p>"
    if [ "$SSH_FAILS" -gt 0 ]; then
        RAW_FAILS=$(echo "$FAILS_LOGS" | awk '{for(i=1;i<=NF;i++) if($i=="from") { print $(i-1) "@" $(i+1); break; } }')
        FAILS_IPS=$(echo "$RAW_FAILS" | awk -F'@' '{print $2}' | sort | uniq -c | sort -nr)
        SSH_FAILS_HTML+="<ul style='list-style-type:none; padding-left:15px; margin:0; font-size:12px; color:#cbd5e1;'>"
        while read -r line; do
            if [ -n "$line" ]; then
                count=$(echo "$line" | awk '{print $1}')
                ip=$(echo "$line" | awk '{print $2}')
                USER_COUNTS=$(echo "$RAW_FAILS" | awk -F'@' -v ip="$ip" '$2==ip {print $1}' | sort | uniq -c | awk '{print $2"("$1")"}' | paste -sd ", " -)
                SSH_FAILS_HTML+="<li>↳ <span style='color:#ff3366;'>$ip</span> ($count intentos) - <span style='color:#94a3b8;'>$USER_COUNTS</span></li>"
            fi
        done <<< "$FAILS_IPS"
        SSH_FAILS_HTML+="</ul>"
    fi

    SSH_SUCCESS_HTML="<p style='margin-bottom:2px; margin-top:10px; color:#cbd5e1; font-size:14px;'><span style='color:#10b981; font-weight:bold; font-size:16px;'>$SSH_SUCCESS</span> ${L_SSH_SUCCESS}</p>"
    if [ "$SSH_SUCCESS" -gt 0 ]; then
        RAW_SUCCESS=$(echo "$SUCCESS_LOGS" | awk '{for(i=1;i<=NF;i++) if($i=="from") { print $(i-1) "@" $(i+1); break; } }')
        SUCCESS_IPS=$(echo "$RAW_SUCCESS" | awk -F'@' '{print $2}' | sort | uniq -c | sort -nr)
        SSH_SUCCESS_HTML+="<ul style='list-style-type:none; padding-left:15px; margin:0; font-size:12px; color:#cbd5e1;'>"
        while read -r line; do
            if [ -n "$line" ]; then
                count=$(echo "$line" | awk '{print $1}')
                ip=$(echo "$line" | awk '{print $2}')
                USER_COUNTS=$(echo "$RAW_SUCCESS" | awk -F'@' -v ip="$ip" '$2==ip {print $1}' | sort | uniq -c | awk '{print $2"("$1")"}' | paste -sd ", " -)
                SSH_SUCCESS_HTML+="<li>↳ <span style='color:#10b981;'>$ip</span> ($count conexiones) - <span style='color:#94a3b8;'>$USER_COUNTS</span></li>"
            fi
        done <<< "$SUCCESS_IPS"
        SSH_SUCCESS_HTML+="</ul>"
    fi
else
    SSH_FAILS_HTML="<p style='color:#cbd5e1; font-size:14px;'><span style='color:#64748b; font-weight:bold; font-size:16px;'>N/A</span> ${L_SSH_FAILS}</p>"
    SSH_SUCCESS_HTML="<p style='color:#cbd5e1; font-size:14px;'><span style='color:#64748b; font-weight:bold; font-size:16px;'>N/A</span> ${L_SSH_SUCCESS}</p>"
fi

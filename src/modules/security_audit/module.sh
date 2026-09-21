#!/bin/bash
# ==============================================================================
# @file      module.sh
# @brief     Main logic for the Security Audit module. Gathers data and exports HTML variables.
# @author Miguel Páramos (www.miguelparamos.com)
#
# This file belongs to the LinuxServerHealthCheck framework.
# ==============================================================================
echo "${L_CLI_LYNIS}" >&2
lynis audit system --quick --no-colors > /tmp/lynis.log 2>/dev/null

TESTS_DONE=$(grep "Tests performed" /tmp/lynis.log | awk -F':' '{print $2}' | tr -d ' ' | tr -d '\n')
if [ -z "$TESTS_DONE" ]; then TESTS_DONE="N/A"; fi

WARNINGS_COUNT=0
SUGGESTIONS_COUNT=0
WARNINGS_DETAILS=""
SUGGESTIONS_DETAILS=""

while IFS= read -r line; do
    if [[ "$line" == warning\[\]=* ]]; then
        WARNINGS_COUNT=$((WARNINGS_COUNT+1))
        DESC=$(echo "$line" | cut -d'|' -f2)
        DETAILS=$(echo "$line" | cut -d'|' -f3)
        WARNINGS_DETAILS+="<li style='margin-bottom:8px;'><span style='color:#ff3366; font-weight:bold;'>[WARN]</span> $DESC <br><span style='color:#cbd5e1; font-size:12px;'>$DETAILS</span></li>"
    elif [[ "$line" == suggestion\[\]=* ]]; then
        SUGGESTIONS_COUNT=$((SUGGESTIONS_COUNT+1))
        DESC=$(echo "$line" | cut -d'|' -f2)
        DETAILS=$(echo "$line" | cut -d'|' -f3)
        SUGGESTIONS_DETAILS+="<li style='margin-bottom:8px;'><span style='color:#0ea5e9; font-weight:bold;'>[SUGG]</span> $DESC <br><span style='color:#cbd5e1; font-size:12px;'>$DETAILS</span></li>"
    fi
done < /var/log/lynis-report.dat 2>/dev/null

if [ -z "$WARNINGS_DETAILS" ]; then WARNINGS_DETAILS="<li style='color:#10b981; font-size:14px;'>0 Warnings (Limpio)</li>"; fi
if [ -z "$SUGGESTIONS_DETAILS" ]; then SUGGESTIONS_DETAILS="<li style='color:#10b981; font-size:14px;'>0 Sugerencias (Limpio)</li>"; fi

export AUDIT_HTML="<p><span style='color:#ffcc00; font-weight:bold;'>$WARNINGS_COUNT Warnings</span> | <span style='color:#00d2ff; font-weight:bold;'>$SUGGESTIONS_COUNT Sugerencias</span></p>
<p style='color:#64748b; font-size:13px;'>$TESTS_DONE tests de seguridad ejecutados</p>
<div style='margin-top:15px;'>
    <h4 style='color:#ff3366; border-bottom:1px solid #334155; padding-bottom:5px; margin-bottom:10px;'>Detalles de Warnings</h4>
    <ul style='list-style-type:none; padding-left:0; margin:0;'>$WARNINGS_DETAILS</ul>
</div>
<div style='margin-top:15px;'>
    <h4 style='color:#0ea5e9; border-bottom:1px solid #334155; padding-bottom:5px; margin-bottom:10px;'>Detalles de Sugerencias</h4>
    <ul style='list-style-type:none; padding-left:0; margin:0;'>$SUGGESTIONS_DETAILS</ul>
</div>"





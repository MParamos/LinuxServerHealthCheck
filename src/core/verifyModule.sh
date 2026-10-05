#!/bin/bash
# ==============================================================================
# @file      verifyModule.sh
# @brief     Utility to verify an individual module interactively.
# @author Miguel Páramos (www.miguelparamos.com)
#
# This file belongs to the LinuxServerHealthCheck framework.
# ==============================================================================
MODULES_DIR="$(dirname "$0")/../modules"

clear
echo "=== Module Verifier ==="

if [ ! -d "$MODULES_DIR" ] || [ -z "$(ls -A "$MODULES_DIR")" ]; then
    echo "No modules installed."
    exit 1
fi

echo "Available modules:"
i=1
declare -a MOD_ARRAY
for mod in "$MODULES_DIR"/*; do
    if [ -d "$mod" ]; then
        MOD_NAME=$(basename "$mod")
        MOD_ARRAY[$i]=$MOD_NAME
        echo "$i) $MOD_NAME"
        i=$((i+1))
    fi
done

echo ""
read -p "Select a module to verify (1-$((i-1))): " SELECTION

if [ -z "${MOD_ARRAY[$SELECTION]}" ]; then
    echo "Invalid selection."
    exit 1
fi

SELECTED_MOD="${MOD_ARRAY[$SELECTION]}"
echo ""
echo "[*] Running detailed verification for: $SELECTED_MOD"
"$(dirname "$0")/check_module_integrity.sh" "$SELECTED_MOD" "verbose"

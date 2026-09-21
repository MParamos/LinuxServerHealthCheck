#!/bin/bash
# ==============================================================================
# @file      check_module_integrity.sh
# @brief     Verifies the structural integrity of a module before loading.
# @author Miguel Páramos (www.miguelparamos.com)
#
# This file belongs to the LinuxServerHealthCheck framework.
# ==============================================================================
MODULE=$1
VERBOSE=$2
DIR="$(dirname "$0")/../modules/$MODULE"

if [ ! -d "$DIR" ]; then
    echo "Directorio no encontrado"
    exit 1
fi

missing_files=0
MISSING_LIST=""
# ------------------------------------------------------------------------------
# @brief Executes the check_file routine.
# ------------------------------------------------------------------------------
check_file() {
    if [ ! -f "$DIR/$1" ]; then
        MISSING_LIST="$MISSING_LIST$1, "
        missing_files=$((missing_files + 1))
    fi
}
check_file "module.sh"
check_file "template.html"
check_file "README.md"
check_file "LICENSE"

if [ ! -d "$DIR/locales" ]; then
    MISSING_LIST="${MISSING_LIST}locales/, "
    missing_files=$((missing_files + 1))
fi

if [ $missing_files -gt 0 ]; then
    echo "$MISSING_LIST" | sed 's/, $//'
    exit 1
else
    exit 0
fi

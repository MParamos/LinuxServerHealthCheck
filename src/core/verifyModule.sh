#!/bin/bash
# ==============================================================================
# @file      verifyModule.sh
# @brief     Helper to verify active modules and install dependencies.
# @author Miguel Páramos (www.miguelparamos.com)
#
# This file belongs to the LinuxServerHealthCheck framework.
# ==============================================================================
# Script interactivo para verificar la integridad de un módulo

cd "$(dirname "$0")/../modules"

echo "=== Verificador de Módulos ==="
folders=(*/)
if [ ${#folders[@]} -eq 0 ] || [ "${folders[0]}" = "*/" ]; then
    echo "No hay módulos instalados."
    exit 1
fi

echo "Módulos disponibles:"
i=1
declare -A MOD_MAP
for d in "${folders[@]}"; do
    MOD_NAME=$(basename "$d")
    echo "$i) $MOD_NAME"
    MOD_MAP[$i]=$MOD_NAME
    ((i++))
done

echo ""
read -p "Selecciona un módulo para verificar (1-$((i-1))): " selection

if [ -z "${MOD_MAP[$selection]}" ]; then
    echo "Selección no válida."
    exit 1
fi

SELECTED_MOD="${MOD_MAP[$selection]}"
echo ""
echo "[*] Ejecutando verificación detallada para: $SELECTED_MOD"

# Llamar al subscript que hace el trabajo real
../core/check_module_integrity.sh "$SELECTED_MOD" "verbose"


#!/bin/bash
# ==============================================================================
# @file      sync_modules.sh
# @brief     Synchronizes host modules with the container environment.
# @author Miguel Páramos (www.miguelparamos.com)
#
# This file belongs to the LinuxServerHealthCheck framework.
# ==============================================================================
# Limpia módulos no listados en ModulesInReport.conf pero que tienen carpeta.

source /etc/healthcheck.conf
MYSQL_CMD="mysql -h 127.0.0.1 -P 33060 -u root -p${DB_ROOT_PASSWORD:-supersecret123} healthcheck -sN -e"

CONF_FILE="/usr/local/bin/ModulesInReport.conf"
MODULES_DIR="/usr/local/bin/src/modules"

# Obtener lista de módulos activos (ignorando líneas vacías)
active_modules=$(grep -v '^$' "$CONF_FILE")

# Buscar todas las carpetas
for mod_dir in "$MODULES_DIR"/*/; do
    [ ! -d "$mod_dir" ] && continue
    mod_name=$(basename "$mod_dir")
    
    # Comprobar si mod_name NO está en active_modules
    if ! echo "$active_modules" | grep -qx "$mod_name"; then
        # El módulo tiene carpeta pero no está en el conf.
        # Ejecutar cleanup.sql si existe
        if [ -f "$mod_dir/cleanup.sql" ]; then
            echo "[SYNC] Limpiando base de datos del módulo desactivado: $mod_name"
            mysql -h 127.0.0.1 -P 33060 -u root -p${DB_ROOT_PASSWORD:-supersecret123} healthcheck < "$mod_dir/cleanup.sql"
        fi
    fi
done

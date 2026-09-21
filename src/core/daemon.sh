#!/bin/bash
# ==============================================================================
# @file      daemon.sh
# @brief     Background daemon orchestrating the cron schedule.
# @author Miguel Páramos (www.miguelparamos.com)
#
# This file belongs to the LinuxServerHealthCheck framework.
# ==============================================================================
# Daemon modular de LinuxServerHealthCheck

source /etc/healthcheck.conf

MYSQL_CMD="mysql -h 127.0.0.1 -P 33060 -u root -p${DB_ROOT_PASSWORD:-supersecret123} healthcheck -sN -e"

# Asegurar tablas base
$MYSQL_CMD "CREATE TABLE IF NOT EXISTS reports (id INT AUTO_INCREMENT PRIMARY KEY, report_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP);"

CONF_FILE="/usr/local/bin/ModulesInReport.conf"

while true; do
    if [ -f "$CONF_FILE" ]; then
        active_modules=$(grep -v '^$' "$CONF_FILE")
        
        for MOD in $active_modules; do
            MOD_DIR="/usr/local/bin/src/modules/$MOD"
            
            # Asegurar la base de datos del módulo (schema.sql)
            if [ -f "$MOD_DIR/schema.sql" ]; then
                mysql -h 127.0.0.1 -P 33060 -u root -p${DB_ROOT_PASSWORD:-supersecret123} healthcheck < "$MOD_DIR/schema.sql"
            fi
            
            # Ejecutar script de recolección en segundo plano si existe
            if [ -f "$MOD_DIR/collect.sh" ]; then
                source "$MOD_DIR/collect.sh"
            fi
        done
    fi
    sleep 60
done

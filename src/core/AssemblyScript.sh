#!/bin/bash
# ==============================================================================
# @file      AssemblyScript.sh
# @brief     Main orchestrator script. Loads modules securely and compiles the final HTML report.
# @author Miguel Páramos (www.miguelparamos.com)
#
# This file belongs to the LinuxServerHealthCheck framework.
# ==============================================================================
# ==========================================
# LinuxServerHealthCheck AssemblyScript
# Orchestrator for modular reports
# ==========================================

export LANG=C.UTF-8
export LC_ALL=C.UTF-8
START_TIME_EPOCH=$(date +%s)


set -a
source /etc/healthcheck.conf
export MACHINE_UPPER="$(echo ${MACHINE_NAME:-Server} | tr a-z A-Z)"
export MACHINE="${MACHINE_NAME:-Server}"
if [ -f "/usr/local/bin/src/core/locales/${LANGUAGE:-en}.sh" ]; then
    source "/usr/local/bin/src/core/locales/${LANGUAGE:-en}.sh"
else
    source "/usr/local/bin/src/core/locales/en.sh"
fi
set +a

MYSQL_CMD="mysql -h 127.0.0.1 -P 33060 -u root -p${DB_ROOT_PASSWORD:-supersecret123} healthcheck -sN -e"

# 1. Ejecutar sync_modules para limpiar basura antes de generar reporte
/usr/local/bin/src/core/sync_modules.sh

# 2. Fechas
export LAST_AUDIT_DATE=$($MYSQL_CMD "SELECT DATE_FORMAT(report_date, '%Y-%m-%d %H:%i:%S') FROM reports ORDER BY id DESC LIMIT 1;")
if [ -z "$LAST_AUDIT_DATE" ]; then export LAST_AUDIT_DATE="${L_NEVER}"; fi

# 3. Inicializar Reporte (El header se ensambla al final para tener la hora exacta)
REPORT_FILE="/tmp/report_assembled.html"
REPORT_BODY="/tmp/report_body.html"
> "$REPORT_BODY"

echo "${L_START_ANALYSIS}"

# 4. Procesar módulos listados
CONF_FILE="/usr/local/bin/ModulesInReport.conf"
if [ ! -f "$CONF_FILE" ]; then
    echo "Error: ModulesInReport.conf no encontrado."
    exit 1
fi

active_modules=$(grep -v '^$' "$CONF_FILE")

for MOD in $active_modules; do
    MOD_DIR="/usr/local/bin/src/modules/$MOD"
    
    # Comprobar integridad
    INTEGRITY_ERRORS=$(/usr/local/bin/src/core/check_module_integrity.sh "$MOD" "silent")
    if [ $? -ne 0 ]; then
        echo "${L_CAUTION} Módulo $MOD falló la prueba de integridad: Faltan $INTEGRITY_ERRORS"
        
        ERR_TITLE_es="Error de Integridad"
        ERR_TITLE_en="Integrity Error"
        ERR_TITLE_fr="Erreur d'intégrité"
        
        ERR_DESC_es="El módulo <strong>$MOD</strong> no cumple con las reglas de integridad y ha sido bloqueado por seguridad. Faltan los siguientes archivos clave:"
        ERR_DESC_en="The <strong>$MOD</strong> module does not comply with integrity rules and has been blocked for security. The following key files are missing:"
        ERR_DESC_fr="Le module <strong>$MOD</strong> ne respecte pas les règles d'intégrité et a été bloqué par sécurité. Les fichiers clés suivants sont manquants:"
        
        LANG_TITLE="ERR_TITLE_${LANGUAGE:-en}"
        LANG_DESC="ERR_DESC_${LANGUAGE:-en}"
        
        echo "<div class='module-container' style='border-left: 4px solid #ff3366;'>" >> "$REPORT_BODY"
        echo "    <h3 class='module-title' style='color:#ff3366;'>🚨 ${!LANG_TITLE}</h3>" >> "$REPORT_BODY"
        echo "    <p style='color:#cbd5e1; font-size:14px; margin-bottom:10px;'>${!LANG_DESC}</p>" >> "$REPORT_BODY"
        echo "    <p style='color:#ffcc00; font-family:monospace; margin:0; padding-left:15px; border-left: 2px solid #ffcc00;'>$INTEGRITY_ERRORS</p>" >> "$REPORT_BODY"
        echo "</div>" >> "$REPORT_BODY"
        continue
    fi
    
    # Ejecutar carga de idioma, lógica y renderizado en subshell aislado
    (
        set -a
        if [ -f "$MOD_DIR/locales/${LANGUAGE:-en}.sh" ]; then
            source "$MOD_DIR/locales/${LANGUAGE:-en}.sh"
        elif [ -f "$MOD_DIR/locales/en.sh" ]; then
            source "$MOD_DIR/locales/en.sh"
        fi
        set +a

        # Ejecutar lógica
        source "$MOD_DIR/module.sh"
        
        # Inyectar plantilla procesada a la salida estándar
        envsubst < "$MOD_DIR/template.html"
    ) >> "$REPORT_BODY"
done

# 5. Ensamblar todo (Header + Body + Footer) con la fecha final
END_TIME_EPOCH=$(date +%s)
export START_TIME=$(date "+%Y-%m-%d %H:%M:%S") # Reutilizamos la variable START_TIME para que el template la pille como la hora de finalizacion
export DURATION=$((END_TIME_EPOCH - START_TIME_EPOCH))

envsubst < /usr/local/bin/src/templates/header.html > "$REPORT_FILE"
cat "$REPORT_BODY" >> "$REPORT_FILE"
envsubst < /usr/local/bin/src/templates/footer.html >> "$REPORT_FILE"

# 6. Enviar correo
if [ "$MANUAL_RUN" = "1" ]; then SUBJECT="[LinuxServerHealthCheck] Auditoría MANUAL de $MACHINE"; else SUBJECT="[LinuxServerHealthCheck] Auditoría de $MACHINE"; fi
if command -v msmtp &> /dev/null; then
    {
        echo "To: ${DESTINATION_EMAIL}"
        echo "From: ${SMTP_USER}"
        echo "Subject: ${SUBJECT}"
        echo "Content-Type: text/html; charset=UTF-8"
        echo "MIME-Version: 1.0"
        echo ""
        cat "$REPORT_FILE"
    } | msmtp -a default "${DESTINATION_EMAIL}"
else
    mail -s "${SUBJECT}" -a "Content-Type: text/html; charset=UTF-8" "${DESTINATION_EMAIL}" < "$REPORT_FILE"
fi

if [ $? -eq 0 ]; then
    echo "${L_CLI_EMAIL_OK}"
    
    # 7. Registrar en DB base
    $MYSQL_CMD "INSERT INTO reports (report_date) VALUES ('$START_TIME');"
    
    # 8. Purgar/Limpiar cada módulo activo
    for MOD in $active_modules; do
        if [ -f "/usr/local/bin/src/modules/$MOD/prune.sh" ]; then
            ( source "/usr/local/bin/src/modules/$MOD/prune.sh" )
        fi
    done
    
    echo "${L_CLI_DB_PRUNED}"
else
    echo "${L_CLI_EMAIL_FAIL}"
fi

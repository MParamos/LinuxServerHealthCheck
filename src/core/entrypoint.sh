#!/bin/bash
# ==============================================================================
# @file      entrypoint.sh
# @brief     Docker entrypoint to initialize environment, cron, and start the daemon.
# @author Miguel Páramos (www.miguelparamos.com)
#
# This file belongs to the LinuxServerHealthCheck framework.
# ==============================================================================
echo "Starting LinuxServerHealthCheck Entrypoint..."

# Dump Docker native environment variables to a secure internal file for Cron usage
export -p > /etc/healthcheck.conf
chmod 400 /etc/healthcheck.conf

# Set default timezone if provided
if [ -n "$TZ" ]; then
    ln -fs /usr/share/zoneinfo/$TZ /etc/localtime
    echo $TZ > /etc/timezone
    echo "Timezone set to $TZ"
fi

# Setup postfix/msmtp
cat <<EOT > /etc/msmtprc
defaults
auth           on
tls            on
tls_trust_file /etc/ssl/certs/ca-certificates.crt
logfile        /var/log/msmtp.log

account        default
host           ${SMTP_HOST}
port           ${SMTP_PORT}
from           ${SMTP_FROM:-$SMTP_USER}
user           ${SMTP_USER}
password       ${SMTP_PASS}
EOT

chmod 600 /etc/msmtprc

# Setup Cron Job
CRON_SCHEDULE=${CRON_SCHEDULE:-"0 3 * * 1"}
echo "$CRON_SCHEDULE root /usr/local/bin/src/core/AssemblyScript.sh >> /var/log/cron.log 2>&1" > /etc/cron.d/healthcheck-cron
chmod 0644 /etc/cron.d/healthcheck-cron
crontab /etc/cron.d/healthcheck-cron
echo "Cron schedule set to: $CRON_SCHEDULE"

# Start cron daemon in background
cron

# Start background daemon for metrics (DB logic)
/usr/local/bin/src/core/daemon.sh &

echo "Container is running. Waiting for scheduled jobs..."
# Keep main process alive
tail -f /dev/null

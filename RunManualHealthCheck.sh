#!/bin/bash
# ==========================================
# Run LinuxServerHealthCheck Manual Trigger
# ==========================================

cd "$(dirname "$0")"

# Load config
if [ -f .env ]; then
    set -a
    source .env
    set +a
fi

LANGUAGE=${LANGUAGE:-en}
if [ -f "src/core/locales/${LANGUAGE}.sh" ]; then
    source "src/core/locales/${LANGUAGE}.sh"
else
    source "src/core/locales/en.sh"
fi

CONTAINER_NAME="linuxserverhealthcheck_${MACHINE_NAME:-MyServer}"

# Verify if container is running
if [ "$(docker inspect -f '{{.State.Running}}' $CONTAINER_NAME 2>/dev/null)" != "true" ]; then
    echo "[!] Error triggering LinuxServerHealthCheck. Is the container running?"
    exit 1
fi

echo "${L_CLI_MANUAL_TRIG} $CONTAINER_NAME"
docker exec -e MANUAL_RUN=1 $CONTAINER_NAME /usr/local/bin/src/core/AssemblyScript.sh

echo "${L_CLI_SUCCESS}"

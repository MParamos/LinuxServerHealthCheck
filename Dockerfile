FROM ubuntu:24.04

# Avoid prompts during apt installations
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    cron \
    curl \
    jq \
    gettext-base \
    msmtp \
    msmtp-mta \
    mailutils \
    mariadb-client

COPY src /usr/local/bin/src
COPY ModulesInReport.conf /usr/local/bin/ModulesInReport.conf

RUN apt-get update && \
    find /usr/local/bin/src/modules -name "packages.txt" -exec cat {} + | tr '\n' ' ' | xargs -r apt-get install -y && \
    rm -rf /var/lib/apt/lists/*

RUN chmod +x /usr/local/bin/src/core/AssemblyScript.sh /usr/local/bin/src/core/entrypoint.sh /usr/local/bin/src/core/daemon.sh /usr/local/bin/src/core/check_module_integrity.sh /usr/local/bin/src/core/sync_modules.sh /usr/local/bin/src/core/verifyModule.sh

ENTRYPOINT ["/usr/local/bin/src/core/entrypoint.sh"]

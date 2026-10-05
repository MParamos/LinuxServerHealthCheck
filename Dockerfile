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
    grep -v '^#' /usr/local/bin/ModulesInReport.conf | grep -v '^$' | while read mod; do \
        if [ -f "/usr/local/bin/src/modules/$mod/packages.txt" ]; then \
            cat "/usr/local/bin/src/modules/$mod/packages.txt"; \
            echo " "; \
        fi; \
    done | tr '\n' ' ' | xargs -r apt-get install -y && \
    rm -rf /var/lib/apt/lists/*

RUN chmod +x /usr/local/bin/src/core/AssemblyScript.sh /usr/local/bin/src/core/entrypoint.sh /usr/local/bin/src/core/daemon.sh /usr/local/bin/src/core/check_module_integrity.sh /usr/local/bin/src/core/sync_modules.sh /usr/local/bin/src/core/verifyModule.sh

ENTRYPOINT ["/usr/local/bin/src/core/entrypoint.sh"]

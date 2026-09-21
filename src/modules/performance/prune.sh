# ==============================================================================
# @file      prune.sh
# @brief     Cron-based database pruning script for the Performance module.
# @author Miguel Páramos (www.miguelparamos.com)
#
# This file belongs to the LinuxServerHealthCheck framework.
# ==============================================================================
mysql -h 127.0.0.1 -P 33060 -u root -p${DB_ROOT_PASSWORD:-supersecret123} healthcheck -e "TRUNCATE TABLE mod_performance_metrics;"

# ==============================================================================
# @file      prune.sh
# @brief     Cron-based database pruning script for the Reliability module.
# @author Miguel Páramos (www.miguelparamos.com)
#
# This file belongs to the LinuxServerHealthCheck framework.
# ==============================================================================
$MYSQL_CMD "TRUNCATE TABLE mod_reliability_net;"

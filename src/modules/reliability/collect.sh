# ==============================================================================
# @file      collect.sh
# @brief     Cron-based data collection script for the Reliability module.
# @author Miguel Páramos (www.miguelparamos.com)
#
# This file belongs to the LinuxServerHealthCheck framework.
# ==============================================================================
if ping -c 1 8.8.8.8 &> /dev/null; then
    NET_STATUS=1
else
    NET_STATUS=0
fi
$MYSQL_CMD "INSERT INTO mod_reliability_net (net_status) VALUES ($NET_STATUS);"

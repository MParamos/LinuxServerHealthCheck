-- =============================================================================
-- @file      schema.sql
-- @brief     Database schema definitions for the Reliability module.
-- @author Miguel Páramos (www.miguelparamos.com)
-- =============================================================================
CREATE TABLE IF NOT EXISTS mod_reliability_net (
    id INT AUTO_INCREMENT PRIMARY KEY,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    net_status INT
);

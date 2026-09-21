-- =============================================================================
-- @file      schema.sql
-- @brief     Database schema definitions for the Performance module.
-- @author Miguel Páramos (www.miguelparamos.com)
-- =============================================================================
CREATE TABLE IF NOT EXISTS mod_performance_metrics (
    id INT AUTO_INCREMENT PRIMARY KEY,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    cpu_temp INT,
    gpu_temp INT,
    load_perc INT,
    ram_used INT
);

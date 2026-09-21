# Performance Module

- **What it is:** A LinuxServerHealthCheck module, created by [Miguel Páramos](https://www.miguelparamos.com).
- **Author:** [Miguel Páramos](https://www.miguelparamos.com)

## Description
Monitors and logs real-time system performance metrics including CPU temperature, GPU temperature, System Load (1-minute average), and RAM utilization. It maintains a historical record to provide minimum, average, and maximum values since the last audit.

## Verification
**Why this is a valid LinuxServerHealthCheck module:**
This module strictly adheres to the architecture of LinuxServerHealthCheck. It provides the required `module.sh` to extract the data, a `template.html` for presentation, and isolated SQL/collection scripts when necessary. It respects the decentralized design, ensuring it can be dynamically loaded or cleanly uninstalled without affecting the core system.

## License
This module is distributed under the MIT License. See the [LICENSE](LICENSE) file for more details.

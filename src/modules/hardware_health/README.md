# Hardware Health Module

- **What it is:** A LinuxServerHealthCheck module, created by [Miguel Páramos](https://www.miguelparamos.com).
- **Author:** [Miguel Páramos](https://www.miguelparamos.com)

## Description
Performs deep physical hardware analysis using S.M.A.R.T. data and `hdparm`. It reads the health status of all connected drives, benchmarks raw read speeds, and provides an estimated remaining lifespan percentage. Note: A 0% remaining lifespan does not mean the disk will immediately fail, but rather that it could start developing errors at any moment.

## Verification
**Why this is a valid LinuxServerHealthCheck module:**
This module strictly adheres to the architecture of LinuxServerHealthCheck. It provides the required `module.sh` to extract the data, a `template.html` for presentation, and isolated SQL/collection scripts when necessary. It respects the decentralized design, ensuring it can be dynamically loaded or cleanly uninstalled without affecting the core system.

## License
This module is distributed under the MIT License. See the [LICENSE](LICENSE) file for more details.

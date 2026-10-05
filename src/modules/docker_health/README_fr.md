# Module de Santé Docker

- **What it is:** A LinuxServerHealthCheck module, created by [Miguel Páramos](https://www.miguelparamos.com).
- **Author:** [Miguel Páramos](https://www.miguelparamos.com)

## Description
Surveille l'état du démon Docker et des conteneurs en cours d'exécution. Il identifie les conteneurs qui se sont arrêtés de manière inattendue ou qui échouent, aidant à maintenir la disponibilité des microservices.

## Verification
**Why this is a valid LinuxServerHealthCheck module:**
This module strictly adheres to the architecture of LinuxServerHealthCheck. It provides the required `module.sh` to extract the data, a `template.html` for presentation, and isolated SQL/collection scripts when necessary. It respects the decentralized design, ensuring it can be dynamically loaded or cleanly uninstalled without affecting the core system.

## License
This module is distributed under the MIT License. See the [LICENSE](LICENSE) file for more details.

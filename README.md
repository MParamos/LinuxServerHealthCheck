[🇪🇸 Español](#español) | [🇬🇧 English](#english) | [🇫🇷 Français](#français)

---

### 📚 Online Documentation
- [🇪🇸 Leer la documentación en Español](https://MParamos.github.io/LinuxServerHealthCheck/es/index.html)
- [🇬🇧 Read the English documentation](https://MParamos.github.io/LinuxServerHealthCheck/en/index.html)
- [🇫🇷 Lire la documentation en Français](https://MParamos.github.io/LinuxServerHealthCheck/fr/index.html)

---

<a name="español"></a>
# LinuxServerHealthCheck Centinela (Español)

Una herramienta de monitorización y auditoría de servidores ligera, autocontenida y basada en Docker. Realiza comprobaciones periódicas de los recursos vitales de su servidor, analiza el hardware en busca de fallos tempranos, escanea vulnerabilidades y le envía un informe HTML detallado por correo electrónico.


## 🏗️ Arquitectura y Persistencia (Novedad)
El proyecto sigue un patrón **MVC (Modelo-Vista-Controlador)** limpio para una máxima mantenibilidad:
- **Controlador**: El núcleo en Bash (`src/LinuxServerHealthCheck.sh`) orquesta el análisis, interactúa con la base de datos y cruza la información.
- **Vista**: Una plantilla HTML (`src/templates/report.html`) independiente, fácilmente personalizable sin necesidad de tocar código lógico.
- **Modelo/Locales**: Traducciones abstraídas en `src/locales/` para facilitar la expansión a otros idiomas.

**Persistencia SQL con MariaDB**: 
El contenedor ya no guarda los datos históricos de forma efímera. LinuxServerHealthCheck despliega su propio contenedor `mariadb` de forma automática.
- Los historiales de temperatura, caídas de red y picos de estrés se guardan en SQL.
- El directorio `./db_data` se mapea localmente. **Para hacer una copia de seguridad total, solo necesitas copiar la carpeta del proyecto**.
- El script de análisis realiza limpiezas automáticas post-informe para asegurar que la base de datos no crezca indefinidamente, conservando solo los agregados históricos permanentes.

## 🔒 Modelo de Seguridad "Submarino"
Puede resultar llamativo que este contenedor requiera `privileged: true` y acceda a las rutas del host (`/host`). **Esto es completamente seguro e intencionado**:
1. **Necesidad de Root**: Para poder auditar de verdad un servidor (leer registros SMART del disco duro, detectar ataques SSH en `/var/log` y buscar malware de bajo nivel con Lynis) se necesitan privilegios absolutos.
2. **Cero Puertos Inbound**: El contenedor **no abre ningún puerto hacia el exterior**. Se comporta como un "submarino" que solo lee el sistema, guarda los datos en su base de datos local aislada (puerto `33060` mapeado solo en localhost) y *dispara* un correo hacia afuera. Al no tener interfaz web ni escuchar peticiones entrantes, es inexpugnable desde Internet salvo que el servidor host ya esté comprometido.

## 🐧 Compatibilidad Universal con Linux
El contenedor detecta dinámicamente tu sistema operativo anfitrión. Ya uses **Debian, Ubuntu, Fedora, CentOS, Arch, SteamOS o Bazzite**, el script auditará automáticamente tus actualizaciones usando `apt`, `dnf`, `pacman` o `zypper`, y leerá los ataques SSH usando archivos físicos o conectándose directamente a `journalctl` (Systemd).

## Librerías y Tests Realizados

LinuxServerHealthCheck Centinela utiliza herramientas de nivel industrial para garantizar que su servidor esté sano y seguro. Cada informe se compone de las siguientes verificaciones:

1. **Estado Vital (CPU y RAM)**:
   - *Test*: Comprueba la temperatura del procesador, la carga media del sistema (relativa a los núcleos de CPU) y el consumo de RAM.
   - *Por qué*: Para evitar cuelgues del sistema, sobrecalentamientos térmicos y cuellos de botella en el procesamiento.
   - *Librerías*: `lm-sensors` (para leer los sensores térmicos de la placa base) y comandos nativos como `free` y `uptime`.

2. **Salud del Hardware y Almacenamiento**:
   - *Test*: Mide la velocidad de lectura física y consulta los registros internos de errores de los discos.
   - *Por qué*: Los discos (incluso los SSD/NVMe) pueden degradarse y fallar silenciosamente, provocando pérdida de datos.
   - *Librerías*: `hdparm` (para tests de rendimiento y cuellos de botella) y `smartmontools / smartctl` (para leer la telemetría S.M.A.R.T. de fábrica del disco, detectar sectores dañados o errores de integridad).

3. **Salud del Sistema Operativo**:
   - *Test*: Busca actualizaciones pendientes del sistema base y procesos zombis colgados.
   - *Por qué*: Mantener el sistema actualizado cierra brechas de seguridad conocidas (Zero-days). Limpiar procesos zombis previene fugas de memoria.
   - *Librerías*: Gestor de paquetes `apt` y comandos nativos `ps`.

4. **Auditoría de Seguridad y Red**:
   - *Test*: Realiza más de 400 pruebas de seguridad, verifica los puertos expuestos a internet, busca usuarios fantasma con permisos de root (UID 0) y cuenta los ataques de fuerza bruta por SSH.
   - *Por qué*: Para detectar intrusiones, configuraciones de red erróneas y puertas traseras (backdoors) antes de que sean explotadas.
   - *Librerías*: `lynis` (escáner avanzado que evalúa miles de configuraciones del sistema, desde firewalls hasta módulos del kernel), `ss` (análisis de sockets de red) y lectura directa de `/var/log/auth.log` y `/etc/shadow`.

## Inicio Rápido

1. Clone o descargue este repositorio.
2. Copie la plantilla de configuración:
   ```bash
   cp .env.template .env
   ```
3. Edite el archivo `.env` con sus credenciales SMTP, su programación y el nombre del servidor.
4. Construya y ejecute el contenedor:
   ```bash
   docker compose build --no-cache
   docker compose up -d
   ```

## Configuración (`.env`)

- `MACHINE_NAME`: El nombre del servidor que se mostrará en el informe.
- `LANGUAGE`: Idioma del informe HTML (`en`, `es`, `fr`).
- `DESTINATION_EMAIL`: Dónde se enviará el informe.
- `CRON_SCHEDULE`: Cuándo ejecutar el informe automáticamente utilizando sintaxis cron estándar (ej., `0 4 * * 1` para todos los lunes a las 04:00 AM).
- `ALLOWED_PORTS`: Lista de puertos separados por espacios que se espera que estén abiertos.

## Ejecución Manual

Puede lanzar un LinuxServerHealthCheck manual en cualquier momento:
```bash
./DoLinuxServerHealthCheckNow.sh
```

## Advertencia de Seguridad para Puertos Autorizados
Al listar puertos en la variable `ALLOWED_PORTS`, usted reconoce que comprende su propósito y acepta los riesgos de seguridad. Estos puertos omitirán las advertencias de alerta roja en el informe. Si una puerta trasera maliciosa utiliza uno de estos puertos, es de su exclusiva responsabilidad.

## Licencia
Este proyecto y su contenedor son propiedad de [Miguel Páramos](https://www.miguelparamos.com) y están licenciados bajo la GNU General Public License v3 (GPLv3). Consulte el archivo [LICENSE](LICENSE) para más detalles.

---

<a name="english"></a>
# LinuxServerHealthCheck Sentinel (English)

A lightweight, Docker-based, self-contained server monitoring and auditing tool. It performs regular checks on your server's vital resources, analyzes hardware for early failures, scans for vulnerabilities, and emails you a detailed HTML report.


## 🏗️ Architecture and Persistence (New)
The project follows a clean **MVC (Model-View-Controller)** pattern for maximum maintainability:
- **Controller**: The Bash core (`src/LinuxServerHealthCheck.sh`) orchestrates the analysis, interacts with the database, and processes information.
- **View**: A standalone HTML template (`src/templates/report.html`), easily customizable without touching logical code.
- **Model/Locales**: Translations abstracted in `src/locales/` to facilitate expansion to other languages.

**SQL Persistence with MariaDB**: 
The container no longer saves historical data ephemerally. LinuxServerHealthCheck deploys its own `mariadb` container automatically.
- Temperature histories, network drops, and stress peaks are saved in SQL.
- The `./db_data` directory is mapped locally. **To make a full backup, you only need to copy the project folder**.
- The analysis script performs automatic post-report cleanups to ensure the database doesn't grow indefinitely, keeping only permanent historical aggregates.

## 🔒 "Submarine" Security Model
It might be surprising that this container requires `privileged: true` and accesses host paths (`/host`). **This is completely secure and intentional**:
1. **Root Necessity**: To truly audit a server (read SMART logs from the hard drive, detect SSH attacks in `/var/log`, and scan for low-level malware with Lynis), absolute privileges are required.
2. **Zero Inbound Ports**: The container **does not open any ports to the outside**. It acts like a "submarine" that only reads the system, saves data in its isolated local database (port `33060` mapped only to localhost), and *fires* an email outwards. Having no web interface and not listening to incoming requests makes it impregnable from the Internet unless the host server is already compromised.

## 🐧 Universal Linux Compatibility
The container dynamically detects your host operating system. Whether you use **Debian, Ubuntu, Fedora, CentOS, Arch, SteamOS, or Bazzite**, the script will automatically audit your updates using `apt`, `dnf`, `pacman`, or `zypper`, and read SSH attacks using physical files or directly connecting to `journalctl` (Systemd).

## Libraries and Tests Performed

LinuxServerHealthCheck Sentinel uses industry-grade tools to ensure your server remains healthy and secure. Each report consists of the following checks:

1. **Vital State (CPU and RAM)**:
   - *Test*: Checks processor temperature, system load average (relative to CPU cores), and RAM consumption.
   - *Why*: To prevent system crashes, thermal throttling, and processing bottlenecks.
   - *Libraries*: `lm-sensors` (to read motherboard thermal sensors) and native commands like `free` and `uptime`.

2. **Hardware and Storage Health**:
   - *Test*: Measures physical read speed and queries internal disk error logs.
   - *Why*: Disks (even SSD/NVMe) can degrade and fail silently, leading to data loss.
   - *Libraries*: `hdparm` (for raw performance tests) and `smartmontools / smartctl` (to read S.M.A.R.T. factory telemetry, detecting damaged sectors and integrity errors).

3. **Operating System Health**:
   - *Test*: Looks for pending base system updates and hung zombie processes.
   - *Why*: Keeping the system updated closes known security gaps (Zero-days). Cleaning zombie processes prevents memory leaks.
   - *Libraries*: Package manager `apt` and native command `ps`.

4. **Security and Network Audit**:
   - *Test*: Runs over 400 security tests, checks ports exposed to the internet, looks for ghost users with root permissions (UID 0), and counts SSH brute force attacks.
   - *Why*: To detect intrusions, misconfigured network settings, and backdoors before they can be exploited.
   - *Libraries*: `lynis` (advanced scanner that evaluates thousands of system settings, from firewalls to kernel modules), `ss` (network socket analysis), and direct reading of `/var/log/auth.log` and `/etc/shadow`.

## 📖 Official Documentation

Full documentation (Architecture, Module Development, Troubleshooting) is available at: **[LinuxServerHealthCheck Documentation](https://your-username.github.io/LinuxServerHealthCheck/)**

## Quick Start

1. Clone or download this repository.
2. Copy the configuration template:
   ```bash
   cp .env.template .env
   ```
3. Edit the `.env` file with your SMTP credentials, schedule, and server name.
4. Build and run the container:
   ```bash
   docker compose build --no-cache
   docker compose up -d
   ```

## Configuration (`.env`)

- `MACHINE_NAME`: The name of the server to be displayed in the report.
- `LANGUAGE`: Language of the HTML report (`en`, `es`, `fr`).
- `DESTINATION_EMAIL`: Where the report will be sent.
- `CRON_SCHEDULE`: When to run the report automatically using standard cron syntax (e.g., `0 4 * * 1` for every Monday at 4:00 AM).
- `ALLOWED_PORTS`: A space-separated list of ports that are expected to be open.

## Manual Execution

You can trigger a manual LinuxServerHealthCheck at any time:
```bash
./DoLinuxServerHealthCheckNow.sh
```

## Security Warning for Authorized Ports
By listing ports in the `ALLOWED_PORTS` variable, you acknowledge that you understand their purpose and accept the security risks. They will bypass the red alert warnings in the report. If a malicious backdoor uses one of these ports, it is solely your responsibility.

## License
This project and its container are property of [Miguel Páramos](https://www.miguelparamos.com) and are licensed under the GNU General Public License v3 (GPLv3). See the [LICENSE](LICENSE) file for details.

---

<a name="français"></a>
# LinuxServerHealthCheck Sentinelle (Français)

Un outil léger, basé sur Docker et autonome pour la surveillance et l'audit de serveurs. Il effectue des vérifications régulières des ressources vitales de votre serveur, analyse le matériel à la recherche de défaillances précoces, recherche les vulnérabilités, et vous envoie un rapport HTML détaillé.


## 🏗️ Architecture et Persistance (Nouveau)
Le projet suit un modèle **MVC (Modèle-Vue-Contrôleur)** propre pour une maintenabilité maximale :
- **Contrôleur** : Le cœur en Bash (`src/LinuxServerHealthCheck.sh`) orchestre l'analyse, interagit avec la base de données et croise les informations.
- **Vue** : Un modèle HTML (`src/templates/report.html`) indépendant, facilement personnalisable sans toucher au code logique.
- **Modèle/Locales** : Traductions abstraites dans `src/locales/` pour faciliter l'expansion vers d'autres langues.

**Persistance SQL avec MariaDB** : 
Le conteneur ne sauvegarde plus les données historiques de manière éphémère. LinuxServerHealthCheck déploie automatiquement son propre conteneur `mariadb`.
- Les historiques de température, les pannes réseau et les pics de stress sont sauvegardés en SQL.
- Le répertoire `./db_data` est mappé localement. **Pour faire une sauvegarde complète, il suffit de copier le dossier du projet**.
- Le script d'analyse effectue des nettoyages automatiques post-rapport pour s'assurer que la base de données ne croisse pas indéfiniment, ne conservant que les agrégats historiques permanents.

## 🔒 Modèle de Sécurité "Sous-marin"
Il peut être surprenant que ce conteneur nécessite `privileged: true` et accède aux chemins de l'hôte (`/host`). **C'est complètement sécurisé et intentionnel** :
1. **Nécessité de Root** : Pour auditer véritablement un serveur (lire les journaux SMART du disque dur, détecter les attaques SSH dans `/var/log` et rechercher des malwares de bas niveau avec Lynis), des privilèges absolus sont nécessaires.
2. **Zéro Port Entrant** : Le conteneur **n'ouvre aucun port vers l'extérieur**. Il se comporte comme un "sous-marin" qui ne fait que lire le système, sauvegarde les données dans sa base de données locale isolée (port `33060` mappé uniquement sur localhost) et *envoie* un e-mail vers l'extérieur. N'ayant pas d'interface web et n'écoutant aucune requête entrante, il est imprenable depuis Internet à moins que le serveur hôte ne soit déjà compromis.

## 🐧 Compatibilité Linux Universelle
Le conteneur détecte dynamiquement votre système d'exploitation hôte. Que vous utilisiez **Debian, Ubuntu, Fedora, CentOS, Arch, SteamOS ou Bazzite**, le script auditera automatiquement vos mises à jour en utilisant `apt`, `dnf`, `pacman` ou `zypper`, et lira les attaques SSH en utilisant des fichiers physiques ou en se connectant directement à `journalctl` (Systemd).

## Bibliothèques et Tests Effectués

LinuxServerHealthCheck Sentinelle utilise des outils de niveau industriel pour garantir que votre serveur reste sain et sécurisé. Chaque rapport comprend les vérifications suivantes :

1. **État Vital (CPU et RAM)** :
   - *Test* : Vérifie la température du processeur, la charge moyenne du système (relative aux cœurs CPU) et la consommation de RAM.
   - *Pourquoi* : Pour éviter les plantages du système, la surchauffe thermique et les goulots d'étranglement de traitement.
   - *Bibliothèques* : `lm-sensors` (pour lire les capteurs thermiques) et commandes natives comme `free` et `uptime`.

2. **Santé du Matériel et Stockage** :
   - *Test* : Mesure la vitesse de lecture physique et interroge les journaux d'erreurs internes des disques.
   - *Pourquoi* : Les disques (même SSD/NVMe) peuvent se dégrader et tomber en panne silencieusement.
   - *Bibliothèques* : `hdparm` (pour les tests de performance) et `smartmontools / smartctl` (pour lire la télémétrie d'usine S.M.A.R.T., détectant les secteurs endommagés).

3. **Santé du Système d'Exploitation** :
   - *Test* : Recherche les mises à jour système en attente et les processus zombies bloqués.
   - *Pourquoi* : Maintenir le système à jour comble les failles de sécurité. Nettoyer les zombies prévient les fuites de mémoire.
   - *Bibliothèques* : Gestionnaire de paquets `apt` et commande native `ps`.

4. **Audit de Sécurité et Réseau** :
   - *Test* : Exécute plus de 400 tests de sécurité, vérifie les ports exposés, recherche les utilisateurs fantômes avec permissions root (UID 0) et compte les attaques par force brute SSH.
   - *Pourquoi* : Pour détecter les intrusions, les erreurs réseau et les portes dérobées avant qu'elles ne soient exploitées.
   - *Bibliothèques* : `lynis` (scanner avancé évaluant des milliers de paramètres système), `ss` (analyse des sockets) et lecture directe de `/var/log/auth.log` et `/etc/shadow`.

## Démarrage Rapide

1. Clonez ou téléchargez ce dépôt.
2. Copiez le modèle de configuration :
   ```bash
   cp .env.template .env
   ```
3. Modifiez le fichier `.env` avec vos identifiants SMTP, votre planification et le nom du serveur.
4. Construisez et exécutez le conteneur :
   ```bash
   docker compose build --no-cache
   docker compose up -d
   ```

## Configuration (`.env`)

- `MACHINE_NAME` : Le nom du serveur à afficher dans le rapport.
- `LANGUAGE` : Langue du rapport HTML (`en`, `es`, `fr`).
- `DESTINATION_EMAIL` : Où le rapport sera envoyé.
- `CRON_SCHEDULE` : Quand exécuter le rapport automatiquement en utilisant la syntaxe cron standard (ex: `0 4 * * 1` pour tous les lundis à 04:00 AM).
- `ALLOWED_PORTS` : Une liste séparée par des espaces des ports censés être ouverts.

## Exécution Manuelle

Vous pouvez lancer un LinuxServerHealthCheck manuel à tout moment :
```bash
./DoLinuxServerHealthCheckNow.sh
```

## Avertissement de Sécurité pour les Ports Autorisés
En listant des ports dans la variable `ALLOWED_PORTS`, vous reconnaissez comprendre leur fonction et acceptez les risques de sécurité. Ils contourneront les avertissements rouges. Si une porte dérobée (backdoor) malveillante utilise l'un de ces ports, c'est de votre entière responsabilité.

## Licence
Ce projet et son conteneur sont la propriété de [Miguel Páramos](https://www.miguelparamos.com) et sont sous licence GNU General Public License v3 (GPLv3). Consultez le fichier [LICENSE](LICENSE) pour plus de détails.

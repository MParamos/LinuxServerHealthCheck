# Network Security Module

- **Qué es:** Un módulo de LinuxServerHealthCheck, creado por [Miguel Páramos](https://www.miguelparamos.com).
- **Autor:** [Miguel Páramos](https://www.miguelparamos.com)

## Descripción
Monitoriza la superficie de ataque de la red listando todos los puertos de escucha expuestos y resaltando aquellos no autorizados. También analiza los registros de autenticación SSH para contar inicios de sesión exitosos e intentos de ataque de fuerza bruta.

## Verificación
**Por qué este es un módulo válido de LinuxServerHealthCheck:**
Este módulo se adhiere estrictamente a la arquitectura de LinuxServerHealthCheck. Proporciona el archivo `module.sh` requerido para extraer los datos, una plantilla `template.html` para su presentación y scripts aislados de SQL o recolección cuando es necesario. Respeta el diseño descentralizado, asegurando que se pueda cargar de forma dinámica o desinstalar limpiamente sin afectar al sistema central.

## Licencia
Este módulo se distribuye bajo la licencia MIT. Consulte el archivo [LICENSE](LICENSE) para más detalles.

# Top Ram Module

- **Qué es:** Un módulo de LinuxServerHealthCheck, creado por [Miguel Páramos](https://www.miguelparamos.com).
- **Autor:** [Miguel Páramos](https://www.miguelparamos.com)

## Descripción
Identifica los procesos que consumen más memoria RAM, detallando su PID, usuario, porcentaje de memoria y comando en ejecución para ayudar a diagnosticar fugas de memoria o cargas pesadas.

## Verificación
**Por qué este es un módulo válido de LinuxServerHealthCheck:**
Este módulo se adhiere estrictamente a la arquitectura de LinuxServerHealthCheck. Proporciona el archivo `module.sh` requerido para extraer los datos, una plantilla `template.html` para su presentación y scripts aislados de SQL o recolección cuando es necesario. Respeta el diseño descentralizado, asegurando que se pueda cargar de forma dinámica o desinstalar limpiamente sin afectar al sistema central.

## Licencia
Este módulo se distribuye bajo la licencia MIT. Consulte el archivo [LICENSE](LICENSE) para más detalles.

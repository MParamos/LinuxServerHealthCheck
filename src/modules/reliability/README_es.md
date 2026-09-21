# Reliability Module

- **Qué es:** Un módulo de LinuxServerHealthCheck, creado por [Miguel Páramos](https://www.miguelparamos.com).
- **Autor:** [Miguel Páramos](https://www.miguelparamos.com)

## Descripción
Rastrea los eventos vitales del ciclo de vida del sistema. Reporta el tiempo de actividad actual, la hora exacta de inicio y la marca de tiempo del último apagado correcto. También implementa controles heurísticos para detectar cortes de energía inesperados o fallos del sistema.

## Verificación
**Por qué este es un módulo válido de LinuxServerHealthCheck:**
Este módulo se adhiere estrictamente a la arquitectura de LinuxServerHealthCheck. Proporciona el archivo `module.sh` requerido para extraer los datos, una plantilla `template.html` para su presentación y scripts aislados de SQL o recolección cuando es necesario. Respeta el diseño descentralizado, asegurando que se pueda cargar de forma dinámica o desinstalar limpiamente sin afectar al sistema central.

## Licencia
Este módulo se distribuye bajo la licencia MIT. Consulte el archivo [LICENSE](LICENSE) para más detalles.

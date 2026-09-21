# Hardware Health Module

- **Qué es:** Un módulo de LinuxServerHealthCheck, creado por [Miguel Páramos](https://www.miguelparamos.com).
- **Autor:** [Miguel Páramos](https://www.miguelparamos.com)

## Descripción
Realiza un análisis físico profundo del hardware utilizando datos S.M.A.R.T. y `hdparm`. Lee el estado de salud de todos los discos conectados, mide la velocidad bruta de lectura y proporciona una estimación del porcentaje de vida útil restante. Nota: El hecho de que este porcentaje llegue a cero no quiere decir que el disco vaya a dejar de funcionar inmediatamente, sino que podría comenzar a tener errores en cualquier momento.

## Verificación
**Por qué este es un módulo válido de LinuxServerHealthCheck:**
Este módulo se adhiere estrictamente a la arquitectura de LinuxServerHealthCheck. Proporciona el archivo `module.sh` requerido para extraer los datos, una plantilla `template.html` para su presentación y scripts aislados de SQL o recolección cuando es necesario. Respeta el diseño descentralizado, asegurando que se pueda cargar de forma dinámica o desinstalar limpiamente sin afectar al sistema central.

## Licencia
Este módulo se distribuye bajo la licencia MIT. Consulte el archivo [LICENSE](LICENSE) para más detalles.

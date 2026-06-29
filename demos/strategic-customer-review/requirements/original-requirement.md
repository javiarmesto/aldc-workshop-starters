# Control de clientes estratégicos

El cliente quiere marcar algunos clientes como estratégicos.

En la ficha del cliente habría que añadir un check para indicar si el cliente es estratégico y una fecha para saber cuándo hay que volver a revisarlo.

La fecha debería ser obligatoria para los clientes estratégicos y no debería poder ponerse una fecha anterior a hoy.

Los campos deberían verse también en la lista de clientes para que el usuario pueda consultar y filtrar esta información.

Sería bueno que aparecieran juntos en una sección nueva de la ficha.

## Problemas del requisito

Este requisito es realista, pero deja decisiones abiertas:

- Qué ocurre si se desmarca el indicador.
- Si la fecha se borra automáticamente o se conserva.
- Cuándo se valida la obligatoriedad.
- Si puede introducirse primero la fecha y después activar el indicador.
- Qué páginas exactas deben modificarse.
- Qué significa hoy: fecha del sistema o WorkDate de Business Central.
- Cómo se comprueba que la solución funciona.
- Qué queda fuera del alcance.

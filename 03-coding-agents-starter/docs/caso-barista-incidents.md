# Contexto · Barista Incidents

> Este es el material de partida del caso de uso para el Bloque 03.
> Formato: un hilo de correo interno como el que llega cualquier lunes.
> Nada de specs formales todavía — eso lo va a producir `al-architect`
> y `al-spec.create` a partir de este material.

---

**De:** Marta Gutiérrez `<m.gutierrez@cafelatte-operations.com>`
**Para:** Carlos Ruiz `<c.ruiz@partner-it.es>`; Laura Méndez `<l.mendez@partner-it.es>`
**CC:** David Ortega `<d.ortega@cafelatte-operations.com>`
**Asunto:** Proyecto BC · módulo para incidencias de barras
**Fecha:** lunes, 14 de abril de 2026, 09:47

Hola Carlos, Laura,

Como comentamos la semana pasada en la reunión de dirección, vamos a dar el paso
de meter las incidencias de las cafeterías dentro de Business Central en vez de
seguir con los Excels y los grupos de WhatsApp que tenemos ahora. Lleva meses siendo
un caos y con la apertura de las tres cafeterías nuevas este trimestre ya no da más
de sí.

Os paso lo que tenemos pensado para que le deis forma técnica. Es un resumen de lo
que hablamos el viernes con los jefes de turno y con Jaime (operaciones).

**El problema**

Cada día nos pasan incidencias en las cafeterías que hay que resolver rápido: se
rompe una máquina de espresso, falta leche de avena, un cliente se queja de que el
café estaba frío, se bloquea el TPV. Ahora mismo el barista le manda un WhatsApp al
encargado, el encargado lo anota en una hoja de Excel compartida en OneDrive, y
cuando el técnico de mantenimiento llega por la tarde mira qué tiene que hacer.

No sabemos cuánto tardamos en resolver cada tipo de incidencia. No sabemos qué
máquinas se rompen más. No podemos cerrar la semana con un informe decente. Y cuando
se abre una cafetería nueva, tenemos que explicarle al encargado de turno que esto
funciona así porque sí.

**Lo que queremos**

Una aplicación dentro de BC — donde ya tenemos clientes, facturación y nóminas —
para que el barista pueda meter la incidencia desde una pantalla sencilla. No vale
una pantalla compleja. El 70% de los baristas son gente joven de fines de semana
que no va a leer un manual. Tiene que ser: abro la pantalla, pulso "Nueva
incidencia", elijo qué tipo, escribo dos líneas, y listo.

Las incidencias que hemos identificado, por ahora, son cuatro tipos:

- **Avería de máquina** (espresso, molinillo, vaporizador, lavavajillas de bar)
- **Falta de suministro** (leche, café, azúcar, vasos, servilletas)
- **Queja de cliente** (café frío, espera larga, error en cobro, atención)
- **Problema de sistema** (TPV colgado, datáfono no va, impresora de tickets)

Cada incidencia tiene una **severidad**. Probablemente tres niveles sean
suficientes — bajo, medio, alto — pero esto lo tenéis que concretar vosotros.
La severidad alta debería avisar por push al técnico de guardia.

Cada incidencia tiene que **asignarse automáticamente** al equipo que le
corresponda según el tipo: las averías van al equipo de mantenimiento, los
problemas de sistema al equipo IT, los suministros al responsable de compras de
zona, las quejas al encargado de tienda. Esto tiene que ser configurable —
cuando abrimos una cafetería nueva no queremos tocar código para meterle el
técnico asignado.

Cuando la incidencia se resuelve, queremos **registrar quién la resolvió, cuánto
tardó y una nota breve**. Esto es oro para el informe semanal.

**El informe semanal**

Los lunes por la mañana, en la reunión de dirección, queremos ver en el Role Center
un panel con:

- Incidencias de la semana pasada, por tipo
- Tiempo medio de resolución por tipo
- Top 3 cafeterías con más incidencias
- Top 3 máquinas con más averías (si aplica)

No hace falta que sea un Power BI con mil filtros. Con unos números grandes y un
par de barras nos vale. Si queréis lo hacéis como tiles del Role Center estándar,
no hay problema.

**Integraciones**

Mantenimiento tiene su propio sistema (es un SaaS externo que usa una empresa
subcontratada). Cuando se crea una incidencia de tipo "Avería de máquina" con
severidad alta, queremos que se les notifique **automáticamente por API** para
que ellos abran su propio ticket interno. Ellos ya tienen un endpoint REST que
usan otras de nuestras empresas. Os pasaré la documentación en una segunda
ronda si os hace falta.

Aparte de eso, el equipo de datos nos ha pedido que expongamos las incidencias
como **API v2.0 de BC** para ellos poder tirar de ahí para el data warehouse.
Esto es importante porque ya no queremos seguir exportando Excels.

**Seguridad y permisos**

- Los baristas tienen que poder **crear** incidencias pero no modificar ni
  cerrar las de otros
- Los encargados pueden **ver todo lo de su tienda** y cerrar incidencias
- Los técnicos ven lo que les está asignado
- Los de oficina (nosotros, dirección) vemos todo

En BC ya tenemos roles para cajero y encargado con la parte de ventas. Habrá que
añadir los de este módulo sin pisar los existentes.

**Tiempos y alcance**

Nos gustaría tener una primera versión funcionando en la cafetería piloto del
centro antes de final de mayo. Con eso — crear y resolver incidencias,
asignación automática, informe básico en Role Center y la API para datos. La
integración con mantenimiento externo la podemos dejar para una segunda iteración
si hace falta, aunque sería ideal tenerla el día uno.

¿Cuándo podemos vernos para que nos planteéis cómo lo atacáis técnicamente? La
próxima semana tengo huecos martes y jueves por la tarde.

Un abrazo,
**Marta**

Marta Gutiérrez
Directora de Operaciones · Cafélatte Group
m.gutierrez@cafelatte-operations.com · +34 96X XXX XXX

---

## Notas para el equipo técnico

> Apunte del partner tras leer el correo — no enviado a Marta.

Cosas que al-architect tendrá que decidir y reflejar en las ADRs:

- ¿Cuántas tablas? Mínimo `Incident`, probablemente `Incident Type`, `Incident
  Severity`, y una tabla de configuración de asignación automática.
- ¿Los tipos de incidencia son Enum fijo o tabla configurable? El correo insinúa
  que quieren configurabilidad — apunta a tabla.
- ¿Cómo se estructura la asignación automática? Matriz Tipo × Tienda → Equipo.
- ¿La severidad "alta" dispara notificación push y llamada al API externo · dos
  integration events distintos o uno solo?
- Role Center tiles: ¿extendemos el Business Manager Role Center o creamos uno
  nuevo para "Operations Manager"?
- La API externa de mantenimiento · necesitará un codeunit cliente HTTP con
  manejo de errores y reintentos · posible candidato para mover a la segunda
  iteración si aprieta el tiempo.
- Permisos: dos sets (`CEB Incidents Basic` para baristas/encargados locales,
  `CEB Incidents Full` para técnicos/oficina).

## Qué se espera que produzcas en el Bloque 03

No se implementa código AL en este bloque. Solo:

1. **`barista-incidents.architecture.md`** · generado por `al-architect`
   - Skills applied (al top)
   - ADRs numerados con alternativas consideradas
   - Modelo de datos (qué tablas, relaciones, cardinalidades)
   - APIs expuestas (v2.0, bound actions, queries)
   - Events publicados
   - Estrategia de permisos
2. **`barista-incidents.spec.md`** · generado por el workflow `al-spec.create`
   - Expande la arquitectura a spec ejecutable
   - Lista de objetos concreta con ID tentativo, campos, dependencias
   - Casos de prueba esperados
   - Plan de fases para el conductor

El conductor (`al-conductor`) y sus tres subagentes (`al-planning`,
`al-implement`, `al-review`) **no se ejecutan en este bloque**. Se ven en
acción en el Bloque 04, cuando los asistentes los aplican ellos mismos.

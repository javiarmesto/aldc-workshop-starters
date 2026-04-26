# Contexto del Caso: CRONUS USA, Inc. — Barista Incidents

**Documento**: Contexto de negocio del proyecto
**Proyecto**: Barista Incidents
**Cliente**: CRONUS USA, Inc.
**Preparado por**: Equipo CRONUS tras reunión de kick-off
**Reunión de kick-off celebrada**: jueves 16 de abril de 2026
**Asistentes por CRONUS**:
- JP — Jefe de Proyecto (punto único de contacto)
- Consultor Funcional de Atención al Cliente
- Consultor Técnico de Sistemas
- Director Técnico de Business Central
**Destinatario**: Equipo de implantación del partner
**Fecha de entrega del documento**: viernes 17 de abril de 2026
**Versión documental**: 1.0-workshop
**Estado**: Entregado. Pendiente de acuse de recibo y propuesta inicial del partner.

---

## 0. Origen de este documento

Este documento recoge el contexto de negocio expuesto por el equipo de CRONUS USA, Inc. durante la reunión de kick-off del proyecto **Barista Incidents**, celebrada el jueves 16 de abril de 2026 en oficinas del cliente.

La reunión duró aproximadamente dos horas. En el primer tramo, JP presentó la situación operativa y la motivación del proyecto. En el segundo tramo, el Consultor Funcional describió los flujos de atención al cliente actuales y los puntos de dolor. El Consultor Técnico aportó el contexto de los sistemas satélite (chatbot web, portal incipiente, sistemas de monitorización de almacén) que podrían integrarse en fases futuras. El Director Técnico de BC validó que el planteamiento es coherente con la arquitectura actual de Business Central en CRONUS y marcó los límites de lo que el partner debería respetar.

Este documento, junto con el **documento 02** (Requerimientos Funcionales) y el **documento 03** (PRD Técnico), conforma el paquete inicial que CRONUS entrega al partner para iniciar el proyecto.

---

## 1. La empresa

**CRONUS USA, Inc.** es una compañía norteamericana especializada en el abastecimiento de cafeterías profesionales y baristas independientes. Su catálogo actual combina dos líneas principales:

- **Café en grano tostado** (prefijo `WRB-*` en el catálogo de artículos: *Whole Roasted Beans*), con orígenes de Colombia, Brasil, Indonesia, México, Kenia, Costa Rica, Etiopía y Hawái.
- **Café en grano descafeinado** (prefijo `WDB-*`: *Whole Decaf Beans*), con los mismos orígenes geográficos.

CRONUS distribuye estos productos a cafeterías, hoteles, restaurantes y obradores de toda Norteamérica. Según datos compartidos por JP en la reunión, la empresa mueve decenas de toneladas mensuales y mantiene activa una cartera de más de 300 clientes profesionales.

## 2. El cliente tipo: el barista

El cliente habitual de CRONUS es un **profesional barista** que trabaja con máquinas de espresso industriales y exige una calidad de grano estable. Según describió el Consultor Funcional en la reunión, este cliente tiene expectativas muy específicas:

- **Consistencia del producto**: una variación en el perfil de tueste le arruina la carta del día.
- **Tiempo de entrega**: la rotación de grano es alta; un retraso significa ventas perdidas.
- **Trazabilidad**: muchos baristas informan a sus clientes finales del origen del grano y exigen documentación clara.
- **Soporte ágil**: cuando algo va mal (un lote defectuoso, un pedido equivocado, una máquina que consume más de lo previsto), necesitan resolución rápida.

El Consultor Funcional insistió en un punto: el barista no es un cliente pasivo. Reporta incidencias a través de **múltiples canales simultáneamente**, y espera que el canal elegido no le suponga una penalización en el tiempo de respuesta. Los canales actualmente en uso incluyen llamadas telefónicas al comercial, correos electrónicos al soporte, conversaciones de WhatsApp con el representante regional y, crecientemente, consultas a asistentes de IA en la web de CRONUS.

## 3. El problema operativo — lo que JP expuso en la reunión

Hoy CRONUS gestiona las incidencias de sus clientes barista de forma dispersa:

- El equipo de atención al cliente las anota en una hoja de cálculo compartida en SharePoint.
- Los comerciales las apuntan en sus notas personales (libretas, OneNote, agendas).
- Los responsables de calidad registran las quejas por defecto de producto en un sistema aparte, propio del departamento.
- El portal web de CRONUS tiene un formulario de contacto que envía emails a una bandeja genérica leída de forma irregular.

JP resumió las consecuencias con una frase que conviene retener: *"no es que no queramos atender al barista; es que cuando nos llama no sabemos ni lo que nos ha contado la semana pasada"*. Las consecuencias operativas detalladas en la reunión:

- Pérdida de información entre canales (la llamada del martes no la conoce quien recibe el email del jueves).
- Duplicación de incidencias cuando un cliente reporta el mismo problema por dos vías distintas.
- Falta de visibilidad del estado: nadie en CRONUS sabe cuántas incidencias hay abiertas en un momento dado.
- Imposibilidad de analizar tendencias: qué orígenes de grano generan más quejas, qué clientes concentran más incidencias, qué canales están saturados.

## 4. La visión del proyecto — lo que CRONUS espera del partner

CRONUS quiere centralizar la gestión de incidencias dentro del sistema donde ya vive toda la información operativa: **Business Central**. El proyecto lleva el nombre interno **Barista Incidents** por el enfoque deliberado en el cliente barista, aunque la herramienta servirá para cualquier tipo de incidencia que un cliente reporte.

Durante la reunión, JP y el Director Técnico de BC acordaron cuatro principios rectores para la **versión 1.0 inicial**:

**Centralizado**. Toda incidencia vive en Business Central. Punto.

**Integrado con el maestro de clientes**. La incidencia conoce al cliente. Esto permite analizar patrones por cliente, priorizar por valor del cliente, y dar contexto completo al agente de soporte cuando atiende una llamada.

**Orientado al uso operativo diario**. El agente de soporte debe tener un punto de entrada visual claro (Role Center) que le diga en cuánto entra al sistema qué incidencias tiene que atender hoy, cuántas críticas hay sin asignar y cómo relanzar la configuración si necesita regenerar datos de formación.

**Manejable en alcance**. La versión 1.0 debe estar operativa en 2-3 semanas de implantación. JP fue claro: *"quiero algo útil en tres semanas, no algo perfecto en tres meses"*.

El Director Técnico de BC añadió un quinto principio orientado a fases futuras: *"queremos tener puerta abierta a integrar chatbots y agentes de IA más adelante, pero eso no puede condicionar el alcance de la v1.0. Primero consolidamos el uso interno y luego abrimos al exterior"*.

## 5. Los actores del sistema

Dentro de CRONUS, tres perfiles van a interactuar con Barista Incidents, según describió el Consultor Funcional:

**Agente de soporte**. Recibe las llamadas y emails de los clientes barista. Necesita crear incidencias con rapidez, consultar el historial de un cliente, añadir notas conforme avanza la resolución, y cerrar el caso con una síntesis clara. Es el usuario habitual del sistema. Hay actualmente 6 personas en este perfil en CRONUS.

**Responsable de atención al cliente**. Supervisa al equipo de agentes. Necesita ver el volumen de incidencias abiertas, las críticas sin resolver, y las tendencias por categoría. Configura el sistema (categorías, técnicos disponibles, numeración, permisos) y puede generar datos de demostración para formar a nuevos agentes. En CRONUS este rol lo ostenta la persona del Consultor Funcional que asistió a la reunión.

**Técnico de soporte**. Personal asignado a resolver incidencias. Es importante destacar que **los técnicos no son necesariamente usuarios de Business Central**: pueden ser personal de campo, técnicos de mantenimiento o personal de calidad que no tiene licencia BC pero sí nombre y responsabilidad sobre incidencias concretas. Por eso el sistema debe tener un maestro propio de técnicos, independiente del maestro de usuarios de BC. El Director Técnico de BC lo explicó así: *"no queremos que tener una licencia Essential sea prerrequisito para que a una persona se le pueda asignar un caso"*.

## 6. Fuera de alcance — explícito y acordado

En la reunión se acordó de forma explícita lo que **NO** entra en la versión 1.0. Esta lista es un acuerdo del equipo CRONUS completo (JP + los 3 consultores) y debe respetarse por el partner sin reabrir negociación salvo cambio formal de alcance:

- No hay cálculo automático de SLAs ni fechas de compromiso contractuales.
- No hay notificaciones por email al cliente cuando cambia el estado de su incidencia.
- No hay flujos de aprobación (todo el equipo de soporte tiene autoridad completa sobre sus incidencias).
- No hay portal de cliente integrado (viene en fase posterior).
- No hay adjuntos de archivos en esta versión.
- No hay métricas avanzadas ni dashboards de Power BI (viene en fase posterior).
- No hay encuestas de satisfacción post-resolución.
- **No hay API REST externa para consumo de chatbots o sistemas externos** (planificado para fase 2 del proyecto, una vez consolidado el uso interno).

Esta lista no es un rechazo del valor de esas funciones. El Director Técnico de BC lo resumió claramente: *"empezar con un sistema sólido y acotado es más inteligente que intentar resolverlo todo desde el primer día, sobre todo porque nos queremos comer el elefante a bocados"*.

Sobre el punto de la API, JP fue más específico: *"la API la queremos, pero no la queremos en la v1.0. Primero validamos que el equipo de soporte usa bien el sistema, luego abrimos al chatbot. Una cosa cada vez"*.

## 7. Por qué este caso es representativo para el partner

Aunque la ambientación es el sector barista, el patrón **gestor de incidencias con Role Center operativo y maestro propio de técnicos** aplica a prácticamente cualquier empresa B2B que:

- Tenga una base de clientes recurrentes.
- Reciba incidencias por múltiples canales.
- Use Business Central como ERP.
- Tenga personal de soporte/técnico que no necesariamente tiene licencia BC.

El Director Técnico de BC lo planteó como argumento en favor de abordar el proyecto: *"si lo resolvemos bien aquí, el patrón es reutilizable para otros tres o cuatro verticales donde tenemos clientes en cartera"*.

Por eso este caso es útil como ejemplo formativo: una vez entendida la arquitectura aplicada a CRONUS y sus baristas, es inmediato mapearla al caso real de cualquier otra organización.

## 8. Acuerdos de la reunión de kick-off

En la reunión del jueves 16 de abril se acordaron formalmente los siguientes puntos:

1. **Alcance cerrado** según el contenido de este documento 01, el documento 02 (requerimientos funcionales) y el documento 03 (PRD técnico). Cualquier ampliación requiere change request formal.
2. **Target de entorno**: desarrollo sobre sandbox de CRONUS con la empresa demo **CRONUS USA, Inc.** como base de datos de trabajo.
3. **Metodología**: CRONUS autoriza al partner a utilizar la metodología **ALDC** (desarrollo asistido por agentes) en todas las fases del proyecto, con HITL gates (revisiones humanas) en los puntos clave. El Director Técnico de BC y el Consultor Técnico de Sistemas participarán como revisores de arquitectura respectivamente.
4. **Cronograma orientativo**: 2-3 semanas de desarrollo efectivo, con posibilidad de entrega en fases si el partner lo considera oportuno.
5. **Interlocutor único**: JP actúa como punto único de contacto. Cualquier consulta del partner se canaliza a través de él.
6. **Próxima reunión**: revisión de arquitectura una vez el partner haya pasado los documentos por el pipeline ALDC y tenga la `architecture.md` propuesta. Plazo sugerido: una semana desde la entrega de estos documentos.
7. **Fase 2 planificada**: una vez entregada y validada la v1.0, el equipo de CRONUS y el partner evaluarán la apertura a integración externa (API REST, chatbot, portal de cliente) como alcance diferenciado de una fase 2. No es compromiso, es intención.
8. **Documentación operativa**: el partner entregará a CRONUS al cierre del proyecto un dossier con arquitectura, especificación técnica, resúmenes de fase y material de formación para el equipo de soporte.

---

*Fin del documento de contexto.*

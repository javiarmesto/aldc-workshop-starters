# Barista Incidents — Requerimientos Funcionales

**Documento**: Requerimientos funcionales del proyecto (visión de negocio)
**Proyecto**: Barista Incidents
**Cliente**: CRONUS USA, Inc.
**Preparado por**: Consultor Funcional de Atención al Cliente (CRONUS)
**Revisado por**: JP (Jefe de Proyecto) y Director Técnico de Business Central (CRONUS)
**Fecha de entrega**: viernes 17 de abril de 2026
**Versión**: 1.0-workshop
**Documentos relacionados**:
- `01-contexto-cronus-barista.md` (contexto de negocio y acta narrativa del kick-off)
- `03-barista-incidents-PRD-ALDC.md` (PRD técnico para el arquitecto de ALDC)

---

## 0. Origen de este documento

Este documento ha sido elaborado por el **Consultor Funcional de Atención al Cliente** de CRONUS en los días posteriores a la reunión de kick-off del 16 de abril de 2026, recogiendo los acuerdos funcionales alcanzados en esa reunión.

Ha sido revisado por **JP** como Jefe de Proyecto y por el **Director Técnico de Business Central** de CRONUS antes de su entrega al partner.

El presente documento describe **qué debe hacer** Barista Incidents desde el punto de vista del usuario y del negocio. No entra en cómo se implementa técnicamente en Business Central: eso queda para el **documento 03** (PRD Técnico para el arquitecto de ALDC).

---

## 1. Lo que el agente de soporte necesita poder hacer

### 1.1 Entrar al sistema y ver su día de trabajo de un vistazo

Al iniciar sesión en Business Central con el perfil de agente de soporte, el usuario debe aterrizar en un **Role Center dedicado** que le muestra de forma inmediata:

- Cuántas incidencias tiene asignadas él mismo y no están cerradas.
- Cuántas incidencias hay en el equipo sin asignar a nadie.
- Cuántas incidencias críticas hay sin resolver en toda la organización (con énfasis visual en rojo si hay al menos una).

El Role Center también debe tener tres acciones rápidas accesibles con un clic: crear una incidencia nueva, abrir la lista completa de incidencias, y relanzar el asistente de configuración.

No debe haber más elementos que los descritos. La norma es "sencillo pero efectivo": el agente necesita ver su trabajo del día, no un dashboard analítico.

### 1.2 Registrar una incidencia

Cuando un cliente barista llama por un problema, el agente debe poder crear una incidencia nueva con estos datos mínimos:

- **Una descripción corta** (para verla en los listados de un vistazo).
- **Una descripción detallada** (todo el contexto que el cliente dé).
- **Una categoría** (soporte técnico, facturación, logística, calidad, accesos, etc.).
- **Una prioridad** (baja, media, alta o crítica).
- **El cliente al que afecta** (opcional, porque a veces llama alguien que aún no está en el sistema).
- **Datos de contacto** del reportador (nombre, email, teléfono).
- **El canal por el que entró** (llamada, email, chat, portal, chatbot).
- **Una referencia externa** (número de ticket de otro sistema, si aplica).
- **Una fecha límite** (opcional).

El sistema debe asignarle un número único automáticamente (por ejemplo `INC-00042`). El agente no debe preocuparse por elegir un número.

### 1.3 Consultar sus incidencias

El agente debe tener acceso rápido a tres vistas filtradas por defecto:

- **Mis incidencias abiertas**: las asignadas al técnico actual, que no estén cerradas.
- **Todas las incidencias abiertas**: el estado general del equipo.
- **Incidencias críticas**: las de prioridad máxima sin resolver, sean de quien sean.

Estas vistas deben distinguirse visualmente por color del estado y de la prioridad, para que el agente detecte lo urgente con un vistazo.

### 1.4 Avanzar una incidencia por su ciclo de vida

El flujo de trabajo típico de una incidencia, acordado en la reunión de kick-off, es:

**Nueva** → el agente recibe el reporte y lo apunta.

**En Progreso** → el agente está trabajando activamente para resolverlo.

**Pendiente** → el agente está esperando algo. Hay dos variantes:
- **Pendiente Cliente**: esperando información del cliente (por ejemplo, un número de lote, una foto del defecto).
- **Pendiente Interno**: esperando a otro departamento dentro de CRONUS (calidad, logística, finanzas).

**Resuelta** → el agente considera que el problema está solucionado, pero aún no se ha cerrado formalmente.

**Cerrada** → la incidencia está terminada y archivada.

**Cancelada** → la incidencia se descarta (duplicado, error al crearla, reporte retirado por el cliente).

El agente debe poder mover la incidencia entre estos estados con un clic. El sistema debe impedir transiciones que no tengan sentido: por ejemplo, no se puede pasar de "Nueva" directamente a "Cerrada" sin pasar por "Resuelta". Este punto fue confirmado explícitamente por JP en la reunión.

### 1.5 Asignar incidencias a un técnico

Al principio, una incidencia nueva suele venir sin asignar. El agente o el responsable debe poder asignarla a un **técnico de soporte** con un clic.

Es **fundamental** entender que **los técnicos no son usuarios de Business Central**. Son personal de la empresa (campo, calidad, atención al cliente, mantenimiento) que puede o no tener licencia BC. Por eso el sistema gestiona su propio maestro de técnicos con datos relevantes: código corto (ejemplo `TECH001`, `MARIA`, `JP`), nombre, email de contacto, especialidad opcional (categoría en la que destaca), y un indicador de si está activo.

El responsable de soporte mantiene este maestro desde su propia lista. Cuando el agente asigna una incidencia, elige de este maestro, no del listado de usuarios BC.

Cuando se cambia la asignación, el sistema debe dejar constancia automática en el historial de la incidencia (comentario de tipo "Assignment" con el técnico anterior y el nuevo).

### 1.6 Añadir comentarios

Cada vez que el agente avanza en la resolución, debe poder añadir una nota al expediente: *"Llamado al cliente, confirma que el lote es el 2025-B-142"*, *"Abierta queja con el proveedor de Colombia"*, *"Facturación revisada, procede abono de 50 USD"*.

Estos comentarios son **permanentes**. No se pueden editar ni borrar, porque la trazabilidad del caso depende de que queden registrados tal cual se escribieron. Esto es importante para auditoría y para conversaciones futuras con el cliente (*"como le comenté el martes pasado..."*). Este requisito fue específicamente recalcado por el Director Técnico de BC por sus implicaciones de gobierno del dato.

### 1.7 Cerrar una incidencia con resolución

Al cerrar, el agente debe poder escribir una **síntesis de la resolución**: qué era el problema, qué se hizo, cuál fue el desenlace. Este texto se almacena en el propio expediente de la incidencia, no como un comentario más, porque es la conclusión canónica del caso.

---

## 2. Lo que el responsable de atención al cliente necesita poder hacer

Todo lo que hace un agente, más:

### 2.1 Configurar el sistema

La primera vez que se instala Barista Incidents, el responsable debe poder acceder a un **asistente de configuración** accesible de dos formas:

- Desde el buscador de BC (Tell Me) escribiendo "Incident Management Setup Wizard".
- Como tile en el Role Center del agente de soporte (para relanzarlo en cualquier momento).

El asistente tiene tres pasos:

**Paso 1 — Bienvenida**: pantalla explicativa del proceso.

**Paso 2 — Configuración de numeración**: el responsable elige cómo numerar las incidencias. Puede crear una serie por defecto (por ejemplo `INC-00001` a `INC-99999`) o seleccionar una serie numérica existente en Business Central.

**Paso 3 — Datos de ejemplo**: el responsable puede marcar una casilla para generar datos de demostración. Si lo hace, el sistema genera:
- 5 categorías de incidencias con códigos `DEMO-*` para distinguirlas de las operativas.
- 5 técnicos de soporte de ejemplo con códigos `DEMO-TECH-*`.
- 15 incidencias ficticias repartidas en distintos estados del ciclo de vida, vinculadas a **3 clientes ya existentes del maestro estándar de CRONUS USA** (el sistema no crea clientes nuevos, usa los que ya están).
- Comentarios coherentes en cada incidencia que reflejen su evolución real a través del ciclo de vida.

El sistema de generación es **idempotente**: si el responsable lanza el generador dos veces seguidas, no crea duplicados. Los datos demo tienen prefijos `DEMO-` que permiten al sistema reconocerlos y saltarlos en la segunda ejecución.

### 2.2 Mantener las categorías

Las categorías son el sistema de clasificación de las incidencias. El responsable debe poder crear categorías nuevas, modificar las existentes y desactivar las que ya no se usan.

Cada categoría tiene:
- Un código corto (por ejemplo, `TECH`, `BILL`, `QUAL`).
- Una descripción legible (*"Soporte Técnico"*, *"Facturación"*, *"Calidad de Producto"*).
- Una prioridad por defecto que se aplica automáticamente al crear una incidencia con esa categoría (el agente puede cambiarla después si lo necesita).

Las categorías iniciales acordadas para CRONUS en la reunión de kick-off son:
- `TECH` — Soporte Técnico (máquinas, equipamiento).
- `BILL` — Facturación (errores en albarán, incidencias de cobro).
- `LOG` — Logística (entregas, transporte, daños).
- `QUAL` — Calidad (defectos de producto, problemas de tueste, sabor inconsistente).

### 2.3 Mantener el maestro de técnicos

El responsable debe poder dar de alta nuevos técnicos, modificar los existentes y marcar como inactivos a los que ya no están disponibles.

Cada técnico tiene:
- Un código corto único (por ejemplo `MARIA`, `TECH001`).
- Un nombre completo.
- Un email de contacto.
- Una especialidad opcional (código de categoría donde ese técnico destaca).
- Un indicador de si está activo (solo los activos aparecen en la lista de asignación).

Los técnicos no son usuarios de Business Central: no necesitan licencia, no requieren cuenta Entra ID. Son simplemente personal interno asignable.

### 2.4 Gestionar permisos

El sistema define tres perfiles de acceso, según acuerdo con el Director Técnico de BC en la reunión:

- **Administrador**: acceso completo. Puede crear, modificar, borrar, configurar categorías, mantener técnicos, lanzar el generador de datos demo. Típicamente: el responsable de soporte y el IT Manager.
- **Usuario**: perfil del agente habitual. Puede crear incidencias, modificar las que tiene asignadas, añadir comentarios, asignar a técnicos. No puede mantener categorías ni técnicos ni lanzar el generador.
- **Consulta**: solo lectura. Para perfiles de dirección o auditoría que solo necesitan ver datos, nunca modificar.

Los perfiles se asignan desde la gestión estándar de permisos de Business Central.

---

## 3. Cómo se ve el sistema funcionando

Aunque este documento es funcional, es útil describir la experiencia visual para que los stakeholders se hagan una imagen mental:

**Role Center del agente de soporte**: pantalla inicial al entrar al sistema. Contiene dos grupos de tiles:
- Tres cues con contadores reales (Mis incidencias abiertas, Sin asignar, Críticas sin resolver).
- Tres acciones rápidas (Nueva incidencia, Ver todas, Relanzar wizard).

Sin headlines, sin gráficas, sin dashboards. Minimalista y operativo.

**Lista de incidencias**: tabla con número, descripción, cliente, estado, prioridad, técnico asignado, fecha de creación. Con filtros predefinidos en la parte superior (*"Mis Abiertas", "Todas Abiertas", "Críticas"*). Colores para distinguir estados y prioridades.

**Ficha de incidencia**: pantalla de detalle organizada en secciones (información general, descripción, contacto, origen, asignación a técnico, resolución). En el lado derecho, un FactBox que muestra el historial de comentarios en orden cronológico. Botones de acción rápida para cambiar estado, asignar a técnico o añadir comentario.

**Lista de categorías**: tabla simple con código, descripción y prioridad por defecto. Editable por el responsable.

**Lista de técnicos**: tabla con código, nombre, email, especialidad, activo. Editable por el responsable.

**Wizard de configuración**: pantalla con navegación paso a paso tipo "Siguiente / Atrás / Finalizar", con una barra de progreso en la parte superior.

---

## 4. Beneficios esperados del proyecto

**Para el agente de soporte**:
Visión centralizada de todas las incidencias al entrar al sistema. Información del cliente disponible en el mismo sistema donde se gestiona el pedido o la factura. Historial completo de cada caso en un solo lugar. Role Center que reduce clics y acelera la reacción a lo urgente.

**Para la dirección (JP y su equipo)**:
Visibilidad del volumen y el estado de incidencias en tiempo real. Base de datos limpia para medir tiempo medio de resolución. Identificación temprana de problemas recurrentes (un origen de grano que genera más quejas, un cliente que concentra muchas incidencias).

**Para el cliente**:
Seguimiento claro del estado de sus incidencias. Comunicación más fluida (el agente sabe qué ocurrió antes). Resolución más rápida al tener contexto completo desde el primer momento.

**Para la automatización futura** (visión de JP, **fase 2 del proyecto**):
Base lista para integrar agentes de IA en fase 2. Modelo de datos robusto sobre el que posteriormente construir una API REST para chatbots y portales de cliente. Primer paso para un futuro portal de cliente autoservicio.

---

## 5. Requisitos de plataforma

Barista Incidents requiere:

- Microsoft Dynamics 365 Business Central versión 27.0 o superior (SaaS Cloud u On-Premise).
- Usuarios con licencia Business Central Essential o Premium.
- No se requieren licencias BC para los técnicos de soporte (el maestro de técnicos es interno al módulo).

No hay dependencias de extensiones de terceros. El módulo se construye sobre la aplicación base de Business Central. El Director Técnico de BC ha confirmado que esto es compatible con la arquitectura actual de CRONUS.

---

## 6. Alcance de la versión 1.0 — lo que sí y lo que no

### Incluido

- ✅ Gestión completa del ciclo de vida de incidencias.
- ✅ Categorías y prioridades configurables.
- ✅ Maestro propio de técnicos (independiente de usuarios BC).
- ✅ Asignación de incidencias a técnicos desde lista interna.
- ✅ Historial de comentarios permanentes (append-only).
- ✅ Relación opcional con clientes del maestro estándar de BC.
- ✅ **Role Center dedicado** del agente de soporte con 3 cues y 3 acciones rápidas.
- ✅ Asistente de configuración inicial con opción de generar datos de ejemplo.
- ✅ Datos demo que usan clientes ya existentes del maestro CRONUS (no inventa clientes).
- ✅ Tres perfiles de permisos (Administrador, Usuario, Consulta).

### Fuera de alcance (acordado en la reunión de kick-off, candidatos a fase 2)

- ❌ Archivos adjuntos en las incidencias.
- ❌ Notificaciones automáticas por email.
- ❌ Acuerdos de nivel de servicio (SLA).
- ❌ Flujos de aprobación formal.
- ❌ Portal de cliente integrado.
- ❌ **API REST para integración externa con chatbots / agentes de IA** (prioridad alta para fase 2).
- ❌ Informes avanzados con Power BI.
- ❌ Categorización automática por IA.
- ❌ Encuestas de satisfacción.

JP fue muy claro sobre la API: *"la queremos, pero no la queremos en la v1.0. Primero validamos que el equipo de soporte usa bien el sistema, luego abrimos al chatbot"*.

---

## 7. Cronograma orientativo

Una implantación estándar de Barista Incidents toma **2 semanas** de trabajo efectivo si se parte de cero y se sigue la metodología ALDC:

- **Semana 1** — Arquitectura aprobada, especificación técnica revisada, primera fase construida (modelo de datos + permisos).
- **Semana 2** — Lógica de negocio, interfaz de usuario incluyendo Role Center, wizard de configuración, datos demo, formación del equipo de soporte, puesta en producción.

Este cronograma asume revisiones humanas en cada fase clave. No es un cronograma de "lanzarlo sin supervisión": ALDC produce código rápido, pero la decisión sobre qué construir y cómo integrarlo en la realidad operativa de CRONUS sigue siendo humana. El Director Técnico de BC participará como revisor en los puntos acordados.

La **fase 2** (API REST + integraciones externas) se planificaría tras el cierre de v1.0 con alcance y cronograma diferenciados.

---

## 8. Acuerdos de validación

Este documento se considera aprobado como fuente de verdad funcional del proyecto Barista Incidents v1.0. La firma siguiente es simbólica y representa el acuerdo alcanzado el 17 de abril de 2026:

- **Por CRONUS USA, Inc.**:
  - JP — Jefe de Proyecto
  - Consultor Funcional de Atención al Cliente
  - Consultor Técnico de Sistemas
  - Director Técnico de Business Central

- **Por el Partner** (pendiente): acuse de recibo y propuesta inicial tras paso por pipeline ALDC.

---

## Anexo: Glosario de negocio

| Término | Definición |
|---|---|
| **Incidencia** | Registro de un problema, consulta o solicitud reportada por un cliente barista |
| **Categoría** | Etiqueta que clasifica una incidencia según su naturaleza (técnico, facturación, logística, calidad) |
| **Prioridad** | Nivel de urgencia de la incidencia (Baja, Media, Alta, Crítica) |
| **Ciclo de vida** | Secuencia de estados por los que pasa una incidencia desde su creación hasta su cierre |
| **Técnico de soporte** | Persona interna de CRONUS asignable a una incidencia. **No es necesariamente usuario de Business Central**. Se gestiona en un maestro propio del módulo. |
| **Role Center** | Pantalla de inicio personalizada en Business Central que muestra los cues relevantes para un perfil de usuario |
| **Cue** | Tile visual con contador que representa una métrica operativa y es clicable para abrir una lista filtrada |
| **Datos de demostración** | Conjunto de datos ficticios identificables con prefijo `DEMO-`, usados para formación. Incluye categorías, técnicos e incidencias. Los clientes demo se eligen del maestro estándar de CRONUS, no se crean nuevos. |
| **HITL** | *Human in the Loop*: principio de la metodología ALDC según el cual un humano valida cada fase antes de avanzar |
| **ALDC** | Metodología de desarrollo asistido por agentes de IA que el partner ha propuesto y CRONUS ha aceptado para este proyecto |
| **Kick-off** | Reunión de arranque del proyecto, celebrada el 16 de abril de 2026 |
| **Fase 2** | Fase posterior a v1.0, no incluida en este alcance, destinada a integración externa (API REST, chatbots, portal de cliente) |

---

*Fin del documento de requerimientos funcionales.*

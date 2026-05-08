> 🇪🇸 Español | [🇬🇧 English](../../i18n/en/04-brownfield-starter/Requerimientos/03-barista-incidents-PRD-ALDC.md)

# Barista Incidents — PRD Técnico para ALDC Architect

**Documento**: PRD Técnico (fuente de entrada para `@al-architect` de ALDC)
**Proyecto**: Barista Incidents
**Cliente**: CRONUS USA, Inc.
**Preparado por**: Consultor Técnico de Sistemas (CRONUS), con revisión del Director Técnico de BC
**Fecha**: viernes 17 de abril de 2026
**Versión**: 1.0-workshop
**Audiencia**: AL Architect (ALDC) y analista técnico del partner
**Idioma de código y metadatos AL**: inglés. Este documento funcional en español.
**Documentos relacionados**:
- `01-contexto-cronus-barista.md` (contexto y acta narrativa del kick-off)
- `02-barista-incidents-requerimientos-funcionales.md` (requerimientos funcionales detallados)

---

## 0. Origen de este documento

Este documento es el **tercero de la terna** entregada por CRONUS al partner tras la reunión de kick-off del 16 de abril de 2026. Ha sido preparado por el **Consultor Técnico de Sistemas** de CRONUS, en colaboración con el **Director Técnico de Business Central**, para traducir el contenido funcional de los documentos 01 y 02 en un briefing técnico consumible por el pipeline ALDC del partner.

La decisión de entregar un PRD ya optimizado para ALDC fue propuesta por el Director Técnico de BC en la reunión de kick-off. El objetivo es **acelerar el primer ciclo** del pipeline: al recibir un PRD bien estructurado, el `@al-architect` del partner puede producir una `architecture.md` con mayor calidad y con menos iteraciones.

La redacción sigue el formato que el Director Técnico de BC sabe que funciona bien con ALDC: secciones diferenciadas, criterios de aceptación numerados, alcance explícito, patrones BC conocidos especificados con detalle para evitar errores comunes, y notas dedicadas al arquitecto al final.

---

## 1. Resumen Ejecutivo

### ¿Qué es Barista Incidents v1.0?

Una extensión para Microsoft Dynamics 365 Business Central que permite a CRONUS USA, Inc. gestionar incidencias de clientes barista de forma centralizada, con un Role Center dedicado para el agente de soporte y un maestro propio de técnicos asignables independiente del sistema de usuarios de BC.

### ¿Por qué se construye?

- Centralizar el seguimiento de incidencias en el mismo sistema donde está la información del cliente.
- Dar al agente de soporte un punto de entrada visual (Role Center) que priorice su trabajo diario.
- Permitir asignar incidencias a personal interno sin requerir que sean usuarios de BC.

### ¿Para quién es?

- Equipos de soporte y atención al cliente de CRONUS (agentes y responsables).
- Técnicos internos asignables a incidencias (no necesariamente usuarios BC).
- Perfiles de dirección o auditoría con acceso read-only.

### Alcance v1.0 — lo que NO se incluye

Esta versión **no incluye API REST ni integraciones externas**. Esas capacidades se han movido explícitamente a una **fase 2** posterior. Cualquier generación de API pages, OData endpoints o integraciones de chatbot está **fuera de alcance** de este PRD.

---

## 2. Funcionalidades Principales

### 2.1 Registro de Incidencias

El sistema debe permitir registrar incidencias con la siguiente información:

| Información | Descripción |
|---|---|
| **Identificación** | Número único automático, descripción corta y descripción detallada |
| **Clasificación** | Categoría y prioridad (Baja, Media, Alta, Crítica) |
| **Origen** | Canal de entrada y referencia externa opcional |
| **Cliente** | Datos del cliente afectado (opcional, enlace al maestro estándar de BC) |
| **Contacto** | Nombre, email y teléfono del reportador |
| **Asignación** | Técnico de soporte responsable (del maestro propio, ver sección 2.5) |
| **Fechas** | Creación, fecha límite y resolución |

### 2.2 Ciclo de Vida de la Incidencia

El sistema debe soportar el siguiente ciclo de estados:

```
   Nueva  →  En Progreso  →  Resuelta  →  Cerrada
                  ↓              ↑
             Pendiente  ─────────┘
            (Cliente /
             Interno)
```

**Estados disponibles**:

- **Nueva** – recién creada, sin asignar
- **En Progreso** – siendo trabajada activamente
- **Pendiente Cliente** – esperando información del cliente
- **Pendiente Interno** – esperando recursos internos
- **Resuelta** – solucionada, pendiente de cierre
- **Cerrada** – finalizada
- **Cancelada** – descartada

El sistema debe validar las transiciones de estado para evitar saltos no permitidos.

### 2.3 Comentarios e Historial

Cada incidencia mantiene un registro de actividad que incluye:

- Notas añadidas por los usuarios.
- Cambios de estado (generados automáticamente al cambiar de estado).
- Cambios de asignación (generados automáticamente al reasignar).
- Notas de resolución.

Los comentarios son **append-only**: no se pueden editar ni borrar una vez registrados, para preservar la trazabilidad.

### 2.4 Categorías Configurables

Categorías iniciales acordadas para CRONUS en la reunión de kick-off:

- `TECH` — Soporte Técnico (máquinas espresso, equipamiento)
- `BILL` — Facturación (errores de albarán, incidencias de cobro)
- `LOG` — Logística (entregas, transporte, bolsas dañadas)
- `QUAL` — Calidad (defectos de producto, perfil de tueste, sabor inconsistente)

Cada categoría tiene código corto, descripción legible y prioridad predeterminada.

### 2.5 Maestro propio de Técnicos de soporte

**Decisión arquitectónica clave**: los técnicos de soporte **NO son usuarios de Business Central**. Esto es una decisión deliberada del Director Técnico de BC para evitar:

1. El acoplamiento del módulo al sistema de identidad de BC (Entra ID, licencias).
2. El patrón común de error al usar la tabla estándar `User` cuyo PK es `User Security ID` (GUID) y no el `User Name` — error que suele introducir bugs en tiempo de ejecución al intentar resolver TableRelation incorrectamente.
3. La dependencia de que cada persona asignable tenga licencia BC Essential o Premium.

**Implementación requerida**:

El sistema debe incluir una tabla propia de técnicos (`Support Technician` o nombre equivalente a criterio del architect) con los siguientes campos:

- `Code` — Code[20], primary key. Código corto legible (`TECH001`, `MARIA`, `JP`).
- `Name` — Text[100], obligatorio.
- `Email` — Text[100], opcional.
- `Specialty Category Code` — Code[20], opcional, TableRelation a la tabla de Incident Category.
- `Active` — Boolean, default true.

El campo `Assigned To` de la tabla Incident debe ser `Code[20]` con `TableRelation` a esta tabla propia de técnicos filtrando `Active = true`. **NO debe usar la tabla estándar `User` de BC bajo ninguna circunstancia**.

Todas las acciones de asignación (desde pages, desde acciones del Role Center, desde lógica interna) deben resolver el lookup contra esta tabla de técnicos.

---

## 3. Interfaces de Usuario

### 3.1 Role Center del agente de soporte (PIEZA PRINCIPAL)

Esta es la pieza protagonista visual del módulo.

**Objetos AL requeridos**:

- **1 tabla Cue** con Primary Key dummy (campo `Primary Key` de tipo Code[10]) y tres FlowFields Integer con CalcFormula:
  - `My Open Incidents` = count incidents where `Assigned To = Code del técnico del usuario actual` AND status NOT IN (Closed, Cancelled)
  - `Unassigned` = count incidents where `Assigned To = ''` AND status = New
  - `Critical Open` = count incidents where Priority = Critical AND status NOT IN (Closed, Cancelled)

  > **Nota sobre "el técnico del usuario actual"**: como los técnicos no son usuarios de BC, el agente de soporte normalmente ve en este cue las incidencias asignadas a sí mismo filtrando por `Assigned To = UserId()` solo si el código del técnico coincide con el UserId. Si en el futuro se desea un mapeo más robusto, puede añadirse un campo `BC User ID` opcional a la tabla de técnicos. Para v1.0 es aceptable que el cue muestre el contador por código de técnico.

- **1 page CardPart** ("Incident Activities" o equivalente) con `SourceTable = Incident Cue` que contiene dos `cuegroup`:
  - **Grupo 1 Activities**: los 3 FlowFields como tiles.
  - **Grupo 2 Quick Actions**: 3 action tiles con imágenes `TileNew`, `TileList`, `TileSetup`.
- **1 page RoleCenter** ("Barista Support Role Center" o equivalente) que incluye el CardPart anterior como parte principal.
- **1 Profile AL** enlazado al Role Center, con `RoleCenter = "Barista Support Role Center"` y `Caption = 'Barista Support Agent'`, configurado para que sea seleccionable desde la gestión estándar de perfiles de BC.

**Action tiles**:

- **Nueva incidencia** → abre la page Incident Card con `RunPageMode = Create`
- **Todas las incidencias** → abre la page Incident List sin filtros
- **Setup Wizard** → ejecuta la page del wizard (`RunObject`)

**Directrices de diseño**:

- Solo 2 cuegroups. No añadir más.
- Cue `Critical Open` debe tener `StyleExpr` con valor `'Unfavorable'` cuando el contador > 0 (visual en rojo/naranja).
- No se requieren Headlines ni Wide Cues para esta v1.0.
- `ApplicationArea = All` en todos los elementos.

### 3.2 Lista de Incidencias

Vista principal con filtros predefinidos:
- **Mis incidencias abiertas** – las asignadas al técnico actual que no estén cerradas.
- **Todas las abiertas** – pendientes de resolución en toda la organización.
- **Críticas** – prioridad máxima sin resolver.

Código de colores por estado y prioridad mediante `StyleExpr`.

### 3.3 Ficha de Incidencia

Secciones lógicas:
- Información general (número, descripción corta, estado, prioridad).
- Descripción detallada (texto largo).
- Datos de contacto.
- Información de origen (canal, referencia externa).
- Asignación (técnico responsable — lookup a tabla de técnicos, NO a User).
- Resolución (fecha y notas de resolución).
- FactBox de comentarios (historial completo).

Acciones desde la ficha: cambio de estado, asignación rápida a técnico, añadir comentario.

### 3.4 Configuración

Apartado en la configuración de Business Central para definir serie numérica, expuesto como extensión de la página de Setup del área de ventas estándar (Sales & Receivables Setup).

### 3.5 Lista de Técnicos

Page tipo List con `SourceTable = Support Technician`, editable inline por usuarios con permiso de administrador. Permite añadir, modificar y desactivar técnicos.

---

## 4. Wizard de Configuración Inicial

Page tipo `NavigatePage` con 3 pasos. Accesible desde:

- **Tell Me** escribiendo "Incident Management Setup Wizard".
- **Tile dedicado en el Role Center** del agente de soporte.

**Paso 1 — Bienvenida**: pantalla informativa con `InstructionalText`.

**Paso 2 — Numeración**:
- Opción A: crear automáticamente una serie numérica por defecto (`INC`, formato `INC-00001` a `INC-99999`, incremento 1).
- Opción B: seleccionar una serie numérica existente mediante lookup estándar a `No. Series`.

**Paso 3 — Datos Demo**: opción de generar datos de ejemplo (ver sección 5 para el detalle del contenido).

### Sobre el registro en Assisted Setup

El PRD **no exige** que el wizard se registre en Assisted Setup de BC. Esta es una decisión deliberada: el registro en Assisted Setup ha mostrado incompatibilidades de firma entre versiones BC 27 y posteriores, y preferimos garantizar que el wizard sea accesible desde Tell Me (que nunca falla) antes que arriesgar problemas de compatibilidad.

Si el architect detecta que el registro en Assisted Setup es viable de forma robusta para BC 27.0+, puede proponerlo como mejora opcional. Si no, dejarlo accesible solo desde Tell Me y desde el Role Center es **suficiente y correcto** para la v1.0.

---

## 5. Datos de demostración

El codeunit de generación de datos demo debe ser **idempotente** y **usar el maestro estándar de CRONUS USA**. Contenido:

### 5.1 Categorías demo (5 unidades)

Con códigos identificables como demo:
- `DEMO-HW` — Hardware Issues (prioridad High)
- `DEMO-SW` — Software Issues (prioridad Medium)
- `DEMO-NET` — Network Issues (prioridad High)
- `DEMO-ACC` — Access Issues (prioridad Medium)
- `DEMO-GEN` — General Support (prioridad Low)

### 5.2 Técnicos demo (5 unidades)

Con códigos identificables como demo:
- `DEMO-T001` — Alice Martinez (specialty: DEMO-HW)
- `DEMO-T002` — Bob Chen (specialty: DEMO-SW)
- `DEMO-T003` — Carmen Ruiz (specialty: DEMO-NET)
- `DEMO-T004` — David Patel (specialty: DEMO-ACC)
- `DEMO-T005` — Elena Rossi (specialty: DEMO-GEN)

Todos con `Active = true` y un email ficticio `<code>@demo.cronus.local`.

### 5.3 Incidencias demo (15 unidades)

Distribuidas en estados:
- 3 nuevas (New)
- 4 en progreso (In Progress)
- 2 pendientes (Pending Customer / Internal — 1 de cada)
- 3 resueltas (Resolved)
- 2 cerradas (Closed)
- 1 cancelada (Cancelled)

Las incidencias están vinculadas a **3 clientes ya existentes del maestro estándar de CRONUS USA, Inc.** El codeunit debe hacer `Customer.FindFirst()` con filtros razonables (por ejemplo, primeros 3 clientes activos) y usar esos `Customer No.` reales. **NO debe crear clientes nuevos**.

Cada incidencia está asignada a uno de los 5 técnicos demo (rotación circular).

Las descripciones y comentarios deben ser narrativos y coherentes con el estado: una incidencia "In Progress" debe tener al menos un comentario que refleje avance; una "Resolved" debe tener una resolution summary escrita; una "Cancelled" debe tener un comentario explicando por qué se canceló.

### 5.4 Idempotencia

El generador debe verificar antes de insertar:

- Categorías: si existe alguna con código `DEMO-*`, no regenerar.
- Técnicos: si existe alguno con código `DEMO-T*`, no regenerar.
- Incidencias: si existe alguna con código externalID demo (`DEMO-INC-*`) o marcador similar, no regenerar.

Re-ejecución del generador sobre datos ya existentes debe terminar silenciosamente sin error y sin duplicar.

---

## 6. Permisos y Seguridad

Tres permission sets:

| Perfil | Permisos |
|---|---|
| **Administrador** | Acceso completo a todas las tablas del módulo (RIMD), incluyendo mantenimiento de técnicos y ejecución del generador de demo data |
| **Usuario** | RIM sobre Incident, R sobre Category y Technician, RI sobre Comment. Puede asignar incidencias a técnicos pero no crear ni modificar técnicos. |
| **Consulta / Read-only** | Solo R sobre todas las tablas del módulo. |

**Importante**: los permission sets deben incluir **permisos de ejecución (X) sobre las pages, codeunits y el Role Center** además de los permisos sobre tabledata. Es un fallo común omitir esto y provoca que usuarios con SuperPermissions deshabilitado no puedan abrir las pages.

---

## 7. Alcance y Limitaciones

### 7.1 Incluido en v1.0

- Gestión completa del ciclo de vida de incidencias.
- Categorización y priorización.
- Maestro propio de técnicos (tabla independiente, NO tabla User).
- Asignación de incidencias a técnicos desde la lista interna.
- Historial de comentarios append-only.
- Relación opcional con el maestro de clientes estándar de BC.
- Role Center dedicado con 3 cues y 3 action tiles.
- Profile AL enlazado al Role Center.
- Wizard de instalación con generación idempotente de demo data (accesible desde Tell Me y desde el Role Center).
- Datos demo que usan clientes ya existentes del maestro CRONUS USA.
- Tres permission sets diferenciados (con permisos X sobre pages/codeunits).

### 7.2 Fuera de alcance (acordado en kick-off)

- **API REST OData (API Pages, API Queries)** — movido explícitamente a fase 2.
- Adjuntos y documentos en incidencias.
- Notificaciones por email.
- SLAs con cálculo de fechas de compromiso.
- Flujos de aprobación multi-paso.
- Portal de cliente integrado.
- Informes avanzados con Power BI.
- Categorización automática por IA.
- Plantillas de incidencias.

Esta separación de alcance es **acuerdo formal** de la reunión. Cualquier ampliación requiere change request aceptado por JP.

---

## 8. Requisitos Técnicos

| Requisito | Especificación |
|---|---|
| **Plataforma** | Microsoft Dynamics 365 Business Central |
| **Versión mínima** | BC 27.0 (2025 Wave 1) |
| **AL Runtime** | 16.0 o superior |
| **Despliegue** | Cloud (SaaS) o On-Premise |
| **Licencias** | Essential o Premium (solo para usuarios BC; los técnicos del maestro propio no requieren licencia) |
| **Dependencias** | Base Application, System Application. Sin dependencias de terceros. |

---

## 9. Criterios de Aceptación

La iteración 1.0 se considera completada cuando:

1. Un usuario con perfil **Usuario** puede crear una incidencia completa (categoría + descripción + asignación a técnico + cliente opcional) desde la Card en menos de 5 clics.
2. El ciclo de vida (Nueva → En Progreso → Pendiente → Resuelta → Cerrada) funciona con validaciones de transición correctas.
3. El wizard de configuración se ejecuta sin errores desde Tell Me y desde el Role Center, y deja el sistema listo para usar.
4. El generador de demo data es idempotente y produce 5 categorías + 5 técnicos + 15 incidencias coherentes vinculadas a 3 clientes existentes del maestro CRONUS.
5. **El Role Center muestra los 3 cues con contadores reales tras ejecutar el generador de demo data**, y los 3 action tiles son funcionales (abren página nueva, lista, wizard).
6. El Profile "Barista Support Agent" es seleccionable desde la configuración de perfiles de BC y al seleccionarlo el usuario aterriza en el Role Center.
7. La asignación de incidencias a técnicos funciona correctamente resolviendo lookup contra la tabla propia de técnicos (NO contra User).
8. Los tres permission sets (Admin, User, Read-only) funcionan según las restricciones definidas, incluyendo permisos X sobre pages y codeunits.
9. La extensión se publica sin errores de compilación y se instala sobre un sandbox limpio de Business Central con CRONUS USA, Inc. como empresa demo.

---

## 10. Glosario

| Término | Definición |
|---|---|
| **Incidencia** | Registro de un problema, consulta o solicitud |
| **Categoría** | Tipología de la incidencia |
| **Comentario** | Nota append-only asociada a una incidencia |
| **Ciclo de vida** | Conjunto de estados y transiciones válidas |
| **Técnico de soporte** | Persona asignable a incidencias. Vive en maestro propio del módulo, NO es usuario BC. |
| **Role Center** | Page AL tipo RoleCenter que agrupa Parts (en v1.0, un único CardPart con cues) y se enlaza a un Profile |
| **Cue** | FlowField Integer de la tabla Cue expuesto en un cuegroup dentro del CardPart |
| **Profile** | Objeto AL que asocia un usuario a un Role Center específico |
| **Setup Wizard** | NavigatePage con pasos secuenciales |
| **Demo Data** | Datos de ejemplo con prefijo `DEMO-` (categorías, técnicos, incidencias) |
| **Permission Set** | Conjunto de permisos de Business Central aplicable a usuarios |
| **Barista** | Profesional del café, cliente tipo de CRONUS |
| **CRONUS** | Empresa demo estándar de BC, adoptada como distribuidor de café |
| **Fase 2** | Fase posterior a v1.0, no incluida en este alcance. Incluirá API REST, integraciones con chatbots y portal de cliente. |

---

## 11. Notas para el Architect (ALDC)

Este documento es la **fuente única** de requerimientos técnicos. Lo que no esté aquí, no forma parte del alcance.

### 11.1 Estructura esperada de objetos AL

El architect debe generar una `architecture.md` que defina:

- **4 tablas principales**: Incident, Incident Category, Incident Comment, Support Technician.
- **1 tabla Cue** dedicada para los 3 FlowFields del Role Center.
- **1 TableExtension** sobre Sales & Receivables Setup (tabla estándar 311) para el campo "Incident Nos.".
- **3 enums**: Status (7 valores), Priority (4 valores), Comment Type. El Channel puede integrarse como enum adicional o como campo Option/Code según criterio del architect.
- **2 codeunits**: Incident Management (lógica de negocio con métodos `CreateIncident`, `UpdateStatus`, `AssignIncident`, `AddComment`, `ResolveIncident`) + Demo Data Generator (idempotente).
- **Pages de usuario**: Incident List, Incident Card, Incident Comments Part (ListPart), Incident Category List, Support Technician List.
- **1 PageExtension** sobre la Sales & Receivables Setup Page.
- **1 NavigatePage** como Setup Wizard de 3 pasos.
- **1 page CardPart** "Incident Activities" con 2 cuegroups (3 cues datos + 3 action tiles).
- **1 page RoleCenter** "Barista Support Role Center".
- **1 Profile AL** enlazado al Role Center.
- **3 Permission Sets**: Admin, User, Read-only (incluyendo X sobre pages, codeunits y el Role Center).

### 11.2 Decisiones técnicas obligatorias

**Campo `Assigned To`**: debe ser `Code[20]` con `TableRelation` a la tabla propia `Support Technician` donde `Active = CONST(true)`. **BAJO NINGUNA CIRCUNSTANCIA** usar la tabla estándar `User`. Esta decisión está justificada en la sección 2.5 de este PRD.

**Cue table**: debe tener un campo `Primary Key` de tipo `Code[10]` como PK (patrón canónico de BC para cue tables) y 3 FlowFields Integer con CalcFormula sobre la tabla Incident.

**Profile**: debe ser objeto AL `profile` con `RoleCenter` asignado y `Caption = 'Barista Support Agent'`. Debe registrarse como seleccionable estándar por BC.

**StyleExpr en cue Critical Open**: debe retornar `'Unfavorable'` cuando el contador es mayor que cero.

**Permissions sobre pages/codeunits**: TODOS los permission sets deben incluir entradas `page X` y `codeunit X` sobre los objetos de su alcance, además de las entradas `tabledata`. Este es un fallo común que se debe evitar explícitamente.

### 11.3 Configuración del proyecto

- **Rango de IDs**: proponer un rango coherente dentro del espacio de partner (por ejemplo `51150-51170` o equivalente que quepa bien).
- **Clasificación de complejidad esperada**: **MEDIUM**. Módulo completo pero acotado a 2 semanas de desarrollo tradicional.
- **Prefijo de objetos**: proponer un prefijo corto (3-4 caracteres) coherente con el publisher. Todos los objetos deben llevar ese prefijo por convención AppSource.
- **Publisher y nombre de app**: placeholder para que el desplegador final los configure en `app.json`. Nombre sugerido: `Barista Incidents`.

### 11.4 Entorno demo target

Sandbox con **CRONUS USA, Inc.** como empresa demo. El generador de demo data debe operar sobre ese dataset estándar:
- Catálogo con artículos `WRB-*` (Whole Roasted Beans) y `WDB-*` (Whole Decaf Beans).
- Usar los **3 primeros clientes activos del maestro** para vincular las 15 incidencias demo. No crear clientes nuevos.

### 11.5 Contacto único para dudas

JP (Jefe de Proyecto CRONUS). Canalizar a través de él cualquier decisión que requiera confirmación del cliente.

### 11.6 Avisos explícitos sobre patrones que deben evitarse

Se listan aquí tres patrones que en proyectos anteriores han causado bugs en tiempo de ejecución. El architect debe evitarlos:

1. **Uso de `User Name` como TableRelation**. La PK de la tabla `User` de BC es `User Security ID` (GUID), no `User Name`. Usar `User Name` provoca el error de runtime *"The following field must be included into the table's primary key"*. Por eso el PRD exige un maestro propio de técnicos: **se elimina la tentación de usar la tabla User**.
2. **Registrar Assisted Setup con firmas que cambien entre versiones BC**. Si el architect quiere intentar el registro, debe verificar compatibilidad con BC 27.0 y posteriores. Si hay dudas, dejar el wizard solo accesible desde Tell Me y Role Center.
3. **Permission Sets sin entradas X sobre pages/codeunits**. Verificar explícitamente que los 3 permission sets tienen entradas de ejecución sobre los objetos funcionales, no solo sobre tabledata.

---

*Fin del documento PRD técnico.*

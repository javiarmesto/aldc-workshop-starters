> 🇪🇸 Español | [🇬🇧 English](../../i18n/en/04-greenfield-starter/Requerimientos/PRD-v0.1-live-mini.md)

# Barista Incidents — PRD v0.1-live (Sprint 0)

**Proyecto**: Barista Incidents
**Cliente**: CRONUS USA, Inc.
**Versión**: 0.1-live (Sprint 0 — validación rápida del pipeline)
**Preparado por**: Consultor Técnico de Sistemas (CRONUS)
**Audiencia**: AL Architect (ALDC)
**Idioma de código y metadatos AL**: inglés.

---

## 0. Propósito de este documento

Este es el PRD **Sprint 0 Minimum Viable Extension** — una versión reducida del PRD v1.0-workshop completo.

**¿Por qué una versión reducida?** Los proyectos reales con ALDC siguen un patrón: antes de soltar al pipeline el alcance completo (que tarda 2-3 horas), el partner valida en un Sprint 0 que ALDC ha entendido el dominio correctamente. Este Sprint 0 genera lo mínimo funcional en ~15 minutos. Si el resultado es coherente, se amplía al alcance completo.

Esta versión genera aproximadamente **11-12 objetos AL** que representan el núcleo transaccional del sistema de incidencias. El wizard, el Role Center, las APIs y la capa de demo data quedan fuera — son piezas de v1.0 completa (fase posterior).

---

## 1. Alcance v0.1-live

### Lo que SÍ entra en el Sprint 0

- **Modelo de datos nuclear**: 4 tablas principales (Incident, Category, Comment, Support Technician)
- **Reglas de negocio mínimas**: ciclo de vida de 5 estados + validación de transiciones
- **Capa lógica**: 1 codeunit Incident Management con los 5 procedures canónicos
- **Interfaz mínima funcional**: List de incidencias + Card + FactBox de comentarios
- **Seguridad mínima**: 2 permission sets (Admin + User) con entradas X sobre pages y codeunits

### Lo que NO entra (se reserva para v1.0 completo)

- Role Center dedicado con cues
- Profile AL
- Setup Wizard con pasos
- Demo Data Generator idempotente
- TableExtension sobre Sales & Receivables Setup
- Cue table con FlowFields
- Permission Set de Read-only (solo Admin y User en v0.1)
- API Pages (fuera de alcance incluso en v1.0 completa)

### Guinda extensible (si queda tiempo tras el Sprint 0)

Si el Sprint 0 termina antes de tiempo, el partner puede pedir a ALDC que añada **una sola** de las siguientes piezas:

- **Opción G-A**: Wizard de setup con 3 pasos (sin Assisted Setup registration)
- **Opción G-B**: Demo Data Generator idempotente (5 categorías + 5 técnicos + 15 incidencias)
- **Opción G-C**: Una API page OData v4 para `incidents` (GET/POST)

Solo una, para no desbordar tiempos. Se elige por votación o preferencia del consultor en ese momento.

---

## 2. Modelo de datos requerido

### 2.1 Tabla Incident

- PK: `No.` Code[20], alimentado por serie numérica
- Campos mínimos:
  - `Short Description` Text[100]
  - `Detailed Description` Text[2048]
  - `Category Code` Code[20] → TableRelation Incident Category
  - `Priority` Enum Priority (4 valores)
  - `Status` Enum Status (5 valores)
  - `Customer No.` Code[20] → TableRelation Customer (opcional)
  - `Assigned To` Code[20] → TableRelation **Support Technician** WHERE Active=true
  - `Creation Date` Date
  - `Created By` Code[50]
- Keys: PK + SK(Status, Assigned To) + SK(Priority, Status)

### 2.2 Tabla Incident Category

- PK: `Code` Code[20]
- Campos:
  - `Description` Text[100]
  - `Default Priority` Enum Priority

### 2.3 Tabla Incident Comment

- PK: `Incident No.` Code[20] + `Line No.` Integer
- Campos:
  - `Comment Text` Text[2048]
  - `Comment Type` Enum CommentType (3 valores: User, Status Change, Assignment)
  - `Created At` DateTime
  - `Created By` Code[50]
- **Append-only**: OnModify y OnDelete bloquean con Error

### 2.4 Tabla Support Technician (DECISIÓN CLAVE)

- PK: `Code` Code[20]
- Campos:
  - `Name` Text[100]
  - `Email` Text[100]
  - `Active` Boolean, default true
- Keys: PK + SK(Active)
- **NO es tabla User de BC**. Es tabla propia del módulo. La razón está documentada en la sección 4.1 de este PRD.

---

## 3. Enums requeridos

### 3.1 Enum Status (5 valores, Extensible=true)

- New
- In Progress
- Pending
- Resolved
- Closed

> **Nota**: el PRD v1.0 completo tiene 7 estados (desglosa Pending en Customer/Internal y añade Cancelled). En v0.1 simplificamos a 5 para reducir el código de transiciones.

### 3.2 Enum Priority (4 valores, Extensible=true)

- Low, Medium, High, Critical

### 3.3 Enum CommentType (3 valores, Extensible=true)

- User
- StatusChange
- Assignment

---

## 4. Lógica de negocio

### 4.1 Decisión crítica — No usar tabla User de BC

El campo `Assigned To` de la tabla Incident debe ser `Code[20]` con `TableRelation` a `Support Technician` donde `Active = CONST(true)`.

**BAJO NINGUNA CIRCUNSTANCIA** usar la tabla estándar `User` de BC. La tabla User tiene como Primary Key `User Security ID` (GUID), no `User Name`. Intentar un TableRelation sobre `User Name` provoca el error de runtime:

```
The following field must be included into the table's primary key: 
Field: User Name Table: User
```

Por eso existe el maestro propio `Support Technician`: elimina la tentación de usar la tabla User y desacopla del sistema de licencias BC (los técnicos no requieren licencia).

### 4.2 Codeunit Incident Management

Procedures públicos (5):

- `CreateIncident(var Incident: Record Incident)` — asigna No. vía serie numérica, Status=New
- `UpdateStatus(var Incident: Record Incident; NewStatus: Enum Status)` — valida transición, actualiza, genera comentario StatusChange automático
- `AssignIncident(var Incident: Record Incident; TechnicianCode: Code[20])` — valida técnico activo, actualiza, genera comentario Assignment automático
- `AddComment(var Incident: Record Incident; CommentText: Text[2048])` — inserta comentario tipo User
- `ValidateStatusTransition(OldStatus, NewStatus: Enum Status): Boolean` — procedure público para que la UI pueda consultar validez antes de ofrecer la acción

### 4.3 Matriz de transiciones de estado

```
         | New | InProg | Pending | Resolved | Closed
---------|-----|--------|---------|----------|-------
New      |  ✓  |   ✓    |    -    |    -     |   -
InProg   |  -  |   ✓    |    ✓    |    ✓     |   -
Pending  |  -  |   ✓    |    ✓    |    ✓     |   -
Resolved |  -  |   ✓    |    -    |    ✓     |   ✓
Closed   |  -  |   -    |    -    |    -     |   ✓  (estado final)
```

Toda transición no marcada con ✓ debe lanzar Error con mensaje explícito.

---

## 5. Interfaz de Usuario

### 5.1 Incident List

- PageType = List, SourceTable = Incident
- UsageCategory = Lists, ApplicationArea = All
- Editable = false, CardPageId = Incident Card
- StyleExpr en Status (Favorable/Attention/Subordinate según estado) y Priority (Unfavorable cuando Critical)
- Sin vistas predefinidas en v0.1 (se dejan para v1.0)

### 5.2 Incident Card

- PageType = Card, SourceTable = Incident
- ApplicationArea = All
- FastTabs: General, Description, Assignment
- FactBox a la derecha: Incident Comments Part
- Acciones: ChangeStatus, AssignTechnician, AddComment
  - Cada acción debe llamar al procedure correspondiente del codeunit (NO stubs con Message())
  - Caption en inglés, Promoted = true, Image semánticamente apropiada

### 5.3 Incident Comments Part

- PageType = ListPart, SourceTable = Incident Comment
- Editable = false (append-only enforced en tabla)
- SubPageLink "Incident No." = field("No.")

---

## 6. Permisos

### 6.1 Permission Set Admin

- RIMD sobre las 4 tabledata del módulo
- X sobre las 3 pages + 1 codeunit
- Assignable = true

### 6.2 Permission Set User

- RIM sobre Incident, R sobre Category y Support Technician, RI sobre Comment
- X sobre List, Card, Comments Part + codeunit Incident Management
- Assignable = true

---

## 7. Configuración del proyecto

| Parámetro | Valor |
|---|---|
| Publisher | Circe Innovation |
| App Name | Barista Incidents Sprint0 |
| Prefijo objetos | BRI |
| Rango IDs | 50900-50929 |
| Platform BC | 27.0 o superior |
| Runtime AL | 16.0 o superior |
| NoImplicitWith | true |
| Dependencias | Base Application, System Application |

---

## 8. Criterios de Aceptación v0.1-live

El Sprint 0 se considera completo cuando:

1. La extensión compila sin errores ni warnings bloqueantes en un sandbox BC 27+.
2. Se publica correctamente.
3. Un usuario Admin puede crear una incidencia desde la Card con los campos obligatorios.
4. El ciclo de vida respeta la matriz de transiciones (no permite Closed directo desde New).
5. La acción AddComment de la Card inserta correctamente un comentario tipo User en la tabla Comment (cableada al codeunit, NO un Message stub).
6. La asignación resuelve correctamente contra la tabla Support Technician sin error de User Name PK.
7. Los 2 permission sets tienen entradas X sobre las 3 pages y el codeunit.

---

## 9. Comparativa visual — v0.1-live vs v1.0-workshop

| Dimensión | v0.1-live (Sprint 0) | v1.0-workshop (completo) |
|---|---|---|
| Tablas | 4 | 5 (+Cue) |
| TableExtensions | 0 | 1 (SalesSetup) |
| Enums | 3 | 4 (+Channel) |
| Codeunits | 1 | 2 (+DemoData) |
| Pages usuario | 3 | 8 (+CategoryList, TechnicianList, Wizard, Activities, RoleCenter) |
| PageExtensions | 0 | 1 (SalesSetup) |
| Profile AL | 0 | 1 (BRI Support Agent) |
| Permission Sets | 2 (Admin, User) | 3 (+Read) |
| **Total objetos** | **~11** | **~25** |
| Role Center | — | ✅ con 3 cues + 3 actions |
| Wizard | — | ✅ 3 pasos |
| Demo Data | — | ✅ idempotente |
| Tiempo ALDC | ~15 min | ~3h |

---

## 10. Notas para el Architect

1. Aplicar **Skills Evidencing**: declarar al top de `architecture.md` las skills usadas (skill-architecture, skill-data-model, skill-permissions).
2. **NO añadir** objetos fuera del alcance del Sprint 0. Si detectas que "faltaría" algo, documéntalo en una sección "Open Questions" al final de la architecture. No inventes piezas.
3. El prefijo BRI es obligatorio y debe aplicarse a todos los objetos.
4. El rango 50900-50929 es obligatorio.
5. Configura `app.json` con target Platform 27.0 y Runtime 16.0 como mínimo. Si tu entorno requiere Runtime 17 o superior, puedes declararlo sin problema.
6. Tras generar architecture, **detente y pregunta** al consultor si aprueba avanzar al spec. HITL gate explícito.

---

*Fin del PRD v0.1-live.*

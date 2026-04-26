# Architecture: Barista Incidents

> **Skills applied**: skill-pages, skill-performance, skill-events
> *(skill-api explícitamente NO cargada — API fuera de alcance v1.0 por Decisión 3)*

**Date**: 2026-04-20
**Complexity**: MEDIUM
**Author**: al-architect
**Status**: Approved
**Version**: 1.0-workshop
**Client**: CRONUS USA, Inc.

---

## 1. Executive Summary

Barista Incidents v1.0 es una extensión para Microsoft Dynamics 365 Business Central (BC 28.0+) que permite a CRONUS USA, Inc. centralizar la gestión de incidencias de clientes barista. La extensión introduce un maestro propio de técnicos de soporte (independiente de la tabla User de BC), un ciclo de vida completo de incidencias con 7 estados y transiciones validadas, un Role Center operativo con 3 cues en tiempo real, y un wizard de configuración accesible desde Tell Me y desde el propio Role Center. La versión 1.0 no incluye API REST ni integraciones externas, que quedan reservadas para fase 2.

---

## 2. Business Context

### Problem Statement
CRONUS gestiona incidencias de clientes barista de forma dispersa: hojas de cálculo SharePoint, notas personales de comerciales, sistema de calidad separado, y bandeja de email genérica. Consecuencia: pérdida de información entre canales, duplicación de incidencias, falta de visibilidad del estado global y ausencia de análisis de tendencias.

### Success Criteria
1. Un agente de soporte puede registrar una incidencia completa en menos de 5 clics desde el Role Center.
2. El ciclo de vida Nueva → Resuelta → Cerrada funciona con validación de transiciones.
3. El Role Center muestra contadores reales (3 cues) y 3 action tiles funcionales tras instalar el demo data.
4. El generador de demo data es idempotente: 5 categorías + 5 técnicos + 15 incidencias vinculadas a 3 clientes existentes de CRONUS.
5. Los 3 permission sets (Admin, User, Read-only) funcionan con permisos X sobre pages y codeunits.
6. La asignación de técnicos resuelve siempre contra la tabla propia `BRI Support Technician` — nunca contra la tabla `User` de BC.

---

## 3. Solution Architecture

### 3.1 Patrón principal

**Módulo autónomo con extensión mínima del core BC.** La extensión introduce sus propias tablas, enums y páginas sin modificar objetos base salvo dos extensiones puntuales: un campo en Sales & Receivables Setup (serie numérica) y su page extension. El resto de integración con BC se hace a través de `TableRelation` a las tablas estándar `Customer` y `No. Series`.

### 3.2 Inventario completo de objetos AL (25 objetos)

| ID | Tipo | Nombre AL | Responsabilidad |
|---|---|---|---|
| 50900 | Table | `BRI Incident` | Entidad principal — incidencia completa |
| 50901 | Table | `BRI Incident Category` | Maestro de categorías configurables |
| 50902 | Table | `BRI Incident Comment` | Historial append-only de comentarios |
| 50903 | Table | `BRI Support Technician` | **Maestro propio de técnicos** (NO tabla User) |
| 50904 | Table | `BRI Incident Cue` | Tabla Cue para FlowFields del Role Center |
| 50905 | TableExtension | `BRI SalesSetup Ext` | Añade campo "BRI Incident Nos." a tabla 311 |
| 50906 | Enum | `BRI Incident Status` | 7 valores del ciclo de vida |
| 50907 | Enum | `BRI Incident Priority` | Low / Medium / High / Critical |
| 50908 | Enum | `BRI Comment Type` | User / Status Change / Assignment / Resolution |
| 50909 | Enum | `BRI Incident Channel` | Phone / Email / Chat / Portal / Chatbot / Other |
| 50910 | Codeunit | `BRI Incident Management` | Lógica de negocio: CreateIncident, UpdateStatus, AssignIncident, AddComment, ResolveIncident |
| 50911 | Codeunit | `BRI Demo Data Generator` | Generación idempotente de datos demo |
| 50912 | Page | `BRI Incident List` | Lista con 3 vistas filtradas + StyleExpr por estado/prioridad |
| 50913 | Page | `BRI Incident Card` | Ficha completa con FactBox de comentarios |
| 50914 | Page | `BRI Incident Comments Part` | ListPart (append-only) para FactBox en Card |
| 50915 | Page | `BRI Incident Category List` | Gestión de categorías |
| 50916 | Page | `BRI Support Technician List` | Gestión de técnicos |
| 50917 | PageExtension | `BRI SalesSetup PageExt` | Expone campo "BRI Incident Nos." en Sales Setup |
| 50918 | Page | `BRI Incident Wizard` | NavigatePage — 3 pasos (Bienvenida / Numeración / Demo) |
| 50919 | Page | `BRI Incident Activities` | CardPart con 2 cuegroups (datos + action tiles) |
| 50920 | Page | `BRI Support Role Center` | RoleCenter page — pieza visual principal |
| 50921 | Profile | `BRI SUPPORT AGENT` | Profile AL enlazado al Role Center |
| 50922 | PermissionSet | `BRI-ADMIN` | Acceso completo + X pages/codeunits/RoleCenter |
| 50923 | PermissionSet | `BRI-USER` | Acceso de agente + X pages/codeunits |
| 50924 | PermissionSet | `BRI-READ` | Solo lectura + X pages (View) |

**Rango de IDs**: 50900–50924 (25 objetos dentro del rango 50900–50949 configurado en `app.json`)
**Publisher propuesto**: `Circe Innovation` *(ya en `app.json` — ver Open Questions OQ-01)*
**App Name propuesto**: `Barista Incidents` *(placeholder — ver Open Questions OQ-01)*
**Prefijo de objetos**: `BRI` (3 caracteres, coherente con Barista Incidents)

### 3.3 Diagrama de relaciones de datos

```
BRI Incident (50900)
├── Category Code     → BRI Incident Category (50901)   [required]
├── Customer No.      → Customer (18)                    [optional]
├── Assigned To       → BRI Support Technician (50903)   [optional, Active=true]
└── has 1..N          → BRI Incident Comment (50902)     [append-only]

BRI Support Technician (50903)
└── Specialty Code    → BRI Incident Category (50901)    [optional]

BRI Incident Cue (50904)
└── FlowFields count  → BRI Incident (50900)             [3 CalcFormula]

BRI SalesSetup Ext (50905)
└── extends           → Sales & Receivables Setup (311)  [campo Incident Nos.]
    └── Incident Nos. → No. Series (308)                 [TableRelation]
```

### 3.4 Ciclo de vida de la incidencia (State Machine)

```
[Crear] ──► New ──────────────────────────────────► Cancelled
             │
             ▼
         In Progress ──► Pending Customer ──► In Progress
             │         └─► Pending Internal ──► In Progress
             │
             ▼
          Resolved ◄──────────────────────── (reopen)
             │
             ▼
           Closed (estado final)

Transiciones INVÁLIDAS (lanzar Error()):
  - New → Resolved, Closed  (salto no permitido)
  - Closed → cualquier estado (estado final)
  - Cancelled → cualquier estado (estado final)
```

---

## 4. Data Model

### 4.1 Table 50900 `BRI Incident`

| Campo | Tipo | Observaciones |
|---|---|---|
| `No.` | Code[20] | PK — serie numérica desde Sales & Receivables Setup |
| `Description` | Text[100] | Descripción corta (visible en list view) |
| `Detail Description` | Text[2048] | Contexto completo del problema |
| `Category Code` | Code[20] | TableRelation → `BRI Incident Category` |
| `Priority` | Enum `BRI Incident Priority` | Default: propagado desde categoría en OnValidate |
| `Status` | Enum `BRI Incident Status` | Default: `New`; modificar solo via `UpdateStatus()` |
| `Customer No.` | Code[20] | TableRelation → Customer (opcional) |
| `Customer Name` | Text[100] | Copiado desde Customer en OnValidate |
| `Contact Name` | Text[100] | Datos del reportador |
| `Contact Email` | Text[100] | |
| `Contact Phone` | Text[30] | |
| `Channel` | Enum `BRI Incident Channel` | Canal de entrada del reporte |
| `External Reference` | Text[50] | Nº ticket externo / marcador demo `DEMO-INC-*` |
| `Assigned To` | Code[20] | TableRelation → `BRI Support Technician` WHERE `Active`=`CONST(true)` |
| `Deadline Date` | Date | Opcional |
| `Creation Date` | Date | Auto-populated en Insert |
| `Created By` | Code[50] | UserId() en Insert |
| `Resolution Date` | Date | Populated en ResolveIncident() |
| `Resolution Summary` | Text[2048] | Síntesis canónica del cierre |

**Keys**:
- PK: `No.`
- Key 2: `Status`, `Assigned To` — para cue My Open Incidents
- Key 3: `Priority`, `Status` — para cue Critical Open
- Key 4: `Customer No.` — para filtros por cliente
- Key 5: `Category Code` — para filtros por categoría

> ⚠️ **DECISIÓN CLAVE D1**: `Assigned To` es Code[20] con TableRelation a `BRI Support Technician` WHERE `Active=CONST(true)`. **BAJO NINGUNA CIRCUNSTANCIA** usar la tabla estándar `User` de BC. La tabla `User` tiene PK `User Security ID` (GUID), no `User Name`, lo que provoca el error de runtime *"The following field must be included into the table's primary key"*. Además los técnicos de CRONUS no tienen necesariamente licencia BC.

### 4.2 Table 50901 `BRI Incident Category`

| Campo | Tipo | Observaciones |
|---|---|---|
| `Code` | Code[20] | PK |
| `Description` | Text[100] | Nombre legible |
| `Default Priority` | Enum `BRI Incident Priority` | Propagada al crear incidencia con esta categoría |

### 4.3 Table 50902 `BRI Incident Comment`

| Campo | Tipo | Observaciones |
|---|---|---|
| `Incident No.` | Code[20] | PK parte 1 — TableRelation → `BRI Incident` |
| `Line No.` | Integer | PK parte 2 — autoincrement |
| `Comment Type` | Enum `BRI Comment Type` | User / Status Change / Assignment / Resolution |
| `Comment` | Text[2048] | Texto del comentario |
| `Created At` | DateTime | Auto-populated — append-only por diseño |
| `Created By` | Code[50] | UserId() |

> **Append-only enforcement**: la página `BRI Incident Comments Part` no expone acciones de editar/borrar. Los permisos `BRI-USER` otorgan solo `I` (Insert) sobre esta tabla, no `M` (Modify) ni `D` (Delete).

### 4.4 Table 50903 `BRI Support Technician`

| Campo | Tipo | Observaciones |
|---|---|---|
| `Code` | Code[20] | PK — códigos legibles: `MARIA`, `TECH001` |
| `Name` | Text[100] | Obligatorio |
| `Email` | Text[100] | Opcional |
| `Specialty Category Code` | Code[20] | TableRelation → `BRI Incident Category` (opcional) |
| `Active` | Boolean | Default `true` — falso = oculto en lookup de asignación |

### 4.5 Table 50904 `BRI Incident Cue`

| Campo | Tipo | CalcFormula |
|---|---|---|
| `Primary Key` | Code[10] | PK dummy — patrón canónico BC para Cue tables |
| `My Open Incidents` | Integer (FlowField) | COUNT `BRI Incident` WHERE `Assigned To`=FILTER(UserId()) AND `Status` NOT IN {Closed, Cancelled} |
| `Unassigned Incidents` | Integer (FlowField) | COUNT `BRI Incident` WHERE `Assigned To`=CONST('') AND `Status`=CONST(New) |
| `Critical Open Incidents` | Integer (FlowField) | COUNT `BRI Incident` WHERE `Priority`=CONST(Critical) AND `Status` NOT IN {Closed, Cancelled} |

> **Limitación conocida v1.0**: `My Open Incidents` usa `FILTER(UserId())` como aproximación. Funciona correctamente solo si el `Code` del técnico coincide con el `UserId()` del usuario BC. Mejora planificada para fase 2: campo `BC User ID` opcional en `BRI Support Technician`.

### 4.6 TableExtension 50905 `BRI SalesSetup Ext`

Extiende tabla estándar 311 `Sales & Receivables Setup`:
- Campo `BRI Incident Nos.` — Code[20], TableRelation → `No. Series`

### 4.7 Enums

**Enum 50906 `BRI Incident Status`** (7 valores):
```al
value(0; New) { Caption = 'New'; }
value(1; "In Progress") { Caption = 'In Progress'; }
value(2; "Pending Customer") { Caption = 'Pending Customer'; }
value(3; "Pending Internal") { Caption = 'Pending Internal'; }
value(4; Resolved) { Caption = 'Resolved'; }
value(5; Closed) { Caption = 'Closed'; }
value(6; Cancelled) { Caption = 'Cancelled'; }
```

**Enum 50907 `BRI Incident Priority`** (4 valores):
```al
value(0; Low) { Caption = 'Low'; }
value(1; Medium) { Caption = 'Medium'; }
value(2; High) { Caption = 'High'; }
value(3; Critical) { Caption = 'Critical'; }
```

**Enum 50908 `BRI Comment Type`** (4 valores):
```al
value(0; User) { Caption = 'User'; }
value(1; "Status Change") { Caption = 'Status Change'; }
value(2; Assignment) { Caption = 'Assignment'; }
value(3; Resolution) { Caption = 'Resolution'; }
```

> ⚠️ Los valores con espacios requieren comillas en las referencias AL: `"Status Change"`, **no** `StatusChange`. Error frecuente documentado en memory.

**Enum 50909 `BRI Incident Channel`** (6 valores):
```al
value(0; Phone) { Caption = 'Phone'; }
value(1; Email) { Caption = 'Email'; }
value(2; Chat) { Caption = 'Chat'; }
value(3; Portal) { Caption = 'Portal'; }
value(4; Chatbot) { Caption = 'Chatbot'; }
value(5; Other) { Caption = 'Other'; }
```

> `Chatbot` incluido deliberadamente para ser additive en fase 2 sin migration.

---

## 5. Business Logic

### 5.1 Codeunit 50910 `BRI Incident Management`

Procedimientos públicos:

| Procedimiento | Firma | Descripción |
|---|---|---|
| `CreateIncident` | `(var Incident: Record "BRI Incident")` | Genera No. desde No. Series, establece Creation Date/Created By, status New |
| `UpdateStatus` | `(var Incident: Record "BRI Incident"; NewStatus: Enum "BRI Incident Status")` | Valida transición, actualiza status, genera comentario automático "Status Change" |
| `AssignIncident` | `(var Incident: Record "BRI Incident"; TechnicianCode: Code[20])` | Valida técnico activo, actualiza Assigned To, genera comentario "Assignment" (anterior → nuevo) |
| `AddComment` | `(var Incident: Record "BRI Incident"; CommentText: Text[2048])` | Inserta línea en `BRI Incident Comment` tipo User, append-only |
| `ResolveIncident` | `(var Incident: Record "BRI Incident"; ResolutionSummary: Text[2048])` | Llama UpdateStatus(Resolved), guarda Resolution Summary y Resolution Date, genera comentario "Resolution" |

Procedimientos privados:
- `GetNextLineNo(IncidentNo: Code[20]): Integer` — calcula MAX Line No. + 10000
- `ValidateStatusTransition(CurrentStatus; NewStatus): Boolean` — tabla de transiciones permitidas

### 5.2 Codeunit 50911 `BRI Demo Data Generator`

Procedimiento público: `GenerateDemoData()` — **idempotente**.

Lógica de idempotencia (verificar ANTES de cualquier insert):
```
IF EXISTS BRI Incident Category WHERE Code LIKE 'DEMO-*' THEN EXIT (silently);
IF EXISTS BRI Support Technician WHERE Code LIKE 'DEMO-T*' THEN EXIT (silently);
IF EXISTS BRI Incident WHERE External Reference LIKE 'DEMO-INC-*' THEN EXIT (silently);
```

Obtención de clientes (DECISIÓN D5):
```al
Customer.Reset();
Customer.SetRange(Blocked, Customer.Blocked::" ");
IF Customer.FindSet() THEN
    REPEAT
        // usar Customer."No." para las incidencias
        CustomerCount += 1;
    UNTIL (Customer.Next() = 0) OR (CustomerCount = 3);
// NO crear clientes nuevos bajo ninguna circunstancia
```

**Datos demo**:
- 5 categorías: `DEMO-HW` (High), `DEMO-SW` (Medium), `DEMO-NET` (High), `DEMO-ACC` (Medium), `DEMO-GEN` (Low)
- 5 técnicos: `DEMO-T001` Alice Martinez, `DEMO-T002` Bob Chen, `DEMO-T003` Carmen Ruiz, `DEMO-T004` David Patel, `DEMO-T005` Elena Rossi
- 15 incidencias: 3 New / 4 In Progress / 1 Pending Customer / 1 Pending Internal / 3 Resolved / 2 Closed / 1 Cancelled
- Asignación rotación circular entre los 5 técnicos demo
- External Reference = `DEMO-INC-001` a `DEMO-INC-015`
- Comentarios narrativos coherentes con el estado de cada incidencia

---

## 6. User Interface

### 6.1 Role Center — Piezas (DECISIÓN D2)

**Page 50919 `BRI Incident Activities`** — CardPart:
- `SourceTable = "BRI Incident Cue"`
- **CueGroup 1** (caption 'Activities'):
  - `My Open Incidents` — drilldown → `BRI Incident List` filtrado por Assigned To=Current
  - `Unassigned Incidents` — drilldown → `BRI Incident List` filtrado por vacío + Status=New
  - `Critical Open Incidents` — `StyleExpr = CriticalStyleExpr` (`'Unfavorable'` cuando > 0, rojo/naranja)
- **CueGroup 2** (caption 'Quick Actions'):
  - `action("New Incident")` — RunObject Page `BRI Incident Card`, RunPageMode=Create, image `TileNew`
  - `action("All Incidents")` — RunObject Page `BRI Incident List`, image `TileList`
  - `action("Setup Wizard")` — RunObject Page `BRI Incident Wizard`, image `TileSetup`

**Page 50920 `BRI Support Role Center`** — RoleCenter:
- Incluye `BRI Incident Activities` como `part` principal

**Profile 50921 `BRI SUPPORT AGENT`**:
```al
profile "BRI SUPPORT AGENT"
{
    Caption = 'Barista Support Agent';
    ProfileDescription = 'Role Center for CRONUS support agents managing barista incidents';
    RoleCenter = "BRI Support Role Center";
    Enabled = true;
    Promoted = true;
}
```

### 6.2 Page 50912 `BRI Incident List`

- Tipo: `List`, SourceTable: `BRI Incident`
- Vistas predefinidas:
  - `My Open` — Assigned To = FILTER(UserId()) AND Status NOT IN (Closed, Cancelled)
  - `All Open` — Status NOT IN (Closed, Cancelled)
  - `Critical` — Priority = Critical AND Status NOT IN (Closed, Cancelled)
- `StyleExpr` sobre campos Status y Priority para coloreado visual
- Acciones: New (Card Create), Assign Technician, Change Status

### 6.3 Page 50913 `BRI Incident Card`

FastTabs:
1. **General** — No., Description, Status, Priority, Category Code
2. **Description** — Detail Description (MultiLine)
3. **Contact** — Contact Name, Email, Phone, Customer No., Customer Name
4. **Origin** — Channel, External Reference, Creation Date, Deadline Date
5. **Assignment** — Assigned To (lookup → BRI Support Technician, filtrado Active=true)
6. **Resolution** — Resolution Date, Resolution Summary (visible cuando Status ≥ Resolved)

FactBox: `BRI Incident Comments Part` (ListPart 50914)

Acciones desde Card: `Change Status`, `Assign Technician`, `Add Comment`, `Resolve`

### 6.4 Page 50914 `BRI Incident Comments Part`

- Tipo: `ListPart`, SourceTable: `BRI Incident Comment`
- `SubPageLink = "Incident No." = field(No.)`
- Campos de lectura: Created At, Comment Type, Created By, Comment
- **Sin botones de editar ni borrar** — enforce append-only en UI y en permisos

### 6.5 Page 50918 `BRI Incident Wizard` (NavigatePage) — DECISIÓN D4

- `UsageCategory = Tasks` — accesible desde **Tell Me** buscando "Incident Management Setup Wizard"
- **Action tile en Role Center** — accesible desde `BRI Incident Activities` CueGroup 2

Pasos:
- **Step 1 — Welcome**: InstructionalText descriptivo del proceso de configuración
- **Step 2 — No. Series**: Campo `BRI Incident Nos.` (desde Sales & Receivables Setup) + botón "Create Default Series" que crea serie `INC` (INC-00001..INC-99999, incremento 1) si está vacío. Acciones: Back / Next
- **Step 3 — Demo Data**: Checkbox `Generate Demo Data`. Si checked: llama `BRI Demo Data Generator.GenerateDemoData()` en Finish. Acciones: Back / Finish

> **Sobre Assisted Setup**: no se registra el wizard en Assisted Setup de BC. Esta es una decisión deliberada (ver Decisión 2 en § 10). Si se confirma compatibilidad con BC 28.0+, puede añadirse como mejora opcional en una iteración posterior.

---

## 7. Integration Points

### 7.1 Integración con tablas estándar BC

| Punto de integración | Tipo | Detalle |
|---|---|---|
| `Customer` (tabla 18) | TableRelation (opcional) | `BRI Incident`.`Customer No.` — solo lectura, no crea clientes |
| `No. Series` (tabla 308) | TableRelation | `BRI SalesSetup Ext`.`BRI Incident Nos.` |
| `No. Series Line` | Lógica en codeunit | `NoSeriesMgt.GetNextNo()` en `CreateIncident()` |
| `Sales & Receivables Setup` (tabla 311) | TableExtension 50905 | Campo `BRI Incident Nos.` añadido |

### 7.2 Eventos

En v1.0 no se publican Integration Events propios (módulo interno, sin consumidores externos). Se reserva la publicación de eventos para fase 2.

Extensibilidad opcional: se puede añadir un IntegrationEvent vacío en `BRI Incident Management`:
- `OnAfterCreateIncident(var Incident: Record "BRI Incident")` — para que partners puedan suscribirse sin breaking change.

### 7.3 Fuera de alcance v1.0 (fase 2)

- API Pages OData v4
- Webhook / Integration Events para chatbot
- Portal de cliente
- Notificaciones por email

---

## 8. Security Model

### 8.1 Permission Sets

> ⚠️ **Patrón crítico**: TODOS los permission sets deben incluir entradas `X` (Execution) sobre pages y codeunits. Omitir las entradas X bloquea el acceso a usuarios sin SuperPermissions. Es el fallo más común en implementaciones BC (PRD § 11.6 punto 3).

**PermissionSet 50922 `BRI-ADMIN`** — Administrador completo:
```
tabledata "BRI Incident"                RIMD
tabledata "BRI Incident Category"       RIMD
tabledata "BRI Incident Comment"        RIMD
tabledata "BRI Support Technician"      RIMD
tabledata "BRI Incident Cue"            RIMD
tabledata "Sales & Receivables Setup"   RM   (solo campo propio)
page "BRI Incident List"                X
page "BRI Incident Card"                X
page "BRI Incident Comments Part"       X
page "BRI Incident Category List"       X
page "BRI Support Technician List"      X
page "BRI SalesSetup PageExt"           X
page "BRI Incident Wizard"              X
page "BRI Incident Activities"          X
page "BRI Support Role Center"          X
codeunit "BRI Incident Management"      X
codeunit "BRI Demo Data Generator"      X
```

**PermissionSet 50923 `BRI-USER`** — Agente de soporte:
```
tabledata "BRI Incident"                RIM  (sin Delete)
tabledata "BRI Incident Category"       R
tabledata "BRI Incident Comment"        RI   (sin Modify ni Delete — append-only)
tabledata "BRI Support Technician"      R
tabledata "BRI Incident Cue"            R
page "BRI Incident List"                X
page "BRI Incident Card"                X
page "BRI Incident Comments Part"       X
page "BRI Incident Wizard"              X
page "BRI Incident Activities"          X
page "BRI Support Role Center"          X
codeunit "BRI Incident Management"      X
```

**PermissionSet 50924 `BRI-READ`** — Consulta / Read-only:
```
tabledata "BRI Incident"                R
tabledata "BRI Incident Category"       R
tabledata "BRI Incident Comment"        R
tabledata "BRI Support Technician"      R
tabledata "BRI Incident Cue"            R
page "BRI Incident List"                X
page "BRI Incident Card"                X
page "BRI Incident Comments Part"       X
page "BRI Incident Activities"          X
page "BRI Support Role Center"          X
```

---

## 9. Performance Considerations

| Hotspot | Impacto | Mitigación |
|---|---|---|
| FlowField `Critical Open Incidents` recalculado en cada render del Role Center | Medio | Key (Priority, Status) en `BRI Incident` para scan rápido |
| FlowField `My Open Incidents` con FILTER(UserId()) | Medio | Key (Status, Assigned To) en `BRI Incident` |
| `BRI Incident List` con filtros complejos en listas grandes | Bajo-Medio | Key (Customer No.) y Key (Category Code) para filtros de usuario |
| Demo Data Generator: 15 incidencias + comentarios | Puntual | Llamada única desde Wizard; idempotencia evita re-ejecuciones |
| `Customer.FindSet()` en Demo Data | Bajo | `SetRange(Blocked, Blocked::" ")` + contador a 3 para minimizar scan |

`SetLoadFields` recomendado en codeunit para operaciones sobre lotes de incidencias.

---

## 10. Technical Decisions

### Decisión 1: Tabla propia de técnicos vs tabla `User` de BC [D1 — OBLIGATORIA]
**Problema**: necesitamos asignar incidencias a personas que pueden no tener licencia BC.
- **Opción A**: TableRelation a tabla `User` (PK = GUID) → requiere licencia BC, PK inutilizable en UI
- **Opción B**: TableRelation a `User` por `User Name` → error runtime (*"field must be in primary key"*)
- **Opción C (elegida)**: Tabla propia `BRI Support Technician` con PK `Code[20]` legible

**Decisión**: Opción C. Elimina dependencia de licencias BC, lookup limpio, PK coherente.

### Decisión 2: Wizard sin registro en Assisted Setup [D4 — OBLIGATORIA]
**Problema**: registro en Assisted Setup tiene incompatibilidades de firma en BC 27+.
- **Opción A**: Registrar en Assisted Setup → riesgo de compatibilidad
- **Opción B (elegida)**: Solo accesible desde Tell Me (`UsageCategory = Tasks`) + action tile Role Center

**Decisión**: Opción B. Garantiza acceso universal sin riesgo de compatibilidad. Si se valida con BC 28.0+, el registro en Assisted Setup puede añadirse como mejora opcional.

### Decisión 3: Sin API Pages en v1.0 [D3 — OBLIGATORIA]
**Decisión**: Fuera de alcance total. Ningún objeto `PageType = API` ni `query` de tipo API. El modelo de datos está diseñado para que una API Page sobre `BRI Incident` sea additive en fase 2.

### Decisión 4: Channel como Enum vs Option
- **Opción A**: `Channel` como `Option` → no extensible
- **Opción B (elegida)**: Enum `BRI Incident Channel`

**Decisión**: Enum permite extensibilidad (p.ej. añadir `WhatsApp` en fase 2 sin cambiar la tabla base).

### Decisión 5: Idempotencia demo data via External Reference [D5 — OBLIGATORIA]
- **Opción A**: Campo `Is Demo` Boolean en `BRI Incident` → columna extra permanente
- **Opción B (elegida)**: Campo `External Reference` = `DEMO-INC-*` como marcador

**Decisión**: Opción B. El campo `External Reference` ya existe con propósito de referencia cruzada. Sin columnas extra en la tabla principal.

---

## 11. Implementation Phases

```
Phase 1 ──► Phase 2 ──► Phase 3 ──► Phase 4
 Data       Business    UI Core     Role Center
 Model      Logic                   + Wizard
```

### Phase 1: Data Model Foundation
**Objetos**: Tablas 50900-50904, TableExtension 50905, Enums 50906-50909, PermissionSets 50922-50924
**Output**: Todas las tablas compilables, CRUD básico funcional, enums con valores exactos, permisos con entradas X
**Habilita**: Phase 2 puede referenciar tablas y enums

### Phase 2: Business Logic
**Objetos**: Codeunit 50910 `BRI Incident Management`, Codeunit 50911 `BRI Demo Data Generator`
**Output**: CreateIncident (No. Series), UpdateStatus (validación de transiciones), AssignIncident (comentario automático), AddComment, ResolveIncident; generador idempotente con 5+5+15 registros
**Habilita**: Phase 3 puede usar codeunits desde pages

### Phase 3: UI Core
**Objetos**: Pages 50912-50916, PageExtension 50917
**Output**: Incident List con 3 vistas y StyleExpr, Incident Card con FactBox, Category List y Technician List editables, Sales Setup con campo No. Series
**Habilita**: Phase 4 tiene las pages destino para action tiles y drilldowns

### Phase 4: Role Center + Wizard
**Objetos**: Page 50918 (Wizard), Page 50919 (CardPart Activities), Page 50920 (RoleCenter), Profile 50921
**Output**: Role Center funcional con 3 cues en tiempo real y 3 action tiles, wizard de 3 pasos con demo data, perfil "Barista Support Agent" seleccionable
**Criterio de cierre**: Acceptance Criteria 1-9 del PRD § 9 superados

---

## 12. Risks & Mitigations

| Riesgo | Impacto | Prob. | Mitigación |
|---|---|---|---|
| FlowField `My Open Incidents` filtra por UserId() que no coincide con Code del técnico | Medio — cue muestra 0 para agentes reales | Media | Documentar en release notes; campo `BC User ID` como mejora fase 2 |
| Demo Data Generator falla si Customer.FindFirst() no devuelve 3 clientes activos | Bajo | Baja | Usar mínimo 1 cliente si hay menos de 3; no lanzar error crítico |
| Enum `"Status Change"` referenciado sin comillas en codeunit | Bajo — error de compilación | Media | Code review checklist: todos los valores enum con espacios requieren comillas |
| Permission Sets sin entradas X | Alto — bloquea acceso usuarios no-Super | Media | Checklist review Phase 1: verificar entradas X en los 3 permission sets antes de aprobar |
| Transición de estado incompleta en ValidateStatusTransition | Medio | Baja | Test unitario en Phase 2 cubriendo todas las rutas del diagrama de estado |

---

## 13. Deployment Plan

**Versión**: 1.0.0.0
**Target**: BC 28.0+ (SaaS Cloud u On-Premise) — *ver OQ-02*
**Empresa demo**: CRONUS USA, Inc.

**Pre-deployment checklist**:
- [ ] `app.json` actualizado con publisher/name/versión definitivos (ver OQ-01)
- [ ] Rango de IDs confirmado (50900-50924 dentro de 50900-50949)
- [ ] Compilación sin errores en BC 28 sandbox
- [ ] Todos los permission sets con entradas X verificadas
- [ ] Wizard ejecutado desde Tell Me sin errores
- [ ] Demo data generado y 3 cues muestran contadores > 0

**Post-deployment checklist**:
- [ ] Perfil "Barista Support Agent" seleccionable desde gestión de perfiles
- [ ] Role Center carga sin errores con el perfil asignado
- [ ] Acceptance Criteria 1-9 del PRD § 9 superados
- [ ] Generador idempotente validado (2 ejecuciones consecutivas sin duplicados)

**Rollback**: desinstalar extensión desde Gestión de Extensiones. No hay datos operativos en v1.0 inicial (entorno demo). Riesgo cero de pérdida de datos.

---

## 14. Open Questions

Las siguientes ambigüedades se documentan aquí para confirmación con JP (punto único de contacto CRONUS) antes de finalizar la spec.

| # | Pregunta | Contexto | Impacto |
|---|---|---|---|
| OQ-01 | **Publisher y App Name definitivos**: `app.json` del workspace tiene `publisher = "Circe Innovation"` y `name = "WorkshopALDC_v3_Ejercicio"`. ¿Son los valores finales del proyecto, o placeholder del workshop? | PRD § 11.3 indica que son placeholders abiertos | Afecta `app.json` y todos los objetos AL |
| OQ-02 | **BC target version**: `app.json` configura `"application": "28.0.0.0"` (BC 28), pero el PRD § 8 especifica mínimo BC 27.0. ¿El target real es BC 27 o BC 28? | Diferencia entre spec y workspace | Afecta `app.json` y runtime features disponibles |
| OQ-03 | **`Detail Description` — longitud**: ¿Text[2048] es suficiente, o los agentes necesitan textos más extensos? BigText permitiría longitud ilimitada pero complica búsquedas. | Sin especificación explícita en PRD | Afecta Table 50900 campos `Detail Description` y `Resolution Summary` |
| OQ-04 | **StyleExpr paleta de colores**: el PRD describe colores por estado/prioridad pero no especifica la paleta concreta. ¿Hay preferencia del equipo de CRONUS, o el partner propone? | PRD § 3.2 menciona colores pero no los define | Afecta Page 50912 `BRI Incident List` |
| OQ-05 | **Técnicos iniciales en el wizard**: ¿interesa añadir un Step 4 para dar de alta los técnicos reales de CRONUS durante el setup, o se hará manualmente post-wizard? | No especificado en PRD § 4 | Podría añadir Step 4 a NavigatePage 50918 |

---

## 15. Dependencies

- **Base Objects**: Customer (18), Sales & Receivables Setup (311), No. Series (308), No. Series Line (309)
- **Extensions**: ninguna dependencia de terceros
- **External Systems**: ninguno en v1.0
- **System App**: `NoSeriesMgt` para generación de numeración

---

## 16. Spec Decomposition

Este requerimiento se implementa con **una única spec** (sin descomposición). El módulo tiene complejidad MEDIUM pero cohesión alta — las 4 fases de implementación son secuenciales y todas encajan en una spec única.

```
@workspace use al-spec.create
Crear spec para barista-incidents.
Leer .github/plans/barista-incidents/barista-incidents.architecture.md
```

Tras la spec:
```
@al-conductor
Implementar barista-incidents siguiendo TDD.
Contratos en .github/plans/barista-incidents/
```

---

## References

- Documentos de requerimientos: `Requerimientos/01-contexto-cronus-barista.md`, `02-barista-incidents-requerimientos-funcionales.md`, `03-barista-incidents-PRD-ALDC.md`
- Workspace: `app.json` (rango de IDs 50900-50949, publisher Circe Innovation)
- Reunión de kick-off: 16 de abril de 2026

---

*Este documento es el diseño autorizado de Barista Incidents v1.0. Toda implementación debe alinearse con las decisiones aquí documentadas, en especial las 5 Decisiones Clave (D1-D5) marcadas como obligatorias por el cliente CRONUS.*

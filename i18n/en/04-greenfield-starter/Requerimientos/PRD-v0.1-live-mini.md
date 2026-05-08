> 🇪🇸 [Versión en español](../../../04-greenfield-starter/Requerimientos/PRD-v0.1-live-mini.md) · 🇬🇧 English

---

# Sprint 0 Minimum Viable Extension PRD

**Project:** Barista Incidents  
**Client:** CRONUS USA Inc.  
**Version:** 0.1-live (Sprint 0 — quick pipeline validation)  
**Audience:** AL Architect (ALDC)

---

## Section 0 · Purpose

This is a **Sprint 0 Minimum Viable Extension (MVE)**. Before running the full ALDC pipeline (~2-3 hours), we want to validate that:

1. The architect understands the domain correctly
2. The data model is structurally sound
3. The business logic compiles and works
4. The minimum UI is functional

**Sprint 0 generates a minimum functional extension in ~15 minutes**, covering approximately 11-12 AL objects.

**Out of Sprint 0**: Wizard, Role Center, APIs, and Demo Data Generator. Those belong to v1.0-workshop (the full version, ~25 objects).

---

## Section 1 · Sprint 0 scope

### Included ✅

| Area | Detail |
|------|--------|
| Nuclear data model | 4 main tables: Incident, Category, Comment, Support Technician |
| Minimum business rules | 5-status lifecycle + validated transitions |
| Logic layer | 1 Codeunit Incident Management with 5 canonical procedures |
| Minimum functional UI | Incident List + Incident Card + Comments FactBox |
| Minimum security | 2 permission sets: Admin + User (with X on pages and codeunits) |

### Explicitly out ❌

| Item | Belongs to |
|------|-----------|
| Role Center + Profile | v1.0-workshop |
| Setup Wizard | v1.0-workshop |
| Demo Data Generator | v1.0-workshop |
| TableExtension Sales & Receivables Setup | v1.0-workshop |
| Cue table with FlowFields | v1.0-workshop |
| Read-only PermissionSet | v1.0-workshop |
| API Pages (OData v4) | Phase 2 |

### Optional "cherry on top" ⭐

If Sprint 0 finishes ahead of time, choose **one** of:

| Option | Description |
|--------|-------------|
| G-A | 3-step setup wizard (no Assisted Setup required) |
| G-B | Idempotent Demo Data Generator (5 categories + 5 technicians + 15 incidents) |
| G-C | OData v4 API page for incidents (GET + POST) |

---

## Section 2 · Data model

### 2.1 Table: Incident

| Field | Type | Constraints |
|-------|------|------------|
| No. | Code[20] | PK · auto via No. Series |
| Short Description | Text[100] | Mandatory |
| Detailed Description | Text[2048] | Optional |
| Category Code | Code[20] | TableRelation → Incident Category |
| Priority | Enum Priority | 4 values |
| Status | Enum Status | 5 values |
| Customer No. | Code[20] | Optional · TableRelation → Customer |
| Assigned To | Code[20] | **TableRelation → Support Technician WHERE Active=true** |
| Creation Date | Date | Auto-filled on insert |
| Created By | Code[50] | UserId() on insert |

**Keys**:
- PK: `No.`
- SK1: `Status`, `Assigned To`
- SK2: `Priority`, `Status`

### 2.2 Table: Incident Category

| Field | Type |
|-------|------|
| Code | Code[20] (PK) |
| Description | Text[100] |
| Default Priority | Enum Priority |

### 2.3 Table: Incident Comment

| Field | Type | Constraints |
|-------|------|------------|
| Incident No. | Code[20] | PK part 1 · TableRelation → Incident |
| Line No. | Integer | PK part 2 |
| Comment | Text[2048] | |
| Comment Type | Enum CommentType | 3 values |
| Created At | DateTime | Auto-filled on insert |
| Created By | Code[50] | UserId() on insert |

**Critical**: `OnModify` and `OnDelete` triggers must call `Error()` — comments are **append-only**.

### 2.4 Table: Support Technician

| Field | Type | Constraints |
|-------|------|------------|
| Code | Code[20] | PK |
| Name | Text[100] | |
| Email | Text[100] | |
| Active | Boolean | Default true |

**Keys**:
- PK: `Code`
- SK1: `Active`

> **This is NOT the standard BC User table.** See Section 4.1 for the explanation.

---

## Section 3 · Enums

### Status (5 values)

```al
enum 50900 "BRI Incident Status"
{
    Extensible = true;

    value(0; "New") { Caption = 'New'; }
    value(1; "In Progress") { Caption = 'In Progress'; }
    value(2; "Pending") { Caption = 'Pending'; }
    value(3; "Resolved") { Caption = 'Resolved'; }
    value(4; "Closed") { Caption = 'Closed'; }
}
```

> Note: v1.0-workshop uses 7 values (splits Pending into Client/Internal, adds Cancelled). Sprint 0 uses 5 for simplicity.

### Priority (4 values)

```al
enum 50901 "BRI Incident Priority"
{
    Extensible = true;

    value(0; "Low") { Caption = 'Low'; }
    value(1; "Medium") { Caption = 'Medium'; }
    value(2; "High") { Caption = 'High'; }
    value(3; "Critical") { Caption = 'Critical'; }
}
```

### CommentType (3 values)

```al
enum 50902 "BRI Comment Type"
{
    Extensible = true;

    value(0; "User") { Caption = 'User'; }
    value(1; "Status Change") { Caption = 'Status Change'; }
    value(2; "Assignment") { Caption = 'Assignment'; }
}
```

---

## Section 4 · Business logic

### 4.1 Critical decision: Support Technician — NOT standard User table

**`Assigned To` must be `Code[20]` with `TableRelation` to the `Support Technician` table WHERE `Active`=CONST(true).**

**Why never the standard User table:**
The User table's primary key is `User Security ID` (GUID type), not `User Name`. Using `User Name` as a `TableRelation` causes a **runtime error** in Business Central:

```
The following field must be included into the table's primary key: 
Field: User Name  Table: User
```

This error only appears at runtime (not at compilation) — it will block agents during normal usage. The own `Support Technician` table completely avoids this issue.

### 4.2 Codeunit: Incident Management

**5 public procedures**:

| Procedure | Signature | Behaviour |
|-----------|-----------|-----------|
| `CreateIncident` | `(var Incident: Record "BRI Incident")` | Assigns `No.` via No. Series, sets Status=New, timestamps |
| `UpdateStatus` | `(var Incident: Record "BRI Incident"; NewStatus: Enum "BRI Incident Status")` | Validates transition, updates status, inserts Status Change comment |
| `AssignIncident` | `(var Incident: Record "BRI Incident"; TechnicianCode: Code[20])` | Validates technician is active, updates `Assigned To`, inserts Assignment comment |
| `AddComment` | `(var Incident: Record "BRI Incident"; CommentText: Text[2048])` | Inserts a new Comment record with Type=User, Created By, Created At |
| `ValidateStatusTransition` | `(OldStatus: Enum "BRI Incident Status"; NewStatus: Enum "BRI Incident Status"): Boolean` | Returns true if the transition is valid (public — for UI to query before offering the action) |

### 4.3 Transition matrix (5-status Sprint 0 version)

| From → | New | In Progress | Pending | Resolved | Closed |
|--------|-----|------------|---------|----------|--------|
| **New** | ✓ | ✓ | - | - | - |
| **In Progress** | - | ✓ | ✓ | ✓ | - |
| **Pending** | - | ✓ | ✓ | ✓ | - |
| **Resolved** | - | ✓ | - | ✓ | ✓ |
| **Closed** | - | - | - | - | ✓ (final) |

All invalid transitions → `Error()` with message listing valid options.

---

## Section 5 · UI

### 5.1 Incident List

```al
page 50900 "BRI Incident List"
{
    PageType = List;
    SourceTable = "BRI Incident";
    UsageCategory = Lists;
    ApplicationArea = All;
    Editable = false;
    CardPageId = "BRI Incident Card";
    // StyleExpr on Status and Priority (Unfavorable when Critical)
    // No predefined views in v0.1
}
```

### 5.2 Incident Card

```al
page 50901 "BRI Incident Card"
{
    PageType = Card;
    SourceTable = "BRI Incident";
    ApplicationArea = All;
    // FastTabs: General · Description · Assignment
    // FactBox: Incident Comments Part (ListPart)
    // Actions: ChangeStatus / AssignTechnician / AddComment
    // ALL actions MUST call codeunit procedures
    // NO Message() stubs — this is an acceptance criterion
}
```

**Action requirements**:
- Caption in English, `Promoted = true`, semantic `Image`
- **Must call codeunit procedures** — `Message()` stubs are explicitly prohibited and represent a defect

### 5.3 Incident Comments Part

```al
page 50902 "BRI Incident Comments Part"
{
    PageType = ListPart;
    SourceTable = "BRI Incident Comment";
    Editable = false;
    // SubPageLink: "Incident No." = field("No.")
}
```

---

## Section 6 · Permissions

### Admin permission set

| Object | Access |
|--------|--------|
| TableData BRI Incident | RIMD |
| TableData BRI Incident Category | RIMD |
| TableData BRI Incident Comment | RIMD |
| TableData BRI Support Technician | RIMD |
| Page BRI Incident List | X |
| Page BRI Incident Card | X |
| Page BRI Incident Comments Part | X |
| Codeunit BRI Incident Management | X |

### User permission set

| Object | Access |
|--------|--------|
| TableData BRI Incident | RIM |
| TableData BRI Incident Category | R |
| TableData BRI Incident Comment | RI |
| TableData BRI Support Technician | R |
| Page BRI Incident List | X |
| Page BRI Incident Card | X |
| Page BRI Incident Comments Part | X |
| Codeunit BRI Incident Management | X |

> **Critical**: `X` (Execute) on pages and codeunits is **mandatory** in both sets. Without it, agents cannot open pages even if they have full table access.

---

## Section 7 · Project configuration

| Parameter | Value |
|-----------|-------|
| Publisher | Circe Innovation |
| App Name | Barista Incidents Sprint0 |
| Object prefix | `BRI` |
| ID range | 50900–50929 |
| Platform | BC 27.0+ |
| AL Runtime | 16.0+ |
| NoImplicitWith | true |
| Dependencies | Base Application + System Application |

---

## Section 8 · Acceptance criteria

The Sprint 0 extension is considered complete when:

1. **AC1** · Compiles without blocking errors (`al build` clean)
2. **AC2** · Publishes to a clean BC sandbox without runtime errors
3. **AC3** · Admin can create an incident from the Card (all required fields accessible)
4. **AC4** · Lifecycle respects the transition matrix — Closed cannot be reached directly from New
5. **AC5** · "Add Comment" action inserts a comment correctly (wired to codeunit, NOT a `Message()` stub)
6. **AC6** · Assignment resolves against `Support Technician` table — no User Name PK runtime error
7. **AC7** · Both permission sets have `X` on the 3 pages and the management codeunit

---

## Section 9 · v0.1-live vs v1.0-workshop comparison

| Component | v0.1-live (Sprint 0) | v1.0-workshop (full) |
|-----------|---------------------|---------------------|
| Main tables | 4 | 5 |
| TableExtensions | 0 | 1 |
| Enums | 3 | 4 |
| Codeunits | 1 | 2 |
| Pages | 3 | 8 |
| PageExtensions | 0 | 1 |
| Profile | No | ✅ |
| PermissionSets | 2 | 3 |
| **Total objects** | **~11** | **~25** |
| Role Center | No | ✅ |
| Setup Wizard | No | ✅ |
| Demo Data Generator | No | ✅ |
| Estimated ALDC time | ~15 min | ~3 hours |

---

## Section 10 · Notes for the Architect

1. **Skills Evidencing required**: the top of `architecture.md` must list the evidence from each skill applied (AL Design, AL Code Quality, etc.)

2. **No objects outside Sprint 0 scope**: if you identify something useful but out of scope, document it in the `Open Questions` section of `architecture.md` — do not implement it

3. **`BRI` prefix mandatory** on all objects

4. **ID range 50900-50929** — stay within this range for all Sprint 0 objects

5. **`app.json`**: set `platform` to `27.0.0.0` and `runtime` to `16.0` exactly

6. **HITL gate**: after `architecture.md` is generated, **stop and wait** for human review before moving to `spec.md`. This is a non-negotiable requirement of the ALDC methodology

7. **Anti-patterns** (same as v1.0, now also valid for Sprint 0):
   - Never use `TableRelation` pointing at `User Name` in the standard `User` table
   - Never stub actions with `Message()` — wire them to codeunit procedures
   - Never omit `X` from permission sets

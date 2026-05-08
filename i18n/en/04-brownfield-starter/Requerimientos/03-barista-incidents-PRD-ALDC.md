> 🇪🇸 [Versión en español](../../../04-brownfield-starter/Requerimientos/03-barista-incidents-PRD-ALDC.md) · 🇬🇧 English

---

# Technical PRD for ALDC Architect

**Project:** Barista Incidents  
**Client:** CRONUS USA Inc.  
**Version:** 1.0-workshop  
**Audience:** AL Architect (ALDC) and partner technical analyst  
**AL code/metadata language:** English  
**Related docs:** [01 – Business context](01-contexto-cronus-barista.md) · [02 – Functional requirements](02-barista-incidents-requerimientos-funcionales.md)

---

## Section 0 · Origin of this document

This is the **third of three documents** in the pre-architecture pack. It was prepared by the CRONUS Technical Consultant and BC Technical Director to translate the functional content into a briefing that `al-architect` can process directly.

**Audience of this document**: AL Architect (ALDC agent) and the partner technical analyst who will supervise the architecture phase.

---

## Section 1 · Executive summary

**Barista Incidents v1.0** is a Business Central extension to centralise CRONUS USA barista-client incident management. It includes:

- A dedicated **Role Center** for support agents
- Full **lifecycle management** of incidents (7 statuses)
- **Own technician master** independent of BC Users (critical architectural requirement)
- **Configurable categories** with default priority
- **Append-only comment history** (User, Status Change, Assignment)
- **Setup wizard** (3 steps) with idempotent demo data generator
- **3 permission sets** (Admin, User, Read-only) with Execute on pages and codeunits

---

## Section 2 · Functional requirements (technical view)

### 2.1 Incident table — minimum fields

| Field | Type | Constraints |
|-------|------|------------|
| No. | Code[20] | PK · auto via No. Series |
| Short Description | Text[100] | Mandatory |
| Detailed Description | Text[2048] | Optional |
| Category Code | Code[20] | TableRelation → Incident Category |
| Priority | Enum Priority | 4 values: Low, Medium, High, Critical |
| Status | Enum Status | 7 values (see lifecycle) |
| Channel | Enum Channel | Call, Email, Chat, Portal, Chatbot |
| Customer No. | Code[20] | Optional · TableRelation → Customer |
| Contact Name | Text[100] | Optional |
| Contact Email | Text[100] | Optional |
| Contact Phone | Text[30] | Optional |
| Assigned To | Code[20] | **TableRelation → Support Technician WHERE Active=true** |
| Creation Date | Date | Auto-filled |
| Created By | Code[50] | UserId() on insert |
| Deadline | Date | Optional |
| Resolution Date | Date | Set on Status→Resolved |
| Resolution By | Code[50] | UserId() on resolution |
| Resolution Summary | Text[2048] | Free text · required at resolution |

### 2.2 Lifecycle and transitions

**7 statuses**:

| Value | Description |
|-------|-------------|
| New | Just opened |
| In Progress | Being worked on |
| Pending Client | Waiting on client response |
| Pending Internal | Waiting on internal information |
| Resolved | Resolution provided, pending client confirmation |
| Closed | Formally closed |
| Cancelled | Dropped |

**Valid transition matrix**:

| From → | New | In Progress | Pend. Client | Pend. Internal | Resolved | Closed | Cancelled |
|--------|-----|------------|-------------|---------------|----------|--------|-----------|
| New | ✓ | ✓ | - | - | - | - | ✓ |
| In Progress | - | ✓ | ✓ | ✓ | ✓ | - | ✓ |
| Pending Client | - | ✓ | ✓ | - | ✓ | - | ✓ |
| Pending Internal | - | ✓ | - | ✓ | ✓ | - | ✓ |
| Resolved | - | ✓ | - | - | ✓ | ✓ | - |
| Closed | - | - | - | - | - | ✓ | - |
| Cancelled | - | - | - | - | - | - | ✓ |

Every invalid transition must trigger `Error()` with an explicit message indicating valid transitions.

### 2.3 Comments and history

**Four comment types**:

| Type | Trigger | Who writes it |
|------|---------|--------------|
| User | Explicit agent action | Agent — free text |
| Status Change | Every status transition | System — automatic |
| Assignment | Assignment changes | System — automatic |

**Critical requirement**: the Comment table must block `OnModify` and `OnDelete` with `Error()`. Comments are **permanent**.

### 2.4 Configurable categories

Separate table (not a fixed enum). Initial 4:

| Code | Description | Default Priority |
|------|-------------|-----------------|
| TECH | Technical Support | High |
| BILL | Billing | Medium |
| LOG | Logistics | Medium |
| QUAL | Quality | High |

### 2.5 OWN TECHNICIAN MASTER — KEY ARCHITECTURAL DECISION

**Technicians are NOT BC users**. The reasons are:

1. Avoids coupling to the BC identity system
2. Avoids the runtime error `"The following field must be included into the table's primary key: Field: User Name Table: User"` — the User table's PK is `User Security ID` (GUID), not `User Name`
3. Technicians do not need a BC licence

**Support Technician table fields**:

| Field | Type | Constraints |
|-------|------|------------|
| Code | Code[20] | PK |
| Name | Text[100] | |
| Email | Text[100] | |
| Specialty | Code[20] | Optional · TableRelation to Incident Category |
| Active | Boolean | Default true |

The `Assigned To` field in the Incident table **MUST** be `Code[20]` with `TableRelation` to this table `WHERE Active=CONST(true)`. **NEVER use the standard User table.**

---

## Section 3 · User interfaces

### 3.1 Role Center — THE MAIN PIECE

**Cue table** (one record, PK = `Primary Key` Code[10]):

Three FlowFields:

| Field | Filter |
|-------|--------|
| My Open Incidents | Count Incident WHERE Assigned To = FILTER(UserId()) AND Status NOT IN (Resolved, Closed, Cancelled) |
| Unassigned | Count Incident WHERE Assigned To = '' AND Status = New |
| Critical Open | Count Incident WHERE Priority = Critical AND Status NOT IN (Closed, Cancelled) |

> Note: `My Open Incidents` links technician `Code` to `UserId()` as a v1.0 approximation. The BC Technical Director suggested optionally adding a `BC User ID` field to the technician master for future robustness. Not required in v1.0.

**Page tree**:

1. **CardPart "Incident Activities"** — the FactBox-like part embedded in the Role Center
   - **CueGroup "Activities"**: 3 FlowFields as cue tiles. StyleExpr = `'Unfavorable'` on Critical Open when > 0
   - **CueGroup "Quick Actions"**: 3 action tiles
     - "New Incident" → Incident Card (RunPageMode = Create)
     - "All Incidents" → Incident List
     - "Setup Wizard" → Wizard (RunObject = Page "Incident Management Setup Wizard")

2. **RoleCenter page "Barista Support Role Center"** — the Role Center itself
   - Embeds the "Incident Activities" CardPart
   - ApplicationArea = All

3. **Profile "BRI Support Agent"** — as a Profile AL object
   - RoleCenter = Barista Support Role Center
   - Caption = 'Barista Support Agent'
   - Enabled = true

**Design constraints**:
- Exactly 2 CueGroups (Activities + Quick Actions). No more
- No Headlines or Wide Cues in v1.0
- ApplicationArea = All throughout

### 3.2 Incident List

- PageType = List · SourceTable = Incident · Editable = false
- CardPageId = Incident Card
- UsageCategory = Lists, ApplicationArea = All
- Default views (via Views): My Open, All Open, Critical
- StyleExpr on Status (Favorable / Attention / Subordinate by status) and Priority (Unfavorable when Critical)

### 3.3 Incident Card

- PageType = Card · SourceTable = Incident
- FastTabs: General · Detailed Description · Assignment · Resolution
- FactBox: Incident Comments Part (ListPart)
- **Actions** (3, all promoted, semantic Image):
  - **Change Status**: dialog or dropdown for valid transitions → calls `UpdateStatus()` in codeunit
  - **Assign Technician**: lookup to Support Technician → calls `AssignIncident()` in codeunit
  - **Add Comment**: input dialog for free text → calls `AddComment()` in codeunit

### 3.4 Sales & Receivables Setup extension

A PageExtension on the Sales & Receivables Setup page to add the `Incident Nos.` field. This is where the Setup Wizard writes the No. Series reference.

### 3.5 Technician List

- PageType = List · editable inline by Admin profile
- Allows adding, editing, and inactivating technicians

---

## Section 4 · Setup wizard

**NavigatePage** with 3 steps (Step 1, Step 2, Step 3).

Accessible from:
- Tell Me: "Incident Management Setup Wizard"
- Role Center: "Setup Wizard" quick action tile

**Step 1 – Welcome**: InstructionalText explaining what will be configured. No user input.

**Step 2 – Numbering**: Option to create a default `INC` series or select an existing one.
- Default series: `INC-00001` through `INC-99999`
- Writes to the `Incident Nos.` field in Sales & Receivables Setup (via TableExtension)

**Step 3 – Demo data**: Button to trigger idempotent demo data generation.
- Progress message while running
- Confirmation at end: "5 categories, 5 technicians, 15 incidents created"

> **Note from BC Technical Director**: This PRD does **NOT** require Assisted Setup registration (`Guided Experience` codeunit). BC 27 compatibility issues with method signatures make it more trouble than it is worth for v1.0. Accessing via Tell Me + Role Center is sufficient and correct. If a future version requires Assisted Setup, a dedicated subscriber codeunit should be added separately.

---

## Section 5 · Demo data (idempotent)

All demo data uses existing CRONUS USA Inc. master data — **no new clients are created**.

### 5.1 Demo categories (5)

| Code | Description | Default Priority |
|------|-------------|-----------------|
| DEMO-HW | Hardware Support | High |
| DEMO-SW | Software Support | Medium |
| DEMO-NET | Network Issues | High |
| DEMO-ACC | Access & Security | Medium |
| DEMO-GEN | General Support | Low |

### 5.2 Demo technicians (5)

| Code | Name | Email | Specialty | Active |
|------|------|-------|-----------|--------|
| DEMO-T001 | Alice Martinez | demo-t001@demo.cronus.local | DEMO-HW | true |
| DEMO-T002 | Bob Chen | demo-t002@demo.cronus.local | DEMO-SW | true |
| DEMO-T003 | Carmen Ruiz | demo-t003@demo.cronus.local | DEMO-NET | true |
| DEMO-T004 | David Patel | demo-t004@demo.cronus.local | DEMO-ACC | true |
| DEMO-T005 | Elena Rossi | demo-t005@demo.cronus.local | DEMO-GEN | true |

### 5.3 Demo incidents (15)

Distribution:

| Status | Count |
|--------|-------|
| New | 3 |
| In Progress | 4 |
| Pending Client / Pending Internal | 2 (1 each) |
| Resolved | 3 |
| Closed | 2 |
| Cancelled | 1 |

- Linked to the **first 3 active customers** in CRONUS USA Inc. (via `Customer.FindFirst()` with active filter)
- Each incident has at least 1-2 narrative comments coherent with its status
- Short descriptions reference realistic barista-equipment issues (espresso machine temperature, coffee bag inventory, etc.)

### 5.4 Idempotency rules

Before inserting any demo record:
- Categories: check if `Code` starting with `DEMO-` already exists → skip silently
- Technicians: same check on `Code` starting with `DEMO-`
- Incidents: check if description starting with `DEMO-` already exists → skip silently

Re-running the wizard never produces duplicates, never throws errors.

---

## Section 6 · Permissions

**Three permission sets** — all must include Execute (`X`) on pages and codeunits. Omitting `X` is a common mistake that causes runtime errors.

### Admin

| Object type | Object | Access |
|-------------|--------|--------|
| TableData | Incident | RIMD |
| TableData | Incident Category | RIMD |
| TableData | Incident Comment | RIMD (insert only via codeunit — but Admin needs M for setup) |
| TableData | Support Technician | RIMD |
| TableData | Sales & Receivables Setup | RM (to write No. Series) |
| Page | Incident List | X |
| Page | Incident Card | X |
| Page | Incident Comments Part | X |
| Page | Category List | X |
| Page | Technician List | X |
| Page | Sales Setup Extension | X |
| Page | Incident Activities | X |
| Page | Barista Support Role Center | X |
| Page | Setup Wizard | X |
| Codeunit | Incident Management | X |
| Codeunit | Demo Data Generator | X |

### User (support agent profile)

| Object type | Object | Access |
|-------------|--------|--------|
| TableData | Incident | RIM |
| TableData | Incident Category | R |
| TableData | Incident Comment | RI (append-only) |
| TableData | Support Technician | R |
| Page | Incident List | X |
| Page | Incident Card | X |
| Page | Incident Comments Part | X |
| Page | Incident Activities | X |
| Page | Barista Support Role Center | X |
| Codeunit | Incident Management | X |

### Read-only

| Object type | Object | Access |
|-------------|--------|--------|
| TableData | Incident | R |
| TableData | Incident Category | R |
| TableData | Incident Comment | R |
| TableData | Support Technician | R |
| Page | All pages listed above | X |

---

## Section 7 · Scope

### Included in v1.0

- Full lifecycle (7 statuses + Cancelled + validated transitions)
- Configurable categories (table, not fixed enum)
- Own Technician Master (independent of BC Users)
- Incident-to-technician assignment with auto comment
- Append-only comment history (3 types)
- Optional link to existing Customer master
- Role Center (3 cues + 3 action tiles + StyleExpr on Critical)
- Profile "Barista Support Agent" as AL object
- Setup Wizard (3 steps, NavigatePage)
- Idempotent Demo Data Generator (5+5+15 linked to 3 existing clients)
- 3 permission sets with Execute on pages and codeunits

### Explicitly out of scope

- **OData REST API for external chatbot integration** → Phase 2, high priority for JP
- File attachments
- Email notifications to clients
- SLA automatic calculation
- Approval workflows
- Client portal
- Power BI advanced
- AI automatic categorisation
- Incident templates

---

## Section 8 · Technical requirements

| Parameter | Value |
|-----------|-------|
| Business Central | 27.0 or higher |
| AL Runtime | 16.0 or higher |
| Deployment | Cloud SaaS or On-Premise |
| BC licence | Essential or Premium |
| Dependencies | Base Application + System Application only |

---

## Section 9 · Acceptance criteria

The extension is considered complete when:

1. **AC1** · Create incident in < 5 clicks from Role Center to saved record
2. **AC2** · Lifecycle respects the transition matrix — invalid transitions trigger explicit `Error()`
3. **AC3** · Setup Wizard accessible from Tell Me and Role Center tile, completes all 3 steps successfully
4. **AC4** · Demo Data Generator creates exactly 5 categories + 5 technicians + 15 incidents linked to 3 existing CRONUS customers. Idempotent — re-running produces no duplicates and no errors
5. **AC5** · Role Center shows 3 cues (My Open, Unassigned, Critical) with correct counts and StyleExpr red on Critical > 0. 3 quick action tiles navigate correctly
6. **AC6** · Profile "Barista Support Agent" appears in Tell Me "Profiles" page and is selectable
7. **AC7** · Assignment lookup resolves correctly against Support Technician table (not User table) — no runtime PK error
8. **AC8** · All 3 permission sets have Execute entries on pages and the management codeunit
9. **AC9** · Extension publishes without errors on a clean BC sandbox CRONUS USA Inc.

---

## Section 10 · Glossary

| Term | Definition |
|------|-----------|
| **NavigatePage** | AL page type for multi-step wizards — uses `Next` / `Back` pattern |
| **FlowField** | Calculated BC field — result of a SIFT (Sum/Average/Count/Min/Max) on another table |
| **TableRelation** | Referential integrity declaration in AL — creates a lookup and validates on validate |
| **SIFT** | Sum Index Field Technology — BC mechanism for pre-aggregated FlowField calculations |
| **CueGroup** | Section within a CardPart for displaying KPI tiles (Cues) |
| **StyleExpr** | AL property that dynamically applies a visual style ('Favorable', 'Unfavorable', 'Attention') |
| **Append-only** | Design pattern: OnModify and OnDelete blocked with Error — records can only be inserted |
| **Idempotent** | Operation that can be executed multiple times producing the same result — no duplicates, no errors |
| **Execute (X)** | Permission to open a page or call a codeunit — required in addition to table data access |
| **No. Series** | BC number series mechanism — auto-assigns sequential formatted codes |

---

## Section 11 · Architect notes

### 11.1 Expected AL object structure

| Category | Objects |
|----------|---------|
| Tables | `Incident` · `Incident Category` · `Incident Comment` · `Support Technician` · `BRI Incident Cue` |
| TableExtensions | `Sales & Receivables Setup` (add `Incident Nos.` field) |
| Enums | `BRI Incident Status` (7) · `BRI Incident Priority` (4) · `BRI Comment Type` (3) · `BRI Incident Channel` (optional, 5) |
| Codeunits | `BRI Incident Management` · `BRI Demo Data Generator` |
| Pages | `Incident List` · `Incident Card` · `Incident Comments Part` · `Incident Category List` · `Support Technician List` · `Incident Activities` (CardPart) · `Incident Management Setup Wizard` (NavigatePage) · `Barista Support Role Center` (RoleCenter) |
| PageExtensions | `Sales Setup Page` extension |
| Profiles | `BRI Support Agent` |
| PermissionSets | `BRI Admin` · `BRI User` · `BRI Read` |

### 11.2 Mandatory technical decisions

1. `Assigned To` = `Code[20]` with `TableRelation` to `Support Technician` WHERE Active=CONST(true). **NEVER** standard `User` table
2. Cue table PK = `Code[10]` (standard BC singleton pattern)
3. Profile as AL object (not just a configuration page)
4. `StyleExpr = 'Unfavorable'` on `Critical Open` when value > 0
5. All permission sets: include `X` (Execute) on **all pages** and **all codeunits** of the module

### 11.3 Project configuration

| Parameter | Notes |
|-----------|-------|
| ID range | Propose within partner space (e.g. 50680-50699 or 50100-50149) |
| Complexity | MEDIUM (not HIGH — the scope is well defined, not ambiguous) |
| Object prefix | 3-4 characters · `BRI` (Barista Incidents) — follows AppSource convention |
| Publisher | Placeholder in `app.json` — adjust before final packaging |
| App Name | `Barista Incidents` |

### 11.4 Target demo environment

- CRONUS USA Inc. sandbox
- Product catalogue: WRB-\* and WDB-\* SKUs
- Demo data uses the first 3 active customers from this master

### 11.5 Single contact

JP is the only stakeholder authorised to approve or reject artefacts. Consult others for context only.

### 11.6 Explicit anti-patterns to avoid

1. **`TableRelation` on `User Name`** field of the standard `User` table — causes runtime error in BC. Use the own `Support Technician` table
2. **Assisted Setup registration** via `Guided Experience` codeunit — method signatures differ between BC versions. Access via Tell Me + Role Center tile is sufficient and stable
3. **Permission sets without `X` on pages and codeunits** — agents will get "You do not have permission" error at runtime even with full table access

---

*End of Technical PRD v1.0-workshop.*

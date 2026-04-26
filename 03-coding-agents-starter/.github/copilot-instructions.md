# Copilot Instructions · Workshop V-Valley 2026 · Bloque 03

> This file is the **project contract**. When you use ALDC agents
> (al-architect, al-spec.create, al-conductor), they read this file
> automatically and respect it across every phase.

## Project Context

- **Type**: Business Central SaaS · Per-Tenant Extension (PTE)
- **Purpose**: Barista Incidents — incident management for a coffee shop chain
- **Target platform**: BC SaaS, minimum version 26.0
- **Company prefix**: `CEB` (CompanyExtensionsBc — playground only)
- **Business context**: see `docs/caso-barista-incidents.md`

## Naming Conventions

- **Object prefix**: every new object name starts with `CEB` followed by a space
  (e.g. `CEB Incident`, `CEB Incident Severity`)
- **File naming**: `<ObjectName>.<ObjectType>.al` (PascalCase)
- **Location**: organize by object type under `app/src/<ObjectType>s/`

## ID Range

- Allowed range: **50100 – 50199** (as declared in `app.json`)
- Objects outside this range are blockers
- Field IDs inside table extensions stay in the parent range

## Required Patterns · Tables

- `DataClassification` at object level (default: `CustomerContent`)
- Every field has `Caption` and `ToolTip`
- Primary key `Code[20]` for master-data tables
- Set `LookupPageId` for lookup tables

## Required Patterns · Pages

- `ApplicationArea = All;` at page level
- `UsageCategory` declared explicitly
- Every page field has `ToolTip`
- List pages show at most 3 quick-access columns

## Required Patterns · Codeunits

- Public procedures have XML documentation (`///`)
- `Access` declared explicitly on every procedure
- Event subscribers preferred over direct system-codeunit calls
- `Rec.Modify(false)` requires inline justification comment

## Required Patterns · APIs

- API version: **v2.0** only (not v1.0)
- Expose APIs as `apipublisher = 'vsSistemas'`, `apigroup = 'workshop'`, `apiversion = 'v2.0'`
- Use **bound actions** for stateful operations (e.g. resolve, assign, escalate)
- Expose GET via queries or API pages; never expose raw table data directly
- API entity names in PascalCase, no spaces, no prefix (`incident`, not `CEB Incident`)

## Required Patterns · Events

- Publish integration events for domain state transitions
- Event naming: `On<State>Happened` for past events, `OnBefore<Action>` / `OnAfter<Action>` for hooks
- Event parameters: always pass the `Rec` record plus any relevant context record

## Permissions

- Every new object has at least one entry in a permission set
- Two permission sets per feature area:
  - `CEB <Feature> Basic` · read + usage (baristas, line workers)
  - `CEB <Feature> Full` · write + configuration (technicians, managers)

## Test Coverage

- Every public codeunit has a matching test codeunit in `test/src/Codeunits/`
- Test codeunits use `Subtype = Test;`
- Minimum one test method per public procedure

## Prohibited

- Obsolete patterns (`LookupFormId`, `RunFormLink`)
- Hardcoded numeric IDs in AL code · use symbol references
- New tables without `DataClassification`
- API v1.0 for new endpoints

## Style

- Indent with 4 spaces, never tabs
- One object per file
- Inside a table: `fields`, `keys`, `fieldgroups`, `procedures`, `triggers` in that order
- Inside a page: `layout`, `actions`, `procedures`, `triggers` in that order

## Output Expectations

When generating AL code:

- Return a single `.al` file unless explicitly asked for multiple
- No commentary before/after the code unless requested
- Code compiles without modifications

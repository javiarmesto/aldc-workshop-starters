# Copilot Instructions · Workshop V-Valley 2026 · Bloque 02

> This file is the **project contract**. It is the source of truth that
> `skill-diagnostics` audits against. Every rule declared here must be
> measurable on the source code — if you cannot verify a rule by scanning
> files, do not put it here.

## Project Context

- **Type**: Business Central SaaS · Per-Tenant Extension (PTE)
- **Purpose**: ALDC + Agent Skills playground · used during Bloque 02 demo
- **Target platform**: BC SaaS, minimum version 26.0
- **Company prefix**: `CEB` (CompanyExtensionsBc — playground only)

## Naming Conventions

- **Object prefix**: every new object name starts with `CEB` followed by a space
- **File naming**: `<ObjectName>.<ObjectType>.al` (PascalCase)
  - Examples: `CEBSupportTier.Table.al`, `CEBSupportTierList.Page.al`
- **Location**: organize by object type under `app/src/<ObjectType>s/`

## ID Range

- Allowed range: **50100 – 50149** (as declared in `app.json`)
- Objects outside this range are blockers
- Field IDs inside table extensions also stay in the parent range

## Required Patterns · Tables

- `DataClassification` declared at object level (default: `CustomerContent`)
- Every field must have `Caption`
- Every field must have `ToolTip` **except** primary-key code fields of lookup tables
- Every field must have `DataClassification` (inherited from object level is OK)
- Primary-key field for master-data tables: `Code[20]`
- If the table is a lookup, set `LookupPageId` to its default list page

## Required Patterns · Pages

- `ApplicationArea = All;` declared at page level
- `UsageCategory` set to one of `Lists`, `Documents`, `Tasks`, `Administration`, `ReportsAndAnalysis`, `History`
- Every page field has `ToolTip`
- List pages expose at most **3 quick-access columns** in the default `Content` area

## Required Patterns · Codeunits

- Public procedures require XML documentation comments (`///`)
- `Access` property explicitly declared (`Public` or `Internal`) on every procedure
- Event subscribers preferred over direct calls to system codeunits when hooking business logic
- `Rec.Modify(false)` requires an inline comment justifying why default validation is skipped

## Required Patterns · Enums

- All new enums declare `Extensible = true;` unless there is a written reason not to
- Enum values have `Caption`

## Permissions

- Every new object has at least one entry in a permission set
- Permission sets are named `CEB <Feature> Basic` and `CEB <Feature> Full`
- `CEB <Feature> Basic` grants read + usage rights; `Full` adds write + configuration

## Test Coverage

- Every public codeunit in `app/src/Codeunits/` has a matching test codeunit
  in `test/src/Codeunits/` named `<OriginalName>Test.Codeunit.al`
- Test codeunits use `Subtype = Test;`
- Minimum one test method per public procedure of the tested codeunit

## Prohibited

- Hardcoded numeric IDs inside AL code (use symbol references)
- `Rec.Modify(false)` without inline justification comment
- Obsoleted patterns: `LookupFormId`, `RunFormLink`, `DataPerCompany = No` without approval
- New tables without `DataClassification` at object level
- New fields without both `Caption` and `ToolTip` (except PK of lookup tables)
- Public procedures without XML documentation

## Style

- Indent with 4 spaces, never tabs
- One object per file
- Inside a table: order is `fields`, `keys`, `fieldgroups`, `procedures`, `triggers`
- Inside a page: order is `layout`, `actions`, `procedures`, `triggers`

## Output Expectations

When generating AL code:

- Return a **single `.al` file** unless explicitly asked for multiple
- No commentary before/after the code unless requested
- Generated code must compile without modifications

# Copilot Instructions · Workshop V-Valley 2026 · Bloque 01

> This file is your **project contract**. Copilot reads it automatically on every
> chat request and uses it to fill in gaps in your prompts. Keep it small, precise,
> and free of examples — examples belong in prompt files and skills.

## Project Context

- **Type**: Business Central SaaS · Per-Tenant Extension (PTE)
- **Purpose**: Customer support tier management demo · playground for Bloque 01
- **Target platform**: BC SaaS, min version 26.0
- **Company prefix**: `CEB` (CompanyExtensionsBc — playground only, not a real brand)

## Naming Conventions

- **Object prefix**: every new object name starts with `CEB` followed by a space (for example `CEB Support Tier`)
- **File naming**: `<ObjectName>.<ObjectType>.al` (PascalCase, abbreviated: `.Table.al`, `.Page.al`, `.Codeunit.al`, `.Enum.al`)
- **Location**: organize files by object type under `app/src/<ObjectType>s/`
  - `app/src/Tables/` · tables, table extensions
  - `app/src/Pages/` · pages, page extensions
  - `app/src/Codeunits/` · codeunits
  - `app/src/Enums/` · enums, enum extensions

## ID Range

- Allowed range: **50100 – 50149** (as declared in `app.json`)
- Never allocate IDs outside this range
- When generating objects, pick the lowest available ID

## Required Patterns

Every AL object must follow these rules. Do not generate code that violates them.

### Tables

- `DataClassification = CustomerContent;` at object level, unless a field holds system metadata
- Every field must have `Caption` and `ToolTip`
- Every field must have `DataClassification` (inherits from object level if not specified)
- Primary key: `Code[20]` for master-data tables named "Code"
- If the table is a lookup table, set `LookupPageId` to its default list page

### Pages

- Every field on a page gets a `ToolTip`
- `ApplicationArea = All;` at page level
- `UsageCategory` set to `Lists`, `Documents`, `Tasks`, or `Administration` as appropriate

### Codeunits

- Prefer event subscribers over modifying base tables directly
- Public procedures require XML documentation comments
- Never call `Rec.Modify(false)` without a comment justifying why the default validation is skipped

## Permissions

- Every new object needs a corresponding entry in at least one permission set
- New permission sets use naming `CEB <Feature> Basic` and `CEB <Feature> Full`

## Prohibited

- Obsoleted patterns (e.g. `LookupFormId`, `RunFormLink`)
- Hardcoded object IDs inside AL code · use symbol references
- Generating code without Caption/ToolTip on user-visible elements
- Creating new tables without `DataClassification`

## Style Preferences

- Indent with 4 spaces (not tabs)
- One object per file
- Group `fields { }`, `keys { }`, `fieldgroups { }`, `procedures`, `triggers` in that order inside a table
- Group `layout { area() { ... } }`, `actions { area() { ... } }`, `procedures`, `triggers` in that order inside a page

## Output Expectations

When generating AL code:

- Return a **single `.al` file** unless explicitly asked for multiple
- Include `namespace <Publisher>;` declarations only if the target workspace already uses namespaces
- Do **not** add commentary before or after the code unless asked for explanation
- Generated code must compile without modifications

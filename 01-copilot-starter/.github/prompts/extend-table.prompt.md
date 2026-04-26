---
mode: edit
description: Generate an AL table extension that follows the project contract (CEB prefix, ID range, Caption/ToolTip, DataClassification).
---

# Extend Table

You are extending an existing Business Central table by adding new fields. Follow the
project's `copilot-instructions.md` contract — prefix, ID range, required patterns,
file layout — without requiring it to be repeated in the prompt.

## Inputs required from the user

Ask the user for the following information if not already provided in the prompt:

1. **Source table** · name of the BC table to extend (e.g. `Customer`, `Item`, `Sales Header`)
2. **New fields** · for each field, ask for:
   - Field name (without prefix · the prefix is added automatically)
   - Data type (e.g. `Code[20]`, `Text[100]`, `Integer`, `Boolean`, `Date`, `Option`)
   - Business description (for `Caption` and `ToolTip`)
   - Whether the field is a FlowField, a linked reference to another table, or a simple value
3. **Business reason** · a single sentence explaining why these fields are needed
   (used only to seed meaningful defaults for Caption and ToolTip — not embedded
   in the output as a comment)

## Generation rules

- **Object name**: `CEB <SourceTable> Ext` (the space before `Ext` is deliberate)
- **Object ID**: allocate the next available ID in the range `50100–50149`
- **File name**: `CEB<SourceTableNoSpaces>Ext.TableExt.al`
- **File location**: `app/src/TableExtensions/`
- **Field IDs**: start at `50100`, increment sequentially
- **Field names**: prefix user-provided field names with `CEB ` (for example
  user writes `Support Tier Code` → field name becomes `CEB Support Tier Code`)
- **Caption**: same as the field name without the prefix
- **ToolTip**: a short, end-user-friendly sentence derived from the business description
- **DataClassification**: `CustomerContent` by default, unless the field is clearly
  system metadata (timestamps, audit fields → `SystemMetadata`)
- **TableRelation**: if the user says the field links to another table, generate
  `TableRelation = <TargetTable>.<PrimaryKey>;`

## Output format

Return a single AL file. Structure:

```al
tableextension 50100 "CEB <SourceTable> Ext" extends "<SourceTable>"
{
    fields
    {
        field(50100; "CEB <FieldName1>"; <Type>)
        {
            Caption = '<Caption1>';
            ToolTip = '<ToolTip1>';
            DataClassification = CustomerContent;
            // TableRelation = ...; when applicable
        }
        // ... additional fields
    }
}
```

## Do not

- Do not generate explanatory prose before or after the code
- Do not add `trigger OnValidate()` or business logic unless the user specifically asks
- Do not introduce new enums or custom types inline — if needed, ask the user to
  create the enum separately first
- Do not invent field IDs outside the allowed range

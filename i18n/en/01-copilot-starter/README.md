> 🇪🇸 [Versión en español](../../01-copilot-starter/README.md) · 🇬🇧 English

<div align="center">

# Workshop ALDC · V-Valley 2026
### Block 01 Template · GitHub Copilot for Business Central

[![Workshop](https://img.shields.io/badge/workshop-V--Valley%202026-232529?style=flat-square)](https://javiarmesto.github.io/workshop-v-valley-aldc-2026-04/)
[![Block 01](https://img.shields.io/badge/block-01%20·%20Copilot-7a9e00?style=flat-square)](https://javiarmesto.github.io/workshop-v-valley-aldc-2026-04/bloques/01-copilot/)
[![AL-Go PTE](https://img.shields.io/badge/AL--Go-PTE-d8723c?style=flat-square)](https://github.com/microsoft/AL-Go-PTE)

**[📖 Block material](https://javiarmesto.github.io/workshop-v-valley-aldc-2026-04/bloques/01-copilot/)** · **[🌐 Full workshop](https://javiarmesto.github.io/workshop-v-valley-aldc-2026-04/)**

</div>

---

## What this is

Starting template for **Block 01 of the ALDC V-Valley 2026 Workshop**. Contains the bare minimum for a functional AL project — the contract file and the prompt file we will use in the demo.

If you arrived here during the workshop, **fork this repo** into your own account and clone it locally. It takes 30 seconds and you can follow along with the demo in parallel.

## Structure

```
workshop-b01-start/
├── app/
│   ├── app.json                         ← PTE · CEB prefix · ID range 50100-50149
│   └── src/
│       └── HelloWorld.PageExt.al        ← initial sample · confirms it compiles
├── .github/
│   ├── copilot-instructions.md          ← 👈 the project contract
│   └── prompts/
│       └── extend-table.prompt.md       ← 👈 the reusable prompt /extend-table
├── .AL-Go/
│   └── settings.json                    ← minimal AL-Go config
├── .vscode/
│   └── launch.json                      ← publish to BC Sandbox Cloud
├── .gitignore
└── README.md                            ← this file
```

## The two files that matter

### 1. `.github/copilot-instructions.md` · the contract

Defines what applies **automatically** to every prompt you fire in this workspace:

- `CEB` prefix on every new object
- ID range `50100 – 50149`
- `DataClassification`, `Caption` and `ToolTip` mandatory in tables
- Folder structure (`Tables/`, `Pages/`, etc.)
- Code style (4 spaces, section ordering, etc.)

> **Customise it.** This contract is a starting point designed for the demo. Your company probably uses a different prefix, a different range, and different conventions. **Open it, read it, and change it to reflect how you actually work.** The good contract is the one that reflects your reality.

### 2. `.github/prompts/extend-table.prompt.md` · the reusable prompt

Invoked with `/extend-table` from Copilot Chat. When you fire it, Copilot:

1. Asks for source table, new fields, and business reason
2. Applies the contract above automatically (prefix, range, DataClassification, Caption/ToolTip)
3. Generates a `.al` file ready to compile

> **Also customisable.** Look at the file — it is 60 lines of markdown. If in your company table extensions always carry a `trigger OnValidate` on certain fields, or specific XML doc, **add it to the prompt rules**.

## How to use it during Block 01

### Prerequisites

- **VS Code** with the following extensions:
  - `ms-dynamics-smb.al` (AL Language)
  - `GitHub.copilot` + `GitHub.copilot-chat`
- **Active GitHub Copilot account** (free trial is fine)
- **Business Central sandbox** (any BC SaaS sandbox works — we will not actually publish, only in case there is time to try)

### Quick start (30 seconds)

```bash
# 1. Clone the exercises repo
git clone https://github.com/javiarmesto/workshop-v-valley-aldc-2026-04-EJERCICIOS.git
# 2. Open ONLY the block folder (important: do not open the repo root)
code workshop-v-valley-aldc-2026-04-EJERCICIOS/01-copilot-starter
```

**⚙️ Configure before compiling** (2 minutes):

1. Open `.vscode/launch.json` → change `"environmentName"` to your real sandbox name
2. Open `app.json` → adjust `idRanges`, `publisher` and `name` to your company's if you want
3. Download symbols: `Ctrl+Shift+P` → `AL: Download Symbols`

Without the steps above AL Language will not compile — the sandbox is the type reference.

> VS Code may take ~30s to load AL extensions on first launch.

### During the demo

> ⚠️ **First exercise — temporarily disable the contract**  
> Prompt 1 is designed to show what Copilot generates **without** any active contract. For the contrast to be real, **move or delete** `.github/copilot-instructions.md` before running it. Restore it afterwards with `git checkout .github/copilot-instructions.md` before Prompts 2 and 3.

The speaker will run 3 prompts in Copilot Chat. Replicate on your machine:

**Prompt 1 · vague** *(without active contract)*
```
Create a table for customer support tiers
```
Observe what it generates. This is what happens without a contract.

**Prompt 2 · structured with Context/Task/Constraints/Output pattern**
```
Context: BC SaaS. Follow copilot-instructions.md.
Task: Generate AL table "CEB Support Tier" in range 50100-50149.
Constraints:
- PK: Code (Code[20])
- Fields: Description, SLA Hours, Priority, Active
- Caption + ToolTip on every field
- DataClassification per field
- Include LookupPageId
Output: Single .al file, ready to compile.
```
Observe how the contract (`copilot-instructions.md`) is applied automatically.

**Prompt 3 · invoking the reusable prompt**
```
/extend-table
```
Answer the questions it asks — for example:
- Source table: `Customer`
- Fields: `Support Tier Code` (Code[20], link to CEB Support Tier), `Support Active` (Boolean), `Support Start Date` (Date)
- Business reason: `Enable tier-based customer support workflows`

Observe how it reuses the contract without you having to repeat it.

## Optional exercises · if you are ahead or want to practise afterwards

### Exercise 1 · create your first prompt file

After Block 01, type in Copilot Chat:

```
/create-prompt
```

When asked what prompt you want to create, respond with something like:

> *A prompt that generates integration codeunits to expose v2.0 APIs following our conventions, with bound actions for stateful operations and error handling using ErrorInfo.*

Copilot will ask clarifying questions and generate the prompt file in `.github/prompts/`. **Review and adjust it.**

### Exercise 2 · customise the instructions

If you have a real ID range from your company, or a different prefix, open `.github/copilot-instructions.md` and change it. Also update `app.json` so that `idRanges` and `publisher` match.

Then re-run **Prompt 2** and watch Copilot apply your new values without you having to repeat them.

### Exercise 3 · extend the contract

Add a custom rule to `copilot-instructions.md` that has caused you problems in another project. Examples:

- *"All text fields in master data tables must be non-blank: add `trigger OnValidate()` enforcing `TestField()`."*
- *"Integer fields representing money must use `Decimal` with `AutoFormatType = 1;` and `AutoFormatExpression = '<Precision,2:>';`."*
- *"Codeunits exposing procedures to other extensions must declare `Access = Public;` explicitly."*

Then re-run `/extend-table` to watch Copilot start following them.

## Relationship to the full workshop

This is the template for **one block only**. For the rest:

- **Block 02** · Template with clean `.github/` + pre-created `skill-diagnostics` skill → [workshop-b02-start](../workshop-b02-start) *(another repo)*
- **Block 03** · Template with ALDC already installed + Barista Incidents context → [workshop-b03-start](../workshop-b03-start) *(another repo)*
- **Block 04** · Online lab guide only → [block 04 site](https://javiarmesto.github.io/workshop-v-valley-aldc-2026-04/bloques/04-caso-practico/)

## Credits

Based on **[AL-Go for GitHub · PTE template](https://github.com/microsoft/AL-Go-PTE)** by Microsoft. The official template includes full CI/CD; here only the minimum files for the workshop are kept. If you are setting up a real project, **fork the official template** and copy only the `.github/` files you want to reuse from here.

## Licence

- **Content** (text, instructions, prompt files) · [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/)
- **AL code** (sample) · [MIT](https://opensource.org/licenses/MIT)

You may use this template at your company, for internal training, or for your own presentations — please credit the source.

---

<div align="center">
<sub>Workshop ALDC · V-Valley 2026 · Javier Armesto</sub>
</div>

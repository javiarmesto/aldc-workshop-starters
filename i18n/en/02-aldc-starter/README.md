> 🇪🇸 [Versión en español](../../02-aldc-starter/README.md) · 🇬🇧 English

<div align="center">

# Workshop ALDC · V-Valley 2026
### Block 02 Template · ALDC + Agent Skills + Skills Evidencing

[![Workshop](https://img.shields.io/badge/workshop-V--Valley%202026-818CF8?style=flat-square)](https://javiarmesto.github.io/workshop-v-valley-aldc-2026-04/)
[![Block 02](https://img.shields.io/badge/block-02%20·%20ALDC-E879A8?style=flat-square)](https://javiarmesto.github.io/workshop-v-valley-aldc-2026-04/bloques/02-aldc/)
[![Agent Skills](https://img.shields.io/badge/agent--skills-spec-34D399?style=flat-square)](https://agentskills.io/specification)

**[📖 Block material](https://javiarmesto.github.io/workshop-v-valley-aldc-2026-04/bloques/02-aldc/)** · **[🌐 Full workshop](https://javiarmesto.github.io/workshop-v-valley-aldc-2026-04/)**

</div>

---

## What this is

Starting template for **Block 02 of the ALDC V-Valley 2026 Workshop**. It is deliberately **minimalist** — it starts with only two files in `.github/`:

- `copilot-instructions.md` · the project contract
- `skills/skill-diagnostics/SKILL.md` · the skill that will audit against that contract

During the block you will watch **ALDC install live** and populate this folder with ~44 more pieces (agents, workflows, other skills). The point of starting clean is that you see the transformation with your own eyes.

## Initial structure

```
workshop-b02-start/
├── app/
│   ├── app.json                              ← PTE playground
│   └── src/
│       └── HelloWorld.PageExt.al             ← compiles OK from minute zero
├── .github/
│   ├── copilot-instructions.md               ← 👈 the contract that skill-diagnostics audits
│   └── skills/
│       └── skill-diagnostics/
│           ├── SKILL.md                      ← 👈 the workshop skill · ~20 rules
│           └── references/
│               └── severity-guide.md         ← severity decision tree
├── .AL-Go/settings.json
├── .vscode/launch.json
├── .gitignore
└── README.md                                 ← this file
```

## The star piece · `skill-diagnostics`

It is an **Agent Skill** written following the [official agentskills.io spec](https://agentskills.io/specification). What it does:

- **Statically audits** the AL workspace against the rules declared in `copilot-instructions.md`
- **Classifies findings** into 4 classes: Compliance · Code quality · Test coverage · Permissions
- **Assigns severity** between Blocker · Major · Minor · Nit (with a conservative rule: *when in doubt, go lower*)
- **Cites `file:line`** and the contract rule that backs each finding
- **Never modifies code.** Reports only.
- **Never invents rules.** If a rule is not declared in the contract, it is not applied. If it believes it should be there, it suggests it in a separate section.

The ~20 rules it ships with are mapped 1:1 to points in the contract. If you modify the contract, the skill adapts automatically — it only enforces rules that still have backing.

### How to invoke it

The skill auto-loads via its `description` when you write something related in Copilot Chat:

```
Audit my workspace against the contract
```

Or explicitly:

```
Load skill-diagnostics and scan the workspace. Use the output format strictly
and include the Skills Applied block at the end.
```

Copilot will emit a structured report with summary, findings by class, and at the end the `Skills Applied` block (so the report self-documents — *Skills Evidencing*).

## How to use it during Block 02

### Prerequisites

- **VS Code** with extensions:
  - `ms-dynamics-smb.al`
  - `GitHub.copilot` + `GitHub.copilot-chat`
  - The **ALDC** extension will be available in Marketplace · **we will install it live during the demo**, do not install it beforehand
- **Active GitHub Copilot account**
- **Business Central sandbox** (optional for this block)

### Quick start

```bash
# 1. Clone the exercises repo
git clone https://github.com/javiarmesto/workshop-v-valley-aldc-2026-04-EJERCICIOS.git
# 2. Open ONLY the block folder (important: do not open the repo root)
code workshop-v-valley-aldc-2026-04-EJERCICIOS/02-aldc-starter
```

> 📁 **Open the `02-aldc-starter/` subfolder, not the repo root.**  
> The files `app.json`, `.gitignore` and the `.vscode/` folder must be directly at the root of what VS Code sees. If you open the full repo, Copilot and AL Language will not find the files where they expect them.

**⚙️ Configure before compiling** (2 minutes):

1. Open `.vscode/launch.json` → change `"environmentName"` to your real sandbox name
2. Review `app.json` → adjust `idRanges` and `publisher` if you want to use your company's
3. Download symbols: `Ctrl+Shift+P` → `AL: Download Symbols`

**Important:** the workspace starts with `.github/` almost empty. This is **intentional**. Do not add anything before the demo.

### During the demo

Follow along with the speaker on your machine:

#### Step 1 · open the contract

Open `.github/copilot-instructions.md` and read it. It is ~80 lines. These are **the rules that skill-diagnostics will audit**. If you change one, the skill adapts.

#### Step 2 · open the skill

Open `.github/skills/skill-diagnostics/SKILL.md`. Look at:

- **YAML frontmatter** with `name` and `description` — where Copilot finds it
- **`## Purpose` section**
- **`## Rule catalogue` section** — the table with the ~20 rules
- **`## Output format` section** — exact shape of the report
- **`## Constraints` section** — rules the skill never breaks

#### Step 3 · test the skill on a real repo (yours)

For `skill-diagnostics` to have **obvious findings**, you do not need to introduce an artificial defect. The most effective approach is to run it against one of your own real AL repos — one without a contract or ALDC.

1. **Open one of your own AL repos** in VS Code (any real company project)
2. **Copy the `.github/` folder** from this starter (`02-aldc-starter/.github/`) to the root of that repo:  
   It should end up as: `your-repo/.github/copilot-instructions.md` and `your-repo/.github/skills/skill-diagnostics/`
3. **Fire the skill** in Copilot Chat on that workspace:
   ```
   Load skill-diagnostics and scan the workspace. Follow the output format strictly.
   ```
4. **Observe the findings.** Without a proper contract in that repo, the skill will report multiple violations — that is the starting point we want to see.

> This is far more instructive than introducing a defect by hand — the findings are real, they are yours, and you recognise them.

#### Step 4 · fire the skill

```
Load skill-diagnostics and scan the workspace. Follow the output format strictly.
```

Read the report. Walk through the findings one by one with the speaker. See how each finding cites:
- The rule (`C3`, `Q1`, etc.)
- The file and line
- Which part of `copilot-instructions.md` backs the rule

#### Step 5 · install ALDC and re-run the audit

When the speaker signals, go back to the starter workspace (or the repo you used above). Open Marketplace and search for **AL Development Collection**. Install the extension, run `AL Collection: Install Toolkit to Workspace`, and refresh Explorer. Verify that `.github/` has been populated with:

- `agents/` · 4 agents (al-architect, al-conductor, al-developer, al-presales)
- `prompts/` · reusable prompts
- `skills/` · 15 skills (your `skill-diagnostics` stays **intact** — ALDC adds, does not overwrite)
- `workflows/` · 10 workflows

**Now re-run the same audit:**
```
Load skill-diagnostics and scan the workspace. Follow the output format strictly.
```

Compare the report with the previous one. With the contract installed by ALDC, many findings will disappear automatically because the contract covers their rules. Those that remain are the ones the project needs to fix in code.

This is **Skills Evidencing** in operation.

## Optional exercises · create your own skill

### Exercise 1 · log skill

As the speaker mentioned, install a **skill creator** (or do it by hand following the canonical structure you see in `skill-diagnostics`) and create a small skill: for example, one that writes entries to a `CHANGELOG.md` file every time you close a feature.

```
/create-skill

I want a skill that records each development milestone in a
CHANGELOG.md file in the repository, with date, feature, decisions taken,
and tests run. The idea is that the project history is traced
without depending on the commit history.
```

Copilot will generate the correct `SKILL.md` structure. Review it, adjust it, and test it.

### Exercise 2 · customise the rules of `skill-diagnostics`

Open the `SKILL.md` and:

1. Add a **new rule** (for example: `Q9 · Every Report object has a Usage Category declared`)
2. Add the corresponding backing in `copilot-instructions.md`
3. Re-run the skill and verify the new rule appears in the catalogue

If you add it to the skill **without adding it to the contract**, the skill should reject it (or move it to "Suggested contract additions" in the report). That is part of the design — **never invent rules**.

### Exercise 3 · look at the official spec

Open https://agentskills.io/specification and compare it with your `SKILL.md`. Which frontmatter fields are we not using? `allowed-tools`? `compatibility`? See if any would be useful for your use case.

## Relationship to the full workshop

- **Block 01** · Basic Copilot template → [workshop-b01-start](../workshop-b01-start) *(another repo)*
- **Block 02** · *this template*
- **Block 03** · Template with ALDC already installed + Barista Incidents context → [workshop-b03-start](../workshop-b03-start) *(another repo)*
- **Block 04** · Online case study guide → [block 04 site](https://javiarmesto.github.io/workshop-v-valley-aldc-2026-04/bloques/04-caso-practico/)

## Credits and resources

- **[Agent Skills specification](https://agentskills.io/specification)** · open spec for skills
- **[VS Code · Agent Skills docs](https://code.visualstudio.com/docs/copilot/customization/agent-skills)** · how auto-loading works in Copilot Chat
- **[ALDC repo](https://github.com/javiarmesto/ALDC-AL-Development-Collection)** · the technical project the workshop talks about
- **[AL-Go PTE template](https://github.com/microsoft/AL-Go-PTE)** · base for this starter

## Licence

- **Content** (contract, SKILL.md, text) · [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/)
- **AL code** (sample) · [MIT](https://opensource.org/licenses/MIT)

---

<div align="center">
<sub>Workshop ALDC · V-Valley 2026 · Javier Armesto</sub>
</div>

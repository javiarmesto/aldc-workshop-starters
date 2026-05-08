> 🇪🇸 [Versión en español](../../../03-coding-agents-starter/docs/INSTALACION-ALDC.md) · 🇬🇧 English

# Installing ALDC in this workspace

> This template starts **without ALDC installed** on purpose — we want you to see
> step 2 on your own machine before starting the Block 03 exercises.

## Prerequisites

- Up-to-date VS Code
- **AL Language** extension (`ms-dynamics-smb.al`) installed
- GitHub Copilot Chat working (free plan is fine)
- This workspace open in VS Code

## The 3 steps · takes about 2 minutes in total

### Step 1 · install the ALDC extension

Open **Marketplace** (`Ctrl+Shift+X`) and search for:

```
AL Development Collection
```

Publisher: **JavierArmestoGonzalez**. Click **Install**.

Or alternatively, open the direct link:

- https://marketplace.visualstudio.com/items?itemName=JavierArmestoGonzalez.al-development-collection

### Step 2 · copy ALDC to the workspace

`Ctrl+Shift+P` to open the command palette, and type:

```
AL Collection: Install Toolkit to Workspace
```

Press **Enter**. ALDC will copy its pieces into `.github/` in the current workspace.

### Step 3 · refresh the Explorer

Press **F1** → `Developer: Reload Window`. Or simply close and reopen the
folder in VS Code.

## What should have appeared in `.github/`

```
.github/
├── agents/
│   ├── al-architect.agent.md
│   ├── al-conductor.agent.md
│   ├── al-developer.agent.md
│   ├── al-presales.agent.md
│   ├── al-planning-subagent.agent.md
│   ├── al-implement-subagent.agent.md
│   └── al-review-subagent.agent.md
├── instructions/
│   ├── (the 7 auto-applied instructions by file type)
├── prompts/
│   ├── al-spec.create.prompt.md
│   └── (remaining prompts)
├── skills/
│   ├── skill-api/
│   ├── skill-debug/
│   ├── skill-events/
│   ├── skill-pages/
│   ├── skill-performance/
│   ├── skill-permissions/
│   └── (and the rest up to 15 skills)
├── workflows/
│   └── (the 10 workflows)
└── copilot-instructions.md  ← 👈 already existed, you kept it
```

That `copilot-instructions.md` you already had is **respected**. ALDC does not overwrite it
— it adds, does not replace. Same mechanic as in Block 02.

## How to invoke ALDC agents and workflows

From Copilot Chat:

- **Invoke al-architect** (agent):
  ```
  Load al-architect
  ```
  or simply describe what you want to do — Copilot auto-loads it via the
  `description` in the frontmatter.

- **Invoke al-spec.create** (workflow):
  ```
  @workspace use al-spec.create
  ```

- **See which agents are available**:
  ```
  /
  ```
  The list that appears will show skills and prompts as slash commands.

## If something does not work

- **The "Install Toolkit to Workspace" command does not appear** → close and reopen VS Code
  to refresh extensions. Verify ALDC is in your installed extensions list (`Ctrl+Shift+X`).
- **The pieces installed but Copilot does not invoke them** → open the palette and
  run `Chat: Open Chat Customizations` to review which agents/prompts/skills are active.
- **General questions about ALDC** → [ALDC repo](https://github.com/javiarmesto/ALDC-AL-Development-Collection)
  with open issues for questions.

## Once installed

Continue with the **main README** of this template for the Block 03 exercises:

→ [README.md](../README.md#how-to-use-it-during-block-03)

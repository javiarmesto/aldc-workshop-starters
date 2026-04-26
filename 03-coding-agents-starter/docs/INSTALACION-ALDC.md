# Instalación de ALDC en este workspace

> Este template parte **sin ALDC instalado** a propósito — queremos que veas
> el paso 2 en tu propia máquina antes de empezar los ejercicios del Bloque 03.

## Pre-requisitos

- VS Code actualizado
- Extensión **AL Language** (`ms-dynamics-smb.al`) instalada
- GitHub Copilot Chat funcionando (plan gratuito vale)
- Este workspace abierto en VS Code

## Los 3 pasos · tardan unos 2 minutos en total

### Paso 1 · instalar la extensión ALDC

Abre **Marketplace** (`Ctrl+Shift+X`) y busca:

```
AL Development Collection
```

Publisher: **JavierArmestoGonzalez**. Pulsa **Install**.

O alternativamente, abre el link directo:

- https://marketplace.visualstudio.com/items?itemName=JavierArmestoGonzalez.al-development-collection

### Paso 2 · copiar ALDC al workspace

`Ctrl+Shift+P` para abrir la paleta de comandos, y escribe:

```
AL Collection: Install Toolkit to Workspace
```

Pulsa **Enter**. ALDC copiará sus piezas dentro de `.github/` en el workspace actual.

### Paso 3 · refrescar el explorador

Pulsa **F1** → `Developer: Reload Window`. O simplemente cierra y reabre la
carpeta en VS Code.

## Qué debería haber aparecido en `.github/`

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
│   ├── (las 7 instructions auto-aplicadas por tipo de fichero)
├── prompts/
│   ├── al-spec.create.prompt.md
│   └── (resto de prompts)
├── skills/
│   ├── skill-api/
│   ├── skill-debug/
│   ├── skill-events/
│   ├── skill-pages/
│   ├── skill-performance/
│   ├── skill-permissions/
│   └── (y el resto hasta las 15 skills)
├── workflows/
│   └── (los 10 workflows)
└── copilot-instructions.md  ← 👈 ya estaba, lo has mantenido
```

Ese `copilot-instructions.md` que ya traías **se respeta**. ALDC no lo sobrescribe
— añade, no reemplaza. Es la misma mecánica que viste en el Bloque 02.

## Cómo invocar agentes y workflows de ALDC

Desde Copilot Chat:

- **Invocar al-architect** (agente):
  ```
  Load al-architect
  ```
  o simplemente describiendo lo que quieres hacer — Copilot lo auto-carga por la
  `description` del frontmatter.

- **Invocar al-spec.create** (workflow):
  ```
  @workspace use al-spec.create
  ```

- **Ver qué agentes están disponibles**:
  ```
  /
  ```
  En la lista que aparece verás las skills y prompts como slash commands.

## Si algo no funciona

- **El comando "Install Toolkit to Workspace" no aparece** → cierra y reabre VS Code
  para refrescar las extensiones. Verifica que ALDC está en tu lista de extensiones
  instaladas (`Ctrl+Shift+X`).
- **Se instalaron las piezas pero Copilot no las invoca** → abre la paleta y
  ejecuta `Chat: Open Chat Customizations` para revisar qué agentes/prompts/skills
  están activos.
- **Dudas sobre ALDC en general** → [repo de ALDC](https://github.com/javiarmesto/ALDC-AL-Development-Collection)
  con issues abiertas para preguntas.

## Una vez instalado

Continúa con el **README principal** de este template para los ejercicios del
Bloque 03:

→ [README.md](../README.md#ejercicios-del-bloque-03)

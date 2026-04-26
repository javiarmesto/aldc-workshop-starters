<div align="center">

# Workshop ALDC · V-Valley 2026
### Template del Bloque 02 · ALDC + Agent Skills + Skills Evidencing

[![Workshop](https://img.shields.io/badge/workshop-V--Valley%202026-818CF8?style=flat-square)](https://javiarmesto.github.io/workshop-v-valley-aldc-2026-04/)
[![Bloque 02](https://img.shields.io/badge/bloque-02%20·%20ALDC-E879A8?style=flat-square)](https://javiarmesto.github.io/workshop-v-valley-aldc-2026-04/bloques/02-aldc/)
[![Agent Skills](https://img.shields.io/badge/agent--skills-spec-34D399?style=flat-square)](https://agentskills.io/specification)

**[📖 Material del bloque](https://javiarmesto.github.io/workshop-v-valley-aldc-2026-04/bloques/02-aldc/)** · **[🌐 Workshop completo](https://javiarmesto.github.io/workshop-v-valley-aldc-2026-04/)**

</div>

---

## Qué es esto

Template de partida para el **Bloque 02 del Workshop ALDC V-Valley 2026**. Es deliberadamente **minimalista** — empieza con solo dos ficheros en `.github/`:

- `copilot-instructions.md` · el contrato del proyecto
- `skills/skill-diagnostics/SKILL.md` · la skill que auditará contra ese contrato

Durante el bloque verás cómo **ALDC se instala en vivo** y puebla esta carpeta con ~44 piezas más (agentes, workflows, otras skills). La gracia de partir limpio es que veas la transformación con tus propios ojos.

## Estructura inicial

```
workshop-b02-start/
├── app/
│   ├── app.json                              ← PTE playground
│   └── src/
│       └── HelloWorld.PageExt.al             ← compila OK desde el minuto cero
├── .github/
│   ├── copilot-instructions.md               ← 👈 el contrato que skill-diagnostics audita
│   └── skills/
│       └── skill-diagnostics/
│           ├── SKILL.md                      ← 👈 la skill del workshop · ~20 reglas
│           └── references/
│               └── severity-guide.md         ← árbol de decisión de severidades
├── .AL-Go/settings.json
├── .vscode/launch.json
├── .gitignore
└── README.md                                 ← este fichero
```

## La pieza estrella · `skill-diagnostics`

Es una **Agent Skill** escrita siguiendo la [spec oficial de agentskills.io](https://agentskills.io/specification). Lo que hace:

- **Audita estáticamente** el workspace AL contra las reglas declaradas en `copilot-instructions.md`
- **Clasifica hallazgos** en 4 clases: Compliance · Code quality · Test coverage · Permissions
- **Asigna severidad** entre Blocker · Major · Minor · Nit (con regla conservadora: *si dudas, baja*)
- **Cita `file:line`** y la regla del contrato que respalda cada hallazgo
- **Nunca modifica código.** Reporta y punto.
- **Nunca inventa reglas.** Si una regla no está declarada en el contrato, no la aplica. Si cree que debería estarlo, la sugiere en una sección aparte.

Las ~20 reglas que trae están mapeadas 1:1 a puntos del contrato. Si tú modificas el contrato, la skill se adapta automáticamente — solo aplica las reglas que aún tengan respaldo.

### Cómo invocarla

La skill se auto-carga por su `description` cuando escribes algo afín en Copilot Chat:

```
Audita mi workspace contra el contrato
```

O explícitamente:

```
Load skill-diagnostics and scan the workspace. Use the output format strictly
and include the Skills Applied block at the end.
```

Copilot emitirá un reporte estructurado con summary, findings por clase, y al final el bloque `Skills Applied` (así el reporte se auto-documenta — *Skills Evidencing*).

## Cómo usarlo durante el Bloque 02

### Pre-requisitos

- **VS Code** con extensiones:
  - `ms-dynamics-smb.al`
  - `GitHub.copilot` + `GitHub.copilot-chat`
  - La extensión de **ALDC** estará disponible en Marketplace · **la instalaremos en vivo durante la demo**, no la instales antes
- **Cuenta GitHub Copilot** activa
- **Sandbox de Business Central** (opcional para este bloque)

### Arranque rápido

```bash
# 1. Fork este repo en tu cuenta GitHub
# 2. Clónalo en local
git clone https://github.com/<tu-usuario>/workshop-b02-start.git
cd workshop-b02-start
code .
```

**Importante:** el workspace empieza con `.github/` casi vacío. Es **a propósito**. No añadas nada antes de la demo — parte de la demostración es ver `.github/` poblarse en vivo cuando el ponente ejecute `AL Collection: Install Toolkit to Workspace`.

### Durante la demo

Acompaña al ponente en tu máquina:

#### Paso 1 · abrir el contrato

Abre `.github/copilot-instructions.md` y léelo. Son ~80 líneas. Son **las reglas que skill-diagnostics va a auditar**. Si cambias una, la skill se adapta.

#### Paso 2 · abrir la skill

Abre `.github/skills/skill-diagnostics/SKILL.md`. Mira:

- **Frontmatter YAML** con `name` y `description` — por donde Copilot la encuentra
- **Sección `## Purpose`**
- **Sección `## Rule catalogue`** — la tabla con las ~20 reglas
- **Sección `## Output format`** — forma exacta del reporte
- **Sección `## Constraints`** — las reglas que la skill nunca rompe

#### Paso 3 · introducir un defecto intencionado

Para que la demo de `skill-diagnostics` tenga algo que reportar, introduce un defecto en `app/src/HelloWorld.PageExt.al` — por ejemplo, borra el `trigger OnOpenPage()` y comenta cualquier otra cosa que rompa una regla.

O mejor aún: deja que Copilot genere una tabla **sin aplicar el contrato** (con un prompt vago del estilo "create a support tier table") y usa ese output defectuoso como objeto de auditoría.

#### Paso 4 · lanzar la skill

```
Load skill-diagnostics and scan the workspace. Follow the output format strictly.
```

Observa el reporte. Recorre los findings uno a uno con el ponente. Ve cómo cada hallazgo cita:
- La regla (`C3`, `Q1`, etc.)
- El fichero y la línea
- Qué apartado de `copilot-instructions.md` respalda la regla

Esto es **Skills Evidencing** operando.

### Paso 5 · instalar ALDC en vivo

Cuando el ponente lo indique, abre Marketplace y busca **AL Development Collection**. Instala la extensión, ejecuta `AL Collection: Install Toolkit to Workspace`, y refresca el explorador. Verás `.github/` poblarse con:

- `agents/` · 4 agentes (al-architect, al-conductor, al-developer, al-presales)
- `prompts/` · prompts reutilizables
- `skills/` · 15 skills (tu `skill-diagnostics` se queda **intacta** — ALDC añade, no sobrescribe)
- `workflows/` · 10 workflows

## Ejercicios opcionales · crea tu propia skill

### Ejercicio 1 · skill de bitácora

Como te comentó el ponente, instala un **skill creator** (o hazlo a mano con la estructura canónica que ves en `skill-diagnostics`) y crea una skill pequeña: por ejemplo, una que escriba entradas a un fichero `BITACORA.md` cada vez que cierras una funcionalidad.

```
/create-skill

Quiero una skill que registre cada milestone de desarrollo en un fichero
BITACORA.md del repositorio, con fecha, feature, decisiones tomadas y
pruebas ejecutadas. La idea es que el historial del proyecto quede
trazado sin depender del commit history.
```

Copilot generará la estructura `SKILL.md` correcta. Revísala, ajústala, y pruébala.

### Ejercicio 2 · personalizar las reglas de `skill-diagnostics`

Abre el `SKILL.md` y:

1. Añade una **regla nueva** (por ejemplo: `Q9 · Every Report object has a Usage Category declared`)
2. Añade el respaldo correspondiente en `copilot-instructions.md`
3. Relanza la skill y verifica que la nueva regla aparece en el catálogo

Si la añades a la skill **sin añadirla al contrato**, la skill debería rechazarla (o mover a "Suggested contract additions" en el reporte). Eso es parte del diseño — **never invent rules**.

### Ejercicio 3 · mirar la spec oficial

Abre https://agentskills.io/specification y compara con tu `SKILL.md`. ¿Qué campos del frontmatter no estamos usando? ¿`allowed-tools`? ¿`compatibility`? Mira si alguno te resultaría útil para tu caso de uso.

## Relación con el workshop completo

- **Bloque 01** · Template Copilot básico → [workshop-b01-start](../workshop-b01-start) *(otro repo)*
- **Bloque 02** · *este template*
- **Bloque 03** · Template con ALDC ya instalado + contexto Barista Incidents → [workshop-b03-start](../workshop-b03-start) *(otro repo)*
- **Bloque 04** · Guía online del caso práctico → [bloque 04 del sitio](https://javiarmesto.github.io/workshop-v-valley-aldc-2026-04/bloques/04-caso-practico/)

## Créditos y recursos

- **[Agent Skills specification](https://agentskills.io/specification)** · spec open de las skills
- **[VS Code · Agent Skills docs](https://code.visualstudio.com/docs/copilot/customization/agent-skills)** · cómo funciona la auto-carga en Copilot Chat
- **[ALDC repo](https://github.com/javiarmesto/ALDC-AL-Development-Collection)** · proyecto técnico del que habla el workshop
- **[AL-Go PTE template](https://github.com/microsoft/AL-Go-PTE)** · base de este starter

## Licencia

- **Contenido** (contrato, SKILL.md, texto) · [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/)
- **Código AL** (sample) · [MIT](https://opensource.org/licenses/MIT)

---

<div align="center">
<sub>Workshop ALDC · V-Valley 2026 · Javier Armesto</sub>
</div>

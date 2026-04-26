<div align="center">

# Workshop ALDC · V-Valley 2026
### Template del Bloque 03 · Coding Agents · architect → spec → conductor

[![Workshop](https://img.shields.io/badge/workshop-V--Valley%202026-818CF8?style=flat-square)](https://javiarmesto.github.io/workshop-v-valley-aldc-2026-04/)
[![Bloque 03](https://img.shields.io/badge/bloque-03%20·%20Coding%20Agents-E879A8?style=flat-square)](https://javiarmesto.github.io/workshop-v-valley-aldc-2026-04/bloques/03-coding-agents/)
[![ALDC Core v1.1](https://img.shields.io/badge/ALDC-Core%20v1.1-38BDF8?style=flat-square)](https://github.com/javiarmesto/ALDC-AL-Development-Collection)

**[📖 Material del bloque](https://javiarmesto.github.io/workshop-v-valley-aldc-2026-04/bloques/03-coding-agents/)** · **[🌐 Workshop completo](https://javiarmesto.github.io/workshop-v-valley-aldc-2026-04/)**

</div>

---

## Qué es esto

Template de partida para el **Bloque 03 del Workshop ALDC V-Valley 2026**.

En este bloque vas a usar los **agentes de ALDC** (al-architect y el workflow al-spec.create) sobre un **caso real de negocio** — gestión de incidencias para una cadena de cafeterías. El objetivo **no es producir código AL todavía** — eso viene en el Bloque 04. Aquí te paras en dos artefactos:

1. **`architecture.md`** · generado por `al-architect`
2. **`spec.md`** · generado por el workflow `al-spec.create`

Y usas el camino `MEDIUM-HIGH complexity` con HITL entre cada fase.

## Estructura

```
workshop-b03-start/
├── app/
│   ├── app.json
│   └── src/
│       └── HelloWorld.PageExt.al             ← sample · compila OK desde el inicio
├── docs/
│   ├── caso-barista-incidents.md             ← 👈 el correo de la clienta · tu input
│   └── INSTALACION-ALDC.md                   ← cómo dejar ALDC listo en tu workspace
├── .github/
│   └── copilot-instructions.md               ← contrato del proyecto
│       (ALDC añade agents/, workflows/, etc. cuando lo instalas)
├── .AL-Go/
├── .vscode/
├── .gitignore
└── README.md                                 ← este fichero
```

## El input del bloque · `docs/caso-barista-incidents.md`

Ábrelo y léelo. **Es lo más importante**.

Es un correo interno — el tipo de material con el que en un proyecto real empezarías a pensar la arquitectura. Tiene detalles, tiene ambigüedades, tiene cosas que el architect va a tener que decidir:

- Qué tablas y con qué relaciones
- Cómo estructurar la severidad (enum vs tabla)
- Cómo modelar la asignación automática (matriz? reglas?)
- Qué eventos publicar
- Qué APIs exponer (REST v2.0 con bound actions)
- Cómo particionar permisos

**Nota:** al final del fichero hay una sección "Notas para el equipo técnico" que apunta candidatos a ADR. Son pistas para ayudarte a guiar al architect, no la solución.

## Cómo usarlo durante el Bloque 03

### Paso 0 · preparar entorno

Sigue [`docs/INSTALACION-ALDC.md`](./docs/INSTALACION-ALDC.md) para dejar ALDC
instalado en tu workspace. Tarda 2 minutos.

```bash
# Fork este repo en tu cuenta GitHub, después:
git clone https://github.com/<tu-usuario>/workshop-b03-start.git
cd workshop-b03-start
code .

# Instala ALDC: Ctrl+Shift+X → buscar "AL Development Collection"
# Luego: Ctrl+Shift+P → "AL Collection: Install Toolkit to Workspace"
# Recarga ventana: F1 → "Developer: Reload Window"
```

### Paso 1 · invocar al-architect

Abre Copilot Chat y pega:

```
Load al-architect.

Context:
Read the business context in docs/caso-barista-incidents.md.
This is a Business Central extension for a coffee shop chain managing
operational incidents. Follow .github/copilot-instructions.md for
naming, ID range, and pattern constraints.

Task: Produce barista-incidents.architecture.md at MEDIUM-HIGH complexity.
Include:
- Skills applied (at the top)
- ADRs (numbered, with alternatives considered and decision rationale)
- Data model (tables, relationships, cardinalities)
- APIs exposed (v2.0, bound actions where applicable, queries)
- Events published (integration events for state transitions)
- Permissions strategy (Basic and Full sets)

Do NOT write AL code. Architecture only.
```

**Qué esperar en el output**:

- Primera línea del fichero: `> **Skills applied**: skill-api, skill-events, skill-pages, skill-permissions` (o conjunto similar)
- 4-6 ADRs numeradas con alternativas consideradas
- Diagrama o lista de entidades del modelo de datos
- APIs con sus bound actions
- Eventos publicados para las transiciones de estado
- Dos permission sets propuestos

### Paso 2 · revisar la arquitectura (HITL gate)

**No saltes este paso.** El punto de ALDC es que un humano firme entre fases.

Abre el `architecture.md` generado y hazte tres preguntas:

1. **¿Las ADRs reflejan la realidad del caso?** · el correo de Marta dice que la asignación tiene que ser "configurable sin tocar código" · si la ADR propone un `enum` fijo para asignación, empújalo a replantear.

2. **¿El modelo de datos cubre lo pedido?** · el informe semanal necesita agregar por tipo, por tienda, por máquina · ¿hay campos suficientes?

3. **¿Faltan eventos?** · el correo menciona que "severidad alta dispara push al técnico" · ¿hay un integration event para eso?

Si algo no te cuadra, pide refinamiento:

```
The ADR about severity modeling chose enum. The email explicitly says
severity thresholds should be configurable. Please reconsider — table or
enum + override table would be alternatives worth evaluating.
```

### Paso 3 · invocar el workflow al-spec.create

Una vez aprobada la arquitectura:

```
@workspace use al-spec.create

Source: barista-incidents.architecture.md
Output: barista-incidents.spec.md
```

El workflow te hará preguntas para expandir la arquitectura a spec ejecutable. **Responde**. No lo ejecutes "a ver qué pasa" · el workflow es dialógico por diseño.

**Qué esperar en el output**:

- Lista concreta de objetos con ID tentativo asignado dentro del rango 50100-50199
- Campos de cada tabla con tipo y constraints
- Dependencias entre objetos (orden de creación)
- Casos de prueba esperados (happy path + edge cases)
- Plan de fases para el conductor · cuántas fases, qué hace cada una

### Paso 4 · parar aquí

**No invoques al-conductor en este bloque.** Ejecutar el pipeline completo desde la spec es el ejercicio del Bloque 04.

Guárdate los dos artefactos (`architecture.md` y `spec.md`) en `docs/` para el Bloque 04, o en otro lugar que encuentres fácil.

## Ejercicios opcionales · para quien vaya por delante

### Ejercicio 1 · comparar dos `architecture.md`

Lanza `al-architect` **dos veces** con el mismo input, en chats separados. Compara:

- ¿Escoge las mismas Skills?
- ¿Propone las mismas tablas?
- ¿Las ADRs coinciden?

Es una forma de calibrar cuánta variabilidad introduce el modelo. Spoiler: la estructura es estable, los detalles varían.

### Ejercicio 2 · forzar complejidad LOW

En un chat nuevo:

```
Load al-architect.

Context: read docs/caso-barista-incidents.md. Take the SIMPLEST POSSIBLE
interpretation — assume only 1 incident type ("machine breakdown"), no
severity levels, no external integration, no role center tiles. Just CRUD.

Task: Produce the MINIMUM architecture at LOW complexity. Single table,
basic page, basic permission set.
```

Compara con el output MEDIUM-HIGH del ejercicio principal. Este es un buen ejemplo de cómo el mismo input produce soluciones muy distintas según qué complejidad declaras.

### Ejercicio 3 · pedir trade-offs explícitos

Vuelve al `architecture.md` principal y pídele:

```
For the 3 most critical ADRs, explain the trade-offs we accept by taking
the decided path. What would break if we later had to reverse each decision?
```

Es buena práctica · te deja un mapa de dolor para el futuro.

## Cuando llegue el Bloque 04

Te llevarás:

- Tu `architecture.md` (aprobado por ti mismo en el Paso 2)
- Tu `spec.md` (dialógicamente construido en el Paso 3)

Y usarás `al-conductor` + sus 3 subagentes (al-planning, al-implement, al-review) para **implementar** las primeras fases de la spec. El Bloque 04 es green-field + brown-field · dos enfoques del mismo caso.

## Relación con el workshop completo

- **Bloque 01** · Template Copilot básico → [workshop-b01-start](../workshop-b01-start) *(otro repo)*
- **Bloque 02** · Template con `skill-diagnostics` → [workshop-b02-start](../workshop-b02-start) *(otro repo)*
- **Bloque 03** · *este template*
- **Bloque 04** · Caso práctico completo (online) → [bloque 04 del sitio](https://javiarmesto.github.io/workshop-v-valley-aldc-2026-04/bloques/04-caso-practico/)

## Créditos y recursos

- **[Repo ALDC](https://github.com/javiarmesto/ALDC-AL-Development-Collection)** · el proyecto técnico del que habla el workshop
- **[Extensión ALDC · Marketplace](https://marketplace.visualstudio.com/items?itemName=JavierArmestoGonzalez.al-development-collection)** · instalación rápida
- **[AL-Go PTE template](https://github.com/microsoft/AL-Go-PTE)** · base de este starter

## Licencia

- **Contenido** · [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/)
- **Código AL** · [MIT](https://opensource.org/licenses/MIT)

---

<div align="center">
<sub>Workshop ALDC · V-Valley 2026 · Javier Armesto</sub>
</div>

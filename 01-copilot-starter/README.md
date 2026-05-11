> 🇪🇸 Español | [🇬🇧 English](../i18n/en/01-copilot-starter/README.md)

<div align="center">

# Workshop ALDC · V-Valley 2026
### Template del Bloque 01 · GitHub Copilot para Business Central

[![Workshop](https://img.shields.io/badge/workshop-V--Valley%202026-232529?style=flat-square)](https://javiarmesto.github.io/workshop-v-valley-aldc-2026-04/)
[![Bloque 01](https://img.shields.io/badge/bloque-01%20·%20Copilot-7a9e00?style=flat-square)](https://javiarmesto.github.io/workshop-v-valley-aldc-2026-04/bloques/01-copilot/)
[![AL-Go PTE](https://img.shields.io/badge/AL--Go-PTE-d8723c?style=flat-square)](https://github.com/microsoft/AL-Go-PTE)

**[📖 Material del bloque](https://javiarmesto.github.io/workshop-v-valley-aldc-2026-04/bloques/01-copilot/)** · **[🌐 Workshop completo](https://javiarmesto.github.io/workshop-v-valley-aldc-2026-04/)**

</div>

---

## Qué es esto

Template de partida para el **Bloque 01 del Workshop ALDC V-Valley 2026**. Contiene lo mínimo para tener un proyecto AL funcional con el contrato y el prompt file que usaremos en la demo.

Si has llegado aquí durante el workshop, **fork este repo** en tu cuenta y clónalo en local. Te llevará 30 segundos y puedes seguir la demo en paralelo.

## Estructura

```
workshop-b01-start/
├── app/
│   ├── app.json                         ← PTE · prefijo CEB · ID range 50100-50149
│   └── src/
│       └── HelloWorld.PageExt.al        ← ejemplo inicial · confirma que compila
├── .github/
│   ├── copilot-instructions.md          ← 👈 el contrato del proyecto
│   └── prompts/
│       └── extend-table.prompt.md       ← 👈 el prompt reutilizable /extend-table
├── .AL-Go/
│   └── settings.json                    ← config mínima AL-Go
├── .vscode/
│   └── launch.json                      ← publicar a BC Sandbox Cloud
├── .gitignore
└── README.md                            ← este fichero
```

## Los dos ficheros que importan

### 1. `.github/copilot-instructions.md` · el contrato

Define qué aplica **automáticamente** a todo prompt que lances en este workspace:

- Prefijo `CEB` en todos los objetos nuevos
- ID range `50100 – 50149`
- `DataClassification`, `Caption` y `ToolTip` obligatorios en tablas
- Estructura de carpetas (`Tables/`, `Pages/`, etc.)
- Estilo de código (4 espacios, orden de secciones, etc.)

> **Personalízalo.** Este contrato es un punto de partida pensado para la demo. En tu empresa probablemente tengas otro prefijo, otro rango, otras convenciones. **Ábrelo, léelo, y cámbialo para reflejar cómo trabajáis.** El contrato bueno es el que refleja tu realidad.

### 2. `.github/prompts/extend-table.prompt.md` · el prompt reutilizable

Se invoca con `/extend-table` desde Copilot Chat. Cuando lo lances, Copilot:

1. Te preguntará tabla fuente, campos nuevos, y razón de negocio
2. Aplicará el contrato de arriba automáticamente (prefijo, rango, DataClassification, Caption/ToolTip)
3. Generará un `.al` listo para compilar

> **También es personalizable.** Mira el fichero · son 60 líneas de markdown. Si en tu empresa los table extensions siempre llevan un `trigger OnValidate` sobre ciertos campos, o un XML doc específico, **añádelo a las reglas del prompt**.

## Cómo usarlo durante el Bloque 01

### Pre-requisitos

- **VS Code** con las extensiones:
  - `ms-dynamics-smb.al` (AL Language)
  - `GitHub.copilot` + `GitHub.copilot-chat`
- **Cuenta GitHub Copilot** activa (trial gratuito vale)
- **Sandbox de Business Central** (cualquier BC SaaS sandbox sirve — no lo publicaremos realmente, solo por si hay tiempo de probar)

### Arranque rápido (30 segundos)

```bash
# 1. Clona el repo de ejercicios
git clone https://github.com/javiarmesto/workshop-v-valley-aldc-2026-04-EJERCICIOS.git
# 2. Abre SOLO la carpeta del bloque (importante: no abras la raíz del repo)
code workshop-v-valley-aldc-2026-04-EJERCICIOS/01-copilot-starter
```

**⚙️ Configura antes de compilar** (2 minutos):

1. Abre `.vscode/launch.json` → cambia `"environmentName"` al nombre de tu sandbox real
2. Abre `app.json` → ajusta `idRanges`, `publisher` y `name` a los de tu empresa si quieres
3. Descarga símbolos: `Ctrl+Shift+P` → `AL: Download Symbols`

Sin los pasos anteriores AL Language no compilará — el sandbox es la referencia de tipos.

> VS Code puede tardar ~30s en la primera carga de extensiones AL.

### Durante la demo

> ⚠️ **Primer ejercicio — desactiva el contrato temporalmente**  
> El Prompt 1 está diseñado para mostrar qué genera Copilot **sin** ningún contrato activo. Para que el contraste sea real, **mueve o elimina** `.github/copilot-instructions.md` antes de lanzarlo. Recupéralo después con `git checkout .github/copilot-instructions.md` antes de los prompts 2 y 3.

El ponente irá ejecutando 3 prompts en Copilot Chat. Replica en tu máquina:

**Prompt 1 · vago** *(sin contrato activo)*
```
Create a table for customer support tiers
```
Observa lo que genera. Es lo que pasa sin contrato.

**Prompt 2 · estructurado con patrón Context/Task/Constraints/Output**
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
Observa cómo el contrato (`copilot-instructions.md`) se aplica automáticamente.

**Prompt 3 · invocación del prompt reutilizable**
```
/extend-table
```
Responde las preguntas que te haga · por ejemplo:
- Source table: `Customer`
- Fields: `Support Tier Code` (Code[20], link to CEB Support Tier), `Support Active` (Boolean), `Support Start Date` (Date)
- Business reason: `Enable tier-based customer support workflows`

Observa cómo reutiliza el contrato sin necesidad de repetirlo.

## Ejercicios opcionales · si vas por delante o quieres practicar después

### Ejercicio 1 · crear tu primer prompt file

Después del Bloque 01, en el chat de Copilot escribe:

```
/create-prompt
```

Cuando te pregunte qué prompt quieres crear, responde algo como:

> *Un prompt que genere codeunits de integración para exponer APIs v2.0 siguiendo nuestras convenciones, con bound actions para operaciones stateful y error handling con ErrorInfo.*

Copilot te hará preguntas aclaratorias y generará el prompt file en `.github/prompts/`. **Revísalo y ajústalo.**

### Ejercicio 2 · personalizar las instrucciones

Si tienes un rango de IDs real de tu empresa, o un prefijo distinto, abre `.github/copilot-instructions.md` y cámbialo. Cambia también `app.json` para que el `idRanges` y el `publisher` coincidan.

Después, relanza el **Prompt 2** y verás que Copilot aplica tus nuevos valores sin que tengas que repetirlos.

### Ejercicio 3 · ampliar el contrato

Añade al `copilot-instructions.md` alguna regla propia que te haya fastidiado en otro proyecto. Ejemplos:

- *"All text fields in master data tables must be non-blank: add `trigger OnValidate()` enforcing `TestField()`."*
- *"Integer fields representing money must use `Decimal` with `AutoFormatType = 1;` and `AutoFormatExpression = '<Precision,2:>';`."*
- *"Codeunits exposing procedures to other extensions must declare `Access = Public;` explicitly."*

Y relanza el `/extend-table` para ver cómo Copilot empieza a seguirlas.

## Relación con el workshop completo

Este es el template de **un solo bloque**. Para el resto:

- **Bloque 02** · Template con `.github/` limpio + skill `skill-diagnostics` pre-creada → [workshop-b02-start](../workshop-b02-start) *(otro repo)*
- **Bloque 03** · Template con ALDC ya instalado + contexto Barista Incidents → [workshop-b03-start](../workshop-b03-start) *(otro repo)*
- **Bloque 04** · Solo guía de laboratorio online → [bloque 04 del sitio](https://javiarmesto.github.io/workshop-v-valley-aldc-2026-04/bloques/04-caso-practico/)

## Créditos

Basado en **[AL-Go for GitHub · PTE template](https://github.com/microsoft/AL-Go-PTE)** de Microsoft. El template oficial incluye CI/CD completo; aquí solo mantengo los ficheros mínimos para el workshop. Si vas a montar un proyecto real, **forkea el template oficial** y copia desde aquí solo los ficheros de `.github/` que quieras reutilizar.

## Licencia

- **Contenido** (texto, instrucciones, prompt files) · [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/)
- **Código AL** (sample) · [MIT](https://opensource.org/licenses/MIT)

Puedes usar este template en tu empresa, para formación interna, o para presentaciones propias · cita la fuente.

---

<div align="center">
<sub>Workshop ALDC · V-Valley 2026 · Javier Armesto</sub>
</div>

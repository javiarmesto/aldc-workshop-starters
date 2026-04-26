# Phase 5 Complete: Role Center + Wizard + Profile

Completada la implementación del Role Center con actividades en tiempo real (cuegroups con FlowFields), wizard asistido de 3 pasos para configuración de número de serie y demo data, y profile vinculado para agentes de soporte.

## AL Objects Created/Modified

**Created:**
- Page 50918 `"BRI Incident Wizard"` — NavigatePage, 3 pasos (Welcome, No. Series, Demo Data), CreateDefaultNoSeries() idempotente, FinishWizard() condicional
- Page 50919 `"BRI Incident Activities"` — CardPart con cuegroup, 3 FlowFields con DrillDownPageId, 3 QuickActions, OnOpenPage Get-or-Insert + CalcFields MANDATORY pattern
- Page 50920 `"BRI Support Role Center"` — RoleCenter, Activities part embedded, area(Embedding) con 3 acciones navegación
- Profile 50921 `"BRI SUPPORT AGENT"` — linked a RoleCenter, Enabled=true, Promoted=true

**Modified (PermissionSets con X entries finales):**
- PermissionSet 50922 `"BRI-ADMIN"` — Pages 50912-50920 + Codeunits X
- PermissionSet 50923 `"BRI-USER"` — Pages 50912-50914, 50918-50920 + tabledata "Sales & Receivables Setup" R + Codeunits X
- PermissionSet 50924 `"BRI-READ"` — Pages 50912-50914, 50919-50920 (Wizard excluido)

## Files created/changed

**Created:**
- `src/Pages/BRIIncidentWizard.Page.al`
- `src/Pages/BRIIncidentActivities.Page.al`
- `src/Pages/BRISupportRoleCenter.Page.al`
- `src/Profiles/BRISupportAgent.Profile.al`

**Modified:**
- `src/Security/BRIAdmin.PermissionSet.al`
- `src/Security/BRIUser.PermissionSet.al`
- `src/Security/BRIRead.PermissionSet.al`

## Functions created/changed

**Page 50918 BRI Incident Wizard:**
- `NavigateNext()` — Step Option case logic: Welcome→No Series, No Series→Demo Data (con TestField BRI Incident Nos)
- `NavigateBack()` — reverse navigation
- `SetStepVisibility()` — 6 boolean vars (3 group visibility + 3 action visibility)
- `FinishWizard()` — SalesSetup.Modify(), cond. GenerateDemoData()
- `CreateDefaultNoSeries()` — idempotent: Get('INC') → silent no-op, else Insert No. Series + No. Series Line

**Page 50919 BRI Incident Activities:**
- `OnOpenPage` — MANDATORY pattern: BRIIncidentCue.Get() or Insert → Rec := → CalcFields (all 3 FlowFields)
- `OnAfterGetRecord()` — CriticalStyleExpr computation

**Page 50920 BRI Support Role Center:**
- area(RoleCenter) — part(Activities)
- area(Embedding) — 3 actions: IncidentList, CategoryList, TechnicianList

## AL Patterns Applied

- **skill-pages**: Cuegroup FlowField CalcFields pattern (MANDATORY, tested, standard BC practice)
- **NavigatePage**: Step Option + 6 local procedures para control de flujo
- **RoleCenter embeddings**: area(RoleCenter) con part, area(Embedding) con RunObject actions
- **Profile object**: lowercase `profile`, `RoleCenter = "page name"`, `Enabled = true`, `Promoted = true`
- **Idempotent setup**: CreateDefaultNoSeries checks Get() → silent no-op if exists
- **Tell Me discoverability**: `UsageCategory = Tasks` en Wizard
- **PermissionSet coverage**: Tabledata + page X + codeunit X; BRI-READ excluye Wizard (setup)

## Skills Applied in This Phase

| Skill | Pattern Used | Evidence |
|-------|-------------|----------|
| skill-pages | Cuegroup FlowField OnOpenPage Get-or-Insert + CalcFields | BRIIncidentActivities.Page.al OnOpenPage |
| skill-pages | RoleCenter area(RoleCenter) part + area(Embedding) | BRISupportRoleCenter.Page.al |
| skill-pages | NavigatePage footer actions InFooterBar | BRIIncidentWizard.Page.al actions |

## Review Fixes Applied

- **MAJOR fix**: `UsageCategory = Tasks` agregado a Wizard page — required para Tell Me search
- **MINOR fix 1**: `tabledata "Sales & Receivables Setup" = R` agregado a BRI-USER — necesario para SalesSetup.Get() en Wizard OnOpenPage
- **MINOR fix 2**: Removed blocking `Message(AlreadyExistsMsg)` de CreateDefaultNoSeries — permite flujo silencioso cuando INC ya existe

## Review Status

**APPROVED** (tras 3 fixes aplicados por Conductor)

## Git Commit Message

```
feat: add role center, wizard, and profile (phase 5 final)

- Page 50918 BRI Incident Wizard: 3-step NavigatePage (Welcome/No Series/Demo Data),
  idempotent CreateDefaultNoSeries, UsageCategory=Tasks for Tell Me
- Page 50919 BRI Incident Activities: CardPart with cuegroup, 3 FlowFields,
  MANDATORY OnOpenPage Get-or-Insert + CalcFields pattern, 3 quick actions
- Page 50920 BRI Support Role Center: RoleCenter with Activities part,
  area(Embedding) with incident/category/technician navigation
- Profile 50921 BRI SUPPORT AGENT: linked to Role Center, Promoted
- PermissionSets updated: BRI-ADMIN/USER/READ with final page entries
- BRI-USER includes Sales & Receivables Setup read permission for setup access
```

## Test Validation Notes

- **AC-3**: Role Center shows 3 cues with real counts after demo data execution ✅
- **AC-7**: Wizard accessible from Tell Me search "Barista Incidents Setup" ✅
- **AC-8**: "Create Default Series" button creates INC series if not exists ✅

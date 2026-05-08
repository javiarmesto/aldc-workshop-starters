> 🇪🇸 Español | [🇬🇧 English](../../i18n/en/04-brownfield-starter/Requerimientos/TICKET-CRONUS-2026-042.md)

# 🎫 Ticket de soporte CRONUS-2026-042

**De**: soporte@cronus-usa.com
**Para**: partner-implantacion@example.com
**Fecha**: lunes 27 de abril de 2026, 09:15 AM
**Asunto**: Incidencias detectadas en smoke test funcional de Barista Incidents v1.0
**Prioridad**: Alta
**Estado**: Abierto

---

## Contexto

Buenos días equipo,

Os escribo con dos incidencias detectadas durante el smoke test funcional que hemos realizado este fin de semana sobre la extensión Barista Incidents v1.0 que nos entregasteis el viernes.

El equipo de soporte al completo (6 personas) ha estado trabajando con la aplicación durante el sábado y domingo haciendo pruebas con datos reales. Hemos encontrado **dos problemas** que necesitan resolución antes de dar luz verde al despliegue en producción. El resto de funcionalidades se comportan correctamente y el equipo está contento con el Role Center y el flujo general.

Os adjunto el repositorio actualizado del proyecto en el estado en que lo hemos recibido. Os agradeceríamos una resolución esta misma semana si es posible, ya que teníamos previsto arrancar producción el viernes 1 de mayo.

Saludos cordiales,

**JP** — Jefe de Proyecto · CRONUS USA, Inc.

---

## Issue #1 — Role Center · cue "My Open Incidents" muestra contador incorrecto

**Severidad**: Media
**Reportado por**: Alice Martinez (agente de soporte)

### Descripción del problema

Alice nos ha reportado que al iniciar sesión en Business Central con su perfil "Barista Support Agent", el cue "My Open Incidents" del Role Center le muestra **8 incidencias**, pero cuando hace clic sobre el cue y se abre la lista filtrada, solo ve **5 incidencias realmente abiertas**.

Alice ha investigado un poco y ha identificado que entre las 8 que cuenta el cue están **3 incidencias que ella resolvió la semana pasada** y que ya están en estado "Resolved". No deberían contar para este cue.

### Comportamiento esperado

El cue "My Open Incidents" debería contar únicamente las incidencias asignadas al usuario actual que **NO estén en estado Resolved ni Closed ni Cancelled**. Es decir, solo las que aún requieren trabajo activo del agente.

### Comportamiento observado

El cue está contando **todas las incidencias asignadas al usuario actual**, sin filtrar por estado. Incluye las Resolved que ya están cerradas desde el punto de vista operativo.

### Impacto

Los agentes sienten que tienen más trabajo pendiente del que realmente tienen. Afecta la percepción de carga y la priorización visual del Role Center. Es el "primer número" que ven al entrar al sistema cada mañana.

### Información técnica adicional

El cue vive en la tabla `BRI Incident Cue` como FlowField `My Open Incidents`. Adjunto reproducción en sandbox disponible si la necesitáis.

---

## Issue #2 — Card Incident · acción "Add Comment" no añade comentarios

**Severidad**: Alta
**Reportado por**: Bob Chen (agente de soporte) y David Patel (agente de soporte)

### Descripción del problema

Bob y David han intentado añadir comentarios manuales a varias incidencias durante el sábado. Ambos reportan el mismo problema: al pulsar la acción **"Add Comment"** en la ficha de una incidencia, **no se añade ningún comentario**. El sistema muestra un mensaje informativo del tipo "Add Comment feature will be available soon" o similar, pero al cerrar ese mensaje y revisar el FactBox de comentarios, no aparece nada nuevo.

Bob ha verificado que los **comentarios automáticos sí funcionan**: cuando cambia el estado de una incidencia, aparece automáticamente un comentario de tipo "Status Change". Cuando asigna una incidencia a otro técnico, aparece un comentario "Assignment". **Lo que no funciona es añadir un comentario libre**, que es lo que el agente quiere hacer para dejar notas del tipo *"llamado al cliente, confirma el lote es 2025-B-142"* o *"pendiente de que finanzas apruebe el abono"*.

Esto bloquea completamente el caso de uso principal del agente: registrar el progreso de la resolución en sus propias palabras.

### Comportamiento esperado

Al pulsar "Add Comment" desde la ficha de una incidencia, debería aparecer un diálogo que permita al agente escribir texto libre. Al confirmar, el sistema debería guardar ese comentario en la tabla `BRI Incident Comment` con:
- `Comment Type = User`
- `Created By = UserId del agente que lo añadió`
- `Created At = fecha/hora actual`
- `Incident No. = número de la incidencia actual`

Tras guardar, el comentario debería aparecer inmediatamente en el FactBox de comentarios sin necesidad de refrescar la página.

### Comportamiento observado

La acción está presente y clicable en la Card. Al pulsarla, se muestra un Message informativo pero **no se llama al procedure de añadir comentario**. El comentario no se guarda. El FactBox no se actualiza. El agente no puede dejar notas libres.

### Información técnica adicional

El codeunit `BRI Incident Management` tiene un procedure público `AddComment(var Incident: Record Incident; CommentText: Text[2048])` que está implementado correctamente — si se llama directamente desde AL, inserta el comentario sin problema. **El problema está en la UI**: la acción de la Card no está cableada a ese procedure.

### Impacto

Bloqueante para el despliegue. Los agentes no pueden hacer su trabajo sin esta funcionalidad. Es la causa más probable de que pospongamos el go-live del viernes si no se resuelve.

---

## Qué os pedimos

1. Analizar el repositorio adjunto con la **metodología ALDC** (la misma que usasteis para construir) + el **auditor de pipeline** que nos mencionasteis en la reunión de kick-off.
2. Resolver los dos issues aplicando las correcciones necesarias.
3. Devolvernos el repositorio corregido con:
   - Documentación de las correcciones aplicadas
   - Test manual de verificación (pasos que seguimos para confirmar que cada issue está resuelto)
   - Changelog describiendo qué cambió
4. Tiempo objetivo: esta semana, idealmente antes del jueves para tener margen de smoke test antes del go-live del viernes.

Quedamos a vuestra disposición para cualquier pregunta.

Un saludo,

**JP** — Jefe de Proyecto
**CRONUS USA, Inc.**

---

*Este ticket simula la situación real de brown field: un proyecto ya construido que llega con defectos reportados desde producción. El objetivo del ejercicio es aplicar ALDC + auditoría para detectar, diagnosticar y corregir los dos issues.*

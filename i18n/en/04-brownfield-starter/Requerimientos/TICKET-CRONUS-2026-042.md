> 🇪🇸 [Versión en español](../../../04-brownfield-starter/Requerimientos/TICKET-CRONUS-2026-042.md) · 🇬🇧 English

---

**From:** soporte@cronus-usa.com  
**Date:** Monday 27 April 2026  
**Subject:** Issues detected in functional smoke test — Barista Incidents v1.0  
**Priority:** High  
**Status:** Open  

---

# Support ticket CRONUS-2026-042

Dear partner team,

Last weekend (Saturday and Sunday) we ran a functional smoke test of the Barista Incidents extension with 6 members of the support team on real data in our CRONUS USA Inc. sandbox. We found **2 issues blocking the go-live** planned for Friday 1 May. The rest of the functionality — Role Center, lifecycle, categories, technicians, wizard — works correctly and the team is satisfied.

We are reporting these issues now so you can resolve them before the end of this week.

---

## Issue #1 — Role Center · "My Open Incidents" cue shows wrong counter

**Severity:** Medium  
**Reported by:** Alice Martinez (Support Agent)

### Observed behaviour

The "My Open Incidents" cue on the Role Center shows a count of **8** incidents. However, when Alice clicks the cue to see the filtered list, only **5 incidents** appear. The 3 extra incidents that the cue is counting are incidents already in **Resolved** status — they do not require any active work.

### Expected behaviour

The cue should count **only incidents assigned to the current user that are in active statuses** — that is, statuses that still require work from the agent. Resolved, Closed, and Cancelled incidents should not be included in this count.

Specifically: **New**, **In Progress**, **Pending Client**, and **Pending Internal** statuses should be counted. **Resolved**, **Closed**, and **Cancelled** must be excluded.

### Impact

Agents see more open work than they actually have. This affects work-load perception and visual prioritisation on the Role Center. It is the first number agents see each morning. If the count is wrong, confidence in the tool erodes quickly.

**Technical information**: the cue is a FlowField on the `BRI Incident Cue` table. The filter on the FlowField definition does not correctly exclude Resolved, Closed, and Cancelled statuses.

---

## Issue #2 — Incident Card · "Add Comment" action adds no comments

**Severity:** High  
**Reported by:** Bob Chen and David Patel (Support Agents)

### Expected behaviour

When an agent clicks "Add Comment" on the Incident Card, a dialog should appear asking for the comment text. After confirming, a new comment of type `User` should be saved in the `BRI Incident Comment` table with:

- `Comment Type` = User
- `Created By` = current user (`UserId()`)
- `Created At` = current date and time
- `Incident No.` = current incident number

The comment should appear **immediately** in the FactBox comment history without requiring a page refresh.

### Observed behaviour

The action is present and clickable on the Card. Clicking it shows an **informational message** (something like "Add Comment feature will be available soon") **but does not call the procedure to add the comment**. The comment is not saved. The FactBox does not update. The agent cannot leave free-text notes.

Auto-generated comments (Status Change and Assignment) work correctly. **Only manual free-text comments do not work.**

### Impact

**Blocker for deployment.** Agents cannot do their job without this functionality. This is the most likely reason we would have to postpone Friday's go-live if not resolved.

### Technical information

The `BRI Incident Management` codeunit has a correctly implemented public procedure `AddComment(var Incident: Record "BRI Incident"; CommentText: Text[2048])` — if called directly from AL it inserts the comment without issue. **The problem is in the UI**: the action on the Card is not wired to that procedure.

---

## What we are asking for

1. Analyse the attached repository with the **ALDC methodology** (the same one used to build it) + the **pipeline auditor** mentioned at the kick-off meeting.
2. Fix both issues with the necessary corrections.
3. Return the corrected repository with:
   - Documentation of the corrections applied
   - Manual verification test steps (steps we follow to confirm each issue is resolved)
   - Changelog describing what changed
4. Target timeline: this week, ideally before Thursday to allow a smoke-test window before Friday's go-live.

We are available for any questions.

Best regards,

**JP** — Project Manager  
**CRONUS USA, Inc.**

---

*This ticket simulates the real brownfield situation: an already-built project arriving with production-reported defects. The exercise objective is to apply ALDC + audit methodology to detect, diagnose, and fix the two issues.*

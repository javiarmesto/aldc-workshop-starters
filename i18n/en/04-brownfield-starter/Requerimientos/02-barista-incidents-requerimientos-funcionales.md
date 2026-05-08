> 🇪🇸 [Versión en español](../../../04-brownfield-starter/Requerimientos/02-barista-incidents-requerimientos-funcionales.md) · 🇬🇧 English

---

# Functional Requirements Document

**Project:** Barista Incidents  
**Client:** CRONUS USA Inc.  
**Version:** 1.0-workshop  
**Related docs:** [01 – Business context](01-contexto-cronus-barista.md) · [03 – Technical PRD ALDC](03-barista-incidents-PRD-ALDC.md)  
**Prepared by:** CRONUS Functional Consultant – Customer Service

---

## Section 1 · Support Agent needs

The support agent is the **primary user** of the system. Everything in v1.0 is designed so that a trained agent can create, update, and close an incident in 3-5 clicks — no more.

### 1.1 Role Center

The first thing the agent sees when opening BC.

**Three cues (KPI tiles)**:

| Cue | Description | Notes |
|-----|-------------|-------|
| My Open Incidents | Count of incidents assigned to me in active statuses | Should **not** count Resolved, Closed, or Cancelled |
| Unassigned | Count of incidents not yet assigned to any technician | High operational priority |
| Critical Open | Count of open incidents with Critical priority | Red emphasis when > 0 |

**Three quick action tiles**:

| Tile | Navigates to |
|------|-------------|
| New Incident | Incident Card in create mode |
| All Incidents | Full Incident List (no predefined filter) |
| Setup Wizard | Incident Management Setup Wizard |

**No additional elements** in v1.0. No Headlines, no Reports section, no wide cues.

---

### 1.2 Log an incident

Required fields (what the agent must fill in every time):

| Field | Type | Notes |
|-------|------|-------|
| Short Description | Text[100] | Mandatory |
| Detailed Description | Text[2048] | Optional but recommended |
| Category | Code lookup | Configurable by manager |
| Priority | Low / Medium / High / Critical | Default from category |
| Client | Customer lookup | Optional — not all incidents come from an identified client |
| Contact Name | Text | Free text |
| Contact Email | Email | Optional |
| Contact Phone | Text | Optional |
| Channel | Call / Email / Chat / Portal / Chatbot | Where did we receive this? |
| External Reference | Text | For tracking in the client's system if applicable |
| Deadline | Date | Optional |

The system **automatically assigns a unique number** in the format `INC-00042` (from a No. Series). The agent never enters this manually.

---

### 1.3 Consult incidents

The Incident List must offer **three predefined filtered views**:

| View | Filter |
|------|--------|
| My Open Incidents | Assigned to me · Status NOT IN (Resolved, Closed, Cancelled) |
| All Open Incidents | Status NOT IN (Closed, Cancelled) |
| Critical | Priority = Critical |

**Visual differentiation**: colour coding by status and priority. At a minimum, Critical open incidents should have distinct red visual weight.

---

### 1.4 Lifecycle

The incident goes through the following statuses:

```
New → In Progress → Pending (Client / Internal) → Resolved → Closed
                                ↑___________________________|
                                           (reopening)
Cancelled (from any non-final status)
```

**Valid transitions**:

| From | Can go to |
|------|-----------|
| New | In Progress, Cancelled |
| In Progress | Pending Client, Pending Internal, Resolved, Cancelled |
| Pending Client | In Progress, Resolved, Cancelled |
| Pending Internal | In Progress, Resolved, Cancelled |
| Resolved | In Progress (reopening), Closed |
| Closed | — (final, no transitions) |
| Cancelled | — (final, no transitions) |

**Critical requirement confirmed by JP**: the system must **prevent invalid transitions**. An agent must not be able to go from New directly to Closed. If they try, they get a clear error message explaining which transitions are valid.

---

### 1.5 Assign to a technician

**Support Technicians are NOT Business Central users**. This is a fundamental constraint.

They have their own master record in the system:

| Field | Notes |
|-------|-------|
| Code | e.g. `TECH001`, `MARIA`, `JP` — used as assignment identifier |
| Name | Full name |
| Email | For future notifications (Phase 2) |
| Specialty | Optional — links to a category as default area |
| Active | Boolean — inactive technicians cannot receive new assignments |

**When an assignment changes**, the system automatically generates a comment of type `Assignment` in the incident history. The agent does not have to write it manually.

---

### 1.6 Add comments

Agents can add free-text notes to any incident at any time.

**Non-negotiable**: comments are **permanent** — they cannot be edited or deleted. This is a traceability requirement confirmed explicitly by the BC Technical Director.

> *"If an agent writes that they spoke with the client at a certain time, that note must not disappear. It may be needed for a future audit or legal dispute."*

Three types of comments exist:

| Type | Who creates it |
|------|---------------|
| User | The agent — free text |
| Status Change | The system — automatic on every status transition |
| Assignment | The system — automatic when the assigned technician changes |

---

### 1.7 Close with resolution

When an incident reaches `Resolved`, the agent must enter a **resolution summary** — free text describing what was done.

This summary is stored in the incident record itself (not as a comment) — it is the canonical conclusion of the incident and appears prominently on the card.

---

## Section 2 · Customer Service Manager needs

The manager configures the module, maintains master data, and has full visibility.

### 2.1 Setup wizard

Accessible from:

- **Tell Me**: search "Incident Management Setup Wizard"
- **Role Center tile**: "Setup Wizard" quick action

The wizard has **3 steps**:

**Step 1 – Welcome**  
Explains what the wizard does and what will be configured. Informational only.

**Step 2 – Numbering**  
Two options:
- Create a new default number series (`INC-00001` through `INC-99999`)
- Select an existing number series from BC

Once the series is assigned, incidents can be created.

**Step 3 – Demo data**  
Generates sample data for immediate testing:
- 5 demo categories (prefixed `DEMO-`)
- 5 demo technicians (prefixed `DEMO-TECH-`)
- 15 demo incidents in various statuses, linked to 3 **existing** CRONUS USA clients (no new clients created)

**Idempotency**: running the wizard more than once must not create duplicates. If `DEMO-*` records already exist, the wizard skips them silently.

---

### 2.2 Maintain categories

The manager can add, edit, and deactivate categories without calling the partner.

| Field | Notes |
|-------|-------|
| Code | Short identifier e.g. TECH, BILL |
| Description | Human-readable label |
| Default Priority | Initial priority when this category is selected |

**Initial 4 categories**:

| Code | Description | Default Priority |
|------|-------------|-----------------|
| TECH | Technical Support | High |
| BILL | Billing | Medium |
| LOG | Logistics | Medium |
| QUAL | Quality | High |

---

### 2.3 Maintain the technician master

From the Technician List page the manager can add, edit, and inactivate technicians. Fields as described in section 1.5.

---

### 2.4 Manage permissions

Three permission sets:

| Set | Intended for |
|-----|-------------|
| Admin | Full access, module configuration, demo data generation |
| User | Agent profile — can create and work incidents, limited to their assigned |
| Read-only | Directors and audit — read everything, modify nothing |

---

## Section 3 · Visual walkthrough

For reference, here is what each screen should contain:

### Role Center – "Barista Support Agent"

```
+--------------------------------------------------+
| [My Open Incidents: 5]  [Unassigned: 2]          |
| [Critical Open: 1] ← red emphasis                |
+--------------------------------------------------+
| [New Incident]  [All Incidents]  [Setup Wizard]  |
+--------------------------------------------------+
```

### Incident List

```
No.       | Short Description          | Category | Priority | Status      | Assigned To
INC-00042 | Machine not heating        | TECH     | Critical | In Progress | TECH001
INC-00041 | Missing milk order         | LOG      | Medium   | New         |
INC-00040 | Billing error on invoice 7 | BILL     | Low      | Resolved    | MARIA
```

### Incident Card

```
[General]           [Description]            [Assignment]
No.: INC-00042      Short Description: ...   Assigned To: TECH001
Status: In Progress Category: TECH           Created By: alice@...
Priority: Critical  Channel: Call            Creation Date: 14/04/2026

[Resolution Summary]
...

[Incident History FactBox]
14/04/2026 10:05 | Status Change | System | Opened as New
14/04/2026 10:12 | Status Change | System | In Progress
14/04/2026 11:00 | User         | alice  | Spoke with client. They confirm machine is completely down.
```

### Category List

```
Code | Description      | Default Priority
TECH | Technical Support | High
BILL | Billing           | Medium
LOG  | Logistics         | Medium
QUAL | Quality           | High
```

### Technician List

```
Code    | Name             | Email                   | Specialty | Active
TECH001 | Alice Martinez   | alice@cronus.local       | TECH      | ✅
MARIA   | Maria Johnson    | maria@cronus.local       |           | ✅
JP      | JP (Manager)     | jp@cronus.local          |           | ✅
```

### Setup Wizard

```
Step 1 of 3 · Welcome
[Welcome text and description of what the wizard does]

Step 2 of 3 · Numbering
[Create new default series] / [Select existing series]
Series preview: INC-00001 → INC-99999

Step 3 of 3 · Demo data
[Generate 5 demo categories + 5 demo technicians + 15 demo incidents]
[Finish]
```

---

## Section 4 · Expected benefits

| For | Benefit |
|-----|---------|
| Support agents | No more spreadsheets — one place for everything, no duplicate entry |
| JP (management) | Weekly data without manual work — Role Center answers his Monday questions |
| Clients (baristas) | Faster resolution — agents know the full history from the first call |
| Future automation | Phase 2 can add chatbot or notification integration from a clean foundation |

---

## Section 5 · Platform requirements

- Business Central 27.0 or higher
- Essential or Premium licence for BC users (agents and manager)
- Support Technicians: **no BC licence required**
- No third-party dependencies

---

## Section 6 · v1.0 scope

### Included ✅

- Full incident lifecycle (7 statuses + Cancelled)
- Configurable categories with default priority
- Own technician master (independent of BC users)
- Incident-to-technician assignment
- Append-only comment history (User, Status Change, Assignment)
- Optional link to existing BC Customer master
- Role Center with 3 cues + 3 quick action tiles
- Profile "Barista Support Agent"
- Setup wizard (3 steps) + idempotent demo data
- 3 permission sets (Admin, User, Read-only) with `Execute` on pages and codeunits

### Not included ❌

- OData REST API for external integration with chatbots **(Phase 2 · high priority)**
- File attachments to incidents
- Email notifications to clients
- SLA automatic calculation
- Approval workflows
- Client portal
- Power BI advanced dashboards
- AI automatic categorisation
- Incident templates

---

## Section 7 · Development timeline

**~2 effective working weeks with ALDC methodology**

| Week | Activities |
|------|-----------|
| Week 1 | Approved architecture · approved spec · first ALDC phase (data model + permissions) |
| Week 2 | Business logic · UI · Role Center · wizard · demo data · training · production deployment |

---

## Section 8 · Validation agreements

This document was validated in a joint session with the following stakeholders:

| Role | Name | Agreement |
|------|------|-----------|
| Project Manager | JP | ✅ Approved |
| Functional Consultant | Customer Service team | ✅ Reviewed and approved |
| Technical Consultant | Systems team | ✅ No technical objections |
| BC Technical Director | BC team | ✅ Coherent with existing implementation |

---

## Annex · Business glossary

| Term | Definition |
|------|-----------|
| **Incident** | Any event requiring attention from the CRONUS support team, reported by a client or logged internally |
| **Category** | Classification of incident type (Technical, Billing, Logistics, Quality) — configurable |
| **Priority** | Urgency level: Low, Medium, High, Critical |
| **Lifecycle** | Sequence of statuses an incident passes through from opening to closing |
| **Support Technician** | Person responsible for resolving incidents — does not have BC licence |
| **Role Center** | BC home page customised for the Support Agent profile |
| **Cue** | KPI tile on the Role Center that shows a count with a colour indicator |
| **Demo data** | Sample records generated by the wizard to enable immediate testing in a new environment |
| **HITL** | Human in the Loop — explicit review gate between development phases |
| **ALDC** | AL Development Collection — VS Code extension with agents, skills and workflows for BC development |
| **Kick-off** | First joint meeting to align scope, objectives and constraints before development |
| **Phase 2** | Next project iteration — REST API + chatbot integration + advanced notifications |

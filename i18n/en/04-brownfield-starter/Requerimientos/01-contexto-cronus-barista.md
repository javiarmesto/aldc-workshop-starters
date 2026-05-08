> 🇪🇸 [Versión en español](../../../04-brownfield-starter/Requerimientos/01-contexto-cronus-barista.md) · 🇬🇧 English

---

# Business Context Document

**Project:** Barista Incidents  
**Client:** CRONUS USA Inc.  
**Version:** 1.0-workshop  
**Status:** Approved after kick-off meeting

---

## Section 0 · Origin of this document

This document was produced after a **2-hour kick-off meeting** held on Thursday 16 April 2026.

Attendees on the CRONUS USA side:

| Name | Role |
|------|------|
| JP | Project Manager (main contact) |
| Functional Consultant – Customer Service | Describes client workflows |
| Technical Systems Consultant | Provides satellite-systems context |
| BC Technical Director | Validates architectural coherence |

During the meeting:

- **JP** presented the operational situation and business priority
- The **Functional Consultant** described current customer service workflows
- The **Technical Consultant** outlined the context of satellite systems (POS, card readers, ticketing)
- The **BC Technical Director** validated coherence with the existing BC implementation

This document captures what was heard, agreed, and approved before starting development.

---

## Section 1 · CRONUS USA Inc.

CRONUS USA Inc. is a **North American company specialising in professional barista coffee supply**.

Product catalogue:

- **WRB-\*** (Whole Roasted Beans): Colombia, Brazil, Indonesia, Mexico, Kenya, Costa Rica, Ethiopia, Hawaii
- **WDB-\*** (Whole Decaf Beans): same origins as WRB

Their customer base: cafeterias, hotels, restaurants, bakeries across North America. They distribute **tens of tons monthly** to more than **300 professional clients**.

Their clients — baristas, chefs, pastry cooks — are **product quality experts**. They trust CRONUS because of consistency: same roast profile batch after batch, guaranteed delivery time, product traceability.

---

## Section 2 · The barista client

The professional barista works with industrial espresso machines and has high expectations:

- **Product consistency**: if they change the grind profile and the beans are different, the extraction is ruined
- **Delivery time**: missing an ingredient means lost service time
- **Traceability**: they need batch info when clients ask "what coffee is this?"
- **Agile support**: when a machine breaks down mid-service, they need an answer in minutes

**The problem**: baristas contact CRONUS through multiple simultaneous channels — phone, email, WhatsApp, AI assistants. Information gets scattered.

---

## Section 3 · The operational problem

**Current situation** (as described by the Functional Consultant):

- Incidents tracked on a spreadsheet on SharePoint
- Personal notes taken by the support agent who took the call
- A separate quality system not integrated with BC
- A generic email inbox shared by the team

**JP quote** (preserved verbatim as it captures the essence perfectly):

> *"It's not that we don't want to help the barista; when they call we don't even know what they told us last week."*

**Concrete consequences**:

1. **Information loss between channels**: a barista calls on Monday, emails on Wednesday — two separate records, no link
2. **Incident duplication**: the same breakdown is logged 2-3 times if reported by different people
3. **No visibility of open count**: support team does not know how many incidents are open right now
4. **No trend analysis**: JP cannot answer "which clients have most incidents?" or "which machine breaks down most often?"

---

## Section 4 · Project vision

**One-sentence goal**: centralise all support incident management in Business Central.

Four founding principles agreed in the meeting:

| # | Principle | Detail |
|---|-----------|--------|
| 1 | Centralised | All incidents logged in BC · one truth |
| 2 | Integrated with customer master | Incidents linked to existing BC clients · no parallel master |
| 3 | Operationally oriented | Dedicated Role Center · agents use BC as their daily tool |
| 4 | Manageable scope | v1.0 ready and deployed in 2-3 weeks |

A **fifth principle** was raised by the BC Technical Director:

> Keep the door open for AI/chatbot integration in future phases. This means exposing a standard REST API from v1.0 — even if not used immediately.  
> **Clarification by JP:** "The API — we want it, but not in v1.0. First validate that the team uses the system, then open it to the chatbot."

This means: **v1.0 does not include the REST API** for external chatbots, but it is **planned as Phase 2 and must not be architecturally blocked**.

---

## Section 5 · Project actors

Three actor types identified:

| Actor | BC user? | Role |
|-------|----------|------|
| Support Agent | ✅ Yes | Logs incidents, updates progress, closes by assigning |
| Customer Service Manager | ✅ Yes | Supervises all incidents, configures the module, runs reports |
| Support Technician | ❌ No | Handles assigned incidents · does NOT have BC license |

**Key decision confirmed in the meeting**: Support Technicians are **NOT BC users**. They have their own operational tools. The system must allow assigning incidents to them (by code/name) without requiring a BC licence. This is a critical architectural constraint.

---

## Section 6 · Explicitly out of scope for v1.0

JP signed off the following list as out of scope:

| Item | Notes |
|------|-------|
| SLA automatic calculation | Deadline fields will exist, but no automatic breach warnings |
| Email notifications to clients | Manual for now |
| Approval workflows | No BC approval module |
| Client portal | Phase 2 or later |
| File attachments | Not required for go-live |
| Advanced Power BI | Standard Role Center cues are enough for v1.0 |
| Satisfaction surveys | Out of scope |
| External REST API for chatbots | **Phase 2 · planned but not committed** |

JP's own words on the API:

> *"The API — we want it, but not in v1.0. First validate that the team uses the system, then open it to the chatbot."*

This is binding: develop v1.0 **without** the OData REST API, but design it so it can be added cleanly as a Page extension without touching core tables.

---

## Section 7 · Why this case is representative

The BP (Barista Incidents pattern) applies virtually **to any B2B company** that has:

- Recurring professional clients
- Multi-channel incidents (phone, email, chat, WhatsApp)
- Business Central as the operational ERP
- Field staff without BC licences (technicians, installers, drivers)

Examples where the same pattern applies: distribution companies with client equipment issues, software publishers with support agents, industrial distributors with field technicians.

If you learn to implement this pattern well, you have the foundation of a reusable incident-management module.

---

## Section 8 · Kick-off agreements

Eight formal points agreed at the end of the meeting:

1. **Closed scope**: no feature is added during development without JP's explicit sign-off
2. **Target environment**: CRONUS USA Inc. sandbox
3. **Development methodology**: ALDC with explicit HITL gates between phases
4. **Delivery timeline**: 2-3 weeks from architecture sign-off
5. **Single contact**: JP is the only stakeholder empowered to approve or reject deliverables
6. **Next meeting**: after `architecture.md` is ready (estimated 1 week)
7. **Phase 2**: planned (REST API + chatbot integration), not committed, no date
8. **Operational documentation**: produced at project close · user guide for agents and setup guide for the manager

---

*Document produced after the kick-off meeting by the partner technical team based on notes taken during the session. Reviewed by JP and approved as an accurate representation of what was agreed.*

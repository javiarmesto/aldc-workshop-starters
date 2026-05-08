> 🇪🇸 [Versión en español](../../../03-coding-agents-starter/docs/caso-barista-incidents.md) · 🇬🇧 English

---

# Business Case · Barista Incidents

> **Block 03 input material**. This document is the starting point for the
> **al-architect** exercise. Format: internal email thread.

---

**From:** Marta Gutiérrez — Operations Director, Cafélatte Group  
**To:** Carlos Ruiz — Technology Partner  
**CC:** Laura Méndez — IT Manager, Cafélatte Group · David Ortega — Operations, Cafélatte Group  
**Subject:** BC project · incidents module for coffee bar stations  
**Date:** Monday 14 April 2026 09:47

---

Carlos,

Thank you for the meeting last week. I want to put in writing what we discussed so there are no misunderstandings when you start the project.

---

## The current problem

Right now our baristas manage incidents via **WhatsApp and a shared Excel on OneDrive**. It works, but just barely. There is no way to know:

- How long it took to resolve a breakdown
- Which machines break down most (and how often)
- How many incidents are open today at each station
- Whether the same incident was reported twice by two different baristas

Every Monday the operations meeting asks me for numbers and I have no way to give them — I have to go through the Excel row by row and do it by hand.

---

## What we want

A **simple app inside Business Central** so that baristas can log incidents directly: someone opens BC, taps "New Incident", selects the type, writes two lines, and that is it. The system handles the rest.

**Important**: 70% of our baristas are young weekend staff. They are not going to read manuals. If it is not obvious, they will not use it.

---

## Incident types

We handle 4 types:

1. **Machine breakdown** (espresso machine, grinder, steamer, dishwasher)
2. **Supply shortage** (milk, coffee, sugar, cups, napkins)
3. **Customer complaint** (cold coffee, long wait, billing error, poor service)
4. **System problem** (POS frozen, card reader, ticket printer)

---

## Severity

Three levels: low, medium, high. When something is **high**, the system should send a push notification to the on-call technician. We do not want the incident sitting open for hours without anyone knowing.

---

## Automatic assignment

Each incident type goes to a different team automatically:

- Machine breakdowns → maintenance team
- System problems → IT team
- Supply shortages → zone purchasing manager
- Customer complaints → store manager

**This must be configurable.** We are opening two new cafeterias this year and I do not want to call you to change a line of code every time. The team behind each type at each location should be configurable from within BC.

---

## Resolution tracking

When an incident is closed, I need to know: who resolved it, how long it took, and a brief note about what was done. That data is gold for my weekly report.

---

## Weekly report

Every Monday management meeting I need a panel in BC showing:

- Incidents by type this week
- Average resolution time by type
- Top 3 cafeterias with most incidents
- Top 3 machines with most breakdowns

It does not have to be fancy. A Role Center with numbers is enough.

---

## Integrations

Two things:

1. **External maintenance SaaS**: when there is a high-severity machine breakdown, the system should automatically notify their platform. They have a REST API (they will send us the documentation). This can be the second iteration — first let us get the basics working.

2. **Internal data warehouse**: our data team wants to stop exporting Excel files. They want to consume the data directly from BC via API. Something standard. v2.0 API should work.

---

## Security

This is important:

- Baristas can **create** incidents but cannot modify or close other people's
- Managers see all incidents from their store and can close them
- Technicians only see the incidents assigned to them
- Operations office and management see everything

The current cashier and store manager profiles in BC must not be broken.

---

## Timeline

We need the first version working in the pilot cafeteria before end of May. Integration with external maintenance is second iteration — that does not block go-live.

---

Thank you and looking forward to the next steps.

**Marta Gutiérrez**  
Operations Director · Cafélatte Group  
marta.gutierrez@cafelatte-group.com · +34 91 555 0132

---

---

> **Technical team notes** (for partner use, not sent to Marta)

The following points are ADR candidates for the architecture:

- **Tables**: Incident, Incident Type, Incident Severity, auto-assignment configuration table. The email implies Incident Type is a configurable table, not a fixed enum (see "configurable" requirement).

- **Types: enum vs table**: the email explicitly states the assignment must be configurable without code changes. This strongly points to a configuration table rather than a fixed enum.

- **Auto-assignment**: the assignment matrix is `Type × Store → Team`. Needs its own configuration table. Decide if `Store` is a standard `Location` or a custom entity.

- **High-severity notification**: should the integration event be one (with subscriber deciding whether to call external API) or two separate events (one for push notification, one for external call)? Trade-offs in subscriber coupling.

- **Role Center**: extend existing `Business Manager RC` or create a new "Operations Manager" Role Center? A new one keeps existing profiles untouched.

- **External maintenance API**: `HttpClient` codeunit with error handling and retries. Candidate for second iteration as Marta confirmed. Use integration event pattern so the subscriber can be unpublished without touching core.

- **Permissions**: two sets minimum: `Barista Incidents Basic` (create/read) for baristas and local managers, `Barista Incidents Full` (full lifecycle + configuration) for technicians and office staff.

---

**Expected output for Block 03**:

The speaker will use `al-architect` and `al-spec.create` to produce two artefacts from this email:

1. `barista-incidents.architecture.md` — produced by `al-architect`:
   - Skills applied at the top
   - Numbered ADRs with considered alternatives and rationale
   - Data model (tables, relationships, cardinalities)
   - APIs (v2.0, bound actions, queries)
   - Integration events for state transitions
   - Permissions strategy

2. `barista-incidents.spec.md` — produced by `al-spec.create` (workflow):
   - Executable spec
   - Object list with IDs within range
   - Fields with types and constraints
   - Inter-object dependencies
   - Test cases (happy path + edge)
   - Phase plan for the conductor

> `al-conductor` is **not executed in this block**. That is Block 04.

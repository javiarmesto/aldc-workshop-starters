# ALDC Demo: Strategic Customer Review

A reproducible 25-minute demo showing how ALDC turns an ambiguous Business Central requirement into an approved technical contract before generating AL code.

## Business case

The sales team wants to identify strategic customers and record the date of their next commercial review.

The scenario is intentionally small:

- Two Customer fields.
- One table extension.
- Two page extensions.
- Table-level business validation.
- Automated acceptance tests.

## Core message

> The customer provides intention. The consultant clarifies behaviour. ALDC creates the contract. Copilot implements it without inventing the scope.

## Run the demo

1. Open `demos/strategic-customer-review` as the VS Code workspace root.
2. Install AL Language, GitHub Copilot Chat and AL Development Collection.
3. Run `AL Collection: Install Toolkit to Workspace`.
4. Update `.vscode/launch.json` if your sandbox is not named `sandbox`.
5. Run `AL: Download Symbols`.
6. Follow `demo-guide.md`.

The project targets Business Central 27, runtime 16.0, with object IDs `50100..50149`.

## Demo flow

1. Show `requirements/original-requirement.md`.
2. Discuss `requirements/review-notes.md`.
3. Show `requirements/optimized-requirement.md`.
4. Run `prompts/01-create-spec.md`.
5. Review and approve the generated contract.
6. Run `prompts/03-implement.md`.
7. Compile and review the generated objects and tests.
8. Close with `vibe-coding-vs-aldc.md`.

## Timing

| Time | Step |
| ---: | --- |
| 0-2 min | Business context |
| 2-5 min | Original requirement and ambiguities |
| 5-8 min | Optimized requirement |
| 8-13 min | Generate specification |
| 13-16 min | Review and approve specification |
| 16-22 min | Implement |
| 22-24 min | Compile or inspect |
| 24-25 min | Closing message |

## Why LOW complexity?

There are no integrations, new tables, background processes or architectural decisions. The flow is therefore:

`al-spec.create` -> human approval -> `AL Implementation Specialist`

The `src` folder is intentionally empty at the start. Generating the implementation is part of the live demo.

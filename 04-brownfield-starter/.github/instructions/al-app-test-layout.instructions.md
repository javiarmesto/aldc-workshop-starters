---
applyTo: "**/{app.json,*.code-workspace}"
description: "Guardrails for nested App/Test AL projects, workspace roots, and compile isolation between the main app and the test app."
---

# AL App/Test Layout Guardrails

Use this instruction when working on manifests or workspace files that affect how the main app and test app are discovered and built.

## Intent

Prevent the main app from accidentally compiling nested test sources and prevent the test project from missing required Microsoft test libraries.

## Rules

- If the repository contains a nested `test/` AL project with its own `app.json`, treat it as a separate extension, not as part of the root app.
- Never assume the main app build is limited to `src/`; check whether extra `.al` files exist elsewhere under the root project tree.
- Do not treat Explorer visibility or `files.exclude` as a build fix. Hiding folders changes UI behavior, not compiler scope.
- When `AL0297` appears on test object IDs during the main app build, first suspect cross-project contamination.
- When `AL0185` appears for `Library Assert`, `Library - Sales`, `Library - Inventory`, or `Library - Random`, check both:
  - whether the test project is being compiled with the wrong manifest;
  - whether `Application Test Library`, `Library Assert`, `Tests-TestLibraries`, and `System Application Test Library` are declared when used.
- Prefer physical separation of app and test projects as sibling folders. If the repo layout cannot change, require an explicit compile barrier such as test-only preprocessor symbols.
- For multi-root workspaces, keep separate roots for the main app and the test app, and verify the `.code-workspace` still points to both.

## Recommended Checks

1. Read the root `app.json`.
2. Read the test project's `app.json`.
3. Read the `.code-workspace`.
4. Confirm whether `test/` is physically nested under the main app root.
5. Validate both builds separately after config changes.

## Safe Fix Order

1. Fix workspace and manifest association issues.
2. Fix missing test dependencies.
3. Add or maintain compile isolation between main app and test app.
4. Only then adjust Explorer or search visibility if the user wants a cleaner UI.
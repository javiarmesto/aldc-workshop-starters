# Severity decision guide

> Consulted by `skill-diagnostics` when a finding could reasonably fall into
> more than one severity level. Keep this short — the skill should decide
> quickly, not deliberate.

## The rule of thumb

> **When in doubt, downgrade.**
> A noisy Blocker-heavy report erodes trust. Make every Blocker count.

## Decision tree

```
Does the violation cause compilation to fail or the extension to not install?
├── Yes → Blocker
└── No  → Does it break a required pattern explicitly declared in the contract?
         ├── Yes → Major
         └── No  → Is it a visible style deviation that a reviewer would comment on?
                  ├── Yes → Minor
                  └── No  → Nit
```

## Concrete examples

### Blocker territory

- Table without `DataClassification` → AppSource submission fails
- Object ID outside the declared range → app cannot install alongside others
- `LookupFormId` used → deprecated and broken in newer runtimes
- New object not in any permission set → runtime permission errors

### Major territory

- Field missing `Caption` → user sees raw field name in UI
- Field missing `ToolTip` → accessibility / AppSource quality gate
- Public procedure without XML doc → ruins IntelliSense for consumers
- Missing test codeunit for a public codeunit → breach of declared coverage rule

### Minor territory

- Hardcoded numeric ID in code → works but brittle
- Filename doesn't match `<Object>.<Type>.al` → searchability only
- Section order wrong inside an object → aesthetics
- Permission set name doesn't follow `CEB <Feature> Basic` convention

### Nit territory

- Inconsistent indentation inside a single file (but 4-space elsewhere)
- Trailing whitespace at end of lines
- Extra blank lines between `fields` and `keys`

## What is NOT in scope

- **Not in scope**: runtime performance, security audits, code smells that the
  contract doesn't address. Those are for other skills (`skill-performance`,
  `skill-security-review`).
- **Not in scope**: enforcement. This is a report-only skill.

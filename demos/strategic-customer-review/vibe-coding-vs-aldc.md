# Vibe Coding vs ALDC

| Ambiguous point | An LLM might invent | Approved ALDC contract |
| --- | --- | --- |
| Disable strategic flag | Clear the date | Preserve the date |
| Meaning of today | Use `Today()` | Use `WorkDate()` |
| Validation location | Page only | Table-level validation |
| Affected pages | Customer Card only | Card and List |
| Tests | None | Acceptance tests |
| Scope evolution | Add features directly | Update and approve the spec |

All invented choices could compile, and all could be wrong.

> The AI should not decide how your ERP works. It should implement what the business has approved.

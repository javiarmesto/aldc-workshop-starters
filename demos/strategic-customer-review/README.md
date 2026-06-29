# ALDC Demo: Strategic Customer Review

This demo shows how ALDC turns an ambiguous Business Central requirement into a clear, reviewable technical contract before implementation.

## Business case

The sales team wants to identify strategic customers and record the date of their next commercial review.

The scenario is intentionally small so it can be demonstrated in 25 minutes:

- 2 new customer fields.
- 1 table extension.
- 2 page extensions.
- Simple business validation.
- Optional automated tests.

## Demo message

The customer provides intention. The consultant clarifies behaviour. ALDC converts it into a technical specification. Copilot implements against that specification instead of inventing the scope.

## Suggested flow

1. Show the original requirement.
2. Discuss why it is not enough for safe AI-assisted development.
3. Show the improved requirement.
4. Run the ALDC specification prompt.
5. Review the generated specification before coding.
6. Run the implementation prompt.
7. Review the generated AL objects and tests.

## Recommended timing

| Time | Step |
| ---: | --- |
| 0-2 min | Business context |
| 2-5 min | Original requirement and ambiguities |
| 5-8 min | Optimized requirement |
| 8-13 min | Run al-spec.create |
| 13-16 min | Review and approve the specification |
| 16-22 min | Implement with AL specialist |
| 22-24 min | Compile or review the result |
| 24-25 min | Closing message |

Recommended ALDC complexity: LOW.

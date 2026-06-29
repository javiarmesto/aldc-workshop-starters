# Expected output

## Classification

`LOW`: no integration, new table, background process or architectural decision.

## Expected objects

| Object | Purpose |
| --- | --- |
| Customer table extension | Add both fields and table-level validation |
| Customer Card page extension | Add the Strategic Customer group |
| Customer List page extension | Expose both filterable fields |
| Test codeunit | Verify the principal acceptance criteria |

Object IDs must be selected from `50100..50149`.

## Expected behaviour

- Strategic customers require a review date.
- A review date earlier than WorkDate is rejected.
- Disabling the flag preserves the date.
- Validation is enforced in the data layer, not only in the UI.

## Expected tests

1. Enabling the flag without a date fails.
2. Entering a past date fails.
3. Enabling the flag with a valid date succeeds.
4. Disabling the flag preserves the date.

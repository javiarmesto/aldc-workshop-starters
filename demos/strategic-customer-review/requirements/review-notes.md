# Review notes

The original requirement leaves business decisions open:

- What happens to the date when the strategic flag is disabled?
- Does "today" mean the system date or Business Central WorkDate?
- Is validation enforced only in the page or also in the table?
- Can the date be entered before enabling the flag?
- Which pages are affected?
- Are automated tests expected?
- What is explicitly out of scope?

The risk is not that Copilot fails to generate AL. The risk is that it generates valid code while making decisions the customer never approved.

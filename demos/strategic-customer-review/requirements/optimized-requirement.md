# Requirement: Strategic Customer Review

## Business context

The sales team needs to identify strategic customers and record the planned date of their next commercial review. Today this information is managed outside Business Central.

## Goal

Allow users to mark a customer as strategic and register the next commercial review date.

## Functional scope

1. Add a Boolean field named `Strategic Customer` to Customer.
2. Add a Date field named `Next Review Date` to Customer.
3. Show both fields in a new `Strategic Customer` group on Customer Card.
4. Show both fields on Customer List.
5. Allow users to sort and filter the list using these fields.

## Business rules

1. If `Strategic Customer` is enabled, `Next Review Date` is mandatory.
2. `Next Review Date` cannot be earlier than Business Central WorkDate.
3. The date may be entered before enabling `Strategic Customer`.
4. Disabling `Strategic Customer` preserves the review date.
5. Date validation applies to strategic and non-strategic customers.
6. Validation applies whether the record is changed from the UI or from AL code.

## Acceptance criteria

### AC-01
Given a customer without a review date, when the user enables `Strategic Customer`, then Business Central rejects the change with an error.

### AC-02
Given any customer, when the user enters a review date earlier than WorkDate, then Business Central rejects the date with an error.

### AC-03
Given a customer with a valid review date, when the user enables `Strategic Customer`, then the change is saved.

### AC-04
Given a strategic customer with a review date, when the flag is disabled, then the date remains unchanged.

### AC-05
Given customers with different values, when Customer List is opened, then both fields can be viewed and filtered.

## Out of scope

- Review notifications or automatic task creation.
- Dynamics 365 Sales integration.
- Reports, dashboards or background processing.
- Historical data migration.

## Open decisions

None.

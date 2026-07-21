---
name: review-verify
description: Verifies PR review concerns against code, targeted tests, and browser behavior. Use before replying, clearing, resolving, or publishing review feedback.
---

# Review Verify

Verify review concerns independently. CI and deployment are supporting signals, not proof.

## Concern Record

Every discovered concern gets one record, including concerns found only in a review summary and comments that are outdated, hidden by a squash, or no longer attached to the current diff:

- source and stable identifier, plus visibility (`current-user-pending`, `teammate-visible`, or `ambiguous`)
- exact concern
- status: `addressed`, `still-open`, `uncertain`, or `not-applicable`
- code mapping: relevant current paths and lines, or why no current code maps to it
- test evidence: command and result, existing coverage inspected, or why a targeted test cannot establish the claim
- browser evidence when user-visible behavior needs it: scenario and result, or why it was unnecessary or blocked
- gap: remaining risk, missing access, unavailable artifact, or `none`

Use only this status vocabulary:

- `addressed`: current evidence demonstrates the concern is fixed.
- `still-open`: current evidence demonstrates the concern remains.
- `uncertain`: evidence is missing, conflicting, or blocked.
- `not-applicable`: the concern no longer applies; explain the changed premise rather than treating an outdated or squashed comment as automatically closed.

`ready-to-resolve` is not a concern status. Derive it only when status is `addressed` **and** the concern belongs to an identifiable, teammate-visible, unresolved public thread. Explicit user authorization is still required to resolve it.

## Steps

1. **Inventory the review state.** Read PR metadata, review bodies, inline comments, active thread state, commits, current head, CI, and deployment state. Include current-user pending reviews and recover referenced commits when squashing or outdated comments obscures context. Read [REFERENCE.md](REFERENCE.md#read-pr-and-review-state) for commands. **Complete when every discovered inline, summary-only, outdated, and squashed concern has a concern record and source identifier.**

2. **Map each concern to the current implementation.** Inspect the referenced code and commit history, then locate the current code path that satisfies or violates the concern. Treat supplied URLs as entry points rather than scope boundaries. **Complete when every record has an exact current code mapping or an explicit explanation of why none exists.**

3. **Gather targeted evidence.** Run the smallest non-E2E tests that directly exercise each testable claim; inspect existing coverage where execution is unavailable. Use manual browser verification when tests do not establish user-visible behavior. Read [REFERENCE.md](REFERENCE.md#targeted-tests) for command selection and [REFERENCE.md](REFERENCE.md#browser-verification) for the browser procedure. **Complete when every record contains test evidence, any required browser evidence, and an explicit gap (including `none`).**

4. **Classify every concern.** Apply exactly one authoritative status from the vocabulary above based on current code and direct evidence. Use CI and deployment only to support that evidence. **Complete when every record has one status with a rationale and no concern is inferred closed merely because it is outdated, squashed, deployed, or green in CI.**

5. **Report verification and route follow-up.** Report all concern records, then list `ready-to-resolve` as a derived subset and state the explicit next action for requested replies, clearing, resolution, or publication. Use [REFERENCE.md](REFERENCE.md#report-shape) for a compact output shape. **Complete when the report accounts for every discovered concern and names every evidence gap and follow-up owner.**

## Mutation and Publication Safety

Verification is read-only, including staging data. Use reversible browser interactions and obtain explicit approval before saving real data. Stop after reporting unless the user explicitly requests a follow-up mutation or publication. Route pending-artifact deletion to `review-clear`, teammate-visible resolution to `team-review-resolve`, and fixes or replies to `review-address`; use the relevant publication skill for submitting a pending review. Keep replies pending unless public visibility was explicitly requested. Never submit an existing pending review as a workaround for making a reply visible, and never resolve a thread whose concern is anything other than `addressed` or which fails public-thread eligibility.

---
name: self-review
description: Creates or reconciles a current-user PENDING PR review with inline comments. Use when review feedback must remain unpublished.
---

# Self Review

Independently review a PR, reconcile the findings with the current user's single pending review, and leave the exact intended feedback in that same `PENDING` draft.

Suggested command: `/self-review <pr-number-or-url>`

## Model

Treat the review as two layers:

1. an independent **finding set**, produced from the diff and evidence without reading the existing draft; and
2. one current-user **pending review**, reconciled in place only after the finding set is complete.

GitHub permits one pending review per user per PR. Preserve that review and its identity. Omit `event` to keep it pending; `PENDING` is not an event value.

## Invariants

- Review every changed risk area: correctness, regressions, authorization and data ownership, security, performance, maintainability, and tests.
- Do not read existing current-user pending feedback until the independent pass is complete.
- Never submit or publish without an explicit instruction naming `COMMENT`, `APPROVE`, or `REQUEST_CHANGES`.
- Never use the REST pull-comment endpoint (`POST /pulls/{pull_number}/comments`) for draft comments; it publishes immediately.
- Preserve one current-user pending review. Do not silently delete or recreate it.
- `review-clear` is the sole authority for destructive pending-review deletion. If in-place reconciliation is genuinely impossible, stop, explain why replacement is required, and require an explicit `review-clear` operation before resuming.
- Keep suggestion widgets pending by attaching GraphQL review threads to the pending review.

## Workflow

### 1. Resolve scope and read the change

Resolve the PR, authenticated user, base/head refs, metadata, full diff, changed files, and repository guidance. Inspect relevant call sites, tests, ownership boundaries, and history—not only isolated hunks.

Use [REFERENCE.md](REFERENCE.md#read-the-pr) for commands.

**Complete when:** every changed file is classified by risk and every changed risk area has been inspected or has an explicit residual-risk note.

### 2. Build findings independently

Before fetching the current user's pending review, verify each potential concern against current code. Prefer focused tests; use browser or direct code-path evidence where appropriate. Record:

- severity, path, and changed-side line;
- concrete behavior and impact;
- supporting evidence and confidence;
- concise, actionable comment text; and
- a minimal fix direction or suggestion when useful.

Do not create comments for unsupported suspicions. For a test-proven issue, include only the essential setup and failing assertion, with the received value when useful.

**Complete when:** the independent finding set accounts for all reviewed risk areas, including explicit testing gaps or residual risks when there are no findings.

### 3. Inventory the existing draft

Only now fetch all reviews and comments and identify reviews where the author is the authenticated user and state is `PENDING`. Follow pagination.

- If none exists, create one pending review.
- If exactly one exists, preserve its review ID and reconcile it in place.
- If ownership or cardinality is ambiguous, stop without mutation.

Use [REFERENCE.md](REFERENCE.md#find-the-current-users-draft) for identity and inventory commands.

**Complete when:** the current-user pending-review cardinality, numeric ID, node ID, body, and complete comment set are known.

### 4. Reconcile every finding and draft comment

Compare the independent findings and existing draft one by one:

- retain independently confirmed, current, non-duplicate comments;
- rewrite partially correct or over-claimed comments;
- remove stale, invalid, duplicate, or superseded draft comments;
- add independently verified findings missing from the draft; and
- set the summary body to the intended final summary.

Record a disposition for every independent finding and every pre-existing draft comment. Reconciliation changes the existing draft through supported in-place comment/body mutations; it does not stack a second draft or replace the review.

Read [REFERENCE.md](REFERENCE.md#reconcile-in-place) before mutating. It contains mutation syntax, line-anchor parameters, suggestion mechanics, and the stop condition for unsupported artifacts.

**Complete when:** every finding and existing comment has exactly one disposition, and the intended body/comment set is fully specified before mutation.

### 5. Create or update the pending draft

For no existing draft, create a review with the intended body and comments while omitting `event`. For an existing draft, update its body and comments in place using its IDs. Add line-anchored comments—especially ````suggestion` blocks—as GraphQL review threads attached to its review node ID.

Do not pass an event, call a submission endpoint, use the REST pull-comment endpoint, or delete the review. If GitHub cannot mutate a required legacy artifact in place, stop and route explicit deletion to `review-clear`; resume only after that separate operation succeeds.

Use [REFERENCE.md](REFERENCE.md#create-a-new-pending-review) and [REFERENCE.md](REFERENCE.md#reconcile-in-place).

**Complete when:** exactly one current-user review contains the intended body and comments, remains `PENDING`, and no destructive or public fallback occurred.

### 6. Verify exact final state

Re-fetch the review, body, comments, and thread state. Compare IDs, ownership, state, anchors, bodies, and count against the intended set. Check that suggestion comments remain in the pending review and render from ````suggestion` blocks.

**Complete only when:**

- every changed risk area was reviewed;
- every independent finding and pre-existing draft comment was reconciled;
- exactly one resulting review belongs to the current authenticated user;
- that review remains `PENDING`; and
- it contains exactly the intended body and comments—no missing, duplicate, stale, or accidentally public feedback.

Report findings first, then reconciliations, draft review ID/state, verification evidence, and residual risks. If exact state cannot be proved, report the gap and make no destructive fallback.

## Explicit Submission Boundary

This skill's default endpoint is a verified pending draft. Submission is a separate action and requires an explicit event instruction. See [REFERENCE.md](REFERENCE.md#submit-only-when-explicitly-instructed) only when the user has clearly requested `COMMENT`, `APPROVE`, or `REQUEST_CHANGES`; otherwise stop with the review pending.

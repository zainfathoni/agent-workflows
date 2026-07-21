---
name: team-review
description: Reviews teammate PRs and drafts evidence-backed feedback in a current-user PENDING review. Use for colleague-facing review before publication.
---

# Team Review

Produce a rigorous colleague-facing review without publishing feedback prematurely. Every review is drafted and verified as `PENDING` before any explicit submission.

Suggested command: `/team-review <pr-number-or-url>`

## Invariants

- Review independently before reading existing current-user pending feedback.
- Inspect every changed risk area: correctness, regressions, authorization and data ownership, security, performance, maintainability, and tests.
- Give every finding a severity, concrete impact, supporting evidence, and confidence. Do not publish unsupported suspicions.
- Use [`self-review`](../self-review/SKILL.md) as the sole authority for pending-review creation, inventory, reconciliation, mutation, suggestions, and verification. Do not duplicate or improvise those mechanics here.
- Never use the REST pull-comment endpoint (`POST /pulls/{pull_number}/comments`) for draft feedback; it publishes immediately.
- Never submit without an explicit instruction naming `COMMENT`, `APPROVE`, or `REQUEST_CHANGES`.
- Never approve while unresolved correctness, security, data-integrity, authorization, or data-ownership concerns remain.

## Workflow

### 1. Review the change independently

Read the PR context, full diff, changed files, relevant call sites, tests, ownership boundaries, and repository guidance. Classify changed areas by risk and verify behavior against implementation rather than assumptions. Do not inspect an existing pending draft yet.

**Complete when:** all changed risk areas have been inspected, or each unverified area has an explicit residual-risk note.

### 2. Establish colleague-ready findings

For each concern, record severity, changed-side path and line, concrete failing scenario and impact, evidence, confidence, and a useful fix direction. Prefer a focused failing test and use the `tdd` skill's one-test-at-a-time proof discipline when feasible; otherwise use browser behavior, logs, API output, or a direct code-path proof. Keep public wording concise and actionable, and remove temporary proof-only changes.

Order findings by severity. If there are none, state that and identify testing gaps or residual risks.

**Complete when:** every finding has evidence and confidence, and unsupported concerns have been omitted or clearly retained only as residual risk.

### 3. Create and verify the pending draft

Only after the independent finding set is complete, follow `self-review` end to end to inventory, create or reconcile, and verify the current user's single pending review. The final body and comments must be complete, exact, colleague-ready, and still unpublished.

**Complete when:** `self-review` verification proves the complete reconciled draft belongs to the authenticated user, contains exactly the intended feedback, and remains `PENDING`.

### 4. Decide publication

Recommend `COMMENT`, `APPROVE`, or `REQUEST_CHANGES` from the verified findings and severity. Any unresolved correctness, security, data-integrity, authorization, or data-ownership concern prevents approval. Unless the user has already explicitly authorized a named event, report the recommendation and stop with the draft pending.

If explicitly authorized, follow [`self-review`'s submission boundary](../self-review/SKILL.md#explicit-submission-boundary) to submit and verify the existing pending review; never create another review.

**Complete when:** either the verified draft remains pending with a publication recommendation, or the existing draft was explicitly submitted and its resulting publication state and visibility were re-read and reported.

---
name: review-address
description: Addresses PR review claims with focused, verified fixes and source-aware follow-up. Use for current-user pending comments or teammate-visible threads.
---

# Review Address

Treat review comments as claims to verify, then make the smallest supported fix. Preserve a concern record compatible with `review-verify`: source and stable identifier, visibility, exact concern, status, code mapping, test evidence, browser evidence when needed, and gap.

Suggested invocation: `/review-address <pr-number-or-url>`

## Review-State Safety Gate

Apply this gate before **every** protected operation. It is the authoritative safety rule for replies, resolution, commit, push, and submission.

- Identify the authenticated GitHub user, review owner and state, thread identity and resolution state, and intended resulting visibility. Classify the source as exactly one of `current-user-pending`, `teammate-visible`, or `ambiguous`.
- Require explicit user intent for each operation independently: public reply, thread resolution, commit, push, or pending-review submission. Permission for one operation does not imply another.
- For a `current-user-pending` source, keep replies in that same pending review. Never submit or delete the review to enable a reply, and never substitute a public issue comment.
- For a `teammate-visible` source, make a public reply or resolve its public thread only when that specific public action was requested. Keep any new feedback in a current-user pending review unless publication was explicitly requested.
- Route every pending-review deletion request to [`review-clear`](../review-clear/SKILL.md); this skill never performs that destructive operation.
- Stop before any protected operation when ownership, state, thread identity, requested operation, or resulting visibility is ambiguous. Also stop rather than crossing an API/schema contract, exceeding roughly 200 changed lines, choosing between conflicting comments, or expanding into an unapproved architectural change.

The gate passes only when the source and visibility are proven, the exact operation and resulting visibility are explicitly authorized, and no stop condition applies. Workflow and follow-up steps below do not relax this gate.

## Reply Semantics

Choose exactly one outcome per thread:

- **Fixed** — state the exact behavior change and verification evidence; include a commit SHA only if a commit was explicitly requested and created.
- **Not actionable** — explain which claim is unsupported or no longer applies and cite the evidence.
- **Deferred** — name the blocker, remaining gap, and follow-up owner or tracking item.

Use `review-verify` status vocabulary in the concern record: `addressed`, `still-open`, `uncertain`, or `not-applicable`. `ready-to-resolve` is not a status; derive it only for an identifiable, teammate-visible, unresolved public thread whose concern is `addressed`. Resolution still requires explicit intent and a passing Review-State Safety Gate.

## Workflow

1. **Inventory review state and intent.** Read PR metadata, review bodies, inline comments, active threads, current-user pending reviews, current head, and the user’s requested mutations. Include summary-only, outdated, and squash-obscured concerns. Use [REFERENCE.md](REFERENCE.md#read-pr-and-review-state) for mechanics. **Complete when every discovered thread and summary-only concern has a stable source identifier, every discovered thread is classified as `current-user-pending`, `teammate-visible`, or `ambiguous`, and every requested or unrequested mutation is recorded separately.**

2. **Verify and triage every claim.** Inspect the current code path and relevant history rather than assuming the comment is correct. Assign each concern one `review-verify` status, with code mapping and existing evidence; route genuinely non-applicable claims without editing. **Complete when every discovered concern has an exact claim, current code mapping or no-mapping explanation, status with rationale, and explicit evidence gap (including `none`).**

3. **Group actionable concerns by root cause.** Combine comments only when the same implementation defect explains them, choose the narrowest correction, and identify focused test and commit boundaries without committing. Keep unrelated concerns separate. **Complete when every `still-open` actionable concern belongs to one justified root-cause group with a minimal fix plan and test plan, while every other concern has a documented no-change reason or blocker.**

4. **Prove the defect and fix minimally.** When practical, add or adjust the smallest focused test that fails for the supported claim, then make only the change needed for that root cause. Preserve the relevant setup and failing assertion as compact evidence; do not narrate red/green process labels. **Complete when every actionable root-cause group has a focused pre-fix failure or a stated reason that such a test is impractical, and its implementation change is limited to the demonstrated cause.**

5. **Verify each concern.** Run touched tests immediately, then the smallest regression batch spanning each root-cause group; use browser evidence where user-visible behavior is not established by tests. Update every concern record using `review-verify` evidence and status rules. Use [REFERENCE.md](REFERENCE.md#targeted-verification) for command examples. **Complete when every actionable concern has fix and verification evidence establishing `addressed`, or is `still-open`/`uncertain` with a concrete blocker and gap, and every non-actionable concern has evidence for `not-applicable` or its remaining status.**

6. **Perform only authorized repository operations.** Apply the Review-State Safety Gate separately to commit and push intent; keep commits aligned to justified root-cause groups when requested. **Complete when each explicitly requested commit or push has passed the gate and has evidence of success, and every unrequested, ambiguous, or blocked repository operation remains unperformed with its reason recorded.**

7. **Prepare and perform source-aware follow-up.** Select one Reply Semantics outcome per thread. Read [REFERENCE.md](REFERENCE.md#reply-templates) when drafting a fixed, not-actionable, or deferred reply. Apply the Review-State Safety Gate independently before any pending reply, public reply, resolution, or submission; use [REFERENCE.md](REFERENCE.md#review-mutation-api) only for API mechanics. Route a requested deletion to `review-clear` and resume only after its separate verification. **Complete when every discovered thread has a selected outcome or explicit blocker, every requested follow-up has fix/verification evidence or a blocker, each performed mutation has confirmed source and resulting visibility, deletion requests have a `review-clear` disposition, and no unrequested submission, resolution, reply, commit, or push occurred.**

8. **Report exhaustively.** Report each concern record, root-cause grouping, changed files, exact verification results, blockers, performed mutations, and deliberately unperformed operations. **Complete when every discovered concern and thread is accounted for, every actionable thread has fix/verification evidence or a blocker, and the report makes ownership, visibility, operation intent, and remaining gaps explicit.**

## Reference

Read [REFERENCE.md](REFERENCE.md) only when a workflow pointer requests GitHub API syntax, test-command syntax, or a reply template. Safety and reply policy live exclusively in this file.

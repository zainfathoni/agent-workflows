---
name: review-address
description: Address PR review comments with TDD, focused fixes, verification, and safe reply handling for current-user pending reviews or teammate-visible threads. Use when fixing issues raised in PR review comments, whether they came from a self-review draft or teammate feedback.
---

# Review Address Skill

Address pull request review comments end-to-end: verify each concern, group shared root causes, make narrow fixes, run targeted verification, and update review threads only when explicitly asked.

Suggested slash command: `/review-address <pr-number-or-url>`

## When to Use

- The user asks to address PR review comments instead of performing a fresh review
- The PR has inline review comments, pending draft comments, or teammate-visible review threads
- The goal is to fix code and optionally reply to addressed comments

## Default Behavior

- Treat review comments as claims to verify, not assumptions to rubber-stamp
- Prefer one focused failing test followed by the minimal fix for actionable regressions
- When a review comment is supported by a failing test, include the relevant setup and failing assertion as a compact snippet without process labels
- Group comments by shared root cause and fix the shared root once
- Keep fixes narrow and localized
- Do not commit, push, reply, resolve, submit, or delete review artifacts unless explicitly asked
- Preserve current-user PENDING review state unless the user explicitly asks to submit or delete it
- Use public replies only when the user explicitly wants teammate-visible replies

## Source-Specific Safety

### Current-user PENDING review comments

- Verify the comment belongs to the current GitHub user and the review state is `PENDING` before using pending-review reply APIs
- Reply inside the same pending review thread instead of creating a public issue comment
- Do not submit the review event or work around GitHub reply restrictions by submitting the review
- If ownership or visibility is unclear, stop before replying

### Teammate-visible review comments

- Public replies and thread resolution are allowed only when explicitly asked
- Resolve only comments that are fully verified as addressed
- Do not submit, delete, or modify current-user pending reviews as part of teammate-visible follow-up unless explicitly asked
- If adding new review feedback while addressing teammate comments, create it as a current-user PENDING review first

## Workflow

1. Read PR metadata, reviews, review comments, and active review threads.
2. Classify each thread as `current-user-pending`, `teammate-visible`, or `ambiguous`.
3. Triage each concern as actionable, non-actionable, or deferred.
4. Group actionable comments by shared root cause and decide commit boundaries.
5. Inspect real code paths before editing.
6. Add or update focused tests first when practical, then fix minimally.
7. Run touched tests immediately and then as a regression batch.
8. Commit or push only when explicitly requested.
9. Reply or resolve only when explicitly requested, using the source-specific safety rules above.

## Reply Shapes

Pick exactly one shape per thread:

- `Fixed`: include commit SHA, exact behavior change, and verification evidence.
- `Not actionable`: explain why no code change is needed.
- `Deferred`: explain the blocker or follow-up tracking.

Use pending-review replies for `current-user-pending` threads. Use public replies only for `teammate-visible` threads and only when explicitly asked.

## Stop Conditions

Stop before committing or replying when:

- A single fix would exceed ~200 LoC of code change
- The fix requires an API contract change, schema change, or cross-team alignment
- The fix exposes a deeper architectural problem that the comment did not flag and the user did not pre-approve
- Two or more comments disagree about the desired behavior
- Comment ownership or visibility is ambiguous

## Reference

See [REFERENCE.md](REFERENCE.md) for GitHub API commands, pending-review reply mutations, test command examples, and full reply templates.

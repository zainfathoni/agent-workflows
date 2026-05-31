---
name: review-verify
description: Verify whether PR review comments are addressed by mapping concerns to code, targeted tests, and browser checks when needed. Use when checking review-fix claims for current-user pending reviews or teammate-visible review threads before replying, resolving, clearing, or submitting.
---

# Review Verify Skill

Verify whether PR review comments have been addressed. Treat CI and deployment as supporting signals, not proof. Map each concern to changed code, tests, and browser behavior when needed.

Suggested slash command: `/review-verify <pr-number-or-url>`

## When to Use

- The user asks whether review comments have been addressed
- The user asks to verify fixes before resolving, replying, clearing, or submitting
- CI has passed but review concerns need independent confirmation
- A staging browser check is useful for behavior that tests do not fully cover
- Review comments may be current-user pending, teammate-visible, squashed, outdated, or only visible through review summaries

## Default Behavior

- Do not assume review comments are addressed; verify them against review text, commits, code, tests, browser behavior, and logs
- Do not run E2E tests by default; use targeted non-E2E tests and manual browser checks when needed
- Do not submit, delete, resolve, publish, or publicly reply to review content unless explicitly asked
- Do not use a pending review as a workaround for publishing replies
- Prefer the smallest targeted test set that maps directly to the review concerns
- Treat example URLs as entry points, not exhaustive scope

## Source-Specific Outcomes

### Current-user pending review concerns

- If pending inline comments are not visible through REST, use the pending review body and referenced commits as the source of truth
- Report whether each concern is addressed, still open, uncertain, or no longer applicable
- If the user asks to clear pending review artifacts after verification, hand off to `review-clear`
- If the user asks to reply, keep replies pending unless they explicitly ask to submit or publish

### Teammate-visible review concerns

- Report which threads are ready to resolve, still open, or uncertain
- If the user explicitly asked to verify and resolve, hand off only fully verified threads to `team-review-resolve`
- If the user only asked to verify, stop before mutating GitHub state
- Public replies are allowed only when explicitly requested and must include concrete evidence

## Workflow

1. Read PR metadata, reviews, review comments, commits, CI status, and current-user pending reviews.
2. Inspect referenced commits, including commits that may have been squashed away.
3. Map each concern to changed files, tests, and browser scenarios.
4. Classify each concern as `addressed`, `still-open`, `uncertain`, or `not-applicable`.
5. Run targeted non-E2E tests that map directly to the concerns.
6. Use browser verification when behavior is not fully covered by tests.
7. Report evidence, ready-to-resolve threads, still-open concerns, and coverage gaps.
8. Mutate GitHub state only through explicit follow-up skills or explicit user instruction.

## Reply and Mutation Rules

- Reply to review or PR comments only when the user explicitly asks
- Never submit an existing pending review to make replies visible unless the user explicitly says to submit that pending review
- Do not use `gh pr review`, the create-review REST endpoint, or any review submission event to satisfy a reply request unless explicitly asked
- Do not delete pending review artifacts; use `review-clear` only when explicitly asked
- Do not resolve teammate-visible threads; use `team-review-resolve` only when explicitly asked and only for fully verified threads

## Reference

See [REFERENCE.md](REFERENCE.md) for GitHub API commands, commit inspection commands, test command examples, browser verification steps, and the final response template.

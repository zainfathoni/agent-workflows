---
name: team-address-review
description: Address colleague review comments with focused fixes, verification, and optional public replies.
---

# Team Address Review

Address colleague-authored PR review comments end-to-end: inspect each concern, reproduce when practical, make narrow fixes, verify the touched behavior, and optionally reply or resolve teammate-visible threads when explicitly asked.

## Default Behavior

- Treat each review comment as a claim to verify, not an assumption.
- Prefer focused red/green tests for actionable regressions.
- Group comments by shared root cause and fix the shared root once.
- Keep fixes narrow and localized.
- Do not commit, push, reply, or resolve review threads unless explicitly asked.
- Do not submit, delete, or modify private pending reviews as part of the team workflow.

## Workflow

### 1. Read PR And Review Threads

```bash
REPO=$(gh repo view --json nameWithOwner --jq .nameWithOwner)
git status --short --branch
gh pr view <pr-number> --json number,title,headRefName,baseRefName,author,url
gh api repos/$REPO/pulls/<pr-number>/reviews --paginate
gh api repos/$REPO/pulls/<pr-number>/comments --paginate
```

### 2. Triage Comments

Classify each active thread as:

- Actionable regression or requested change.
- Non-actionable because it is wrong, superseded, or out of scope.
- Deferred because it is real but blocked or too large for this session.

Skip resolved or outdated threads unless the user explicitly asks to revisit them.

### 3. Implement And Verify

- Inspect real code paths before editing.
- Add or update focused tests first when practical.
- Fix minimally.
- Run targeted tests immediately after each fix.
- Use browser checks only for behavior that is awkward to prove with tests.

### 4. Report Or Reply

By default, report what changed and what was verified.

If the user explicitly asks to reply or resolve, post concise public replies with evidence and resolve only threads that are fully addressed.

## Rules

- Do not silently mutate GitHub review state.
- Do not resolve partially addressed or uncertain comments.
- Do not publish speculative replies.
- Do not bundle unrelated cleanup with review-comment fixes.

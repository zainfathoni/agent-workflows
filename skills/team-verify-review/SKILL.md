---
name: team-verify-review
description: Verify whether colleague-facing PR review comments were addressed, with optional handoff to team-resolve-review when explicitly requested.
---

# Team Verify Review

Verify whether colleague-facing PR review comments have been addressed. Treat CI and deployment as supporting signals, not proof. Map each concern to changed code, targeted tests, and browser behavior when needed.

## Default Behavior

- Do not assume review comments are addressed; verify them against code and behavior.
- Do not run expensive or flaky end-to-end suites unless repository docs identify them as appropriate for this workflow or the user explicitly asks.
- Do not resolve or publicly reply to review comments unless explicitly asked.
- Do not delete or submit pending reviews.
- Prefer the smallest targeted test set that maps directly to the review concerns.
- Use browser verification when UI behavior needs evidence.

## Handoff To `team-resolve-review`

If the user explicitly asked to resolve addressed comments, and a thread is fully verified with concrete evidence, hand off only those verified threads to `team-resolve-review`.

If the user only asked to verify, report which threads are ready to resolve and stop before mutating GitHub state.

Verification-only phrases must not auto-resolve:

- `verify whether they addressed my comments`
- `test the review comments`
- `check this PR`

## Workflow

### 1. Read PR And Review State

```bash
REPO=$(gh repo view --json nameWithOwner --jq .nameWithOwner)
git status --short --branch
gh pr view <pr-number> --comments --json title,headRefName,baseRefName,reviewDecision,comments,reviews,latestReviews,statusCheckRollup,url
gh api repos/$REPO/pulls/<pr-number>/reviews --paginate
gh api repos/$REPO/pulls/<pr-number>/comments --paginate
```

### 2. Map Concerns To Evidence

For each active concern, identify:

- Changed files that implement the fix.
- Test files that assert the behavior.
- Browser scenarios that require manual verification.
- Whether the thread is `resolved-ready`, `still-open`, or `uncertain`.

### 3. Run Targeted Tests

Run the smallest useful test commands that map directly to the concerns. Use repository-specific test instructions.

### 4. Browser Verification When Needed

Use browser verification only after confirming authentication. Do not mutate shared environment data unless explicitly approved.

### 5. Report Results

```markdown
The claim is <fully supported|partially supported|not supported>.

Verified:
- <thread/concern/result/evidence>

Ready to resolve:
- <thread id or comment summary>

Still open:
- <thread id or comment summary>

Not covered:
- <gap or blocker>
```

## Rules

- Do not treat passing CI as sufficient evidence.
- Do not treat example URLs as exhaustive scope.
- Do not run expensive or flaky end-to-end suites by default.
- Do not resolve or reply unless explicitly asked.

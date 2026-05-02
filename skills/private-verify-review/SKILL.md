---
name: private-verify-review
description: Verify whether private PR review comments are addressed without publishing or deleting pending review artifacts.
---

# Private Verify Review

Verify claims that private or pending PR review comments have been addressed. Treat CI and deployment as supporting signals, not proof.

## Default Behavior

- Do not assume the claim is true.
- Do not run expensive or flaky end-to-end suites unless repository docs identify them as appropriate for this workflow or the user explicitly asks.
- Do not delete pending reviews or comments unless explicitly asked.
- Do not submit pending reviews unless explicitly asked.
- Do not create a new review as a way to reply.
- Do not resolve or publicly reply to review comments unless explicitly asked.
- Prefer the smallest targeted test set that maps directly to the review concerns.
- Use browser checks when behavior needs UI-level evidence.

## Workflow

### 1. Read PR And Review State

```bash
REPO=$(gh repo view --json nameWithOwner --jq .nameWithOwner)
git status --short --branch
gh pr view <pr-number> --comments --json title,headRefName,baseRefName,reviewDecision,comments,reviews,latestReviews,statusCheckRollup,url
gh api repos/$REPO/pulls/<pr-number>/reviews --paginate
gh api repos/$REPO/pulls/<pr-number>/comments --paginate
```

If inline pending comments are not visible through REST, use the available pending review body and any referenced commits as the source of truth. State that pending inline comments may not be visible through public comment endpoints.

### 2. Inspect Referenced Commits

Review summaries may mention commits that were squashed or replaced. Check whether each referenced commit is available:

```bash
git cat-file -t <sha>
git show --stat --oneline --find-renames <sha>
git show --stat --oneline --find-renames HEAD
```

### 3. Map Concerns To Code And Tests

For each concern, identify:

- Changed files implementing the fix.
- Tests asserting the behavior.
- Browser scenarios that need manual verification.
- Any remaining coverage gap.

Search for review keywords, helper names, UI labels, and regression phrases. Use repository-specific docs and testing commands.

### 4. Run Targeted Tests

Run the smallest useful test commands that map directly to review concerns. If the repository has a documented test runner, use it. If a required service is unavailable, state the deviation.

### 5. Verify Browser Scenarios When Needed

Use browser verification only after confirming authentication. For each scenario:

1. Navigate to the relevant page.
2. Wait for page-ready text.
3. Exercise the behavior from the review concern.
4. Confirm the expected result.
5. Check console errors and relevant network failures.

Do not mutate shared environment data unless explicitly approved.

### 6. Evaluate Coverage

Report whether the claim is fully supported, partially supported, or not supported.

Be precise:

- Passing CI is not sufficient evidence.
- Example URLs are not exhaustive scope.
- Identify concerns covered by tests.
- Identify concerns covered by browser checks.
- Identify concerns not covered and why.

### 7. Reply Only When Asked

Only reply to review or PR comments when the user explicitly asks. Keep replies factual and scoped to the specific concern.

Never submit an existing pending review to make replies visible unless the user explicitly says to submit that pending review.

## Final Response Template

```markdown
The claim is <fully supported|partially supported|not supported>.

Tested:
- <test command/result>

Browser verified:
- <scenario/result>

Not covered:
- <gap or blocker, if any>

Notes:
- <environment caveat or expected warning>
```

## Rules

- Do not run expensive or flaky end-to-end suites by default.
- Do not publish or delete review comments without explicit instruction.
- Do not treat CI as proof.
- Do not mutate shared environment data unless explicitly approved.

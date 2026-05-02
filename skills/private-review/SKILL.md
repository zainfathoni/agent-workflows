---
name: private-review
description: Create or update a private pending PR review with inline comments using GitHub API.
---

# Private Review

Create a private pending GitHub pull request review with inline comments on specific changed lines.

Use this when the user wants review notes to stay private until they explicitly submit the review.

## Default Behavior

- Always create or update a **pending** review by default.
- Do not submit the review unless the user explicitly asks for `APPROVE`, `COMMENT`, or `REQUEST_CHANGES`.
- `PENDING` is not a valid GitHub review event. To keep a review pending, omit the `event` field entirely.
- Prefer findings about correctness, regressions, security, data integrity, authorization, performance, and missing tests.
- Avoid nit-only review comments unless the user asks for style feedback.

## Workflow

### 1. Read PR Context

```bash
git status --short --branch
gh pr view <pr-number> --json number,title,headRefName,baseRefName,author,url,reviewDecision,statusCheckRollup
gh pr diff <pr-number>
```

If a narrower hunk is needed, prefer local diffing against fetched refs:

```bash
gh pr view <pr-number> --json baseRefName,headRefName
git diff --unified=20 origin/<base-ref>...origin/<head-ref> -- path/to/file
```

### 2. Inspect Relevant Code

- Read changed files and nearby call sites.
- Search for shared helpers, tests, serializers, authorization checks, data ownership boundaries, and existing patterns.
- Verify the PR's claims against implementation rather than assuming they are true.

### 3. Prepare Findings

For each finding, record:

- File path relative to repo root.
- New-file line number from the diff.
- Concrete risk.
- Why this code causes the risk.
- Focused suggestion when useful.

If no findings are found, say so and mention residual risks or testing gaps.

### 4. Create A Pending Review

Resolve the current repo once:

```bash
REPO=$(gh repo view --json nameWithOwner --jq .nameWithOwner)
```

Create a pending review by omitting `event`:

```bash
cat <<'EOF' | gh api repos/$REPO/pulls/<pr-number>/reviews --method POST --input -
{
  "body": "Review summary",
  "comments": [
    {
      "path": "path/to/file.js",
      "line": 42,
      "body": "Comment body"
    }
  ]
}
EOF
```

### 5. Revise A Pending Review Carefully

GitHub allows only one pending review per user per PR.

If you need to revise draft inline comments after creating a pending review, prefer deleting and recreating the full pending review rather than trying to stack another pending review.

```bash
REPO=$(gh repo view --json nameWithOwner --jq .nameWithOwner)
ME=$(gh api user --jq .login)
gh api repos/$REPO/pulls/<pr-number>/reviews --paginate \
  | jq --arg me "$ME" '.[] | select(.state=="PENDING" and .user.login==$me) | {id,node_id,user:.user.login}'

gh api repos/$REPO/pulls/<pr-number>/reviews/<numeric-review-id> --method DELETE
```

Then recreate the pending review with the complete updated comment set.

### 6. Submit Only On Explicit Instruction

When the user explicitly asks to submit the review, submit the existing pending review:

```bash
REPO=$(gh repo view --json nameWithOwner --jq .nameWithOwner)
cat <<'EOF' | gh api repos/$REPO/pulls/<pr-number>/reviews/<numeric-review-id>/events --method POST --input -
{
  "event": "REQUEST_CHANGES",
  "body": "Requesting changes because ..."
}
EOF
```

Allowed submission events are `COMMENT`, `APPROVE`, and `REQUEST_CHANGES`.

## Comment Guidelines

- Keep comments actionable and specific.
- Explain the bug or risk, not just the preferred code shape.
- Use inline comments only for changed lines. Use a top-level PR comment for broader feedback.
- Do not comment on unchanged lines unless a top-level comment is not sufficient.

## Safety Rules

- Never submit a pending review unless explicitly asked.
- Never use `"event": "PENDING"`.
- Never approve if unresolved correctness, security, data integrity, authorization, data-ownership, or missing-test concerns remain.
- If GitHub rejects comment line numbers, re-read the diff and correct the line mapping instead of submitting a weaker top-level review.

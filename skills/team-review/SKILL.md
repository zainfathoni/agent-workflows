---
name: team-review
description: Review a teammate's PR and prepare or submit colleague-facing review feedback.
---

# Team Review

Review a teammate's pull request for correctness, regressions, security, performance, maintainability, and missing tests.

This is a colleague-facing workflow. Comments may become visible to teammates when the user explicitly asks to publish or submit them.

## Default Behavior

- Inspect the actual diff and relevant code before commenting.
- Prioritize bugs, regressions, data integrity, authorization, data ownership, security concerns, and missing tests.
- Keep findings specific and actionable with file/line references.
- Do not submit a GitHub review unless the user explicitly asks.
- If preparing a pending review, make clear it is teammate-facing and may be submitted later.

## Workflow

### 1. Read PR Context

```bash
git status --short --branch
gh pr view <pr-number> --json number,title,headRefName,baseRefName,author,url,reviewDecision,statusCheckRollup
gh pr diff <pr-number>
```

If a narrower hunk is needed, prefer local diffing:

```bash
gh pr view <pr-number> --json baseRefName,headRefName
git diff --unified=20 origin/<base-ref>...origin/<head-ref> -- path/to/file
```

### 2. Inspect Relevant Code

- Read changed files and nearby call sites.
- Search for shared helpers, tests, API transformers, authorization checks, data ownership boundaries, and existing patterns.
- Verify claims against implementation rather than assumptions.

### 3. Produce Findings

Return findings first, ordered by severity. Include:

- File and line.
- Concrete risk.
- Why the current code causes it.
- Focused suggestion when useful.

If no findings are found, say so and mention residual risks or testing gaps.

### 4. Publish Only When Asked

When the user explicitly asks to create a GitHub review, use inline comments on changed lines where possible. Omit `event` for a draft review; use `COMMENT`, `APPROVE`, or `REQUEST_CHANGES` only when explicitly requested.

```bash
REPO=$(gh repo view --json nameWithOwner --jq .nameWithOwner)
cat <<'EOF' | gh api repos/$REPO/pulls/<pr-number>/reviews --method POST --input -
{
  "body": "Review summary",
  "comments": [
    { "path": "path/to/file.js", "line": 42, "body": "Comment body" }
  ]
}
EOF
```

## Rules

- Do not use private pending-review safety rules as a substitute for teammate-facing clarity.
- Do not submit reviews unless explicitly asked.
- Do not approve if unresolved correctness, security, data integrity, authorization, data-ownership, or missing-test concerns remain.
- Do not comment on unchanged lines unless a top-level PR comment is more appropriate.

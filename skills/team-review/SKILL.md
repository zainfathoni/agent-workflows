---
name: team-review
description: Review a teammate's PR and prepare colleague-ready feedback in a current-user PENDING review first. Use when reviewing teammate PRs, drafting inline comments, approvals, requests for changes, or team-facing review summaries.
---

# Team Review Skill

Review a teammate's pull request for correctness, regressions, security, performance, maintainability, and missing tests. This is a colleague-facing workflow; comments may become visible to teammates when the user explicitly asks to publish or submit them.

Suggested slash command: `/team-review <pr-number-or-url>`

## When to Use

- The user asks to review a teammate's PR
- The user wants public or publishable review feedback
- The user asks for inline comments, approval, request changes, or a team-facing review summary

## Default Behavior

- Inspect the actual diff and relevant code before commenting
- Prioritize bugs, regressions, data integrity, authorization, data ownership, security concerns, and missing tests
- Keep findings specific and actionable with file/line references
- Conduct an independent review first; do not let an existing current-user PENDING review steer the initial findings pass
- After independent findings are complete, use the `self-review` flow to reconcile and create or update the teammate-facing PENDING review draft
- For correctness findings, try to prove the case with a focused failing test, existing test gap, or browser/manual evidence before publishing; use the `tdd` skill's one-test-at-a-time proof discipline when feasible, but keep public comments focused on the verified behavior rather than internal process labels
- Do not submit a GitHub review unless the user explicitly asks
- If preparing a pending review, make clear it is teammate-facing and may be submitted later

## Workflow

### Step 1: Read PR Context

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

### Step 2: Inspect Relevant Code

- Read changed files and nearby call sites
- Search for shared helpers, tests, API transformers, authorization checks, and data ownership boundaries
- Verify claims against implementation rather than assumptions

### Step 3: Prove Actionable Findings

For each potential blocking finding:

- Prefer a focused test or existing test change that demonstrates the behavior fails
- If a test is impractical, use browser evidence, logs, API responses, or a code-path proof
- Remove any temporary proof-only test or instrumentation before finishing unless the user asked you to keep it
- In teammate-facing inline comments, show the concrete failing scenario and impact. For findings proven by a focused failing test, include the important setup and failing assertion as a compact test snippet the author can copy, not process labels or proof jargon. Mention temporary local-only test mechanics only if the user explicitly wants that detail published

If proof is not feasible within the review pass, say why and mark the confidence level.

### Step 4: Produce Findings

Return findings first, ordered by severity. Include:

- File and line
- The concrete risk
- Why the current code causes it
- A focused suggestion when useful

If no findings are found, say so and mention residual risks or testing gaps.

### Step 5: Draft as PENDING First

Before any teammate-visible submission, create or update a current-user **PENDING** GitHub review using the `self-review` workflow. If a current-user PENDING review already exists, reconcile it only after Steps 1-4 are complete:

- Omit `event` so the review stays pending
- Complete the independent review findings first, then fetch the existing pending review body and inline comments
- Compare independent findings against the existing pending review one comment at a time
- Keep or merge existing pending comments only when they are independently confirmed, still relevant, and teammate-ready
- Dismiss existing pending comments that are invalid, stale, duplicate, superseded, or not supported by the independent review evidence; note the reason in the final summary instead of carrying them forward
- Rewrite partially right comments so the final draft states only the verified concern and avoids over-claiming
- Replace an existing pending review with the complete reconciled comment set rather than stacking drafts
- Keep comments colleague-ready, but pending until the user explicitly asks to submit or publish them for teammate exposure
- If a comment is backed by a focused failing test, format it as: concise issue, "Minimal failing case:" with only the necessary test lines, the failing expectation/received value, then the requested fix direction

### Step 6: Submit Only When Asked

When the user explicitly asks to submit or publish a GitHub review for teammate exposure, submit the existing current-user PENDING review with `COMMENT`, `APPROVE`, or `REQUEST_CHANGES` as requested. If the user asks generally whether to request changes, recommend based on severity, then wait for confirmation unless they already gave permission to submit.

```bash
cat <<'EOF' | gh api repos/{owner}/{repo}/pulls/<pr-number>/reviews --method POST --input -
{
  "body": "Review summary",
  "comments": [
    { "path": "path/to/file.js", "line": 42, "body": "Comment body" }
  ]
}
EOF
```

## Rules

- Use self-review pending-review safety rules before teammate-facing publication, not as a substitute for teammate-facing clarity
- Do not submit reviews unless explicitly asked
- Do not approve if unresolved correctness, security, data integrity, authorization, or data-ownership concerns remain
- Do not comment on unchanged lines unless using a top-level PR comment is more appropriate

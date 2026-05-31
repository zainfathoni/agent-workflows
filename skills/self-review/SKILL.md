---
name: self-review
description: Create or update a current-user PENDING PR review with inline comments using GitHub API. Use when doing self-review, draft review notes, or any PR review that must stay unsubmitted until explicitly published.
---

# Self Review Skill

Create a self-review pending GitHub pull request review with inline comments on specific lines of code.

Suggested slash command: `/self-review <pr-number-or-url>`

## Default Behavior

- Always create or update a **PENDING** review by default.
- Conduct an independent review first; do not let an existing current-user PENDING review steer the initial findings pass.
- Reconcile any existing current-user PENDING review only after independent findings are complete.
- Do **not** submit the review unless the user explicitly instructs you to submit it as `APPROVE`, `COMMENT`, or `REQUEST_CHANGES`.
- `PENDING` is not a valid submission event. To keep a review pending, omit the `event` field entirely.

## Arguments

- `<pr-number>` - The PR number to review (required)

## Steps

1. **Get PR details and diff**

   ```bash
   gh pr view <pr-number>
   gh pr diff <pr-number>
   ```

   If you need to inspect a single changed file or a narrower hunk, prefer local git diffing against the PR base/head refs instead of passing extra path args to `gh pr diff`:

   ```bash
   gh pr view <pr-number> --json baseRefName,headRefName
   git diff --unified=20 origin/<base-ref>...origin/<head-ref> -- path/to/file.js
   ```

2. **Analyze the changes** - Review the diff for:

   - Code correctness and potential bugs
   - Style and convention issues (run ESLint if applicable)
   - Performance implications
   - Security considerations
   - Test coverage

3. **Identify specific lines to comment on independently** - For each issue found before reading any existing current-user pending review, note:

   - File path (relative to repo root)
   - Line number in the new version of the file
   - The issue/suggestion to raise

   When a finding is proven with a focused failing test, inline the important
   setup and failing assertion in the comment. Prefer a compact snippet the PR
   author can copy into the suite over process labels or proof jargon. Keep
   only the lines needed to show the scenario and the failing expectation, and
   note the received value inline when useful.

4. **Reconcile with any existing current-user pending review**

   GitHub allows only **one pending review per user per PR**. After independent findings are complete, fetch the current-user pending review, if any, and compare it with the new findings.

   ```bash
   ME=$(gh api user --jq .login)
   gh api repos/{owner}/{repo}/pulls/<pr-number>/reviews --paginate \
     | jq --arg me "$ME" '.[] | select(.state=="PENDING" and .user.login==$me) | {id,node_id,user:.user.login,body,commit_id}'
   ```

   - Keep or merge existing pending comments only when they are independently confirmed, still relevant, and useful.
   - Dismiss existing pending comments that are invalid, stale, duplicate, superseded, or unsupported by the independent review evidence; note the reason in the final summary instead of carrying them forward.
   - Rewrite partially right comments so the final draft states only the verified concern and avoids over-claiming.
   - Do not submit, delete, or replace the pending review until the complete reconciled comment set is ready.

5. **Create or replace the pending review with inline comments** using GitHub API:

   This is the default action. Unless the user explicitly asks to submit the review, omit `event` and leave the review pending. If replacing an existing pending review, use the complete reconciled comment set.

   ```bash
   # For a PENDING (draft) review - omit "event" field
   cat <<'EOF' | gh api repos/{owner}/{repo}/pulls/<pr-number>/reviews --method POST --input -
   {
     "body": "Summary of the review",
     "comments": [
       {
         "path": "path/to/file.js",
         "line": 42,
         "body": "Comment about line 42"
       },
       {
         "path": "path/to/another/file.js",
         "line": 10,
         "body": "Comment about line 10"
       }
     ]
   }
   EOF

    # Only add "event": "COMMENT", "APPROVE", or "REQUEST_CHANGES" when the user explicitly asks to submit the review
   ```

6. **Manage pending reviews carefully**

   - If no draft review exists yet, create one by omitting `event`.
   - If you need to revise the draft before submission, recreate it with the full reconciled comment set.
   - Do not assume you can append more inline comments later to the same draft review.

   Recommended workflow when reconciliation changes the pending review:

   ```bash
   # First get the REST numeric review id for the current user's pending review
   ME=$(gh api user --jq .login)
   gh api repos/{owner}/{repo}/pulls/<pr-number>/reviews --paginate \
     | jq --arg me "$ME" '.[] | select(.state=="PENDING" and .user.login==$me) | {id,node_id,user:.user.login}'

   # Delete the existing pending review by REST numeric id
   gh api repos/{owner}/{repo}/pulls/<pr-number>/reviews/<numeric-review-id> --method DELETE

   # Recreate the pending review with the complete reconciled comments array
   cat <<'EOF' | gh api repos/{owner}/{repo}/pulls/<pr-number>/reviews --method POST --input -
   {
     "body": "Updated review summary",
     "comments": [
       { "path": "path/to/file.js", "line": 42, "body": "First comment" },
       { "path": "path/to/file.js", "line": 57, "body": "Newly added comment" }
     ]
   }
   EOF
   ```

7. **Submit the pending review only on explicit user instruction**

   Once the inline comments look correct, keep the draft review pending unless the user explicitly tells you to submit it.

   When the user does explicitly instruct submission, submit the existing draft review:

   ```bash
   cat <<'EOF' | gh api repos/{owner}/{repo}/pulls/<pr-number>/reviews/<review-id>/events --method POST --input -
   {
     "event": "REQUEST_CHANGES",
     "body": "Requesting changes because ..."
   }
   EOF
   ```

## API Parameters

| Parameter         | Description                                                        |
| ----------------- | ------------------------------------------------------------------ |
| `event`           | Review action: `COMMENT`, `APPROVE`, `REQUEST_CHANGES`, or **omit for PENDING** |
| `body`            | Overall review summary (shown at top of review)                    |
| `comments`        | Array of inline comment objects                                    |
| `comments[].path` | File path relative to repo root                                    |
| `comments[].line` | Line number in the **new** version of the file (right side of diff)|
| `comments[].body` | The comment text (supports GitHub Markdown)                        |

## Comment Formatting Tips

- Use `**Bold**` for emphasis on issue type
- Use code blocks with language hints for suggested fixes
- For findings proven by a focused failing test, include a minimal failing test snippet instead of process labels or proof jargon
- Keep comments actionable and specific
- Reference documentation or style guides when relevant

## Example Comment Body

```markdown
**Functional regression:** initial URL hydration resets shared URLs with `page=3` back to page 1.

Minimal failing case:

```tsx
Object.defineProperty(window, 'location', {
  configurable: true,
  value: {
    ...originalLocation,
    search: '?q%5Bproduct_id_eq%5D=7&page=3',
    pathname: '/admin/reservations',
  },
});

render(
  <ReservationsProvider syncURL>
    <ContextViewCapture />
    <ReservationsTable settings={settings} />
  </ReservationsProvider>
);

expect(capturedContextView.page).toBe(3); // received 1
```

Please hydrate the selected view without applying the interactive pagination reset.
```

## Review Events

| Event | Description |
| ----- | ----------- |
| *(omit field)* | Creates a **PENDING** (draft) review - user can edit before submitting |
| `COMMENT` | Submit feedback without explicit approval |
| `APPROVE` | Submit as approval |
| `REQUEST_CHANGES` | Submit requesting changes before merging |

**Note:** `PENDING` is not a valid event value - to create a draft review, omit the `event` field entirely.

## Notes

- Line numbers must reference lines that exist in the diff
- For multi-line comments, use the `line` parameter for the ending line
- The `{owner}/{repo}` placeholders are auto-resolved by `gh` CLI
- GitHub rejects a second pending review on the same PR from the same user
- If you need to add or revise draft inline comments, replace the pending review instead of trying to stack another pending review
- Unless the user explicitly says to submit the review, leave it pending after posting inline comments

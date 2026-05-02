---
name: private-address-review
description: Address PR review comments with focused fixes while keeping pending review replies private by default.
---

# Private Address Review

Address pull request review comments end-to-end while preserving private pending-review safety.

Use this when the user wants to fix code based on review comments and keep review replies private unless they explicitly publish or submit them.

## Default Behavior

- Treat review comments as claims to verify, not assumptions to rubber-stamp.
- Prefer red/green TDD for each actionable regression.
- Group comments by shared root cause and fix the shared root once.
- Keep fixes narrow and localized.
- Keep existing pending reviews pending unless the user explicitly asks to submit.
- Do not commit, push, reply, resolve, delete, or submit review state unless explicitly asked.
- Do not create a new review as a way to reply to existing comments.

## Private Review Safety

Before any private reply mutation, verify both conditions in the actual review payload:

1. `pullRequestReview.state == "PENDING"`
2. `pullRequestReview.author.login == $(gh api user --jq .login)`

If either condition is false, do not use private pending-review reply APIs. Ask before posting anything public.

## Workflow

### 1. Read PR State And Review Threads

```bash
REPO=$(gh repo view --json nameWithOwner --jq .nameWithOwner)
OWNER=${REPO%/*}
NAME=${REPO#*/}
ME=$(gh api user --jq .login)

git status --short --branch
gh pr view <pr-number> --json number,title,headRefName,baseRefName,author,url
gh api repos/$REPO/pulls/<pr-number>/reviews --paginate
gh api graphql -F owner="$OWNER" -F repo="$NAME" -F number=<pr-number> -f query='query($owner:String!, $repo:String!, $number:Int!) {
  repository(owner:$owner, name:$repo) {
    pullRequest(number:$number) {
      reviewThreads(first:100) {
        nodes {
          id
          isResolved
          isOutdated
          comments(first:50) {
            nodes {
              id
              databaseId
              body
              path
              line
              state
              author { login }
              pullRequestReview { id state author { login } }
              replyTo { id databaseId author { login } body }
            }
          }
        }
      }
    }
  }
}'
```

### 2. Triage And Group Threads

When there are more than a few threads, classify before editing:

- Actionable regression or requested change.
- Non-actionable because it is wrong, superseded, or out of scope.
- Deferred because it is real but blocked or too large for this session.

Group actionable threads by shared root cause. Decide commit boundaries before editing. Skip resolved or outdated threads unless the user explicitly asks to revisit them.

### 3. Inspect Real Code Paths

- Read touched files first.
- Identify shared helpers or patterns before patching one file at a time.
- Search for existing tests and usage sites.
- Fix shared roots instead of applying ad hoc patches everywhere.

### 4. Red/Green TDD Where Practical

For each actionable group:

1. Add or update a focused failing test.
2. Run that test immediately and confirm it fails for the expected reason.
3. Fix the code minimally.
4. Re-run the same test and confirm it passes.
5. Move to the next group.

If no good test seam exists, document why and use the narrowest meaningful verification.

### 5. Browser Verification When Needed

Use browser verification for flows that are awkward to prove only through tests, such as navigation guards, modals, save/discard flows, authenticated UI state, and client-side failure paths.

Do not mutate shared environment data unless the user explicitly approves.

### 6. Regression Batch

After per-comment fixes, run the touched regression tests together plus any repository-required quality gate.

### 7. Commit And Push Only When Requested

If the user explicitly asks for commit/push:

1. Check `git status`, `git diff`, and recent commit style.
2. Stage only relevant files.
3. Create intent-focused commits.
4. Push the current branch.

### 8. Update Review Threads Only When Requested

If the user explicitly asks to update review threads, reply with short factual evidence.

For private pending review thread replies, use `addPullRequestReviewThreadReply` only after verifying the current user's pending review node id:

```bash
gh api graphql \
  -f query='mutation($review: ID!, $thread: ID!, $body: String!) {
    addPullRequestReviewThreadReply(input: {
      pullRequestReviewId: $review,
      pullRequestReviewThreadId: $thread,
      body: $body
    }) {
      comment { id }
    }
  }' \
  -f review='<pending-review-node-id>' \
  -f thread='<thread-node-id>' \
  -f body='Addressed in <commit>. <what changed>.'
```

Use GraphQL node ids, not REST numeric ids, for `pullRequestReviewId` and `pullRequestReviewThreadId`.

## Reply Templates

Fixed:

```markdown
Addressed in `<commit-sha>`.

<one or two sentences describing the exact behavior change>

Verified with:
- `<targeted test command or manual check>`
```

Not actionable:

```markdown
Not actionable: <one sentence reason>. No code change made.
```

Deferred:

```markdown
Deferred: <one sentence reason>. This needs <decision / follow-up> before a fix can land.
```

## Stop Conditions

Stop and ask when:

- A single fix would exceed the review comment's intended scope.
- The fix requires an API contract change, schema change, or cross-team alignment.
- The comment exposes a deeper architectural problem the user did not approve fixing.
- Two or more comments disagree about desired behavior.

## Checklist

- [ ] Every actionable review comment maps to a fix, non-actionable note, or deferred note.
- [ ] Focused tests were added or updated first where practical.
- [ ] Touched regression tests pass.
- [ ] Browser-only flows were checked when necessary.
- [ ] Commit/push happened only if requested.
- [ ] Pending review replies stayed private unless the user explicitly asked to publish or submit.

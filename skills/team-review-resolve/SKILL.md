---
name: team-review-resolve
description: Resolve colleague-facing PR review threads that are fully verified as addressed. Use when explicitly asked to resolve review threads; draft any new review feedback as PENDING unless explicitly submitted.
---

# Team Review Resolve Skill

Resolve teammate-visible PR review threads after they have been fully verified as addressed. This skill mutates GitHub review state, so it requires explicit user intent.

Suggested slash command: `/team-review-resolve <pr-number-or-url>`

## When to Use

- The user explicitly asks to resolve addressed review threads
- `review-verify` has classified specific threads as `resolved-ready` and the user asked to resolve them
- The user wants concise public replies before resolving fully addressed threads

## Default Behavior

- Resolve only threads with concrete verification evidence
- Do not resolve uncertain, partially addressed, outdated-without-review, or still-open concerns
- Do not delete review comments
- Do not submit or delete pending reviews
- Prefer replying with a short evidence note before resolving when the user asks for replies

## Pending-First Publication Rule

- Any new review feedback must be created or updated as a current-user **PENDING** review first
- Omit `event` when creating review drafts; `PENDING` is a state, not a submission event
- Do not submit, publish, publicly reply, or resolve for teammate exposure unless the user explicitly asks
- If the user asks for public teammate exposure, submit the existing PENDING review or post the explicitly requested public replies only after re-checking the target comments

## Workflow

### Step 1: Read Active Review Threads

```bash
REPO=$(gh repo view --json nameWithOwner --jq .nameWithOwner)
OWNER=${REPO%/*}
NAME=${REPO#*/}
gh api graphql -F owner="$OWNER" -F repo="$NAME" -F number=<pr-number> -f query='query($owner:String!, $repo:String!, $number:Int!) {
  repository(owner:$owner, name:$repo) {
    pullRequest(number:$number) {
      reviewThreads(first:100) {
        nodes {
          id
          isResolved
          isOutdated
          comments(first:20) {
            nodes { id body path line author { login } }
          }
        }
      }
    }
  }
}'
```

GitHub GraphQL queries are read-only here, but `gh api graphql` uses HTTP POST. If a smoke test or environment policy forbids all POST requests, use REST endpoints as a fallback:

```bash
REPO=$(gh repo view --json nameWithOwner --jq .nameWithOwner)
gh api repos/$REPO/pulls/<pr-number>/reviews --paginate
gh api repos/$REPO/pulls/<pr-number>/comments --paginate
```

The REST fallback can inspect review comments and replies, but it cannot reliably report exact thread resolution state or provide the thread node ids needed for `resolveReviewThread`. In that case, report the limitation and do not resolve anything.

### Step 2: Confirm Resolve Set

For each thread, confirm:

1. It is not already resolved
2. It maps to a user-approved resolve request
3. It has concrete verification evidence
4. It is not partially addressed or uncertain

If the resolve set is ambiguous, stop and ask.

### Step 3: Optional Public Reply

When asked to reply, keep it concise:

```markdown
Verified addressed in `<commit-or-branch>`.

Evidence: `<targeted test command/result>` or `<browser scenario/result>`.
```

### Step 4: Resolve Threads

Use GraphQL `resolveReviewThread` for each approved thread id:

```bash
gh api graphql \
  -f query='mutation($thread: ID!) {
    resolveReviewThread(input: { threadId: $thread }) {
      thread { id isResolved }
    }
  }' \
  -f thread='<thread-node-id>'
```

### Step 5: Verify Resolution

Re-read the thread state and report which threads were resolved and which were skipped.

## Rules

- Never resolve comments just because CI passed
- Never resolve threads that still have open behavioral, test, security, data integrity, authorization, or data-ownership concerns
- Never delete public review history as part of resolution
- Stop before mutating if the user asked only for verification

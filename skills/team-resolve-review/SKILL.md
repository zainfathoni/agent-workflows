---
name: team-resolve-review
description: Resolve colleague-facing PR review threads that are fully verified as addressed.
---

# Team Resolve Review

Resolve teammate-visible PR review threads after they have been fully verified as addressed.

This skill mutates GitHub review state, so it requires explicit user intent.

## When To Use

- The user explicitly asks to resolve addressed review threads.
- `team-verify-review` classified specific threads as `resolved-ready` and the user asked to resolve them.
- The user wants concise public replies before resolving fully addressed threads.

## Default Behavior

- Resolve only threads with concrete verification evidence.
- Do not resolve uncertain, partially addressed, outdated-without-review, or still-open concerns.
- Do not delete review comments.
- Do not submit or delete pending reviews.
- Prefer replying with a short evidence note before resolving when the user asks for replies.

## Workflow

### 1. Read Active Review Threads

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

### 2. Confirm Resolve Set

For each thread, confirm:

1. It is not already resolved.
2. It maps to a user-approved resolve request.
3. It has concrete verification evidence.
4. It is not partially addressed or uncertain.

If the resolve set is ambiguous, stop and ask.

### 3. Optional Public Reply

When asked to reply, keep it concise:

```markdown
Verified addressed in `<commit-or-branch>`.

Evidence: `<targeted test command/result>` or `<browser scenario/result>`.
```

### 4. Resolve Threads

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

### 5. Verify Resolution

Re-read the thread state and report which threads were resolved and which were skipped.

## Rules

- Never resolve comments just because CI passed.
- Never resolve threads that still have open behavioral, test, security, data integrity, authorization, or data-ownership concerns.
- Never delete public review history as part of resolution.
- Stop before mutating if the user asked only for verification.

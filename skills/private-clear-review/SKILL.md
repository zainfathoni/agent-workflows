---
name: private-clear-review
description: Clean up current-user private pending PR review artifacts only after explicit instruction.
---

# Private Clear Review

Clean up private pending PR review artifacts created by the current GitHub user.

This skill is only for private pending reviews and private pending review replies. It is not for resolving teammate-visible review threads.

## Default Behavior

- Do not delete anything unless the user explicitly asks.
- Verify the pending review belongs to the current GitHub user before deleting it.
- Never submit a pending review as part of cleanup.
- Never delete teammate-authored reviews, submitted reviews, or public comments.
- Prefer reporting what would be deleted before mutating when the request is ambiguous.

## Workflow

### 1. Read PR And Current User State

```bash
REPO=$(gh repo view --json nameWithOwner --jq .nameWithOwner)
ME=$(gh api user --jq .login)
gh pr view <pr-number> --json url
gh api repos/$REPO/pulls/<pr-number>/reviews --paginate \
  | jq --arg me "$ME" '.[] | select(.state=="PENDING" and .user.login==$me) | {id,node_id,user:.user.login,body,commit_id}'
```

### 2. Verify Ownership

Only delete a pending review when both are true:

1. `state == "PENDING"`
2. `user.login == $ME`

If no current-user pending review exists, stop and report that there is nothing private to clear.

### 3. Verify Pending Replies When Required

When the user asks to clear only after threads have resolution replies, verify coverage before deleting anything.

Fetch pending review comments and review threads:

```bash
REPO=$(gh repo view --json nameWithOwner --jq .nameWithOwner)
OWNER=${REPO%/*}
NAME=${REPO#*/}
ME=$(gh api user --jq .login)

gh api repos/$REPO/pulls/<pr-number>/reviews/<numeric-review-id>/comments --paginate \
  | jq --arg me "$ME" '[.[] | select(.user.login==$me) | {id,node_id,body,path,line,in_reply_to_id,pull_request_review_id}]'

gh api graphql \
  -F owner="$OWNER" \
  -F repo="$NAME" \
  -F number=<pr-number> \
  -f query='query($owner:String!, $repo:String!, $number:Int!) { repository(owner:$owner, name:$repo) { pullRequest(number:$number) { reviewThreads(first:100) { nodes { id isResolved path line startLine comments(first:50) { nodes { id databaseId author { login } body state createdAt replyTo { id databaseId author { login } body } } } } } } } }'
```

Only proceed when the pending review still belongs to the current user and the requested cleanup scope is unambiguous.

### 4. Delete The Intended Pending Review

Use the REST numeric review id from the reviews endpoint:

```bash
REPO=$(gh repo view --json nameWithOwner --jq .nameWithOwner)
gh api -X DELETE repos/$REPO/pulls/<pr-number>/reviews/<numeric-review-id>
```

### 5. Verify Cleanup

```bash
REPO=$(gh repo view --json nameWithOwner --jq .nameWithOwner)
ME=$(gh api user --jq .login)
gh api repos/$REPO/pulls/<pr-number>/reviews --paginate \
  | jq --arg me "$ME" '[.[] | select(.state=="PENDING" and .user.login==$me)]'
```

Report the deleted review id and confirm whether any pending reviews remain.

## Rules

- Do not delete submitted reviews.
- Do not delete public issue comments or public review comments.
- Do not resolve review threads.
- Do not submit or publish pending review content.
- Stop and ask if more than one current-user pending review-like artifact appears or ownership is unclear.

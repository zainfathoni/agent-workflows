---
name: review-clear
description: Clean up current-user PENDING PR review artifacts only after explicit instruction. Use when deleting or clearing draft review notes from self-review or team-review workflows before submission.
---

# Review Clear Skill

Clean up current-user PENDING PR review artifacts. This applies to pending drafts created by `self-review`, `team-review`, or related review workflows; it is not for resolving teammate-visible review threads.

Suggested slash command: `/review-clear <pr-number-or-url>`

## When to Use

- The user explicitly asks to delete, clear, or clean up a current-user pending review
- The user wants to remove draft review notes before switching to a team-facing workflow
- A current-user pending review was created accidentally and should not be submitted

## Default Behavior

- Do not delete anything unless the user explicitly asks
- Verify the pending review belongs to the current GitHub user before deleting it
- If the user asks to clear only after resolution, verify every current-user pending review thread has a current-user pending resolution reply before deleting
- Never submit a pending review as part of cleanup
- Never delete teammate-authored reviews, submitted reviews, or public comments
- Prefer reporting what would be deleted before mutating when the request is ambiguous

## Workflow

### Step 1: Read PR and User State

```bash
ME=$(gh api user --jq .login)
gh pr view <pr-number> --json url
gh api repos/{owner}/{repo}/pulls/<pr-number>/reviews --paginate \
  | jq --arg me "$ME" '.[] | select(.state=="PENDING" and .user.login==$me) | {id,node_id,user:.user.login,body,commit_id}'
```

### Step 2: Verify Ownership

Only delete a pending review when both are true:

1. `state == "PENDING"`
2. `author.login == $ME`

If no current-user pending review exists, stop and report that there is no current-user pending review to clear.

### Step 3: Verify Pending Thread Replies When Required

When the user asks to clear only if threads have been replied to with resolutions, verify coverage before deleting anything.

Fetch pending review comments and PR review threads:

```bash
ME=$(gh api user --jq .login)
gh api repos/{owner}/{repo}/pulls/<pr-number>/reviews/<numeric-review-id>/comments --paginate \
  | jq --arg me "$ME" '[.[] | select(.user.login==$me) | {id,node_id,body,path,line,in_reply_to_id,pull_request_review_id}]'

REPO=$(gh repo view --json nameWithOwner --jq .nameWithOwner)
gh api graphql \
  -F owner="${REPO%/*}" \
  -F repo="${REPO#*/}" \
  -F number=<pr-number> \
  -f query='query($owner:String!, $repo:String!, $number:Int!) { repository(owner:$owner, name:$repo) { pullRequest(number:$number) { reviewThreads(first:100) { nodes { id isResolved path line startLine comments(first:50) { nodes { id databaseId author { login } body state createdAt replyTo { id databaseId author { login } body } } } } pageInfo { hasNextPage endCursor } } } } }'
```

Only proceed when all are true:

1. Each original current-user pending review comment (`replyTo == null` / `in_reply_to_id == null`) has at least one current-user pending reply in the same thread.
2. Each reply clearly communicates resolution or verification, for example `Verified addressed`, `Verified not addressed`, or another explicit final status.
3. The pending review still belongs to the current GitHub user and there is exactly one current-user pending review to delete.

Stop and report missing or ambiguous replies instead of deleting. Do not submit the pending replies as part of this verification.

### Step 4: Delete the Intended Pending Review

Use the REST numeric review id from the reviews endpoint output:

```bash
gh api -X DELETE repos/{owner}/{repo}/pulls/<pr-number>/reviews/<numeric-review-id>
```

### Step 5: Verify Cleanup

```bash
ME=$(gh api user --jq .login)
gh api repos/{owner}/{repo}/pulls/<pr-number>/reviews --paginate \
  | jq --arg me "$ME" '[.[] | select(.state=="PENDING" and .user.login==$me)]'
```

Report the deleted review id and confirm whether any pending reviews remain.

## Rules

- Do not delete submitted reviews
- Do not delete public issue comments or public review comments
- Do not resolve review threads
- Do not submit or publish pending review content
- Stop and ask if more than one current-user pending review-like artifact appears or ownership is unclear

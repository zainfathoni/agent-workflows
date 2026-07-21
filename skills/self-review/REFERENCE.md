# Self Review GitHub API Reference

Read only the section needed for the current step. Commands use `{owner}/{repo}` placeholders supported by `gh api`; replace `<pr-number>` and IDs explicitly.

## Read the PR

```bash
git status --short --branch
gh pr view <pr-number> --json number,title,url,author,baseRefName,headRefName,headRefOid,reviewDecision,statusCheckRollup
gh pr diff <pr-number>
```

For focused context, fetch refs as needed and use local Git:

```bash
git diff --unified=20 origin/<base-ref>...origin/<head-ref> -- path/to/file
```

Line comments must anchor to lines represented in the PR diff. `RIGHT` means the new side; `LEFT` means the old side.

## Find the current user's draft

```bash
ME=$(gh api user --jq .login)
gh api --paginate repos/{owner}/{repo}/pulls/<pr-number>/reviews \
  | jq --arg me "$ME" '[.[] | select(.state == "PENDING" and .user.login == $me) | {id,node_id,body,commit_id,user:.user.login,state}]'
gh api --paginate repos/{owner}/{repo}/pulls/<pr-number>/comments
```

Use GraphQL when complete thread state or comment node IDs are required:

```bash
gh api graphql --paginate -f owner='{owner}' -f repo='{repo}' -F number=<pr-number> -f query='
query($owner:String!, $repo:String!, $number:Int!, $endCursor:String) {
  repository(owner:$owner, name:$repo) {
    pullRequest(number:$number) {
      reviewThreads(first:100, after:$endCursor) {
        nodes { isResolved comments(first:100) { nodes { id databaseId body path line originalLine state author { login } pullRequestReview { id databaseId state author { login } } } } }
        pageInfo { hasNextPage endCursor }
      }
    }
  }
}'
```

Filter comments by the pending review's numeric or node ID, not merely by author. Confirm zero or one current-user pending review before mutation.

## Create a new pending review

Create only when inventory proves no current-user pending review exists. Omit `event` entirely:

```bash
cat <<'EOF' | gh api repos/{owner}/{repo}/pulls/<pr-number>/reviews --method POST --input -
{
  "body": "Review summary",
  "comments": [
    {"path":"path/to/file.js", "line":42, "side":"RIGHT", "body":"Actionable comment"}
  ]
}
EOF
```

For suggestion widgets, create the shell without comments, capture `.node_id`, and add threads using the GraphQL mutation below. A ````suggestion` fenced block remains pending when its thread belongs to the pending review.

## Reconcile in place

Actual safe mechanics are **append/update/delete comments inside the existing pending review**, not delete-and-recreate. Snapshot the intended set first and preserve the review IDs throughout.

### Update the review summary

```bash
gh api repos/{owner}/{repo}/pulls/<pr-number>/reviews/<numeric-review-id> \
  --method PUT -f body='Updated pending review summary'
```

### Add a pending line-anchored thread

Use this for ordinary comments and suggestions. `startLine`/`startSide` are optional and only for multi-line anchors.

```bash
body=$(cat <<'EOF'
**Functional regression:** concise behavior and impact.

```suggestion
replacement code
```
EOF
)

gh api graphql \
  -f query='mutation($review:ID!, $path:String!, $line:Int!, $side:DiffSide!, $body:String!) { addPullRequestReviewThread(input:{pullRequestReviewId:$review,path:$path,line:$line,side:$side,body:$body}) { thread { comments(first:1) { nodes { id databaseId body pullRequestReview { databaseId state } } } } } }' \
  -f review='<pending-review-node-id>' \
  -f path='path/to/file.js' \
  -F line=42 \
  -f side='RIGHT' \
  -f body="$body"
```

Multi-line form adds `$startLine:Int!` and `$startSide:DiffSide!` variables and `startLine:$startLine,startSide:$startSide` to the input.

### Update a pending review comment

```bash
gh api graphql \
  -f query='mutation($id:ID!, $body:String!) { updatePullRequestReviewComment(input:{pullRequestReviewCommentId:$id,body:$body}) { pullRequestReviewComment { id databaseId body } } }' \
  -f id='<comment-node-id>' \
  -f body='Reconciled comment body'
```

### Delete a pending review comment, not the review

Removing a stale comment is an in-place reconciliation. First prove the comment belongs to the preserved current-user `PENDING` review.

```bash
gh api graphql \
  -f query='mutation($id:ID!) { deletePullRequestReviewComment(input:{pullRequestReviewCommentId:$id}) { clientMutationId } }' \
  -f id='<comment-node-id>'
```

If an artifact lacks a usable node ID, a mutation is rejected, or exact in-place state cannot be established, do not delete the review as a shortcut. Stop and require explicit use of `review-clear`; after it verifies and deletes the draft, rerun inventory before creating anything.

## Parameters

| Parameter | Meaning |
| --- | --- |
| `body` | Review summary or inline Markdown |
| `comments` | Inline comments included only when creating a review |
| `path` | Repository-relative changed file path |
| `line` / `side` | End line and diff side (`RIGHT` new, `LEFT` old) |
| `startLine` / `startSide` | Optional start of a multi-line diff range |
| `event` | Submission action; omit for a pending draft |
| review numeric ID | REST review identifier |
| review/comment node ID | GraphQL global identifier |

Do not send `event: PENDING`; no such review event exists. Do not use `POST /repos/{owner}/{repo}/pulls/<pr-number>/comments` for drafts.

## Comment and suggestion mechanics

- State the concrete behavior, impact, and requested direction; avoid vague preferences.
- Put a suggestion fence on an applicable changed line and include only replacement text.
- Use a language fence for illustrative code that is not directly applyable.
- For a proven regression, a compact “Minimal failing case” may include essential setup, assertion, and received value.
- Keep each comment focused on one concern; merge duplicates during reconciliation.

Example:

````markdown
**Authorization regression:** this lookup is no longer scoped to the current account, so an ID from another tenant can be updated.

Please retain the account scope:

```suggestion
const booking = await account.bookings.find(id)
```
````

## Submit only when explicitly instructed

Submission changes visibility and is outside the default self-review result. Only after an explicit event instruction, submit the existing numeric pending-review ID:

```bash
cat <<'EOF' | gh api repos/{owner}/{repo}/pulls/<pr-number>/reviews/<numeric-review-id>/events --method POST --input -
{"event":"REQUEST_CHANGES","body":"Requesting changes because …"}
EOF
```

Allowed explicit events are `COMMENT`, `APPROVE`, and `REQUEST_CHANGES`. Verify the resulting submitted state and visibility. Never submit merely to make a comment or suggestion appear.

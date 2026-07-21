# Review Clear GitHub Mechanics

Read only the section named by the active step. The safety gates and completion criteria remain authoritative in [SKILL.md](SKILL.md).

## Inventory and snapshot

Resolve identity and PR context, then fetch every REST collection with pagination:

```bash
ME=$(gh api user --jq .login)
gh pr view <pr-number> --json url

gh api repos/{owner}/{repo}/pulls/<pr-number>/reviews --paginate
gh api repos/{owner}/{repo}/pulls/<pr-number>/comments --paginate
gh api repos/{owner}/{repo}/issues/<pr-number>/comments --paginate
```

Identify current-user pending candidates by REST numeric ID while retaining the fields needed by the deletion gate:

```bash
gh api repos/{owner}/{repo}/pulls/<pr-number>/reviews --paginate \
  | jq --arg me "$ME" '.[] | select(.state=="PENDING" and .user.login==$me) | {id,node_id,user:.user.login,body,commit_id}'
```

Fetch complete thread state with GraphQL pagination. `gh api graphql --paginate` supplies `$endCursor` on subsequent requests:

```bash
REPO=$(gh repo view --json nameWithOwner --jq .nameWithOwner)
gh api graphql --paginate \
  -F owner="${REPO%/*}" \
  -F repo="${REPO#*/}" \
  -F number=<pr-number> \
  -f query='query($owner:String!, $repo:String!, $number:Int!, $endCursor:String) {
    repository(owner:$owner, name:$repo) {
      pullRequest(number:$number) {
        reviewThreads(first:100, after:$endCursor) {
          nodes {
            id isResolved isOutdated path line startLine
            comments(first:100) {
              nodes {
                id databaseId author { login } body state createdAt
                pullRequestReview { id databaseId state author { login } }
                replyTo { id databaseId author { login } body }
              }
              totalCount
              pageInfo { hasNextPage endCursor }
            }
          }
          pageInfo { hasNextPage endCursor }
        }
      }
    }
  }'
```

If any nested comment connection has another page, deletion remains ineligible until that thread is fully paginated:

```bash
gh api graphql --paginate -F thread='<thread-node-id>' -f query='query($thread:ID!, $endCursor:String) {
  node(id:$thread) {
    ... on PullRequestReviewThread {
      comments(first:100, after:$endCursor) {
        nodes {
          id databaseId author { login } body state createdAt
          pullRequestReview { id databaseId state author { login } }
          replyTo { id databaseId author { login } body }
        }
        pageInfo { hasNextPage endCursor }
      }
    }
  }
}'
```

Persist or retain normalized snapshots of submitted reviews, public review comments, issue comments, and teammate-authored thread nodes before deletion. Include stable IDs, author, state/resolution, and body so post-delete equality can be checked; exclude only artifacts owned by the candidate pending review.

## Conditional reply validation

Read candidate review comments through REST as a second view of original/reply relationships:

```bash
gh api repos/{owner}/{repo}/pulls/<pr-number>/reviews/<numeric-review-id>/comments --paginate \
  | jq --arg me "$ME" '[.[] | select(.user.login==$me) | {id,node_id,body,path,line,in_reply_to_id,pull_request_review_id}]'
```

Correlate these records with the paginated GraphQL threads from the inventory. An original has `in_reply_to_id == null` in REST or `replyTo == null` in GraphQL. Count only replies whose author is `$ME`, whose owning review is the same current-user `PENDING` candidate, and whose body states exactly one allowed final status. Validate every original candidate thread; a REST-only or GraphQL-only gap blocks deletion rather than reducing the inventory.

## Final-state verification

After deletion, rerun every REST and GraphQL inventory command above and regenerate the normalized protected-artifact snapshots. Confirm the candidate review is absent and enumerate any current-user pending review that remains:

```bash
gh api repos/{owner}/{repo}/pulls/<pr-number>/reviews --paginate \
  | jq --arg me "$ME" '[.[] | select(.state=="PENDING" and .user.login==$me) | {id,node_id,user:.user.login,body,commit_id}]'
```

Compare each submitted review, public review comment, issue comment, and teammate-authored thread against its pre-delete record by stable ID and relevant state. Report the deleted numeric review ID, the resulting pending-review array, and any protected-artifact difference.

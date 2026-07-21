# Review Address Mechanics

Load only the section linked by the current workflow step in [SKILL.md](SKILL.md).

## Read PR and Review State

```bash
git status --short --branch
gh pr view <pr-number> --comments --json number,title,headRefName,headRefOid,baseRefName,author,reviews,latestReviews,url
gh api repos/{owner}/{repo}/pulls/<pr-number>/reviews --paginate
gh api repos/{owner}/{repo}/pulls/<pr-number>/comments --paginate
ME=$(gh api user --jq .login)
```

Read thread identity, resolution, outdated state, author, and owning review:

```bash
gh api graphql --paginate -F owner='<owner>' -F repo='<repo>' -F number=<pr-number> -f query='query($owner:String!, $repo:String!, $number:Int!, $endCursor:String) {
  repository(owner:$owner, name:$repo) {
    pullRequest(number:$number) {
      reviewThreads(first:100, after:$endCursor) {
        nodes {
          id isResolved isOutdated
          comments(first:100) {
            nodes {
              id body path line originalLine author { login }
              pullRequestReview { id state author { login } }
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

If any nested `comments.pageInfo.hasNextPage` is true, paginate that thread before claiming complete inventory:

```bash
gh api graphql --paginate -F thread='<thread-node-id>' -f query='query($thread:ID!, $endCursor:String) {
  node(id:$thread) {
    ... on PullRequestReviewThread {
      comments(first:100, after:$endCursor) {
        nodes { id body path line originalLine author { login } pullRequestReview { id state author { login } } }
        pageInfo { hasNextPage endCursor }
      }
    }
  }
}'
```

List the current user’s pending review node IDs:

```bash
gh api graphql --paginate -F owner='<owner>' -F repo='<repo>' -F number=<pr-number> -f query='query($owner:String!, $repo:String!, $number:Int!, $endCursor:String) {
  repository(owner:$owner, name:$repo) {
    pullRequest(number:$number) {
      reviews(first:100, after:$endCursor, states:PENDING) {
        nodes { id state author { login } }
        pageInfo { hasNextPage endCursor }
      }
    }
  }
}' | jq --arg me "$ME" '.data.repository.pullRequest.reviews.nodes[] | select(.author.login == $me)'
```

## Targeted Verification

Use the repository’s own runner and narrowest useful path or filter:

```bash
<backend-test-runner> <test-path-or-filter>
<frontend-test-runner> <test-path-or-filter>
```

Capture the exact command, exit status, and relevant assertion. For browser verification, record environment, scenario, expected result, actual result, console/network observations, and cleanup result.

## Reply Templates

Use these shapes when writing the matching reply branch; replace every placeholder and keep the evidence factual.

Fixed:

```markdown
<one or two sentences describing the exact behavior change>

<optional: Addressed in `<commit-sha>` when a commit was explicitly requested and created.>

Verified with:
- `<targeted test command or file>`
```

Not actionable:

```markdown
Not actionable: <one sentence reason>. Closing without code change.
```

Deferred:

```markdown
Deferred: <one sentence reason>. Tracked in <ticket / follow-up note>; not addressed in this PR.
```

## Review Mutation API

Reply inside a pending review thread using GraphQL node IDs:

```bash
gh api graphql \
  -f query='mutation($review:ID!, $thread:ID!, $body:String!) {
    addPullRequestReviewThreadReply(input:{
      pullRequestReviewId:$review,
      pullRequestReviewThreadId:$thread,
      body:$body
    }) { comment { id body } }
  }' \
  -f review='<pending-review-node-id>' \
  -f thread='<thread-node-id>' \
  -f body='<reply-body>'
```

Reply to a public review comment using its REST numeric comment ID:

```bash
gh api repos/{owner}/{repo}/pulls/<pr-number>/comments/<comment-id>/replies \
  -f body='<reply-body>'
```

Resolve a GraphQL review thread using its node ID:

```bash
gh api graphql \
  -f query='mutation($thread:ID!) {
    resolveReviewThread(input:{threadId:$thread}) { thread { id isResolved } }
  }' \
  -f thread='<thread-node-id>'
```

Query the affected review or thread again after a mutation to capture its resulting state.

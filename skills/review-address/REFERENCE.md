# Review Address Reference

## Read PR State

```bash
git status --short --branch
gh pr view <pr-number> --json number,title,headRefName,baseRefName,author,url
gh api repos/{owner}/{repo}/pulls/<pr-number>/reviews --paginate
gh api repos/{owner}/{repo}/pulls/<pr-number>/comments --paginate
REPO=$(gh repo view --json nameWithOwner --jq .nameWithOwner)
OWNER=${REPO%/*}
NAME=${REPO#*/}
gh api graphql -F owner="$OWNER" -F repo="$NAME" -F number=<pr-number> -f query='query($owner:String!, $repo:String!, $number:Int!) {
  repository(owner:$owner, name:$repo) {
    pullRequest(number:$number) {
      reviewThreads(first: 100) {
        nodes {
          id
          isResolved
          isOutdated
          comments(first: 20) {
            nodes {
              id
              body
              path
              line
              state
              author { login }
              pullRequestReview { id state author { login } }
            }
          }
        }
      }
    }
  }
}'
```

## Verify Current-User Pending Review Ownership

```bash
ME=$(gh api user --jq .login)
gh api graphql -f query='query { repository(owner:"<owner>", name:"<repo>") { pullRequest(number:<n>) { reviews(first:10, states:PENDING) { nodes { id author { login } } } } } }'   | jq --arg me "$ME" '.data.repository.pullRequest.reviews.nodes[] | select(.author.login == $me) | .id'
```

If this returns no node id, do not use `addPullRequestReviewThreadReply`.

## Pending Review Reply Mutation

```bash
gh api graphql   -f query='mutation($review: ID!, $thread: ID!, $body: String!) {
    addPullRequestReviewThreadReply(input: {
      pullRequestReviewId: $review,
      pullRequestReviewThreadId: $thread,
      body: $body
    }) {
      comment { id }
    }
  }'   -f review='<pending-review-node-id>'   -f thread='<thread-node-id>'   -f body='Addressed in <commit>. <what changed>.'
```

`<pending-review-node-id>` is the GraphQL `pullRequestReview.id` node id, not the REST numeric review id. `<thread-node-id>` is `reviewThreads.nodes[].id` from GraphQL.

## Test Commands

Run the smallest test set that maps to the review concern, using the project's
own runner. Examples:

```bash
# Backend unit/functional test scoped to a file or line
<test-runner> <path/to/test_file>[:<line>]

# Frontend test scoped to a single suite, run serially
<frontend-test-runner> <path/to/component.test.jsx> --runInBand
```

## Reply Templates

Fixed:

```markdown
Addressed in `<commit-sha>`.

<one or two sentences describing the exact behavior change>

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

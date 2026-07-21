# Review Verify Mechanics

Load only the section linked by the current step in [SKILL.md](SKILL.md).

## Read PR and Review State

```bash
git status --short --branch
gh pr view <pr-number> --comments --json title,headRefName,headRefOid,baseRefName,reviewDecision,comments,reviews,latestReviews,statusCheckRollup,url
gh api repos/{owner}/{repo}/pulls/<pr-number>/reviews --paginate
gh api repos/{owner}/{repo}/pulls/<pr-number>/comments --paginate
```

Find the current user's pending reviews:

```bash
ME=$(gh api user --jq .login)
gh api repos/{owner}/{repo}/pulls/<pr-number>/reviews --paginate \
  | jq --arg me "$ME" '.[] | select(.state=="PENDING" and .user.login==$me) | {id,node_id,user:.user.login,body,commit_id}'
```

Read thread resolution and outdated state:

```bash
gh api graphql --paginate -F owner='<owner>' -F repo='<repo>' -F number=<pr-number> -f query='query($owner:String!, $repo:String!, $number:Int!, $endCursor:String) {
  repository(owner:$owner, name:$repo) {
    pullRequest(number:$number) {
      reviewThreads(first:100, after:$endCursor) {
        nodes {
          id isResolved isOutdated
          comments(first:100) {
            nodes { id body path line originalLine commit { oid } author { login } }
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

If a nested comment connection has another page, paginate that thread before classifying its concern:

```bash
gh api graphql --paginate -F thread='<thread-node-id>' -f query='query($thread:ID!, $endCursor:String) {
  node(id:$thread) {
    ... on PullRequestReviewThread {
      comments(first:100, after:$endCursor) {
        nodes { id body path line originalLine commit { oid } author { login } }
        pageInfo { hasNextPage endCursor }
      }
    }
  }
}'
```

REST review bodies can reveal summary-only concerns. GraphQL supplies active thread identity and resolution state; record a gap if access prevents a complete inventory.

Inspect current and referenced commits:

```bash
git cat-file -t <sha>
git show --stat --oneline --find-renames <sha>
git show --find-renames <sha> -- <relevant-paths>
git diff --find-renames <base>...<current-pr-head-sha> -- <relevant-paths>
```

## Targeted Tests

Discover the repository's test instructions and use its own runner. Select the narrowest test file or filter that exercises the mapped concern:

```bash
<frontend-test-runner> <test-path-or-filter>
<backend-test-runner> <test-path-or-filter>
```

Capture the exact command, exit result, and relevant assertions. If execution is blocked, inspect mapped tests and record the blocker separately from their expected coverage.

## Browser Verification

Use Chrome DevTools only after confirming authentication. Saving real staging data requires explicit user approval; otherwise use reversible interactions and safe test data.

1. Confirm the target environment, authenticated identity, and safe test data.
2. Navigate to the mapped page and wait for a stable page-ready signal.
3. Reproduce the smallest scenario that distinguishes fixed from unfixed behavior.
4. Observe the UI result plus relevant console and network activity.
5. Restore or discard temporary state and verify the cleanup.
6. Record environment, scenario, expected result, actual result, and any blocker.

## Report Shape

```markdown
## Verification

Overall: <fully supported | partially supported | not supported | uncertain>

### <source / stable identifier> — <status>
- Concern: <exact concern>
- Visibility: <current-user-pending | teammate-visible | ambiguous>
- Code: <paths/lines or no-mapping explanation>
- Tests: <command and result, inspected coverage, or limitation>
- Browser: <scenario/result, unnecessary, or blocked>
- Gap: <remaining gap or none>

## Ready to resolve
- <derived eligible public thread identifiers, or none>

## Follow-up
- <explicit requested next action and skill, or verification only>
```

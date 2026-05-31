# Review Verify Reference

## Read PR and Review State

```bash
git status --short --branch
gh pr view <pr-number> --comments --json title,headRefName,baseRefName,reviewDecision,comments,reviews,latestReviews,statusCheckRollup,url
gh api repos/{owner}/{repo}/pulls/<pr-number>/reviews --paginate
gh api repos/{owner}/{repo}/pulls/<pr-number>/comments --paginate
```

To find current-user pending reviews explicitly:

```bash
ME=$(gh api user --jq .login)
gh api repos/{owner}/{repo}/pulls/<pr-number>/reviews --paginate   | jq --arg me "$ME" '.[] | select(.state=="PENDING" and .user.login==$me) | {id,node_id,user:.user.login,body,commit_id}'
```

## Inspect Referenced Commits

```bash
git cat-file -t <sha>
git show --stat --oneline --find-renames <sha>
git show --stat --oneline --find-renames <current-pr-head-sha>
```

Use commit stats and changed files to expand the verification scope beyond URLs supplied by the user.

## Targeted Tests

Use the project's own test runner, scoped to the concern. Examples:

```bash
<frontend-test-runner> <test_paths> --runInBand
<backend-test-runner> <test_file>
```

Prefer the smallest test set that maps directly to the review concern. Do not run end-to-end/browser-automation suites unless the user explicitly overrides this default.

## Browser Verification

Use Chrome DevTools only after confirming authentication. Do not save real staging data unless the user explicitly approves.

1. Navigate to the authenticated staging page
2. Wait for page-ready text
3. Make only reversible, non-persisting changes where possible
4. Verify the behavior tied to the review concern
5. Discard/reset changes before leaving
6. Check console warnings/errors and relevant network failures

## Final Response Template

```markdown
The claim is <fully supported|partially supported|not supported>.

Verified:
- <thread/concern/result/evidence>

Ready to resolve:
- <teammate-visible thread id or summary, if any>

Still open:
- <thread/concern/evidence>

Not covered:
- <gap or blocker>
```

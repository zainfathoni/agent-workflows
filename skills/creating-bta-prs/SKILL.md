---
name: creating-bta-prs
description: Prepares focused BookThatApp branches and pull requests. Use when asked to turn an existing BTA issue worktree into a GitHub PR.
---

# Creating BTA PRs

## Workflow

### 1. Establish the target and requested outcome

Use the repository/worktree named by the user, or the current workspace when none was named. Anchor every Git command there with `git -C` so inspection and changes stay isolated from sibling worktrees.

```bash
repo=/path/to/issue-worktree
git -C "$repo" rev-parse --show-toplevel
old_branch=$(git -C "$repo" branch --show-current)
git -C "$repo" status --short --branch
```

Confirm that the resolved root is the intended worktree, the current branch is the issue branch, and unrelated changes can remain untouched. Treat push and PR creation as authorized only when the user explicitly requested them; otherwise prepare only the requested local state. Stop before making changes when the target or issue branch is wrong, or when intended changes cannot be isolated safely.

**Complete when:** the absolute target root, current branch, full status, intended paths, and whether push/PR creation is authorized are recorded.

### 2. Discover and apply the branch convention

Inspect actual local and remote names rather than relying on memory:

```bash
git -C "$repo" branch --list
git -C "$repo" branch --list --remotes
```

Derive a concise name from that evidence. Preserve a user-specified prefix, place the issue identifier where comparable branches place it, and use a specific short slug, for example `bugfix/trello-962/safari-back-links`.

Check the exact candidate locally and remotely before renaming:

```bash
new_branch=bugfix/TICKET/short-slug
git -C "$repo" branch --list "$new_branch"
git -C "$repo" branch --list --remotes "*/$new_branch"
```

An existing local or remote match is a hard collision: stop and ask before selecting an alternative. With no collision, rename only the checked-out branch and inspect its state:

```bash
git -C "$repo" branch -m "$new_branch"
git -C "$repo" branch --show-current
git -C "$repo" status --short --branch
```

**Complete when:** branch listings demonstrate the convention, collision checks are empty, and `branch --show-current` returns the chosen new name (or the collision is reported without a rename).

### 3. Stage and commit only the intended change

Review the worktree before staging:

```bash
git -C "$repo" status --short
git -C "$repo" diff --stat
git -C "$repo" diff --check
```

Resolve whitespace errors in touched files or report them as a blocker. Keep unrelated changes unstaged and intact. Stage explicit intended paths, then inspect the complete staged state:

```bash
git -C "$repo" add path/to/intended-file path/to/other-file
git -C "$repo" diff --cached --stat
git -C "$repo" diff --cached --check
git -C "$repo" status --short
```

Commit with a focused message only when the index contains the intended change. If the appropriate commit already exists, retain it instead of creating an empty or duplicate commit. Verify either outcome:

```bash
git -C "$repo" commit -m "Fix Safari back link handling"
git -C "$repo" log --oneline --decorate -5
```

**Complete when:** the intended diff passes `diff --check`, every staged path is in scope, unrelated changes remain unstaged, and the intended commit is identified by hash and summary without an empty or duplicate commit.

### 4. Discover GitHub metadata and prepare the PR body

When PR creation is authorized, query the target repository for its identity and default branch; use that default as the PR base rather than a hard-coded branch:

```bash
repo_nwo=$(cd "$repo" && gh repo view --json nameWithOwner --jq '.nameWithOwner')
default_branch=$(cd "$repo" && gh repo view --json defaultBranchRef --jq '.defaultBranchRef.name')
template="$repo/.github/pull_request_template.md"
```

Use `.github/pull_request_template.md` when present. If it is absent, report that fact and use the best available repository convention only when the user still wants the PR. Create a temporary body file with cleanup installed immediately, preserve template headings when present, and fill only known facts:

```bash
pr_body=$(mktemp)
trap 'rm -f "$pr_body"' EXIT
if test -f "$template"; then
  cp "$template" "$pr_body"
else
  # Write the user-approved repository-convention fallback to "$pr_body".
  : > "$pr_body"
fi
$EDITOR "$pr_body"
```

A heredoc may fill the body when no editor is available. Record tests exactly as run, including failures and skipped checks; claim a pass only for a check that ran and passed.

**Complete when:** for an authorized PR, repository identity and default base came from GitHub, the body follows the repository template or a reported fallback, test statements match observed results, and temporary-file cleanup is active; otherwise the PR preparation branch is recorded as skipped.

### 5. Push and create the PR when authorized

Recheck status and proceed only with the explicit push/PR authorization established in step 1:

```bash
git -C "$repo" status --short --branch
git -C "$repo" push -u origin "$new_branch"
pr_url=$(gh pr create \
  --repo "$repo_nwo" \
  --base "$default_branch" \
  --head "$new_branch" \
  --title "Fix Safari back link handling" \
  --body-file "$pr_body")
```

Capture the command result, and remove the temporary body file after the attempt; the trap provides cleanup on failure as well.

```bash
rm -f "$pr_body"
trap - EXIT
```

**Complete when:** for an authorized PR, the branch has an upstream push result, `gh pr create` has returned a URL or a recorded error, and the temporary body file no longer exists; otherwise no remote mutation occurred.

### 6. Apply standard BTA PR ownership and contextual metadata

Treat assignment and issue-type labeling as part of authorized BTA PR creation,
not as optional follow-up. Resolve the authenticated GitHub login and assign the
PR to that user. Select the issue-type label from the PR's actual context:
`bug`, `feature`, or `chore`. Prefer an explicit user or issue-tracker
classification, then consistent branch/title evidence. Do not default to `bug`;
ask when the classification is absent, conflicting, or ambiguous.

```bash
github_login=$(gh api user --jq '.login')
: "${pr_label:?set pr_label to the established bug, feature, or chore classification}"
gh pr edit "$pr_url" \
  --repo "$repo_nwo" \
  --add-assignee "$github_login" \
  --add-label "$pr_label"
```

Verify GitHub's resulting state directly:

```bash
gh pr view "$pr_url" \
  --repo "$repo_nwo" \
  --json assignees,labels,url \
  --jq '{url, assignees: [.assignees[].login], labels: [.labels[].name]}'
```

Do not silently omit a failed assignment or missing label. Report the exact
partial state and error. Follow an explicit user instruction when they name a
different assignee or label.

**Complete when:** the authenticated user is an assignee and the established
`bug`, `feature`, or `chore` label is present, or the exact metadata blocker and
partial state are reported.

### 7. Trigger missing stacked-PR CI only when authorized

After creating a stacked PR, inspect its exact head, base, draft state, reviews,
and check rollup. Do not infer that CI cannot run merely because the workflow's
`pull_request.branches` filter names the default branch while the PR currently
targets another stack branch. In this repository, a `ready_for_review` event can
start the Tests workflow for that stacked PR.

```bash
gh pr view "$pr_url" \
  --repo "$repo_nwo" \
  --json state,isDraft,headRefName,headRefOid,baseRefName,reviews,reviewRequests,statusCheckRollup
```

If checks are absent and the user explicitly authorized triggering CI, first
require an OPEN, non-draft PR at the expected head and base. Inspect existing
reviews and review requests because changing draft state can disrupt active
review. Stop and ask before toggling a PR that already has approval or active
review state. For a new unreviewed PR, convert it to draft and immediately back
to ready:

```bash
gh pr ready "$pr_url" --repo "$repo_nwo" --undo
gh pr ready "$pr_url" --repo "$repo_nwo"
```

Treat the two commands as one bounded operation: if the draft conversion
succeeds but restoring ready state fails, report and repair that partial state
before doing anything else. Then verify that the PR is ready again, its head and
base are unchanged, and an exact-head Tests run or check rollup appeared. Do not
rerun workflows or repeat the toggle blindly when no run appears; diagnose the
observed event/workflow state instead.

**Complete when:** CI triggering was not requested or was unnecessary because
checks already existed; or the explicitly authorized draft/ready toggle restored
the PR to ready at the unchanged head/base and the resulting exact-head CI run
was verified; or the exact partial-state/blocker was reported.

### 8. Request external review only after explicit approval

Do not request review from `unrooty` during PR creation by default. The owner may
need to complete a self-review first. Wait for an explicit instruction to
request the review for this PR; an instruction for an earlier PR does not carry
forward.

After that explicit go-ahead:

```bash
gh pr edit "$pr_url" --repo "$repo_nwo" --add-reviewer unrooty
gh pr view "$pr_url" \
  --repo "$repo_nwo" \
  --json reviewRequests,url \
  --jq '{url, reviewRequests: [.reviewRequests[].login]}'
```

Report a failed request or unexpected reviewer state instead of claiming the PR
is awaiting review.

**Complete when:** review was intentionally left unrequested for self-review, or
an explicitly authorized request is verified with `unrooty` in requested
reviewers.

### 9. Verify and report evidence

Inspect the final local state and, when a PR was created, query GitHub rather than relying only on command output:

```bash
git -C "$repo" status --short --branch
git -C "$repo" branch --show-current
git -C "$repo" log -1 --format='%H %s'
gh pr view --repo "$repo_nwo" --json url,baseRefName,headRefName,title
```

Report the old and new branch names; commit hash and summary (or why no commit was created); push result and upstream; PR URL, base, and head; every verification command and result; and any blocker, missing template, skipped check, or unrelated dirty file left untouched.

For a created PR, include the verified assignee and contextual label from step
6, plus whether external review was intentionally deferred or explicitly
requested under step 8. When step 7 applied, include the restored ready state,
unchanged head/base, and exact-head CI run URL.

**Complete when:** the final report contains checkable branch and commit evidence, PR and metadata evidence when created, honest test results, and every remaining concern.

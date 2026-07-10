---
name: creating-bta-prs
description: Renames BookThatApp issue worktree branches to the user's existing BTA branch convention, commits and pushes focused changes, and creates GitHub PRs from the repository template. Use when asked to prepare a BTA worktree branch and open a PR.
---

# Creating BTA PRs

Prepare an existing BookThatApp issue worktree for review by matching the user's BTA branch naming convention, committing only the intended changes, pushing the renamed branch, and creating a GitHub PR from the repository's PR template.

## When to use

- The user asks to rename a BookThatApp issue/worktree branch before opening a PR.
- The user asks to follow existing branch names such as `bugfix/...`, `feature/...`, or another local convention.
- The user explicitly asks to commit, push, and create a PR using `.github/pull_request_template.md`.

This is not a general Git tutorial. Keep the workflow focused on the current worktree, branch naming, a focused commit, and PR creation.

## Safety rules

- Work only in the target repository/worktree the user named or the current workspace. Do not modify sibling worktrees while inspecting branch conventions.
- Inspect existing branch names before choosing the new name. Do not invent a convention from memory.
- Check status before staging, committing, renaming, pushing, or creating the PR.
- Do not discard, overwrite, or silently include unrelated changes. If unrelated changes exist, leave them alone and report the blocker or stage only the intended paths.
- Only push or create a PR when the user explicitly asked for it.
- Use the repository's default branch as the PR base, not a hard-coded `main` or `master`.
- Use the repository's PR template when it exists. If it is missing, report that honestly and create the body from the best available repo convention only if the user still wants the PR.
- Clean up temporary PR body files after `gh pr create`, even when PR creation fails.

## Workflow

### 1. Confirm the target worktree and current state

Use `git -C` when the target repo is not the current working directory so commands cannot drift into another worktree:

```bash
repo=/path/to/issue-worktree
git -C "$repo" rev-parse --show-toplevel
git -C "$repo" status --short --branch
git -C "$repo" branch --show-current
```

Stop before changing anything if:

- The command is not running in the intended repository.
- The current branch is not the issue branch the user wants prepared.
- Status contains unrelated changes that cannot be excluded safely.

### 2. Inspect branch naming conventions

List local branches, and include remote branches when useful for convention discovery:

```bash
git -C "$repo" branch --list
git -C "$repo" branch --list --remotes
```

Choose a new branch name that follows the user's existing pattern. Prefer names that keep the issue identifier and describe the fix briefly, for example:

```text
bugfix/trello-962/safari-back-links
```

Decision points:

- If the user specifies a prefix such as `bugfix/`, keep it.
- If existing branches include ticket IDs, keep the issue ID in the same position.
- Use a short slug for the specific change; avoid broad names like `fixes` or `updates`.
- If a local or remote branch with the target name already exists, stop and ask before choosing an alternate.

Check for collisions before renaming:

```bash
new_branch=bugfix/TICKET/short-slug
git -C "$repo" branch --list "$new_branch"
git -C "$repo" branch --list --remotes "*/$new_branch"
```

Rename only the current branch:

```bash
git -C "$repo" branch -m "$new_branch"
git -C "$repo" status --short --branch
```

### 3. Verify and commit focused changes

Review the diff before staging:

```bash
git -C "$repo" status --short
git -C "$repo" diff --stat
git -C "$repo" diff --check
```

Use `git diff --check` to catch whitespace errors before committing. If it fails, fix the reported touched-file issues or report the blocker; do not ignore it to force a commit.

Stage only the intended files:

```bash
git -C "$repo" add path/to/intended-file path/to/other-file
git -C "$repo" diff --cached --stat
git -C "$repo" diff --cached --check
git -C "$repo" status --short
```

Commit with a focused message that describes the actual change:

```bash
git -C "$repo" commit -m "Fix Safari back link handling"
```

If there is already an appropriate commit, do not create an empty or duplicate commit. Verify the branch contains the intended commit instead:

```bash
git -C "$repo" log --oneline --decorate -5
```

### 4. Discover the default branch and PR template

Use GitHub metadata for the base branch:

```bash
repo_nwo=$(cd "$repo" && gh repo view --json nameWithOwner --jq '.nameWithOwner')
default_branch=$(cd "$repo" && gh repo view --json defaultBranchRef --jq '.defaultBranchRef.name')
```

Use `.github/pull_request_template.md` from the target repo when it exists:

```bash
template="$repo/.github/pull_request_template.md"
test -f "$template"
```

Build the PR body from a temporary copy of the template, filling only what is known. Include verification results and blockers honestly; do not claim checks passed unless they ran and passed.

```bash
pr_body=$(mktemp)
cp "$template" "$pr_body"
$EDITOR "$pr_body"
```

If no editor is available, write the body with a heredoc while preserving the template's headings.

### 5. Push and create the PR

Only do this when explicitly requested by the user.

Push the renamed branch and set upstream:

```bash
git -C "$repo" push -u origin "$new_branch"
```

Create the PR with the default branch as base, the renamed branch as head, and the template-derived body:

```bash
gh pr create \
  --repo "$repo_nwo" \
  --base "$default_branch" \
  --head "$new_branch" \
  --title "Fix Safari back link handling" \
  --body-file "$pr_body"
```

Always remove the temporary body file:

```bash
rm -f "$pr_body"
```

Prefer a shell `trap` while creating the body so cleanup happens on failure:

```bash
pr_body=$(mktemp)
trap 'rm -f "$pr_body"' EXIT
cp "$template" "$pr_body"
# fill template, then gh pr create --body-file "$pr_body"
```

### 6. Final verification and report

After creating the PR, verify the branch and PR state:

```bash
git -C "$repo" status --short --branch
gh pr view --repo "$repo_nwo" --json url,baseRefName,headRefName,title
```

Report:

- Old branch name and new branch name.
- Commit hash and summary, or why no new commit was created.
- Push result and upstream branch.
- PR URL, base branch, and head branch.
- Verification run, including `git diff --check` and any repo-specific checks.
- Any blockers, missing template sections, skipped checks, or unrelated dirty files left untouched.

## Example command sequence

```bash
repo=/Users/zain/Code/GitHub/book-that-app/bta-trello-962
old_branch=$(git -C "$repo" branch --show-current)
git -C "$repo" status --short --branch
git -C "$repo" branch --list

new_branch=bugfix/trello-962/safari-back-links
git -C "$repo" branch --list "$new_branch"
git -C "$repo" branch --list --remotes "*/$new_branch"
git -C "$repo" branch -m "$new_branch"

git -C "$repo" diff --check
git -C "$repo" add path/to/focused-change
git -C "$repo" diff --cached --check
git -C "$repo" commit -m "Fix Safari back link handling"

repo_nwo=$(cd "$repo" && gh repo view --json nameWithOwner --jq '.nameWithOwner')
default_branch=$(cd "$repo" && gh repo view --json defaultBranchRef --jq '.defaultBranchRef.name')
pr_body=$(mktemp)
trap 'rm -f "$pr_body"' EXIT
cp "$repo/.github/pull_request_template.md" "$pr_body"
# Fill the template honestly, including verification and blockers.

git -C "$repo" push -u origin "$new_branch"
gh pr create --repo "$repo_nwo" --base "$default_branch" --head "$new_branch" --body-file "$pr_body"

git -C "$repo" status --short --branch
```

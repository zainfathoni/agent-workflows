---
name: squash-commits
description: Commit multiple related changes into a single commit with a descriptive message.
---

# Git Squash Commits Skill

Analyze commits on the current branch and prepare a rebase guide document for manual interactive rebase.

## Steps

1. **Get commits on current branch** (use 10-char hashes for git compatibility)

   ```bash
   git log master..HEAD --format="%h %s" --reverse
   ```

2. **Analyze and group commits** by identifying:

   - Feature implementation commits that belong together
   - Related bug fixes that should be squashed with their feature
   - Test commits that can be grouped (unit tests, E2E tests, etc.)
   - Refactoring commits that are part of the same effort
   - Infrastructure/config changes that support the main feature

   **⚠️ CRITICAL: Maintain chronological order**

   - **NEVER reorder commits** in the rebase script - keep them in their original chronological order
   - Reordering commits causes merge conflicts and breaks the rebase
   - **Groups must be formed from CONTIGUOUS commits only** - you cannot group commits 1, 3, 5 together if commits 2 and 4 exist between them
   - If related commits are scattered throughout history, either:
     - Squash ALL commits between them into one group (include the unrelated commits), OR
     - Keep them as separate groups (don't try to group non-contiguous commits)
   - The `--reverse` flag in `git log` gives oldest-first order - preserve this EXACT order in the rebase script
   - **Verification**: After creating the rebase script, verify that commit hashes appear in the same order as `git log --reverse` output

3. **Create the rebase guide document**

   - Location: `docs/rebases/{ticket-id}/YYYY-MM-DD.md`
   - Extract ticket ID from branch name (e.g., `sc-61299` from `feature/sc-61299/...`)
   - Use current date for filename
   - **Multiple squashes same day**: If `YYYY-MM-DD.md` already exists, append `-1`, `-2`, etc.
     - First file: `2026-01-08.md`
     - Second file: `2026-01-08-1.md`
     - Third file: `2026-01-08-2.md`

4. **Document structure**:

   ````markdown
   # Squash Guide for {ticket-id}

   Branch: `{branch-name}`
   Total commits: X → Suggested: Y squashed commits

   ## Instructions

   Run `git rebase -i master`, then replace the content with:

   ```txt

   # Group 1: {Group Description}

   pick {hash} {message}
   s {hash} {message}
   ...

   ```

   ## Suggested Commit Messages

   ### Group 1 ({N} commits)

   > First commit: "{first commit message}..."

   ```txt

   {Type}: {Short summary}

   {Detailed description of what this group of commits accomplishes}

   Changes:

   - {Bullet point of specific change}
   - {Bullet point of specific change}

   ```
   ````

## Group Header Guidelines

Each group's commit message section should include hints to help identify position during rebase:

- **Commit count**: Number of commits in the group (e.g., "4 commits")
- **First commit**: The original first commit message of the group as a blockquote

This helps the user verify they're applying the correct commit message during interactive rebase.

## Commit Message Guidelines

Each squashed commit message should include:

- **Type prefix**: Feature, Fix, Test, E2E, Refactor, Chore, Docs
- **Short summary**: One line describing the change (50 chars or less)
- **Detailed description**: Paragraph explaining the purpose and context
- **Changes list**: Bullet points of specific files/components affected

## Example Output

See `docs/rebases/sc-61299/2026-01-07.md` for a real example.

## Backup, Automate, and Push

After creating the squash guide, perform these steps:

1. **Create backup branch** (local only) before rebasing:

   ```bash
   git branch backup/{original-branch-name}-before-rebase-{rebase-identifier}
   ```

   - `{original-branch-name}`: The current branch name (e.g., `feature/short-name`)
   - `{rebase-identifier}`: Matches the squash guide filename (e.g., `2026-01-08-1`)

   Example:
   ```bash
   git branch backup/feature/short-name-before-rebase-2026-01-08-1
   ```

2. **If the goal is one squashed commit for the entire branch**, automate the interactive rebase with `sed`:

   ```bash
   GIT_SEQUENCE_EDITOR='sed -i "" -e "2,$s/^pick /s /"' \
   GIT_EDITOR=true \
   git rebase -i master
   ```

   - Only use this shortcut when every commit in `master..HEAD` should become a single commit
   - This preserves chronological order and only changes later `pick` lines to `s`
   - `GIT_EDITOR=true` accepts Git's default combined squash message so it can be replaced immediately afterward

3. **After the automated rebase**, amend the resulting commit message using the guide's suggested text:

   ```bash
   git commit --amend
   ```

   Paste the prepared commit message for the squashed group from the guide.

4. **After completing the rebase and amend**, push with force-lease:

   ```bash
   git push --force-with-lease
   ```

   Using `--force-with-lease` instead of `--force` ensures you don't accidentally overwrite commits pushed by others.

5. **Commit the rebase guide after the squash succeeds**

   After the rebase, amend, and push succeed, commit the generated guide file so
   the notes repository does not remain dirty. The guide may live in a different
   repository from the code branch, especially when project docs are symlinked
   into the codebase from a notes repository.

   Detect the repository that owns the guide file:

   ```bash
   guide_path="docs/rebases/{ticket-id}/{rebase-identifier}.md"
   guide_abs="$(cd "$(dirname "$guide_path")" && pwd -P)/$(basename "$guide_path")"
   guide_repo="$(git -C "$(dirname "$guide_abs")" rev-parse --show-toplevel)"
   git -C "$guide_repo" status --short -- "$guide_abs"
   ```

   Then stage, commit, and push only the generated guide file from that owning
   repository:

   ```bash
   git -C "$guide_repo" add "$guide_abs"
   git -C "$guide_repo" commit -m "Docs: add {ticket-id} rebase guide"
   git -C "$guide_repo" push
   ```

   If multiple guide files were created for the same squash session, stage only
   those files. Do not include unrelated notes, reports, or working-tree changes.

If the guide contains multiple groups, do not use the single-command `sed` shortcut above. Follow the generated rebase plan manually so each contiguous group is squashed without reordering commits.

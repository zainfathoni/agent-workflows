---
name: creating-bta-worktrees
description: Creates or repairs BookThatApp sibling worktrees with purpose-named branches, shared symlinks, and Docker-safe runtime files. Use for new or existing ../bta-* worktrees.
---

# Creating BTA Worktrees

Dispatch the request to exactly one script branch. Treat each script's `--help` and source as the single source of truth for its managed options and file inventories.

## Shared safety gates

- Resolve the directory containing this `SKILL.md` to an absolute `skill_dir`, then set `create_script="$skill_dir/scripts/create-bta-worktree.sh"` and `setup_script="$skill_dir/scripts/setup-bta-worktree.sh"`. Verify both are executable and use only these absolute variables for script help and execution.
- If the user asked only for a plan, present the plan and wait for approval before running the create branch.
- Keep branches local: fetch nothing, push nothing, and create no remote branch.
- Name ephemeral worktrees `bta-<slug>`, independently of their branch. Name each new ephemeral branch `<type>/trello-<id>/<slug>`, where `<type>` is exactly `bugfix`, `feature`, or `chore`, the numeric Trello ID is known from the task, and the slug describes the expected change. The Trello segment groups multiple branches for one card in Git clients. For example, use worktree `bta-947-search-save-recovery` with branch `bugfix/trello-947/search-save-recovery`. Reserve `bta/*` branches for explicitly identified existing long-running worktrees; never infer that branch prefix from an ephemeral worktree name.
- Preserve existing paths and real per-worktree runtime files. The scripts refuse an existing create target and skip real runtime files; surface either outcome instead of replacing anything manually.
- Record `git status --short --branch` for every existing target before mutation so pre-existing dirt can be distinguished from setup effects.

## Branch 1 — create

1. Choose the `bta-*` sibling name separately from the branch. For ephemeral work, classify the change as `bugfix`, `feature`, or `chore`, then construct and validate the required `<type>/trello-<id>/<slug>` branch. Choose only a base branch that exists locally; use the default only after confirming it is local. Record the current worktree's status. Read `"$create_script" --help` and source when managed options or exact behavior matter. Read [REFERENCE.md](REFERENCE.md#create-invocations) when selecting an invocation or non-default option. This step is complete when the target, explicit branch, local base, canonical source, lock intent, and pre-create dirt are explicit; locking remains the default.
2. From a BookThatApp worktree, run `"$create_script"` once with `--branch` for new ephemeral work and the approved sibling name. Let it create the local branch/worktree and invoke setup; runtime files remain hard links where possible and copies otherwise, managed notes symlinks are refreshed, and `.amp` remains absent for User Plugin discovery. This step is complete when the script succeeds, or its refusal/error is preserved and reported without manual bypass.
3. Inspect the resulting worktree registration, branch, lock state, status, User Plugins boundary, and every runtime result emitted by setup. Read [REFERENCE.md](REFERENCE.md#verification-and-runtime-diagnosis) when verifying the result or diagnosing runtime failures. This branch is complete only when the report accounts for the target path, branch used or created, lock outcome, absent-or-real `.amp` result, every runtime file as applied/skipped/missing/bad, and any pre-existing dirt.

## Branch 2 — repair

1. Resolve every requested existing worktree target and canonical source. Read `"$setup_script" --help` and source when managed options, symlink inventory, runtime inventory, or exact behavior matter. Read [REFERENCE.md](REFERENCE.md#repair-invocations) when discovering all sibling BTA worktrees or selecting a repair invocation. This step is complete when every target exists and its pre-repair status has been recorded.
2. Run `"$setup_script"` once with all targets and required options. Let it refresh managed notes symlinks, remove legacy `.amp` symlinks for User Plugin discovery, preserve real paths and runtime files, and install missing/symlinked runtime files as hard links or copies. This step is complete when the script succeeds for every target, or the exact target and refusal/error are preserved for reporting.
3. Inspect every target's branch, lock state, status, User Plugins boundary, symlink results, and runtime results. Read [REFERENCE.md](REFERENCE.md#verification-and-runtime-diagnosis) when verifying the result or diagnosing runtime failures. This branch is complete only when the report accounts for every target, its branch, lock outcome, absent-or-real `.amp` result, every managed symlink result, every runtime file as applied/skipped/missing/bad, and any pre-existing dirt.

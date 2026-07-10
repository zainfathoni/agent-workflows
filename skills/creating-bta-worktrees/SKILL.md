---
name: creating-bta-worktrees
description: Creates and repairs BookThatApp sibling worktrees with matching local bta/* branches, shared Claude/notes symlinks, and Docker-safe local runtime files. Use when creating, standardizing, or fixing ../bta-* worktrees.
---

# Creating BTA Worktrees

Create and standardize sibling BookThatApp worktrees in the parent directory using the local `bta/*` branch convention, shared Claude/notes symlinks, and Docker-safe runtime files.

## When to use

- The user asks to create a BookThatApp worktree such as `bta-debug`, `bta-teach`, or another `bta-*` sibling.
- The user asks to repair, standardize, or re-apply local setup to existing BookThatApp worktrees.
- The user reports local worktree runtime issues caused by missing `.env.development.local`, Traefik cert/key files, or `routes.local.toml`.

## Core rules

- Plan first when the user asks for a plan. Do not create worktrees until the user approves.
- Prefer local-only git operations. Do not push branches or create remote branches unless explicitly requested.
- Do not overwrite existing directories, branches, or real per-worktree runtime files without explicit approval.
- Use the embedded scripts as the source of truth instead of copy-pasting shell snippets.
- Keep runtime files as hard links or copies, not absolute symlinks, because Docker containers cannot read absolute macOS symlink targets inside a mounted worktree.

## Worktree convention

Derive the local branch name by replacing the first hyphen with a slash:

- `bta-debug` → `bta/debug`
- `bta-teach` → `bta/teach`

Default base branch is local `bta/main` when it exists. If it does not exist, inspect the repo before choosing a base.

## Create a new worktree

Run `scripts/create-bta-worktree.sh` from the current BookThatApp worktree or pass explicit options:

```bash
skills/creating-bta-worktrees/scripts/create-bta-worktree.sh bta-debug
```

The script:

1. Verifies the current repo is a git worktree.
2. Derives the local branch name, for example `bta-debug` → `bta/debug`.
3. Creates the branch from `bta/main` when missing.
4. Adds a locked sibling worktree, for example `../bta-debug`.
5. Runs `scripts/setup-bta-worktree.sh` for the new worktree.

Useful options:

```bash
scripts/create-bta-worktree.sh --base bta/main bta-debug
scripts/create-bta-worktree.sh --no-lock bta-debug
scripts/create-bta-worktree.sh --canonical ../bookthatapp bta-debug
```

## Repair or standardize existing worktrees

Run `scripts/setup-bta-worktree.sh` for one or more worktrees:

```bash
skills/creating-bta-worktrees/scripts/setup-bta-worktree.sh ../bta-debug ../bta-teach
```

To apply to all sibling BTA worktrees from any BookThatApp worktree:

```bash
git worktree list --porcelain |
  awk '/^worktree / {print $2}' |
  grep '/bta-' |
  sort |
  xargs skills/creating-bta-worktrees/scripts/setup-bta-worktree.sh
```

The setup script refreshes common top-level symlinks:

- `.agents`
- `.claude`
- `.envrc`
- `.mcp.json`
- `CLAUDE.md`
- `CONTEXT.md`
- `PATTERNS.md`
- `docs`
- `scripts`
- `teach`

It also hard-links or copies Docker/local-runtime files from the canonical `bookthatapp` worktree when missing or already symlinks:

- `.env.development.local`
- `docker/development/traefik/bookthatapp.internal.crt`
- `docker/development/traefik/bookthatapp.internal.key`
- `docker/development/traefik/routes.local.toml`

The script skips real per-worktree runtime files rather than overwriting them.

## Why runtime files are not symlinked

Do not use absolute symlinks for runtime files. Docker mounts the worktree into app and Traefik containers; an absolute macOS symlink target such as `/Users/zain/...` is not readable inside the container.

Symptoms this prevents:

- Traefik cannot find PEM data for TLS cert/key files.
- Rails boot fails because `.env.development.local` is missing, such as `ShopifyAPI::Context.setup` receiving a nil API key.
- Local URLs return Traefik 404s when `routes.local.toml` is unavailable and Traefik cannot discover Docker routes.

## Verification

After creating or repairing worktrees, verify:

```bash
git worktree list --porcelain
git -C ../bta-debug status --short --branch
git -C ../bta-teach status --short --branch
```

For runtime files, `setup-bta-worktree.sh` prints `OK runtime file` only when each runtime file is non-empty and not a symlink.

## User-facing summary

When done, report:

- Worktrees created or repaired.
- Branches used or created.
- Whether worktrees were locked.
- Runtime files applied, skipped, or missing.
- Verification results and any pre-existing dirty worktree state.

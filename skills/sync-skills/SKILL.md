---
name: sync-skills
description: Synchronize global skill installations across machines. Updates allowlisted upstream skills, cleans up deprecated ones, installs local-owned shared skills, and verifies the result. Use when setting up a new machine, after pulling skill changes, or to audit an existing installation.
disable-model-invocation: true
---

# Sync Skills

Synchronize the global agent skills installation from the agent-workflows repository. This is the single entry point for installing, updating, and verifying all skills on any machine.

## Bootstrap on a new machine

`/sync-skills` cannot be invoked globally until `install.sh` has symlinked it once. On a brand-new machine, bootstrap first:

```bash
~/Code/GitHub/zainfathoni/agent-workflows/skills/install.sh
```

Then invoke `/sync-skills` for all future updates and audits.

## Locate the repo

Find the agent-workflows repository. Check in order:

1. `AGENT_WORKFLOWS_ROOT` environment variable if set.
2. `~/Code/GitHub/zainfathoni/agent-workflows` (default location).
3. Ask the user for the path.

Verify the repo contains `skills/update-upstream.sh` and `skills/install.sh`.

## Resolve skill roots

Determine two paths before running anything:

- **Upstream root**: `~/.agents/skills` — where `npx skills add --global` installs upstream skills.
- **Local root**: `${AGENT_SKILLS_DIR:-$HOME/.agents/skills}` — where `install.sh` symlinks local-owned skills.

When `AGENT_SKILLS_DIR` is not set, both roots are the same directory. When it differs (e.g. `~/.claude/skills`), upstream skills are still in `~/.agents/skills` and local skills are in the override target. Verification must check each root accordingly.

## Run the upstream update

Run the upstream skills installer, which cleans up deprecated skills and installs/updates all upstream-tracked skills:

```bash
"<ROOT>/skills/update-upstream.sh"
```

This script:
- Removes deprecated upstream skills (`to-prd`, `to-issues`, `to-plan`, `caveman`, `zoom-out`) from all registered agent directories via `npx skills remove --global`, with a filesystem fallback for stragglers.
- Installs all upstream-tracked Matt Pocock skills via `npx skills add mattpocock/skills` with an explicit allowlist.
- Installs `improve` from `shadcn/improve` via a separate explicit allowlist.
- Uses `--global --copy` to install deterministically for the explicitly configured agents, defaulting to `amp`, `claude-code`, and `codex`.
- Verifies that `improve` and its required reference files are complete at every configured agent destination and that the global Skills CLI lock records `shadcn/improve` as its GitHub source.

Override the target agents with a space-separated subset of supported IDs, for example `UPSTREAM_SKILLS_AGENTS="amp claude-code"`. The script rejects unknown IDs because their global destinations cannot be verified.

## Run the local skills installer

Install local-owned and shared skills as symlinks into the local root:

```bash
"<ROOT>/skills/install.sh"
```

This symlinks every skill directory under `skills/` that has a `SKILL.md` into the local root. It refuses to overwrite a real directory; existing symlinks are replaced.

Override the local root with `AGENT_SKILLS_DIR`:

```bash
AGENT_SKILLS_DIR=~/.claude/skills "<ROOT>/skills/install.sh"
```

## Verify

After both scripts complete, verify the installation is consistent. Derive the expected lists from the repo rather than hardcoding them, so the audit cannot drift from the actual scripts.

### Expected upstream skills

Read the `UPSTREAM_SKILLS` and `IMPROVE_SKILLS` arrays from `skills/update-upstream.sh`. These must be present as directories or symlinks in the upstream root (`~/.agents/skills`) when the CLI creates a canonical multi-target installation. `improve` must contain `SKILL.md` and all three files under `references/` at every configured agent destination.

### Deprecated upstream skills

Read the `DEPRECATED_UPSTREAM_SKILLS` array from `skills/update-upstream.sh`. These must NOT be present in the upstream root, the local root, or `~/.claude/skills`.

### Expected local-owned/shared skills

Derive from the filesystem: list every directory under `skills/` that contains a `SKILL.md` file. These must be present as symlinks in the local root, pointing into the agent-workflows repo.

### Verification steps

1. Parse `UPSTREAM_SKILLS`, `IMPROVE_SKILLS`, and `DEPRECATED_UPSTREAM_SKILLS` arrays from `skills/update-upstream.sh`.
2. List the upstream root and check every expected upstream skill is present. For `improve`, check the complete required file set and each configured agent destination as enforced by `update-upstream.sh`.
3. Check that no deprecated skills remain in the upstream root, the local root, or `~/.claude/skills`.
4. List directories with `SKILL.md` under `skills/` and check each is a valid symlink in the local root pointing into the agent-workflows repo.
5. Report any missing, extra, or broken symlinks.

## Report

Print a summary:

```
Sync complete.

Upstream skills: N installed (list any new/updated)
Deprecated skills: N removed (list any removed)
Local skills: N symlinked
Issues: any discrepancies found, or "none"
```

If issues are found, list each one with the expected state and the actual state, and suggest the fix.

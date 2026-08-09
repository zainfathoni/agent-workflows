---
name: sync-skills
description: Synchronize and verify global skill installations across machines.
disable-model-invocation: true
---

# Sync Skills

Follow this process in order. Treat the repository scripts as authoritative whenever prose and implementation differ.

## 1. Locate and validate the repository

Resolve the agent-workflows root in this order:

1. `$AGENT_WORKFLOWS_ROOT`, when set.
2. `~/Code/GitHub/zainfathoni/agent-workflows`.
3. A path supplied by the user.

Require readable executable files at `skills/update-upstream.sh` and `skills/install.sh`. If this skill is not installed yet on a new machine, follow [`BOOTSTRAP.md`](BOOTSTRAP.md).

**Complete when:** one root has both required scripts and its canonical path is recorded. Otherwise stop and report every lookup attempted.

## 2. Resolve upstream and local roots

Read both scripts before running them. Resolve their paths using the current environment, including `HOME`, `AGENT_SKILLS_DIR`, `UPSTREAM_SKILLS_AGENTS`, `XDG_CONFIG_HOME`, `CLAUDE_CONFIG_DIR`, `CODEX_HOME`, and `XDG_STATE_HOME`. Distinguish the canonical upstream root, every configured agent destination, the local install root, and the global lock file. Preserve script defaults when overrides are absent.

**Complete when:** every destination and lock path used by this run is listed as an absolute path and every configured agent is accepted by the upstream script.

## 3. Update upstream skills

Run, without changing its environment or logic:

```bash
"<ROOT>/skills/update-upstream.sh"
```

The script's own order is binding: deprecated/blocked cleanup, release-pinned upstream package install, invocation/pointer/provenance checks, then separately sourced installs and their checks.

**Complete when:** the script exits zero and none of its checks report an error. A nonzero exit is a discrepancy; continue only with read-only verification so the final report captures the full state.

## 4. Install local skills

Run:

```bash
"<ROOT>/skills/install.sh"
```

Allow the script to replace symlinks. If it refuses a real directory, preserve that directory and record the refusal exactly.

**Complete when:** the installer exits zero. On failure, continue only with read-only verification.

## 5. Derive expectations and verify exhaustively

Derive expectations fresh from `update-upstream.sh`, `install.sh`, and the repository filesystem; never copy their inventories into this skill.

1. Extract every active upstream, separately sourced, deprecated, and blocked skill from the script's arrays, plus configured agent destinations, package provenance, required installed files, and lock-file assertions from its executable checks.
2. Derive local skills by enumerating each immediate `skills/*/` directory containing `SKILL.md`, exactly as the installer does.
3. At every destination where the scripts install upstream skills, verify each expected skill exists and resolves to a directory containing `SKILL.md`. Require each validation helper and required reference encoded by the upstream script to pass, including relative context pointers, Codex sidecars, invocation parity, and lock assertions.
4. Check every deprecated and blocked name across the canonical upstream root, local root, every configured agent root, and the explicit fallback roots used by the script. Count broken symlinks as present discrepancies.
5. In the local root, verify every derived local skill is a symlink, is not broken, and its fully resolved target equals that skill's canonical repository directory. Enumerate the root to report extra skill symlinks, wrong targets, missing links, broken links, and real directories occupying expected names.

**Complete when:** every derived item has an explicit expected-versus-actual result, every relevant root has been enumerated (including overlapping roots), all symlink targets have been resolved, and no check was skipped.

## 6. Report

Report `Sync complete` only when both scripts exited zero and every verification passed. Include counts for upstream, deprecated, and local skills and state that discrepancies are none.

Otherwise report `Sync incomplete`, followed by every discrepancy as an exact path or command, expected state, and actual state, including script exit failures. Never claim completion from partial checks.

**Complete when:** the report names exactly one overall state, includes every required count, and accounts for every script result and verification discrepancy.

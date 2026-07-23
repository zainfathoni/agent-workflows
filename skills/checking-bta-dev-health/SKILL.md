---
name: checking-bta-dev-health
description: Checks BookThatApp development readiness before unattended work.
disable-model-invocation: true
argument-hint: "[BTA worktree or task scope]"
---

# Checking BTA Development Health

Establish whether the currently unfinished BookThatApp work can proceed unattended. Invoke as `/checking-bta-dev-health`; Amp has no documented skill-alias field, so `/bta-dev-health` is not an alias.

## Readiness contract

Classify every check:

- `ready`: the required capability works now.
- `auto-recoverable`: one deterministic, reversible recovery is known, but this health run leaves it for an authorized recovery step.
- `needs-owner`: authentication, permission, ambiguity, destructive recovery, or a human decision blocks unattended work.
- `deferred`: the current unfinished-work inventory does not require the capability.

The overall result is `needs-owner` when any required check has that status, otherwise `auto-recoverable` when any required check has that status, otherwise `ready`. Deferred checks do not lower the overall result.

Health is inspection-only except for disposable runtime probes: one `--rm` container and one temporary Chrome profile. Preserve repositories, services, databases, documents, pull requests, deployments, and agent state. Never deploy, edit Google Docs or PRs, save staging data, migrate a database, start provider delegation, or stop an unrelated process. Propose recovery separately with its required authorization.

Keep tokens, cookies, authorization headers, emails, account names, merchant/store names, document contents, and private pane output out of reports. Exact worktree paths, amux workspace names, and worker/runner identities may appear only where needed to identify the diagnosed local resource. Write a claude-notes report only when the user explicitly requests one; otherwise report in the conversation.

## Ordered readiness process

### 1. Inventory unfinished work before health probes

Resolve the intended BTA repository from the supplied scope or a verified local remote. Before running any amux doctor, inventory every registered BTA worktree, branch/upstream state, dirt, open current-user PR, and configured amux resource. Use [the unfinished-work inventory](reference/system-probes.md#unfinished-work-inventory). Treat a worktree as unfinished when it is dirty, ahead/diverged, lacks a settled upstream, has an open PR, or owns an active amux resource. Retain explicit planned tasks supplied by the user even when Git is clean.

Map each unfinished item to its required capabilities: local runtime, GitHub, Cloud 66 staging, Google Docs comments, Shopify embedded staging, full-page staging, and agent capacity. Pi is `deferred` unless a planned task explicitly requires it.

**Complete when:** every registered BTA worktree and supplied task appears exactly once in the inventory, each unfinished item has evidence and required capabilities, and no health probe has started early.

### 2. Check only owned amux resources with bounded diagnostics

Load `/amux`, then read its disclosed `reference/workflows.md#health-workers-and-runners` section as the sole authority for ownership, idle-worker ping, response, and runner classifications. BTA health adds only inventory-derived scope, external deadlines, and redacted reporting. Derive relevant workspaces from step 1, then list each workspace separately. Never run aggregate `amux doctor --all` or repeatedly retry a timeout.

For each configured worker, follow the loaded `/amux` health authority and run `scripts/bounded-amux-diagnostics.py worker-doctor --thread <thread-id>` once. Its fixed 30-second deadline records a timeout independently from tmux ownership and responsiveness. If needed to localize a timeout, run its two `amp-list` branches once each as described in [bounded amux diagnostics](reference/system-probes.md#bounded-amux-diagnostics).

For each runner, run the exact command `amux --json runner doctor --workdir <path>` and apply the loaded `/amux` classification. Ping eligibility, prompt mechanics, deadline, and response interpretation come only from that authority.

**Complete when:** every amux resource mapped in step 1 has separate doctor, exact ownership, and responsiveness classifications; each timeout records only its thread identity and process-shape class; and no amux state changed.

### 3. Check external access without exposing identity

Follow [external access probes](reference/system-probes.md#external-access). Check GitHub API authentication, SSH transport, and each relevant remote; Claude Code first-party authentication; and Cloud 66 authentication plus visibility of the required staging stack. Record booleans and sanitized status categories rather than account or stack identity.

**Complete when:** every external capability required by the unfinished inventory has a current result, every credential output is redacted or reduced to safe fields, and login/MFA/permission work is classified `needs-owner`.

### 4. Check local runtime and capacity

Follow [local runtime probes](reference/system-probes.md#local-runtime-and-capacity). Check the Docker daemon, Compose CLI and resolved config, required local images, container-side Ruby and Bundler, filesystem headroom, Docker disk usage, and every registered worktree path. Prefer an existing exact BTA app container for version probes; otherwise use one network-disabled `--rm` container. The probe may read versions only.

**Complete when:** Docker client/server, Compose resolution, required images, Ruby, Bundler, disk state, and every worktree path have explicit results, and any disposable container has exited and been removed.

### 5. Check the three browser surfaces in one temporary profile

Read and follow [the browser probe](reference/browser-probe.md). Use its bundled isolated Chrome DevTools server and exact probe-owned cleanup helper for all required URLs. Verify authenticated Google Docs comment visibility, Shopify embedded staging, and full-page staging without entering data or changing state. A missing required URL is `needs-owner`; a surface not required by any unfinished item is `deferred`.

**Complete when:** each required surface has authentication and load results plus any safe interaction named by the unfinished-work inventory; no state-changing control was used; all probe tabs are closed; and the exact probe-owned Chrome process and temporary profile are gone.

### 6. Report readiness and recovery ownership

Report the unfinished-work inventory first, then one table with capability, scope, classification, sanitized evidence, and next owner/action. Keep amux worker-doctor timeout, exact tmux ownership, and ping responsiveness as three distinct rows. List only recovery actions that are deterministic and reversible; do not execute them in this run.

If explicitly asked for a claude-notes artifact, write the same redacted report to the user-selected project location after reading its local conventions. Otherwise create no report file.

**Complete when:** every required capability is classified once, the overall result follows the precedence rule, every non-ready item has an owner and next action, cleanup is verified, and no secret or prohibited mutation appears in the report or worktree.

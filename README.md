# Agent Workflows

Reusable personal agent workflow tooling for repositories that use globally installed agent skills and GitHub Issues.

## What This Provides

- `ralph/ralph.sh` - an execution-only Agent Queue runner.
- `ralph/PROMPT.md` - the shared prompt used by Ralph work sessions.
- `ralph/init.sh` - a plan-then-apply onboarding script for new or existing repositories.
- `ralph/github-blockers.sh` - audits, syncs, and checks real GitHub blocked-by relationships.
- `ralph/templates/docs/agents/*` - repo-local documentation templates consumed by global skills and Ralph.
- `skills/*` - reusable personal skills that can be installed globally by symlink.

## Workflow Contract

Planning and triage are manual, maintainer-triggered steps:

- `/prototype` answers unclear product, UI, state, or integration questions with throwaway spikes before work is committed to issues.
- `/handoff` compacts a long planning, debugging, or prototyping session so a fresh agent can continue with context.
- `/to-prd` creates PRD issues.
- `/to-issues` creates vertical-slice implementation issues.
- `/triage` evaluates readiness and applies triage labels.

Ralph starts after triage. It only consumes issues already marked `ready-for-agent`. It also treats GitHub's issue dependency graph as the canonical blocker source: issues with open `blockedBy` dependencies are not eligible for execution.

If upstream skills create issues with `ready-for-agent-triage`, treat that as a planning/triage queue label. It does not make an issue eligible for Ralph until the repository's triage labels map the issue to `ready-for-agent`.

Reference: [Skills Changelog: /handoff, /prototype, /review and /writing](https://www.aihero.dev/skills/skills-changelog-handoff-prototype-review-and-writing).

## Onboard A Repository

From the target repository:

```bash
~/Code/GitHub/zainfathoni/agent-workflows/ralph/init.sh
```

To apply without the interactive confirmation:

```bash
~/Code/GitHub/zainfathoni/agent-workflows/ralph/init.sh --yes
```

If the repository uses a GitHub Project dashboard, pass it explicitly:

```bash
~/Code/GitHub/zainfathoni/agent-workflows/ralph/init.sh --project-owner zainfathoni --project-number 6
```

The init script creates or updates repo-local `docs/agents/*`, creates missing canonical labels, and creates local-only Ralph symlinks ignored through `.git/info/exclude`.

## Run Ralph

After onboarding, run from the target repository:

```bash
./ralph.sh
```

Debug resolved configuration without invoking an agent:

```bash
./ralph.sh --dry-run
```

Run exactly one iteration:

```bash
./ralph.sh 1
```

Force one issue while still validating all Agent Queue rules:

```bash
RALPH_ISSUE=168 ./ralph.sh 1
```

## Blocked-by Relationships

Markdown `Blocked by: #123` lines are documentation only. GitHub's real issue dependency graph is the canonical blocker source. Use the helper to audit or repair repositories where markdown blockers may not have matching GitHub relationships:

```bash
~/Code/GitHub/zainfathoni/agent-workflows/ralph/github-blockers.sh audit --repo OWNER/REPO --state all
~/Code/GitHub/zainfathoni/agent-workflows/ralph/github-blockers.sh sync --repo OWNER/REPO --state all
```

Before Ralph claims work, it must verify the selected issue has no open real blockers:

```bash
~/Code/GitHub/zainfathoni/agent-workflows/ralph/github-blockers.sh check-issue --repo OWNER/REPO --issue 168
```

## Environment

Common overrides:

- `RALPH_WORKSPACE` - target repository path.
- `RALPH_REPO` - GitHub repository, such as `OWNER/REPO`.
- `RALPH_PROJECT_OWNER` - GitHub Project owner when a Project is configured.
- `RALPH_PROJECT_NUMBER` - GitHub Project number when a Project is configured.
- `RALPH_RUNNER` - `opencode` or `claude`.
- `RALPH_MODEL` - optional runner model override.
- `RALPH_ISSUE` - optional forced issue number, still validated by the prompt.
- `RALPH_NOTE` - runtime note appended to the prompt.
- `RALPH_BRANCH_PREFIX` - issue branch prefix, default `agent/issue-`.
- `RALPH_AUTO_APPROVE` - default `1`; set `0` to avoid permission auto-approval.
- `RALPH_DRY_RUN` - default `0`; set `1` to print resolved config and exit before invoking an agent.
- `RALPH_PRINT_CONFIG_ONLY` - default `0`; set `1` to print resolved config and exit before invoking an agent.

When present, `docs/agents/ralph.md` supplies default values for `RALPH_REPO`, `RALPH_PROJECT_OWNER`, `RALPH_PROJECT_NUMBER`, and `RALPH_BRANCH_PREFIX`. Environment variables override those repo-local defaults.

## Repository Docs

Each onboarded repository should commit:

- `docs/agents/issue-tracker.md`
- `docs/agents/triage-labels.md`
- `docs/agents/domain.md`
- `docs/agents/ralph.md`

These files adapt the global skills and shared Ralph runner to the local repository. They are not an issue tracker or backlog.

## Install Shared Skills

Install or update upstream-tracked Matt Pocock skills first, then install this repo's local-owned/shared skills:

```bash
~/Code/GitHub/zainfathoni/agent-workflows/skills/update-upstream.sh
~/Code/GitHub/zainfathoni/agent-workflows/skills/install.sh
```

`skills/update-upstream.sh` installs an explicit allowlist of upstream-tracked skills and intentionally excludes local-owned `teach`, so pulling this repo does not depend on a human remembering which upstream skills are safe to update.

By default this symlinks shared skills into `~/.agents/skills`. Set `AGENT_SKILLS_DIR` to install somewhere else.

## Script Safety

This repo uses [destructive_command_guard](https://github.com/Dicklesworthstone/destructive_command_guard) scan config in `.dcg/hooks.toml` and CI in `.github/workflows/dcg-scan.yml` to catch destructive commands added to shell scripts and workflows.

For local checks, install `dcg` and run:

```bash
dcg scan --paths skills/ .github/workflows/ --fail-on error
```

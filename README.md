# Agent Workflows

Reusable personal agent workflow tooling for repositories that use globally installed agent skills and GitHub Issues.

## What This Provides

- `ralph/ralph.sh` - an execution-only Agent Queue runner.
- `ralph/PROMPT.md` - the shared prompt used by Ralph work sessions.
- `ralph/init.sh` - a plan-then-apply onboarding script for new or existing repositories.
- `ralph/templates/docs/agents/*` - repo-local documentation templates consumed by global skills and Ralph.

## Workflow Contract

Planning and triage are manual, maintainer-triggered steps:

- `/to-prd` creates PRD issues.
- `/to-issues` creates vertical-slice implementation issues.
- `/triage` evaluates readiness and applies triage labels.

Ralph starts after triage. It only consumes issues already marked `ready-for-agent`.

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

Run exactly one iteration:

```bash
./ralph.sh 1
```

Force one issue while still validating all Agent Queue rules:

```bash
RALPH_ISSUE=168 ./ralph.sh 1
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

## Repository Docs

Each onboarded repository should commit:

- `docs/agents/issue-tracker.md`
- `docs/agents/triage-labels.md`
- `docs/agents/domain.md`
- `docs/agents/ralph.md`

These files adapt the global skills and shared Ralph runner to the local repository. They are not an issue tracker or backlog.

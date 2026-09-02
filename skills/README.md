# Shared Skills

Reusable personal skills that should be available across projects.

## Workflow Skills

- `fizzy` - manage Fizzy boards, cards, steps, comments, reactions, and pins. Card descriptions must be authored as HTML and card relationships must be linked.
- `sync-skills` - synchronize global skill installations across machines: update upstream skills, clean up deprecated ones, install local-owned shared skills, and verify the result. The single entry point for setting up or auditing any machine.
- `log-notes` - log completed agent work into iCloud-synced Obsidian daily notes and relevant topical/project notes.
- `squash-commits` - prepare a chronological rebase guide and, when explicitly authorized, execute and verify the guided squash.
- `pr-e2e-evidence` - collect repo-agnostic PR QA evidence: E2E results, browser verification notes, report screenshots, before/after screenshots, and PR description updates.
- `creating-bta-worktrees` - create and repair BookThatApp sibling worktrees with matching local branches, shared symlinks, and Docker-safe runtime files.
- `creating-bta-prs` - rename BookThatApp issue worktree branches to existing BTA conventions, commit and push focused changes, and create GitHub PRs from the repo template.
- `checking-bta-dev-health` - inventory unfinished BookThatApp work and check bounded agent, credential, runtime, staging, disk, worktree, and temporary-browser readiness before AFK development.
- `teach` - stateful, multi-session teaching workspace (mission, lessons, reference docs, learning records, reusable workspace assets, workspace-owned hosting docs). Vendored from Matt Pocock's AI Hero ([learn-anything-with-my-teach-skill](https://www.aihero.dev/learn-anything-with-my-teach-skill)) and tracked here so local modifications are version-controlled. Local changes: codebase lessons link source references via `vscode://file/<path>:<line>` deep links and pinned GitHub permalinks; lesson hosting is documented per workspace.

`teach` is local-owned. Do not overwrite it with `npx skills add mattpocock/skills`; compare upstream changes in a separate grilling session and selectively port only the accepted parts.

When comparing `teach` with upstream, treat upstream as input, not authority: adopt upstream changes only when they improve the teaching model without weakening the local delta. Preserve the local delta unless a grilling decision explicitly retires it: source-derived workspace directories, reusable workspace assets as the default architecture, static/offline hosting portability, per-workspace hosting docs, codebase source chips with both VS Code deep links and pinned GitHub permalinks, optional Tailscale serving helper, Tycho inquiry feedback loops, and the committed local templates/scripts under `skills/teach/`.

Use globally installed upstream skills alongside these shared skills. Upstream-tracked skills are installed from their source repositories and may accept upstream breaking changes, including renames and removal of deprecated skills.

- `ask-matt` - route to the appropriate upstream user-invoked skill.
- `domain-modeling` - maintain durable domain language and ADRs while decisions are made.
- `grill-with-docs` - user-invoked wrapper that runs `grilling` with `domain-modeling`.
- `codebase-design` - shared deep-module vocabulary for architecture and interface decisions.
- `diagnosing-bugs` - renamed upstream replacement for `diagnose`.
- `writing-for-agents` - model-invoked reference for skills, agent instructions, and other documents agents consume. Renamed upstream from `writing-great-skills`.
- `resolving-merge-conflicts` - resolve in-progress git merge or rebase conflicts.
- `handoff` - compact a long session into a handoff document before switching agents or tasks.
- `grill-me` - stateless user-invoked grilling when no working directory should retain the result.
- `to-questionnaire` - turn an external decision gap into a questionnaire for the person who can answer it.
- `wait-what` - re-pitch one message that did not land with enough context and plain language.

- `grilling` - reusable interview loop for stress-testing plans and designs. Distinguishes facts (found by exploring the codebase) from decisions (the user must decide), asks one question at a time, and waits for confirmation before enacting any plan.
- `prototype` - answer one logic or UI question with throwaway code, retaining the primary source on a `prototype/*` branch outside main. Model-invoked so `/wayfinder` can use it directly.
- `to-spec` - turn the current conversation into a spec and publish it to the issue tracker. No interview — just synthesizes what you've already discussed. Renamed from `to-prd`.
- `to-tickets` - break a plan, spec, or conversation into tracer-bullet tickets, each declaring its blocking edges. Works as a local `tickets.md` file or native tracker blocking links. Merged from `to-plan` and `to-issues`.
- `implement` - build the work described by a spec or set of tickets, driving TDD at pre-agreed seams and closing out with `/code-review` before committing.
- `wayfinder` - plan a huge chunk of work as a shared map of investigation tickets on the issue tracker — research, grilling, prototype, and task tickets linked with blocking relationships, resolved one at a time until the route is clear.
- `research` - investigate a question against primary sources and capture findings as a cited Markdown file in the repo, run as a background agent.
- `code-review` - two-axis review of the diff since a fixed point: Standards (coding standards plus a Fowler refactoring-smell baseline) and Spec (faithfulness to the originating spec or ticket), run as parallel sub-agents.
- `tdd` - test-driven development reference material: red-green loop with refactoring moved to the code-review phase. Now reference-only so AFK agents can work autonomously.
- `improve-codebase-architecture`, `setup-matt-pocock-skills`, and `triage` - upstream engineering workflow skills.
- `improve` - audit a codebase, produce a prioritized improvement plan, and execute or reconcile that plan. Installed from [`shadcn/improve`](https://github.com/shadcn/improve).
- `tycho` - manage Tycho-monitored projects and managed agents: create/list/run/stop/send/archive/clone agents, control schedules. Installed from [`firewalker06/tycho`](https://github.com/firewalker06/tycho).

Deprecated or replaced upstream skills such as `writing-great-skills`, `ubiquitous-language`, `design-an-interface`, `qa`, `request-refactor-plan`, `caveman`, `zoom-out`, `to-prd`, `to-issues`, and `to-plan` should remain uninstalled unless they become local-owned skills with explicit documented behavior.

Upstream `wizard` is deliberately uninstalled. Its v1.2.3 model-invoked template permits an unconstrained `ENV_FILE` and ambient GitHub repository writes; see [ADR 005](../docs/decisions/005-defer-upstream-wizard.md).

Do not treat prototype code as production code unless a human explicitly promotes it into an implementation task.

The lifecycle flow is: Grilling → Spec → Tickets → Implement → Code Review. Start with `/grill-with-docs` (or `/wayfinder` for genuinely multi-session decision maps), generate a spec with `/to-spec`, break it into tickets with `/to-tickets`, implement each ticket with `/implement`, and review with `/code-review`.

Reference: [Skills Changelog v1.2: /wait-what, /writing-for-agents, Claude Code Plugin, and more](https://www.aihero.dev/skills/skills-changelog-v12-wait-what-writing-for-agents-claude-code-plugin-and-more). The installer pins the audited v1.2.3 patch tag.

## Install

After cloning this repo, bootstrap the `/sync-skills` skill once:

```bash
~/Code/GitHub/zainfathoni/agent-workflows/skills/install.sh
```

Then invoke `/sync-skills` for all future updates and audits. It fast-forwards this repository, runs both scripts below, cleans up deprecated skills, and verifies the installation.

For manual control or troubleshooting, the underlying scripts are:

```bash
~/Code/GitHub/zainfathoni/agent-workflows/skills/update-upstream.sh
~/Code/GitHub/zainfathoni/agent-workflows/skills/install.sh
```

`update-upstream.sh` uses explicit allowlists for Matt Pocock's skills, `shadcn/improve`, and `firewalker06/tycho`, and intentionally excludes local-owned `teach`. Matt's package is pinned to the audited v1.2.3 tag. The script removes deprecated and blocked skills before installing, validates copied context pointers and Claude/Codex invocation metadata, and verifies lock provenance. By default it copies skills for `amp`, `claude-code`, and `codex`; Amp and Codex share the Agent Skills root used by the Skills CLI. Override the agent set with a whitespace-separated subset, such as `UPSTREAM_SKILLS_AGENTS="amp claude-code"`; other agent IDs are rejected.

The copied multi-agent installation remains authoritative. Do not install Matt's Claude Code plugin alongside it; that creates a second update path for the same skills.

`install.sh` symlinks all local-owned shared skills. The default target is `~/.agents/skills`. Override it with `AGENT_SKILLS_DIR`:

```bash
AGENT_SKILLS_DIR=~/.claude/skills ~/Code/GitHub/zainfathoni/agent-workflows/skills/install.sh
```

The installer refuses to overwrite a real directory or file. If a target path already exists as a symlink, it is replaced.

Shell scripts under `skills/` are covered by destructive-command scanning. If you add or change a script, run `dcg scan --paths skills/ --fail-on error` when `dcg` is installed; CI also scans scripts and workflows. Prefer installing `dcg` through machine configuration rather than an ad-hoc local installer when the machine is managed declaratively.

## Review Skills

All review skills default to a current-user **PENDING** review and never submit, publish, publicly reply, resolve, or delete review content without explicit instruction.

### Source-aware review skills

These handle review comments regardless of source — current-user pending drafts *or* teammate-visible threads — and apply source-specific safety internally:

- `self-review` - create or update a current-user PENDING review with inline comments.
- `review-address` - address review comments end-to-end (verify, fix, optionally reply), for pending drafts or teammate threads.
- `review-verify` - verify whether review comments were addressed before replying, resolving, clearing, or submitting.
- `review-clear` - delete current-user pending review artifacts only after explicit instruction.

### Teammate-facing review skills

Use these for colleague-facing review work where feedback may become visible when explicitly requested:

- `team-review` - review a teammate's PR; draft findings as a PENDING review first, submit only when asked.
- `team-review-resolve` - resolve verified teammate-visible review threads.

## Pending-first contract

Every skill above creates or updates a current-user PENDING review by default and treats publication as an explicit, opt-in step. Do not mix current-user pending-review cleanup (`review-clear`) with teammate-visible thread resolution (`team-review-resolve`) in the same step.

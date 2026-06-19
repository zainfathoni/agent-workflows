# Shared Skills

Reusable personal skills that should be available across projects.

## Workflow Skills

- `fizzy` - manage Fizzy boards, cards, steps, comments, reactions, and pins. Card descriptions must be authored as HTML and card relationships must be linked.
- `log-notes` - log completed agent work into iCloud-synced Obsidian daily notes and relevant topical/project notes.
- `squash-commits` - analyze branch commits and prepare a rebase guide for squashing related work into descriptive commits.
- `explain-and-quiz` - explain a topic or PR with codebase references, alternatives, and trade-offs, then quiz the user to verify understanding.
- `pr-e2e-evidence` - collect repo-agnostic PR QA evidence: E2E results, browser verification notes, report screenshots, before/after screenshots, and PR description updates.
- `teach` - stateful, multi-session teaching workspace (mission, lessons, reference docs, learning records). Vendored from Matt Pocock's AI Hero ([learn-anything-with-my-teach-skill](https://www.aihero.dev/learn-anything-with-my-teach-skill)) and tracked here so local modifications are version-controlled. Local change: codebase lessons link source references via `vscode://file/<path>:<line>` deep links.

`teach` is local-owned. Do not overwrite it with `npx skills add mattpocock/skills`; compare upstream changes in a separate grilling session and selectively port only the accepted parts.

Use globally installed upstream skills alongside these shared skills. Upstream-tracked skills are installed from Matt Pocock's skills and may accept upstream breaking changes, including renames and removal of deprecated skills.

- `ask-matt` - route to the appropriate upstream user-invoked skill.
- `grilling` - reusable interview loop for stress-testing plans and designs.
- `domain-modeling` - maintain durable domain language and ADRs while decisions are made.
- `grill-with-docs` - user-invoked wrapper that runs `grilling` with `domain-modeling`.
- `codebase-design` - shared deep-module vocabulary for architecture and interface decisions.
- `diagnosing-bugs` - renamed upstream replacement for `diagnose`.
- `writing-great-skills` - renamed upstream replacement for `write-a-skill`.
- `resolving-merge-conflicts` - resolve in-progress git merge or rebase conflicts.
- `handoff` - compact a long session into a handoff document before switching agents or tasks.
- `prototype` - build throwaway UI or business-logic spikes before turning decisions into PRDs or issues.
- `improve-codebase-architecture`, `setup-matt-pocock-skills`, `tdd`, `to-issues`, `to-prd`, and `triage` - upstream engineering workflow skills.

Deprecated upstream skills such as `caveman` and `zoom-out` should remain uninstalled unless they become local-owned skills with explicit documented behavior.

Do not treat prototype code as production code unless a human explicitly promotes it into an implementation task.

Reference: [Skills Changelog v1](https://www.aihero.dev/skills/skills-changelog-v1-announcement).

## Install

Install or update all shared skills by symlinking them into the global skills directory:

```bash
~/Code/GitHub/zainfathoni/agent-workflows/skills/install.sh
```

The default target is `~/.agents/skills`. Override it with `AGENT_SKILLS_DIR`:

```bash
AGENT_SKILLS_DIR=~/.claude/skills ~/Code/GitHub/zainfathoni/agent-workflows/skills/install.sh
```

The installer refuses to overwrite a real directory or file. If a target path already exists as a symlink, it is replaced.

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

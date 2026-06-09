# Shared Skills

Reusable personal skills that should be available across projects.

## Workflow Skills

- `fizzy` - manage Fizzy boards, cards, steps, comments, reactions, and pins. Card descriptions must be authored as HTML and card relationships must be linked.
- `squash-commits` - analyze branch commits and prepare a rebase guide for squashing related work into descriptive commits.
- `explain-and-quiz` - explain a topic or PR with codebase references, alternatives, and trade-offs, then quiz the user to verify understanding.
- `pr-e2e-evidence` - collect repo-agnostic PR QA evidence: E2E results, browser verification notes, report screenshots, before/after screenshots, and PR description updates.

Use globally installed upstream planning skills alongside these shared skills:

- `handoff` - compact a long session into a handoff document before switching agents or tasks.
- `prototype` - build throwaway UI or business-logic spikes before turning decisions into PRDs or issues.

Do not treat prototype code as production code unless a human explicitly promotes it into an implementation task.

Reference: [Skills Changelog: /handoff, /prototype, /review and /writing](https://www.aihero.dev/skills/skills-changelog-handoff-prototype-review-and-writing).

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

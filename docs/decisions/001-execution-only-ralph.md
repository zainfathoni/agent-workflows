---
id: "001"
title: Keep Ralph Execution-Only and Reusable Across Repositories
status: accepted
date: 2026-05-02
---

## Context

Personal repositories use globally installed skills based on <https://github.com/mattpocock/skills>. Those skills can turn product ideas into PRD issues, split plans into implementation issues, triage issues, diagnose bugs, and guide TDD.

Several repositories also have repo-local Ralph loop files. Copying runner and prompt files into each repository lets them drift and makes it harder to update the workflow consistently.

We want one reusable workflow implementation that can onboard new repositories and migrate existing repositories without turning repository-local files into a second source of truth.

## Decision

Ralph is an execution-only runner. It consumes issues that have already been manually triaged to `ready-for-agent`.

Ralph must not run `/to-prd`, `/to-issues`, or `/triage` automatically. Those skills remain maintainer-triggered.

GitHub Issues are the source of truth for work. GitHub Projects are preferred dashboards when configured, but labels-only repositories are supported.

Each repository should commit `docs/agents/*` files that document its issue tracker, triage label mapping, domain docs, and Ralph execution rules.

This repository stores the reusable Ralph runner, prompt, onboarding script, and templates. Application repositories should use local-only symlinks to this shared tooling rather than tracking divergent copies.

## Consequences

### Positive

- Ralph stays focused on AFK execution.
- Planning and triage decisions remain explicit human-triggered acts.
- Workflow updates can be made once and reused across personal repositories.
- Existing repositories can migrate through reviewable PRs.

### Negative

- Local repositories depend on this shared repository for Ralph execution.
- Each machine needs local symlink setup.
- Repositories with older workflow ADRs need explicit migration notes.

## When To Revisit

Revisit this decision if Ralph needs sandboxed parallel execution, long-lived worktree orchestration, or if symlink-based local setup becomes brittle.

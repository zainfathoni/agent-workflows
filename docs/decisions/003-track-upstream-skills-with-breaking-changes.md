---
id: "003"
title: Track Upstream Skills Without Compatibility Aliases
status: accepted
date: 2026-06-19
---

## Context

Agent Workflows installs both local-owned skills and upstream skills, especially Matt Pocock's skills. Matt's v1 skill release renamed some skills, removed deprecated skills, and introduced a clearer split between user-invoked and model-invoked skills.

Keeping old upstream skill names as compatibility aliases would preserve muscle memory, but it would also hide upstream changes, add context noise, and make future skill updates harder to reason about.

## Decision

For upstream-tracked skills, Agent Workflows accepts upstream breaking changes. Deprecated upstream-only skills should be removed from the global skill directory. Renamed upstream skills should move to their new upstream names rather than keeping local aliases.

Local-owned skills are preserved when they are symlinked from this repository or explicitly documented as customized local behavior. A skill should only be forked into Agent Workflows when its behavior is materially customized for Zain's workflows.

## Consequences

- Global skills stay aligned with upstream vocabulary and invocation patterns.
- Some old slash-command muscle memory may break after upstream updates.
- Future cleanup can distinguish upstream-tracked skills from local-owned skills before deleting anything.

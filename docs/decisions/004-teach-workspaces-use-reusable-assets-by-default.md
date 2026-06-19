---
id: "004"
title: Teach Workspaces Use Reusable Assets By Default
status: accepted
date: 2026-06-19
---

## Context

The local-owned `teach` skill was originally preserved as a self-contained lesson workflow: each lesson started from a canonical HTML template and carried its own inline CSS. This made lessons easy to open over `file://`, serve over Tailscale, and archive without worrying about missing dependencies.

Matt Pocock's v1 upstream `teach` skill introduced a workspace-level `./assets/*` convention for reusable lesson components such as shared stylesheets, quiz widgets, simulators, and diagram helpers. The upstream package does not ship an `assets/` directory; it defines a convention for each teaching workspace to create one as needed.

Keeping every lesson fully self-contained reduces dependency drift, but it also causes styling and interaction code to be copied across lessons. That makes a multi-session teaching workspace feel less like one course and more like a pile of independent artifacts.

## Decision

Local-owned `teach` workspaces use `./assets/*` as the default lesson architecture. Agents should read and reuse existing workspace assets before authoring a lesson, create shared components when a second lesson would otherwise duplicate code, and make a shared stylesheet the first component a growing workspace earns.

The local-owned behavior still preserves Zain-specific teaching constraints:

- source-derived workspace directory names for lessons tied to tickets, PRs, support cases, or other hosted sources;
- codebase source references with both local VS Code deep links and pinned GitHub permalinks;
- Tailscale lesson serving guidance;
- no package managers, bundlers, external CDNs, or network-only runtime dependencies unless explicitly accepted for that workspace.
- explicit tracking of the local `teach` delta so future upstream comparisons do not accidentally erase local-owned behavior.
- upstream `teach` changes are input, not authority: adopt them only when they improve the teaching model without weakening the local delta, and grill conflicts before changing local `teach`.

## Consequences

- Multi-lesson workspaces can share visual language and interactive components.
- Future lessons may depend on local workspace assets, so moving a single lesson now requires carrying the relevant assets with it.
- Existing self-contained lessons remain valid; they should be fixed in place when needed rather than assuming asset changes will update them.
- The local `lesson-template.html` remains the accessible baseline for seeding the first lesson and first shared assets, not a requirement that every future lesson duplicate all CSS inline.

---
id: "005"
title: Defer the Upstream Wizard Skill Until Its Mutation Boundary Is Hardened
status: accepted
date: 2026-08-09
---

## Context

Matt Pocock's skills v1.2 promotes `wizard` as a model-invoked skill. It generates an interactive shell script for human-only setup work, including `.env` updates and GitHub Actions secrets.

The v1.2.3 fixed template accepts `ENV_FILE` without constraining it to the repository, rewrites that path without rejecting symlinks or applying a restrictive mode, and sends secrets and variables to the GitHub repository selected by ambient `gh` context. The generated stages are arbitrary shell below the fixed template marker. These boundaries are broader than Agent Workflows' local-file and shared-service approval rules.

## Decision

Keep `wizard` out of the upstream allowlist and remove installed copies during synchronization. Continue adopting the rest of the audited v1.2.3 promoted set, except local-owned `teach`.

Reconsider `wizard` only when its template or a deliberately local-owned fork:

- constrains environment-file writes to reviewed repository-relative paths and rejects symlinks;
- uses restrictive permissions for secret-bearing files;
- resolves, displays, and explicitly targets the intended GitHub repository;
- confirms remote secret/variable writes and irreversible stages; and
- requires review of the complete generated script before execution.

## Consequences

- Agent Workflows does not exactly mirror the upstream promoted set.
- `/wizard` remains unavailable until its mutation boundary is evidence-backed.
- The blocked inventory makes this exception visible and prevents stale installations across machines.

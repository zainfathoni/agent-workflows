# Triage Labels

The skills speak in canonical triage roles. This file maps those roles to the actual label strings used in this repo's issue tracker.

## Category Roles

| Canonical role | Label in this repo | Meaning |
| --- | --- | --- |
| `bug` | `bug` | Something is broken |
| `enhancement` | `enhancement` | New feature or improvement |

## Triage-State Roles

| Canonical role | Label in this repo | Meaning |
| --- | --- | --- |
| `needs-triage` | `needs-triage` | Maintainer needs to evaluate this issue |
| `ready-for-agent-triage` | `ready-for-agent-triage` | Generated planning output ready for an agent-assisted triage pass |
| `needs-info` | `needs-info` | Waiting on reporter for more information |
| `ready-for-agent` | `ready-for-agent` | Fully specified, ready for an AFK agent |
| `ready-for-human` | `ready-for-human` | Requires human implementation or review |
| `wontfix` | `wontfix` | Will not be actioned |

Every triaged issue should have exactly one category role and exactly one triage-state role. `ready-for-agent-triage` is not Ralph execution eligibility unless this repository explicitly maps it to the same label as `ready-for-agent`.

When a skill mentions a role, use the corresponding label string from this table. If this repository already has equivalent labels with different names, edit the right-hand column instead of creating duplicates.

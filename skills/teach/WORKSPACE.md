# Teach Workspace Rules

## Local-owned delta

Preserve these local behaviours unless a grilling decision explicitly retires one:

- source-derived workspace directory names for topics tied to hosted sources;
- reusable `./assets/*` as the default lesson architecture;
- static/offline hosting portability for lesson assets, with no build step or network-only dependencies unless explicitly accepted;
- per-workspace hosting documentation via `HOSTING.md`;
- codebase source references with both VS Code deep links and pinned GitHub permalinks;
- optional Tailscale helper `serve-lessons.sh` for workspaces that choose that hosting method;
- Tycho structured inquiry feedback loops;
- committed local templates and scripts in this directory.

## Source-derived workspace names

When a topic has a single canonical source (ticket, PR, support case), give it its own subdirectory named `<source>-<id>`, where the prefix comes from where the original information is hosted — never a generic word like `issue-`.

| Source | Prefix | Example |
| --- | --- | --- |
| Trello card | `trello-` | `trello-HSwwTrRE/` |
| Zendesk ticket | `zendesk-` | `zendesk-93087/` |
| GitHub pull request | `pr-` | `pr-11826/` |
| GitHub issue | `gh-` | `gh-4821/` |
| Shortcut story | `sc-` | `sc-46543/` |

If a topic spans several sources, use the prefix of the system of record and note the others in `MISSION.md`. If no hosted source exists, use a plain dash-case slug.

## State first

Before teaching, inspect existing state and preserve it. Do not overwrite lessons, references, assets, hosting docs, or records unless the user asks or the current teaching step requires a targeted update.

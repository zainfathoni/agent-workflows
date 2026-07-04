# Teach Workspace Rules

## Local-owned delta

Preserve these local behaviours unless a grilling decision explicitly retires one:

- source-derived workspace directory names for topics tied to hosted sources;
- reusable `./assets/*` as the default lesson architecture;
- micro-world simulators and in-page quiz widgets as the default interactivity for mechanism lessons (see LESSON-RULES.md "Micro-worlds");
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

## Shared repository sync

When the workspace lives in a git-backed, multi-machine repository (e.g. a `claude-notes` checkout shared across machines), **hosting a lesson is not the same as sharing it.** Serving a lesson (Tailscale, a local `http.server`, GitHub Pages preview) makes it reachable but does not commit it — so two machines can teach the same topic and stay invisible to each other until someone pushes. This has already caused two divergent lesson sets for the same PR.

Both sides of the workflow are load-bearing:

- **Before authoring**, `git fetch` and check the remote (e.g. `origin/main`) for an existing set for this `<source>-<id>`. A local "untracked / absent" check is not enough — the other set may be pushed but unfetched. If one exists, adopt or extend it instead of writing a duplicate.
- **After authoring**, commit and push the new lesson set **right away**, in its own commit. Do not leave freshly authored lessons uncommitted on one machine — that is exactly how divergence starts. Prompt-and-push is the default, not an afterthought.

When two sets have already diverged, reconcile to one canonical set (prefer the more accurate/complete one, verifying factual claims against the source diff), delete the duplicate, and push. A path collision on `MISSION.md` will block `git pull` — remove the local untracked duplicate before `git pull --ff-only`.

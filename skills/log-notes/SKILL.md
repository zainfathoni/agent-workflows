---
name: log-notes
description: Logs completed work and durable context to its owning Obsidian vault. Use for fleet operational notes or personal and non-fleet notes.
---

# Log Notes

Put each fact in the vault and note that naturally own it. There are two independent decisions: **vault owner** (fleet or iCloud) and **note owner** (daily session trail or durable owner note).

## Routing model

### 1. Choose the vault owner

- **Fleet:** machine inventory, access, state, restoration, cross-machine systems, and operational endpoint knowledge.
- **iCloud:** personal and non-fleet work. Its vault and daily directory are:

```text
/Users/zain/Library/Mobile Documents/iCloud~md~obsidian/Documents/obsidian-notes/
/Users/zain/Library/Mobile Documents/iCloud~md~obsidian/Documents/obsidian-notes/log/daily/
```

- **Mixed work:** use both vaults when appropriate, but give each fact exactly one owner. Link or briefly reference across vaults rather than duplicating sections.

Discover fleet in this exact order:

  1. `$FLEET_VAULT`, when set.
  2. The current repository, when its remote or repository name identifies `fleet`; during the rename transition, also accept `zainfathoni/mac-notes` only when the vault structure validates.
  3. `~/Docs`.
  4. `~/fleet`.

Validate each candidate before selecting it. A fleet vault is a directory containing `CONTEXT.md`, `machines/`, `systems/`, and either `index.md` or `.obsidian/`. If no candidate validates, report that fleet is unavailable; never guess, select a similarly named directory, or silently redirect fleet facts into iCloud.

### 2. Choose the note owner

- **Daily note:** session history, drafts, timestamps, one-off investigation or support/deployment narration, and detailed source context. Use `daily/YYYY-MM-DD.md` in fleet or `log/daily/YYYY-MM-DD.md` in iCloud. A one-off investigation with no lasting outcome can remain daily-only.
- **Durable owner/topical note:** reusable facts, decisions, operating rules, gotchas, restoration details, current state, and deferred actions. Use `machines/<id>/index.md`, a relevant machine topic note, or `systems/<id>.md` in fleet; use the relevant project/topical note in iCloud. Update one whenever work changes current state, affects future restoration/debugging/setup, changes a deferred action, records a lasting decision, or would otherwise strand reusable knowledge in a daily note.

Search for an existing owner note before creating one. Create a note only when a durable outcome has no existing home. Summarize the durable lesson rather than copying a daily section, and link back when provenance helps.

## Ordered workflow

1. **Inventory the facts and choose each vault owner.** For fleet facts, run ordered discovery and structural validation before proceeding. **Complete when every fact is assigned to fleet or iCloud, mixed-work facts have one owner each, and every selected fleet path has passed all structural checks.**
2. **Choose each note owner.** Identify the daily note for the session trail and search for existing durable owner notes; create a durable note only when required by the routing criteria and no owner exists. **Complete when every fact is assigned to a specific daily or durable note and every proposed new note has been checked against existing owner notes.**
3. **Read every target note before editing.** Observe its headings, frontmatter, links, and entry conventions. **Complete when the full current contents and local style of every target have been inspected.**
4. **Make the smallest local-style edit.** Record useful future context: request, finding or result, changed files or systems, validation, and unresolved follow-up or caution. Preserve unrelated content; use useful Obsidian wikilinks between daily and owner notes. For fleet daily notes, add only relevant `machines/<id>` and `systems/<id>` YAML tags; repositories are not tags. **Complete when all routed facts are recorded once, durable summaries replace copied narration, links and tags are useful and valid, and no unrelated text changed.**
5. **Review safety and repository state.** Keep entries brief and scrubbed; record a non-secret owner/location reference instead of any token, secret value, secret payload, or sensitive command output. Do not commit or push either vault. **Complete when the diff contains no secrets, transcripts, command dumps, internal tool details, or unrelated edits, and no commit or push was performed.**
6. **Report the result.** List changed files and validation, include repository `git status` where applicable, and distinguish pre-existing or unrelated changes. **Complete when every changed file is accounted for and all unrelated status is explicitly separated from this task's changes.**

## Daily log format

Preserve the target daily note's existing format. When appending agent work, use this shape unless the note clearly uses a different local pattern:

```md
# Relevant Area

## Short outcome title

- Briefly describe the request or context.
- Capture the key finding, decision, or result.
- Note changed files, notes, systems, or links when useful.
- Include validation performed and outcome when relevant.
- Note follow-up only when something remains unresolved.

Related notes:

- [[path/to/non-periodic-note|Readable note title]] — why it is relevant.
```

If the relevant area heading exists, append the new `##` section there. Otherwise create the smallest fitting area heading. Do not add empty boilerplate fields.

## Style

- Keep entries brief and skimmable.
- Prefer concrete paths and commands over vague summaries.
- Include only scrubbed details needed for future restoration.

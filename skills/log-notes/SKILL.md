---
name: log-notes
description: "Logs fleet operational work to the fleet vault and personal or non-fleet work to the user's iCloud Obsidian notes, including durable owner notes. Use when asked to log actions, document a session, update notes, or capture reusable context."
---

# Log Notes

Route operational fleet knowledge to the fleet vault and personal or non-fleet knowledge to the user's iCloud Obsidian vault. Daily notes keep the session trail; owner notes keep durable knowledge.

Vault paths:

```text
/Users/zain/Library/Mobile Documents/iCloud~md~obsidian/Documents/obsidian-notes/
/Users/zain/Library/Mobile Documents/iCloud~md~obsidian/Documents/obsidian-notes/log/daily/
```

## Choose and discover the vault

- Fleet operational work belongs in fleet: machine inventory/access/state/restore work, cross-machine systems, and operational endpoint knowledge.
- Personal and non-fleet work retains the existing iCloud behavior and paths above.
- Mixed work may update both vaults. Give each fact one natural owner and link or briefly reference it; do not duplicate whole sections between vaults.
- Discover fleet in this order:
  1. `$FLEET_VAULT`, when set.
  2. The current repository, when its remote or repository name identifies `fleet`; during the rename transition, also accept `zainfathoni/mac-notes` only when the vault structure validates.
  3. `~/Docs`.
  4. `~/fleet`.
- Validate every candidate before selecting it: it must be a directory and contain `CONTEXT.md`, `machines/`, `systems/`, and either `index.md` or `.obsidian/`. Do not select an arbitrary similarly named directory. If none validates, report fleet unavailable instead of guessing or redirecting fleet facts into iCloud.

## Workflow

1. Identify all target notes.
   - In fleet, use `daily/YYYY-MM-DD.md`; durable facts belong in `machines/<id>/index.md` or the relevant machine topic note, or in `systems/<id>.md`.
   - In iCloud, use `log/daily/YYYY-MM-DD.md` for completed-work session logs.
   - Also update topical/project notes that own durable facts, decisions, restore details, current state, or follow-ups.
   - Search before creating topical notes; prefer an existing owner note. Create one only when the outcome needs a durable home.
2. Read each target note before editing it.
3. Append or update the smallest relevant section; preserve unrelated content and local style.
4. Record only useful future context: request, finding/result, changed files/systems, validation, follow-ups or cautions.
5. Cross-link daily and topical notes with Obsidian wikilinks when it helps navigation.
6. For fleet daily notes, add only relevant YAML frontmatter tags: `machines/<id>` and `systems/<id>`. Repositories are not tags. Add body wikilinks when useful.
7. Never commit or push either vault.
8. At completion, report changed files, repository `git status` when applicable, and pre-existing/unrelated changes separately.

## Daily vs topical

- Daily notes own session history, drafts, timestamps, one-off support/deployment narration, and detailed source context.
- Topical/project notes own reusable knowledge: stable facts, decisions, operating rules, gotchas, restore details, and current state.
- Do not copy daily sections into topical notes. Summarize the durable lesson and link back if provenance matters.

## When to update topical notes

Update a non-periodic owner note outside the selected vault's daily directory (`daily/` in fleet; `log/daily/` in iCloud) when the work:

- changes current system/project state
- affects future restoration, debugging, or setup
- resolves, narrows, or adds a deferred action
- records a lasting user decision
- would otherwise leave reusable knowledge only in the daily note

A one-off investigation with no lasting outcome can stay daily-only.

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
- Never record secret values, tokens, or secret payloads, plaintext or encrypted. In fleet, record only a non-secret owner/location reference.
- Avoid transcripts, command dumps, internal tool details, and sensitive command output; include only scrubbed details needed for future restoration.

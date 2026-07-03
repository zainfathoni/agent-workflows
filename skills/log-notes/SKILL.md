---
name: log-notes
description: "Logs agent work into the user's iCloud Obsidian daily notes and durable topical/project notes. Use when asked to log actions, document a session, update notes, or capture reusable context."
---

# Log Notes

Capture agent work in the user's iCloud Obsidian vault: daily notes keep the session trail; topical notes keep durable knowledge.

Vault paths:

```text
/Users/zain/Library/Mobile Documents/iCloud~md~obsidian/Documents/obsidian-notes/
/Users/zain/Library/Mobile Documents/iCloud~md~obsidian/Documents/obsidian-notes/log/daily/
```

## Workflow

1. Identify all target notes.
   - Use `log/daily/YYYY-MM-DD.md` for completed-work session logs.
   - Also update topical/project notes that own durable facts, decisions, restore details, current state, or follow-ups.
   - Search before creating topical notes; prefer an existing owner note. Create one only when the outcome needs a durable home.
2. Read each target note before editing it.
3. Append or update the smallest relevant section; preserve unrelated content and local style.
4. Record only useful future context: request, finding/result, changed files/systems, validation, follow-ups or cautions.
5. Cross-link daily and topical notes with Obsidian wikilinks when it helps navigation.
6. Do not commit or push the vault; it is iCloud-synced.

## Daily vs topical

- Daily notes own session history, drafts, timestamps, one-off support/deployment narration, and detailed source context.
- Topical/project notes own reusable knowledge: stable facts, decisions, operating rules, gotchas, restore details, and current state.
- Do not copy daily sections into topical notes. Summarize the durable lesson and link back if provenance matters.

## When to update topical notes

Update a non-periodic note outside `log/daily/` when the work:

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
- Avoid transcripts, command dumps, internal tool details, secrets, tokens, and sensitive command output unless needed for future restoration.

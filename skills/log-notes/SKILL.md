---
name: log-notes
description: "Logs agent work into the user's iCloud Obsidian daily notes and relevant topical/project notes. Use when asked to log actions, document a session, update notes, capture what changed, or write durable context in Obsidian."
---

# Log Notes

Capture agent work as concise, durable context in the user's iCloud-synced Obsidian vault.

Vault root:

```text
/Users/zain/Library/Mobile Documents/iCloud~md~obsidian/Documents/obsidian-notes/
```

Daily notes live under:

```text
/Users/zain/Library/Mobile Documents/iCloud~md~obsidian/Documents/obsidian-notes/log/daily/
```

Logging is not only a daily transcript. Always preserve the durable outcome where a future agent or the user would naturally look for it.

## Workflow

1. Identify all target notes.
   - Use `/Users/zain/Library/Mobile Documents/iCloud~md~obsidian/Documents/obsidian-notes/log/daily/YYYY-MM-DD.md` for the session log when the user asks to log completed work.
   - Also update every relevant non-periodic topical/project note in the Obsidian vault that should own the durable concept, fact, decision, state change, restore detail, or follow-up.
   - If no topical note exists and the outcome is durable enough to preserve outside the daily log, create the smallest appropriate non-periodic topic note and link it from the nearest index/status note.
2. Read each target note before editing it.
3. Append or update the smallest relevant section instead of rewriting unrelated content.
4. Use Obsidian wikilinks for existing notes, for example `[[mac/lid-and-suspend]]`.
5. Include only durable information:
   - problem or request
   - key findings
   - files changed
   - validation performed
   - remaining follow-ups or cautions
6. Avoid noisy transcripts, command dumps, and internal tool details unless the command/result is needed for future restoration.
7. Cross-link the daily entry and topical note when it helps future navigation.
8. Do not commit or push the notes. This vault path is iCloud-synced rather than git-tracked.

## Choosing non-periodic topical notes

Always consider whether the work belongs in one or more non-periodic notes outside `log/daily/`. Update a topical note when any of these are true:

- The work changes current system/project state.
- The result affects future restoration, debugging, or setup.
- A deferred action was resolved, narrowed, or added.
- The user made a decision that should outlive the session.
- The finding belongs to an existing topic map, project page, concept note, checklist, or status page.
- The daily entry would otherwise become the only place that explains a reusable concept, troubleshooting path, setup choice, or project state.

Search the vault for likely related non-periodic notes before creating a new one. Prefer updating an existing owner note over creating duplicates. Good search terms usually include the project name, tool name, error phrase, concept, and relevant tags from the daily note.

Examples:

- Hardware/system work: update the relevant Mac status, restore, deferred-action, or hardware note if one exists.
- Tooling/setup work: update the relevant setup/restore note and any status dashboard.
- Work/project investigations: update the project or concept note when the result changes reusable knowledge or future next steps.
- A one-off investigation with no lasting outcome and no reusable concept: daily log only is fine.

## Daily log format

Preserve the existing format of the target daily note. Today's reliable pattern (`2026-06-15.md`) is:

- YAML frontmatter with `date` and `tags`.
- `# Weekday, Month D, YYYY` title.
- Top-level life/work/project areas as `#` headings, for example `# BTA` and `# Side Projects`.
- Specific work items as `## Short outcome title` under the relevant area.
- Concise bullets with important links, findings, actions, validation, and result.
- Optional `Related notes:` block with Obsidian wikilinks when cross-links help navigation.

When appending agent work, use this shape unless the existing daily note clearly uses a different local pattern:

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

If the target daily note already has the relevant area heading, append the new `##` section there. If not, create the smallest fitting area heading using the note's existing naming style. Do not add empty boilerplate fields.

## Style

- Keep entries brief and skimmable.
- Prefer concrete paths and commands over vague summaries.
- Preserve the user's existing note structure and voice.
- Do not include secrets, tokens, private URLs, or sensitive command output.

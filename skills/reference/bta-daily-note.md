# BTA Daily Note Reference

This file is authoritative for behavior shared by the daily-standup and release skills.

## Schema and file handling

The target is `log/daily/YYYY-MM-DD.md`; default to today's date unless the user specifies another date. Read the entire existing note before editing. Preserve all content outside the target owner block, including private notes, and retain existing content inside it unless deduplication requires no new bullet.

If the note does not exist, create it with this exact structure:

```md
---
date: YYYY-MM-DD
tags:
  - webstreet/bta
---
# BTA

## Daily Standup

🌥️️️ Good afternoon, here's my update for today:

### Vlad

## Released ✅

### Vlad

## Escalated Bugs 🐛

## Private Notes 📝
```

Keep all section headings even when empty. When a note exists, keep its greeting rather than replacing it. If the expected structure or placement is unclear, inspect recent daily notes; do not otherwise use recent notes as a source of item data.

## Owner placement

- Zain standup bullets go after the greeting and before the standup `### Vlad` heading.
- Vlad standup bullets go after that `### Vlad` heading and before `## Released ✅`.
- Zain release bullets go after `## Released ✅` and before its `### Vlad` heading.
- Vlad release bullets go after that `### Vlad` heading and before the next `##` heading.
- Keep `### Vlad` present and empty when that owner has no items. If Zain has no releases, `### Vlad` remains directly below `## Released ✅`.

## Source precedence

Resolve content and placement in this order:

1. The user's supplied platform data, pasted text, ticket links, PR links, explicit labels, and explicit ownership.
2. The target daily note's existing structure and nearby formatting.
3. Recent daily notes, only when the target note is absent or its section structure is unclear.

Do not query external systems unless the user explicitly supplies that workflow or asks to use an available CLI or API. Never invent a title, status, category, owner, or link. Ask one concise question when required information remains ambiguous.

## Exact-link policy

Preserve every supplied Trello, GitHub, Slack, Zendesk, and legacy Shortcut URL exactly as given. Do not expand, shorten, substitute, or reconstruct URLs. Preserve linked titles and legacy Shortcut wording from the source when provided. Spacing around a link may be normalized without changing the URL or its supplied meaning.

## Deduplication

Before adding a bullet, compare it with existing bullets in the relevant section. Treat matching ticket URLs, matching PR URLs, or the same item title as the same item. Add each requested item at most once; preserve the existing bullet rather than creating a variant.

## Standup versus release routing

- Completed shipped work and production deploys belong under `## Released ✅`, not `## Daily Standup`.
- Work only on staging, ready for testing, pending review, needing review, represented by an already-raised PR, or reporting environment availability belongs in standup, not release.
- Route by actual state, not by the skill that was invoked. Apply the destination skill's item-specific classification and formatting rules in the same daily-note edit; do not recursively restart its full process.
- Treat every owner block receiving a supplied item as a target block. When an existing matching bullet reflects an older state in the other section, reconcile it into the current destination rather than leaving duplicate standup and release records.

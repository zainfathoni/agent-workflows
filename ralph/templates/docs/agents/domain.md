# Domain Docs

How engineering skills should consume this repo's domain documentation when exploring the codebase.

## Before Exploring, Read These

- `CONTEXT.md` at the repo root, if it exists.
- `CONTEXT-MAP.md` at the repo root, if it exists. It points at one `CONTEXT.md` per context.
- `docs/adr/` or `docs/decisions/` for architectural decisions that touch the area being changed.

If these files do not exist, proceed silently. Producer skills such as `/grill-with-docs` create domain docs lazily when terms or decisions are resolved.

## Use The Glossary Vocabulary

When output names a domain concept in an issue title, refactor proposal, hypothesis, test name, or PR body, use the term as defined in `CONTEXT.md`. Do not drift to synonyms the glossary explicitly avoids.

If the concept is missing from the glossary, either reconsider whether the term belongs to the project or note it for `/grill-with-docs`.

## Flag Decision Conflicts

If output contradicts an existing ADR or decision record, surface the contradiction explicitly instead of silently overriding it.

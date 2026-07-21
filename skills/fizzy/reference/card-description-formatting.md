# Card Description and Rich-Text Formatting

Load this reference before creating or changing a card description, adding rich-text attachments, or choosing inline versus header images. This is the authoritative home for description formatting and relationship-link rules.

## Card Description Formatting

**Always pass card descriptions as HTML, not Markdown or plain text.** Fizzy stores a plain-text `.description`, but the rendered card body is ActionText HTML in `.description_html`. Plain text with headings like `ContextFoo` or list markers like `• item` renders poorly and breaks existing card styling.

Use these tags for card descriptions:

- `<p>` for paragraphs
- `<h2>` for sections
- `<ul>` / `<ol>` / `<li>` for lists
- `<code>` for paths, commands, identifiers, and code symbols
- `<a href="...">` for links

Relationship links are mandatory:

- Link every `Card #123` and `Fizzy #123` reference to `https://app.fizzy.do/<account-id>/cards/123`, deriving `<account-id>` from the selected card/account context.
- Link every parent, child, blocker, duplicate, Shortcut, GitHub PR, GitHub issue, and external relationship reference when a URL is available.
- Do not leave bare card references in card descriptions.

Before updating an existing card description:

- Read `.description_html`, not just `.description`.
- Preserve existing HTML structure and links unless intentionally replacing the whole body.
- Do not round-trip through `.description`; it loses structure and can remove links.

After creating or updating a card description:

- Read `.description_html` to verify that headings, paragraphs, lists, code spans, and links render as HTML tags.
- Check that all `Card #...` / `Fizzy #...` references are clickable links.

Recommended creation/update pattern:

```bash
fizzy card create --board BOARD_ID --title "Title" --description "$(cat <<'HTML'
<p>Short intro paragraph.</p>
<h2>Context</h2>
<p>Structured HTML body.</p>
<h2>Related cards</h2>
<ul>
<li><a href="https://app.fizzy.do/6104728/cards/123">Card #123 Example</a></li>
</ul>
HTML
)"
```

Verification pattern:

```bash
fizzy card show CARD_NUMBER | jq -r '.data.description_html'
```

---
## Rich Text Formatting

Card descriptions and comments support HTML. Card descriptions must be authored as HTML; do not use Markdown or plain text. For multiple paragraphs with spacing:

```html
<p>First paragraph.</p>
<p><br></p>
<p>Second paragraph with spacing above.</p>
```

**Note:** Each `attachable_sgid` can only be used once. Upload the file again for multiple uses.

---

## Default Behaviors

- **Card images:** Use inline (via `attachable_sgid` in description) by default. Only use background/header (`signed_id` with `--image`) when user explicitly says "background" or "header".
- **Comment images:** Always inline. Comments do not support background images.

---

# Accounts, Pagination, Status Queries, and jq

Load this reference when selecting an account, listing/searching cards, traversing pages, querying non-open states, or reducing JSON output.

## Global Flags

All commands support:

| Flag | Description |
|------|-------------|
| `--account SLUG` | Account slug (for multi-account users) |
| `--pretty` | Pretty-print JSON output |
| `--verbose` | Show request/response details |

---

## Pagination

List commands use `--page` for pagination. There is NO `--limit` flag.

```bash
# Get first page (default)
fizzy card list --page 1

# Get specific number of results using jq
fizzy card list --page 1 | jq '.data[:5]'

# Fetch ALL pages at once
fizzy card list --all
```

**IMPORTANT:** The `--all` flag controls pagination only - it fetches all pages of results for your current filter. It does NOT change which cards are included. By default, `card list` returns only open cards. See [Card Statuses](#card-statuses) for how to fetch closed or postponed cards.

Commands supporting `--all` and `--page`:
- `board list`
- `card list`
- `search`
- `comment list`
- `tag list`
- `user list`
- `notification list`

---

## Card Statuses

Cards exist in different states. By default, `fizzy card list` returns **open cards only** (cards in triage or columns). To fetch cards in other states, use the `--indexed-by` or `--column` flags:

| Status | How to fetch | Description |
|--------|--------------|-------------|
| Open (default) | `fizzy card list` | Cards in triage ("Maybe?") or any column |
| Closed/Done | `fizzy card list --indexed-by closed` | Completed cards |
| Not Now | `fizzy card list --indexed-by not_now` | Postponed cards |
| Golden | `fizzy card list --indexed-by golden` | Starred/important cards |
| Stalled | `fizzy card list --indexed-by stalled` | Cards with no recent activity |

You can also use pseudo-columns:

```bash
fizzy card list --column done --all     # Same as --indexed-by closed
fizzy card list --column not-yet --all  # Same as --indexed-by not_now
fizzy card list --column maybe --all    # Cards in triage (no column assigned)
```

The CLI pseudo-column value is `not-yet`; JSON column data may expose the corresponding pseudo ID as `not-now`, while `--indexed-by` uses `not_now`.

**Fetching all cards on a board:**

To get all cards regardless of status (for example, to build a complete board view), make separate queries:

```bash
# Open cards (triage + columns)
fizzy card list --board BOARD_ID --all

# Closed/Done cards
fizzy card list --board BOARD_ID --indexed-by closed --all

# Optionally, Not Now cards
fizzy card list --board BOARD_ID --indexed-by not_now --all
```

---

## Common jq Patterns

### Reducing Output

```bash
# Card summary (most useful)
fizzy card list | jq '[.data[] | {number, title, status, board: .board.name}]'

# First N items
fizzy card list | jq '.data[:5]'

# Just IDs
fizzy board list | jq '[.data[].id]'

# Specific fields from single item
fizzy card show 579 | jq '.data | {number, title, status, golden}'

# Card with description length (description is a string, not object)
fizzy card show 579 | jq '.data | {number, title, desc_length: (.description | length)}'
```

### Filtering

```bash
# Cards with a specific status
fizzy card list --all | jq '[.data[] | select(.status == "published")]'

# Golden cards only
fizzy card list --indexed-by golden | jq '[.data[] | {number, title}]'

# Cards with non-empty descriptions
fizzy card list | jq '[.data[] | select(.description | length > 0) | {number, title}]'

# Cards with steps (must use card show, steps not in list)
fizzy card show 579 | jq '.data.steps'
```

### Extracting Nested Data

```bash
# Comment text only (body.plain_text for comments)
fizzy comment list --card 579 | jq '[.data[].body.plain_text]'

# Rendered card body HTML. Use this before editing descriptions.
fizzy card show 579 | jq -r '.data.description_html'

# Step completion status
fizzy card show 579 | jq '[.data.steps[] | {content, completed}]'
```

### Activity Analysis

```bash
# Cards with steps count (requires card show for each)
fizzy card show 579 | jq '.data | {number, title, steps_count: (.steps | length)}'

# Comments count for a card
fizzy comment list --card 579 | jq '.data | length'
```

---

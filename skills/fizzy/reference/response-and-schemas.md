# Fizzy Responses and Schemas

Load this reference when parsing output, selecting `jq` paths, handling errors, or inspecting resource fields.

## Response Structure

All responses follow this structure:

```json
{
  "success": true,
  "data": { ... },           // Single object or array
  "summary": "4 boards",     // Human-readable description
  "breadcrumbs": [ ... ],    // Contextual next actions (omitted when empty)
  "meta": {
    "timestamp": "2026-01-12T21:21:48Z"
  }
}
```

**Summary field formats:**
| Command | Example Summary |
|---------|-----------------|
| `board list` | "5 boards" |
| `board show ID` | "Board: Engineering" |
| `card list` | "42 cards (page 1)" or "42 cards (all)" |
| `card show 123` | "Card #123: Fix login bug" |
| `search "bug"` | "7 results for \"bug\"" |
| `notification list` | "8 notifications (3 unread)" |

**List responses with pagination:**
```json
{
  "success": true,
  "data": [ ... ],
  "summary": "10 cards (page 1)",
  "pagination": {
    "has_next": true,
    "next_url": "https://..."
  },
  "meta": { ... }
}
```

**Breadcrumbs (contextual next actions):**

Responses include a `breadcrumbs` array suggesting what you can do next. Each breadcrumb has:
- `action`: Short action name (e.g., "comment", "close", "assign")
- `cmd`: Ready-to-run command with actual values interpolated
- `description`: Human-readable description

```bash
fizzy card show 42 | jq '.breadcrumbs'
```

```json
[
  {"action": "comment", "cmd": "fizzy comment create --card 42 --body \"text\"", "description": "Add comment"},
  {"action": "triage", "cmd": "fizzy card column 42 --column <column_id>", "description": "Move to column"},
  {"action": "close", "cmd": "fizzy card close 42", "description": "Close card"},
  {"action": "assign", "cmd": "fizzy card assign 42 --user <user_id>", "description": "Assign user"}
]
```

Use breadcrumbs to discover available actions without memorizing the full CLI. Values like card numbers and board IDs are pre-filled; placeholders like `<column_id>` need to be replaced.

**Error responses:**
```json
{
  "success": false,
  "error": {
    "code": "NOT_FOUND",
    "message": "Not Found",
    "status": 404
  },
  "meta": { ... }
}
```

**Create/update responses include location:**
```json
{
  "success": true,
  "data": { ... },
  "location": "/6102600/cards/579.json",
  "meta": { ... }
}
```

---

## Resource Schemas

Complete field reference for all resources. Use these exact field paths in jq queries.

### Card Schema

**IMPORTANT:** `card list` and `card show` return different fields. `steps` only in `card show`.

| Field | Type | Description |
|-------|------|-------------|
| `number` | integer | **Use this for CLI commands** |
| `id` | string | Internal ID (in responses only) |
| `title` | string | Card title |
| `description` | string | Plain text content (**NOT an object**) |
| `description_html` | string | HTML version with attachments |
| `status` | string | Usually "published" for active cards |
| `closed` | boolean | true = card is closed |
| `golden` | boolean | true = starred/important |
| `image_url` | string/null | Header/background image URL |
| `has_more_assignees` | boolean | More assignees than shown |
| `created_at` | timestamp | ISO 8601 |
| `last_active_at` | timestamp | ISO 8601 |
| `url` | string | Web URL |
| `comments_url` | string | Comments endpoint URL |
| `board` | object | Nested Board (see below) |
| `creator` | object | Nested User (see below) |
| `assignees` | array | Array of User objects |
| `tags` | array | Array of Tag objects |
| `steps` | array | **Only in `card show`**, not in list |

### Board Schema

| Field | Type | Description |
|-------|------|-------------|
| `id` | string | Board ID (use for CLI commands) |
| `name` | string | Board name |
| `all_access` | boolean | All users have access |
| `created_at` | timestamp | ISO 8601 |
| `url` | string | Web URL |
| `creator` | object | Nested User |

### User Schema

| Field | Type | Description |
|-------|------|-------------|
| `id` | string | User ID (use for CLI commands) |
| `name` | string | Display name |
| `email_address` | string | Email |
| `role` | string | "owner", "admin", or "member" |
| `active` | boolean | Account is active |
| `created_at` | timestamp | ISO 8601 |
| `url` | string | Web URL |

### Comment Schema

| Field | Type | Description |
|-------|------|-------------|
| `id` | string | Comment ID (use for CLI commands) |
| `body` | object | **Nested object with html and plain_text** |
| `body.html` | string | HTML content |
| `body.plain_text` | string | Plain text content |
| `created_at` | timestamp | ISO 8601 |
| `updated_at` | timestamp | ISO 8601 |
| `url` | string | Web URL |
| `reactions_url` | string | Reactions endpoint URL |
| `creator` | object | Nested User |
| `card` | object | Nested {id, url} |

### Step Schema

| Field | Type | Description |
|-------|------|-------------|
| `id` | string | Step ID (use for CLI commands) |
| `content` | string | Step text |
| `completed` | boolean | Completion status |

### Column Schema

| Field | Type | Description |
|-------|------|-------------|
| `id` | string | Column ID or pseudo ID ("not-now", "maybe", "done") |
| `name` | string | Display name |
| `kind` | string | "not_now", "triage", "closed", or custom |
| `pseudo` | boolean | true = built-in column |

### Tag Schema

| Field | Type | Description |
|-------|------|-------------|
| `id` | string | Tag ID |
| `title` | string | Tag name |
| `created_at` | timestamp | ISO 8601 |
| `url` | string | Web URL |

### Reaction Schema

| Field | Type | Description |
|-------|------|-------------|
| `id` | string | Reaction ID (use for CLI commands) |
| `content` | string | Emoji |
| `url` | string | Web URL |
| `reacter` | object | Nested User |

### Identity Schema (from `identity show`)

| Field | Type | Description |
|-------|------|-------------|
| `accounts` | array | Array of Account objects |
| `accounts[].id` | string | Account ID |
| `accounts[].name` | string | Account name |
| `accounts[].slug` | string | Account slug (use with --account) |
| `accounts[].user` | object | Your User in this account |

### Key Schema Differences

| Resource | Text Field | HTML Field |
|----------|------------|------------|
| Card | `.description` (string) | `.description_html` (string) |
| Comment | `.body.plain_text` (nested) | `.body.html` (nested) |

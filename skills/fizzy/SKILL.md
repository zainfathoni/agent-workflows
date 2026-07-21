---
name: fizzy
description: Manages Fizzy resources through its CLI. Use for card or board operations, account queries, search or notifications, uploads, or migrations.
---

# Fizzy CLI

Route every Fizzy request through the ordered process below. Load only the branch references whose firing conditions match the request.

## Universal invariants

### Identifiers

Cards expose two identifiers:

| Field | Format | Use |
|---|---|---|
| `number` | `579` | Every `card` CLI command and every `--card` value |
| `id` | `03fe4rug9kt1mpgyy51lq8i5i` | JSON relationships and internal identity |

Boards, columns, comments, steps, reactions, users, notifications, and other resources use their `id` field in CLI arguments. Preserve an entity's account context along with its identifier.

### Accounts

Commands operate in the selected account. Run `fizzy identity show` when the account is unknown or a request crosses accounts; select the account with global `--account SLUG`. Before account selection, completion means the intended account slug and the acting user are known.

### Discovery and output

Fizzy returns JSON envelopes. Use `jq` with the exact paths in [response and schemas](reference/response-and-schemas.md) rather than inferring shapes. In particular, card `.description` is a string, comment text is `.body.plain_text`, and steps occur in `card show`, not `card list`.

Responses can include `breadcrumbs` containing `action`, ready-to-run `cmd`, and `description`. Treat them as contextual action discovery: keep interpolated card/board values and replace angle-bracket placeholders such as `<column_id>` before execution.

List and search scope has two independent axes:

- Pagination chooses how many pages of the current filter to retrieve. `--all` fetches every page; it does not add another status.
- Status chooses which cards qualify. The default is open cards; closed, Not Now, golden, stalled, and pseudo-column views require their documented filters.

A complete board inventory therefore uses separate status queries and complete pagination for each included status. Completion means both axes match the user's requested scope.

### Mutations

Before a destructive, state-changing, or cross-account operation, resolve the target in the selected account and retain its number/ID. For card-description mutations, first load [card description formatting](reference/card-description-formatting.md); it is the sole authority for HTML, links, relationships, and image placement.

After every mutation, inspect `success`, `error`, and returned `data`/`location`, then read the changed resource with its show/list command. Compare the requested fields or relationship against the read-back value. For card descriptions, verification includes `.description_html` tags and clickable card relationships. Completion means the response succeeded and the persisted state—not merely the mutation response—matches the request.

Mutation verification is operation-specific:

| Mutation | Read-back evidence |
|---|---|
| Create/update | Returned number/ID plus requested fields from `show` |
| Move/column/status | Destination board/column or resulting lane/state |
| Assignment/tag/watch/pin/golden | Relationship or toggle state after the action |
| Comment/step/reaction | New child ID and content under the intended card/comment |
| Delete | Target no longer resolves or appears in the applicable list |
| Migration | Dry-run reviewed first; target board content and stated non-migrated relationships reconciled afterward |

Toggle commands such as assign and tag depend on current state. Discover that state first so the command reaches the requested result.

## Ordered command routing

### 1. Resolve intent and context

Identify the resource, action, supplied identifiers, desired state, and account. If the request names a card ID but needs a card command, discover its card number from JSON before continuing. If account context is ambiguous, resolve it with `identity show`.

**Complete when:** one account, one target resource, the CLI-form identifier, and the requested outcome are explicit.

### 2. Load branch reference

Load each matching reference before building the command:

- **Any command construction or flag choice:** [command inventory](reference/command-inventory.md), the authoritative inventory for all Fizzy commands and flags.
- **JSON parsing, error handling, field selection, or resource inspection:** [response and schemas](reference/response-and-schemas.md).
- **Account selection, list/search, filtering, status lanes, pagination, or `jq`:** [querying and accounts](reference/querying-and-accounts.md).
- **Creating/updating a card description, rich text, relationships, or images:** [card description formatting](reference/card-description-formatting.md).
- **Board migration:** [board migration behavior](reference/board-migration.md), plus the migration entry in the command inventory.
- **A multi-command card/step/image/move/search/reaction task:** the matching pattern in [example workflows](reference/example-workflows.md).

**Complete when:** all matched references have been read and every required argument can be sourced rather than guessed.

### 3. Discover before mutating

Use the narrowest list, search, show, identity, or breadcrumb query that resolves missing IDs and current state. Lists default to open cards and one page; when completeness matters, load the query reference and explicitly query every relevant status and page. Reduce large responses with documented `jq` paths.

For an existing description, read `.description_html`; preserve its structure and links unless replacement is intentional. For migration, establish source and target access and run the dry-run example first.

**Complete when:** every placeholder is replaced, current state is known, and the intended target is unique in the chosen account.

### 4. Execute safely

Construct the command from the inventory. Use HTML/file patterns and relationship rules from the formatting reference. Use inline images by default and header/background images only when explicitly requested. Run one mutation at a time when later commands depend on returned identifiers.

**Complete when:** the command returns a successful JSON envelope and any identifiers needed by subsequent operations have been extracted from documented paths.

### 5. Verify and report

Perform the read-after-write check from the mutation invariant. For multi-command work, verify each created relationship and final state. Report the account, card number or resource ID, resulting state, and any relevant URL; report structured Fizzy errors accurately.

**Complete when:** every requested mutation has persisted, every requested item is accounted for across pagination/status boundaries, and the report includes stable identifiers.

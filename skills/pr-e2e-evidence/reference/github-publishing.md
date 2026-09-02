# GitHub Evidence Publishing

Read this reference when local screenshots or videos must become GitHub-hosted PR or issue attachments.

## Preconditions

- Use GitHub CLI v2.99.0 or newer against GitHub.com.
- Authenticate `gh` with an OAuth token or classic personal access token that has push access to the repository.
- Keep images and GIFs at or below 10 MB. Keep videos at or below 10 MB on Free plans or 100 MB on paid plans.
- Attach PNG, JPEG, GIF, WebP, SVG, MP4, MOV, or WebM files. GitHub Enterprise Server does not support this flow.

**Complete when:** the CLI version, host, authentication, repository access, file types, and file sizes satisfy every precondition.

## Publish with `--attach`

Build the complete body before publication. Reference each image by its local path and meaningful alt text:

```md
![Checkout retains the selected date after refresh](docs/tests/web-123/checkout-after.png)
```

Reference each video with image syntax in its own paragraph so GitHub renders a player:

```md
![](docs/tests/web-123/checkout-save.webm)
```

Pass every referenced file through a repeatable `--attach` flag in the same command that writes the body. GitHub CLI uploads each file and rewrites the matching local path in place while preserving image alt text:

```bash
gh pr edit "$PR_NUMBER" \
  --body-file docs/tests/web-123/pr-body.md \
  --attach docs/tests/web-123/checkout-after.png \
  --attach docs/tests/web-123/checkout-save.webm
```

Use the same pattern with `gh pr create`, `gh pr comment`, `gh issue create`, `gh issue edit`, or `gh issue comment` when that command owns the publication target. An attached file not referenced in the body is appended in flag order. Add `#alt text` to an image attachment path only when appending it, for example `--attach 'checkout.png#Checkout confirmation'`; videos do not support attachment-flag alt text. Do not attach the same file twice in one command.

After publication, fetch the resulting body and confirm that every local reference became a distinct GitHub-hosted URL in the intended scenario. Inspect the rendered target at normal review size: every image must render, every video must expose a playable control, and all pre-existing body content must remain intact.

**Complete when:** one publication command has mapped every local artifact to the intended body location, and the fetched and rendered result passes every check.

## Fallbacks

When the native flow is unavailable, choose the first acceptable option:

1. Update GitHub CLI to v2.99.0 or newer when the current environment permits package changes.
2. Ask the user to upload the files and return the rendered Markdown or URLs when GitHub Enterprise Server, permissions, or environment ownership blocks native upload.
3. Use an external public host only with the user's explicit acceptance of its visibility and durability tradeoff.

Repository raw URLs, committed `docs/tests/` media, and notes-repository links count as final evidence only when they render reliably in the PR body or intentional comment. Mark an earlier broken or redundant comment as superseded and link to the rendered evidence. Delete a self-authored public comment only when the user explicitly requests that deletion.

GitHub documents no attachment-retention SLA, so keep structured PR text and decisive stills as the durable record.

**Complete when:** the selected fallback renders in the intended publication target and its access and durability tradeoffs are recorded.

---
name: pr-e2e-evidence
description: Runs repo-agnostic PR E2E evidence flow from PR creation through dev/preview/staging browser verification, before/after screenshots, and PR description updates. Use when asked to create a PR with E2E evidence, attach dev or staging browser evidence, capture browser screenshots, wait for deployment, compare baseline vs candidate, or update PR descriptions with collapsible QA sections.
---

# PR E2E Evidence

## Quick Start

Use after implementation is ready and the user wants PR E2E evidence: create a PR if missing, discover the repo's relevant PR and deployment conventions, exercise the affected browser workflow, capture evidence screenshots, draft the evidence under `docs/tests/` with embedded screenshots by default, upload the final evidence to the GitHub PR, wait for deployment when needed, capture deployed browser evidence, update the draft and PR again, then clean up any temporary browser/evidence helpers.

Evidence should be browser-facing:
- Dev, preview, or staging Chrome/browser verification.
- Before/after screenshots, focused after-only screenshots, console/network notes, and baseline-vs-candidate comparisons.
- Avoid duplicating non-browser implementation verification in the PR evidence unless the user explicitly asks for it.

Default draft evidence location:
- Use `docs/tests/<platform>-<id>/` as the working area for drafting PR evidence unless the repository already has a more specific documented convention. Examples: `docs/tests/github-123/`, `docs/tests/linear-ABC-123/`, or `docs/tests/jira-PROJ-123/`.
- Store the draft Markdown at `docs/tests/<platform>-<id>/<file>.md`.
- Store draft screenshots in the same `docs/tests/<platform>-<id>/` area, preferably in a sibling assets directory or a subdirectory named after the draft document.
- Embed screenshots in the Markdown draft with relative paths so the evidence can be reviewed locally, for example `![Dev booking save evidence](./<assets-dir>/dev-booking-save.png)`.
- Treat the `docs/tests/<platform>-<id>/<file>.md` document as an intermediary artifact for composing the final PR evidence. The final evidence belongs in the actual GitHub PR description or PR attachments, not only in `docs/tests/`.
- Unless the user asks to commit the draft evidence, remove or leave uncommitted any temporary `docs/tests/<platform>-<id>/` draft files after the PR has been updated.

## Repo Discovery

Before collecting evidence, inspect the repository for local conventions:

- PR template sections and expected placement for E2E evidence.
- Deployment environments such as local dev, preview, staging, production baseline, or other named environments.
- Browser surfaces, route paths, user roles, tenant/account setup, feature flags, and data fixtures needed for reliable evidence.

If the relevant environment or browser surface is unclear, ask the user before collecting evidence.

## PR Creation

- Check for an existing PR before creating one:
  `gh pr list --head $(git branch --show-current) --json number,title,url,state`
- If missing, create the PR with the repository's PR template preserved.
- Use `gh pr edit` for description updates.

## Dev Or Preview E2E Browser Evidence

Exercise the affected user workflow in the closest relevant browser environment: local dev, preview, staging, or a production baseline plus candidate deployment. Capture the state that proves the behavior, preferably at the decision point before the action and the resulting state after the action.

Record environment, route or scenario, selected fixture/data, result, notable console/network observations, and cleanup performed.

## PR Description Format

Add or update a `## E2E evidence` section in the PR body. Preserve the repository's PR template and place the section near existing checklist, QA, or validation sections when present. By default, first draft the full evidence in a Markdown document at `docs/tests/<platform>-<id>/<file>.md` with screenshots embedded via relative paths, then use that draft to update the actual GitHub PR with the final evidence.

Default to putting pre-merge evidence in the PR description, not in a PR comment. The PR body is the review artifact while the PR is still open. Comments are appropriate for post-production deployment evidence after the PR has already been merged, when the comment serves as a deployment follow-up record rather than review evidence. Comments are also acceptable when the repository convention or user explicitly asks for a comment, or when the PR body is not editable. If the comment editor is used only as GitHub's attachment uploader, extract the `user-attachments` URLs, clear the editor, and do not submit the comment.

Default `docs/tests/` draft document format:

````md
# E2E evidence: <PR title or feature>

Environment:
- Branch: `<branch>`
- Commit: `<commit>`
- Primary URL: `<url>`
- Candidate URL: `<url-if-used>`
- Baseline URL: `<url-if-used>`

## Summary

- `<browser scenario>`: `<result>`

## Evidence

### Browser verification

Result:
- `<verified behavior>`

Console/network notes:
- `<notable warnings or none>`

![Scenario label](./<assets-dir>/<scenario-screenshot>.png)
````

Use a stable, descriptive path such as `docs/tests/github-123/e2e-evidence.md`, `docs/tests/linear-ABC-123/e2e-evidence.md`, or `docs/tests/jira-PROJ-123/e2e-evidence.md`. After the draft is complete, upload or embed the screenshots in the GitHub PR and copy the relevant Markdown into the PR body. Do not leave the PR pointing only to local draft evidence unless the repository explicitly expects committed evidence documents.

### Uploading screenshots to GitHub-hosted attachments

When the user wants the agent to attach screenshots directly to a GitHub PR or issue, prefer GitHub-hosted attachment URLs over repository raw URLs. `raw.githubusercontent.com` links from a separate notes/assets repository may not render reliably in PR conversations. GitHub-hosted attachment URLs look like:

```md
![Scenario label](https://github.com/user-attachments/assets/<uuid>)
```

Use this browser-based upload flow when Chrome DevTools is available and the browser is logged in to GitHub. The default pre-merge target is the PR body, with the comment editor used only as an attachment URL generator:

1. Open the PR or issue conversation in the browser.
2. Scroll to the comment editor.
3. Use the editor's "Paste, drop, or click to add files" / attachment target to upload each local screenshot.
4. Wait for each placeholder such as `![Uploading screenshot.png…]()` to become a completed Markdown or HTML embed containing `https://github.com/user-attachments/assets/...`.
5. Extract the inserted attachment URLs from the editor text.
6. Clear the comment editor and verify the PR comment button is disabled or the editor is empty.
7. Add the uploaded attachment URLs to the structured `## E2E evidence` section in the PR body with `gh pr edit --body-file` or the browser edit UI.
8. Verify the PR body contains the new `user-attachments` URLs and that no new PR comment was posted.

Only submit a PR comment when that is intentionally the final evidence location. The common intentional case is post-production deployment evidence after the PR is merged. If an earlier comment used non-rendering raw URLs, prefer deleting it when redundant and authored by you; otherwise edit it to say it is superseded and link to the rendered attachment-hosted evidence.

Practical DevTools pattern:

```text
upload_file(uid=<attachment drop target>, filePath=<local screenshot>)
wait until the editor text contains `user-attachments` and no longer contains `Uploading`
repeat for each screenshot
read the editor text and map alt text / filename to attachment URL
clear the editor value and dispatch input/change events
update the PR body with the final grouped Markdown evidence
verify comment count did not increase
```

For many screenshots, upload one at a time or in small batches. After each upload, verify the count of `user-attachments` URLs increased before starting the next upload. This avoids losing track of failed, slow, or still-pending uploads.

If browser upload is unavailable, optional fallbacks are:

- Ask the user to upload the files manually and provide the rendered Markdown/URLs.
- Use a CLI helper such as `gh image` / `gh-image` only if it is already installed or acceptable to install, and only if it can access a valid GitHub browser session token.
- Use an external public image host only when the user explicitly accepts that visibility and durability tradeoff.

Do not treat screenshots committed to `docs/tests/` or a notes repository as final PR evidence unless the PR comment/body embeds renderable image URLs.

### Evidence Dos and Don'ts

Do:

- Ground the browser surface before claiming coverage. If a customer reports a Calendar widget, verify whether the live page is the app-proxy Calendar page, an embedded React/xcomponent Calendar widget, an Upcoming Event widget, or a different storefront surface.
- Use the closest matching deployed route for staging/preview evidence. For example, staging Shopify app proxies may use a different path prefix than production, such as `/apps/bookthatapp-staging` instead of `/apps/bookthatapp`; discover and record that difference.
- Capture the interaction mode that matches the report. If the bug occurs in list view, include list-view evidence even if month-view evidence also passes.
- Include enough route/data context in the PR body for reviewers to reproduce the evidence: store, environment, path, fixture/event/product name, selected date/filter, and target URL after click.
- Note unrelated console/network noise separately instead of hiding it. State whether it blocked the scenario or was outside the behavior under test.
- Keep local draft evidence and annotated screenshots useful for review, but treat them as source material for the PR body, not as the final artifact.

Don't:

- Don't leave a PR comment just to get GitHub attachment URLs. Upload through the comment box if needed, extract the URLs, clear the editor, and put the evidence in the PR description by default.
- Don't use PR comments for normal pre-merge review evidence unless explicitly requested. Save comments for post-production deployment evidence after merge, repository convention, or body-not-editable cases.
- Don't use public upload helpers or image hosts when the user asks for Chrome/GitHub attachment uploads or when visibility matters.
- Don't assume the homepage has the same widgets across dev, staging, and production. If the requested storefront lacks the widget, use a documented app-proxy/admin-preview route or explain the closest available equivalent.
- Don't mark a production issue as addressed solely because a related widget passes. Confirm the exact reported widget path or explicitly document which surface remains unverified.
- Don't conflate navigation success with downstream product-widget health. A product-page reservation/checking error after navigation can be unrelated to a Calendar link-click fix; record it separately.

For E2E browser evidence:

````md
## E2E evidence

<details>
<summary>Dev browser verification</summary>

Passed on dev.

Result:
- `<verified behavior>`

Screenshots:
- `<scenario label>`:
  <uploaded or embedded in the GitHub PR; drafted first in `docs/tests/<platform>-<id>/<file>.md`>

</details>

<details>
<summary>Staging browser verification</summary>

Pending staging deployment.

</details>
````

After staging or preview deployment is ready, replace pending text with result and screenshot reference.

For manual browser verification evidence, use the same `## E2E evidence` placement and use a summary that names the evidence type:

````md
## E2E evidence

<details>
<summary>Manual browser verification evidence</summary>

Passed on dev.

Environment:
- Branch: `<branch>`
- Commit: `<commit>`
- Primary URL: `<url>`
- Candidate URL: `<url>`
- Baseline URL: `<url-if-used>`

Result:
- `<verified behavior>`

Console/network notes:
- `<notable warnings or none>`

Screenshots:
- `<scenario label>`:
  <uploaded or embedded in the GitHub PR; drafted first in `docs/tests/<platform>-<id>/<file>.md`>

</details>
````

### Manual Before/After Browser Evidence

Use this when the PR needs visual regression-style evidence across a baseline environment and a candidate environment.

Process:

1. Capture matching baseline and candidate screenshots for each route or scenario.
   - Use the stable deployed environment as the before baseline.
   - Use the PR, dev, preview, or staging deployment as the after candidate.
   - Keep viewport, scroll position, filters, date ranges, selected records, account, role, feature flags, and relevant UI mode as similar as practical.
   - If exact parity is impossible, note the reason in the PR description.
2. Combine each before/after pair into one image.
   - Left side: `Before: <baseline environment>`.
   - Right side: `After: <candidate environment>`.
   - Include the page or scenario title in the image.
   - Do not add highlights unless the user explicitly asks; highlights can obscure the UI evidence.
3. Move draft screenshots into the `docs/tests/<platform>-<id>/` evidence directory by default.
   - Use descriptive filenames, for example `<ticket-or-pr>-<date>-<route-or-scenario>-before-after.png`.
   - Embed each screenshot in the corresponding `docs/tests/<platform>-<id>/<file>.md` draft with a relative path.
   - Upload the final screenshots to the PR description or PR attachments before considering the evidence complete.
   - Tell the user which files to upload to the PR description when manual upload is required.
4. After the screenshots are uploaded to the PR, update the PR description.
   - Group screenshots by surface area or scenario, not upload order.
   - Add the corresponding route path or scenario above each image.
   - Explain what each screenshot demonstrates.
   - Do not mention "previously uploaded"; present the PR as one unified review artifact.
   - If a screenshot is after-only, label it honestly as focused after evidence.

Before/after PR description example:

````md
Screenshots:

The before/after screenshots compare the baseline environment against the candidate deployment. They focus on the route surfaces affected by this PR.

Main workflow before/after:

- Scenario label: `/example/route`
  <img ... />

Settings surface before/after:

- Scenario label: `/example/settings`
  <img ... />

Focused evidence:

- Scenario label: `/example/focused-route`
  <img ... />
````

## Deployed E2E

After the relevant deployment is ready, repeat the browser workflow in the deployed environment. If a surface is unavailable in one environment, choose the closest supported equivalent and explain the difference in the PR evidence.

For post-production deployment evidence after the PR is merged, a PR comment is acceptable and often preferable: the PR body already served its review purpose, and the comment records the deployed verification chronologically. Still use GitHub-hosted attachments, group screenshots by scenario, include production URLs and console/network notes, and avoid throwaway upload-only comments.

## Checklist

- [ ] Existing PR checked or new PR created.
- [ ] PR template and deployment conventions discovered.
- [ ] Relevant dev or preview browser evidence captured.
- [ ] Browser screenshots captured.
- [ ] E2E evidence drafted at `docs/tests/<platform>-<id>/<file>.md` unless the repository has a more specific documented convention.
- [ ] Evidence screenshots stored under `docs/tests/<platform>-<id>/` and embedded in the draft with relative paths.
- [ ] Final evidence screenshots uploaded or embedded in the actual GitHub PR.
- [ ] GitHub-hosted attachment URLs (`github.com/user-attachments/assets/...`) used when the user wants agent-uploaded screenshots in a GitHub PR/issue.
- [ ] Each uploaded screenshot verified to have completed from `Uploading...` placeholder to a stable attachment URL before using it in the PR body or submitting an intentional comment.
- [ ] Comment editor cleared after attachment upload when the PR body is the final evidence location.
- [ ] PR comment count checked when the user asked for PR-body evidence or no redundant comments.
- [ ] Evidence screenshots copied to an upload-ready directory when user will attach manually.
- [ ] PR description updated with `## E2E evidence` near the repository's existing QA or checklist sections.
- [ ] PR description updated with `<details><summary>Dev browser verification</summary>` or a more accurate environment label.
- [ ] Deployment readiness confirmed when deployed evidence is needed.
- [ ] Relevant deployed-environment browser evidence captured.
- [ ] Baseline and candidate URLs identified when before/after evidence is used.
- [ ] Matching baseline and candidate screenshots captured.
- [ ] Before/after screenshots combined into paired images.
- [ ] User uploaded screenshots to GitHub PR description when manual upload is required, or agent uploaded/embedded them when possible.
- [ ] PR description updated with route paths or scenario labels and explanations for each screenshot.
- [ ] Any after-only or non-parity screenshots are clearly labeled.
- [ ] PR description updated with deployed-environment evidence when required.
- [ ] Post-production deployment evidence posted as an intentional PR comment only after merge, when applicable.
- [ ] Any earlier broken/raw-link evidence comment marked as superseded and linked to the rendered attachment-hosted evidence.
- [ ] Temporary browser/evidence helpers stopped or cleaned up.

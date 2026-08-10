---
name: pr-e2e-evidence
description: Collects and publishes browser-facing PR E2E evidence. Use for static pre-merge screenshots, baseline/candidate UI comparison, bounded interaction video, or post-deployment verification.
---

# PR E2E Evidence

Produce a compact, reproducible browser record that lets a reviewer judge the PR without reconstructing the test session.

## Evidence Contract

- Populate the evidence section with browser verification; add implementation verification when the user explicitly requests it.
- Name the exact environment, route, browser surface, role, fixture or data, interaction mode, and result needed to reproduce each claim.
- Keep claims bounded to the scenario exercised. Record unrelated console or network noise separately and state whether it blocked the scenario.
- Provide an adjacent text verdict for every visual artifact. Prefer PR prose over baked video captions when the native interaction and result are already visible; when annotation is necessary, use labels in addition to color without covering live UI.
- Treat GitHub attachment URLs as shareable. Never capture secrets or sensitive merchant or customer data.

## Screenshot or Video Gate

Use screenshots by default. Prefer one cropped, annotated before/after composite when a decision point and result tell the story together; focused after-only evidence is valid when labeled honestly.

Choose video when motion, timing, or a multi-stage interaction is itself the evidence: navigation guards, loading transitions, save/discard lifecycles, animation, or layout shifts. Keep a decisive still and text verdict as the canonical review record. Treat the named scenario as the video's full coverage boundary.

## Ordered Evidence Process

### 1. Discover the local contract

Inspect the repository's PR template and documented QA, deployment, route, role, tenant/account, feature-flag, fixture, and evidence conventions. Check for an existing PR before creating one:

```bash
gh pr list --head "$(git branch --show-current)" --json number,title,url,state
```

If no PR exists and PR creation is in scope, create one while preserving the template. Ask one narrow question when the relevant environment or browser surface remains ambiguous after discovery.

**Complete when:** the PR target, template placement, environment, exact browser surface, access context, and required deployment follow-up are known.

### 2. Define the proof

Write a bounded scenario with its starting state, action, expected result, route, fixture/data, and meaningful console or network checks. For a regression comparison, identify the stable baseline and candidate and align viewport, scroll position, filters, dates, account, role, flags, and UI mode as closely as practical.

**Complete when:** every intended claim maps to one reproducible browser scenario and any unavoidable baseline/candidate mismatch is recorded.

### 3. Choose the smallest decisive medium

Apply the screenshot-or-video gate above. Use the closest relevant browser environment: local dev, preview, staging, or a production baseline plus candidate deployment.

- For screenshots or manual before/after comparison, read [`reference/screenshots.md`](reference/screenshots.md) before capture.
- For temporal evidence, read [`reference/video.md`](reference/video.md) before recording.

**Complete when:** each scenario has one chosen medium and the selected branch reference has been read.

### 4. Capture and inspect

Exercise the real interaction mode and capture only the state needed to prove the result. Ground the exact surface before claiming coverage: related widgets or routes are separate claims. Inspect final media at normal review size; recapture evidence that shows stale loading, the wrong state, hidden labels, or misleading crops.

**Complete when:** every claim has inspected media showing the named surface, action or comparison, and result, with no sensitive data.

### 5. Compose the local draft

Create `docs/tests/<platform>-<id>/<file>.md`, store draft screenshots in the same evidence area, and embed them with relative paths. Record branch and commit, URLs, scenario, result, reproduction context, console/network notes, limitations, and cleanup. Read [`reference/pr-templates.md`](reference/pr-templates.md) when composing the draft or PR section.

Treat this directory as working material for the final PR evidence rather than the final destination.

**Complete when:** the local Markdown renders as a self-contained review draft and every media reference resolves relatively.

### 6. Publish the pre-merge evidence

Make the open PR body the final pre-merge evidence location. A repository convention, explicit user request, or uneditable body may select an intentional comment instead. Transfer the structured evidence and embed renderable media. When GitHub-hosted attachment upload is needed, read and follow [`reference/github-publishing.md`](reference/github-publishing.md). The comment editor may generate attachment URLs, but never submit an upload-only comment; clear it after extracting the URLs.

Use `gh pr edit --body-file` or the browser edit UI. Group evidence by scenario or surface, preserve the existing template, and explain what each artifact demonstrates.

**Complete when:** the chosen PR location renders the structured evidence and all media, existing template content remains intact, and no unintended comment was created.

### 7. Follow the deployment

When preview, staging, or production verification is required, keep that environment marked pending until it is ready, then repeat the same bounded scenario in the deployed environment. Use the closest supported equivalent when a surface is unavailable and explain the difference.

Update the local draft while it remains active. Before merge, replace pending body text with the deployed result. After merge, an intentional PR comment may record production verification chronologically; use GitHub-hosted attachments, production URLs, scenario grouping, and console/network notes.

**Complete when:** each required environment is either explicitly pending with a reason or published with a reproducible result in the correct PR location.

### 8. Clean up and report

Remove temporary browser helpers and recording overlays. Remove or leave uncommitted the `docs/tests/` draft and generated media unless the user requested a commit or the repository requires durable evidence. Retain raw local video only until upload and playback are confirmed.

Report the PR URL, environments verified, scenarios and verdicts, evidence location, deployment status, limitations, and cleanup state.

**Complete when:** temporary processes and helpers are stopped, the worktree contains only intended durable files, published evidence is still accessible, and the owner has a concise verification summary.

---
name: pr-e2e-evidence
description: Runs repo-agnostic PR QA evidence flow from PR creation through dev/preview/staging E2E, manual browser verification, before/after screenshots, Playwright report screenshots, and PR description updates. Use when asked to create a PR with E2E evidence, attach dev or staging results, capture report or browser screenshots, wait for deployment, compare baseline vs candidate, or update PR descriptions with collapsible QA sections.
---

# PR E2E Evidence

## Quick Start

Use after implementation is ready and the user wants PR QA evidence: create a PR if missing, discover the repo's relevant test and deployment conventions, run the appropriate automated or manual checks, capture evidence screenshots, update the PR, wait for deployment when needed, capture deployed evidence, update the PR again, then stop any temporary report servers.

Evidence can be either:
- Automated E2E, such as command output and report screenshots.
- Manual browser verification, such as Chrome or Browser screenshots, console/network notes, and baseline-vs-candidate comparisons.

## Repo Discovery

Before running checks, inspect the repository for local conventions:

- Test commands in `package.json`, task files, CI workflows, Makefiles, docs, or project instructions.
- PR template sections and expected placement for test evidence.
- Deployment environments such as local dev, preview, staging, production baseline, or other named environments.
- Browser surfaces, route paths, user roles, tenant/account setup, feature flags, and data fixtures needed for reliable evidence.

If the relevant command, environment, or surface is unclear, ask the user before collecting evidence.

## PR Creation

- Check for an existing PR before creating one:
  `gh pr list --head $(git branch --show-current) --json number,title,url,state`
- If missing, create the PR with the repository's PR template preserved.
- Use `gh pr edit` for description updates.

## Dev Or Preview E2E

Run the affected specs only unless the user asks for the entire suite.

```bash
<e2e-command> <affected-specs>
```

Record environment, exact command, result line, and failures/retries if any.

## Playwright Report Screenshot

If the repo uses Playwright HTML reports, serve the latest report with the repo's command. A common command is:

```bash
PLAYWRIGHT_HTML_OPEN=never npx playwright show-report --host 127.0.0.1 --port 9323 >/tmp/playwright-report-9323.log 2>&1 &
```

Capture with the available browser tool: open `http://127.0.0.1:9323`, verify the summary, take a full-page screenshot, not viewport-only, and save it with a descriptive name such as `~/Downloads/dev-e2e-playwright-report-full.png`, `~/Downloads/preview-e2e-playwright-report-full.png`, or `~/Downloads/staging-e2e-playwright-report-full.png`.

Always stop the report server after capture:

```bash
lsof -ti tcp:9323 | xargs -r kill
```

## PR Description Format

Add or update a `## Test results` section in the PR body. Preserve the repository's PR template and place the section near existing checklist, testing, QA, or validation sections when present.

For E2E evidence:

````md
## Test results

<details>
<summary>Dev E2E result</summary>

Passed on dev.

Command: `<command>`
Result: `<result>`
Screenshot: <attach after upload or note local filename>

</details>

<details>
<summary>Staging E2E result</summary>

Pending staging deployment.

</details>
````

After staging or preview deployment is ready, replace pending text with command, result, and screenshot reference.

For manual browser verification evidence, use the same `## Test results` placement and use a summary that names the evidence type:

````md
## Test results

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
  <attach after upload or note local filename>

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
3. Move final upload-ready screenshots into one directory.
   - Use descriptive filenames, for example `<ticket-or-pr>-<date>-<route-or-scenario>-before-after.png`.
   - Tell the user which files to upload to the PR description when manual upload is required.
4. After the user uploads all screenshots, update the PR description.
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

After the relevant deployment is ready, run the repo's deployed-environment command, for example:

```bash
<staging-or-preview-e2e-command> <affected-staging-or-preview-specs>
```

Use the environment and test project that the repository supports. If a surface is unavailable in one environment, choose the closest supported equivalent and explain the difference in the PR evidence.

## Checklist

- [ ] Existing PR checked or new PR created.
- [ ] Repo-local test command, PR template, and deployment conventions discovered.
- [ ] Relevant dev or preview evidence captured: automated E2E result, manual browser run, or both.
- [ ] Playwright full-page report screenshot captured when automated E2E is used and a report is available.
- [ ] Browser screenshots captured when manual verification is used.
- [ ] Evidence screenshots copied to an upload-ready directory if user will attach manually.
- [ ] PR description updated with `## Test results` near the repository's existing testing or checklist sections.
- [ ] PR description updated with `<details><summary>Dev E2E result</summary>` or a more accurate environment label.
- [ ] Deployment readiness confirmed when deployed evidence is needed.
- [ ] Relevant deployed-environment evidence captured: automated E2E result, manual browser run, or both.
- [ ] Deployed Playwright full-page report screenshot captured when automated E2E is used and a report is available.
- [ ] Baseline and candidate URLs identified when before/after evidence is used.
- [ ] Matching baseline and candidate screenshots captured.
- [ ] Before/after screenshots combined into paired images.
- [ ] User uploaded screenshots to GitHub PR description when manual upload is required.
- [ ] PR description updated with route paths or scenario labels and explanations for each screenshot.
- [ ] Any after-only or non-parity screenshots are clearly labeled.
- [ ] PR description updated with deployed-environment results when required.
- [ ] Temporary report servers stopped with `lsof -ti tcp:9323 | xargs -r kill` or the appropriate port cleanup command.

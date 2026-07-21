# Evidence Templates

Read this reference while composing the local draft or the PR's `## E2E evidence` section. Adapt labels to the repository and omit fields that do not apply.

## Local draft

Use a stable path such as `docs/tests/github-123/e2e-evidence.md`, `docs/tests/linear-ABC-123/e2e-evidence.md`, or `docs/tests/jira-PROJ-123/e2e-evidence.md`.

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

### <scenario and environment>

Result:
- `<verified behavior>`

Reproduction context:
- Route/surface: `<route and exact surface>`
- Fixture/data: `<fixture, selected date/filter, or record>`

Console/network notes:
- `<notable warnings or none>`

![Scenario label](./<assets-dir>/<scenario-screenshot>.png)
````

## PR body section

Place this near the repository's QA, validation, or checklist section without replacing template content:

````md
## E2E evidence

<details>
<summary>Dev browser verification</summary>

Passed on dev.

Result:
- `<verified behavior>`

Reproduction context:
- Route/surface: `<route and exact surface>`
- Fixture/data: `<fixture or record>`

Console/network notes:
- `<notable warnings or none>`

Screenshots:
- `<scenario label>`
  <GitHub-hosted attachment markup>

</details>

<details>
<summary>Staging browser verification</summary>

Pending staging deployment.

</details>
````

Use `Manual browser verification evidence` when that is the accurate summary. For baseline/candidate comparisons, state both URLs and explain any parity gap. Label focused after-only evidence honestly.

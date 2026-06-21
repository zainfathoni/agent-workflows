# HOSTING.md Format

`HOSTING.md` lives at the teaching workspace root. It records how this workspace's static lessons and reference documents are previewed or published. Hosting is intentionally workspace-owned: `teach` should not assume every workspace uses Tailscale, GitHub Pages, or a custom app.

Create this file lazily — only when a hosted URL is needed or the user has chosen a hosting method.

## Template

````md
# Hosting: {Workspace name}

## Method
{One or two sentences describing how lessons are hosted. Examples: custom static app at `https://ai.zainf.dev/`, GitHub Pages, Tailscale serve, local-only file viewing.}

## Base URLs
- Production: {https://example.com/ or "none"}
- Preview/local: {http://localhost:3000/ or file:// path, if relevant}

## Path mapping
- `lessons/0001-example.html` → `{base-url}/lessons/0001-example.html`
- `reference/example.html` → `{base-url}/reference/example.html`
- `assets/lesson.css` → `{base-url}/assets/lesson.css`

## Publish or serve command
```bash
{command that publishes or serves the workspace, or "none — host watches the repository"}
```

## Verification
```bash
{curl -I or other command that proves a lesson URL is live}
```

## Notes
- {Authentication, tailnet-only constraints, deployment lag, branch/source of truth, or "local-only" caveats}
````

## Rules

- **Be concrete.** Record the actual base URL and path mapping, not just "hosted somewhere".
- **Keep it static-friendly.** Lessons and assets should work without a build step unless the user explicitly accepts a workspace-specific app pipeline.
- **Verify before sharing.** When handing over a hosted lesson link, run the verification command or clearly say it was not verified.
- **Do not globalize local hosting.** Tailscale, GitHub Pages, and custom domains are workspace choices, not generic `teach` defaults.
- **Update when hosting moves.** If a workspace changes from Tailscale to a custom domain, update this file rather than editing the skill.

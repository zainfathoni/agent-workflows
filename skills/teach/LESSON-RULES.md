# Lesson Rules

## Lesson shape

A lesson is one short HTML file in `lessons/`, named `0001-<dash-case-name>.html`, `0002-<dash-case-name>.html`, etc. Scan `lessons/` for the highest existing number and increment it; never reuse a lesson number. Each lesson teaches one tightly-scoped idea tied to the mission and gives the user one tangible win.

Start each workspace from [lesson-template.html](./lesson-template.html): seed the first lesson and shared assets from its accessible baseline, then factor repeated styling and behaviour into `assets/`.

Every lesson should:

- be beautiful, readable, and accessible;
- include viewport metadata and WCAG AA body-text contrast;
- keep dark callout boxes legible by overriding nested `code`/`pre` colours;
- link to related lessons and reference docs;
- recommend one primary high-trust source;
- remind the user to ask follow-up questions.

## Assets

`assets/*` is the default architecture for reusable components: stylesheets, quiz widgets, simulators, diagrams, and generated media. Before authoring a lesson, read existing assets and reuse them. Add a shared stylesheet as the first reusable component a growing workspace earns.

Keep assets portable: they should work over `file://` and ordinary static hosting without a build step. Tailscale, GitHub Pages, custom domains, or repo-specific app deployments belong in `HOSTING.md`. Do not add package managers, bundlers, CDNs, or network-only dependencies unless the user accepts that workspace trade-off.

## Hosting

Hosting is workspace-owned. Read `HOSTING.md` before sharing remote lesson URLs. If hosted links are needed and `HOSTING.md` is missing, create it from [HOSTING-FORMAT.md](./HOSTING-FORMAT.md) after confirming the method.

When handing over a lesson, prefer:

1. verified hosted URL from `HOSTING.md`;
2. local file opened with `open`;
3. a prompt to define hosting if cross-device access is needed.

For private tailnet workspaces, [serve-lessons.sh](./serve-lessons.sh) remains available. Follow [TAILSCALE-HOSTING.md](./TAILSCALE-HOSTING.md) before sharing a tailnet URL.

```bash
~/.agents/skills/teach/serve-lessons.sh [TEACH_DIR] [PORT] [URL_PATH]
```

## Codebase source links

When a lesson/reference cites real source code, include both links:

- local VS Code deep link: `vscode://file/<absolute-path>:<line>`; use one slash after `file`;
- pinned GitHub permalink: `https://github.com/<owner>/<repo>/blob/<commit-SHA>/<repo-rel-path>#L<line>`.

Re-derive line numbers against the exact commit before linking. Render both as small source chips (`.vsc` and `.gh`) under the relevant code block. The GitHub permalink is the portable link for phones, tablets, shared docs, and hosted lessons.

## Reference documents

Reference docs in `reference/*.html` are the compressed essence of lessons: cheat sheets, maps, algorithms, syntax, pose lists, routines, or glossaries. They should share assets with lessons and link back to relevant lessons.

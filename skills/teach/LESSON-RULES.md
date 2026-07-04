# Lesson Rules

## Lesson shape

A lesson is one short HTML file in `lessons/`, named `0001-<dash-case-name>.html`, `0002-<dash-case-name>.html`, etc. Scan `lessons/` for the highest existing number and increment it; never reuse a lesson number. Each lesson teaches one tightly-scoped idea tied to the mission and gives the user one tangible win.

Start each workspace from [lesson-template.html](./lesson-template.html): seed the first lesson and shared assets from its accessible baseline, then factor repeated styling and behaviour into `assets/`.

Every lesson should:

- embed a micro-world when the topic is a mechanism (see "Micro-worlds" below);
- embed an in-page quiz widget (see [QUIZ-FEEDBACK.md](./QUIZ-FEEDBACK.md));
- be beautiful, readable, and accessible;
- include viewport metadata and WCAG AA body-text contrast;
- keep dark callout boxes legible by overriding nested `code`/`pre` colours;
- make code blocks listenable in screen readers, especially mobile Safari;
- link to related lessons and reference docs;
- recommend one primary high-trust source;
- remind the user to ask follow-up questions.

## Micro-worlds

When a lesson teaches a mechanism or system (not a pure fact, glossary, or routine), embed a **micro-world**: a small self-contained simulator inside the lesson HTML that lets the learner drive the mechanism and watch consequences form (Papert's "Mathland"; Geoffrey Litt, ["Understanding is the new bottleneck"](https://www.geoffreylitt.com/2026/07/02/understanding-is-the-new-bottleneck.html), 2026-07-02).

- Vanilla inline JS/CSS, working over `file://` like every other asset — no build step, no CDN.
- The learner manipulates the same variables the real system has (modes, inputs, ordered phases), and the display shows the system's *internal* view — its clusters, queues, decisions — not just the final output.
- Deterministic by default, so the learner can replay and compare runs; add randomness only when variance is the point.
- Pair it with a visible "Things to try" prompt naming the contrast the learner should go look for.
- A mechanism lesson is not done until the target misconception can be both **reproduced and resolved inside the micro-world** — if the simulator can't show the failure and the fix, it is decoration, not a micro-world.

## Screen-reader and listening support

Lessons are often consumed by listening, not looking. Treat raw code as a visual artifact that needs an audio-friendly companion.

For every non-trivial code block:

1. Put the code in a `<figure>` with a short `<figcaption>` that states what the snippet demonstrates.
2. Add a visible prose summary immediately before the code, using a class such as `.listen`. Explain the code in words a screen reader can read naturally: name the key identifiers, say what changes, and describe symbols by purpose rather than dumping punctuation.
3. Put the raw code in `<pre aria-hidden="true">`. Do not add `role="img"`, `aria-label`, or `tabindex` to the `<pre>`.

The raw code stays visible and selectable for sighted users, but the `.listen` prose is the accessible equivalent. This is intentional for punctuation-heavy snippets: WebKit/VoiceOver does not treat `role="img"` as a leaf when a `<pre>` has rendered text children, so Safari still descends into the code and reads symbols one by one. Hiding the raw `<pre>` from the accessibility tree avoids that failure mode and lets VoiceOver read only the human-friendly summary.

Also keep lesson HTML structurally navigable:

- include a skip link to `<main>`;
- use one `<h1>` and ordered heading levels;
- write descriptive link text instead of "click here";
- give images meaningful `alt` text, or empty `alt=""` only for decorative images;
- avoid conveying meaning with colour, emoji, or punctuation alone;
- label source chips clearly, e.g. `aria-label="Open local source file.ext line NN in VS Code"` and `aria-label="Open pinned GitHub source for file.ext line NN"`.

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

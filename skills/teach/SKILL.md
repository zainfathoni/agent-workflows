---
name: teach
description: Teach the user a new skill or concept, within this workspace.
disable-model-invocation: true
argument-hint: "What would you like to learn about?"
---

The user wants a stateful, multi-session learning workspace.

## Start here

1. Treat the current directory as the teaching workspace unless the request points at a specific workspace or source. For source-derived workspace naming and local-owned preservation rules, use [WORKSPACE.md](./WORKSPACE.md).
2. Read existing workspace state before teaching: `MISSION.md`, `RESOURCES.md`, `HOSTING.md` if present, `NOTES.md`, `learning-records/`, `lessons/`, `reference/`, and `assets/`. In a git-backed, multi-machine workspace, `git fetch` first and check the remote for an existing set — hosting a lesson elsewhere is not the same as sharing it, so another machine's work may exist but be unfetched (see [WORKSPACE.md](./WORKSPACE.md) "Shared repository sync"). Commit and push any lesson set you author right away.
   If this is a new workspace, create files lazily in this order: `MISSION.md`, `RESOURCES.md` when sources are needed, `NOTES.md` when preferences or working notes exist, then `assets/`, `lessons/`, `reference/`, and `learning-records/` only when the first artifact in each category is earned.
3. If `MISSION.md` is missing or vague, interview for the concrete outcome first. Use [MISSION-FORMAT.md](./MISSION-FORMAT.md).
4. Choose the next lesson from the mission and the learner's zone of proximal development. Use [TEACHING-MODEL.md](./TEACHING-MODEL.md) for the philosophy, learning records, resources, and wisdom/community rules.
5. When creating or revising lessons, reference docs, assets, source-code links, or hosted URLs, follow [LESSON-RULES.md](./LESSON-RULES.md).
6. When running quizzes or asking for lesson-direction choices, follow [QUIZ-FEEDBACK.md](./QUIZ-FEEDBACK.md).
7. Record durable learning only when evidenced. Use [LEARNING-RECORD-FORMAT.md](./LEARNING-RECORD-FORMAT.md). Put transient preferences and working notes in `NOTES.md`.

## Workspace files

- `MISSION.md` — why the user is learning this topic.
- `RESOURCES.md` — trusted knowledge sources and communities. Use [RESOURCES-FORMAT.md](./RESOURCES-FORMAT.md).
- `HOSTING.md` — workspace-owned lesson hosting. Use [HOSTING-FORMAT.md](./HOSTING-FORMAT.md); create it lazily when hosted links are needed.
- `lessons/*.html` — short, single-win lesson outputs.
- `reference/*.html` — reusable cheat sheets, maps, glossaries, algorithms, and syntax references.
- `assets/*` — reusable components shared across lessons.
- `learning-records/*.md` — evidenced learning, prior knowledge, misconceptions corrected, or mission shifts.
- `NOTES.md` — scratchpad for teaching preferences and working notes.

## Local-owned guardrail

This `teach` skill is local-owned. Upstream changes are input, not authority: adopt them only when they improve teaching without weakening the local delta in [WORKSPACE.md](./WORKSPACE.md). Conflicts require explicit grilling acceptance before changing local `teach`.

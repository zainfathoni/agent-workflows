---
name: teach
description: Teach the user a new skill or concept, within this workspace.
disable-model-invocation: true
argument-hint: "What would you like to learn about?"
---

The user wants a stateful, multi-session learning workspace.

## Start here

1. Treat the current directory as the teaching workspace unless the request points at a specific workspace or source. Follow [WORKSPACE.md](./WORKSPACE.md) for authoritative workspace naming, state preservation, shared-repository sync, and local-owned guardrails. **Complete when:** the canonical workspace, source, ownership mode, and sync state are explicit.
2. Read existing workspace state before teaching: `MISSION.md`, `RESOURCES.md`, `HOSTING.md` if present, `NOTES.md`, `learning-records/`, `lessons/`, `reference/`, and `assets/`. When the workspace is a shared git repository, perform the remote check and immediate authored-lesson commit/push workflow in [WORKSPACE.md](./WORKSPACE.md).
   If this is a new workspace, create files lazily in this order: `MISSION.md`, `RESOURCES.md` when sources are needed, `NOTES.md` when preferences or working notes exist, then `assets/`, `lessons/`, `reference/`, and `learning-records/` only when the first artifact in each category is earned. **Complete when:** every existing state source has been read and each missing artifact is either earned by this run or left absent.
3. If `MISSION.md` is missing or vague, follow the authoritative interview, format, and revision rules in [MISSION-FORMAT.md](./MISSION-FORMAT.md). **Complete when:** `MISSION.md` states a concrete learning outcome and current revision evidence, or the unanswered mission question is the explicit blocker.
4. Choose the next lesson from the mission and the learner's zone of proximal development. Use [TEACHING-MODEL.md](./TEACHING-MODEL.md) for the philosophy, learning records, resources, and wisdom/community rules. **Complete when:** one next lesson has a stated mission link, prerequisite basis, and single intended win.
5. When creating or revising lessons, reference docs, assets, source-code links, or hosted URLs, follow [LESSON-RULES.md](./LESSON-RULES.md). **Complete when:** every artifact created or revised in this run passes the applicable lesson, source, asset, and hosting rules.
6. When choosing or running a feedback loop, including quizzes and lesson-direction choices, follow the authoritative rules in [QUIZ-FEEDBACK.md](./QUIZ-FEEDBACK.md). **Complete when:** the selected feedback loop has a recorded learner response and rule-compliant next action, or is explicitly deferred by the learner.
7. Record durable learning only when evidenced. Use [LEARNING-RECORD-FORMAT.md](./LEARNING-RECORD-FORMAT.md). Put transient preferences and working notes in `NOTES.md`. **Complete when:** every new durable claim cites evidence, transient notes remain in `NOTES.md`, and no unsupported learning claim was recorded.

## Workspace files

- `MISSION.md` — why the user is learning this topic.
- `RESOURCES.md` — trusted knowledge sources and communities. Use [RESOURCES-FORMAT.md](./RESOURCES-FORMAT.md).
- `HOSTING.md` — workspace-owned lesson hosting. Use [HOSTING-FORMAT.md](./HOSTING-FORMAT.md); create it lazily when hosted links are needed.
- `lessons/*.html` — short, single-win lesson outputs.
- `reference/*.html` — reusable cheat sheets, maps, glossaries, algorithms, and syntax references.
- `assets/*` — reusable components shared across lessons.
- `learning-records/*.md` — evidenced learning, prior knowledge, misconceptions corrected, or mission shifts.
- `NOTES.md` — scratchpad for teaching preferences and working notes.

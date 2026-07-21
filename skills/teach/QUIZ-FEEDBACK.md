# Quiz and Feedback Rules

## Feedback loops

Skills need tight feedback loops. Use quizzes, light browser tasks, short real-world procedures, or recall prompts. Give corrective feedback immediately and record results in `NOTES.md`.

For multiple-choice quizzes, make answer choices the same number of words where possible so formatting does not leak the answer.

Mechanism lessons embed an **in-page quiz widget**: radio options with immediate corrective feedback on submit, no page reload, self-contained over `file://`. All answer-position and key-leak rules below apply to widget quizzes too. Then mirror a *fresh variant* (not the same questions) in chat for grading — the widget builds fluency; only the chat quiz is evidence for a learning record.

Non-mechanism lessons use another tight feedback loop appropriate to the material: a chat quiz or recall prompt, light browser task, or short real-world procedure. They may use a widget when it adds value, but do not require one. Combined lesson types satisfy both requirements.

## Tycho inquiry

When running in Tycho and asking the user to answer a quiz or choose a next teaching direction, use the structured final-response `inquiry` object **and** present the questions as plain Markdown in the same reply. The `inquiry` select fields are the preferred answer mechanism, but they may silently fail to render — the Markdown version ensures the learner always sees the quiz.

For multiple-choice quizzes:

- create one inquiry field per question;
- use `input_type: "select"`;
- put choices in each field's `options` array;
- use stable keys such as `q1_presence_gate`;
- use `input_type: "text"` only for free-recall prompts.

Always mirror the same questions and options in plain Markdown below (or above) the inquiry block. The Markdown version is a fallback display, not a separate answer path — if the learner answers via text, accept that too and grade it.

After the user answers, grade each field explicitly, correct misses, and write a learning record only when the user demonstrates understanding.

## Answer-format examples must not leak the key

**Hard guardrail: never reveal or encode the real answer key in instructions, examples, option formatting, or positional patterns.**

When showing the learner how to format answers, use a neutral placeholder such as `1<letter> 2<letter> 3<letter> …` or `Q1: A/B/C/D`. With Tycho select fields, rely on the controls and omit a free-text format example. For a required free-text fallback, verify before sending that its example does not match the real key.

## Answer-position entropy

Give correct answers high positional entropy: deliberately distribute them across available positions without a fixed slot or repeating pattern, and reshuffle options for every retry. Check the complete key sequence before sending. Recommendation prompts may put a recommended option first; assessment quizzes have no recommended option, so their ordering follows this entropy rule.

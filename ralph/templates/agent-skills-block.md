## Agent skills

### Issue tracker

Issues live as GitHub issues in `{{REPO}}`. See `docs/agents/issue-tracker.md`.

### Triage labels

Canonical skills labels are mapped in `docs/agents/triage-labels.md`.

### Planning and prototypes

Use `/prototype` for throwaway spikes before committing ambiguous UI, state-machine, or integration decisions to issues. Use `/handoff` when a long planning, debugging, or prototyping session should continue in a fresh agent context.

### Domain docs

Domain documentation and ADR lookup rules are described in `docs/agents/domain.md`.

### Ralph

Ralph is execution-only and consumes `ready-for-agent` issues. Ralph must not automatically run planning skills such as `/prototype`, `/handoff`, `/to-prd`, `/to-issues`, or `/triage`. See `docs/agents/ralph.md`.

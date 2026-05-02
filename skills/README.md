# Shared Skills

Reusable personal skills that should be available across projects.

## Install

Install or update all shared skills by symlinking them into the global skills directory:

```bash
~/Code/GitHub/zainfathoni/agent-workflows/skills/install.sh
```

The default target is `~/.agents/skills`. Override it with `AGENT_SKILLS_DIR`:

```bash
AGENT_SKILLS_DIR=~/.claude/skills ~/Code/GitHub/zainfathoni/agent-workflows/skills/install.sh
```

The installer refuses to overwrite a real directory or file. If a target path already exists as a symlink, it is replaced.

## Review Skill Families

### Private Review Skills

Use these when review comments or draft review notes should stay private until explicit submission:

- `private-review` - create a pending private review.
- `private-address-review` - address private review comments while keeping replies pending/private.
- `private-verify-review` - verify whether private review comments were addressed without publishing anything.
- `private-clear-review` - delete current-user pending review artifacts only after explicit instruction.

### Team Review Skills

Use these for colleague-facing review work where replies may become visible when explicitly requested:

- `team-review` - review a teammate's PR and prepare review feedback.
- `team-address-review` - address colleague review comments with focused fixes.
- `team-verify-review` - verify whether colleague review comments were addressed.
- `team-resolve-review` - resolve verified colleague-facing review threads.

## Private vs Team

Pick the private family when the key requirement is: "do not publish or submit pending review content without explicit instruction."

Pick the team family when the key requirement is: "prepare or manage feedback intended for teammates."

Do not mix private pending-review cleanup with team-visible thread resolution in the same step.

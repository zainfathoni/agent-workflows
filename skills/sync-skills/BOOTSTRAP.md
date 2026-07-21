# Bootstrap Sync Skills

On a machine where `/sync-skills` is not installed yet, locate the agent-workflows repository in the same order used by `SKILL.md`, validate that `skills/install.sh` is executable, and run:

```bash
"<ROOT>/skills/install.sh"
```

The installer may use `AGENT_SKILLS_DIR` from the environment. It replaces existing symlinks but intentionally refuses to overwrite a real directory. After it exits successfully, invoke `/sync-skills` for the complete update and verification process.

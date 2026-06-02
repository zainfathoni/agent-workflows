---
id: "002"
title: Document Tycho Amp Harness Limitation
status: accepted
date: 2026-06-02
---

## Context

Tycho supports custom harnesses through a Claude-compatible adapter shape. When a custom harness is configured with `adapter: claude`, Tycho builds a Claude-style command line and passes flags such as `--print`, `--output-format stream-json`, `--json-schema`, and session or resume flags.

Amp exposes a different non-interactive automation interface. Its one-shot execution entrypoint is `amp --execute` or `amp -x`, optionally with `--stream-json`. Non-interactive tool use may also require `--dangerously-allow-all` or equivalent environment setup.

Because of that command-line mismatch, Tycho cannot currently run Amp by setting a custom harness `execution_command` directly to `amp`.

## Decision

When using Amp from Tycho, document the integration as a compatibility shim rather than a native Tycho harness.

The recommended local configuration is:

1. Create an executable shim that accepts Tycho's Claude-style argv, ignores Claude-only flags, extracts the final prompt, and invokes Amp with `amp --execute "$prompt" --stream-json`.
2. Configure Tycho with `adapter: claude` and point `execution_command` at the shim.
3. Treat the setup as one-shot execution support only.

Example shim:

```bash
#!/usr/bin/env bash
set -euo pipefail

prompt=""
allow_all=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dangerously-skip-permissions)
      allow_all=true
      shift
      ;;
    --print|--verbose)
      shift
      ;;
    --output-format|--json-schema|--session-id|--resume)
      shift 2
      ;;
    *)
      prompt="$1"
      shift
      ;;
  esac
done

cmd=(amp --execute "$prompt" --stream-json)
if [[ "$allow_all" == true ]]; then
  cmd=(amp --dangerously-allow-all --execute "$prompt" --stream-json)
fi

exec "${cmd[@]}"
```

Example Tycho configuration:

```yaml
custom_harnesses:
  - key: amp
    adapter: claude
    execution_command: /Users/you/bin/tycho-amp

projects:
  - key: my-app
    name: My App
    group: Personal
    path: /Users/you/Code/my-app
    apps: true
    agent: amp
```

## Consequences

### Positive

- Tycho can invoke Amp for one-shot agent runs without waiting for upstream Tycho adapter support.
- The workaround keeps Tycho configuration explicit and reversible.
- The shim isolates Amp-specific command translation in one local file.

### Negative

- The integration is not native Amp support.
- Claude-specific Tycho flags must be translated or dropped by the shim.
- Tycho session ids do not map to Amp threads. Amp resumes conversations through `amp threads continue`, so this workaround should not be treated as native resume support.
- The shim may need updates if Tycho changes the Claude adapter argv contract or Amp changes its automation flags.

## When To Revisit

Revisit this decision if Tycho adds an Amp adapter, if Amp adds a Claude-compatible command-line mode, or if this workflow needs reliable thread resume semantics rather than one-shot execution.

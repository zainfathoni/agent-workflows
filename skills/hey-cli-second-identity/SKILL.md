---
name: hey-cli-second-identity
description: Give one agent its own HEY account through the hey CLI without clobbering the operator's own login. Use when an agent needs to read or write someone else's HEY mail, calendar, or todos, or when a second hey identity is needed on one machine.
---

The hey CLI stores one identity per machine by default. Pointing a second agent at a second
HEY account is not a matter of logging in twice — the second login destroys the first. This
skill is the recipe that survives.

## The collision

hey keys credentials in the system keyring by **server origin**. Every HEY account lives at
the same origin, so a second `hey auth login` overwrites the first one silently. There is no
per-account slot.

The way out is to keep the second identity out of the keyring entirely:

- `XDG_CONFIG_HOME` relocates both `config.json` and `credentials.json` to a private profile
  directory.
- `HEY_NO_KEYRING=1` forces file storage inside that profile.

`HEY_NO_KEYRING=1` is required **on the login command itself**, not just on later reads.
Without it the login goes to the shared keyring and the collision happens anyway.

## Log the second identity in

```sh
XDG_CONFIG_HOME=<profile-dir> HEY_NO_KEYRING=1 hey auth login
```

Put `<profile-dir>` outside any committed repository: `credentials.json` is plaintext, mode
0600. A path like `~/.config/hey-<agent>` keeps it obvious which agent owns it.

Two traps at sign-in:

- If the browser is already signed in as the primary account, use a private window. HEY will
  otherwise hand back the wrong identity into the new profile, and nothing later will look
  wrong.
- Away from the machine, `hey auth login --no-browser` prints the URL instead of opening one.
  It waits on a callback server on an ephemeral loopback port on the *host*, so read that
  port out of the URL's `redirect_uri` and forward it: `ssh -L <port>:127.0.0.1:<port> <host>`.

Confirm with `hey auth status --json` (expect `storage: file`) and `hey account list --json`
(expect the intended person, not the operator).

## Carry the identity in a wrapper, not in config

Agent harnesses generally have no per-agent environment: env overrides are per-call, host
exec commonly rejects `PATH` overrides, and shell startup snapshots strip secret-looking
variables. A small wrapper script is the only carrier that survives every invocation path.

```sh
#!/bin/sh
set -eu
export XDG_CONFIG_HOME="${AGENT_HEY_PROFILE:-$HOME/.config/hey-<agent>}"
export HEY_NO_KEYRING=1
export HEY_NONINTERACTIVE=1
exec "$HOME/bin/hey" "$@"
```

Three details earn their place:

- **Absolute binary path.** The installer may drop `hey` somewhere that is on the operator's
  interactive `PATH` but not the agent runtime's. A bare `hey` then works when tested by hand
  and fails under the agent. Resolve it explicitly, or probe a list of candidates and fail
  with a clear message.
- **`HEY_NONINTERACTIVE=1`.** Agent exec can run under a PTY, and hey offers interactive
  sign-in at a TTY. Without this, an expired token makes the command prompt and hang until
  the agent timeout instead of exiting 3.
- **Profile override variable.** Keeps the same script reusable for a second agent.

Give the agent the wrapper's absolute path in its own instructions, and tell it explicitly
never to run plain `hey` — that is a different identity, or none. If hey's own fleet-wide
skill is installed, its examples all call plain `hey`; instruct the agent to translate every
one of them to the wrapper.

## Do not vendor hey's own skill

`hey skill install` writes a large, versioned `SKILL.md` into the shared agent skills
directory and marks the directory as its own. It refuses to claim a directory it did not
mark, and its per-release refresh skips symlinks. An installer that symlinks skills into that
same path will either refuse to run or freeze the vendor doc at whichever release it captured.
Let hey own its skill directory; own the identity recipe instead.

## Verify from inside the agent

The operator's login shell and the agent runtime are different execution contexts. Two checks
belong to the agent, not the terminal:

1. A read through the wrapper, to prove the path and profile resolve under exec.
2. `hey auth refresh --json`, to prove the runtime can **write** the refreshed
   `credentials.json`. Reads working proves nothing about this, and a refresh that cannot
   write turns into a silent "Not logged in" when the token expires weeks later.

## Calendar gotchas

- `hey event list` returns each repeating item **once, as the series it is stored as**. For
  "what is on day X", use `hey event day <date>`, which expands recurrences into real
  occurrences. A one-day `event list` window makes daily routines look absent.
- `hey event add` without `--calendar` files onto the first calendar it can, and an account's
  personal calendar is listed but refuses events. Pass `--calendar <id>` on every write.
- `hey event delete <id>` takes exactly one argument — no date, unlike `hey event edit`.
- Clock times are read in `--time-zone`, defaulting to the machine's zone. Set it explicitly
  or HEY reads them as UTC.
- On a shared calendar the agent is a guest. Require human approval before deleting anything,
  or editing anything the agent did not just create.

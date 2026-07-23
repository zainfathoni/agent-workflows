# BTA Development Health System Probes

Load only the section named by the current process step. Replace placeholders from verified local state; never invent a repository, worktree, workspace, thread, runner, stack, service, image, or URL.

## Unfinished-work inventory

Establish the repository and remote before using its worktree registry:

```bash
repo=/absolute/path/to/verified/bookthatapp-worktree
root=$(git -C "$repo" rev-parse --show-toplevel)
git -C "$root" remote -v
git -C "$root" worktree list --porcelain
```

For every `worktree` entry, inspect it independently:

```bash
git -C "$worktree" status --short --branch
git -C "$worktree" branch --show-current
git -C "$worktree" rev-parse --abbrev-ref --symbolic-full-name '@{upstream}'
git -C "$worktree" rev-list --left-right --count '@{upstream}...HEAD'
```

An absent upstream is inventory evidence, not a command failure to hide. Fetch only when the user requested fresh remote state; otherwise label remote comparisons with their observation time. After Git inventory, use authenticated GitHub access to list current-user open PRs and map their head branches back to worktrees:

```bash
repo_name=$(git -C "$root" remote get-url origin)
gh pr list --repo "$repo_name" --state open --author '@me' \
  --json number,headRefName,baseRefName,isDraft,url
```

Reduce the remote to an accepted `OWNER/REPO` form before passing it to `gh`; URLs containing embedded credentials are `needs-owner` and must be redacted.

Only after the complete Git/PR inventory exists, discover configured amux resources without doctoring them:

```bash
amux --json workspace list
amux --json list --workspace "$workspace"
```

Select only workspaces whose configured resource identity or canonical workdir maps to unfinished BTA work. Record ambiguous mappings as `needs-owner` rather than widening to `--all`.

## Bounded amux diagnostics

Resolve the directory containing the skill's `SKILL.md`, then invoke its helper by absolute path:

```bash
python3 "$skill_dir/scripts/bounded-amux-diagnostics.py" \
  worker-doctor --thread "$thread_id"
```

The helper always invokes exact-thread `amux --json worker doctor --thread <id>` and enforces one 30-second wall-clock deadline. On success it emits only an allowlisted envelope with the expected thread, exit/status category, schema validity, and outcome counts. On timeout it discards private subprocess output, records the thread identity plus either `amux -> amp threads list` or `other`, terminates only the command process group it created, and exits `124`.

When a timeout needs localization, independently run both exact Amp list shapes once:

```bash
python3 "$skill_dir/scripts/bounded-amux-diagnostics.py" amp-list
python3 "$skill_dir/scripts/bounded-amux-diagnostics.py" amp-list --include-archived
```

Each uses the same 30-second deadline around, respectively:

```bash
amp threads list --json --limit 500 --offset 0
amp threads list --json --limit 500 --offset 0 --include-archived
```

The helper reports status and result size, never thread-list content. A doctor timeout with either Amp-list timeout indicates an Amp-list stall; successful independent lists leave tmux/doctor inspection as the remaining diagnosis. Preserve uncertainty when evidence conflicts. The timeout never authorizes another aggregate attempt, restart, reconcile, park, or kill.

Runner diagnosis remains the exact canonical command, once per mapped runner:

```bash
amux --json runner doctor --workdir "$runner_workdir"
```

Use the loaded `/amux` `reference/workflows.md#health-workers-and-runners` section directly for exact tmux/process ownership, ping eligibility and mechanics, response deadlines, no-response meaning, and runner classifications. Do not copy those rules into this skill's report or treat this reference as an alternative authority.

## External access

### GitHub API, SSH, and remotes

```bash
gh auth status
gh api rate_limit --jq '{core: .resources.core.remaining, reset: .resources.core.reset}'
git -C "$worktree" remote -v
git -C "$worktree" ls-remote --exit-code origin HEAD
ssh -o BatchMode=yes -o ConnectTimeout=10 -T git@github.com
```

GitHub's SSH probe commonly exits nonzero after confirming authentication. Classify from the recognized authentication result, suppress the greeting identity, and treat network, host-key, and permission failures separately. Check every distinct relevant remote once and redact embedded credentials immediately.

### Claude Code

```bash
claude auth status --json
```

Retain only `loggedIn`, `authMethod`, and `apiProvider`. Readiness requires `loggedIn: true` and `apiProvider: firstParty`; report the authentication method category without account identity. This check does not authorize provider delegation. Pi remains deferred unless the task inventory requires it.

### Cloud 66 staging

```bash
cx test
cx stacks list -e staging
```

Use `cx test` only for authenticated status. From the staging list, record whether the exact required stack/environment is visible; keep account, stack, server, and application names out of the report. Missing login, MFA, or stack access is `needs-owner`. Health never runs `cx login`, `redeploy`, `restart`, `run`, `ssh`, configuration apply, or another remote mutation.

## Local runtime and capacity

Run from the verified BTA worktree and use its documented Compose file:

```bash
docker info --format '{{json .ServerVersion}}'
docker compose version
docker compose -f "$compose_file" config --services
docker compose -f "$compose_file" config --images
docker compose -f "$compose_file" ps --format json
```

Do not print fully rendered Compose configuration because interpolation can expose secrets. Inspect every image reported by `config --images`:

```bash
docker image inspect "$image" --format '{{.Id}} {{.Os}}/{{.Architecture}}'
```

If an exact running BTA app container exists, read versions there:

```bash
docker compose -f "$compose_file" exec -T "$app_service" \
  sh -lc 'ruby --version && bundle --version'
```

Otherwise use the resolved app image in one disposable, network-disabled container:

```bash
docker run --rm --network none --entrypoint sh "$app_image" \
  -lc 'ruby --version && bundle --version'
```

Do not build, pull, start Compose services, run Rails, or invoke database/search tasks. After an ephemeral probe, verify no container from that probe remains.

Check filesystem and worktree capacity without deleting anything:

```bash
df -Pk "$root"
docker system df
git -C "$root" worktree list --porcelain
test -d "$worktree"
git -C "$worktree" status --short --branch
```

Report available bytes and Docker usage without inventing a cleanup threshold. An actual allocation failure or documented project minimum is blocking; otherwise surface low headroom with its observed value and owner decision. Missing, inaccessible, duplicate, or ambiguously owned worktrees are `needs-owner`. Health never prunes Docker, removes worktrees, deletes branches, stashes, resets, or cleans files.

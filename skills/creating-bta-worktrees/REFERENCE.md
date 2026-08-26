# BTA Worktree Invocation and Diagnosis

Read only the section named by the active create or repair step. The scripts' `--help` output and source remain authoritative for options, managed paths, and exact behavior.

Resolve the skill-owned executables once before using any example:

```bash
skill_dir=/absolute/path/to/creating-bta-worktrees
create_script="$skill_dir/scripts/create-bta-worktree.sh"
setup_script="$skill_dir/scripts/setup-bta-worktree.sh"
test -x "$create_script" && test -x "$setup_script"
```

## Create invocations

From a BookThatApp worktree, invoke the resolved skill script with the approved sibling name:

```bash
"$create_script" \
  --branch bugfix/trello-947/search-save-recovery \
  bta-947-search-save-recovery
```

Examples of conditional options:

```bash
"$create_script" --base feature/trello-1001/stale-cache --branch bugfix/trello-1001/toast-recovery bta-1001-toast-recovery
"$create_script" --no-lock --branch feature/trello-1234/capacity-calendar bta-1234-capacity-calendar
"$create_script" --canonical ../bookthatapp --branch chore/trello-1234/test-harness bta-1234-test-harness
```

New ephemeral branches require an explicit `--branch` matching
`<bugfix|feature|chore>/trello-<numeric-id>/<lowercase-slug>`. The Trello segment
groups multiple branches belonging to one card. Existing branches using the older
hyphen-only form remain accepted for compatibility. A command without
`--branch` can only reuse an existing legacy `bta/<slug>` branch for an explicitly
identified long-running worktree; it cannot create a new legacy branch.

## Repair invocations

Repair explicit targets in one call:

```bash
"$setup_script" ../bta-debug ../bta-teach
```

To discover every sibling BTA worktree without mutating it, capture and inspect the complete target set first:

```bash
worktrees=()
while IFS= read -r worktree; do
  worktrees+=("$worktree")
done < <(
  git worktree list --porcelain |
    awk '/^worktree / {print $2}' |
    grep '/bta-' |
    sort
)

printf '%s\n' "${worktrees[@]}"
for worktree in "${worktrees[@]}"; do
  git -C "$worktree" status --short --branch
done
```

After the target list and every pre-mutation status are reviewed, repair that exact set in one call:

```bash
"$setup_script" "${worktrees[@]}"
```

## Verification and runtime diagnosis

Verify registration and every target's branch/status explicitly:

```bash
git worktree list --porcelain
git -C ../bta-947-search-save-recovery status --short --branch
git -C ../bta-teach status --short --branch
```

For each target supplied to setup, require its emitted `OK runtime file` result. The script emits that result only when the runtime file is non-empty and is not a symlink.

Also require `OK User Plugins boundary: <worktree>/.amp absent` for worktrees without real project-local Amp configuration. Setup removes legacy `.amp` symlinks so the global User Plugins repository owns plugin discovery, while preserving a real per-worktree `.amp` path with `SKIP real path`.

Runtime files use hard links or copies because Docker containers cannot resolve absolute macOS symlink targets outside the mounted worktree. These signatures identify the affected runtime file:

- missing Traefik certificate or key: Traefik cannot find PEM data;
- missing `.env.development.local`: Rails boot can reach `ShopifyAPI::Context.setup` with a nil API key;
- missing `routes.local.toml`: local URLs can return Traefik 404s because Traefik cannot discover Docker routes.

Use the setup script to repair these files; preserve its refusal, missing-source, and `BAD runtime file` results rather than replacing files manually.

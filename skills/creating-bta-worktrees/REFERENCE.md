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
"$create_script" bta-debug
```

Examples of conditional options:

```bash
"$create_script" --base bta/main bta-debug
"$create_script" --no-lock bta-debug
"$create_script" --canonical ../bookthatapp bta-debug
```

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
git -C ../bta-debug status --short --branch
git -C ../bta-teach status --short --branch
```

For each target supplied to setup, require its emitted `OK runtime file` result. The script emits that result only when the runtime file is non-empty and is not a symlink.

Runtime files use hard links or copies because Docker containers cannot resolve absolute macOS symlink targets outside the mounted worktree. These signatures identify the affected runtime file:

- missing Traefik certificate or key: Traefik cannot find PEM data;
- missing `.env.development.local`: Rails boot can reach `ShopifyAPI::Context.setup` with a nil API key;
- missing `routes.local.toml`: local URLs can return Traefik 404s because Traefik cannot discover Docker routes.

Use the setup script to repair these files; preserve its refusal, missing-source, and `BAD runtime file` results rather than replacing files manually.

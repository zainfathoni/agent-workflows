# Guide repository ownership

Read this file only after the authorized squash reaches step 9 of [`../SKILL.md`](../SKILL.md). A guide can be owned by a different repository when project docs are symlinked from a notes repository.

Resolve the physical guide path and owning repository:

```bash
guide_path="docs/rebases/{ticket-id}/{rebase-identifier}.md"
guide_abs="$(cd "$(dirname "$guide_path")" && pwd -P)/$(basename "$guide_path")"
guide_repo="$(git -C "$(dirname "$guide_abs")" rev-parse --show-toplevel)"
git -C "$guide_repo" status --short -- "$guide_abs"
```

Confirm that `guide_repo` owns the path. Stage and commit only the generated guide file:

```bash
git -C "$guide_repo" add "$guide_abs"
git -C "$guide_repo" commit -m "Docs: add {ticket-id} rebase guide"
```

If the squash session created multiple guides, stage only those guide paths. Leave unrelated notes, reports, and working-tree changes untouched. When pushing the guide repository is explicitly authorized, run it as a separate operation:

```bash
git -C "$guide_repo" push
```

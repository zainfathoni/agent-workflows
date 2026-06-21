# Agent Workflows

Agent Workflows provides reusable personal automation for agent-assisted software projects. It keeps global skills reusable while making each repository's local workflow conventions explicit.

## Language

**Agent Workflows**:
The public repository that stores reusable personal agent workflow tooling.
_Avoid_: Dotfiles, one-off scripts

**Ralph**:
The execution-only runner that consumes issues already marked `ready-for-agent`.
_Avoid_: Triage bot, planner

**Ready Queue**:
The set of open GitHub issues that satisfy the Agent Queue rules, especially the `ready-for-agent` triage label.
_Avoid_: Backlog, todo list

**Agent Queue**:
The workflow lane for AFK-ready implementation issues.
_Avoid_: Needs Attention, Human Queue

**Triage State**:
The readiness state represented by labels such as `needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, and `wontfix`.
_Avoid_: Project status

**Delivery Status**:
The optional GitHub Project `Status` field that represents delivery progress: `Todo`, `In Progress`, or `Done`.
_Avoid_: Triage state

**Repo-Local Agent Docs**:
The committed `docs/agents/*` files that map global skills and Ralph to one repository's issue tracker, labels, domain docs, and execution rules.
_Avoid_: Backlog, ticket mirror

**Local Symlink**:
An untracked entrypoint such as `./ralph.sh` or `.ralph/ralph.sh` pointing from a target repository to shared tooling in Agent Workflows.
_Avoid_: Installed copy, checked-in runner

**Shared Skill**:
A reusable skill stored in Agent Workflows and installed into the global agent skills directory by symlink.
_Avoid_: Repo-local skill, copied skill

**Upstream Skill**:
A reusable skill owned by an external skill source, especially Matt Pocock's skills, and installed globally from that source rather than mirrored in Agent Workflows.
_Avoid_: Shared skill, local fork

**Local-Owned Skill**:
A skill whose behavior is materially customized for Zain's workflows and whose source of truth is Agent Workflows.
_Avoid_: Upstream skill, vendored copy

**Upstream-Tracked Skill**:
A skill that may be installed or updated from its upstream source because Agent Workflows does not own local behavior for it.
_Avoid_: Local-owned skill, fork

**Teaching Workspace Assets**:
The `./assets/*` directory inside a `teach` workspace that stores reusable lesson components such as shared stylesheets, quiz widgets, simulators, and diagram helpers.
_Avoid_: Skill assets, bundled upstream assets

**Teaching Workspace Hosting**:
The per-workspace instructions that tell `teach` how static lessons and reference documents are previewed or published, such as a custom domain, GitHub Pages, a repo-specific app deployment, or an optional Tailscale serve mapping.
_Avoid_: Teach skill hosting, hardcoded Tailscale hosting

**Local Teach Delta**:
The explicitly documented behavior that Agent Workflows adds to the upstream `teach` skill and must preserve during upstream comparisons.
_Avoid_: Fork drift, accidental changes

**Private Review**:
A review workflow where pending review comments and replies must remain private unless the user explicitly submits or publishes them.
_Avoid_: Team review, public review

**Team Review**:
A colleague-facing review workflow where feedback may be prepared for publication and published only when explicitly requested.
_Avoid_: Private review

## Relationships

- **Agent Workflows** provides **Ralph** and onboarding tooling.
- **Ralph** consumes the **Ready Queue**.
- **Triage State** is represented by labels on GitHub issues.
- **Delivery Status** is represented by GitHub Project `Status` only when a Project is configured.
- **Repo-Local Agent Docs** adapt global skills and **Ralph** to a specific repository.
- **Local Symlinks** provide convenient entrypoints without committing shared runner copies into application repositories.
- A **Shared Skill** may be installed globally by symlink, while project-specific skill behavior should remain in repo-local skills.
- **Upstream Skills** are installed from their upstream source; only materially customized skills become **Local-Owned Skills** in Agent Workflows.
- **Upstream-Tracked Skills** may accept upstream breaking changes, including renames and removal of deprecated skills.
- The v1 upstream grilling stack (`grilling`, `domain-modeling`, and `grill-with-docs`) remains **Upstream-Tracked** unless Agent Workflows needs concrete customized behavior.
- Local-owned `teach` workspaces use **Teaching Workspace Assets** as the default lesson architecture while preserving local codebase source-linking behavior and deferring publication details to **Teaching Workspace Hosting**.
- The **Local Teach Delta** is the preservation checklist for local-owned `teach`; upstream comparisons may add accepted upstream behavior, but must not erase the delta.
- **Private Review** skills protect pending review artifacts.
- **Team Review** skills manage colleague-visible review feedback and thread resolution.

## Flagged Ambiguities

- **Status** can mean triage state or delivery status. Use **Triage State** for labels and **Delivery Status** for GitHub Project `Status`.
- **Ralph** is not a planning or triage mechanism. Planning and triage are manually triggered through skills.
- **Repo-Local Agent Docs** are not a second source of truth for work. GitHub Issues remain the work source of truth.
- **Shared Skill** does not mean every globally installed skill. Use **Upstream Skill** for skills owned elsewhere and **Local-Owned Skill** for customized skills maintained here.
- **Teaching Workspace Assets** are created inside each teaching workspace; they are not files bundled in Matt Pocock's upstream `teach` skill package.
- **Teaching Workspace Hosting** belongs to the teaching workspace, not the generic `teach` skill. Tailscale is one possible hosting method, not the default for every workspace.
- **Local Teach Delta** should be updated whenever a local-owned `teach` behavior is accepted, rejected, or deliberately retired.
- Upstream `teach` changes are input, not authority. Adopt them only when they improve the teaching model without weakening the **Local Teach Delta**; conflicts require explicit grilling acceptance.
- **Private Review** and **Team Review** are intentionally separate. Do not use private pending-review cleanup rules to mutate team-visible threads.

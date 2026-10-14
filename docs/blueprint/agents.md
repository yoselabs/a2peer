# Blueprint: agents (Agent harness)

Written by `blueprint check --write` on 2026-10-14; rewritten on every run.

kind: application · stacks: python-uv (from pyproject.toml, uv.lock) · surfaces: cli · traits: - · tracker: beads · checkpoint set: `422284787105`

engine: shelf `08940947c` · blueprint 0.1.0

concerns checked: stack, gate, backlog, knowledge, secrets, agents · not run: framework · audit-only checkpoints included

## Overrides

none

| | checkpoint | set up | working | evidence | remediation | fixed by |
|---|---|---|---|---|---|---|
| ✅ | `agents.instructions` | yes | yes | CLAUDE.md imports @AGENTS.md | - | - |
| ✅ | `agents.bd-metrics-off` | yes | yes | BD_DISABLE_METRICS=1 in .claude/settings.json | - | - |
| ✅ | `agents.session-hooks` | yes | yes | SessionStart runs bd prime; Stop flags in-progress beads | - | - |
| ✅ | `agents.pocock-skills` | yes | yes | mattpocock marketplace declared and mattpocock-skills enabled in .claude/settings.json | - | - |
| ✅ | `agents.worktrees` | yes | yes | ignored: .claude/worktrees/, .worktrees/; the rule is in docs/agents/working-with-agents.md | - | - |
| ✅ | `agents.worktrees-in-sync` | yes | yes | 2 worktrees, each within 24h of main both ways | - | - |
| ✅ | `agents.culture-files` | yes | yes | 8 conventions files: constitution, working-with-agents, gate, testing, architecture, domain, issue-tracker, python; no placeholder in the instruction files | - | - |
| ✅ | `agents.managed-block` | yes | yes | managed block current | - | - |

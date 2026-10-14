# Blueprint: backlog (Generic: any repo)

Written by `blueprint check --write` on 2026-10-14; rewritten on every run.

kind: application · stacks: python-uv (from pyproject.toml, uv.lock) · surfaces: cli · traits: - · tracker: beads · checkpoint set: `422284787105`

engine: shelf `08940947c` · blueprint 0.1.0

concerns checked: stack, gate, backlog, knowledge, secrets, agents · not run: framework · audit-only checkpoints included

## Overrides

none

| | checkpoint | set up | working | evidence | remediation | fixed by |
|---|---|---|---|---|---|---|
| ✅ | `backlog.tracker` | yes | yes | beads initialised (.beads/config.yaml) | - | - |
| ❌ | `backlog.strict-config` | yes | no | import.auto=true (want false) | edit .beads/config.yaml directly (a dotted key is nested YAML, `import.auto` is `import:` then `  auto: false`): import.auto: false; not `bd config set`, which writes bd's database; unset any BD_*/BEADS_* override, then confirm `bd config show --json` lists each with "source": "config.yaml"; in a git worktree bd reads the main checkout's .beads/config.yaml (`bd where`): the row passes once this branch merges | agent |
| ✅ | `backlog.lock-ignored` | yes | yes | .beads.gate.lock is git-ignored | - | - |
| ✅ | `backlog.no-tracked-export` | yes | yes | no JSONL under .beads is tracked | - | - |
| ✅ | `backlog.no-local-override` | yes | yes | no local file or session env overrides bd | - | - |
| ✅ | `backlog.lint` | yes | yes | `bd lint` passes for open, blocked beads | - | - |
| ✅ | `backlog.no-tracker-file` | yes | yes | beads is the only backlog | - | - |
| ✅ | `backlog.hooks-spare-beads` | yes | yes | no end-of-file-fixer reaches .beads/ | - | - |

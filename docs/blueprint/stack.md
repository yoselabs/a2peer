# Blueprint: stack (Stack-specific)

Written by `blueprint check --write` on 2026-10-14; rewritten on every run.

kind: application · stacks: python-uv (from pyproject.toml, uv.lock) · surfaces: cli · traits: - · tracker: beads · checkpoint set: `422284787105`

engine: shelf `08940947c` · blueprint 0.1.0

concerns checked: stack, gate, backlog, knowledge, secrets, agents · not run: framework · audit-only checkpoints included

## Overrides

none

| | checkpoint | set up | working | evidence | remediation | fixed by |
|---|---|---|---|---|---|---|
| ✅ | `stack.tool-pins` | yes | yes | 4 tools pinned and locked: bd 1.3.1, gitleaks 8.30.1, prek 0.5.5, uv 0.13.0 | - | - |
| ✅ | `stack.tools-installed` | yes | yes | installed as pinned: uv 0.13.0, prek 0.5.5, gitleaks 8.30.1, bd 1.3.1 | - | - |

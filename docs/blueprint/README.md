# Blueprint

Written by `blueprint check --write` on 2026-10-14; rewritten on every run.

kind: application · stacks: python-uv (from pyproject.toml, uv.lock) · surfaces: cli · traits: - · tracker: beads · checkpoint set: `422284787105`

engine: shelf `08940947c` · blueprint 0.1.0

concerns checked: stack, gate, backlog, knowledge, secrets, agents · not run: framework · audit-only checkpoints included

## Overrides

none

| layer | concern | ✅ | ❌ | ⚠️ | 🔒 | first to fix |
|---|---|---|---|---|---|---|
| Generic: any repo | gate | 9 | 1 | 0 | 1 | `gate.ci-green`: main 4f9206f: check (failure) |
|  | backlog | 7 | 1 | 0 | 0 | `backlog.strict-config`: import.auto=true (want false) |
|  | knowledge | 3 | 0 | 0 | 0 | - |
|  | secrets | 1 | 0 | 0 | 0 | - |
| Stack-specific | stack/python-uv | 20 | 0 | 0 | 0 | - |
|  | stack | 2 | 0 | 0 | 0 | - |
| Agent harness | agents | 8 | 0 | 0 | 0 | - |

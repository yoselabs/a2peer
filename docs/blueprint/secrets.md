# Blueprint: secrets (Generic: any repo)

Written by `blueprint check --write` on 2026-10-14; rewritten on every run.

kind: application · stacks: python-uv (from pyproject.toml, uv.lock) · surfaces: cli · traits: - · tracker: beads · checkpoint set: `422284787105`

engine: shelf `08940947c` · blueprint 0.1.0

concerns checked: stack, gate, backlog, knowledge, secrets, agents · not run: framework · audit-only checkpoints included

## Overrides

none

| | checkpoint | set up | working | evidence | remediation | fixed by |
|---|---|---|---|---|---|---|
| - | `secrets.encrypted` | - | - | no sops files and no .sops.yaml: this repo seals no secrets | - | - |
| - | `secrets.rule-coverage` | - | - | no sops files and no .sops.yaml: this repo seals no secrets | - | - |
| ✅ | `secrets.scanner` | yes | yes | the gate runs gitleaks | - | - |

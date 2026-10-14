# Blueprint: stack/python-uv (Stack-specific)

Written by `blueprint check --write` on 2026-10-14; rewritten on every run.

kind: application · stacks: python-uv (from pyproject.toml, uv.lock) · surfaces: cli · traits: - · tracker: beads · checkpoint set: `422284787105`

engine: shelf `08940947c` · blueprint 0.1.0

concerns checked: stack, gate, backlog, knowledge, secrets, agents · not run: framework · audit-only checkpoints included

## Overrides

none

| | checkpoint | set up | working | evidence | remediation | fixed by |
|---|---|---|---|---|---|---|
| ✅ | `stack.python-uv.profile` | yes | yes | evidenced profile: toolchain: uv, with a committed lockfile and a declared Python range · formatter: ruff format · linter: ruff check, the shelf's rule set · types: pyrefly, strict preset · spelling: codespell · dependencies: deptry (unused, missing, transitive) · tests: pytest, strict markers · coverage: pytest-cov with a floor · architecture: import-linter (layers, forbidden, independence, acyclic_siblings, protected) for import edges; ruff TID251 banned-api for banned APIs; both read pyproject.toml, one declaration each · hooks: prek runs ruff check and ruff format --check on staged Python files · agent-guidance: docs/agents/python.md: tools per role, placement, naming, comments, traps; python-uv detected from pyproject.toml, uv.lock | - | - |
| ✅ | `stack.python-uv.toolchain` | yes | yes | uv, with a committed lockfile and a declared Python range, run by the gate (`uv lock --check`) | - | - |
| ✅ | `stack.python-uv.formatter` | yes | yes | ruff format, run by the gate (`ruff format --check`) | - | - |
| ✅ | `stack.python-uv.linter` | yes | yes | ruff check, the shelf's rule set, run by the gate (`ruff check`) | - | - |
| ✅ | `stack.python-uv.types` | yes | yes | pyrefly, strict preset, run by the gate (`pyrefly check`) | - | - |
| ✅ | `stack.python-uv.dependencies` | yes | yes | deptry (unused, missing, transitive), run by the gate (`deptry`) | - | - |
| ✅ | `stack.python-uv.tests` | yes | yes | pytest, strict markers, run by the gate (`pytest`) | - | - |
| ✅ | `stack.python-uv.coverage` | yes | yes | pytest-cov with a floor, run by the gate (`cov-fail-under`) | - | - |
| ✅ | `stack.python-uv.spelling` | yes | yes | codespell, run by the gate (`codespell`) | - | - |
| ✅ | `stack.python-uv.architecture` | yes | yes | import-linter (layers, forbidden, independence, acyclic_siblings, protected) for import edges; ruff TID251 banned-api for banned APIs; both read pyproject.toml, one declaration each, run by the gate (`lint-imports`) | - | - |
| ✅ | `stack.python-uv.hooks` | yes | yes | prek runs ruff check and ruff format --check on staged Python files | - | - |
| ✅ | `stack.python-uv.agent-guidance` | yes | yes | docs/agents/python.md: tools per role, placement, naming, comments, traps | - | - |
| ✅ | `stack.python-uv.python-pin` | yes | yes | .python-version 3.12 | - | - |
| ✅ | `stack.python-uv.python-range` | yes | yes | .: >=3.12 | - | - |
| ✅ | `stack.python-uv.python-range-tested` | yes | yes | every lower bound is the pin 3.12 or has a CI run | - | - |
| ✅ | `stack.python-uv.python-ci` | yes | yes | CI takes Python from .python-version through uv | - | - |
| ✅ | `stack.python-uv.uv-version` | yes | yes | pyproject.toml: required-version >=0.13.0 | - | - |
| ✅ | `stack.python-uv.uv-ci` | yes | yes | no setup-uv step and no image copies uv; a mise-action CI installs the mise.toml pin | - | - |
| ✅ | `stack.python-uv.cli-parse` | yes | yes | no parse_known_args or add_help=False outside tests | - | - |
| ✅ | `stack.python-uv.cli-help-tested` | yes | yes | 1 console script(s) and 0 directly run script(s), each run with --help by a test | - | - |
| - | `stack.python-uv.uv-tool` | - | - | a2peer is not installed as a uv tool on this machine | - | - |

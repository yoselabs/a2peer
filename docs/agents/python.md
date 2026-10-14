# Python conventions

Stack: python-uv. The gate is `just check`; this file is what to know before writing code.

## Tools per role

| role | tool | run by |
|---|---|---|
| toolchain | uv | `uv sync --locked`, `uv run <cmd>` |
| formatter | ruff format | `uv run just format` |
| linter | ruff check | `uv run just lint` |
| types | pyrefly (strict) | `uv run just typecheck` |
| spelling | codespell | `uv run just spell` |
| dependencies | deptry, `uv lock --check` | `uv run just deps` |
| tests | pytest, pytest-asyncio | `uv run just test` |
| coverage | pytest-cov (floor 65%) | `uv run just cov` |
| architecture | import-linter (`[tool.importlinter]` in `pyproject.toml`) | `uv run just arch` |
| hooks | prek (`.pre-commit-config.yaml`) | `prek install` |

Why: one tool per role, strictest preset.

## Run

```bash
uv sync                  # environment from the lockfile
just check               # the gate: whole repo, same as CI
uv run pytest path::name # one test while iterating; the gate still decides done
`uv run pytest tests/<file> -x`, then `uv run just check` before handoff
```

Always `uv run <tool>`; never a global interpreter or `pip install`. Add a dependency with
`uv add` (`--dev` for tooling) and commit `uv.lock`.

## Versions

| file | rule |
|---|---|
| `.python-version` | one `X.Y` line; every run uses it (dev, CI, agents) |
| `requires-python` | `">=X.Y"` in every pyproject, no upper cap, the pin inside it |
| CI | a lower bound below the pin runs in CI; Python comes from the pin through uv, never `setup-python` |
| `[tool.uv] required-version` | uv's floor; a different uv rewrites `uv.lock` |

Why: the shelf's ADR 0016. Change the pin and the floors together, then `uv lock`.

## Code rules

| rule | why |
|---|---|
| Full type annotations; no `Any` without a one-line reason; no `# type: ignore` without the error code and a reason | Strict types catch what tests do not |
| Suppress a lint rule per path in `pyproject.toml` with a reason, not inline `# noqa` | Inline hides where the rule is weakened |
| `pathlib` over `os.path`; `from __future__ import annotations`; `X \| None` over `Optional` | One style, fewer imports |
| Every command answers `--help` with its usage and changes nothing, and refuses an unknown flag (ADR 0025): `parse_args`, never `parse_known_args`; keep `add_help`; only a two-stage globals pre-parser is excused, by an `[[override]]` (`id = "stack.python-uv.cli-parse"`, `scope` = the file or `file:line`, a reason, `expires` or `adr`) in `docs/blueprint/blueprint.toml`; a `# lenient:` comment still works for now and is reported with the override to write instead. Each console script has a test running it with `--help` (`stack.python-uv.cli-help-tested`) | Agents probe a command with `--help` before using it; a2kay 2026-10: `serve --help` started a server that committed to main, and five sibling commands had the same shape |
| Dependencies injected at the edge (parameters, a factory); no module-level I/O or global state | Hermetic tests ([testing.md](testing.md)) |
| Comments say why (units, invariant, workaround with a link), never what; a docstring only states a public contract | The code already says what |
| No `print` in library code; return values or log | Output belongs to the surface |
| Dataclass or small class owns its derived state; do not pass loose dicts around | A dict has no contract |

## Layout and naming

| thing | convention |
|---|---|
| Source | `src/<package>/`, one concept per module |
| Tests | `tests/<mirrored source path>/test_<module>.py`; scenarios in `tests/` |
| Names | modules and functions `snake_case`, classes `PascalCase`, constants `UPPER_SNAKE`; a domain term spelled as in `CONTEXT.md` |
| Test names | `test_<behaviour>`; never after a bead or fix |

## Traps

- Mutable default arguments: use `None`, build inside.
- A test reading `HOME`, env or git config: scrub in `conftest.py`.
- `uv` choosing a different Python in a fresh worktree: commit `.python-version`.
- A linter or type checker can skip a hidden folder (a worktree under `.claude/`): pass paths explicitly there.
- A dependency added without `uv lock` fails the gate.

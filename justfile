# Definition of Done: `just check` green over the whole repo -- no carve-outs.
# The runner is just (ADR 0023): pinned as the `rust-just` dev dependency, run as `uv run just <recipe>`.
# No backticks anywhere: `just --dry-run` evaluates them, and blueprint reads this graph from `just --dump`.

set shell := ["bash", "-euo", "pipefail", "-c"]

# The gate. Fast, deterministic tools first; tests last.
[group('gate')]
check: beads-lint guard preset secrets lint typecheck arch spell deps blueprint test

# The commit guard as a gate: finds the guard in-repo or via $SHELF_HOME -> ../shelf -> ~/Workspaces/shelf.
# Exit 2 means the guard could not run, which is never a pass.
[group('gate')]
guard:
    #!/usr/bin/env bash
    set -euo pipefail
    g=tools/hooks/forbid-local-shelf-source.py
    [ -f "$g" ] || g="${SHELF_HOME:-../shelf}/tools/hooks/forbid-local-shelf-source.py"
    [ -f "$g" ] || g="$HOME/Workspaces/shelf/tools/hooks/forbid-local-shelf-source.py"
    if [ -f "$g" ]; then python3 "$g" --committed
    else echo "guard: shelf clone not found (set SHELF_HOME) -- CANNOT VERIFY, not a pass" >&2; exit 2; fi

# Fails on any difference from the shelf's linter preset that [tool.shelf-preset] has not declared with a reason.
[group('gate')]
preset:
    #!/usr/bin/env bash
    set -euo pipefail
    g=tools/preset_drift.py
    [ -f "$g" ] || g="${SHELF_HOME:-../shelf}/tools/preset_drift.py"
    [ -f "$g" ] || g="$HOME/Workspaces/shelf/tools/preset_drift.py"
    if [ -f "$g" ]; then python3 "$g" --repo .
    else echo "preset: shelf clone not found (set SHELF_HOME) -- CANNOT VERIFY, not a pass" >&2; exit 2; fi

# Every bead still to be started (open or blocked) carries its acceptance criteria: criteria are what make a bead
# ready (owner, 2026-10-10); claimed work is past that gate and a deferred idea may stay unfinished. Runs on the
# host, before the container: bd's database lives in this clone (CI bootstraps it from refs/dolt/data first).
[group('gate')]
beads-lint:
    #!/usr/bin/env bash
    set -euo pipefail
    [ -d .beads ] || exit 0
    command -v bd >/dev/null || { echo "beads-lint: bd is not installed -- run just tools" >&2; exit 2; }
    # A clone with no (or an uninitialized) database lints 0 beads and exits 0; that is no pass (shelf-9g7).
    if ! out=$(BD_DISABLE_METRICS=1 bd list --limit 1 --json 2>&1); then
        echo "beads-lint: bd's database does not answer in this clone -- run bd bootstrap" >&2
        case "$out" in *"not initialized"*) echo "  (bootstrap calls an uninitialized one 'nothing to do': mv .beads/embeddeddolt .beads/embeddeddolt.broken first)" >&2;; esac
        exit 1
    fi
    rc=0
    for status in open blocked; do BD_DISABLE_METRICS=1 bd lint --status "$status" || rc=1; done
    exit "$rc"

# No secret in the history (gitleaks, pinned in mise.toml). A false positive goes in .gitleaks.toml with a reason.
[group('gate')]
secrets:
    #!/usr/bin/env bash
    set -euo pipefail
    command -v gitleaks >/dev/null || { echo "secrets: gitleaks is not installed -- run just tools" >&2; exit 2; }
    gitleaks git --no-banner --redact --log-level warn .

[group('gate')]
lint:
    uv run ruff check src tests
    uv run ruff format --check src tests

format:
    uv run ruff format src tests

# A type warning fails the build. No slow rot.
[group('gate')]
typecheck:
    uv run pyrefly check

# Import edges: layers, forbidden and acyclic contracts in pyproject.toml.
[group('gate')]
arch:
    uv run lint-imports

[group('gate')]
spell:
    uv run codespell src tests docs README.md AGENTS.md CONTEXT.md

# Unused, missing and transitive dependencies.
[group('gate')]
deps:
    env -u UV_FROZEN uv lock --check
    uv run deptry .

[group('gate')]
blueprint:
    #!/usr/bin/env bash
    set -euo pipefail
    s=packages/blueprint/src
    [ -d "$s/blueprint" ] || s="${SHELF_HOME:-../shelf}/packages/blueprint/src"
    [ -d "$s/blueprint" ] || s="$HOME/Workspaces/shelf/packages/blueprint/src"
    if [ -d "$s/blueprint" ]; then PYTHONPATH="$s" python3 -m blueprint check --repo . --gate
    else echo "blueprint: shelf clone not found (set SHELF_HOME) -- CANNOT VERIFY, not a pass" >&2; exit 2; fi

[group('gate')]
test:
    uv run pytest --cov --cov-report=term-missing --cov-fail-under=65

# Coverage report without the floor, for looking around.
cov:
    uv run pytest --cov --cov-report=term-missing

# The pinned tools (mise.toml, locked by mise.lock; ADR 0024).
tools:
    mise trust --yes .
    MISE_IGNORED_CONFIG_PATHS="$HOME/.config/mise" mise install --locked

# One-time setup for a consumer repo (commit guard, beads, linter preset). Idempotent.
bootstrap:
    #!/usr/bin/env bash
    set -euo pipefail
    s=.agents/skills/onboard-consumer/scripts/onboard.py
    [ -f "$s" ] || s="${SHELF_HOME:-../shelf}/.agents/skills/onboard-consumer/scripts/onboard.py"
    [ -f "$s" ] || s="$HOME/Workspaces/shelf/.agents/skills/onboard-consumer/scripts/onboard.py"
    if [ -f "$s" ]; then python3 "$s" --repo .
    else echo "bootstrap: shelf clone not found (set SHELF_HOME) -- clone https://github.com/yoselabs/shelf" >&2; exit 2; fi

# Re-check onboarding state; converges drift rather than only reporting it. Same as `bootstrap`.
bootstrap-verify: bootstrap

sync:
    uv sync

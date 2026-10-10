.PHONY: check guard preset bootstrap bootstrap-verify lint format typecheck spell deps test cov sync

# The gate. Fast, deterministic tools first; tests last.
check: guard preset lint typecheck spell deps test

guard:
	@g=tools/hooks/forbid-local-shelf-source.py; \
	 [ -f "$$g" ] || g="$${SHELF_HOME:-../shelf}/tools/hooks/forbid-local-shelf-source.py"; \
	 [ -f "$$g" ] || g="$$HOME/Workspaces/shelf/tools/hooks/forbid-local-shelf-source.py"; \
	 if [ -f "$$g" ]; then python3 "$$g" --committed; \
	 else echo "guard: shelf clone not found (set SHELF_HOME) -- CANNOT VERIFY, not a pass" >&2; exit 2; fi

# The linter preset, as a GATE. Resolution 0004 makes this repo's config the preset and
# says drift is "acceptable and visible" -- it was not visible. The onboarding copy is
# append-only, so it reports "already current" for a repo missing whole rule families.
# This fails on any difference from the preset that the consumer has not declared, with
# a reason, in its own [tool.shelf-preset]. Inside the shelf it is a no-op: this repo IS
# the preset, so there is nothing to compare against.
#
# Consumers copy this target verbatim, same resolution order as `guard`.
preset:
	@g=tools/preset_drift.py; \
	 [ -f "$$g" ] || g="$${SHELF_HOME:-../shelf}/tools/preset_drift.py"; \
	 [ -f "$$g" ] || g="$$HOME/Workspaces/shelf/tools/preset_drift.py"; \
	 if [ -f "$$g" ]; then python3 "$$g" --repo .; \
	 else echo "preset: shelf clone not found (set SHELF_HOME) -- CANNOT VERIFY, not a pass" >&2; exit 2; fi

# One-time (idempotent, safe to re-run) setup for a CONSUMER repo: wires the commit guard,
# resolver block, beads (opt-out), and this linter preset via the operations in
# tools/onboard/ -- ordering and verification are enforced there (run_all()'s precondition
# harness), never re-implemented here as a Make prerequisite graph. See
# openspec/changes/onboard-consumer-skill and openspec/changes/bootstrap-target-contract.
#
# Consumers copy this target the same way as `guard` above. Run inside the shelf's OWN repo,
# the underlying script refuses (there is nothing to onboard here -- this repo IS the shelf).
bootstrap:
	@s=.agents/skills/onboard-consumer/scripts/onboard.py; \
	 [ -f "$$s" ] || s="$${SHELF_HOME:-../shelf}/.agents/skills/onboard-consumer/scripts/onboard.py"; \
	 [ -f "$$s" ] || s="$$HOME/Workspaces/shelf/.agents/skills/onboard-consumer/scripts/onboard.py"; \
	 if [ -f "$$s" ]; then python3 "$$s" --repo .; \
	 else echo "bootstrap: shelf clone not found (set SHELF_HOME) -- clone https://github.com/yoselabs/shelf" >&2; exit 2; fi

# Re-check this repo's onboarding state. NOT a `check` prerequisite -- an environment
# assertion, not a content one (bootstrap-target-contract design.md D4) -- and deliberately
# NOT read-only: the operations converge drift back to correct state on every call rather
# than merely reporting it (tools/onboard/verify.py's whole design). Mechanically identical
# to `bootstrap` above; the separate name signals intent to the caller.
bootstrap-verify: bootstrap

lint:
	uv run ruff check src tests
	uv run ruff format --check src tests

format:
	uv run ruff format src tests

# --error-on-warning: a type warning fails the build. No slow rot.
typecheck:
	uv run pyrefly check

# typos in code, docstrings, and docs.
spell:
	uv run codespell src tests docs README.md AGENTS.md CONTEXT.md

# dependency hygiene: unused, missing and transitive dependencies (deptry).
deps:
	uv run deptry .

test:
	uv run pytest $(PYTEST_PAR) --cov --cov-report=term-missing --cov-fail-under=65

# Coverage report without the floor, for looking around.
cov:
	uv run pytest --cov --cov-report=term-missing

sync:
	uv sync

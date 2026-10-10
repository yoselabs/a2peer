# New project setup — checklist

Raw material for a future skill. Extracted from the a2peer kickoff, 2026-10-10.
Source per item: **D** = Denis asked for it; **+** = added by Claude, the advisor model or Fable.

## 1. Before any code: research and shape

1. **D** Research how others solve it: best practice, what works best, what works worst.
2. **D** Split the problem into lanes when deployment differs (local vs server/remote).
3. **D** State the hard constraints up front (here: subscriptions only, native tool prompts).
4. **+** Each research claim gets a verdict (supported / refuted / untested); a one-pass finding is
   labelled provisional.
5. **D** Consult Fable on the design: blind spots, spikes, decisions not yet made.
6. **+** List spikes (small throwaway experiments) in order, each naming the decision it settles.
7. **+** List open decisions separately from decisions taken; record who decided (owner / session /
   Fable) and what each decision supersedes.
8. **+** Check terms of service for every external service the project drives.

## 2. Name

1. **D** Name research: no clash with similar projects.
2. **D** Plain word the target audience knows (English plus Russian, Ukrainian, Turkish and Spanish
   speakers). No rare words.
3. **+** Screen npm, PyPI, Homebrew, GitHub repos and the MCP registry; check the word has no bad
   meaning in the audience's languages.
4. **+** House convention: `a2` + a noun for the thing on the other side (a2kay, a2web, a2db).
5. **+** Short: the name becomes the MCP tool prefix every agent types each call.

## 3. Workspace

1. **D** New folder under `~/Workspaces/<name>`; move the session there.
2. **+** `git init`; `.gitignore`; no commit without asking.
3. **D** Backlog in beads (`bd init`); parked ideas go to the backlog, not into scope.
4. **+** Spikes as beads; blocked on the owner → `--status blocked` plus a comment saying why.

## 4. Tech stack

1. **D** Decide it explicitly and record it as a decision.
2. **+** Default for a2 tools: Python ≥3.12, uv, FastMCP 3.x, pydantic.
3. **+** Shelf SEAM check before writing any substrate glue: pull the shelf, compare against the
   catalog, adopt (DEEP · STABLE · WINS) by git tag, never a local path.
4. **+** Write down what the project must NOT adopt and why (here: `anyllm`, because it is the raw
   model).

## 5. Strictness

1. **D** Strictest linters available.
   - **+** Adopt the shelf's reference ruff preset whole; gate drift with `preset_drift.py`.
   - **+** `ty` type checker, strict preset.
   - **+** Complexity ceiling (mccabe 12).
2. **D** Layering and joints (seams) enforced, not just documented.
   - **+** Import contracts from day one (import-linter or tach — one tool, not both).
   - **+** Lower layers never import upper ones; sibling adapters never import each other.
3. **+** One gate: `make check` = lint + types + tests with coverage + architecture.
4. **+** Pre-commit: ruff, ruff-format, pymarkdown, actionlint; ty on pre-push.
5. **+** Secrets from env only; subprocess calls in list form.

## 6. Code structure

1. **D** Decide the codebase structure up front.
2. **+** Layers by dependency direction: `core` (types, protocols, no IO) → `adapters` / `store` →
   `orchestration` → entry points (`mcp`, `cli`).
3. **+** Every external system sits behind a Protocol in `core`; that Protocol is the mock seam.

## 7. Testing

1. **D** Behaviour-driven development as much as possible.
   - **+** Gherkin features under `tests/usecases/<area>/`, driven through the real entry point
     (shelf `mcp-steps` for MCP servers).
   - **+** `@spec:` tags bind each scenario to a requirement; `bdd-tags` handles `@known_bug` and
     `@pending`.
2. **D** Integration testing and mocking strategy.
   - **+** Unit lane: in-process fakes at the Protocol seam.
   - **+** Integration lane (default): fake executables on PATH that speak the real tool's output
     format, driving the full stack.
   - **+** Vendor lane: opt-in marker, real logged-in tools, cost-capped, excluded from `make check`.
   - **+** Contract goldens: real outputs captured once, byte-for-byte, so formats are pinned by tests,
     not memory.
3. **+** Coverage gate in `make check`, not in the inner loop.

## 8. Instructions and code style

1. **D** Code style and agent instructions.
2. **+** `CLAUDE.md` (with `AGENTS.md` as a symlink to it): what the repo IS / IS NOT, hard
   constraints, operating rules, the shelf resolver block.
3. **+** Adopt the a2 Constitution; cite its articles in decisions.

## 9. Knowledge

1. **D** Basic knowledge library and ontology for everything about the project.
2. **+** One job per system, no fourth one:
   - beads = work queue;
   - openspec = requirements and change proposals;
   - a2kay repo vault (kernel pack) = decision, option, research, probe (spike), question, source.
3. **+** Move the design draft into vault entities; keep a one-page overview linking them.
4. **+** A glossary: every coined name glossed by its job on first use.

## 10. Measure the value claim

1. **+** If the project rests on an unproven benefit (here: debate beats one opinion), log every use
   and its outcome from day one so the claim can be tested.

## 11. Added in the second pass (Claude)

1. **+** CI from the first commit: GitHub Actions running the same `make check`; git remote, and
   `bd dolt remote add` so beads syncs.
2. **+** Release story: semver tags, CHANGELOG, install path (`uv tool install` / `uvx`), config
   location (`~/.config/<name>`).
3. **+** Dependency pins with upper bounds; pin external CLIs the project drives to tested versions.
4. **+** Threat model before the first feature: what data leaves the machine to which vendor, what
   input is untrusted, what can run commands.
5. **+** Error taxonomy decided once (shelf `a2effect`), not per module.
6. **+** Observability: structured logs; OpenTelemetry spans per tool call (a2mcp pattern).
7. **+** Definition of done per bead: tests, `make check` green, decision or spec updated.
8. **+** Spike loop: each spike result updates the decision it was created for, then closes.
9. **+** Dogfood early: register the tool in your own agent sessions as soon as one path works.
10. **+** Agent ergonomics check: tool names and descriptions tested with a real agent (a2web `eval`
    pattern), since agents are the users.
11. **+** Repo hygiene files: LICENSE, README with a one-line purpose, SECURITY.md.

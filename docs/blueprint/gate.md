# Blueprint: gate (Generic: any repo)

Written by `blueprint check --write` on 2026-10-14; rewritten on every run.

kind: application · stacks: python-uv (from pyproject.toml, uv.lock) · surfaces: cli · traits: - · tracker: beads · checkpoint set: `422284787105`

engine: shelf `08940947c` · blueprint 0.1.0

concerns checked: stack, gate, backlog, knowledge, secrets, agents · not run: framework · audit-only checkpoints included

## Overrides

none

| | checkpoint | set up | working | evidence | remediation | fixed by |
|---|---|---|---|---|---|---|
| ✅ | `gate.one-command` | yes | yes | `just --dry-run check` resolves | - | - |
| ✅ | `gate.runner` | yes | yes | a justfile holds the gate | - | - |
| ✅ | `gate.ci` | yes | yes | 1 workflow(s) run the gate, pinned, with permissions | - | - |
| ✅ | `gate.ci-no-manifest-edit` | yes | yes | 1 workflow(s): no step before the gate edits a manifest or re-locks | - | - |
| ✅ | `gate.hooks-recipe` | yes | yes | .pre-commit-config.yaml owns the hooks, bd's five events run from it | - | - |
| ✅ | `gate.hooks-installed` | yes | yes | prek's hooks installed in .git/hooks; no bd block injected | - | - |
| ✅ | `gate.runs-blueprint` | yes | yes | `just check` reaches `blueprint check --gate` | - | - |
| - | `gate.guards-have-red-tests` | - | - | `just check` runs no repo-local Python script | - | - |
| 🔒 | `gate.clean-clone` | - | - | fresh-clone step `bd bootstrap --yes` failed: mise ERROR Run with --verbose or MISE_VERBOSE=1 for more information; the working tree passes in a snapshot clone: commit to verify (uncommitted: .beads/hooks/post-checkout, .beads/hooks/post-merge, .beads/hooks/pre-commit, .beads/hooks/pre-push, .beads/hooks/prepare-commit-msg and 36 more) | commit the changes on the owner's yes and re-run the audit; a file the gate needs but nobody commits belongs in the gate | owner |
| - | `gate.checkers-wired` | - | - | no check_*/lint_* script under tools/ or scripts/ | - | - |
| ✅ | `gate.default-branch` | yes | yes | the default branch is main | - | - |
| ✅ | `gate.git-remote` | yes | yes | origin: git@github.com:yoselabs/a2peer.git | - | - |
| ❌ | `gate.ci-green` | yes | no | main 4f9206f: check (failure) | `gh run view --log-failed` on the red run; fix it before anything else ships | agent |
| - | `gate.lfs-binaries` | - | - | the repo declares no LFS pattern (.gitattributes has no filter=lfs) | - | - |
| - | `gate.git-config-clean` | - | - | not the main checkout of a non-bare clone (a linked worktree or no git repository) | - | - |
| - | `gate.lfs-installed` | - | - | the repo declares no LFS pattern (.gitattributes has no filter=lfs) | - | - |

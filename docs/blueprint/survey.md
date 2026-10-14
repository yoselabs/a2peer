# Blueprint run survey: bridge-cse_016Vb152cRTCogVhPQaP5qav

Checkpoint set: `422284787105`. Answer every row with one of: yes · partly · no · n/a. Evidence is one line: a row id, a file, a quote. Anything worth a checkpoint goes in Lacks.

## experience

Did the run meet the owner's expectations of blueprint?

| id | question | answer | evidence |
|---|---|---|---|
| E1 | The report says, per stack, which tools the repo will use for each role (formatter, linter, types, tests, coverage) and what gets installed | yes | docs/agents/python.md role table |
| E2 | Every finding sits under its concern (gate, backlog, stack, ...), one table per concern, not one mixed list | yes | one file per concern in docs/blueprint/ |
| E3 | Each failing row names its remediation and who applies it (auto, agent, owner) | yes | remediation + fixed-by columns in every table |
| E4 | The chat carried only the summary table, at most three owner decisions and any mistakes (SKILL.md section 4); no prose recap of the report | partly | chat had summary + 2 decisions; several progress notes were added |
| E5 | Nothing was asked of the owner that the agent could have found itself | partly | owner had to restate "shelf blueprint skill"; the skill was not in my skill list, found in ~/Workspaces/shelf/skills/blueprint |
| E6 | The audit changed nothing outside docs/blueprint/ before the owner's yes | yes | audit wrote only docs/blueprint/ (git status) |
| E7 | The report and the chat kept the layers apart: generic, stack-specific, framework-specific, agent harness | yes | summary table grouped by layer |
| E8 | A stack or role with no standard was said plainly as 'no standard for this stack yet', not as a repo failure | n/a | python-uv has a profile |
| E9 | The run felt managed: the owner saw the summary and their decisions only, no narration of the process | partly | tool-by-tool work was visible in the terminal |

## completeness

Did blueprint cover what this repo needs?

| id | question | answer | evidence |
|---|---|---|---|
| C1 | The engine detected every stack the repo uses (name any it missed in the evidence) | yes | python-uv from pyproject.toml, uv.lock |
| C2 | Every stack had a profile, and every role in it had a tool (name roles left untested) | yes | all roles present, stack-python-uv.md |
| C3 | The concerns checked cover what matters here; name the concerns this repo needs that blueprint lacks | yes | no missing concern seen |
| C4 | Every framework in use (game engine, web framework) was detected and judged from its own profile, or named as a blueprint gap | n/a | no framework in use |
| C5 | Each 'not checked' row says why, and the reason is outside the repo's control | yes | gate.lfs-* n/a rows state why |

## correctness

Were the verdicts and remediations right?

| id | question | answer | evidence |
|---|---|---|---|
| R1 | Every verdict matches what you see in the repo (name rows you disagree with) | partly | gate.ci-green stays red until a green run on main; backlog.strict-config reads main checkout in a worktree |
| R2 | Every remediation is safe and complete as written (name ones that were wrong or partial) | partly | hooks-recipe remediation said git rm --cached but the recipe alone does not keep existing ruff hooks; preset_drift owed private recipe steps (bead filed in shelf) |
| R3 | Remediated rows turned passing on re-check (name any that did not) | yes | re-audit: 2 non-green rows left, both resolve on merge/push |

## cost

What did the run cost, and what should be a script?

| id | question | answer | evidence |
|---|---|---|---|
| K1 | The engine ran in under a minute (give the wall time) | yes | audit under a minute, clean-clone included |
| K2 | The agent did no repeated manual inspection a script could do (name it if it did) | partly | read each concern file by hand to get remediation rows |
| K3 | Bulk work went to a cheaper model where the harness allowed it (name the harness and model in the evidence) | no | Claude Code, no subagent used; one small repo, done inline |

## Lacks

One line each: `blueprint lacks: <what>` (also filed as a bead in the shelf).

blueprint lacks: preset_drift demands the shelf-private `steps` recipe (bead filed in the shelf)

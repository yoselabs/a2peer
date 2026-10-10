# a2peer — design draft

Status: draft, 2026-10-10. Nothing built yet. Name: `a2peer` (npm, PyPI, GitHub free).

## Goal

From one agent session (Claude Code first), consult other agents as advisors: second opinion,
multi-round debate, or delegate a task the caller is confident delegating. Reverse direction too
(Grok consults Claude).

## Hard constraints

- **Subscriptions only.** Claude Max, ChatGPT (Codex), SuperGrok (Grok Build). No pay-per-token API
  billing, ever. Consequence: OpenCode + Grok model (needs an xAI API key) is out.
- **Talk to the tool, not the raw model.** Each advisor runs in its vendor's own harness with its
  native system prompt. We never override it. Consequence: LiteLLM `codex-sub` (raw ChatGPT
  completions via homelab codex-proxy) is not an advisor.
- **Sessions persist.** An advisor keeps its own session across turns so debates have memory.

## Advisors (adapters)

| profile | harness | start | resume | auth |
|---|---|---|---|---|
| `grok` | Grok Build CLI | `grok -p "…" --output-format json` | `grok -p "…" -r <id>` | SuperGrok login |
| `codex` | Codex CLI | `codex exec --json "…"` (or built-in `codex mcp-server`) | `codex exec resume <id> "…"` (or `codex-reply`) | ChatGPT login |
| `claude` | Claude Code | `claude -p "…" --output-format json` | `claude -p "…" --resume <id>` | Claude Max (official CLI) |
| `gpt-oc` (optional) | OpenCode + OpenAI model | `opencode run --format json "…"` | `opencode run -s <id> …` | ChatGPT via community plugin; OpenCode's prompt, not OpenAI's |

All flags unverified until spike 1.

Adapter contract: `start(prompt, cwd, mode) -> (advisor_session_id, result)`,
`resume(advisor_session_id, prompt) -> result`.

## Decisions taken

- **One advisor session per (caller chat, advisor). Topics are tags inside it, not separate
  sessions.** Owner decision, 2026-10-10. The caller chat id is set by the orchestrating agent:
  locally a SessionStart hook gives Claude its own session id to pass; elsewhere the server issues
  an id on the first call and the caller reuses it. New caller chat ⇒ fresh advisor sessions. Each
  message carries a `topic` tag in its header, so the advisor sees every topic of the chat in one
  memory and can relate them ("this ties to what we said about X"). The server logs topic per turn
  so `threads` can list them. Optional later: `--fork` a topic into its own advisor session when it
  is truly separate. Supersedes Fable's named-topic-per-project key.
- **Local mode: advisors run in the caller's repo**, so relative paths mean the same file for every
  agent.
- **Interface = MCP server** (Python, FastMCP), plus a thin CLI over the same core for debugging.
  - MCP `instructions` built at startup from advisors actually available (CLI installed + logged in).
  - MCP prompts as ready-made workflows: `second-opinion`, `debate`, `delegate`.
- **Async job model.** `ask` returns the answer if done within N seconds, else a job id; `wait(job,
  max_s)`; progress notifications where the client supports them. Same code for both lanes.
- **Read-only advisors run in the caller's real folder, no copy.** Owner decision, 2026-10-10,
  supersedes Fable's worktree-per-call. Enforced by the vendor's read-only mode plus an a2peer check:
  `git status --porcelain` before and after each turn; any change fails the result loudly and marks
  that advisor's read-only mode untrusted. Only `--worker` advisors get a git worktree, created once
  per (chat, advisor) on its own branch and reused, never per call. Spike 2 checks whether vendor
  read-only modes really block writes.
- **Structured result**, not free text: verdict, reasons, confidence, files referenced, cost (wall
  time; pool usage where visible). The caller judges on evidence.
- **Debate is triggered by disagreement.** Round 1 independent; if they agree, stop; if not,
  cross-feed answers into each retained session, cap 2 more rounds; the caller decides and records
  why.
- **Budget per advisor** (daily cap in config; a debate counts 3x). Grok's weekly pool is the
  scarcest resource.
- **One codebase, two deployments.** Local stdio where the repo is; remote HTTP on the homelab
  behind a2mcp (Google OAuth). Separate SQLite per deployment.
- **LiteLLM front: no for v1.** Chat-completions is stateless (client resends history) vs our
  stateful native sessions.
- **Log every consult** (question, round-1 answers, verdict, caller's final call; outcome filled
  later) to measure whether debate beats a single opinion.

## Open decisions

1. **Remote mode — backlog.** Owner direction: the host agent says which folder/repo it means and
   shares content on demand. Proposed flow: each remote caller chat gets a workspace folder on the
   server mirroring the host repo's relative paths; an advisor turn may end with `needs: [files…]`;
   the server returns `status: needs_context` to the caller; the caller sends those files in its
   next call; the server writes them into the workspace and resumes the advisor. Agent-to-agent by
   turns, no live callback needed.
2. Which caller surfaces are first-class: Claude Code only, or also claude.ai / mobile.
3. Re-auth on the homelab box (how often headless logins expire) and blast radius (three
   subscription logins on one box).
4. Grok terms on headless/automated use from a server — read xAI consumer terms first.
5. Adopt vs build for Codex: `codex mcp-server` + `openai/codex-plugin-cc` may cover the Codex-only
   path; build only the thread registry, debate and instructions on top.

## Spikes, in order

1. **Headless auth + resume** for `grok`, `codex`, `claude`, including resume after the advisor's
   own compaction, and the session-id field in each JSON output. Decides adapter feasibility.
2. **Read-only**: do vendor flags hold; confirm worktree isolation.
3. **MCP plumbing**: Claude Code stdio tool timeout; via a2mcp to claude.ai — timeout, and whether
   `instructions` and prompts surface at all. Decides dynamic instructions and async details.
4. **Cost**: one Grok review vs a 3-round debate against the weekly pool. Decides budget policy.
5. **`codex mcp-server` used directly** vs our wrapper. Decides adopt/build for Codex.
6. Does Grok Build have an MCP-server mode? If both vendors do, the tool shrinks to registry +
   debate + instructions.

## Risks (terms of service), highest first

1. Homelab `codex-proxy` raw-completions sidecar (reverse-engineered backend) — existing, outside
   this tool.
2. Anything exposing Claude Max as a model — forbidden already.
3. Grok headless on a server driven by another agent — unknown until terms are read.
4. `codex exec`, `claude -p` — documented headless modes used as designed.

## Not used, and why

- OpenCode + Grok: per-token xAI API key.
- PAL `clink`, multi_mcp, claude-octopus: API-key based or no Grok CLI support.
- grok-build-mcp-server wrappers: one-shot, no resume.
- Raw APIs: no tools, no native prompt.

## Evidence on debate

Early multi-agent debate work (Du et al. 2023) reports gains on verifiable tasks; later work (Smit
et al. 2024) finds a single strong model often matches and debaters drift to the majority. Our case
differs: different vendors and harnesses, not one model in three roles. Untested; the consult log
decides.

## Gaps not yet designed (2026-10-10)

1. **Advisor output is untrusted data.** It returns into the caller's context; a2peer must frame it as
   data, never instructions. Worker mode can run commands: decide its sandbox.
2. **Brief: decided, tunable.** Owner, 2026-10-10. The text a2peer adds to each message is
   configurable per advisor and evaluated, including the variant of adding nothing. Starting text:
   you are advising another agent; ask if you need anything; debate when you disagree.
3. **No recursion limit in a2peer.** Owner, 2026-10-10. The caller agent decides when a
   back-and-forth stops moving and escalates to the human.
4. **Health and discovery.** How a2peer detects installed + logged-in advisors and remaining quota;
   quota exhausted → status `exhausted`, not an error.
5. **Cancel and cleanup.** Job cancel, orphan child processes, stale worker worktrees.
6. **Retention.** How long threads and vendor session files live; who deletes them.
7. **Per-advisor model choice.** Grok model, Codex model and reasoning effort, in config.
8. **Privacy.** Which repo content goes to which vendor; per-repo opt-out.
9. **Vendor CLI drift.** Pin tested CLI versions; contract goldens catch format changes.
10. **Two caller chats in one repo** with workers at the same time.

## Grilling round 1 — owner answers (2026-10-10)

1. **Debate in v1 = caller ↔ one advisor**, back and forth through repeated `ask`. A debate between
   a2peer's own advisors is backlog (`a2peer-0yv`).
2. **Advisors are read-only in v1.** They may create temporary files and run scripts of their own.
   Worker mode is backlog (`a2peer-yfm`).
3. **v1 advisors: Grok Build and Codex.** Claude as advisor is backlog (`a2peer-2ao`). OpenCode / Pi
   profiles are a later comparison experiment (`a2peer-9bg`); they do not use the vendor's own prompt.
4. **Profiles may share a tool** (e.g. `grok-critic`), but v1 ships plain `grok` only.
5. **No spending limits in v1.** A tool reporting its quota is used up returns a distinct status
   `exhausted` with the tool's own message, not a generic error. Limits research is backlog
   (`a2peer-9eq`).
6. **Reply is free text in v1.**
7. **Consult log: yes, local JSON lines. No `rate` tool.**
8. **Installed locally 2026-10-10:** codex-cli 0.162.1 (npm), grok 1.0.50 (x.ai installer; also added
   `~/.local/bin/agent` and a PATH line in `~/.zshrc`). Logins pending. Docker image belongs to
   remote mode.

## Grilling round 2 — owner answers (2026-10-10)

1. **Version awareness.** a2peer should know each advisor tool's version and whether it is up to
   date; v1 if cheap, else backlog (`bd` "Advisor CLI version check").
2. **Pending replies carry a hint.** A reply not ready in time returns `pending` plus a `hint` field
   telling the caller exactly what to do: call `check` with the same chat and advisor, first after
   ~10 s, then backing off, never waiting longer than 10 minutes between checks. Each `check` also
   returns a short progress note (latest advisor activity).
3. **Isolation is crucial**, including for less trusted harnesses (e.g. a DeepSeek-based agent).
   Scratch folder and advisor bash are allowed, inside isolation. Research running:
   `docs/research/isolation.md`.
4. **Chat identity: delegated to session.** Decision (session): one a2peer process per Claude Code
   chat is the chat identity in v1; `claude --resume` starts fresh advisor sessions; a hook to keep
   them is backlog.
5. **Settings:** global defaults, overridable by server arguments (e.g. in a project `.mcp.json`).
   Distribution (MCP bundle, local server, Docker) is open and depends on isolation.
6. **Advisor needs something:** it asks in plain text; the caller answers with the next `ask`.
7. **Where it is registered:** open; owner unsure how it will be used day to day.

## Grilling round 3 — owner answers (2026-10-10)

1. **Isolation: one Docker container per advisor tool, same setup on Mac (OrbStack) and homelab.**
2. **Scratch files** live in a disposable place outside the repo, kept per advisor session so they
   survive a2peer and container restarts and can be wiped any time.
3. **Network: open.** No egress proxy. Owner does not want extra safety layers beyond this.
4. **Secrets hidden at mount level** (Docker mount rules), not by asking the advisor.
5. **Untrusted harnesses run the same way as Grok** (Docker, Mac included). Owner accepts the shared
   OrbStack VM.
6. **Subscriptions only, no API keys.** No terms-reading gate.
7. **Fast availability detection at startup:** which advisors are logged in and usable (e.g. Codex
   may be unavailable on a low or missing subscription). Only usable advisors are offered.
8. Not answered, session defaults stand: a2peer runs on the host (uvx) and manages the containers;
   one container per (advisor tool, repo), started on first use, stopped when idle.

## Grilling round 4 — owner answers (2026-10-10)

1. **No log reading by the owner.** Instead, later: a live debate viewer as an MCP App (backlog).
2. **Setup:** `a2peer setup` exists, plus one preparation guide written so an AI agent can walk the
   owner through logins. No per-service login wizardry required in v1.
3. **Availability check spends zero tokens.** Use each tool's own auth-status command (e.g.
   `codex login status`). Session design: runs in the background, never blocks startup; result
   cached in one host file shared by all a2peer processes, so per-chat / per-repo starts do not
   re-run it. A missing plan is only discovered on the first real `ask`; that advisor is then
   marked unavailable in the shared cache.

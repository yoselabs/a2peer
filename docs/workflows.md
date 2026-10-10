# a2peer — user workflows and where they break

Draft, 2026-10-10. Written from Denis's side: what he does, what he sees, what a2peer does
underneath. Each flow ends with its break points; each break point names the decision or spike that
settles it. Terms: see `../CONTEXT.md`.

## W1. First setup on a new machine

1. Denis installs a2peer (`uv tool install a2peer`) and adds it once to Claude Code's MCP config.
2. He runs `a2peer setup`: it checks Docker/OrbStack is running, pulls or builds one image per advisor
   tool, creates the volumes.
3. `a2peer login grok` runs the tool's device-code login inside the container; Denis opens the link and
   approves. Same for `codex`.
4. `a2peer status` prints each advisor: ready / not logged in / no subscription / tool outdated.

Breaks:
- **B1.1** Codex device-code login is off by default in ChatGPT security settings → login fails with an
  unclear message. a2peer must detect it and say exactly which setting to enable.
- **B1.2** A logged-in account without the needed plan (Codex on a low or missing subscription) looks
  "logged in" but every call fails. Detection must make one real cheap call, not only check that an
  auth file exists. Cost of that call against the quota: spike.
- **B1.3** Docker not running → every advisor unavailable. The status and the MCP instructions must say
  "start OrbStack", not list zero advisors silently.
- **B1.4** Image build pulls the vendor installer from the internet → pin the tool version in the image
  (ties to the version-check bead).

## W2. Everyday second opinion

1. In a Claude Code chat Denis says: "ask Grok whether this migration plan is sane."
2. Claude calls `ask(advisor="grok", message=<plan + file paths>, topic="migration")`.
3. a2peer: first call in this chat → new Grok session in the (grok, repo) container; adds the brief;
   runs `grok -p … --output-format json`; stores the session id; checks `git status` before/after.
4. Reply within ~50 s → Claude reads it and tells Denis what Grok said and whether Claude agrees.

Breaks:
- **B2.1** Claude pastes whole files into the message instead of paths → wasted tokens. The MCP
  instructions must say: send paths, the advisor reads the repo itself.
- **B2.2** The repo is mounted at the same absolute path, so paths match. But a Claude Code session
  running in a git worktree (`.claude/worktrees/x`) has a different root: the container must mount
  the folder Claude is actually in. Which folder a2peer sees as "the repo": spike 3 (cwd of the MCP
  process).
- **B2.3** Uncommitted edits: the read-only mount is live, so Grok sees Claude's latest edits. Claude
  editing a file while Grok reads it gives Grok a half-written file. Accept for v1; mention in
  instructions ("don't edit files you just asked about until the reply is back").
- **B2.4** Claude relays Grok's answer as fact. Instructions must frame advisor replies as another
  agent's opinion, to be judged.

## W3. Debate, back and forth

1. Denis: "debate with Grok about the save format until you agree or get stuck."
2. Claude asks, reads, disagrees, asks again in the same chat and topic. Grok's session remembers the
   earlier rounds.
3. Claude stops when they converge or stop moving, and reports both positions and its verdict.

Breaks:
- **B3.1** Both agents drift into agreeing politely. The brief says "debate when you disagree"; whether
  that is enough is what the brief evaluation measures.
- **B3.2** Grok's session grows long and Grok compacts it on its own; earlier rounds may be summarised
  away. Spike 1 checks resume after the tool's own compaction.
- **B3.3** Denis wants to see the actual exchange, not Claude's summary. Need a way to read the
  transcript: `a2peer log --chat … --advisor grok` from the consult log.

## W4. Slow reply

1. Grok takes 4 minutes on a large question. After ~50 s `ask` returns `pending` with a `hint`: call
   `check(chat, advisor)` after 10 s, back off, never wait more than 10 minutes between checks.
2. Each `check` returns a short note of what Grok is doing (from its streaming events).

Breaks:
- **B4.1** Claude ignores the hint, or ends its turn with the reply still pending → the reply lands
  nowhere. The hint must say "do not end your turn while a reply is pending". The result stays stored,
  so a later `check` still gets it.
- **B4.2** Claude asks the same advisor again while a reply is pending in that session → the tool's
  session would get two writers. a2peer must refuse with `busy` and the pending hint.
- **B4.3** Denis interrupts Claude. The Grok process keeps running and keeps using quota. Need
  `cancel`, or a rule that an unchecked pending reply is killed after N minutes.

## W5. Advisor needs something

1. Grok replies: "I need the error log and to know which Python version you run."
2. Claude answers with the next `ask` in the same session.

Breaks:
- **B5.1** Grok asks for a file outside the repo (the log is in `/tmp` on the Mac). It cannot read it.
  Claude must paste content or copy it into the repo; instructions say so.

## W6. Advisor runs out of quota mid-debate

1. Grok's weekly pool runs out; its CLI returns an error.
2. a2peer returns status `exhausted` with the tool's own message; Claude tells Denis and offers
   another advisor.

Breaks:
- **B6.1** Each tool words quota errors differently and may change wording. Detection by pattern is
  fragile → contract goldens of real quota errors when we hit them.
- **B6.2** After `exhausted`, `status` should show the advisor as unavailable until reset, so the next
  chat does not try it first.

## W7. New chat, compaction, resume

1. Denis opens a new Claude chat → new a2peer process → fresh Grok session.
2. A long chat compacts → same a2peer process → same Grok session continues.
3. `claude --resume` of yesterday's chat → new a2peer process → fresh Grok session (accepted for v1).

Breaks:
- **B7.1** After compaction Claude forgets that it already talked to Grok. Cheap fix: every `ask`
  reply includes "this session has N earlier consults on topics: …".
- **B7.2** Spike 3 must confirm Claude Code really starts one MCP process per chat and keeps it across
  compaction. If it shares one process across chats, chat identity breaks.

## W8. Two projects, two chats at once

1. Denis works in `lifesim` and `a2peer` in parallel, both consulting Grok.
2. Two containers: (grok, lifesim), (grok, a2peer). Both share the one Grok login.

Breaks:
- **B8.1** One login, two containers: both refresh the same OAuth token; one refresh can invalidate the
  other's token. The login volume must be shared and the tool must tolerate it — spike.
- **B8.2** Idle containers pile up. Stop after idle N minutes; start again on next ask.

## W9. Scratch files

1. Grok writes `probe.py` to `/scratch` and runs it.
2. Days later Denis wants to see it.

Breaks:
- **B9.1** Scratch is kept per advisor session on the host (e.g. `~/.local/share/a2peer/scratch/
  <chat>/<advisor>/`), mounted into the container. Retention: delete after N days; `a2peer clean`.
- **B9.2** Grok writes to `/tmp` instead of `/scratch` → lost on container restart. Set `TMPDIR` and
  `HOME` subfolders to point into scratch.

## W10. Secrets

1. The repo has `.env` and `secrets/`.
2. a2peer mounts empty files over `.env*` and listed paths, so the advisor cannot read them.

Breaks:
- **B10.1** A secret file created after the container started is not masked (masks are set at start).
  Restart the container when the mask list or matching files change, or check before each ask.
- **B10.2** Secrets inside tracked files (a token in `config.yaml`) are not covered. Accepted; stated in
  docs.

## W11. Maintenance

1. A new Grok version is out; the login expires after weeks.
2. `a2peer status` shows "update available" and "login expired"; `a2peer update` rebuilds the image.

Breaks:
- **B11.1** A tool auto-updates itself inside the container and changes its output format →
  disable self-update in the image; versions change only through `a2peer update` plus contract tests.

## Cross-cutting

- **C1** Every error Claude sees must say what to do next (start OrbStack, run `a2peer login grok`,
  wait for reset). The error text is part of the interface.
- **C2** The consult log is the source for transcripts (W3), the brief evaluation and debugging.

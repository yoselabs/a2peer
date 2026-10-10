# a2peer — glossary

**Caller** — the agent that asks for help and decides what to do with the answers (Claude Code
first). It decides when a discussion stops and when to escalate to the human.

**Advisor** — another agent the caller consults, running in its vendor's own tool with that tool's
own system prompt (Grok Build, Codex CLI, Claude Code).

**Profile** — a named advisor in config: which tool, which model, which brief. Two profiles may use
the same tool.

**Chat** — one conversation of the caller. Identified by a chat id the caller supplies, or one a2peer
issues on the first call.

**Advisor session** — the advisor tool's own conversation, kept for one chat and one profile. A new
chat starts new advisor sessions.

**Topic** — a label on a message inside an advisor session, so one session can hold several related
subjects.

**Brief** — the text a2peer adds to the caller's message before it reaches the advisor. Never the
advisor's system prompt.

**Consult** — one message from the caller to an advisor and its reply.

**Worker** — an advisor allowed to change files, in its own git worktree.

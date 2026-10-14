---
id: 0001
title: One advisor session per caller chat and advisor
statement: Each (caller chat, advisor) pair has one retained advisor session; topics are tags inside it, and a new caller chat starts fresh advisor sessions.
concerns: [domain]
status: accepted
decided_by: owner
updated: 2026-10-14
---

# 0001 — One advisor session per caller chat and advisor

The caller chat id is set by the orchestrating agent. Every message carries a `topic` tag so the advisor sees all topics of the chat in one memory. Separate sessions per topic are an optional later `--fork`.

## History

Recorded from docs/design.md (owner decisions of 2026-10-10) when the repo was onboarded to the blueprint.

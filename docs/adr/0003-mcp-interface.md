---
id: 0003
title: The interface is an MCP server over one core
statement: a2peer is a Python MCP server (FastMCP) with a thin CLI over the same core; one codebase serves local stdio and remote HTTP, each with its own SQLite.
concerns: [architecture]
status: accepted
decided_by: owner
updated: 2026-10-14
---

# 0003 — The interface is an MCP server over one core

`ask` returns the answer if done within N seconds, else a job id for `wait`. Results are structured (verdict, reasons, confidence, files, cost). Every consult is logged to measure whether debate beats a single opinion.

## History

Recorded from docs/design.md (owner decisions of 2026-10-10) when the repo was onboarded to the blueprint.

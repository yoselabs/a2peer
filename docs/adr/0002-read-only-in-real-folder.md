---
id: 0002
title: Read-only advisors run in the caller's real folder
statement: Read-only advisors work in the caller's real folder with no copy, guarded by the vendor's read-only mode and a git status check before and after each turn; only worker advisors get a git worktree.
concerns: [architecture]
status: accepted
decided_by: owner
updated: 2026-10-14
---

# 0002 — Read-only advisors run in the caller's real folder

Any change found by `git status --porcelain` fails the result loudly and marks that advisor's read-only mode untrusted. Worker advisors get one worktree per (chat, advisor), reused, never per call.

## History

Recorded from docs/design.md (owner decisions of 2026-10-10) when the repo was onboarded to the blueprint.

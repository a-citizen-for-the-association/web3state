# 0001. Record architecture decisions

**Date:** 2026-10-03
**Status:** Accepted

## Context

This project is expected to grow into a large, long-running effort (modeling the institutional functions of a nation-state as smart contracts), with people joining after major decisions have already been made. Without a record, the reasoning behind past choices gets lost, and the project risks re-litigating settled questions or silently drifting from its original intent.

## Decision

We will use lightweight Architecture Decision Records (ADRs), stored in `docs/decisions/`, for any decision that is expensive to reverse. Each ADR is numbered sequentially, dated, and immutable once accepted — changes are made by superseding, not editing.

## Consequences

- Anyone joining the project can read `docs/decisions/` in order to understand how the current architecture came to be.
- Decisions carry an explicit paper trail separate from code history (git log) and from the living status snapshot (`docs/PROJECT_STATUS.md`).
- Adds a small amount of process overhead for significant decisions; day-to-day implementation choices are explicitly exempted (see `docs/decisions/README.md`).

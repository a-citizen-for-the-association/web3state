# 0010. Employee ID credential: corporate-registration reuse, no ResidentLink dependency

**Date:** 2026-10-09
**Status:** Accepted

## Context

Following health insurance (ADR 0009), the fifth concrete instance of the general "credentials" pattern designed was the employee ID (社員証). Its trust-anchor had effectively already been identified when the general credentials pattern was first discussed (any registered corporation can issue from its own existing [corporations](0005-corporate-registration-model.md) registration address, the same way the corporations design let employee IDs piggyback on corporate registration with no new mechanism). Discussion (see [`docs/state-design/credentials/employee-id/discussion-log.md`](../state-design/credentials/employee-id/discussion-log.md)) confirmed this and resolved sole-proprietor scope, granularity, lifecycle, and — the most substantive new point — whether a `ResidentLink` precondition applies, all in a single round with no disagreement.

## Decision

- **Issuer = any registered corporation**, using its existing corporate-registration address — no new trust-anchor mechanism, unlike every prior credential which had a specific authority type (government body, school, insurer).
- **Sole proprietors (個人事業主) cannot issue this credential.** They have no corporate registration address to issue from, per the corporations design's scope exclusion. Their employees simply have no on-chain `EmployeeID` under this design.
- **One contract per company, no further granularity** — mirroring license/health-insurance's resolution: proves only "currently employed here," not department, role, or clearance level.
- **Lifecycle is continuous, not periodically renewed** — same shape as health insurance: mint on hiring, burn on employment ending (any reason, kept off-chain), no self-burn (including for resignation, for the same reason passport's 国籍離脱 self-burn was ultimately rejected — invalidating a controlled credential stays authority-side even when the underlying real-world action is personally initiated), no renewal cycle.
- **No `ResidentLink` precondition** — the first credential independent of `ResidentLink` since passport, and for a related reason: employment at a Japanese-registered company isn't inherently tied to Japanese residency (remote workers, overseas-branch local hires). This is a deliberate departure from diploma, license, and health insurance, all of which are run by Japan-specific institutions for Japan-based individuals.

## Consequences

- This is the first credential whose issuer is "any corporation" rather than a specific authority type or category — establishing that the credentials pattern generalizes cleanly to arbitrary corporate issuers, not just government bodies or specially-regulated institutions.
- This is the first credential since passport to have no `ResidentLink` dependency, confirming that the dependency is a per-credential judgment call tied to whether the underlying real-world institution is Japan-residency-specific, not a default to apply everywhere.
- Sole proprietors remain unable to issue any employment-like credential under this design — if ever needed, a separate mechanism (e.g. letting a sole proprietor issue from their own `ResidentLink` address) would need its own design discussion; not raised as a priority by the user.
- With five concrete credential types now designed (passport, diploma, license, health insurance, employee ID), only vaccination remains from the originally-listed examples.

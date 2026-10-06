# 0008. License credential: single possession-only contract, suspension and revocation both burn

**Date:** 2026-10-06
**Status:** Accepted

## Context

Following diploma (ADR 0007), the third concrete instance of the general "credentials" pattern designed was the driver's license (運転免許証), issued by a prefectural 公安委員会. Discussion (see [`docs/state-design/credentials/license/discussion-log.md`](../state-design/credentials/license/discussion-log.md)) worked through trust-anchor (reusing `.lg.jp`, already established for prefectures), granularity, how to represent the real-world distinction between temporary suspension (停止) and permanent revocation (取消), renewal, and whether a `ResidentLink` precondition applies as it does for diploma.

Claude initially proposed one contract per vehicle class (mirroring diploma's per-faculty/degree granularity). The user revised this: a single physical license already manages multiple classes/conditions on one card today, so the on-chain credential should mirror that — a single contract proving only "holds an active license," with class/condition detail left entirely off-chain.

## Decision

- **Single contract per prefecture — no granularity by vehicle class or condition.** Unlike diploma's per-faculty/degree contracts, a `License` NFT proves only "the holder has an active driver's license," not which classes (普通, 中型, 大型, 二輪, etc.) or conditions (AT限定, 眼鏡等, etc.) — those stay entirely in 公安委員会's own off-chain records.
- **Trust-anchor: `.lg.jp`**, since 公安委員会 is a prefectural body — no new mechanism, reusing what taxation (ADR 0004) already established for prefectures.
- **Suspension (停止) and revocation (取消) are both represented identically on-chain as a burn.** No on-chain status field distinguishes "temporarily suspended, will resume automatically" from "permanently revoked, requires a fresh application" — that real-world legal distinction, and the conditions under which re-issuance is possible, stay off-chain, consistent with this project's established practice of keeping revocation *reasons* off-chain (citizenship, corporations, passport, diploma all do this).
- **Renewal is modeled as burn-and-reissue**, same as passport — no on-chain expiry date.
- **Minting requires the recipient to hold a valid `ResidentLink` NFT**, checked on-chain at mint time only via an applicant-declared contract — the same pattern established for diploma (ADR 0007), with no nationality distinction.
- **Authority-only mint/burn — no self-burn**, same as every other credential designed so far.
- No per-token data beyond standard ERC-721 ownership, per the credentials-wide rule.

## Consequences

- This is the first credential where the user explicitly chose *less* on-chain granularity than Claude proposed, on the grounds that the real-world document already aggregates multiple facts onto one card — establishing that "mirror the real-world document's own level of aggregation" is itself a valid, user-directed granularity heuristic, not just "split wherever a natural static distinction exists" (diploma's heuristic). Future credential types should consider both heuristics and ask rather than assume.
- This is also the first credential with a real suspension/revocation distinction; resolving it as "both are burn, real-world meaning stays off-chain" sets a reusable precedent for any future credential with a similar temporary-vs-permanent inactive state (e.g., a professional license with a disciplinary suspension).
- Professional licenses (医師免許, 建築士, etc.) remain undesigned — they have a more varied set of issuing bodies (ministries, self-regulatory bodies with delegated authority) and would need their own issuer-trust analysis if taken up later.

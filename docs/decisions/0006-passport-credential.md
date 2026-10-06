# 0006. Passport credential: pure travel document, nationality verified off-chain

**Date:** 2026-10-06
**Status:** Accepted

## Context

Following citizenship (ADR 0003), taxation (ADR 0004), and corporations (ADR 0005), the fourth state function designed was the first concrete instance of the general "credentials" pattern (diplomas, licenses, employee IDs, health/vaccination certificates, etc.): the passport. This also cleared a dependency deferred since the citizenship design — `ResidentLink` deliberately makes no nationality claim, so anything needing nationality specifically (a passport being the clearest example) needed its own credential.

Initial discussion considered splitting this into two credentials — a persistent **Nationality** credential (issued by 法務省) and a renewable **Passport** credential depending on it (issued by 外務省) — reasoning that nationality and passport validity have different lifecycles. Mid-discussion, the user clarified the actual intent: the national/foreign-resident distinction is understood to already exist in the *existing off-chain administrative data* municipalities and related national systems manage (analogous to 住基ネット) — the same off-chain information already relied on when verifying identity before minting `ResidentLink`. The user wants to build on that existing off-chain management rather than create a new on-chain credential for nationality, and wants passport designed purely as a travel document. See [`docs/state-design/credentials/passport/discussion-log.md`](../state-design/credentials/passport/discussion-log.md) for the full back-and-forth, including the scope correction.

## Decision

- **Only a `Passport` credential is designed — no on-chain `Nationality` credential is built.** 外務省 verifies an applicant's nationality entirely off-chain, using existing real-world administrative processes (戸籍 documents, etc.), the same pattern as how a municipality verifies identity off-chain before minting `ResidentLink`.
- **The NFT carries zero on-chain fields beyond standard ERC-721 ownership** — consistent with the credentials-wide rule (established in the general credentials discussion) that these NFTs prove possession only.
- **Soulbound / non-transferable**, same as every other identity-linked NFT in this project.
- **Authority-only mint/burn — no self-burn.** The self-initiated-renunciation exception considered for a hypothetical on-chain nationality credential (mirroring the real 国籍法 Art. 13 right) does not apply here, since nationality has no on-chain representation in this design. A passport is a controlled travel document, not a personal-rights status, so it reverts to the citizenship default.
- **Renewal is modeled as burn-and-reissue**, not an on-chain expiry field — "holds a `Passport` NFT" means "administratively valid as of 外務省's last mint/burn action," not a continuously-tracked date.
- **No dependency on `ResidentLink`.** A Japanese national living abroad has no 住所地 registration (and so no `ResidentLink`) but can still hold a passport — nationality and residency are decoupled (already noted in ADR 0003). No cross-contract check between `Passport` and `ResidentLink`.
- **Trust-anchor reuses the existing `.go.jp` mechanism** — no new design needed, since 外務省 is a national government body like 国税庁 and 法務省.
- **Whether nationality (or a residence-status/在留カード equivalent for foreign residents) should ever be represented on-chain is explicitly deferred**, to a future "foreign residents" design topic — tracked in [`docs/BACKLOG.md`](../BACKLOG.md).

## Consequences

- This is the first validated instance of the general "credentials" pattern (possession-only NFT, authority-issued, `.go.jp`/`.lg.jp`-style attestation, burn-and-reissue for renewal) — the remaining credential types (diploma, license, employee ID, health-insurance, vaccination) can now be designed by applying this same validated template, tuned per type.
- Any future feature needing nationality specifically (voting eligibility is the clearest anticipated case) cannot reuse `Passport` as a proxy for nationality, since passport validity and nationality have different lifecycles (someone can be a national without a currently-valid passport). That future feature will need to address nationality verification on its own terms — likely by finally deciding whether to build the deferred on-chain nationality/residence-status credential.
- The "credentials" feature as a whole remains 🟡 in progress — only passport is resolved; the other listed credential types (diploma, license, employee ID, health-insurance, vaccination) are still 🔴 not started, to be designed one at a time per the established process.

# 0007. Diploma credential: reuses corporate registration, requires ResidentLink

**Date:** 2026-10-06
**Status:** Accepted

## Context

Following passport (ADR 0006), the second concrete instance of the general "credentials" pattern designed was the diploma/graduation certificate. Discussion (see [`docs/state-design/credentials/diploma/discussion-log.md`](../state-design/credentials/diploma/discussion-log.md)) worked through: whether schools need a new trust-anchor mechanism or can reuse the existing corporations registration, how fine-grained to make contract-per-sub-type, lifecycle (simpler than any prior credential), and — the most substantive point — whether holding a diploma should require the recipient to hold a `ResidentLink` NFT.

The user initially proposed requiring `ResidentLink` to prevent non-Japanese-nationals from "graduating from a Japanese school." This conflated residency with nationality: `ResidentLink` is deliberately nationality-neutral (ADR 0003), so the requirement doesn't actually restrict to nationals — it restricts to registered residents of any nationality. This was surfaced and the user accepted the resulting, more coherent design: require `ResidentLink` (any nationality), with no special handling needed for foreign students as a direct consequence.

## Decision

- **Schools register via the existing [corporations](0005-corporate-registration-model.md) pattern** — 国立大学法人, public schools, and private 学校法人 are simply another category of specially-regulated corporation (supervised by 文部科学省 and/or a prefectural board of education). `Diploma` NFTs are issued from that same registered address; no new `.ac.jp`/`.ed.jp`-based trust mechanism is introduced (though both are real, available Japanese TLDs if ever needed later).
- **Granularity: one contract per faculty/degree-level.** Graduation year is **not** given its own contract — it's recoverable from the mint event's block timestamp, consistent with the data-minimization reasoning already established for citizenship (ADR 0003, Issue 5).
- **Lifecycle is mint-once, no updates, no renewal** — the simplest of any credential designed so far. Burn is authority-only, reserved for rare degree revocation, with no on-chain reason code (same minimization principle as citizenship/corporations). No self-burn.
- **Minting requires the recipient to hold a valid `ResidentLink` NFT**, checked on-chain via a cross-contract call to a `ResidentLink` contract the applicant themselves declares (mirroring citizenship's Issue 6 deduplication-check pattern) — **at mint time only**, not an ongoing requirement; a diploma already issued is unaffected by the holder's `ResidentLink` later being burned.
- **No special-casing for foreign residents.** Since `ResidentLink` makes no nationality distinction, a registered foreign resident qualifies identically to a Japanese national resident. Graduates who were never registered Japan residents (e.g. fully remote overseas distance-learning students) are out of scope for this on-chain credential and continue to rely on a traditional paper diploma.

## Consequences

- This is the second validated instance of the general "credentials" pattern, and the first to depend on another credential (`ResidentLink`) as a mint precondition — establishing a reusable cross-contract-check pattern (declared-contract + `balanceOf`) that later credential types can reuse when they need a similar dependency.
- A visible scope boundary now exists for this credential: Japan-resident graduates (any nationality) are covered on-chain; non-resident graduates are not, and this is a deliberate, documented limitation rather than an oversight.
- The remaining credential types (license, employee ID, health-insurance, vaccination) can now draw on two validated templates: `Passport`'s "pure government-issued document, no dependencies" shape, and `Diploma`'s "issuer reuses corporate registration, requires `ResidentLink`" shape — each new type should state explicitly which shape (or what hybrid) fits it, rather than assuming one by default.

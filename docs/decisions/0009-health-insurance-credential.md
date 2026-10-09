# 0009. Health insurance credential: continuous status, multi-issuer-type trust reuse

**Date:** 2026-10-09
**Status:** Accepted

## Context

Following license (ADR 0008), the fourth concrete instance of the general "credentials" pattern designed was the public health insurance card (健康保険証). Japan's public health insurance system has an unusually wide variety of insurer types — municipalities, prefectural 広域連合 (for elderly care), and several categories of specially-regulated corporation (協会けんぽ, 組合健保, 共済組合). Discussion (see [`docs/state-design/credentials/health-insurance/discussion-log.md`](../state-design/credentials/health-insurance/discussion-log.md)) worked through whether this needs any new trust mechanism, granularity, lifecycle, the `ResidentLink` precondition, and dependent handling — resolving all five issues, plus a scope clarification, in two rounds with no disagreement.

## Decision

- **Scope: public health insurance only, distinct from private insurance.** This credential covers enrollment in 国民健康保険, 後期高齢者医療制度, 協会けんぽ, 組合健保, and 共済組合. *Private* commercial insurance (life, earthquake, etc.) remains a separate, deferred item in [`docs/BACKLOG.md`](../BACKLOG.md) under the "financial infrastructure" theme, for tax-deduction-computation purposes.
- **No new trust-anchor mechanism needed.** Every insurer type maps onto something already established: municipalities and prefectural 広域連合 via `.lg.jp` (the same mechanism as `ResidentLink`); 協会けんぽ, 組合健保, and 共済組合 via the [corporations](0005-corporate-registration-model.md) pattern, registering as a specially-regulated corporation supervised by the relevant ministry (the same treatment diploma gave 国立大学法人).
- **One contract per insurer, no further granularity** — mirroring license's resolution (ADR 0008), not diploma's: a person is enrolled in exactly one scheme at a time, so the NFT proves only "currently enrolled," with no plan/coverage detail.
- **Lifecycle is continuous, not periodically renewed** — a departure from passport/license. Enrollment doesn't expire on a schedule; it changes when circumstances change (job change, aging into 後期高齢者医療制度, death). Mint on enrollment, burn on disenrollment (reason kept off-chain), no self-burn, no renewal cycle — the same shape as citizenship's municipality-move pattern rather than passport/license's burn-and-reissue.
- **Minting requires the recipient to hold a valid `ResidentLink` NFT**, checked on-chain at mint time via an applicant-declared contract — the same pattern as diploma and license, no nationality distinction.
- **No special handling for dependents (扶養家族).** A dependent is simply another enrolled person, receiving their own NFT from the same insurer's contract, provided they hold their own `ResidentLink`. No on-chain distinction between primary insured and dependent.

## Consequences

- This is the first credential whose issuer category spans *both* of the two trust-anchor templates established so far (government-domain-anchored, per citizenship/taxation; corporate-registration-reuse, per diploma) within a single credential type — different insurers use different templates depending on their own institutional nature. Future credential types with similarly varied issuers (e.g., a hypothetical cross-sector credential) should expect to do the same per-issuer-type mapping rather than assume one uniform mechanism.
- This is the first credential with a continuous (non-expiring) lifecycle rather than periodic renewal — establishing that credential lifecycle shape depends on the real-world document's own nature (a license/passport expires; enrollment doesn't), not a one-size-fits-all rule.
- All five issues and the scope clarification were resolved by the user in a single confirming message with no pushback — the fastest resolution of any credential designed so far, suggesting the established patterns (trust-anchor reuse, `ResidentLink` precondition, off-chain reason codes) are now well-understood defaults that mostly need confirming rather than debating.

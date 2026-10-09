# 0011. Vaccination credential: stateful coupon, three-party authorization

**Date:** 2026-10-10
**Status:** Accepted

## Context

Following employee ID (ADR 0010), the sixth and final originally-listed concrete instance of the general "credentials" pattern designed was the vaccination certificate (接種証明). The initial framing (proposed by Claude) modeled it as a retroactive, possession-only proof of a completed dose, consistent with every other credential's zero-on-chain-fields rule. The user corrected this mid-discussion: the real intended workflow is a **vaccination coupon (接種券)** issued by a municipality *before* vaccination, which a **hospital** — not the municipality — marks as used once the dose is administered. See [`docs/state-design/credentials/vaccination/discussion-log.md`](../state-design/credentials/vaccination/discussion-log.md) for the full reasoning, including this correction.

This forced two genuine departures from every prior identity-style credential (citizenship, passport, diploma, license, health insurance, employee ID): (1) real on-chain mutable state is needed (a two-stage status), and (2) a party other than the issuer needs authorized write access to a token.

## Decision

- **Contract: `VaccinationCoupon`, one per (municipality × vaccine type)** — issued under the same `.lg.jp` trust-anchor as `ResidentLink`, no new mechanism. Granularity follows diploma's fine-grained reasoning (which vaccine matters), not license/health-insurance's aggregation.
- **A status field is introduced as a deliberate, justified exception to the credentials-wide zero-fields rule**: `enum Status { Issued, Vaccinated }` — the second credential (after corporations) to carry real per-token state, because a two-stage coupon→completion lifecycle cannot otherwise be represented.
- **Three-party authorization model**: the municipality (issuer) mints coupons and may burn unused ones; a **hospital**, granted `VACCINATOR_ROLE` by the municipality, flips a coupon's status from `Issued` to `Vaccinated`. This is the first credential where someone other than the issuing authority has write access to an issued token.
- **Granting `VACCINATOR_ROLE` requires an on-chain precondition**: the candidate hospital address must currently hold a valid corporate registration NFT (as a specially-regulated 医療法人, per [corporations](0005-corporate-registration-model.md)), checked via a cross-contract call — the same general pattern as `ResidentLink` checks elsewhere. The hospital's actual legitimacy and medical licensing, beyond being a registered corporation, remains the municipality's off-chain due diligence.
- **`Vaccinated` is permanent — never burned.** Burn is authority-only and applies **only** to unused (`Issued`) coupons (e.g., expiry, program cancellation, cleanup).
- **Multiple doses are multiple separate coupons**: each dose (primary series, booster, etc.) is minted fresh and independently cycles through `Issued` → `Vaccinated`. No dedicated dose-count field — dose history is derivable by enumerating a holder's tokens and their statuses.
- **Soulbound / non-transferable**, explicitly motivated by preventing resale/scalping of vaccination coupons, not merely for consistency with other credentials.
- **`ResidentLink` precondition, resolved specifically for this credential's structure**: since the issuing municipality is, by definition, the recipient's own municipality (unlike diploma/license/health-insurance, where the issuing authority isn't necessarily tied to the person's specific municipality), the contract references its own deploying municipality's `ResidentLink` contract directly — no applicant-declared parameter needed.
- **No on-chain medical-sequencing logic** (dose ordering, intervals, eligibility) — the vaccinating municipality's real-world clinical responsibility, same as license not enforcing the real-world driving test.

## Consequences

- This is the first credential requiring a genuine multi-role permission structure (issuer role + a separately-grantable updater role), establishing a reusable pattern — "authority A grants a role to party B, conditioned on B holding some other already-designed credential" — that future features needing similar delegated-update workflows can reuse.
- Corporations (ADR 0005) and now vaccination are the only two credential-like designs with real on-chain mutable state; every other credential remains a pure possession proof. This confirms that the zero-fields default is a strong preference, not an absolute rule, overridden only when the underlying real-world object has a genuine multi-stage lifecycle a third party must attest to.
- This completes the originally-listed set of six credential examples (passport, diploma, license, health-insurance, employee ID, vaccination). Any further credential types are new scope, not part of the original list.

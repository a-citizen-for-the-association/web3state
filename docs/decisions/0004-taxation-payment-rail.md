# 0004. Taxation payment rail: direct, resident-initiated payments only, no dedicated contract

**Date:** 2026-10-03
**Status:** Accepted

## Context

Following the citizenship/residency design (ADR 0003), the next state function designed was taxation. The initial proposal: residents receive income in a JPY-pegged stablecoin, and pay taxes by sending from their `ResidentLink` address to an appropriate tax-receiving address, with tax calculation and correctness verification explicitly out of scope.

Discussion (see [`docs/state-design/taxation/discussion-log.md`](../state-design/taxation/discussion-log.md)) worked through: whether reusing the identity-linked `ResidentLink` address for payment is an acceptable privacy trade-off, the scope of "tax" (individual vs. corporate, direct-pay vs. source-withheld), how a receiving address's authenticity is established, which stablecoin is assumed, whether a dedicated smart contract is needed, and how the mechanism generalizes beyond municipal taxes to prefectural and national ones.

## Decision

- **Scope:** taxes an individual (natural person) pays directly, by their own initiative — e.g. 住民税, 固定資産税, 自動車税, 所得税 (self-assessed), 相続税, 贈与税. Corporate taxes are out of scope (separate future feature). Tax amount calculation, correctness verification, refunds, and late-payment handling are explicitly out of scope — determined and reconciled off-chain via existing real-world processes, unchanged by this project.
- **Source-withheld taxes (employer withholding) are explicitly not modeled on-chain**, now or later. The project's position is that withholding should eventually be *eliminated* — once financial-product (insurance/loan) tokenization makes deduction data chain-derivable and a legal-reform assumption removes the employer's withholding obligation — rather than replicated as an on-chain "employer remittance" mechanism. Until that precondition is met, withheld income stays entirely outside this project, handled off-chain as today.
- **Payment is made from the same `ResidentLink` address used for residency proof.** This is a deliberate privacy trade-off, not an oversight: the user explicitly accepted that a resident's approximate income/payment history becomes publicly observable on-chain, since it doesn't identify the real person. This also gives a free benefit: the sending address itself serves as the payer's reference (an on-chain equivalent of a real-world 納付書 reference number).
- **Receiving-address authenticity reuses and generalizes the citizenship design's mechanism**: municipalities and prefectures (both 地方公共団体) publish under `.lg.jp`; national bodies (e.g. 国税庁) would publish under `.go.jp`, using the same principle at a different root domain. A single authority handling multiple tax types publishes one receiving address per tax type (extending the same well-known JSON schema), so the destination address itself signals which tax a payment is for.
- **No on-chain allowlist of accepted tokens.** Any address can technically receive any token; whether a received token is a legitimate stablecoin is verified off-chain during the authority's existing reconciliation process, the same way amount-correctness already is.
- **No dedicated smart contract for this feature.** Given the scope above, the entire mechanism reduces to: an authority publishes a verified receiving address, and a taxpayer calls the stablecoin's standard `transfer()`.
- **Stablecoin assumption:** existing, externally-issued JPY-pegged stablecoins (e.g. JPYC, JPYSC) — this project does not issue its own currency, since that would amount to a CBDC, which is explicitly not wanted.
- Current-law feasibility (e.g., whether a private stablecoin legally discharges a tax obligation) is explicitly **not** a design concern for this project — standing guidance (not feature-specific), since the project is a thought experiment with no goal of pursuing real-world legal adoption.

## Consequences

- This feature ships with no new Solidity — only a documented convention (receiving-address publication format) that extends the citizenship design's attestation mechanism.
- A real privacy exposure is accepted: anyone can observe a `ResidentLink`-holding address's approximate income and tax-payment history. This is consistent with the user's explicit risk tolerance for this project, not an oversight to revisit without being asked.
- Financial-product tokenization (insurance, loans) and the resulting ability to eliminate employer withholding are deferred, tracked in [`docs/BACKLOG.md`](../BACKLOG.md) under a "financial infrastructure" theme, to be tackled after the overall state design reaches a stable shape — not as part of this feature.
- A new, not-yet-designed dependency is noted for that future work: private regulated financial institutions (banks, insurers) will need their own official-issuer attestation mechanism, since neither `.lg.jp` nor `.go.jp` applies to them (likely anchored to a regulator such as 金融庁).
- The `.go.jp`-anchored attestation for national tax authorities is a resolved *principle*, not yet an implemented one — tracked in `docs/BACKLOG.md` as an implementation-time task.

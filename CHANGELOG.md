# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
This project does not yet follow a release/version numbering scheme (no releases have been made); entries are grouped by date until the first tagged release.

For *why* a change was made (not just *what* changed), see [`docs/decisions/`](docs/decisions/).

## [Unreleased]

### Added
- Initial repository scaffold: directory structure, README, documentation structure (`docs/`), contracts placeholder (Foundry), frontend placeholder (Next.js).
- `docs/decisions/0001-record-architecture-decisions.md` and `0002-initial-stack-and-structure.md`.
- MIT License.
- `docs/FEATURES.md`: at-a-glance progress table across all planned state functions.
- `docs/state-design/citizenship/`: completed design spec for the citizenship/residency (国民・住民) feature — a municipality-issued, soulbound, nationality-neutral "resident-link" NFT. Full reasoning in `discussion-log.md`.
- `docs/decisions/0003-resident-link-identity-model.md`: ADR for the citizenship/residency identity model.
- Japanese translation added to `docs/state-design/citizenship/README.md`.
- `docs/state-design/taxation/`: completed design spec for the taxation payment-rail feature (納税) — individual direct tax payments only, no dedicated smart contract, extends the citizenship design's official-address attestation mechanism. Full reasoning in `discussion-log.md`.
- `docs/decisions/0004-taxation-payment-rail.md`: ADR for the taxation payment-rail decisions.
- `docs/BACKLOG.md`: cross-feature list of deferred items (financial-product tokenization, employer-withholding abolition, national-level `.go.jp` attestation implementation, and others).
- `docs/state-design/corporations/`: completed design spec for the corporate registration feature (法人) — authority-issued, soulbound, on-chain registration NFT(s); officer/representative names public on-chain, addresses never on-chain; corporation's own address is a multisig contract signed with officers' personal keys. Full reasoning in `discussion-log.md`.
- `docs/decisions/0005-corporate-registration-model.md`: ADR for the corporate registration model.
- `docs/state-design/credentials/`: opened the general "credentials" feature (diplomas, passports, licenses, employee IDs, health-insurance and vaccination certificates, etc.) — cross-cutting rules agreed: NFTs prove possession only (no on-chain fields), trust-anchor and sub-type granularity decided per credential type. Full reasoning in `discussion-log.md`.
- `docs/state-design/credentials/passport/`: completed design spec for the passport credential — a pure travel-document NFT issued by 外務省; no on-chain nationality credential was built (nationality verified entirely off-chain, same pattern as `ResidentLink`'s identity check). Full reasoning in `discussion-log.md`.
- `docs/decisions/0006-passport-credential.md`: ADR for the passport credential decisions.
- `docs/state-design/credentials/diploma/`: completed design spec for the diploma/graduation-certificate credential — issued from a school's existing corporate-registration address (schools treated as a specially-regulated corporation category, no new `.ac.jp`/`.ed.jp` mechanism); requires the recipient to hold a `ResidentLink` NFT at mint time (one-time, on-chain, nationality-neutral check); simplest lifecycle so far (mint-once, rare-burn only). Full reasoning in `discussion-log.md`.
- `docs/decisions/0007-diploma-credential.md`: ADR for the diploma credential decisions.
- `docs/state-design/credentials/license/`: completed design spec for the driver's-license credential — a single contract per prefecture (no per-vehicle-class split, unlike diploma); suspension and revocation both represented identically on-chain as burn, with the real-world distinction kept off-chain; requires the recipient to hold a `ResidentLink` NFT at mint time, same pattern as diploma. Full reasoning in `discussion-log.md`.
- `docs/decisions/0008-license-credential.md`: ADR for the license credential decisions.
- `docs/state-design/credentials/health-insurance/`: completed design spec for the public health-insurance credential — one contract per insurer; every insurer type (municipality, prefectural 広域連合, 協会けんぽ, 組合健保, 共済組合) maps onto an already-established trust mechanism; continuous (non-expiring) lifecycle unlike passport/license; requires `ResidentLink` at mint; no special handling for dependents. Full reasoning in `discussion-log.md`.
- `docs/decisions/0009-health-insurance-credential.md`: ADR for the health-insurance credential decisions.
- `docs/state-design/credentials/employee-id/`: completed design spec for the employee ID credential — issued from any registered corporation's existing corporate-registration address (sole proprietors cannot issue it); one contract per company; continuous lifecycle like health insurance; no `ResidentLink` precondition (the first since passport, since employment isn't inherently tied to Japanese residency). Full reasoning in `discussion-log.md`.
- `docs/decisions/0010-employee-id-credential.md`: ADR for the employee ID credential decisions.
- `docs/state-design/credentials/vaccination/`: completed design spec for the vaccination credential — a municipality-issued, soulbound vaccination coupon with a genuine on-chain status field (`Issued`/`Vaccinated`), the second credential (after corporations) needing real mutable state; a hospital holding a `VACCINATOR_ROLE` (granted only to addresses holding a valid corporate/医療法人 registration, checked on-chain) marks coupons vaccinated, not the issuing municipality; multiple doses are multiple separate coupons; `Vaccinated` coupons are never burned. Completes the originally-listed set of six credential examples. Full reasoning in `discussion-log.md`.
- `docs/decisions/0011-vaccination-credential.md`: ADR for the vaccination credential decisions.
- `docs/decisions/0012-onchain-scope-philosophy.md`: ADR recording the project's broader on-chain scope philosophy — ~20 new candidate systems across 8 categories (political transparency, social welfare, public-interest finance, property/vital records, corporate/market transparency, judicial infrastructure, commerce/markets, governance core), everyday commerce in-scope for tax transparency, wealth-focused financial services carved out to provider-handled compliance, and high-frequency trading / personal wealth-accumulation investment explicitly excluded (not silently omitted).
- Root `README.md`: added a prominent "System Roadmap" table (English + Japanese) embedding a condensed copy of `docs/FEATURES.md` directly in the README, per the user's request for maximum visibility — not merely linked.
- `docs/state-design/legislative/` and `docs/decisions/0014-legislative-process-scope.md`: scoped the legislative process out (🚫), carving out direct-demand petition signatures as their own item; adopted the reusable on-chain value test.
- `docs/state-design/political-donations/` and `docs/decisions/0015-political-donations-model.md`: completed design spec for political donations — receiving-side `PoliticalFund` contracts, traceable donors without on-chain names, and a 総務省-operated `OfficialContractRegistry`.
- `docs/state-design/direct-demand/` and `docs/decisions/0016-direct-demand-petition-model.md`: completed design spec for direct-demand petition signatures — one `Petition` contract per demand, explicit per-petition eligible list, full-text hash, fixed threshold, public self-signed signatures with no collectors, count certification only.
- `docs/state-design/executive/` and `docs/decisions/0017-executive-document-anchoring-v1.md`: executive screened with the on-chain value test; minimal v1 spec — mandatory title-and-hash registration of approval documents in a per-agency append-only `DocumentRegistry`. Also records the workflow change to design → implement → scenario test → redesign.
- `docs/state-design/judiciary/` and `docs/decisions/0018-judiciary-model.md`: judiciary spec — `EvidenceRegistry` (evidence registered at seizure), `CaseRecordRegistry` (retention classes, guarded disposal, judgments), enforcement by court-ordered address disclosure; token-juror arbitration excluded.
- `docs/state-design/treasury/` and `docs/decisions/0019-treasury-model.md`: treasury spec — per-body `PublicTreasury`, identified payees, budget codes as tags, public `OffChainExit`; adopts the "off-chain if it can be" principle.
- `docs/state-design/certified-stablecoin/` and `docs/decisions/0020-certified-address-stablecoin.md`: project-wide certified-address JPY stablecoin rule, successor migration, visitor pass.
- `docs/state-design/vip-asset-disclosure/` and `docs/decisions/0021-vip-asset-disclosure.md`: VIP asset disclosure without a new contract.

### Changed
- `docs/PROJECT_STATUS.md`: recorded the explicit workflow decision that implementation (`contracts/` Foundry init, Solidity) is deferred until all initially-planned state functions are designed and reviewed together for cross-feature consistency — not started per-feature as each design finishes.
- `docs/FEATURES.md`: removed the stale "Municipality registry" row (decided against in ADR 0003; tracked in `docs/BACKLOG.md` instead).
- `docs/BACKLOG.md`: closed the original "nationality/passport credential" row (passport now designed); added a new row for whether nationality/residence-status should ever be managed on-chain, deferred to a future "foreign residents" topic.
- `docs/PROJECT_STATUS.md`: removed the "paused / resume point" section (resolved) and updated to reflect the passport credential's completion.
- `docs/PROJECT_STATUS.md`: added, then removed (resolved), a "paused / resume point" section covering the gap between the license and health-insurance credentials.
- `docs/FEATURES.md`: restructured with a new `Category` column and a new `🚫 Deliberately excluded` status; added ~20 new 🔴 candidate rows from the scope-expansion discussion; removed a stale duplicate "Vaccination credential — Not started" row left over from before vaccination was designed.
- `docs/FEATURES.md`, root `README.md`: Voting status updated from 🟡 Discussing to 🟢 Spec drafted now that all six design issues are resolved.
- `docs/PROJECT_STATUS.md`: updated to reflect voting's completion (ten state functions now fully specified) and removed voting-specific next-step language now that it's done.
- `docs/state-design/voting/discussion-log.md`, `README.md`, `docs/FEATURES.md`, `docs/PROJECT_STATUS.md`: resolved voting's foundational privacy/anonymity question (Issue 1) — vote content protected by a Helios-style scheme (homomorphic encryption + zero-knowledge proof of correct tally + threshold decryption across multiple trustees); vote participation uses the resident's existing `ResidentLink` address rather than a fresh per-election address, to avoid creating a new off-chain identity↔disposable-address mapping at the municipality. Full reasoning in `discussion-log.md` Round 2.
- `docs/state-design/voting/`: completed the full design spec for voting — one generic election primitive (closed option list + one-hot encrypted ballots + homomorphic per-option summation + threshold decryption of only the final totals + a pluggable seat-allocation method) covering referendums, single-seat plurality, multi-seat single-non-transferable-vote elections, and party-list proportional representation (both binding and non-binding list variants); ranked-choice/single-transferable-vote and write-in candidates explicitly excluded. Voter eligibility verified off-chain by the election board plus an on-chain `ResidentLink` check; voting period is a deliberate exception to this project's general avoidance of on-chain dates. Full reasoning in `discussion-log.md` Round 3.
- `docs/decisions/0013-voting-model.md`: ADR for the voting design decisions.
- `docs/glossary.md`: added "Voting / Election" and "Threshold decryption" entries.
- `docs/BACKLOG.md`: added two voting-related deferred items — selecting the concrete audited cryptographic library/implementation and commissioning its security audit, and reducing the operational cost of per-voter eligibility grants at national-election scale.
- `docs/FEATURES.md`, root `README.md`: legislative process moved to 🚫 Excluded; new 🔴 row for direct-demand petition signatures; political donations set to 🟢 Spec drafted.
- `docs/decisions/0003`, `0014`: status lines annotated (registry point revisited / roll-call bullet superseded by ADR 0015).
- `docs/BACKLOG.md`: closed the on-chain municipality registry item (now `OfficialContractRegistry`); added disposition of a political organization's funds on dissolution.
- `docs/glossary.md`: added on-chain value test, political fund, and official contract registry.
- `docs/PROJECT_STATUS.md`: updated for ADR 0014/0015 and added a "paused / resume point" section before choosing the next system.
- `docs/FEATURES.md`, root `README.md`: direct-demand petition signatures set to 🟢 Spec drafted.
- `docs/glossary.md`: added direct demand. `docs/BACKLOG.md`: the large-list cost item now also covers petitions. `docs/state-design/legislative/README.md`: petition open items marked resolved.
- `docs/PROJECT_STATUS.md`: removed the paused/resume section; updated for ADR 0016; next steps set to executive, then judiciary (Governance Core top-down).
- `docs/FEATURES.md`, root `README.md`: executive set to 🟢 Spec drafted (minimal v1). `docs/BACKLOG.md`: added five executive items deferred to the redesign phase. `docs/PROJECT_STATUS.md`: workflow change recorded (the initial design still covers every listed item, corrected the same day); next step is judiciary.
- `docs/FEATURES.md`, root `README.md`: judiciary 🟢; public court records merged into judiciary (🟢); new 🚫 row for token-juror arbitration; everyday-commerce note on purchase escrow. `docs/BACKLOG.md`: case-record content preservation. `docs/PROJECT_STATUS.md`: Governance Core complete.
- `docs/PROJECT_STATUS.md`: added a "paused / resume point" section after the judiciary (confirm judiciary adjustments, then show the remaining list and let the user choose).
- `docs/state-design/judiciary/discussion-log.md`: Round 4 — user confirmed the four spec adjustments. `docs/PROJECT_STATUS.md`: resume point updated accordingly.
- `docs/FEATURES.md`, root `README.md`: treasury 🟢. `docs/glossary.md`: added public treasury. `docs/PROJECT_STATUS.md`: removed the resume point; recorded ADR 0019 and its principle.
- `docs/state-design/treasury/discussion-log.md`: Round 4 — user confirmed the spec adjustments. `docs/PROJECT_STATUS.md`: added a "paused / resume point" section after the treasury.
- `docs/FEATURES.md`, root `README.md`: new 🟢 row for the certified-address stablecoin; VIP asset disclosure 🟢. `docs/decisions/0004`, `0018`: status lines annotated for ADR 0020. `docs/glossary.md`: certified address, successor migration. `docs/BACKLOG.md`: three items from ADR 0020.

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

### Changed
- `docs/PROJECT_STATUS.md`: recorded the explicit workflow decision that implementation (`contracts/` Foundry init, Solidity) is deferred until all initially-planned state functions are designed and reviewed together for cross-feature consistency — not started per-feature as each design finishes.
- `docs/FEATURES.md`: removed the stale "Municipality registry" row (decided against in ADR 0003; tracked in `docs/BACKLOG.md` instead).
- `docs/BACKLOG.md`: closed the original "nationality/passport credential" row (passport now designed); added a new row for whether nationality/residence-status should ever be managed on-chain, deferred to a future "foreign residents" topic.
- `docs/PROJECT_STATUS.md`: removed the "paused / resume point" section (resolved) and updated to reflect the passport credential's completion.

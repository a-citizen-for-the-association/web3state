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

### Changed
- `docs/PROJECT_STATUS.md`: recorded the explicit workflow decision that implementation (`contracts/` Foundry init, Solidity) is deferred until all initially-planned state functions are designed and reviewed together for cross-feature consistency — not started per-feature as each design finishes.
- `docs/FEATURES.md`: removed the stale "Municipality registry" row (decided against in ADR 0003; tracked in `docs/BACKLOG.md` instead).

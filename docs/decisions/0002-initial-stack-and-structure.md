# 0002. Initial stack and repository structure

**Date:** 2026-10-03
**Status:** Accepted

## Context

The project needs to begin from a concrete scaffold before feature design can be discussed productively. Several choices had to be made up front: how to lay out the repository, which smart contract tooling to use, which chains to target during testing vs. mainnet, which documentation language to use, and what license to apply.

Key constraints:
- The application is composed of on-chain smart contracts plus a web frontend.
- Two chains are candidates for the system: Ethereum and Polkadot Hub. Both are EVM-compatible (Polkadot Hub supports Solidity contracts via PolkaVM / `pallet-revive`), so a single Solidity codebase can target either.
- Sepolia must be usable preferentially during testing; the mainnet chain choice is a separate, later decision.
- Frontend is Next.js, deployed on Vercel (given, not reconsidered here).
- The project is expected to become large and will have contributors joining after the fact, who may need to work offline (outside the web app and outside the chain) on some tasks.

## Decision

- **Repository layout:** a single repository with two independent, self-contained top-level directories — `contracts/` and `frontend/` — with no workspace tool (pnpm workspaces, Turborepo, etc.) linking them. Simpler to reason about; nothing today requires sharing code or build pipelines between them. Revisit if/when real duplication appears (YAGNI).
- **Smart contract tooling:** [Foundry](https://getfoundry.sh/). Actively maintained, fast, widely adopted, and lets contracts and tests both be written in Solidity.
- **Chain targeting:** both chains are EVM-compatible, so the contract codebase itself does not need to branch per chain. Network selection happens at the deploy/config layer — Foundry named RPC endpoints (`[rpc_endpoints]` in `foundry.toml`) and environment variables — not in contract code. Sepolia is configured as the default/priority network now; mainnet endpoint(s) are left as placeholders pending ADR for mainnet chain choice.
- **Documentation language:** English as the primary language, with Japanese included alongside for key documents (README, CONTRIBUTING, docs index, project status, ADRs). Rationale: this project models state/legal structures where precision matters, and English keeps it accessible to a broader open-source audience; Japanese keeps it accessible to the project's current core contributors.
- **License:** MIT — the most widely used permissive license, minimizing friction for contributors and future adopters.
- **History/state tracking convention:** three separate, non-overlapping documents — `CHANGELOG.md` (what changed, code-level), `docs/decisions/*.md` (why a significant decision was made, immutable), and `docs/PROJECT_STATUS.md` (where things stand right now, a frequently-updated snapshot).
- **Online / on-chain / offline classification:** because this project models real institutional functions, every feature is expected to document which parts run on-chain, which run in the web app (online), and which require a human to act in the physical/legal world (offline). Convention lives in `docs/operations/`.

## Consequences

- Contract code can be written once and deployed to either candidate chain by changing configuration, not code — but this has not been validated against real Polkadot Hub deployment yet; treat as an assumption to verify once contracts exist.
- Mainnet chain selection remains an open question (tracked in `docs/PROJECT_STATUS.md`) and will get its own ADR when decided.
- No CI, no workspace tooling, and no actual contract/frontend code exist yet — this ADR covers structure and tooling choices only, not feature scope.
- Because `contracts/` and `frontend/` are independent, there is currently no enforced shared TypeScript config, linting, or versioning between them; this is an accepted tradeoff for simplicity today.

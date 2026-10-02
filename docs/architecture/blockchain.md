# Blockchain Targeting

See also: [ADR 0002](../decisions/0002-initial-stack-and-structure.md).

## Candidate chains

| Chain | Role | Status |
|---|---|---|
| Ethereum (Sepolia testnet) | **Priority network for all development and testing right now.** | Active |
| Ethereum (mainnet) | Mainnet candidate | Deferred decision |
| Polkadot Hub (EVM-compatible via PolkaVM / `pallet-revive`, testnet) | Secondary candidate, to validate cross-chain portability of the contracts | Not yet validated |
| Polkadot Hub (mainnet) | Mainnet candidate | Deferred decision |

**Decision on which chain to use for mainnet is explicitly deferred** (see [`docs/PROJECT_STATUS.md`](../PROJECT_STATUS.md)). The goal for now is to keep the contract codebase chain-agnostic so that choice can be made later without a rewrite.

## How chain selection is meant to work

Both candidate chains are EVM-compatible, so in principle the **same Solidity bytecode** can be deployed to either. Chain selection should therefore live at the **configuration/deploy layer**, not in contract code:

- `contracts/foundry.toml` defines named RPC endpoints (`[rpc_endpoints]`) per network (`sepolia`, `polkadot_hub_testnet`, with mainnet entries to be added once decided). Deploy scripts pick a target via `--rpc-url <name>`, not by branching Solidity code.
- `frontend/` reads the active chain from environment variables (`NEXT_PUBLIC_DEFAULT_CHAIN` and per-chain contract addresses) rather than hardcoding a single chain.

This assumption (same bytecode, no chain-specific Solidity) has **not yet been validated** against a real Polkadot Hub deployment — treat it as a working hypothesis to confirm once contracts exist and a first testnet deployment to Polkadot Hub is attempted.

## Why Sepolia first

- Most mature tooling and documentation support (Foundry, block explorers, faucets).
- Lets contract and frontend development proceed immediately without waiting on Polkadot Hub testnet specifics.
- Validating against a second EVM-compatible chain (Polkadot Hub testnet) can happen once the first feature is stable on Sepolia, to catch any portability assumptions that don't hold.

---

# ブロックチェーン対象チェーン(日本語)

関連: [ADR 0002](../decisions/0002-initial-stack-and-structure.md)

## 候補チェーン

上記の英語版の表を参照してください。

**メインネットでどのチェーンを使うかは意図的に保留しています**([`docs/PROJECT_STATUS.md`](../PROJECT_STATUS.md) 参照)。現段階の目標は、後からの書き換えなしにその選択ができるよう、コントラクトのコードベースをチェーンに依存しない形に保つことです。

## チェーン選択の仕組み

候補となる2つのチェーンはいずれもEVM互換なので、原則として**同一のSolidityバイトコード**をどちらにもデプロイできます。したがって、チェーンの選択は**設定/デプロイ層**で行い、コントラクトのコードでは行いません。

- `contracts/foundry.toml` にネットワークごとの名前付きRPCエンドポイント(`[rpc_endpoints]`)を定義(`sepolia`, `polkadot_hub_testnet`。メインネット用は決定後に追加)。デプロイスクリプトは `--rpc-url <name>` でデプロイ先を切り替え、Solidityコードの分岐では行わない。
- `frontend/` は有効なチェーンを環境変数(`NEXT_PUBLIC_DEFAULT_CHAIN` とチェーンごとのコントラクトアドレス)から読み取る。

この前提(同一バイトコードでチェーン固有のSolidityが不要であること)は**まだ検証されていません**。コントラクトが実装され、Polkadot Hubテストネットへの最初のデプロイを試みた時点で検証すべき仮説として扱ってください。

## なぜ最初にSepoliaか

- ツール・ドキュメントのサポートが最も成熟している(Foundry、ブロックエクスプローラー、フォーセット)。
- Polkadot Hubテストネット固有の事情を待たずに、コントラクト・フロントエンド開発をすぐに進められる。
- 最初の機能がSepolia上で安定した段階で、2つ目のEVM互換チェーン(Polkadot Hubテストネット)での検証を行い、移植性の前提が崩れていないか確認する。

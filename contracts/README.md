# contracts/

Smart contracts for web3state, built with [Foundry](https://getfoundry.sh/).

> Status: provisional implementation in progress (phases 1–2 of 5 done: `src/core/`, `src/corporate/`, `src/public/`). Minimal tests only. Dependencies: OpenZeppelin Contracts v5.7.0, forge-std v1.17.0 (git submodules under `lib/`); solc 0.8.38. Clone with `git submodule update --init --recursive`. See [`docs/PROJECT_STATUS.md`](../docs/PROJECT_STATUS.md).

## Planned structure

```
contracts/
├── foundry.toml      # project + network config
├── src/              # contract source
├── test/             # Foundry (Solidity) tests
├── script/           # deployment scripts (forge script)
└── .env.example      # RPC URLs / keys template — never commit a real .env
```

## Network targeting

Both candidate chains (Ethereum, Polkadot Hub) are EVM-compatible, so the same contracts deploy to either by changing the RPC target, not the code. See [`docs/architecture/blockchain.md`](../docs/architecture/blockchain.md) for the full rationale.

`foundry.toml` defines named RPC endpoints under `[rpc_endpoints]`:

- `sepolia` — **priority network for development and testing right now.**
- `polkadot_hub_testnet` — secondary target, to validate portability once contracts exist.
- Mainnet entries are intentionally not yet defined — add them once the mainnet chain decision is made (see open question in `docs/PROJECT_STATUS.md`).

To deploy/test against a given network:

```sh
forge script script/<Script>.s.sol --rpc-url sepolia --broadcast
```

Copy `.env.example` to `.env` and fill in real values (never commit `.env`).

## Getting started (once contracts exist)

```sh
curl -L https://foundry.paradigm.xyz | bash   # install foundryup, if not already installed
foundryup
forge build
forge test
```

---

# contracts/(日本語)

[Foundry](https://getfoundry.sh/) で構築する web3state のスマートコントラクト。

> ステータス: 仮実装を進めている(5段階のうち段階1〜2が完了: `src/core/`、`src/corporate/`、`src/public/`)。テストは最低限。依存: OpenZeppelin Contracts v5.7.0、forge-std v1.17.0(`lib/`のgitサブモジュール)。solc 0.8.38。クローン後は`git submodule update --init --recursive`を実行する。[`docs/PROJECT_STATUS.md`](../docs/PROJECT_STATUS.md)を参照。

## 想定構成

上記の英語版を参照してください。

## ネットワークの切り替え

候補となる2チェーン(Ethereum、Polkadot Hub)はいずれもEVM互換のため、同一のコントラクトをRPCの切り替えのみでデプロイできます。詳細は [`docs/architecture/blockchain.md`](../docs/architecture/blockchain.md) を参照。

`foundry.toml` の `[rpc_endpoints]` に名前付きRPCエンドポイントを定義:

- `sepolia` — **現在、開発・テストで優先的に使用するネットワーク。**
- `polkadot_hub_testnet` — コントラクト実装後、移植性を検証するためのセカンダリターゲット。
- メインネット用のエントリは意図的に未定義です。メインネットのチェーンが決定次第追加します(`docs/PROJECT_STATUS.md` の未解決の論点を参照)。

特定のネットワークに対してデプロイ/テストする場合:

```sh
forge script script/<Script>.s.sol --rpc-url sepolia --broadcast
```

`.env.example` を `.env` にコピーして実際の値を設定してください(`.env` は絶対にコミットしないこと)。

## 始め方(コントラクト実装後)

```sh
curl -L https://foundry.paradigm.xyz | bash   # 未インストールの場合、foundryupをインストール
foundryup
forge build
forge test
```

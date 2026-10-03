# web3state

> 🚧 Early-stage, exploratory project. Architecture and scope are being actively discussed and will change.

An experimental project to design and build the institutional functions of a modern nation-state — law, public administration, and political decision-making — using Web3 / blockchain technology, starting from scratch under the assumption that a modern state's legal, administrative, and political frameworks already exist as a reference model.

This is **not** a simulation or a game. It is an attempt to see how far the mechanisms of statehood can be meaningfully implemented as smart contracts, and what must remain off-chain (law, human judgment, physical-world enforcement).

## Tech Stack

| Layer | Choice | Notes |
|---|---|---|
| Smart contracts | [Foundry](https://getfoundry.sh/) (Solidity) | See [`contracts/README.md`](contracts/README.md) |
| Frontend | [Next.js](https://nextjs.org/) (App Router), deployed on [Vercel](https://vercel.com/) | See [`frontend/README.md`](frontend/README.md) |
| Target chains | Ethereum, Polkadot Hub (both EVM-compatible) | **Sepolia testnet is the priority network for now.** Mainnet chain choice is deferred — see [`docs/architecture/blockchain.md`](docs/architecture/blockchain.md) |
| License | MIT | See [`LICENSE`](LICENSE) |

Both candidate chains are EVM-compatible, so the same Solidity codebase targets either network; only the deploy target (RPC endpoint / network config) changes. See [`docs/architecture/blockchain.md`](docs/architecture/blockchain.md) for details.

## Repository Structure

```
web3state/
├── contracts/          # Foundry project: Solidity smart contracts
├── frontend/           # Next.js application (App Router)
└── docs/
    ├── PROJECT_STATUS.md     # Where the project stands right now
    ├── FEATURES.md            # At-a-glance progress: every planned function and how far it's gotten
    ├── decisions/             # Architecture Decision Records (ADRs) — why past choices were made
    ├── architecture/          # System design: overview, blockchain, frontend
    ├── state-design/          # Mapping real-world state functions to on-chain/off-chain design
    ├── operations/            # Online / on-chain / offline task conventions
    └── glossary.md            # Shared vocabulary between state concepts and implementation
```

## Where to Start

- **New to the project?** Read [`docs/PROJECT_STATUS.md`](docs/PROJECT_STATUS.md) first — it describes the current phase and open questions.
- **Want to see implementation progress at a glance?** See [`docs/FEATURES.md`](docs/FEATURES.md).
- **Want the history of why things are the way they are?** See [`docs/decisions/`](docs/decisions/).
- **Working on contracts?** See [`contracts/README.md`](contracts/README.md).
- **Working on the frontend?** See [`frontend/README.md`](frontend/README.md).

## Contributing

See [`CONTRIBUTING.md`](CONTRIBUTING.md) and [`CHANGELOG.md`](CHANGELOG.md).

## License

[MIT](LICENSE)

---

# web3state (日本語)

> 🚧 これは初期段階の実験的プロジェクトです。アーキテクチャやスコープは現在進行形で議論・変更されています。

現代の国家(法律・行政・政治の仕組み)が既に存在することを前提に、その国家としての機能を、ゼロからWeb3/ブロックチェーン技術を用いて設計・実装してみるという実験的プロジェクトです。

これはシミュレーションやゲームではありません。国家としての仕組みをどこまでスマートコントラクトとして意味のある形で実装できるか、そして何がオフチェーン(法律・人間の判断・現実世界での執行)に残らざるを得ないかを検証する試みです。

## 技術スタック

| レイヤー | 採用技術 | 備考 |
|---|---|---|
| スマートコントラクト | [Foundry](https://getfoundry.sh/) (Solidity) | [`contracts/README.md`](contracts/README.md) 参照 |
| フロントエンド | [Next.js](https://nextjs.org/) (App Router)、[Vercel](https://vercel.com/) にデプロイ | [`frontend/README.md`](frontend/README.md) 参照 |
| 対象チェーン | Ethereum、Polkadot Hub (いずれもEVM互換) | **テストではSepoliaテストネットを優先的に使用します。** メインネットでどのチェーンを採用するかは別途決定 — 詳細は [`docs/architecture/blockchain.md`](docs/architecture/blockchain.md) |
| ライセンス | MIT | [`LICENSE`](LICENSE) 参照 |

候補となる2つのチェーンはいずれもEVM互換のため、同一のSolidityコードベースをデプロイ先の切り替えだけで両対応させる方針です。詳細は [`docs/architecture/blockchain.md`](docs/architecture/blockchain.md) を参照してください。

## リポジトリ構成

上記の英語版の構成図を参照してください(構成は言語に依存しません)。

## まず読むもの

- **初めてこのプロジェクトに参加する方**: まず [`docs/PROJECT_STATUS.md`](docs/PROJECT_STATUS.md) を読んでください。現在のフェーズと未解決の論点がまとまっています。
- **実装の進捗を一覧で見たい方**: [`docs/FEATURES.md`](docs/FEATURES.md) を参照してください。
- **過去の経緯(なぜその決定に至ったか)を知りたい方**: [`docs/decisions/`](docs/decisions/) を参照してください。
- **コントラクト開発に関わる方**: [`contracts/README.md`](contracts/README.md)
- **フロントエンド開発に関わる方**: [`frontend/README.md`](frontend/README.md)

## コントリビュート

[`CONTRIBUTING.md`](CONTRIBUTING.md) と [`CHANGELOG.md`](CHANGELOG.md) を参照してください。

## ライセンス

[MIT](LICENSE)

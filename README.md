# web3state

> 🚧 Early-stage, exploratory project. Architecture and scope are being actively discussed and will change.

An experimental project to design and build the institutional functions of a modern nation-state — law, public administration, and political decision-making — using Web3 / blockchain technology, starting from scratch under the assumption that a modern state's legal, administrative, and political frameworks already exist as a reference model.

This is **not** a simulation or a game. It is an attempt to see how far the mechanisms of statehood can be meaningfully implemented as smart contracts, and what must remain off-chain (law, human judgment, physical-world enforcement).

## System Roadmap — What This Project Is Designing

> The authoritative, detailed version of this table — with design-doc and ADR links, discussion logs, and per-feature notes — lives in [`docs/FEATURES.md`](docs/FEATURES.md). This is a condensed, at-a-glance copy; update both when a status changes. See [ADR 0012](docs/decisions/0012-onchain-scope-philosophy.md) for the reasoning behind what's in/out of scope.

| Category | Function | Status |
|---|---|---|
| Identity & Rights | [Citizenship / residency](docs/state-design/citizenship/) (`ResidentLink`) | 🟢 Spec drafted |
| Identity & Rights | [Corporations](docs/state-design/corporations/) | 🟢 Spec drafted |
| Identity & Rights | [Credentials](docs/state-design/credentials/): passport, diploma, license, health insurance, employee ID, vaccination | 🟢 Spec drafted (all six) |
| Governance Core | Voting | 🔴 Not started |
| Governance Core | Legislative process | 🔴 Not started |
| Governance Core | Executive / administration | 🔴 Not started |
| Governance Core | Judiciary / dispute resolution | 🔴 Not started |
| Public Finance & Taxation | [Taxation: payment](docs/state-design/taxation/) | 🟢 Spec drafted |
| Public Finance & Taxation | Treasury / public finance (budget, spending) | 🔴 Not started |
| Political Transparency | Political donations | 🔴 Not started |
| Political Transparency | VIP / politician asset disclosure | 🔴 Not started |
| Political Transparency | Public procurement / bidding | 🔴 Not started |
| Political Transparency | Subsidies / grants disbursement | 🔴 Not started |
| Social Welfare | Pension | 🔴 Not started |
| Social Welfare | Benefits (child allowance, welfare, etc.) | 🔴 Not started |
| Social Welfare | Unemployment insurance | 🔴 Not started |
| Public-Interest Finance | Donations | 🔴 Not started |
| Public-Interest Finance | Crowdfunding (social-purpose) | 🔴 Not started |
| Public-Interest Finance | NPO / public-interest corporation funds | 🔴 Not started |
| Property & Vital Records | Real estate registry | 🔴 Not started |
| Property & Vital Records | Vital records (birth, marriage, death) | 🔴 Not started |
| Corporate & Market Transparency | Public company disclosures | 🔴 Not started |
| Corporate & Market Transparency | Audit trails | 🔴 Not started |
| Judicial Infrastructure | Notarization / contract timestamping | 🔴 Not started |
| Judicial Infrastructure | Public court records | 🔴 Not started |
| Commerce & Markets | Everyday commerce | 🔴 Not started |
| Commerce & Markets | Wealth-focused financial services | 🔴 Not started (provider-handled tax compliance, not full on-chain transparency) |
| Deliberately excluded | High-frequency trading | 🚫 Excluded |
| Deliberately excluded | Personal wealth-accumulation investment | 🚫 Excluded |

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

## 設計ロードマップ — このプロジェクトが設計するもの

> この表の詳細版(設計書・ADRへのリンク、議論ログ、機能ごとの注記を含む正式なもの)は [`docs/FEATURES.md`](docs/FEATURES.md) にあります。こちらは一覧性を重視した凝縮版です。ステータスが変わったら両方を更新してください。何をオンチェーン化の対象/対象外とするかの考え方は [ADR 0012](docs/decisions/0012-onchain-scope-philosophy.md) を参照してください。

| カテゴリ | 機能 | ステータス |
|---|---|---|
| アイデンティティ・権利 | [国民・住民](docs/state-design/citizenship/)(`ResidentLink`) | 🟢 設計確定 |
| アイデンティティ・権利 | [法人](docs/state-design/corporations/) | 🟢 設計確定 |
| アイデンティティ・権利 | [公的証明](docs/state-design/credentials/): パスポート、卒業証明、免許証、健康保険証、社員証、接種証明 | 🟢 設計確定(6つ全て) |
| 統治の中核 | 投票 | 🔴 未着手 |
| 統治の中核 | 立法プロセス | 🔴 未着手 |
| 統治の中核 | 行政 | 🔴 未着手 |
| 統治の中核 | 司法・紛争解決 | 🔴 未着手 |
| 財政・税 | [納税](docs/state-design/taxation/) | 🟢 設計確定 |
| 財政・税 | 財務(予算・歳出) | 🔴 未着手 |
| 政治の透明性 | 政治献金 | 🔴 未着手 |
| 政治の透明性 | 要人(政治家等)の資産公開 | 🔴 未着手 |
| 政治の透明性 | 公共調達・入札 | 🔴 未着手 |
| 政治の透明性 | 補助金・交付金の交付 | 🔴 未着手 |
| 社会保障 | 年金 | 🔴 未着手 |
| 社会保障 | 各種手当(児童手当、生活保護等) | 🔴 未着手 |
| 社会保障 | 雇用保険 | 🔴 未着手 |
| 公益金融 | 寄付 | 🔴 未着手 |
| 公益金融 | クラウドファンディング(社会性の強いもの) | 🔴 未着手 |
| 公益金融 | NPO法人・公益法人の資金管理 | 🔴 未着手 |
| 財産・身分登記 | 不動産登記 | 🔴 未着手 |
| 財産・身分登記 | 戸籍・婚姻・出生等の身分関係記録 | 🔴 未着手 |
| 法人・市場の透明性 | 上場企業の開示書類 | 🔴 未着手 |
| 法人・市場の透明性 | 会計監査記録 | 🔴 未着手 |
| 司法インフラ | 公証・契約の電子証明 | 🔴 未着手 |
| 司法インフラ | 判決等の司法記録の公開 | 🔴 未着手 |
| 商取引・市場 | 日常の商取引 | 🔴 未着手 |
| 商取引・市場 | 富裕層向け金融サービス | 🔴 未着手(提供者が納税処理の責任を持ち、完全なオンチェーン透明化は行わない) |
| 意図的に対象外 | 高頻度取引(HFT) | 🚫 対象外 |
| 意図的に対象外 | 個人の資産形成目的の投資 | 🚫 対象外 |

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

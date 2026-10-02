# Project Status

> Living document. Update this whenever the project moves phase, a major question is resolved, or a new major question opens. Keep it short — detail belongs in ADRs or architecture docs, this is a snapshot.

**Last updated:** 2026-10-03

## Current phase

**Phase 0 — Scaffolding.** Repository structure, documentation conventions, and tooling choices are in place. No smart contracts or frontend code have been written yet. Concrete feature design (which parts of a state's functions to model, and how) has not started.

## Decided

- Monorepo-style single repository with two main components: `contracts/` (Foundry/Solidity) and `frontend/` (Next.js, deployed on Vercel). No workspace tooling (pnpm workspaces, Turborepo) linking them — kept as independent, self-contained directories.
- Target chains: Ethereum and Polkadot Hub, both EVM-compatible — same Solidity codebase, deploy target switches via config. **Sepolia testnet is the priority network during development.** Mainnet chain choice is explicitly deferred.
- Documentation language: English primary, Japanese alongside for key documents.
- License: MIT.
- Decision history tracked via ADRs in [`docs/decisions/`](decisions/); code-level history via [`CHANGELOG.md`](../CHANGELOG.md).
- See [`docs/decisions/0002-initial-stack-and-structure.md`](decisions/0002-initial-stack-and-structure.md) for the full rationale.

## Open questions

- Which mainnet chain to launch on (Ethereum mainnet vs. Polkadot Hub mainnet) — deferred until testing phase provides more signal.
- Which real-world state functions to model first (e.g., citizenship/identity, treasury, legislative process, voting) — not yet scoped.
- Governance model for the project itself (who can propose/approve changes to the "constitution" of the contracts).
- Whether any part of the system requires off-chain components beyond the frontend (e.g., indexing, notifications) — not yet needed, revisit when a concrete feature requires it (YAGNI).
- CI/CD setup (tests, linting, deployment pipeline) — not yet set up; add when there is code to verify.

## Next steps

1. Discuss and scope the first concrete state function to model (see [`docs/state-design/README.md`](state-design/README.md)).
2. Write an ADR for the chosen scope and initial contract module boundaries.
3. Bootstrap `contracts/` (Foundry init) and `frontend/` (create-next-app) once there is a concrete target to build against.

---

# プロジェクトの現状(日本語)

> 生きたドキュメントです。プロジェクトのフェーズが進んだとき、大きな論点が解決したとき、新たな論点が生まれたときに更新してください。詳細はADRやアーキテクチャドキュメントに記載し、ここはスナップショットとして簡潔に保ちます。

**最終更新日:** 2026-10-03

## 現在のフェーズ

**フェーズ0 — 足場固め。** リポジトリ構成、ドキュメント規約、ツール選定が完了した段階。スマートコントラクト・フロントエンドのコードはまだ書かれていません。具体的な機能設計(国家のどの機能をどのようにモデル化するか)もまだ始まっていません。

## 決定済み事項

- `contracts/`(Foundry/Solidity)と `frontend/`(Next.js、Vercelへデプロイ)の2コンポーネントによる単一リポジトリ構成。pnpm workspace等での統合は行わず、独立したディレクトリとする。
- 対象チェーンはEthereumとPolkadot Hub(いずれもEVM互換)。同一のSolidityコードベースをデプロイ先の切り替えで両対応。**開発中はSepoliaテストネットを優先使用。** メインネットの選定は意図的に保留。
- ドキュメント言語: 英語を主言語とし、重要なドキュメントには日本語を併記。
- ライセンス: MIT。
- 決定の経緯は [`docs/decisions/`](decisions/) のADRで、コードレベルの変更履歴は [`CHANGELOG.md`](../CHANGELOG.md) で管理。
- 詳細な理由は [`docs/decisions/0002-initial-stack-and-structure.md`](decisions/0002-initial-stack-and-structure.md) を参照。

## 未解決の論点

- メインネットでどのチェーンを採用するか(Ethereum mainnet vs. Polkadot Hub mainnet) — テスト段階でより多くの知見を得てから決定。
- 国家のどの機能から着手するか(市民権/本人確認、財務、立法プロセス、投票など) — 未着手。
- プロジェクト自体のガバナンスモデル(コントラクトの「憲法」部分の変更を誰が提案・承認できるか)。
- フロントエンド以外のオフチェーンコンポーネント(インデクシング、通知等)が必要かどうか — 現時点では不要。具体的な機能要件が出てから検討(YAGNI)。
- CI/CD — コードが存在してから整備する。

## 次のステップ

1. 最初にモデル化する具体的な国家機能をディスカッションしてスコープを決める([`docs/state-design/README.md`](state-design/README.md) 参照)。
2. 決定したスコープと初期コントラクトモジュール境界についてADRを書く。
3. 具体的な実装対象が決まり次第、`contracts/`(Foundry init)と `frontend/`(create-next-app)を実際にブートストラップする。

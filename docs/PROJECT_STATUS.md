# Project Status

> Living document. Update this whenever the project moves phase, a major question is resolved, or a new major question opens. Keep it short — detail belongs in ADRs or architecture docs, this is a snapshot.

**Last updated:** 2026-10-06

## Current phase

**Phase 1 (continued) — Designing state functions; implementation deliberately deferred.** Repository scaffold is in place (Phase 0 complete). Five state functions are fully resolved and specified: citizenship/residency (resident-link NFT, [ADR 0003](decisions/0003-resident-link-identity-model.md)), taxation/payment rail ([ADR 0004](decisions/0004-taxation-payment-rail.md)), corporations/registration ([ADR 0005](decisions/0005-corporate-registration-model.md)), the passport credential ([ADR 0006](decisions/0006-passport-credential.md)), and the diploma credential ([ADR 0007](decisions/0007-diploma-credential.md)) — the first two concrete instances of the broader "credentials" pattern. See [`docs/FEATURES.md`](FEATURES.md) for the full, up-to-date progress table, and [`docs/BACKLOG.md`](BACKLOG.md) for items deferred out of those designs.

**Explicit workflow decision (2026-10-03):** implementation (Solidity, `contracts/` Foundry init, etc.) will **not** start after each individual feature's design is finished. Instead, the project will first design all of the initially-planned state functions, then review them together for overall cross-feature consistency, and only then move into implementation. No smart contracts or frontend code have been written yet, and none will be until that consistency review happens.

## Decided

- Monorepo-style single repository with two main components: `contracts/` (Foundry/Solidity) and `frontend/` (Next.js, deployed on Vercel). No workspace tooling (pnpm workspaces, Turborepo) linking them — kept as independent, self-contained directories.
- Target chains: Ethereum and Polkadot Hub, both EVM-compatible — same Solidity codebase, deploy target switches via config. **Sepolia testnet is the priority network during development.** Mainnet chain choice is explicitly deferred.
- Documentation language: English primary, Japanese alongside for key documents.
- License: MIT.
- Decision history tracked via ADRs in [`docs/decisions/`](decisions/); code-level history via [`CHANGELOG.md`](../CHANGELOG.md).
- Citizenship/residency: a municipality-issued, soulbound, nationality-neutral "resident-link" NFT (proves residency-linkage only, no nationality claim); see [ADR 0003](decisions/0003-resident-link-identity-model.md) for full rationale.
- Taxation (individual, direct payment only): no dedicated contract — a plain stablecoin transfer from the resident's `ResidentLink` address to an officially-attested receiving address; see [ADR 0004](decisions/0004-taxation-payment-rail.md).
- Corporations: an authority-issued, soulbound, on-chain registration NFT per registration/supervision relationship (a corporation may hold several); officer/representative names are public on-chain, their addresses never are; the corporation's own address is a contract governed by a multisig signed with officers' personal keys; see [ADR 0005](decisions/0005-corporate-registration-model.md).
- Credentials (公的証明), general pattern: any credential NFT (diploma, passport, license, employee ID, etc.) proves possession only — zero on-chain fields; trust-anchor reuse and sub-type granularity are per-credential-type judgment calls, not a fixed rule.
- Passport: the first concrete credential — a pure travel-document NFT issued by 外務省, authority-only mint/burn, renewal modeled as burn-and-reissue. **No on-chain nationality credential exists** — 外務省 verifies nationality entirely off-chain, the same way a municipality verifies identity off-chain before minting `ResidentLink`. See [ADR 0006](decisions/0006-passport-credential.md).
- Diploma: the second concrete credential — issued from a school's existing corporate-registration address (no new trust mechanism); mint-once lifecycle (simplest so far); requires the recipient to hold a `ResidentLink` NFT at mint time (one-time, on-chain check) — no nationality distinction, since `ResidentLink` itself makes none. See [ADR 0007](decisions/0007-diploma-credential.md).
- Standing guidance: current-law feasibility (e.g., "does a municipality have legal authority to do X") is not raised as a discussion point in this project — it's an explicit thought experiment, not aimed at real-world legal adoption.

## Open questions

- Which mainnet chain to launch on (Ethereum mainnet vs. Polkadot Hub mainnet) — deferred until testing phase provides more signal.
- Which real-world state functions to design after citizenship, taxation, corporations, and credentials (e.g., legislative process, executive/administration, judiciary, treasury/spending, voting) — not yet scoped. See [`docs/BACKLOG.md`](BACKLOG.md) for specific deferred items already identified (financial-product tokenization, employer-withholding abolition, the audited multisig standard to use, beneficial-ownership transparency, whether nationality/residence-status should ever be on-chain, etc.).
- Within credentials: license, employee ID, health-insurance, and vaccination credentials remain to be designed, one at a time, applying the patterns validated by passport and diploma.
- Governance model for the project itself (who can propose/approve changes to the "constitution" of the contracts).
- Whether any part of the system requires off-chain components beyond the frontend (e.g., indexing, notifications) — not yet needed, revisit when a concrete feature requires it (YAGNI).
- CI/CD setup (tests, linting, deployment pipeline) — not yet set up; add when there is code to verify.

## Next steps

1. Continue designing the remaining credential types one at a time (license, employee ID, health-insurance, vaccination), applying the patterns validated by passport and diploma — or move to a different state function entirely (e.g. voting, legislative process) if the user prefers; either way, raise issues, discuss with the user, record in a discussion log, write an ADR + spec.
2. Once the initially-planned state functions are specified, review them together for cross-feature consistency before writing any Solidity.
3. Only after that review: `contracts/` (Foundry init) and implementation, starting with `ResidentLink`.

---

# プロジェクトの現状(日本語)

> 生きたドキュメントです。プロジェクトのフェーズが進んだとき、大きな論点が解決したとき、新たな論点が生まれたときに更新してください。詳細はADRやアーキテクチャドキュメントに記載し、ここはスナップショットとして簡潔に保ちます。

**最終更新日:** 2026-10-06

## 現在のフェーズ

**フェーズ1(継続中)— 国家機能の設計を継続。実装は意図的に延期。** リポジトリの足場固め(フェーズ0)は完了。国民・住民(住民登録リンクNFT、[ADR 0003](decisions/0003-resident-link-identity-model.md))、納税(決済レール、[ADR 0004](decisions/0004-taxation-payment-rail.md))、法人(登録、[ADR 0005](decisions/0005-corporate-registration-model.md))、パスポートクレデンシャル([ADR 0006](decisions/0006-passport-credential.md))、卒業証明クレデンシャル([ADR 0007](decisions/0007-diploma-credential.md))の5機能が議論を経て確定済みです(パスポートと卒業証明は、より広い「公的証明」パターンの最初の2つの具体例)。全機能の最新進捗は [`docs/FEATURES.md`](FEATURES.md)、これらの設計から先送りされた項目は [`docs/BACKLOG.md`](BACKLOG.md) を参照してください。

**明示的なワークフロー決定(2026-10-03):** 各機能の設計が終わるたびに実装(Solidity、`contracts/` のFoundry initなど)には進みません。まず当初想定している国家機能全体の設計を終わらせ、機能間で矛盾がないか全体を見直した上で、初めて実装に入ります。スマートコントラクト・フロントエンドのコードはまだ書かれておらず、この全体整合性のレビューが終わるまでは書きません。

## 決定済み事項

- `contracts/`(Foundry/Solidity)と `frontend/`(Next.js、Vercelへデプロイ)の2コンポーネントによる単一リポジトリ構成。pnpm workspace等での統合は行わず、独立したディレクトリとする。
- 対象チェーンはEthereumとPolkadot Hub(いずれもEVM互換)。同一のSolidityコードベースをデプロイ先の切り替えで両対応。**開発中はSepoliaテストネットを優先使用。** メインネットの選定は意図的に保留。
- ドキュメント言語: 英語を主言語とし、重要なドキュメントには日本語を併記。
- ライセンス: MIT。
- 決定の経緯は [`docs/decisions/`](decisions/) のADRで、コードレベルの変更履歴は [`CHANGELOG.md`](../CHANGELOG.md) で管理。
- 国民・住民: 市区町村が発行する、譲渡不可(Soulbound)かつ国籍を問わない「住民登録リンク」NFT(住民であることの証明のみを行い、国籍は主張しない)。詳細は [ADR 0003](decisions/0003-resident-link-identity-model.md) を参照。
- 納税(個人の直接支払いのみ): 専用コントラクトなし — 住民の`ResidentLink`アドレスから、公式に証明された受取アドレスへの単純なステーブルコイン送金。詳細は [ADR 0004](decisions/0004-taxation-payment-rail.md) を参照。
- 法人: 登録・監督関係ごとに発行主体が発行する、譲渡不可・オンチェーンの登録NFT(法人は複数保有可)。役員・代表者の氏名はオンチェーンで公開、アドレスは一切非公開。法人自身のアドレスは、役員本人の個人鍵で署名するマルチシグが統治するコントラクト。詳細は [ADR 0005](decisions/0005-corporate-registration-model.md) を参照。
- 公的証明(一般パターン): どの証明NFT(卒業証明、パスポート、免許証、社員証等)も、保持の事実のみを証明する — オンチェーンのフィールドは一切なし。信頼の起点の流用、細分化の粒度は、固定ルールではなく証明の種類ごとの判断とする。
- パスポート: 最初の具体的な証明。外務省が発行する純粋な渡航文書NFTで、発行主体のみがmint/burnでき、更新はburn+再発行でモデル化する。**オンチェーンの国籍クレデンシャルは存在しない** — 外務省は、市区町村が`ResidentLink`発行前に本人確認を行うのと同じく、完全にオフチェーンで国籍を確認する。詳細は [ADR 0006](decisions/0006-passport-credential.md) を参照。
- 卒業証明: 2つ目の具体的な証明。学校の既存の法人登録アドレスから発行する(新しい信頼の仕組みは不要)。mintは一度きりという、これまでで最もシンプルなライフサイクル。受領者がmint時点で`ResidentLink`NFTを保有していることを要件とする(一度きりのオンチェーンチェック) — `ResidentLink`自体が国籍を区別しないため、国籍による区別はない。詳細は [ADR 0007](decisions/0007-diploma-credential.md) を参照。
- 恒常的な方針: 「市区町村にそれを行う法的権限があるか」のような現行法上の実現可能性は、このプロジェクトでは議論の対象としない — これは実社会への法制度化を目指すものではない、明示的な思考実験であるため。

## 未解決の論点

- メインネットでどのチェーンを採用するか(Ethereum mainnet vs. Polkadot Hub mainnet) — テスト段階でより多くの知見を得てから決定。
- citizenship・taxation・法人・credentialsの後にどの国家機能を設計するか(立法プロセス、行政、司法、財務/歳出、投票など) — 未着手。既に特定済みの先送り項目(金融商品のトークン化、源泉徴収の廃止、法人用監査済みマルチシグの選定、実質的支配者の透明性、国籍/在留資格をオンチェーンで扱うか等)は [`docs/BACKLOG.md`](BACKLOG.md) を参照。
- 公的証明のうち、免許証・社員証・健康保険証・接種証明は未設計のまま残っている — パスポート・卒業証明で検証したパターンを使い、1つずつ進める。
- プロジェクト自体のガバナンスモデル(コントラクトの「憲法」部分の変更を誰が提案・承認できるか)。
- フロントエンド以外のオフチェーンコンポーネント(インデクシング、通知等)が必要かどうか — 現時点では不要。具体的な機能要件が出てから検討(YAGNI)。
- CI/CD — コードが存在してから整備する。

## 次のステップ

1. 残りの公的証明(免許証、社員証、健康保険証、接種証明)を1つずつ、パスポート・卒業証明で検証したパターンを適用しながら設計を続ける — あるいはユーザーが希望すれば、全く別の国家機能(投票、立法プロセス等)に進む。いずれの場合も、論点の提起→ユーザーとの議論→議論ログへの記録→ADR＋設計書の作成、という進め方を続ける。
2. 当初想定している国家機能の設計が出揃った段階で、Solidityを書く前に機能間の整合性を全体でレビューする。
3. そのレビューの後に初めて `contracts/`(Foundry init)と実装(`ResidentLink`から)に着手する。

# Project Status

> Living document. Update this whenever the project moves phase, a major question is resolved, or a new major question opens. Keep it short — detail belongs in ADRs or architecture docs, this is a snapshot.

**Last updated:** 2026-10-10

## Current phase

**Phase 1 (continued) — Designing state functions; implementation deliberately deferred.** Repository scaffold is in place (Phase 0 complete). Nine state functions are fully resolved and specified: citizenship/residency (resident-link NFT, [ADR 0003](decisions/0003-resident-link-identity-model.md)), taxation/payment rail ([ADR 0004](decisions/0004-taxation-payment-rail.md)), corporations/registration ([ADR 0005](decisions/0005-corporate-registration-model.md)), the passport credential ([ADR 0006](decisions/0006-passport-credential.md)), the diploma credential ([ADR 0007](decisions/0007-diploma-credential.md)), the license credential ([ADR 0008](decisions/0008-license-credential.md)), the health-insurance credential ([ADR 0009](decisions/0009-health-insurance-credential.md)), the employee ID credential ([ADR 0010](decisions/0010-employee-id-credential.md)), and the vaccination credential ([ADR 0011](decisions/0011-vaccination-credential.md)) — **completing the originally-listed set of six concrete "credentials" instances.** See [`docs/FEATURES.md`](FEATURES.md) for the full, up-to-date progress table, and [`docs/BACKLOG.md`](BACKLOG.md) for items deferred out of those designs.

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
- License (driver's license): the third concrete credential — a single contract per prefecture (no per-vehicle-class split, unlike diploma — mirrors how one physical card already manages multiple classes today); suspension and revocation both represented identically on-chain as burn, with the real-world distinction kept off-chain; requires `ResidentLink` at mint, same pattern as diploma. See [ADR 0008](decisions/0008-license-credential.md).
- Health insurance: the fourth concrete credential — one contract per insurer; every insurer type (municipality, prefectural 広域連合, 協会けんぽ, 組合健保, 共済組合) maps onto an already-established trust mechanism, no new one needed; continuous (non-expiring) lifecycle unlike passport/license; requires `ResidentLink` at mint; no special handling for dependents. See [ADR 0009](decisions/0009-health-insurance-credential.md).
- Employee ID: the fifth concrete credential — issued from any registered corporation's existing corporate-registration address (no specific authority type); sole proprietors cannot issue it; one contract per company; continuous lifecycle like health insurance; **no `ResidentLink` precondition** — the first since passport, since employment isn't inherently tied to Japanese residency. See [ADR 0010](decisions/0010-employee-id-credential.md).
- Vaccination: the sixth and final originally-listed concrete credential — a municipality-issued, soulbound vaccination coupon with a genuine on-chain status field (`Issued`/`Vaccinated`), the second credential (after corporations) needing real mutable state. A hospital — not the municipality — flips the status, via a `VACCINATOR_ROLE` the municipality grants only to addresses already holding a valid corporate (医療法人) registration, checked on-chain; the hospital's actual legitimacy stays an off-chain determination. Multiple doses are multiple separate coupons; `Vaccinated` coupons are never burned. See [ADR 0011](decisions/0011-vaccination-credential.md).
- Standing guidance: current-law feasibility (e.g., "does a municipality have legal authority to do X") is not raised as a discussion point in this project — it's an explicit thought experiment, not aimed at real-world legal adoption.

## Open questions

- Which mainnet chain to launch on (Ethereum mainnet vs. Polkadot Hub mainnet) — deferred until testing phase provides more signal.
- Which real-world state functions to design next (e.g., legislative process, executive/administration, judiciary, treasury/spending, voting) — the originally-listed credentials are now all designed, so this is the next open choice. See [`docs/BACKLOG.md`](BACKLOG.md) for specific deferred items already identified (financial-product tokenization, employer-withholding abolition, the audited multisig standard to use, beneficial-ownership transparency, whether nationality/residence-status should ever be on-chain, etc.).
- Whether any *additional* credential types beyond the original six (passport, diploma, license, health insurance, employee ID, vaccination) are wanted — not currently planned, but the pattern is now well-validated if more come up.
- Governance model for the project itself (who can propose/approve changes to the "constitution" of the contracts).
- Whether any part of the system requires off-chain components beyond the frontend (e.g., indexing, notifications) — not yet needed, revisit when a concrete feature requires it (YAGNI).
- CI/CD setup (tests, linting, deployment pipeline) — not yet set up; add when there is code to verify.

## Next steps

1. Choose and design the next state function (e.g. voting, legislative process, executive/administration, judiciary, treasury/spending) — the originally-planned credentials set is complete. Same process as always: raise issues, discuss with the user, record in a discussion log, write an ADR + spec.
2. Once the initially-planned state functions are specified, review them together for cross-feature consistency before writing any Solidity.
3. Only after that review: `contracts/` (Foundry init) and implementation, starting with `ResidentLink`.

---

# プロジェクトの現状(日本語)

> 生きたドキュメントです。プロジェクトのフェーズが進んだとき、大きな論点が解決したとき、新たな論点が生まれたときに更新してください。詳細はADRやアーキテクチャドキュメントに記載し、ここはスナップショットとして簡潔に保ちます。

**最終更新日:** 2026-10-10

## 現在のフェーズ

**フェーズ1(継続中)— 国家機能の設計を継続。実装は意図的に延期。** リポジトリの足場固め(フェーズ0)は完了。国民・住民(住民登録リンクNFT、[ADR 0003](decisions/0003-resident-link-identity-model.md))、納税(決済レール、[ADR 0004](decisions/0004-taxation-payment-rail.md))、法人(登録、[ADR 0005](decisions/0005-corporate-registration-model.md))、パスポートクレデンシャル([ADR 0006](decisions/0006-passport-credential.md))、卒業証明クレデンシャル([ADR 0007](decisions/0007-diploma-credential.md))、免許証クレデンシャル([ADR 0008](decisions/0008-license-credential.md))、健康保険証クレデンシャル([ADR 0009](decisions/0009-health-insurance-credential.md))、社員証クレデンシャル([ADR 0010](decisions/0010-employee-id-credential.md))、接種証明クレデンシャル([ADR 0011](decisions/0011-vaccination-credential.md))の9機能が議論を経て確定済みです — **これで当初挙げられていた「公的証明」6つの具体例が全て出揃いました。** 全機能の最新進捗は [`docs/FEATURES.md`](FEATURES.md)、これらの設計から先送りされた項目は [`docs/BACKLOG.md`](BACKLOG.md) を参照してください。

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
- 免許証(運転免許証): 3つ目の具体的な証明。都道府県ごとに1つのコントラクト(卒業証明と異なり車両区分での分割はしない — 今日でも1枚の物理的な免許証で複数の区分を管理しているのを反映)。停止と取消はオンチェーンでは同一(burn)として扱い、現実の区別はオフチェーンに残す。mintには卒業証明と同じパターンで`ResidentLink`を要件とする。詳細は [ADR 0008](decisions/0008-license-credential.md) を参照。
- 健康保険証: 4つ目の具体的な証明。保険者ごとに1コントラクト。全ての保険者の種類(市区町村、都道府県の広域連合、協会けんぽ、組合健保、共済組合)が既存の信頼の仕組みに対応し、新しい仕組みは不要。パスポート・免許証と異なり、継続的な(期限切れのない)ライフサイクル。mintには`ResidentLink`を要件とする。扶養家族への特別な対応はなし。詳細は [ADR 0009](decisions/0009-health-insurance-credential.md) を参照。
- 社員証: 5つ目の具体的な証明。登録された法人であれば誰でも、既存の法人登録アドレスから発行できる(特定の機関の種類は問わない)。個人事業主は発行できない。会社ごとに1コントラクト。健康保険証と同じ継続的なライフサイクル。**`ResidentLink`の前提条件なし** — パスポート以来初めて、雇用は日本の住民資格と本質的に結びついていないため。詳細は [ADR 0010](decisions/0010-employee-id-credential.md) を参照。
- 接種証明: 当初挙げられていた6つ目で最後の具体的な証明。市区町村が発行する、譲渡不可の接種券で、実質的なオンチェーンの状態フィールド(`Issued`/`Vaccinated`)を持つ、法人に続き2例目のクレデンシャル。発行主体の市区町村ではなく**病院**がステータスを変更する。市区町村は、既に有効な法人登録(医療法人)を保有しているアドレスにのみ`VACCINATOR_ROLE`を付与する(オンチェーンで確認)。病院の実際の正当性はオフチェーンの判断のまま。複数回接種は複数の別々の接種券とし、`Vaccinated`になった接種券は決してburnしない。詳細は [ADR 0011](decisions/0011-vaccination-credential.md) を参照。
- 恒常的な方針: 「市区町村にそれを行う法的権限があるか」のような現行法上の実現可能性は、このプロジェクトでは議論の対象としない — これは実社会への法制度化を目指すものではない、明示的な思考実験であるため。

## 未解決の論点

- メインネットでどのチェーンを採用するか(Ethereum mainnet vs. Polkadot Hub mainnet) — テスト段階でより多くの知見を得てから決定。
- 次にどの国家機能を設計するか(立法プロセス、行政、司法、財務/歳出、投票など) — 当初挙げられていた公的証明は全て設計済みのため、これが次に決めるべき論点になる。既に特定済みの先送り項目(金融商品のトークン化、源泉徴収の廃止、法人用監査済みマルチシグの選定、実質的支配者の透明性、国籍/在留資格をオンチェーンで扱うか等)は [`docs/BACKLOG.md`](BACKLOG.md) を参照。
- 当初の6つ(パスポート、卒業証明、免許証、健康保険証、社員証、接種証明)を超える追加の公的証明が必要かどうか — 現時点では予定なし。ただしパターンは十分検証済みなので、今後出てきても対応可能。
- プロジェクト自体のガバナンスモデル(コントラクトの「憲法」部分の変更を誰が提案・承認できるか)。
- フロントエンド以外のオフチェーンコンポーネント(インデクシング、通知等)が必要かどうか — 現時点では不要。具体的な機能要件が出てから検討(YAGNI)。
- CI/CD — コードが存在してから整備する。

## 次のステップ

1. 次の国家機能(投票、立法プロセス、行政、司法、財務/歳出等)を選び、設計する — 当初予定していた公的証明一式は完了した。いつもと同じ進め方(論点の提起→ユーザーとの議論→議論ログへの記録→ADR＋設計書の作成)を続ける。
2. 当初想定している国家機能の設計が出揃った段階で、Solidityを書く前に機能間の整合性を全体でレビューする。
3. そのレビューの後に初めて `contracts/`(Foundry init)と実装(`ResidentLink`から)に着手する。

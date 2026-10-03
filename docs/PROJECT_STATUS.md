# Project Status

> Living document. Update this whenever the project moves phase, a major question is resolved, or a new major question opens. Keep it short — detail belongs in ADRs or architecture docs, this is a snapshot.

**Last updated:** 2026-10-03

## ⏸ Paused — resume point

Work is paused mid-discussion on the **passport/nationality credential** (first concrete instance of the [credentials](state-design/credentials/) pattern — see [`docs/state-design/credentials/passport/discussion-log.md`](state-design/credentials/passport/discussion-log.md), Round 1).

**When the user says "再開して" (resume), re-present these 5 open issues verbatim and continue the discussion from there — do not start a new topic first:**

1. Split "nationality" (persistent, 法務省-issued) and "passport" (renewable travel document, 外務省-issued, requires holding a valid nationality credential) into two separate credentials, since they have different lifecycles — confirm or prefer one combined credential.
2. Allow **self-initiated burn** for the nationality credential specifically (mirroring the real right of 国籍離脱 under 国籍法 Art. 13), as a deliberate, justified exception to citizenship's "authority-only, no self-burn" rule — confirm, or require authority confirmation even for self-initiated renunciation.
3. (Already resolved, not actually open) Trust-anchor for both 法務省 and 外務省 reuses the existing `.go.jp` mechanism — no new design needed.
4. Passport renewal is modeled as **burn-and-reissue** (not an on-chain expiry field), consistent with the credentials-wide decision to put zero fields on any credential NFT — confirm this is acceptable.
5. Should minting a Passport NFT require an **on-chain check** that the applicant already holds a valid Nationality NFT (reusing the `everIssued`/`balanceOf` cross-contract pattern), or is relying on 外務省's existing **off-chain** verification (戸籍 documents) sufficient, with no on-chain dependency between the two contracts? — confirm a preference, or state either is fine to decide at implementation time.

## Current phase

**Phase 1 (continued) — Designing state functions; implementation deliberately deferred.** Repository scaffold is in place (Phase 0 complete). Three state functions are fully resolved and specified: citizenship/residency (resident-link NFT, [ADR 0003](decisions/0003-resident-link-identity-model.md)), taxation/payment rail ([ADR 0004](decisions/0004-taxation-payment-rail.md)), and corporations/registration ([ADR 0005](decisions/0005-corporate-registration-model.md)). See [`docs/FEATURES.md`](FEATURES.md) for the full, up-to-date progress table, and [`docs/BACKLOG.md`](BACKLOG.md) for items deferred out of those designs.

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
- Standing guidance: current-law feasibility (e.g., "does a municipality have legal authority to do X") is not raised as a discussion point in this project — it's an explicit thought experiment, not aimed at real-world legal adoption.

## Open questions

- Which mainnet chain to launch on (Ethereum mainnet vs. Polkadot Hub mainnet) — deferred until testing phase provides more signal.
- Which real-world state functions to design after citizenship, taxation, and corporations (e.g., legislative process, executive/administration, judiciary, treasury/spending) — not yet scoped. See [`docs/BACKLOG.md`](BACKLOG.md) for specific deferred items already identified (financial-product tokenization, employer-withholding abolition, the audited multisig standard to use, beneficial-ownership transparency, etc.).
- Governance model for the project itself (who can propose/approve changes to the "constitution" of the contracts).
- Whether any part of the system requires off-chain components beyond the frontend (e.g., indexing, notifications) — not yet needed, revisit when a concrete feature requires it (YAGNI).
- CI/CD setup (tests, linting, deployment pipeline) — not yet set up; add when there is code to verify.

## Next steps

1. Continue designing the remaining initially-planned state functions (see [`docs/FEATURES.md`](FEATURES.md)) the same way citizenship/residency was designed: raise issues, discuss with the user, record in a discussion log, write an ADR + spec.
2. Once all of those are specified, review them together for cross-feature consistency (e.g., does anything in the citizenship design conflict with how treasury, voting, etc. end up needing to reference residents?) before writing any Solidity.
3. Only after that review: `contracts/` (Foundry init) and implementation, starting with `ResidentLink`.

---

# プロジェクトの現状(日本語)

> 生きたドキュメントです。プロジェクトのフェーズが進んだとき、大きな論点が解決したとき、新たな論点が生まれたときに更新してください。詳細はADRやアーキテクチャドキュメントに記載し、ここはスナップショットとして簡潔に保ちます。

**最終更新日:** 2026-10-03

## ⏸ 中断中 — 再開ポイント

**パスポート・国籍クレデンシャル**([公的証明](state-design/credentials/)パターンの最初の具体例 — [`docs/state-design/credentials/passport/discussion-log.md`](state-design/credentials/passport/discussion-log.md) のRound 1参照)の議論の途中で作業を中断しています。

**ユーザーが「再開して」と言ったら、以下の5つの論点をそのまま再提示し、そこから議論を続けること。先に別の話題を始めないこと:**

1. 「国籍」(永続的、法務省発行)と「パスポート」(更新可能な渡航文書、外務省発行、取得には有効な国籍クレデンシャルの保有が必要)を、ライフサイクルが異なるため2つの別のクレデンシャルに分ける — この分割でよいか、それとも1つに統合したいか確認。
2. 国籍クレデンシャルに限り、**本人による自主バーン**を認める(国籍法13条の国籍離脱という実在の権利を反映)。国民・住民設計の「発行主体のみ、自主バーンなし」というルールへの、正当な例外として — この方針でよいか、それとも自主的な離脱でも発行主体の確認を必要とするか確認。
3. (実質的に解決済み、未解決ではない)法務省・外務省とも、既存の`.go.jp`の仕組みをそのまま流用でき、新しい設計は不要。
4. パスポートの更新は、(全ての証明NFTにフィールドを一切持たせないという横断的な決定を踏まえ)オンチェーンの有効期限フィールドではなく**burnして再発行する**形でモデル化する — これでよいか確認。
5. パスポートNFTの発行時、申請者が既に有効な国籍NFTを保有していることを**オンチェーンで確認する**(国民・住民・納税のeverIssued/balanceOfパターンを再利用)べきか、それとも外務省の既存の**オフチェーンの確認**(戸籍書類)で十分で、2つのコントラクト間にオンチェーンの依存関係を持たせないべきか — お好みを確認、またはどちらでもよく実装時に決めてよいと伝える。

## 現在のフェーズ

**フェーズ1(継続中)— 国家機能の設計を継続。実装は意図的に延期。** リポジトリの足場固め(フェーズ0)は完了。国民・住民(住民登録リンクNFT、[ADR 0003](decisions/0003-resident-link-identity-model.md))、納税(決済レール、[ADR 0004](decisions/0004-taxation-payment-rail.md))、法人(登録、[ADR 0005](decisions/0005-corporate-registration-model.md))の3機能が議論を経て確定済みです。全機能の最新進捗は [`docs/FEATURES.md`](FEATURES.md)、これらの設計から先送りされた項目は [`docs/BACKLOG.md`](BACKLOG.md) を参照してください。

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
- 恒常的な方針: 「市区町村にそれを行う法的権限があるか」のような現行法上の実現可能性は、このプロジェクトでは議論の対象としない — これは実社会への法制度化を目指すものではない、明示的な思考実験であるため。

## 未解決の論点

- メインネットでどのチェーンを採用するか(Ethereum mainnet vs. Polkadot Hub mainnet) — テスト段階でより多くの知見を得てから決定。
- citizenship・taxation・法人の後にどの国家機能を設計するか(立法プロセス、行政、司法、財務/歳出など) — 未着手。既に特定済みの先送り項目(金融商品のトークン化、源泉徴収の廃止、法人用監査済みマルチシグの選定、実質的支配者の透明性など)は [`docs/BACKLOG.md`](BACKLOG.md) を参照。
- プロジェクト自体のガバナンスモデル(コントラクトの「憲法」部分の変更を誰が提案・承認できるか)。
- フロントエンド以外のオフチェーンコンポーネント(インデクシング、通知等)が必要かどうか — 現時点では不要。具体的な機能要件が出てから検討(YAGNI)。
- CI/CD — コードが存在してから整備する。

## 次のステップ

1. 国民・住民と同じ進め方(論点の提起 → ユーザーとの議論 → 議論ログに記録 → ADR＋設計書の作成)で、残りの当初想定している国家機能の設計を続ける([`docs/FEATURES.md`](FEATURES.md) 参照)。
2. それらの設計が出揃った段階で、Solidityを書く前に機能間の整合性(例: 国民・住民の設計が、財務・投票などが住民を参照する際の要件と矛盾しないか)を全体でレビューする。
3. そのレビューの後に初めて `contracts/`(Foundry init)と実装(`ResidentLink`から)に着手する。

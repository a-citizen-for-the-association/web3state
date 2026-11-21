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
- `docs/state-design/credentials/`: opened the general "credentials" feature (diplomas, passports, licenses, employee IDs, health-insurance and vaccination certificates, etc.) — cross-cutting rules agreed: NFTs prove possession only (no on-chain fields), trust-anchor and sub-type granularity decided per credential type. Full reasoning in `discussion-log.md`.
- `docs/state-design/credentials/passport/`: completed design spec for the passport credential — a pure travel-document NFT issued by 外務省; no on-chain nationality credential was built (nationality verified entirely off-chain, same pattern as `ResidentLink`'s identity check). Full reasoning in `discussion-log.md`.
- `docs/decisions/0006-passport-credential.md`: ADR for the passport credential decisions.
- `docs/state-design/credentials/diploma/`: completed design spec for the diploma/graduation-certificate credential — issued from a school's existing corporate-registration address (schools treated as a specially-regulated corporation category, no new `.ac.jp`/`.ed.jp` mechanism); requires the recipient to hold a `ResidentLink` NFT at mint time (one-time, on-chain, nationality-neutral check); simplest lifecycle so far (mint-once, rare-burn only). Full reasoning in `discussion-log.md`.
- `docs/decisions/0007-diploma-credential.md`: ADR for the diploma credential decisions.
- `docs/state-design/credentials/license/`: completed design spec for the driver's-license credential — a single contract per prefecture (no per-vehicle-class split, unlike diploma); suspension and revocation both represented identically on-chain as burn, with the real-world distinction kept off-chain; requires the recipient to hold a `ResidentLink` NFT at mint time, same pattern as diploma. Full reasoning in `discussion-log.md`.
- `docs/decisions/0008-license-credential.md`: ADR for the license credential decisions.
- `docs/state-design/credentials/health-insurance/`: completed design spec for the public health-insurance credential — one contract per insurer; every insurer type (municipality, prefectural 広域連合, 協会けんぽ, 組合健保, 共済組合) maps onto an already-established trust mechanism; continuous (non-expiring) lifecycle unlike passport/license; requires `ResidentLink` at mint; no special handling for dependents. Full reasoning in `discussion-log.md`.
- `docs/decisions/0009-health-insurance-credential.md`: ADR for the health-insurance credential decisions.
- `docs/state-design/credentials/employee-id/`: completed design spec for the employee ID credential — issued from any registered corporation's existing corporate-registration address (sole proprietors cannot issue it); one contract per company; continuous lifecycle like health insurance; no `ResidentLink` precondition (the first since passport, since employment isn't inherently tied to Japanese residency). Full reasoning in `discussion-log.md`.
- `docs/decisions/0010-employee-id-credential.md`: ADR for the employee ID credential decisions.
- `docs/state-design/credentials/vaccination/`: completed design spec for the vaccination credential — a municipality-issued, soulbound vaccination coupon with a genuine on-chain status field (`Issued`/`Vaccinated`), the second credential (after corporations) needing real mutable state; a hospital holding a `VACCINATOR_ROLE` (granted only to addresses holding a valid corporate/医療法人 registration, checked on-chain) marks coupons vaccinated, not the issuing municipality; multiple doses are multiple separate coupons; `Vaccinated` coupons are never burned. Completes the originally-listed set of six credential examples. Full reasoning in `discussion-log.md`.
- `docs/decisions/0011-vaccination-credential.md`: ADR for the vaccination credential decisions.
- `docs/decisions/0012-onchain-scope-philosophy.md`: ADR recording the project's broader on-chain scope philosophy — ~20 new candidate systems across 8 categories (political transparency, social welfare, public-interest finance, property/vital records, corporate/market transparency, judicial infrastructure, commerce/markets, governance core), everyday commerce in-scope for tax transparency, wealth-focused financial services carved out to provider-handled compliance, and high-frequency trading / personal wealth-accumulation investment explicitly excluded (not silently omitted).
- Root `README.md`: added a prominent "System Roadmap" table (English + Japanese) embedding a condensed copy of `docs/FEATURES.md` directly in the README, per the user's request for maximum visibility — not merely linked.
- `docs/state-design/legislative/` and `docs/decisions/0014-legislative-process-scope.md`: scoped the legislative process out (🚫), carving out direct-demand petition signatures as their own item; adopted the reusable on-chain value test.
- `docs/state-design/political-donations/` and `docs/decisions/0015-political-donations-model.md`: completed design spec for political donations — receiving-side `PoliticalFund` contracts, traceable donors without on-chain names, and a 総務省-operated `OfficialContractRegistry`.
- `docs/state-design/direct-demand/` and `docs/decisions/0016-direct-demand-petition-model.md`: completed design spec for direct-demand petition signatures — one `Petition` contract per demand, explicit per-petition eligible list, full-text hash, fixed threshold, public self-signed signatures with no collectors, count certification only.
- `docs/state-design/executive/` and `docs/decisions/0017-executive-document-anchoring-v1.md`: executive screened with the on-chain value test; minimal v1 spec — mandatory title-and-hash registration of approval documents in a per-agency append-only `DocumentRegistry`. Also records the workflow change to design → implement → scenario test → redesign.
- `docs/state-design/judiciary/` and `docs/decisions/0018-judiciary-model.md`: judiciary spec — `EvidenceRegistry` (evidence registered at seizure), `CaseRecordRegistry` (retention classes, guarded disposal, judgments), enforcement by court-ordered address disclosure; token-juror arbitration excluded.
- `docs/state-design/treasury/` and `docs/decisions/0019-treasury-model.md`: treasury spec — per-body `PublicTreasury`, identified payees, budget codes as tags, public `OffChainExit`; adopts the "off-chain if it can be" principle.
- `docs/state-design/certified-stablecoin/` and `docs/decisions/0020-certified-address-stablecoin.md`: project-wide certified-address JPY stablecoin rule, successor migration, visitor pass.
- `docs/state-design/vip-asset-disclosure/` and `docs/decisions/0021-vip-asset-disclosure.md`: VIP asset disclosure without a new contract.
- `docs/state-design/procurement/` and `docs/decisions/0022-procurement-model.md`: procurement spec — commit–reveal sealed bidding, committed ceiling price, all bids public, contracts and change contracts on one record.
- `docs/state-design/subsidies/` and `docs/decisions/0023-subsidies-model.md`: subsidies spec — no new contract; on-chain transactions replace receipts.

### Changed
- `docs/PROJECT_STATUS.md`: recorded the explicit workflow decision that implementation (`contracts/` Foundry init, Solidity) is deferred until all initially-planned state functions are designed and reviewed together for cross-feature consistency — not started per-feature as each design finishes.
- `docs/FEATURES.md`: removed the stale "Municipality registry" row (decided against in ADR 0003; tracked in `docs/BACKLOG.md` instead).
- `docs/BACKLOG.md`: closed the original "nationality/passport credential" row (passport now designed); added a new row for whether nationality/residence-status should ever be managed on-chain, deferred to a future "foreign residents" topic.
- `docs/PROJECT_STATUS.md`: removed the "paused / resume point" section (resolved) and updated to reflect the passport credential's completion.
- `docs/PROJECT_STATUS.md`: added, then removed (resolved), a "paused / resume point" section covering the gap between the license and health-insurance credentials.
- `docs/FEATURES.md`: restructured with a new `Category` column and a new `🚫 Deliberately excluded` status; added ~20 new 🔴 candidate rows from the scope-expansion discussion; removed a stale duplicate "Vaccination credential — Not started" row left over from before vaccination was designed.
- `docs/FEATURES.md`, root `README.md`: Voting status updated from 🟡 Discussing to 🟢 Spec drafted now that all six design issues are resolved.
- `docs/PROJECT_STATUS.md`: updated to reflect voting's completion (ten state functions now fully specified) and removed voting-specific next-step language now that it's done.
- `docs/state-design/voting/discussion-log.md`, `README.md`, `docs/FEATURES.md`, `docs/PROJECT_STATUS.md`: resolved voting's foundational privacy/anonymity question (Issue 1) — vote content protected by a Helios-style scheme (homomorphic encryption + zero-knowledge proof of correct tally + threshold decryption across multiple trustees); vote participation uses the resident's existing `ResidentLink` address rather than a fresh per-election address, to avoid creating a new off-chain identity↔disposable-address mapping at the municipality. Full reasoning in `discussion-log.md` Round 2.
- `docs/state-design/voting/`: completed the full design spec for voting — one generic election primitive (closed option list + one-hot encrypted ballots + homomorphic per-option summation + threshold decryption of only the final totals + a pluggable seat-allocation method) covering referendums, single-seat plurality, multi-seat single-non-transferable-vote elections, and party-list proportional representation (both binding and non-binding list variants); ranked-choice/single-transferable-vote and write-in candidates explicitly excluded. Voter eligibility verified off-chain by the election board plus an on-chain `ResidentLink` check; voting period is a deliberate exception to this project's general avoidance of on-chain dates. Full reasoning in `discussion-log.md` Round 3.
- `docs/decisions/0013-voting-model.md`: ADR for the voting design decisions.
- `docs/glossary.md`: added "Voting / Election" and "Threshold decryption" entries.
- `docs/BACKLOG.md`: added two voting-related deferred items — selecting the concrete audited cryptographic library/implementation and commissioning its security audit, and reducing the operational cost of per-voter eligibility grants at national-election scale.
- `docs/FEATURES.md`, root `README.md`: legislative process moved to 🚫 Excluded; new 🔴 row for direct-demand petition signatures; political donations set to 🟢 Spec drafted.
- `docs/decisions/0003`, `0014`: status lines annotated (registry point revisited / roll-call bullet superseded by ADR 0015).
- `docs/BACKLOG.md`: closed the on-chain municipality registry item (now `OfficialContractRegistry`); added disposition of a political organization's funds on dissolution.
- `docs/glossary.md`: added on-chain value test, political fund, and official contract registry.
- `docs/PROJECT_STATUS.md`: updated for ADR 0014/0015 and added a "paused / resume point" section before choosing the next system.
- `docs/FEATURES.md`, root `README.md`: direct-demand petition signatures set to 🟢 Spec drafted.
- `docs/glossary.md`: added direct demand. `docs/BACKLOG.md`: the large-list cost item now also covers petitions. `docs/state-design/legislative/README.md`: petition open items marked resolved.
- `docs/PROJECT_STATUS.md`: removed the paused/resume section; updated for ADR 0016; next steps set to executive, then judiciary (Governance Core top-down).
- `docs/FEATURES.md`, root `README.md`: executive set to 🟢 Spec drafted (minimal v1). `docs/BACKLOG.md`: added five executive items deferred to the redesign phase. `docs/PROJECT_STATUS.md`: workflow change recorded (the initial design still covers every listed item, corrected the same day); next step is judiciary.
- `docs/FEATURES.md`, root `README.md`: judiciary 🟢; public court records merged into judiciary (🟢); new 🚫 row for token-juror arbitration; everyday-commerce note on purchase escrow. `docs/BACKLOG.md`: case-record content preservation. `docs/PROJECT_STATUS.md`: Governance Core complete.
- `docs/PROJECT_STATUS.md`: added a "paused / resume point" section after the judiciary (confirm judiciary adjustments, then show the remaining list and let the user choose).
- `docs/state-design/judiciary/discussion-log.md`: Round 4 — user confirmed the four spec adjustments. `docs/PROJECT_STATUS.md`: resume point updated accordingly.
- `docs/FEATURES.md`, root `README.md`: treasury 🟢. `docs/glossary.md`: added public treasury. `docs/PROJECT_STATUS.md`: removed the resume point; recorded ADR 0019 and its principle.
- `docs/state-design/treasury/discussion-log.md`: Round 4 — user confirmed the spec adjustments. `docs/PROJECT_STATUS.md`: added a "paused / resume point" section after the treasury.
- `docs/FEATURES.md`, root `README.md`: new 🟢 row for the certified-address stablecoin; VIP asset disclosure 🟢. `docs/decisions/0004`, `0018`: status lines annotated for ADR 0020. `docs/glossary.md`: certified address, successor migration. `docs/BACKLOG.md`: three items from ADR 0020.
- `docs/FEATURES.md`, root `README.md`: new 🔴 item "Securities / shareholdings" (user intends to put securities on-chain). VIP disclosure: Round 5 recorded (shareholder-controlled corporations: declare for now, option (a)).
- `docs/BACKLOG.md`: design direction for securities (corporations as "glass boxes": traceable layered ownership, penalties for borrowed names). `docs/PROJECT_STATUS.md`: added a "paused / resume point" section.
- `docs/state-design/pension/discussion-log.md`: opened pension screening (Round 1). `docs/FEATURES.md`, root `README.md`: pension 🟡. `docs/PROJECT_STATUS.md`: removed the resume point; Social Welfare is next.
- `docs/state-design/pension/` and `docs/decisions/0024-pension-model.md`: pension spec — no new contract; the contribution transfer is the record; employees pay their whole premium.
- `docs/FEATURES.md`, root `README.md`: pension 🟢. `docs/PROJECT_STATUS.md` updated.
- `docs/state-design/pension/discussion-log.md`: Round 3 — adjustments confirmed.
- `docs/state-design/benefits/discussion-log.md`: opened benefits screening (Round 1). `docs/FEATURES.md`, root `README.md`: benefits 🟡.
- `docs/state-design/benefits/` and `docs/decisions/0025-benefits-model.md`: benefits spec — no new contract; one shared social-security budget code (ADR 0024 status note updated); consented income checks only. `docs/BACKLOG.md`: medical-claims system.
- `docs/FEATURES.md`, root `README.md`: benefits 🟢. `docs/PROJECT_STATUS.md` updated.
- `docs/state-design/benefits/discussion-log.md`: Round 3 — adjustments confirmed.
- `docs/state-design/unemployment-insurance/discussion-log.md`: opened unemployment-insurance screening (Round 1). `docs/FEATURES.md`, root `README.md`: unemployment insurance 🟡.
- `docs/state-design/unemployment-insurance/` and `docs/decisions/0026-unemployment-insurance-model.md`: unemployment-insurance spec — no new contract; working while receiving made visible. `docs/BACKLOG.md`: workers' accident compensation; the existing statistics row now also cites ADR 0026.
- `docs/FEATURES.md`, root `README.md`: unemployment insurance 🟢 (Social Welfare complete). `docs/PROJECT_STATUS.md` updated.
- `docs/decisions/0027-remaining-scope-triage.md`: remaining-scope triage — nine low-value items ⏸ on hold (new status, not blocking implementation); new item "personal data held by companies" (Data Protection). `docs/FEATURES.md`, root `README.md`, `docs/PROJECT_STATUS.md` updated. Unemployment-insurance adjustments accepted (Round 3).
- `docs/state-design/personal-data/discussion-log.md`: opened screening of personal data held by companies (Round 0: user's direction; Round 1). `docs/FEATURES.md`, root `README.md`: 🟡.
- `docs/state-design/personal-data/` and `docs/decisions/0028-personal-data-model.md`: personal-data spec — "don't hold it" law, age-threshold credentials, shared `AnchorRegistry`. `docs/FEATURES.md`, root `README.md`: 🟢; notarization row notes `AnchorRegistry`. `docs/PROJECT_STATUS.md` updated.
- `docs/state-design/personal-data/discussion-log.md`: Round 3 — adjustments accepted. `docs/PROJECT_STATUS.md`: added a "paused / resume point" section.
- `docs/state-design/real-estate/discussion-log.md`: opened screening of the real estate registry (Round 0: user chose it; Round 1). `docs/FEATURES.md`, root `README.md`: 🟡. `docs/PROJECT_STATUS.md`: resume point removed.
- `docs/state-design/real-estate/discussion-log.md`: Round 2 — tokenisation, off-chain dealings, owner + agent approval; remaining issues A–J.
- `docs/state-design/real-estate/discussion-log.md`: Round 3 — A–G and J accepted; migration (I) dropped (zero-based state); H explained.
- `docs/state-design/real-estate/` and `docs/decisions/0029-real-estate-registry-model.md`: real-estate spec — `RealEstateToken`, owner + agent transfers, no parcel on-chain, no foreign ownership, `NonResidentOwner`. `docs/FEATURES.md`, root `README.md`: 🟢. `docs/BACKLOG.md`: VIP row updated, two rows added. ADR 0020 status notes the new kind. `docs/PROJECT_STATUS.md` updated.
- `docs/state-design/real-estate/`: Round 5 — agents per token and public (adjustments 1–2 withdrawn); spec updated.
- `docs/state-design/real-estate/`: Round 6 — remaining adjustments accepted.
- `docs/state-design/securities/discussion-log.md`: opened screening of securities and shareholdings (Round 0; Round 1). `docs/FEATURES.md`, root `README.md`: 🟡.
- `docs/state-design/securities/discussion-log.md`: Round 2 — trading and matching on-chain; remaining issues A–E.
- `docs/state-design/securities/` and `docs/decisions/0030-securities-model.md`: Round 3 (user's proposal: exchanges off-chain, brokers record on-chain) and spec — `ShareRegistry`, daily net settlement via `ClearingContract`, daily execution anchors, beneficial-owner names, `ForeignInvestor`. `docs/FEATURES.md`, root `README.md`: 🟢. `docs/BACKLOG.md`: four rows closed, one added. ADRs 0005, 0020, 0021, 0029 status notes. `docs/PROJECT_STATUS.md`: initial design complete.
- `docs/state-design/securities/`: Round 4 — adjustments accepted.
- `docs/architecture/consistency-review.md`: cross-feature consistency review opened (five parallel reviews merged into issues R1–R6). `docs/PROJECT_STATUS.md` updated.
- `docs/PROJECT_STATUS.md`: roadmap after the review (provisional implementation, 10+ PoCs, PoC method, PoC results, paper).
- `docs/PROJECT_STATUS.md`: added a "paused / resume point" section (resume by showing the review results again).
- `docs/architecture/consistency-review.md`: R1.1–R1.6 accepted.
- `docs/decisions/0031-registered-address-transfer-rule.md`: transfer rule relaxed (one registered address per resident and corporation; cumulative cap on sending to unregistered addresses; zero for VIPs; the rest checked afterwards); supersedes ADR 0020's rule. Consistency review: R2.1, R2.2 accepted; decision D1 recorded; R2.3 to be re-examined.
- Consistency review under D1: R2.3 revised, R2.2 and R1.3 confirmed; visitor pass abolished and the exchanger exemption narrowed (ADR 0031 updated).
- Consistency review: R3.1–R3.10 accepted (suspension on key theft; heavy path for every asset token; credential re-issue on succession and burn on death; registrar-led heavy path; dissolution/merger order; signer rotation; ballot-time checks; mint-before-burn on moves; heirs' agents; age checks abroad).
- Consistency review: R4.1–R4.3 accepted (`DocumentRegistry` and `EvidenceRegistry` folded into `AnchorRegistry`; author anchors; kind list; naming and token-standard pass).
- Consistency review: R5.1–R5.9 decided (officers and beneficial owners accept name–address links; real-estate buyer exposure accepted for PoC study; order codes on delivery labels; monthly age-credential batches; standing voter credential; shared social-security code kept; optional VIP address switch). R1–R5 complete; R6 open.
- `docs/FEATURES.md`, root `README.md`: procurement 🟢. `docs/PROJECT_STATUS.md`: next is subsidies.
- `docs/FEATURES.md`, root `README.md`: subsidies 🟢 (Political Transparency complete). `docs/PROJECT_STATUS.md` updated.
- `docs/state-design/subsidies/discussion-log.md`: Round 3 — adjustments confirmed. `docs/PROJECT_STATUS.md`: added a "paused / resume point" section.
- R6 done (Japanese translations of ADRs 0001–0013, template, citizenship log, feature template and CHANGELOG; stale status text; back-references; backlog tidy-up). `docs/decisions/0032-consistency-review-decisions.md` records all review decisions; affected ADRs carry status notes; affected specs, `docs/FEATURES.md` and the glossary rewritten to match.
- Consistency review follow-ups: F1 (standing voter credential withdrawn; eligibility per election and per petition), F2–F3 dissolved, F4–F5 accepted, gaps filled. Review complete. `docs/PROJECT_STATUS.md`: resume point updated (next: provisional implementation).

---

# 変更履歴(日本語)

本プロジェクトの主要な変更はすべてこのファイルに記録する。

形式は[Keep a Changelog](https://keepachangelog.com/en/1.1.0/)に準拠する。
本プロジェクトはまだリリース/バージョン番号の体系を採用していない(リリース実績なし)。最初のタグ付きリリースまでは、項目を日付単位でまとめる。

変更の*内容*だけでなく*理由*については[`docs/decisions/`](docs/decisions/)を参照。

## [未リリース]

### 追加
- リポジトリの初期骨格: ディレクトリ構成、README、ドキュメント構成(`docs/`)、コントラクトのプレースホルダ(Foundry)、フロントエンドのプレースホルダ(Next.js)。
- `docs/decisions/0001-record-architecture-decisions.md`および`0002-initial-stack-and-structure.md`。
- MITライセンス。
- `docs/FEATURES.md`: 計画中の全国家機能の進捗を一覧できる表。
- `docs/state-design/citizenship/`: 国民・住民機能の設計仕様を完成 — 市区町村が発行する、譲渡不可で国籍中立な「resident-link」NFT。詳細な議論は`discussion-log.md`。
- `docs/decisions/0003-resident-link-identity-model.md`: 国民・住民の本人性モデルのADR。
- `docs/state-design/citizenship/README.md`に日本語訳を追加。
- `docs/state-design/taxation/`: 納税の支払いレール機能の設計仕様を完成 — 個人の直接税の納付のみ、専用スマートコントラクトなし、国民・住民設計の公式アドレス認証の仕組みを拡張。詳細な議論は`discussion-log.md`。
- `docs/decisions/0004-taxation-payment-rail.md`: 納税の支払いレールに関する決定のADR。
- `docs/BACKLOG.md`: 機能横断の保留項目一覧(金融商品のトークン化、源泉徴収の廃止、国レベルの`.go.jp`認証の実装など)。
- `docs/state-design/corporations/`: 法人登記機能の設計仕様を完成 — 当局が発行する、譲渡不可のオンチェーン登記NFT。役員・代表者の氏名はオンチェーンで公開、住所は一切オンチェーンに載せない。法人自身のアドレスは役員の個人鍵で署名するマルチシグコントラクト。詳細な議論は`discussion-log.md`。
- `docs/decisions/0005-corporate-registration-model.md`: 法人登記モデルのADR。
- `docs/state-design/credentials/`: 汎用「クレデンシャル」機能(卒業証書、旅券、免許、社員証、健康保険証、予防接種証明など)を開始 — 横断ルールで合意: NFTは保有の証明のみ(オンチェーンのフィールドなし)、トラストアンカーとサブタイプの粒度はクレデンシャル種別ごとに決定。詳細な議論は`discussion-log.md`。
- `docs/state-design/credentials/passport/`: 旅券クレデンシャルの設計仕様を完成 — 外務省が発行する純粋な渡航文書NFT。国籍のオンチェーンクレデンシャルは作らない(国籍は完全にオフチェーンで確認、`ResidentLink`の本人確認と同じパターン)。詳細な議論は`discussion-log.md`。
- `docs/decisions/0006-passport-credential.md`: 旅券クレデンシャルに関する決定のADR。
- `docs/state-design/credentials/diploma/`: 卒業証書・卒業証明書クレデンシャルの設計仕様を完成 — 学校の既存の法人登記アドレスから発行(学校は特別に規制される法人カテゴリとして扱い、新たな`.ac.jp`/`.ed.jp`の仕組みは設けない)。発行時に受領者が`ResidentLink` NFTを保有していることを要件とする(一度きり、オンチェーン、国籍中立の確認)。これまでで最も単純なライフサイクル(発行は一度、バーンはまれ)。詳細な議論は`discussion-log.md`。
- `docs/decisions/0007-diploma-credential.md`: 卒業証書クレデンシャルに関する決定のADR。
- `docs/state-design/credentials/license/`: 運転免許クレデンシャルの設計仕様を完成 — 都道府県ごとに単一のコントラクト(卒業証書と異なり車種区分ごとの分割なし)。停止と取消はオンチェーンではどちらも同じくバーンとして表し、現実の区別はオフチェーンに保持。卒業証書と同じく、発行時に受領者の`ResidentLink` NFT保有を要件とする。詳細な議論は`discussion-log.md`。
- `docs/decisions/0008-license-credential.md`: 免許クレデンシャルに関する決定のADR。
- `docs/state-design/credentials/health-insurance/`: 公的健康保険クレデンシャルの設計仕様を完成 — 保険者ごとに一つのコントラクト。すべての保険者種別(市区町村、都道府県の広域連合、協会けんぽ、組合健保、共済組合)が既存の信頼の仕組みに対応。旅券・免許と異なり継続的(期限なし)なライフサイクル。発行時に`ResidentLink`を要件とする。被扶養者の特別扱いなし。詳細な議論は`discussion-log.md`。
- `docs/decisions/0009-health-insurance-credential.md`: 健康保険クレデンシャルに関する決定のADR。
- `docs/state-design/credentials/employee-id/`: 社員証クレデンシャルの設計仕様を完成 — 登記済みの任意の法人の既存の法人登記アドレスから発行(個人事業主は発行不可)。会社ごとに一つのコントラクト。健康保険と同じく継続的なライフサイクル。`ResidentLink`の前提条件なし(雇用は本質的に日本の住民であることと結びつかないため。旅券以来初)。詳細な議論は`discussion-log.md`。
- `docs/decisions/0010-employee-id-credential.md`: 社員証クレデンシャルに関する決定のADR。
- `docs/state-design/credentials/vaccination/`: 予防接種クレデンシャルの設計仕様を完成 — 市区町村が発行する譲渡不可の接種券で、真のオンチェーン状態フィールド(`Issued`/`Vaccinated`)を持つ。実際に可変な状態を要する二つ目のクレデンシャル(法人に次ぐ)。接種券を接種済みにするのは発行元の市区町村ではなく、`VACCINATOR_ROLE`を持つ病院(有効な法人/医療法人登記を持つアドレスにのみ付与、オンチェーンで確認)。複数回接種は別々の複数の接種券。`Vaccinated`の接種券はバーンしない。当初挙げた6つのクレデンシャル例がこれで完了。詳細な議論は`discussion-log.md`。
- `docs/decisions/0011-vaccination-credential.md`: 予防接種クレデンシャルに関する決定のADR。
- `docs/decisions/0012-onchain-scope-philosophy.md`: プロジェクトのより広いオンチェーン範囲の方針を記録したADR — 8カテゴリ(政治の透明性、社会福祉、公益金融、財産・身分記録、企業・市場の透明性、司法基盤、商取引・市場、統治の中核)にわたる約20の新候補システム、税の透明性のため日常の商取引を範囲内とすること、富裕層向け金融サービスは事業者側のコンプライアンスに切り出すこと、高頻度取引・個人の資産形成投資を明示的に除外すること(黙って省くのではなく)。
- ルートの`README.md`: 目立つ「System Roadmap」表(英語+日本語)を追加し、`docs/FEATURES.md`の要約版をREADMEに直接埋め込み — 最大限の視認性を求めるユーザーの要望による(リンクのみではなく)。
- `docs/state-design/legislative/`および`docs/decisions/0014-legislative-process-scope.md`: 立法過程を範囲外(🚫)とし、直接請求の署名を独立項目として切り出し。再利用可能なオンチェーン価値テストを採用。
- `docs/state-design/political-donations/`および`docs/decisions/0015-political-donations-model.md`: 政治献金の設計仕様を完成 — 受取側の`PoliticalFund`コントラクト、氏名をオンチェーンに載せずに追跡可能な献金者、総務省が運営する`OfficialContractRegistry`。
- `docs/state-design/direct-demand/`および`docs/decisions/0016-direct-demand-petition-model.md`: 直接請求の署名の設計仕様を完成 — 請求ごとに一つの`Petition`コントラクト、請求ごとの明示的な有資格者リスト、全文のハッシュ、固定の閾値、収集者なしの公開の自署、件数の認証のみ。
- `docs/state-design/executive/`および`docs/decisions/0017-executive-document-anchoring-v1.md`: 行政をオンチェーン価値テストで選別。最小v1仕様 — 決裁文書の表題とハッシュを機関ごとの追記専用`DocumentRegistry`に登録することを義務化。設計 → 実装 → シナリオテスト → 再設計というワークフロー変更も記録。
- `docs/state-design/judiciary/`および`docs/decisions/0018-judiciary-model.md`: 司法の仕様 — `EvidenceRegistry`(押収時に証拠を登録)、`CaseRecordRegistry`(保存区分、保護された廃棄、判決)、裁判所命令によるアドレス開示での執行。トークン陪審員による仲裁は除外。
- `docs/state-design/treasury/`および`docs/decisions/0019-treasury-model.md`: 国庫の仕様 — 団体ごとの`PublicTreasury`、特定された支払先、タグとしての予算コード、公開の`OffChainExit`。「オフチェーンにできるならオフチェーン」原則を採用。
- `docs/state-design/certified-stablecoin/`および`docs/decisions/0020-certified-address-stablecoin.md`: プロジェクト全体の認定アドレスJPYステーブルコインのルール、承継移行、訪問者パス。
- `docs/state-design/vip-asset-disclosure/`および`docs/decisions/0021-vip-asset-disclosure.md`: 新規コントラクトなしのVIP資産公開。
- `docs/state-design/procurement/`および`docs/decisions/0022-procurement-model.md`: 調達の仕様 — コミット–リビール方式の封印入札、予定価格のコミット、全入札の公開、契約と変更契約を一つの記録に。
- `docs/state-design/subsidies/`および`docs/decisions/0023-subsidies-model.md`: 補助金の仕様 — 新規コントラクトなし。オンチェーン取引が領収書を代替。

### 変更
- `docs/PROJECT_STATUS.md`: 実装(`contracts/`のFoundry初期化、Solidity)は、当初計画した全国家機能を設計し、機能横断の整合性のためにまとめてレビューするまで延期する、という明示的なワークフロー決定を記録 — 各設計の完了ごとに機能単位で開始はしない。
- `docs/FEATURES.md`: 古い「Municipality registry」行を削除(ADR 0003で不採用と決定、代わりに`docs/BACKLOG.md`で管理)。
- `docs/BACKLOG.md`: 当初の「国籍/旅券クレデンシャル」行をクローズ(旅券は設計済み)。国籍・在留資格をそもそもオンチェーンで管理すべきかの新しい行を追加し、将来の「外国人住民」トピックへ延期。
- `docs/PROJECT_STATUS.md`: 「中断/再開ポイント」節を削除(解決済み)し、旅券クレデンシャルの完了を反映。
- `docs/PROJECT_STATUS.md`: 免許と健康保険クレデンシャルの間の空白を扱う「中断/再開ポイント」節を追加し、その後削除(解決済み)。
- `docs/FEATURES.md`: 新たな`Category`列と新ステータス`🚫 Deliberately excluded`で再構成。範囲拡張の議論から約20の新しい🔴候補行を追加。予防接種の設計前から残っていた古い重複行「Vaccination credential — Not started」を削除。
- `docs/FEATURES.md`、ルートの`README.md`: 6つの設計論点がすべて解決したため、投票のステータスを🟡 Discussingから🟢 Spec draftedに更新。
- `docs/PROJECT_STATUS.md`: 投票の完了を反映(10の国家機能の仕様が完成)。完了に伴い投票固有の次ステップの記述を削除。
- `docs/state-design/voting/discussion-log.md`、`README.md`、`docs/FEATURES.md`、`docs/PROJECT_STATUS.md`: 投票の根本的なプライバシー/匿名性の問題(Issue 1)を解決 — 投票内容はHelios型の方式(準同型暗号+正しい集計のゼロ知識証明+複数の管理者による閾値復号)で保護。投票への参加には選挙ごとの新規アドレスではなく住民の既存の`ResidentLink`アドレスを使い、市区町村に本人↔使い捨てアドレスの新たなオフチェーン対応表が生じるのを回避。詳細な議論は`discussion-log.md`のRound 2。
- `docs/state-design/voting/`: 投票の設計仕様全体を完成 — 一つの汎用選挙プリミティブ(閉じた選択肢リスト+one-hot暗号化投票+選択肢ごとの準同型加算+最終合計のみの閾値復号+差し替え可能な議席配分方式)で、住民投票、単記の小選挙区多数決、複数議席の単記非移譲式選挙、政党名簿式比例代表(拘束・非拘束名簿の両方)をカバー。順位付け投票/単記移譲式と記名候補(write-in)は明示的に除外。有権者資格は選挙管理委員会がオフチェーンで確認し、加えてオンチェーンで`ResidentLink`を確認。投票期間は、オンチェーンで日付を扱うことを原則避ける本プロジェクトの意図的な例外。詳細な議論は`discussion-log.md`のRound 3。
- `docs/decisions/0013-voting-model.md`: 投票の設計決定のADR。
- `docs/glossary.md`: 「Voting / Election」と「Threshold decryption」の項目を追加。
- `docs/BACKLOG.md`: 投票関連の保留項目を2つ追加 — 監査済みの具体的な暗号ライブラリ/実装の選定とそのセキュリティ監査の委託、国政選挙規模での有権者ごとの資格付与の運用コスト削減。
- `docs/FEATURES.md`、ルートの`README.md`: 立法過程を🚫 Excludedへ移動。直接請求の署名の新しい🔴行。政治献金を🟢 Spec draftedに。
- `docs/decisions/0003`、`0014`: ステータス行に注記(レジストリの論点を再検討/記名投票の項目はADR 0015で置き換え)。
- `docs/BACKLOG.md`: オンチェーンの市区町村レジストリ項目をクローズ(現在は`OfficialContractRegistry`)。政治団体の解散時の資金の処分を追加。
- `docs/glossary.md`: オンチェーン価値テスト、政治資金、公式コントラクトレジストリを追加。
- `docs/PROJECT_STATUS.md`: ADR 0014/0015に合わせて更新し、次のシステムを選ぶ前の「中断/再開ポイント」節を追加。
- `docs/FEATURES.md`、ルートの`README.md`: 直接請求の署名を🟢 Spec draftedに。
- `docs/glossary.md`: 直接請求を追加。`docs/BACKLOG.md`: 大規模リストのコスト項目の対象に請求も追加。`docs/state-design/legislative/README.md`: 請求に関する未決項目を解決済みと記載。
- `docs/PROJECT_STATUS.md`: 中断/再開節を削除。ADR 0016に合わせて更新。次ステップを行政、次いで司法に設定(統治の中核をトップダウンで)。
- `docs/FEATURES.md`、ルートの`README.md`: 行政を🟢 Spec drafted(最小v1)に。`docs/BACKLOG.md`: 再設計フェーズに延期する行政の5項目を追加。`docs/PROJECT_STATUS.md`: ワークフロー変更を記録(初期設計は引き続き全掲載項目を対象とする。同日に訂正)。次ステップは司法。
- `docs/FEATURES.md`、ルートの`README.md`: 司法🟢。公開裁判記録を司法に統合(🟢)。トークン陪審員による仲裁の新しい🚫行。購入エスクローに関する日常の商取引の注記。`docs/BACKLOG.md`: 事件記録の内容の保存。`docs/PROJECT_STATUS.md`: 統治の中核が完了。
- `docs/PROJECT_STATUS.md`: 司法の後に「中断/再開ポイント」節を追加(司法の調整を確認し、残りの一覧を示してユーザーに選んでもらう)。
- `docs/state-design/judiciary/discussion-log.md`: Round 4 — ユーザーが仕様の4つの調整を確認。`docs/PROJECT_STATUS.md`: 再開ポイントをそれに合わせて更新。
- `docs/FEATURES.md`、ルートの`README.md`: 国庫🟢。`docs/glossary.md`: 公的国庫を追加。`docs/PROJECT_STATUS.md`: 再開ポイントを削除。ADR 0019とその原則を記録。
- `docs/state-design/treasury/discussion-log.md`: Round 4 — ユーザーが仕様の調整を確認。`docs/PROJECT_STATUS.md`: 国庫の後に「中断/再開ポイント」節を追加。
- `docs/FEATURES.md`、ルートの`README.md`: 認定アドレスのステーブルコインの新しい🟢行。VIP資産公開🟢。`docs/decisions/0004`、`0018`: ADR 0020に合わせてステータス行に注記。`docs/glossary.md`: 認定アドレス、承継移行。`docs/BACKLOG.md`: ADR 0020由来の3項目。
- `docs/FEATURES.md`、ルートの`README.md`: 新しい🔴項目「Securities / shareholdings」(ユーザーは有価証券をオンチェーンに載せる意向)。VIP公開: Round 5を記録(株主が支配する法人: 当面は申告、選択肢(a))。
- `docs/BACKLOG.md`: 有価証券の設計方針(法人を「ガラス張り」に: 階層的な所有を追跡可能にし、名義借りに罰則)。`docs/PROJECT_STATUS.md`: 「中断/再開ポイント」節を追加。
- `docs/state-design/pension/discussion-log.md`: 年金の選別を開始(Round 1)。`docs/FEATURES.md`、ルートの`README.md`: 年金🟡。`docs/PROJECT_STATUS.md`: 再開ポイントを削除。次は社会福祉。
- `docs/state-design/pension/`および`docs/decisions/0024-pension-model.md`: 年金の仕様 — 新規コントラクトなし。保険料の送金そのものが記録。被用者が保険料の全額を負担。
- `docs/FEATURES.md`、ルートの`README.md`: 年金🟢。`docs/PROJECT_STATUS.md`を更新。
- `docs/state-design/pension/discussion-log.md`: Round 3 — 調整を確認。
- `docs/state-design/benefits/discussion-log.md`: 給付の選別を開始(Round 1)。`docs/FEATURES.md`、ルートの`README.md`: 給付🟡。
- `docs/state-design/benefits/`および`docs/decisions/0025-benefits-model.md`: 給付の仕様 — 新規コントラクトなし。社会保障の共通予算コードを一つ(ADR 0024のステータス注記を更新)。所得確認は同意に基づくもののみ。`docs/BACKLOG.md`: 医療費請求システム。
- `docs/FEATURES.md`、ルートの`README.md`: 給付🟢。`docs/PROJECT_STATUS.md`を更新。
- `docs/state-design/benefits/discussion-log.md`: Round 3 — 調整を確認。
- `docs/state-design/unemployment-insurance/discussion-log.md`: 雇用保険の選別を開始(Round 1)。`docs/FEATURES.md`、ルートの`README.md`: 雇用保険🟡。
- `docs/state-design/unemployment-insurance/`および`docs/decisions/0026-unemployment-insurance-model.md`: 雇用保険の仕様 — 新規コントラクトなし。受給中の就労を可視化。`docs/BACKLOG.md`: 労災補償。既存の統計の行がADR 0026も参照。
- `docs/FEATURES.md`、ルートの`README.md`: 雇用保険🟢(社会福祉が完了)。`docs/PROJECT_STATUS.md`を更新。
- `docs/decisions/0027-remaining-scope-triage.md`: 残りの範囲のトリアージ — 価値の低い9項目を⏸保留(新ステータス、実装を妨げない)。新項目「企業が保有する個人データ」(データ保護)。`docs/FEATURES.md`、ルートの`README.md`、`docs/PROJECT_STATUS.md`を更新。雇用保険の調整を承認(Round 3)。
- `docs/state-design/personal-data/discussion-log.md`: 企業が保有する個人データの選別を開始(Round 0: ユーザーの方針、Round 1)。`docs/FEATURES.md`、ルートの`README.md`: 🟡。
- `docs/state-design/personal-data/`および`docs/decisions/0028-personal-data-model.md`: 個人データの仕様 — 「保有するな」という法、年齢閾値クレデンシャル、共有の`AnchorRegistry`。`docs/FEATURES.md`、ルートの`README.md`: 🟢。公証の行に`AnchorRegistry`を注記。`docs/PROJECT_STATUS.md`を更新。
- `docs/state-design/personal-data/discussion-log.md`: Round 3 — 調整を承認。`docs/PROJECT_STATUS.md`: 「中断/再開ポイント」節を追加。
- `docs/state-design/real-estate/discussion-log.md`: 不動産登記の選別を開始(Round 0: ユーザーが選択、Round 1)。`docs/FEATURES.md`、ルートの`README.md`: 🟡。`docs/PROJECT_STATUS.md`: 再開ポイントを削除。
- `docs/state-design/real-estate/discussion-log.md`: Round 2 — トークン化、オフチェーンでの取引、所有者+代理人の承認。残りの論点A–J。
- `docs/state-design/real-estate/discussion-log.md`: Round 3 — A–GとJを承認。移行(I)は取り下げ(ゼロベースの国家)。Hを説明。
- `docs/state-design/real-estate/`および`docs/decisions/0029-real-estate-registry-model.md`: 不動産の仕様 — `RealEstateToken`、所有者+代理人による移転、地番はオンチェーンに載せない、外国人所有なし、`NonResidentOwner`。`docs/FEATURES.md`、ルートの`README.md`: 🟢。`docs/BACKLOG.md`: VIPの行を更新、2行追加。ADR 0020のステータスに新しい種別を注記。`docs/PROJECT_STATUS.md`を更新。
- `docs/state-design/real-estate/`: Round 5 — 代理人はトークンごとかつ公開(調整1–2は撤回)。仕様を更新。
- `docs/state-design/real-estate/`: Round 6 — 残りの調整を承認。
- `docs/state-design/securities/discussion-log.md`: 有価証券・株式保有の選別を開始(Round 0、Round 1)。`docs/FEATURES.md`、ルートの`README.md`: 🟡。
- `docs/state-design/securities/discussion-log.md`: Round 2 — 売買とマッチングをオンチェーンで。残りの論点A–E。
- `docs/state-design/securities/`および`docs/decisions/0030-securities-model.md`: Round 3(ユーザーの提案: 取引所はオフチェーン、証券会社がオンチェーンに記録)と仕様 — `ShareRegistry`、`ClearingContract`による日次ネット決済、日次の約定アンカー、実質的所有者の氏名、`ForeignInvestor`。`docs/FEATURES.md`、ルートの`README.md`: 🟢。`docs/BACKLOG.md`: 4行をクローズ、1行を追加。ADR 0005、0020、0021、0029のステータス注記。`docs/PROJECT_STATUS.md`: 初期設計が完了。
- `docs/state-design/securities/`: Round 4 — 調整を承認。
- `docs/architecture/consistency-review.md`: 機能横断の整合性レビューを開始(5つの並行レビューを論点R1–R6に統合)。`docs/PROJECT_STATUS.md`を更新。
- `docs/PROJECT_STATUS.md`: レビュー後のロードマップ(暫定実装、10以上のPoC、PoCの手法、PoCの結果、論文)。
- `docs/PROJECT_STATUS.md`: 「中断/再開ポイント」節を追加(レビュー結果を再提示して再開)。
- `docs/architecture/consistency-review.md`: R1.1–R1.6を承認。
- `docs/decisions/0031-registered-address-transfer-rule.md`: 移転ルールを緩和(住民・法人ごとに登録アドレスは一つ。未登録アドレスへの送金に累積上限。VIPはゼロ。それ以外は事後確認)。ADR 0020のルールを置き換え。整合性レビュー: R2.1、R2.2を承認。決定D1を記録。R2.3は再検討。
- D1に基づく整合性レビュー: R2.3を修正、R2.2とR1.3を確定。訪問者パスを廃止し、両替業者の免除を縮小(ADR 0031を更新)。
- 整合性レビュー: R3.1–R3.10を承認(鍵盗難時の停止、すべての資産トークンに重い手続き経路、承継時のクレデンシャル再発行と死亡時のバーン、登記官主導の重い経路、解散・合併の順序、署名者のローテーション、投票時の確認、転居時はバーン前に発行、相続人の代理人、国外での年齢確認)。
- 整合性レビュー: R4.1–R4.3を承認(`DocumentRegistry`と`EvidenceRegistry`を`AnchorRegistry`に統合、作成者アンカー、種別リスト、命名とトークン規格の見直し)。
- 整合性レビュー: R5.1–R5.9を決定(役員と実質的所有者は氏名–アドレスの紐付けを受け入れる、不動産の買主の露出はPoCでの検討のため受け入れ、配送ラベルに注文コード、年齢クレデンシャルの月次バッチ、常設の有権者クレデンシャル、社会保障の共通コードは維持、VIPアドレスの任意切替)。R1–R5完了、R6は未決。
- `docs/FEATURES.md`、ルートの`README.md`: 調達🟢。`docs/PROJECT_STATUS.md`: 次は補助金。
- `docs/FEATURES.md`、ルートの`README.md`: 補助金🟢(政治の透明性が完了)。`docs/PROJECT_STATUS.md`を更新。
- `docs/state-design/subsidies/discussion-log.md`: Round 3 — 調整を確認。`docs/PROJECT_STATUS.md`: 「中断/再開ポイント」節を追加。
- R6を完了(ADR 0001〜0013、テンプレート、国民・住民の議論ログ、機能のテンプレート、CHANGELOGの日本語訳。古いステータスの記述。相互参照。バックログの整理)。`docs/decisions/0032-consistency-review-decisions.md`にレビューの決定をすべて記録。影響するADRにステータスの注記を加え、影響する仕様、`docs/FEATURES.md`、用語集をそれに合わせて書き直した。
- 整合性レビューの追加の論点: F1(常設の有権者クレデンシャルを取り下げ、資格は選挙ごと・請求ごと)、F2〜F3は解消、F4〜F5を了承、抜けを埋めた。レビュー完了。`docs/PROJECT_STATUS.md`: 再開ポイントを更新(次は仮実装)。

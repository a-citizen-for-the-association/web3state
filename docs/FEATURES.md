# Feature Progress

> Living document. One row per state function (see [`docs/state-design/`](state-design/)). Update whenever a feature's status changes — this is the single place to see "how much has been built" across a project expected to grow very large. A condensed copy of this table is also embedded directly in the root [`README.md`](../README.md) for visibility; keep both in sync when status changes. For items deferred out of a feature's scope rather than actively in progress, see [`docs/BACKLOG.md`](BACKLOG.md) instead of adding a row here. For the reasoning behind what's in/out of scope at a category level, see [ADR 0012](decisions/0012-onchain-scope-philosophy.md).

## Status legend

| Status | Meaning |
|---|---|
| 🔴 Not started | Not yet scoped or discussed |
| 🟡 Discussing | Design/contradictions being worked out with the user; see linked discussion log |
| 🟢 Spec drafted | Design doc written and agreed; no contract code yet |
| 🔵 Implemented | Contract code written (may still be under test) |
| ✅ Tested (testnet) | Tests pass; deployed/verified on Sepolia (and/or Polkadot Hub testnet) |
| 🏛️ Mainnet | Deployed to the chosen mainnet |
| 🚫 Deliberately excluded | Decided *not* to put on-chain, as a matter of policy — see [ADR 0012](decisions/0012-onchain-scope-philosophy.md) |

## Status table

| Category | Function | Status | Design doc | Notes |
|---|---|---|---|---|
| **Identity & Rights** | Citizenship / residency (住民・国民): Resident-Link NFT | 🟢 Spec drafted | [`state-design/citizenship/`](state-design/citizenship/) | Municipality-issued, soulbound, nationality-neutral residency-link NFT. [ADR 0003](decisions/0003-resident-link-identity-model.md). |
| **Identity & Rights** | Corporations (法人) | 🟢 Spec drafted | [`state-design/corporations/`](state-design/corporations/) | Authority-issued, soulbound, on-chain corporate registration NFT(s); officer names public, addresses never on-chain. [ADR 0005](decisions/0005-corporate-registration-model.md). |
| **Identity & Rights** | Credentials (公的証明) — general pattern | 🟢 Spec drafted | [`state-design/credentials/`](state-design/credentials/) | Cross-cutting rules: possession-only NFTs by default, per-type trust-anchor reuse and granularity. |
| **Identity & Rights** | ↳ Passport | 🟢 Spec drafted | [`.../passport/`](state-design/credentials/passport/) | Pure travel document; nationality verified off-chain. [ADR 0006](decisions/0006-passport-credential.md). |
| **Identity & Rights** | ↳ Diploma | 🟢 Spec drafted | [`.../diploma/`](state-design/credentials/diploma/) | Issued from school's corporate-registration address; requires `ResidentLink`. [ADR 0007](decisions/0007-diploma-credential.md). |
| **Identity & Rights** | ↳ License (免許証) | 🟢 Spec drafted | [`.../license/`](state-design/credentials/license/) | One contract per prefecture; suspension/revocation both = burn. [ADR 0008](decisions/0008-license-credential.md). |
| **Identity & Rights** | ↳ Health insurance (健康保険証) | 🟢 Spec drafted | [`.../health-insurance/`](state-design/credentials/health-insurance/) | One contract per insurer; continuous status, not renewed. [ADR 0009](decisions/0009-health-insurance-credential.md). |
| **Identity & Rights** | ↳ Employee ID (社員証) | 🟢 Spec drafted | [`.../employee-id/`](state-design/credentials/employee-id/) | Issued by any registered corporation; no `ResidentLink` dependency. [ADR 0010](decisions/0010-employee-id-credential.md). |
| **Identity & Rights** | ↳ Vaccination (接種証明) | 🟢 Spec drafted | [`.../vaccination/`](state-design/credentials/vaccination/) | Stateful coupon; hospitals mark vaccinated via a role gated on corporate registration. [ADR 0011](decisions/0011-vaccination-credential.md). |
| **Governance Core** | Voting | 🔴 Not started | — | Next up. Needs ballot-secrecy/coercion-resistance design; nationality verification still unresolved (see `docs/BACKLOG.md`). |
| **Governance Core** | Legislative process | 🔴 Not started | — | |
| **Governance Core** | Executive / administration | 🔴 Not started | — | |
| **Governance Core** | Judiciary / dispute resolution | 🔴 Not started | — | |
| **Public Finance & Taxation** | Taxation: payment (納税) | 🟢 Spec drafted | [`state-design/taxation/`](state-design/taxation/) | Payment rail only, no dedicated contract. [ADR 0004](decisions/0004-taxation-payment-rail.md). |
| **Public Finance & Taxation** | Treasury / public finance (歳出・予算) | 🔴 Not started | — | Public money deserves maximal auditability. |
| **Political Transparency** | Political donations (政治献金) | 🔴 Not started | — | Makes covert political funding harder to hide. |
| **Political Transparency** | VIP / politician asset disclosure (要人の資産公開) | 🔴 Not started | — | Continuous, verifiable wealth disclosure for accountability; pairs with stablecoin-income visibility. |
| **Political Transparency** | Public procurement / bidding (公共調達・入札) | 🔴 Not started | — | Reduces bid-rigging (談合). |
| **Political Transparency** | Subsidies / grants disbursement (補助金・交付金) | 🔴 Not started | — | Traceable disbursement reduces subsidy fraud. |
| **Social Welfare** | Pension (年金) | 🔴 Not started | — | Direct stablecoin disbursement cuts admin overhead and fraud. |
| **Social Welfare** | Benefits (児童手当・生活保護等) | 🔴 Not started | — | Same efficiency gain; needs careful individual-privacy design (cf. health insurance). |
| **Social Welfare** | Unemployment insurance (雇用保険) | 🔴 Not started | — | Natural extension of Employee ID + income visibility. |
| **Public-Interest Finance** | Donations (寄付) | 🔴 Not started | — | Explicit policy priority — transparency builds donor/recipient trust, reduces fraud. |
| **Public-Interest Finance** | Crowdfunding, social-purpose (クラウドファンディング) | 🔴 Not started | — | Same rationale as donations; explicit policy priority. |
| **Public-Interest Finance** | NPO / public-interest corporation funds (NPO法人等の資金管理) | 🔴 Not started | — | Extends the corporations design to fund-flow transparency. |
| **Property & Vital Records** | Real estate registry (不動産登記) | 🔴 Not started | — | Addresses abandoned-property (空き家) and inheritance-dispute problems from stale paper records. |
| **Property & Vital Records** | Vital records (戸籍・婚姻・出生等) | 🔴 Not started | — | Related to the deferred nationality/在留資格 backlog item. |
| **Corporate & Market Transparency** | Public company disclosures (有価証券報告書等) | 🔴 Not started | — | Extends corporations' transparency principle to ongoing reporting, not just registration. |
| **Corporate & Market Transparency** | Audit trails (会計監査記録) | 🔴 Not started | — | Tamper-proof certification of financial statements. |
| **Judicial Infrastructure** | Notarization / contract timestamping (公証・契約証明) | 🔴 Not started | — | Tamper-proof existence/content proof for legal documents. |
| **Judicial Infrastructure** | Public court records (判決等の公開) | 🔴 Not started | — | Judicial transparency; needs litigant-privacy care. |
| **Commerce & Markets** | Everyday commerce (日常の商取引) | 🔴 Not started | — | On-chain for tax-transparency purposes, per [ADR 0012](decisions/0012-onchain-scope-philosophy.md). |
| **Commerce & Markets** | Wealth-focused financial services (富裕層向け金融サービス) | 🔴 Not started | — | Provider (not the chain) bears tax-compliance responsibility — not pushed to full on-chain transparency. [ADR 0012](decisions/0012-onchain-scope-philosophy.md). |
| **Deliberately excluded** | High-frequency trading | 🚫 Excluded | — | Weak social character; no reason for the state to build this infrastructure. [ADR 0012](decisions/0012-onchain-scope-philosophy.md). |
| **Deliberately excluded** | Personal wealth-accumulation investment vehicles | 🚫 Excluded | — | Same reasoning, unless independently justified (e.g. VIP asset disclosure). [ADR 0012](decisions/0012-onchain-scope-philosophy.md). |

Already tracked separately in [`docs/BACKLOG.md`](BACKLOG.md), not duplicated here: private insurance/loan tokenization, whether nationality/residence-status should ever be on-chain, the audited multisig standard for corporations, beneficial-ownership transparency for layered corporate structures.

---

# 機能の進捗(日本語)

> 生きたドキュメントです。[`docs/state-design/`](state-design/) の国家機能ごとに1行。機能のステータスが変わるたびに更新してください。大規模化が予想されるこのプロジェクトで「どこまで実装されているか」を一目で確認できる場所です。同じ内容を凝縮した表をルートの[`README.md`](../README.md)にも直接埋め込んでいます。ステータスが変わったら両方を更新してください。機能のスコープから先送りされた項目(現在進行中ではないもの)は、ここではなく[`docs/BACKLOG.md`](BACKLOG.md)を参照してください。カテゴリ単位でのオンチェーン化の対象・対象外の考え方は[ADR 0012](decisions/0012-onchain-scope-philosophy.md)を参照してください。

## ステータス凡例

| ステータス | 意味 |
|---|---|
| 🔴 未着手 | まだスコープ・議論されていない |
| 🟡 議論中 | ユーザーと設計・矛盾点を議論中。リンク先の議論ログを参照 |
| 🟢 設計確定 | 設計書作成・合意済み。コントラクトコードはまだ |
| 🔵 実装済み | コントラクトコード実装済み(テスト中含む) |
| ✅ テスト済み(テストネット) | テスト通過、Sepolia(および/またはPolkadot Hubテストネット)にデプロイ・検証済み |
| 🏛️ メインネット | 選定したメインネットにデプロイ済み |
| 🚫 意図的に対象外 | 方針としてオンチェーン化しないと決定 — [ADR 0012](decisions/0012-onchain-scope-philosophy.md)参照 |

## ステータス表

上記の英語版の表を参照してください(内容は同一です)。

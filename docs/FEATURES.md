# Feature Progress

> Living document. One row per state function (see [`docs/state-design/`](state-design/)). Update whenever a feature's status changes — this is the single place to see "how much has been built" across a project expected to grow very large. For items deferred out of a feature's scope rather than actively in progress, see [`docs/BACKLOG.md`](BACKLOG.md) instead of adding a row here.

## Status legend

| Status | Meaning |
|---|---|
| 🔴 Not started | Not yet scoped or discussed |
| 🟡 Discussing | Design/contradictions being worked out with the user; see linked discussion log |
| 🟢 Spec drafted | Design doc written and agreed; no contract code yet |
| 🔵 Implemented | Contract code written (may still be under test) |
| ✅ Tested (testnet) | Tests pass; deployed/verified on Sepolia (and/or Polkadot Hub testnet) |
| 🏛️ Mainnet | Deployed to the chosen mainnet |

## Status table

| Function | Status | Design doc | Contracts | Notes |
|---|---|---|---|---|
| Citizenship / residency (住民・国民): Resident-Link NFT | 🟢 Spec drafted | [`state-design/citizenship/`](state-design/citizenship/) | — | Municipality-issued, soulbound, nationality-neutral residency-link NFT. See [ADR 0003](decisions/0003-resident-link-identity-model.md) and [discussion log](state-design/citizenship/discussion-log.md). |
| Taxation: payment (納税) | 🟢 Spec drafted | [`state-design/taxation/`](state-design/taxation/) | — | Payment rail only, no dedicated contract needed. See [ADR 0004](decisions/0004-taxation-payment-rail.md) and [discussion log](state-design/taxation/discussion-log.md). |
| Corporations (法人) | 🟢 Spec drafted | [`state-design/corporations/`](state-design/corporations/) | — | Authority-issued, soulbound, on-chain corporate registration NFT(s); officer names public, addresses never on-chain. See [ADR 0005](decisions/0005-corporate-registration-model.md) and [discussion log](state-design/corporations/discussion-log.md). |
| Credentials (公的証明) — general pattern | 🟢 Spec drafted (pattern only) | [`state-design/credentials/`](state-design/credentials/) | — | Cross-cutting rules: pure-possession NFTs (no on-chain fields), per-type trust-anchor reuse, per-type granularity judgment calls. Concrete instances tracked individually below. |
| ↳ Passport credential | 🟢 Spec drafted | [`state-design/credentials/passport/`](state-design/credentials/passport/) | — | Pure travel-document credential; nationality verified off-chain, no on-chain nationality credential built. See [ADR 0006](decisions/0006-passport-credential.md) and [discussion log](state-design/credentials/passport/discussion-log.md). |
| ↳ Diploma / graduation certificate credential | 🟢 Spec drafted | [`state-design/credentials/diploma/`](state-design/credentials/diploma/) | — | Issued from the school's existing corporate registration address; requires recipient to hold `ResidentLink` (any nationality) at mint time; mint-once lifecycle. See [ADR 0007](decisions/0007-diploma-credential.md) and [discussion log](state-design/credentials/diploma/discussion-log.md). |
| ↳ License credential (運転免許証) | 🟢 Spec drafted | [`state-design/credentials/license/`](state-design/credentials/license/) | — | Single contract per prefecture (no per-class split); suspension and revocation both represented as burn. See [ADR 0008](decisions/0008-license-credential.md) and [discussion log](state-design/credentials/license/discussion-log.md). |
| ↳ Health-insurance credential (健康保険証) | 🟢 Spec drafted | [`state-design/credentials/health-insurance/`](state-design/credentials/health-insurance/) | — | Many insurer types all map onto existing trust mechanisms (no new one needed); continuous (non-expiring) lifecycle, unlike passport/license. See [ADR 0009](decisions/0009-health-insurance-credential.md) and [discussion log](state-design/credentials/health-insurance/discussion-log.md). |
| ↳ Employee ID, vaccination credentials | 🔴 Not started | — | — | To be designed one at a time, applying the patterns validated so far. |
| Voting | 🔴 Not started | — | — | Deliberately sequenced after credentials. No on-chain nationality credential exists yet (see `docs/BACKLOG.md`) — voting eligibility will need to address nationality verification on its own terms. Also needs its own ballot-secrecy/coercion-resistance design. |
| Legislative process | 🔴 Not started | — | — | |
| Executive / administration | 🔴 Not started | — | — | |
| Judiciary / dispute resolution | 🔴 Not started | — | — | |
| Treasury / public finance (spending/budget) | 🔴 Not started | — | — | Split from the original "treasury" placeholder — revenue collection is now tracked separately under Taxation above. |

---

# 機能の進捗(日本語)

> 生きたドキュメントです。[`docs/state-design/`](state-design/) の国家機能ごとに1行。機能のステータスが変わるたびに更新してください。大規模化が予想されるこのプロジェクトで「どこまで実装されているか」を一目で確認できる唯一の場所です。

## ステータス凡例

| ステータス | 意味 |
|---|---|
| 🔴 未着手 | まだスコープ・議論されていない |
| 🟡 議論中 | ユーザーと設計・矛盾点を議論中。リンク先の議論ログを参照 |
| 🟢 設計確定 | 設計書作成・合意済み。コントラクトコードはまだ |
| 🔵 実装済み | コントラクトコード実装済み(テスト中含む) |
| ✅ テスト済み(テストネット) | テスト通過、Sepolia(および/またはPolkadot Hubテストネット)にデプロイ・検証済み |
| 🏛️ メインネット | 選定したメインネットにデプロイ済み |

## ステータス表

上記の英語版の表を参照してください(内容は同一です)。

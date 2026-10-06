# License (免許証) — Driver's License

**Status: 🟢 Spec drafted.** Third concrete instance of the [credentials](../) pattern, following [passport](../passport/) and [diploma](../diploma/). Conceptual and architecture questions resolved through discussion with the user; see [`discussion-log.md`](discussion-log.md) for the full reasoning and [`docs/decisions/0008-license-credential.md`](../../../decisions/0008-license-credential.md) for the formal ADR. No contract code written yet.

## Summary

A soulbound, possession-only NFT issued by a prefectural 公安委員会 (Public Safety Commission), proving only that the holder has an active driver's license — **not which vehicle classes or conditions**. Unlike passport and diploma, this credential introduces a real-world distinction between temporary suspension (停止) and permanent revocation (取消); both are represented identically on-chain (burn), with the distinction and re-issuance conditions kept off-chain. Minting requires the recipient to hold a `ResidentLink` NFT, same as diploma.

## Scope

**In scope:** possession of an active driver's license, as a single yes/no fact per prefecture.

**Out of scope:**
- Vehicle class/condition detail (普通, 中型, 大型, 二輪, 第二種, AT限定, 眼鏡等, etc.) — stays entirely in 公安委員会's own off-chain records, mirroring how a single physical card today already manages multiple classes/conditions at once. The on-chain NFT does not distinguish them.
- Professional licenses (医師免許, 建築士, etc.) — a different set of issuing bodies, to be designed separately if needed.
- Any claim beyond possession — per the credentials-wide decision, this NFT carries no fields.

## On-chain / Online / Offline breakdown

(See [`docs/operations/README.md`](../../../operations/README.md) for the convention.)

**On-chain:**
- Mint (公安委員会's admin role only, after the real-world licensing process), restricted to that role.
- A one-time, mint-time-only cross-contract check that the recipient holds a valid `ResidentLink` NFT, against a `ResidentLink` contract the applicant declares — same pattern as diploma.
- Soulbound ownership (`tokenId ↔ address`) — no other fields.
- Burn (公安委員会's admin role only) — used for both suspension and revocation; no on-chain distinction, no reason code.

**Online:**
- 公安委員会's officially-attested contract address, published under its `.lg.jp` domain (prefectures already fall under this mechanism, established in the taxation design).

**Offline:**
- Which vehicle classes/conditions a holder has — 公安委員会's own records, unchanged by this design.
- Whether a burn represents a suspension (temporary, resumes automatically after a fixed period) or a revocation (permanent, requires a fresh application) — an off-chain legal/administrative classification.
- The real-world renewal process (vision test, safety lecture for violators, etc.).

## Architecture

### Contract: `License` (issued by a prefectural 公安委員会)

A soulbound, ERC-721-based token, following the same shape as `ResidentLink`, `Passport`, and `Diploma`:

- **No per-token data** beyond standard ERC-721 ownership.
- **Single contract per prefecture — no granularity by vehicle class.** This is a deliberate departure from diploma's per-faculty/degree contracts: the user's reasoning is that a single physical license already manages multiple classes/conditions at once today, so the on-chain credential mirrors that as a single "has an active license" fact, with detail staying off-chain.
- **Soulbound / non-transferable.**

### Suspension and revocation: both are burn

Unlike any credential designed so far, a Japanese driver's license has a real distinction between temporary suspension (免許停止, points-based, resumes automatically after a fixed period with no new application) and permanent revocation (免許取消, requires a fresh application). This design does **not** introduce an on-chain status field to distinguish them — both are simply a burn by 公安委員会. Whether/when re-issuance is possible, and under what conditions, is an off-chain legal/administrative matter, consistent with this project's established practice of keeping revocation reasons off-chain (citizenship, corporations, passport, diploma all do this).

### `ResidentLink` precondition (nationality-neutral)

Same pattern as [diploma](../diploma/#residentlink-precondition-nationality-neutral): minting requires the recipient to hold a valid `ResidentLink` NFT, checked on-chain at mint time only via an applicant-declared contract — no special-casing for foreign residents, since `ResidentLink` itself makes no nationality distinction.

### Lifecycle

```
[not issued] --mint (公安委員会 only, after licensing process + ResidentLink check)--> [Active: NFT exists]
[Active]      --burn (公安委員会 only; suspension or revocation, reason kept off-chain)--> [not issued]
[not issued]  --mint again (renewal, or re-issuance after suspension/revocation ends)--> [Active]
```

- **Authority-only mint/burn — no self-burn.**
- **Renewal is burn-and-reissue**, same as passport — no on-chain expiry date.
- **No on-chain reason code** for any burn (suspension or revocation alike).

## Open items for later

None specific to this credential. Professional licenses (医師免許, 建築士, etc.), if ever designed, would need their own issuing-body analysis — tracked in [`docs/FEATURES.md`](../../../FEATURES.md) if taken up.

---

# 免許証(日本語)— 運転免許証

**ステータス: 🟢 設計確定。** [公的証明](../)パターンの3番目の具体例、[パスポート](../passport/)・[卒業証明](../diploma/)に続くもの。ユーザーとの議論を通じて概念・アーキテクチャ上の論点は解決済み。詳細な議論の経緯は [`discussion-log.md`](discussion-log.md)、正式なADRは [`docs/decisions/0008-license-credential.md`](../../../decisions/0008-license-credential.md) を参照。コントラクトコードはまだ実装していません。

## 概要

都道府県の公安委員会が発行する、譲渡不可・保持のみを証明するNFTで、保有者が有効な運転免許を持っていることのみを証明します — **どの車両区分・条件かは証明しません**。パスポート・卒業証明とは異なり、このクレデンシャルには、一時的な停止(免許停止)と恒久的な取消(免許取消)という現実の区別があります。オンチェーンでは両方とも同一(burn)として表現し、区別と再発行の条件はオフチェーンに残します。mintには卒業証明と同様に`ResidentLink`NFTの保有を要件とします。

## スコープ

**対象:** 都道府県ごとの、有効な運転免許の保有という単純な有無の事実。

**対象外:**
- 車両区分・条件の内訳(普通、中型、大型、二輪、第二種、AT限定、眼鏡等) — 公安委員会側のオフチェーン記録に完全に留める。今日、1枚の物理的な免許証で複数の区分・条件を同時に管理しているのと同じ考え方です。オンチェーンのNFTはこれらを区別しません。
- 専門職免許(医師免許、建築士等) — 発行主体が異なるため、必要であれば別途設計します。
- 保持の事実以上のあらゆる主張 — 公的証明全体の決定により、このNFTは一切フィールドを持ちません。

## オンチェーン/オンライン/オフラインの内訳

(規約は[`docs/operations/README.md`](../../../operations/README.md)参照)

**オンチェーン:**
- mint(公安委員会の管理者ロールに限定。現実の免許取得プロセスを経た後)。
- 受領者が、申告された`ResidentLink`コントラクトで有効な`ResidentLink`NFTを保有していることの、mint時点限りのクロスコントラクトチェック(卒業証明と同じパターン)。
- 譲渡不可の所有権(`tokenId ↔ アドレス`) — それ以外のフィールドはなし。
- burn(公安委員会の管理者ロールに限定) — 停止・取消のいずれにも使用。オンチェーンでの区別も理由コードもなし。

**オンライン:**
- 公安委員会の、公式に証明されたコントラクトアドレス。`.lg.jp`ドメイン配下で公表(都道府県は納税設計で既にこの仕組みの対象として確立済み)。

**オフライン:**
- 保有者がどの車両区分・条件を持っているか — 公安委員会側の記録のまま、この設計によって変更されない。
- あるburnが停止(一時的、一定期間後に新たな申請なしで自動的に復活)なのか取消(恒久的、新規申請が必要)なのか — オフチェーンの法的・行政上の分類。
- 現実の更新プロセス(視力検査、違反者向けの講習等)。

## アーキテクチャ

### コントラクト: `License`(都道府県の公安委員会が発行)

`ResidentLink`、`Passport`、`Diploma`と同じ形の、譲渡不可のERC-721ベースのトークンです。

- **トークンごとのデータは一切なし**(標準的なERC-721の所有権以外)。
- **都道府県ごとに1つのコントラクト — 車両区分による細分化はなし。** 卒業証明の学部・学位ごとのコントラクトからの意図的な逸脱です。ユーザーの理由付け: 今日でも1枚の物理的な免許証が複数の区分・条件を同時に管理しているため、オンチェーンのクレデンシャルもそれを反映し、「有効な免許を持っている」という単一の事実とし、内訳はオフチェーンに留めます。
- **譲渡不可(Soulbound)。**

### 停止と取消: いずれもburn

これまで設計したどのクレデンシャルにもなかった点として、日本の運転免許には、一時的な停止(免許停止、点数制度に基づき、一定期間後に新規申請なしで自動的に復活)と恒久的な取消(免許取消、新規申請が必要)という現実の区別があります。この設計では、これらを区別するオンチェーンの状態フィールドを**導入しません** — どちらも単に公安委員会によるburnです。再発行が可能かどうか、いつ、どのような条件でかは、オフチェーンの法的・行政上の事項とし、失効理由をオフチェーンに残すというこのプロジェクトの一貫した方針(国民・住民、法人、パスポート、卒業証明のいずれも同様)と一致させます。

### `ResidentLink`の前提条件(国籍を問わない)

[卒業証明](../diploma/#residentlinkの前提条件国籍を問わない)と同じパターンです: mintには、受領者が有効な`ResidentLink`NFTを保有していることを要件とし、mint時点でのみ、申請者が申告したコントラクトに対してオンチェーンで確認します — `ResidentLink`自体が国籍を区別しないため、外国人住民への特別な扱いはありません。

### ライフサイクル

上記の英語版の図を参照してください(内容は同一です)。

- **発行主体限定のmint/burn — 自主バーンなし。**
- **更新はパスポートと同じくburn+再発行** — オンチェーンの有効期限フィールドはなし。
- **いかなるburnについてもオンチェーンの理由コードなし**(停止・取消いずれも)。

## 今後の課題

このクレデンシャル固有のものはありません。専門職免許(医師免許、建築士等)を将来設計する場合は、発行主体について別途分析が必要です — 着手する場合は[`docs/FEATURES.md`](../../../FEATURES.md)で追跡します。

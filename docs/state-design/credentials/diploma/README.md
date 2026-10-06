# Diploma / Graduation Certificate (卒業証明)

**Status: 🟢 Spec drafted.** Second concrete instance of the [credentials](../) pattern, following [passport](../passport/). Conceptual and architecture questions resolved through discussion with the user; see [`discussion-log.md`](discussion-log.md) for the full reasoning and [`docs/decisions/0007-diploma-credential.md`](../../../decisions/0007-diploma-credential.md) for the formal ADR. No contract code written yet.

## Summary

A soulbound, possession-only NFT (per the credentials-wide rule) proving a graduate holds a diploma from a specific school/faculty/degree. Issued from the school's own address — which is simply the school's existing [corporations](../../corporations/) registration address, reused rather than anchored by a new mechanism. Minting requires the recipient to hold a `ResidentLink` NFT at mint time (checked on-chain, one-time) — making no distinction between Japanese nationals and foreign residents, since `ResidentLink` itself makes none.

## Scope

**In scope:** diplomas for graduates who hold (at time of issuance) a `ResidentLink` NFT from some Japanese municipality — any nationality.

**Out of scope:**
- Graduates who were never registered residents of Japan (e.g., fully remote overseas distance-learning students) — they fall outside this on-chain credential and continue to rely on a traditional paper diploma.
- Sole proprietors / individuals acting outside an institutional capacity — not applicable here (the issuer is always a school).
- Any claim beyond possession — per the credentials-wide decision, this NFT carries no fields (no degree title, GPA, honors, etc. — those distinctions are expressed by *which contract* issued the token, see [Architecture](#architecture)).

## On-chain / Online / Offline breakdown

(See [`docs/operations/README.md`](../../../operations/README.md) for the convention.)

**On-chain:**
- Mint (authority/school only, after conferring the degree through its existing real-world process), restricted to the school's admin role.
- A one-time, mint-time-only cross-contract check that the recipient holds a valid `ResidentLink` NFT, against a `ResidentLink` contract the applicant declares.
- Soulbound ownership (`tokenId ↔ address`) — no other fields.
- Burn (authority only, rare — actual degree revocation).

**Online:**
- The school's officially-attested registration, published the same way as any other corporation (see [corporations](../../corporations/)) — no separate mechanism for diploma-issuing specifically.

**Offline:**
- The school's real-world graduation/degree-conferral process (unchanged by this design).
- The real-world process behind a degree revocation (e.g. an academic-fraud finding), with the reason kept off-chain only (same minimization principle as citizenship/corporations).

## Architecture

### Contract: `Diploma` (issued by a school, per faculty/degree)

A soulbound, ERC-721-based token, following the same shape as `ResidentLink`, the corporations registration NFTs, and `Passport`:

- **No per-token data** beyond standard ERC-721 ownership — these NFTs prove possession only.
- **Issuer address = the school's existing corporate registration address.** Schools (国立大学法人, public schools, private 学校法人) are simply another category of specially-regulated corporation already covered by the [corporations](../../corporations/) design (supervised by 文部科学省 and/or a prefectural board of education) — reusing that same registered address to issue `Diploma` NFTs needs no new trust-anchor mechanism (the same pattern already used for employer-issued employee IDs).
- **Granularity: one contract per faculty/degree-level** — a natural, static distinction a school decides when deploying (e.g. "University of Tokyo Faculty of Engineering Bachelor's"). **Graduation year is not a separate contract** — it's recoverable from the mint event's block timestamp, consistent with the citizenship design's Issue 5 reasoning (don't store on-chain what's already recoverable from event data).
- **Soulbound / non-transferable** — same as every other identity-linked NFT in this project.

### `ResidentLink` precondition (nationality-neutral)

Minting requires the recipient to hold a valid `ResidentLink` NFT:

- **Checked on-chain, at mint time only** — not an ongoing requirement. A diploma already issued remains valid even if the holder's `ResidentLink` is later burned (e.g. after moving abroad), mirroring how a real diploma isn't invalidated by a later house move.
- **The applicant declares which `ResidentLink` contract to check** (i.e., which municipality they're a resident of); the school's `Diploma` contract performs a cross-contract `balanceOf` check against that declared contract at mint time — the same pattern as citizenship's Issue 6 deduplication check.
- **No special-casing for foreign residents.** Since `ResidentLink` itself makes no nationality distinction, a registered foreign resident qualifies identically to a Japanese national resident — this is a direct, free consequence of `ResidentLink`'s nationality-neutral design (ADR 0003), not a new mechanism.

### Lifecycle

```
[not issued] --mint (school only, after conferring the degree + ResidentLink check)--> [Active: NFT exists]
[Active]      --burn (school only; rare — actual degree revocation, reason kept off-chain)--> [not issued]
```

- **The simplest lifecycle designed so far.** Unlike `Passport` (renews) or corporations (fields change routinely), a conferred degree doesn't legitimately change. No updates, no renewal.
- **Authority-only mint/burn — no self-burn.**
- No on-chain reason code for a revocation (same minimization principle as citizenship/corporations).

## Open items for later

None specific to this credential — the general credentials pattern's remaining instances (license, employee ID, health-insurance, vaccination) are tracked in [`docs/FEATURES.md`](../../../FEATURES.md).

---

# 卒業証明(日本語)

**ステータス: 🟢 設計確定。** [公的証明](../)パターンの2番目の具体例、[パスポート](../passport/)に続くもの。ユーザーとの議論を通じて概念・アーキテクチャ上の論点は解決済み。詳細な議論の経緯は [`discussion-log.md`](discussion-log.md)、正式なADRは [`docs/decisions/0007-diploma-credential.md`](../../../decisions/0007-diploma-credential.md) を参照。コントラクトコードはまだ実装していません。

## 概要

卒業生が特定の学校・学部・学位の卒業証明を保持していることを証明する、譲渡不可・保持のみを証明するNFT(公的証明全体のルールに従う)です。発行元は学校自身のアドレスですが、これは新しい仕組みで証明するのではなく、学校の既存の[法人登録](../../corporations/)アドレスをそのまま流用します。mintには、受領者が受領時点で`ResidentLink`NFTを保有していることを要件とします(オンチェーンで一度きり確認)。これは`ResidentLink`自体が国籍を区別しないため、日本国民と外国人住民を区別しません。

## スコープ

**対象:** 発行時点で、何らかの市区町村の`ResidentLink`NFTを保有している卒業生の卒業証明(国籍を問わない)。

**対象外:**
- 一度も日本の住民登録をしたことがない卒業生(完全遠隔の海外留学生等) — このオンチェーンクレデンシャルの対象外とし、従来の紙の卒業証明に頼る。
- 個人事業主/組織に属さない個人としての活動 — ここでは該当しない(発行主体は常に学校)。
- 保持の事実以上のあらゆる主張 — 公的証明全体の決定により、このNFTは一切フィールドを持ちません(学位名、成績、優等学位等は含まない — こうした区別は「どのコントラクトが発行したか」で表現します。[アーキテクチャ](#アーキテクチャ)参照)。

## オンチェーン/オンライン/オフラインの内訳

(規約は[`docs/operations/README.md`](../../../operations/README.md)参照)

**オンチェーン:**
- mint(学校の管理者ロールに限定。既存の現実の学位授与プロセスを経た後)。
- 受領者が、申告された`ResidentLink`コントラクトで有効な`ResidentLink`NFTを保有していることの、mint時点限りのクロスコントラクトチェック。
- 譲渡不可の所有権(`tokenId ↔ アドレス`) — それ以外のフィールドはなし。
- burn(発行主体のみ、稀 — 実際の学位取消)。

**オンライン:**
- 学校の、公式に証明された登録。他の法人と同じ方法で公表([法人設計](../../corporations/)参照) — 卒業証明専用の別の仕組みはない。

**オフライン:**
- 学校の現実の卒業・学位授与プロセス(この設計によって変更されない)。
- 学位取消(学術不正の認定等)の背後にある現実のプロセス。理由はオフチェーンにのみ残す(国民・住民・法人設計と同じ最小化の原則)。

## アーキテクチャ

### コントラクト: `Diploma`(学校が学部・学位ごとに発行)

`ResidentLink`、法人登録NFT、`Passport`と同じ形の、譲渡不可のERC-721ベースのトークンです。

- **トークンごとのデータは一切なし**(標準的なERC-721の所有権以外)— これらのNFTは保持の事実のみを証明します。
- **発行主体のアドレス＝学校の既存の法人登録アドレス。** 学校(国立大学法人、公立学校、私立学校(学校法人))は、[法人設計](../../corporations/)で既にカバーしている「特殊な規制対象の法人」の一種にすぎません(文部科学省および/または都道府県教育委員会の監督下)。同じ登録済みアドレスを使って`Diploma`NFTを発行することに、新しい信頼の仕組みは不要です(雇用主発行の社員証と同じパターン)。
- **粒度: 学部・学位レベルごとに1つのコントラクト** — 自然で静的な区別で、学校がデプロイ時に決定します(例:「東京大学工学部学士」)。**卒業年度は別コントラクトにしません** — mintイベントのブロックタイムスタンプから復元可能であり、国民・住民設計のIssue 5の理由と一致します(イベントデータから復元できるものをあえてオンチェーンに持たない)。
- **譲渡不可(Soulbound)** — このプロジェクトの他の全てのアイデンティティ関連NFTと同様。

### `ResidentLink`の前提条件(国籍を問わない)

mintには、受領者が有効な`ResidentLink`NFTを保有していることを要件とします。

- **オンチェーンで、mint時点のみ確認** — 継続的な要件ではありません。既に発行された卒業証明は、保有者の`ResidentLink`が後に(例えば海外転居により)失効しても有効なままです。現実の卒業証明が、後の引っ越しによって無効にならないのと同じです。
- **申請者は、確認すべき`ResidentLink`コントラクト(＝どの市区町村の住民か)を申告**し、学校の`Diploma`コントラクトがmint時にその申告先に対してクロスコントラクトの`balanceOf`チェックを行います — 国民・住民設計のIssue 6の重複防止チェックと同じパターンです。
- **外国人住民に対する特別な扱いはありません。** `ResidentLink`自体が国籍を区別しないため、住民登録されている外国人は、日本国民の住民と全く同じ扱いになります — これは`ResidentLink`の国籍を問わない設計(ADR 0003)の直接的かつ無償の帰結であり、新しい仕組みではありません。

### ライフサイクル

上記の英語版の図を参照してください(内容は同一です)。

- **これまで設計した中で最もシンプルなライフサイクルです。** `Passport`(更新される)や法人(フィールドが日常的に変化する)とは異なり、授与された学位は正当に変化しません。更新も更新(renewal)もありません。
- **発行主体限定のmint/burn — 自主バーンなし。**
- 失効(学位取消)の理由コードはオンチェーンに残しません(国民・住民・法人設計と同じ最小化の原則)。

## 今後の課題

このクレデンシャル固有のものはありません — 公的証明パターンの残りの具体例(免許証、社員証、健康保険証、接種証明)は[`docs/FEATURES.md`](../../../FEATURES.md)で追跡しています。

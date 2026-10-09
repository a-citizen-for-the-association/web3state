# Health Insurance Card (健康保険証)

**Status: 🟢 Spec drafted.** Fourth concrete instance of the [credentials](../) pattern, following [passport](../passport/), [diploma](../diploma/), and [license](../license/). Conceptual and architecture questions resolved through discussion with the user; see [`discussion-log.md`](discussion-log.md) for the full reasoning and [`docs/decisions/0009-health-insurance-credential.md`](../../../decisions/0009-health-insurance-credential.md) for the formal ADR. No contract code written yet.

## Summary

A soulbound, possession-only NFT proving current enrollment in a specific public health insurance scheme. Japan's public health insurance system has an unusually wide variety of insurer types, but every one of them maps onto a trust mechanism this project has already established — no new category was needed. Lifecycle is continuous (like `ResidentLink`) rather than periodically renewed (like passport/license), since enrollment doesn't expire on a schedule — it changes when circumstances change.

## Scope

**In scope:** enrollment in a *public* health insurance scheme (国民健康保険, 後期高齢者医療制度, 協会けんぽ, 組合健保, 共済組合), for the primary insured and dependents alike.

**Out of scope:**
- *Private* commercial insurance (life, earthquake, etc.) — tracked separately in [`docs/BACKLOG.md`](../../../BACKLOG.md) under the "financial infrastructure" theme, for tax-deduction-computation purposes, deferred until later.
- Plan/coverage detail (copay rate, specific benefits, etc.) — per the credentials-wide rule, this NFT proves possession only.

## On-chain / Online / Offline breakdown

(See [`docs/operations/README.md`](../../../operations/README.md) for the convention.)

**On-chain:**
- Mint (insurer's admin role only, upon enrollment) and burn (insurer's admin role only, upon disenrollment — reason kept off-chain).
- A one-time, mint-time-only cross-contract check that the recipient holds a valid `ResidentLink` NFT, against a contract the applicant declares — same pattern as diploma/license.
- Soulbound ownership (`tokenId ↔ address`) — no other fields.

**Online:**
- Each insurer's officially-attested contract address, published under the applicable domain: `.lg.jp` for municipalities and prefectural 広域連合; the corporations design's existing publication mechanism for 協会けんぽ/組合健保/共済組合 (registered as specially-regulated corporations).

**Offline:**
- Enrollment and disenrollment eligibility determination — the insurer's existing real-world process, unchanged by this design.
- The reason for disenrollment (job change, aging into 後期高齢者医療制度, death, etc.) — kept off-chain only.
- Plan/coverage detail — stays in the insurer's own records.

## Architecture

### Contract: `HealthInsurance` (issued by an insurer)

A soulbound, ERC-721-based token, following the same shape as `ResidentLink`, `Passport`, `Diploma`, and `License`:

- **No per-token data** beyond standard ERC-721 ownership.
- **One contract per insurer — no further granularity.** Mirrors license's resolution (not diploma's): a person is enrolled in exactly one insurer's scheme at a time, so the NFT proves only "currently enrolled," nothing about plan type or coverage detail.
- **Soulbound / non-transferable.**

### Trust-anchor mapping per insurer type

No new mechanism was needed — every insurer type maps onto something already established:

| Insurer type | Trust-anchor |
|---|---|
| 国民健康保険 (municipality-run) | `.lg.jp` — same mechanism as `ResidentLink` |
| 後期高齢者医療制度 (prefectural 広域連合) | `.lg.jp` — same local-government mechanism |
| 協会けんぽ (single nationally-organized statutory corporation) | Registers via the [corporations](../../corporations/) pattern as a specially-regulated corporation, supervised by 厚生労働省 — same treatment as 国立大学法人 in the diploma design |
| 組合健保 (company/industry health insurance unions) | Same corporations-pattern treatment, supervised by 厚生労働省 |
| 共済組合 (public-servant mutual aid associations) | Same corporations-pattern treatment, supervised by the relevant ministry |

### `ResidentLink` precondition (nationality-neutral)

Same pattern as diploma and license: minting requires the recipient to hold a valid `ResidentLink` NFT, checked on-chain at mint time only via an applicant-declared contract — no special-casing for foreign residents.

### Dependents (扶養家族): no special handling

A dependent is simply another enrolled person: they receive their own `HealthInsurance` NFT from the same insurer's contract, provided they hold their own `ResidentLink`. There is no on-chain distinction between a primary insured person and a dependent.

### Lifecycle

```
[not enrolled] --mint (insurer only, upon enrollment + ResidentLink check)--> [Active: NFT exists]
[Active]         --burn (insurer only; any disenrollment reason, kept off-chain)--> [not enrolled]
```

- **Continuous status, not periodic renewal** — unlike `Passport`/`License`, there is no fixed validity period to renew. Enrollment persists until a disenrollment event (job change, aging into 後期高齢者医療制度, death, etc.), at which point the insurer burns the NFT. Switching insurers is simply burn (old) + mint (new), the same shape as citizenship's municipality-move pattern.
- **Authority-only mint/burn — no self-burn.**
- **No on-chain reason code** for disenrollment (same minimization principle as every other credential).

## Open items for later

None specific to this credential. Tracked separately in [`docs/BACKLOG.md`](../../../BACKLOG.md): private insurance tokenization (for tax-deduction purposes), a distinct future topic.

---

# 健康保険証(日本語)

**ステータス: 🟢 設計確定。** [公的証明](../)パターンの4番目の具体例、[パスポート](../passport/)・[卒業証明](../diploma/)・[免許証](../license/)に続くもの。ユーザーとの議論を通じて概念・アーキテクチャ上の論点は解決済み。詳細な議論の経緯は [`discussion-log.md`](discussion-log.md)、正式なADRは [`docs/decisions/0009-health-insurance-credential.md`](../../../decisions/0009-health-insurance-credential.md) を参照。コントラクトコードはまだ実装していません。

## 概要

特定の公的医療保険制度への現在の加入を証明する、譲渡不可・保持のみを証明するNFTです。日本の公的医療保険制度は保険者の種類が非常に多様ですが、そのいずれもがこのプロジェクトで既に確立した信頼の仕組みにそのまま当てはまり、新しいカテゴリは不要でした。ライフサイクルは(パスポート・免許証のような)定期更新ではなく、(`ResidentLink`のような)継続的な状態です。加入は決まった周期で期限切れになるものではなく、状況の変化によって変わるためです。

## スコープ

**対象:** 本人・扶養家族を問わず、**公的**医療保険制度(国民健康保険、後期高齢者医療制度、協会けんぽ、組合健保、共済組合)への加入。

**対象外:**
- **民間の**商業保険(生命保険、地震保険等) — 控除計算を目的として、`docs/BACKLOG.md`の「金融インフラ」テーマの下で別途追跡し、後日扱う。
- 保険の種類・給付内容等の詳細 — 公的証明全体のルールにより、このNFTは保持の事実のみを証明する。

## オンチェーン/オンライン/オフラインの内訳

(規約は[`docs/operations/README.md`](../../../operations/README.md)参照)

**オンチェーン:**
- mint(保険者の管理者ロールに限定、加入時)とburn(保険者の管理者ロールに限定、脱退時 — 理由はオフチェーンに残す)。
- 受領者が、申告されたコントラクトで有効な`ResidentLink`NFTを保有していることの、mint時点限りのクロスコントラクトチェック — 卒業証明・免許証と同じパターン。
- 譲渡不可の所有権(`tokenId ↔ アドレス`) — それ以外のフィールドはなし。

**オンライン:**
- 各保険者の、公式に証明されたコントラクトアドレス。該当するドメインで公表: 市区町村・都道府県の広域連合は`.lg.jp`、協会けんぽ・組合健保・共済組合(特殊な規制対象法人として登録)は法人設計の既存の公表の仕組み。

**オフライン:**
- 加入・脱退の資格判定 — 保険者の既存の現実のプロセスのまま、この設計によって変更されない。
- 脱退の理由(転職、後期高齢者医療制度への移行、死亡等) — オフチェーンにのみ残す。
- 保険の種類・給付内容の詳細 — 保険者自身の記録に留まる。

## アーキテクチャ

### コントラクト: `HealthInsurance`(保険者が発行)

`ResidentLink`、`Passport`、`Diploma`、`License`と同じ形の、譲渡不可のERC-721ベースのトークンです。

- **トークンごとのデータは一切なし**(標準的なERC-721の所有権以外)。
- **保険者ごとに1つのコントラクト — それ以上の細分化なし。** 卒業証明ではなく免許証の結論を踏襲します: ある時点で1つの保険者の制度にのみ加入しているため、NFTは「現在加入しているか」のみを証明し、保険の種類や給付内容については何も主張しません。
- **譲渡不可(Soulbound)。**

### 保険者の種類ごとの信頼の起点の対応

新しい仕組みは不要でした — 全ての保険者の種類が既存の仕組みに当てはまります:

| 保険者の種類 | 信頼の起点 |
|---|---|
| 国民健康保険(市区町村運営) | `.lg.jp` — `ResidentLink`と同じ仕組み |
| 後期高齢者医療制度(都道府県の広域連合) | `.lg.jp` — 同じ地方公共団体の仕組み |
| 協会けんぽ(全国単一の特別法人) | [法人設計](../../corporations/)のパターンで特殊な規制対象法人として登録、厚生労働省の監督下 — 卒業証明における国立大学法人と同じ扱い |
| 組合健保(企業・業界の健康保険組合) | 同じく法人設計のパターン、厚生労働省の監督下 |
| 共済組合(公務員向け共済組合) | 同じく法人設計のパターン、該当する省庁の監督下 |

### `ResidentLink`の前提条件(国籍を問わない)

卒業証明・免許証と同じパターンです: mintには、受領者が有効な`ResidentLink`NFTを保有していることを要件とし、mint時点でのみ、申請者が申告したコントラクトに対してオンチェーンで確認します — 外国人住民への特別な扱いはありません。

### 扶養家族: 特別な対応なし

扶養家族も単に別の加入者です: 自身の`ResidentLink`を保有していれば、同じ保険者のコントラクトから自分自身の`HealthInsurance`NFTを受け取ります。被保険者本人と扶養家族をオンチェーンで区別することはありません。

### ライフサイクル

上記の英語版の図を参照してください(内容は同一です)。

- **継続的な状態であり、定期更新ではありません** — `Passport`/`License`とは異なり、更新すべき決まった有効期間はありません。加入は、脱退事由(転職、後期高齢者医療制度への移行、死亡等)が発生するまで継続し、その時点で保険者がNFTをburnします。保険者の切り替えは、単に旧保険者のburn＋新保険者のmintであり、国民・住民設計の転居パターンと同じ形です。
- **発行主体限定のmint/burn — 自主バーンなし。**
- **脱退について、オンチェーンの理由コードなし**(他の全てのクレデンシャルと同じ最小化の原則)。

## 今後の課題

このクレデンシャル固有のものはありません。`docs/BACKLOG.md`で別途追跡: 控除計算を目的とした民間保険のトークン化(別の将来のトピック)。

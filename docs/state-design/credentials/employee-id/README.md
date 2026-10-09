# Employee ID (社員証)

**Status: 🟢 Spec drafted.** Fifth concrete instance of the [credentials](../) pattern, following [passport](../passport/), [diploma](../diploma/), [license](../license/), and [health-insurance](../health-insurance/). Conceptual and architecture questions resolved through discussion with the user; see [`discussion-log.md`](discussion-log.md) for the full reasoning and [`docs/decisions/0010-employee-id-credential.md`](../../../decisions/0010-employee-id-credential.md) for the formal ADR. No contract code written yet.

## Summary

A soulbound, possession-only NFT proving current employment at a specific company, issued from that company's existing [corporations](../../corporations/) registration address — no new trust mechanism needed, since the issuing address's legitimacy as "Company X" is already established there. Unlike diploma, license, and health insurance, this credential has **no `ResidentLink` precondition**: employment at a Japanese-registered company isn't inherently tied to Japanese residency (remote or overseas-branch employees may never have been Japan residents).

## Scope

**In scope:** employment at an actual registered corporation.

**Out of scope:**
- Sole proprietors (個人事業主) as employers — they have no corporate registration to issue from; their employees do not get an on-chain `EmployeeID` under this design.
- Department, role, or clearance-level detail — per the credentials-wide rule, this NFT proves possession only (mirrors license/health-insurance's level of aggregation, not diploma's per-sub-type split).

## On-chain / Online / Offline breakdown

(See [`docs/operations/README.md`](../../../operations/README.md) for the convention.)

**On-chain:**
- Mint (company's admin role only, upon hiring) and burn (company's admin role only, upon employment ending — reason kept off-chain).
- Soulbound ownership (`tokenId ↔ address`) — no other fields. No `ResidentLink` check (unlike diploma/license/health-insurance).

**Online:**
- The employer's officially-attested corporate registration (see [corporations](../../corporations/)) — no separate mechanism for employee-ID issuance specifically.

**Offline:**
- The real-world hiring and termination process (unchanged by this design).
- The reason employment ended (resignation, termination, retirement, contract end, etc.) — kept off-chain only.

## Architecture

### Contract: `EmployeeID` (issued by a corporation)

A soulbound, ERC-721-based token, following the same shape as `ResidentLink`, `Passport`, `Diploma`, `License`, and `HealthInsurance`:

- **No per-token data** beyond standard ERC-721 ownership.
- **Issuer address = the company's existing corporate registration address.** Any registered corporation can issue `EmployeeID` NFTs from its own address — this was already identified when the general credentials pattern was first discussed, needing no new trust-anchor mechanism.
- **One contract per company — no further granularity.** Mirrors license/health-insurance's resolution: proves only "currently employed here," not department, role, or clearance level.
- **Sole proprietors cannot issue this credential** — they have no corporate registration address to issue from (per the corporations design's scope). Their employees simply have no on-chain employee ID.
- **Soulbound / non-transferable.**

### No `ResidentLink` precondition

Unlike diploma, license, and health insurance — all run by Japan-specific institutions for Japan-based individuals — employment at a Japanese-registered company is not inherently tied to Japanese residency. A company may employ remote workers or local hires at an overseas branch who were never Japan residents. `EmployeeID` is therefore independent of `ResidentLink`, the same way `Passport` is.

### Lifecycle

```
[not employed] --mint (company only, upon hiring)--> [Active: NFT exists]
[Active]         --burn (company only; any reason, kept off-chain)--> [not employed]
```

- **Continuous status, not periodic renewal** — same shape as health insurance. Employment doesn't expire on a schedule; it ends on specific trigger events (resignation, termination, retirement, fixed-term contract end).
- **Authority-only mint/burn — no self-burn, including for resignation.** Although resignation is initiated by the employee in the real world, invalidating the credential itself is still processed by the employer (notice periods, possible withdrawal of resignation, handover requirements, etc.) — consistent with how this project keeps credential invalidation authority-side even where the underlying real-world action is personally initiated (see passport's discussion of 国籍離脱, resolved the same way).
- **No on-chain reason code** for employment ending (same minimization principle as every other credential).

## Open items for later

None specific to this credential.

---

# 社員証(日本語)

**ステータス: 🟢 設計確定。** [公的証明](../)パターンの5番目の具体例、[パスポート](../passport/)・[卒業証明](../diploma/)・[免許証](../license/)・[健康保険証](../health-insurance/)に続くもの。ユーザーとの議論を通じて概念・アーキテクチャ上の論点は解決済み。詳細な議論の経緯は [`discussion-log.md`](discussion-log.md)、正式なADRは [`docs/decisions/0010-employee-id-credential.md`](../../../decisions/0010-employee-id-credential.md) を参照。コントラクトコードはまだ実装していません。

## 概要

特定の会社における現在の雇用関係を証明する、譲渡不可・保持のみを証明するNFTで、その会社の既存の[法人登録](../../corporations/)アドレスから発行します — 発行アドレスが「A社」であることの正当性は既に確立されているため、新しい信頼の仕組みは不要です。卒業証明・免許証・健康保険証とは異なり、このクレデンシャルには**`ResidentLink`の前提条件がありません**: 日本で登録された会社での雇用は、日本の住民資格と本質的に結びついていません(遠隔勤務者や海外拠点の現地採用者は、一度も日本の住民になったことがない場合があります)。

## スコープ

**対象:** 実際に登録された法人における雇用。

**対象外:**
- 雇用主としての個人事業主 — 発行元となる法人登録がないため。その従業員は、この設計の下ではオンチェーンの`EmployeeID`を持ちません。
- 部署・役職・権限レベルの詳細 — 公的証明全体のルールにより、このNFTは保持の事実のみを証明します(卒業証明の種類ごとの分割ではなく、免許証・健康保険証と同じ集約レベル)。

## オンチェーン/オンライン/オフラインの内訳

(規約は[`docs/operations/README.md`](../../../operations/README.md)参照)

**オンチェーン:**
- mint(会社の管理者ロールに限定、雇用時)とburn(会社の管理者ロールに限定、雇用終了時 — 理由はオフチェーンに残す)。
- 譲渡不可の所有権(`tokenId ↔ アドレス`) — それ以外のフィールドはなし。`ResidentLink`のチェックはなし(卒業証明・免許証・健康保険証とは異なる)。

**オンライン:**
- 雇用主の、公式に証明された法人登録([法人設計](../../corporations/)参照) — 社員証発行専用の別の仕組みはない。

**オフライン:**
- 現実の採用・退職プロセス(この設計によって変更されない)。
- 雇用が終了した理由(退職、解雇、定年、有期契約満了等) — オフチェーンにのみ残す。

## アーキテクチャ

### コントラクト: `EmployeeID`(法人が発行)

`ResidentLink`、`Passport`、`Diploma`、`License`、`HealthInsurance`と同じ形の、譲渡不可のERC-721ベースのトークンです。

- **トークンごとのデータは一切なし**(標準的なERC-721の所有権以外)。
- **発行主体のアドレス＝会社の既存の法人登録アドレス。** 登録された法人であれば誰でも、自身のアドレスから`EmployeeID`NFTを発行できます — これは公的証明の一般パターンを最初に議論した際に既に特定されていたもので、新しい信頼の起点の仕組みは不要です。
- **会社ごとに1つのコントラクト — それ以上の細分化なし。** 免許証・健康保険証の結論を踏襲し、「現在ここで雇用されているか」のみを証明し、部署・役職・権限レベルは証明しません。
- **個人事業主はこのクレデンシャルを発行できません** — 発行元となる法人登録アドレスがないためです(法人設計のスコープによる)。その従業員は単にオンチェーンの社員証を持ちません。
- **譲渡不可(Soulbound)。**

### `ResidentLink`の前提条件なし

卒業証明・免許証・健康保険証(いずれも日本固有の機関が日本在住者向けに運用)とは異なり、日本で登録された会社での雇用は日本の住民資格に本質的に結びついていません。会社は、一度も日本の住民になったことがない遠隔勤務者や海外拠点の現地採用者を雇用することがあります。したがって`EmployeeID`は、`Passport`と同様、`ResidentLink`から独立しています。

### ライフサイクル

上記の英語版の図を参照してください(内容は同一です)。

- **継続的な状態であり、定期更新ではありません** — 健康保険証と同じ形です。雇用は決まった周期で期限切れになるものではなく、特定の契機(退職、解雇、定年、有期契約満了)で終了します。
- **発行主体限定のmint/burn — 退職の場合も含め自主バーンなし。** 現実には退職は従業員本人の意思で開始されますが、クレデンシャル自体の無効化は雇用主側が処理する事項です(予告期間、退職撤回の可能性、引継ぎ要件等があるため) — 本人が行使する現実の行為であっても、クレデンシャルの無効化権限は発行主体側に残すという、このプロジェクトの一貫した方針です(パスポート設計での国籍離脱の議論を参照、同じ結論になりました)。
- **雇用終了について、オンチェーンの理由コードなし**(他の全てのクレデンシャルと同じ最小化の原則)。

## 今後の課題

このクレデンシャル固有のものはありません。

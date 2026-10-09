# Vaccination Certificate (接種証明)

**Status: 🟢 Spec drafted.** Sixth and final concrete instance of the originally-listed [credentials](../) examples, following [passport](../passport/), [diploma](../diploma/), [license](../license/), [health-insurance](../health-insurance/), and [employee-id](../employee-id/). Conceptual and architecture questions resolved through discussion with the user; see [`discussion-log.md`](discussion-log.md) for the full reasoning (including a mid-discussion model correction) and [`docs/decisions/0011-vaccination-credential.md`](../../../decisions/0011-vaccination-credential.md) for the formal ADR. No contract code written yet.

## Summary

A municipality-issued, soulbound **vaccination coupon (接種券)** NFT with a two-stage lifecycle: `Issued` (entitled, not yet vaccinated) and `Vaccinated` (administered). Unlike every prior identity-style credential, a hospital — not the issuing municipality — flips the status once vaccination occurs, via a role the municipality grants only to addresses that already hold a valid corporate registration (as a 医療法人). This is the first credential needing genuine on-chain mutable state (a status field) since corporations, and the first needing a three-party authorization model (issuer, updater, holder) rather than issuer-only control.

## Scope

**In scope:** vaccination coupons issued by a municipality to its own residents, for any vaccine type it administers, with hospital-side completion marking.

**Out of scope:**
- Medical sequencing logic (dose ordering, minimum intervals, age/eligibility rules, medical exemptions) — entirely the vaccinating municipality's real-world clinical responsibility.
- Any data beyond the status field (no dose date, lot number, administering clinic identity, etc.) — kept off-chain in the municipality's and hospital's own records.

## On-chain / Online / Offline breakdown

(See [`docs/operations/README.md`](../../../operations/README.md) for the convention.)

**On-chain:**
- Mint (municipality's admin role only), requiring the recipient to hold a valid `ResidentLink` NFT on the issuing municipality's *own* `ResidentLink` contract (no applicant-declared parameter — see [Architecture](#residentlink-precondition-municipality-is-always-the-residents-own)).
- `markVaccinated` (callable only by addresses holding `VACCINATOR_ROLE`), flipping a coupon's status from `Issued` to `Vaccinated`.
- Granting `VACCINATOR_ROLE` (municipality's admin role only), requiring the candidate address to hold a valid corporate registration NFT (checked on-chain).
- Burn (municipality's admin role only), allowed **only** while a coupon is `Issued`.
- Soulbound ownership (`tokenId ↔ address`) plus the status field — the only credential besides corporations with real per-token state.

**Online:**
- The municipality's officially-attested `VaccinationCoupon` contract address, published under `.lg.jp` — same mechanism as `ResidentLink`.

**Offline:**
- The municipality's due diligence in selecting which hospitals to contract with and grant `VACCINATOR_ROLE` — being a registered corporation is a necessary on-chain precondition, not a substitute for this real vetting.
- The actual vaccination event itself (administering the dose, clinical judgment on eligibility/timing).
- Dose scheduling, intervals, and medical sequencing.

## Architecture

### Contract: `VaccinationCoupon` (issued by a municipality, per vaccine type)

A soulbound, ERC-721-based token — but unlike every other credential except corporations, it carries real per-token state:

- **One status field per token**: `enum Status { Issued, Vaccinated }` — a deliberate, justified exception to the credentials-wide zero-fields rule, since a two-stage coupon→completion lifecycle cannot otherwise be represented.
- **One contract per (municipality × vaccine type)** — e.g. "City A COVID-19 Vaccine Coupon," "City A Measles Vaccine Coupon," issued separately. Unlike license/health-insurance's single-contract aggregation, which vaccine a person has is usually the entire point of checking, so this follows diploma's finer-grained reasoning instead.
- **Soulbound / non-transferable** — explicitly to prevent resale or scalping of vaccination appointments, not just for consistency with other credentials.
- **No other per-token data** — no dose date, batch/lot number, or administering clinic identity on-chain; that detail stays in the municipality's and hospital's own records.

### Lifecycle

```
                    mint (municipality only,
                    recipient must hold ResidentLink
                    on the issuing municipality's own contract)
[not issued] ─────────────────────────────────────────────> [Issued]

[Issued] ──markVaccinated (VACCINATOR_ROLE only)───────────> [Vaccinated]  (permanent — never burned)

[Issued] ──burn (municipality only; unused/expired)────────> [not issued]
```

- **Multiple doses = multiple separate coupons.** Each dose (primary series, booster, etc.) is a fresh mint from the same vaccine-type contract, independently cycling through `Issued` → `Vaccinated`. A fully-vaccinated person accumulates multiple permanent `Vaccinated` tokens over time — dose history is derivable by enumerating a holder's tokens and their statuses, with no dedicated "dose count" field needed.
- **`Vaccinated` is permanent — never burned.** Only `Issued` (unused) coupons can be burned by the municipality (e.g., expiry, program cancellation, administrative cleanup).
- **No self-burn, no self-update** — only the municipality (mint/burn) and role-holding hospitals (`markVaccinated`) can act on a coupon.

### Vaccinator authorization: a three-party model

This is the first credential where the issuer (municipality) isn't the only party that can act on a token:

- The municipality grants `VACCINATOR_ROLE` to a specific hospital address.
- **On-chain precondition**: that address must, at grant time, hold a valid corporate registration NFT (registered as a specially-regulated 医療法人 corporation, per the [corporations](../../corporations/) design) — checked via a cross-contract call, the same general pattern as `ResidentLink` checks elsewhere.
- **Off-chain responsibility**: whether this hospital is actually a legitimate, properly-licensed medical institution the municipality wants to contract with is the municipality's own due diligence — holding a corporate registration is a necessary but not sufficient on-chain signal.
- A `VACCINATOR_ROLE` holder can call `markVaccinated` on any `Issued` coupon in that municipality's contract for that vaccine type.

### `ResidentLink` precondition: municipality is always the resident's own

Unlike diploma, license, and health insurance — where the applicant declares which `ResidentLink` contract to check, since the issuing authority (a school, prefecture, insurer) isn't necessarily tied to the person's specific municipality — a vaccination coupon's issuing municipality *is*, by definition, the recipient's own municipality. The `VaccinationCoupon` contract therefore references its own deploying municipality's `ResidentLink` contract directly, with no applicant-declared parameter needed — a simplification specific to this credential's structure.

## Open items for later

None specific to this credential. This completes the originally-listed set of six credential examples (passport, diploma, license, health-insurance, employee-id, vaccination).

---

# 接種証明(日本語)

**ステータス: 🟢 設計確定。** 当初挙げられていた[公的証明](../)の例の6番目で最後の具体例、[パスポート](../passport/)・[卒業証明](../diploma/)・[免許証](../license/)・[健康保険証](../health-insurance/)・[社員証](../employee-id/)に続くもの。ユーザーとの議論を通じて概念・アーキテクチャ上の論点は解決済み(議論の途中でモデルの修正あり)。詳細な議論の経緯は [`discussion-log.md`](discussion-log.md)、正式なADRは [`docs/decisions/0011-vaccination-credential.md`](../../../decisions/0011-vaccination-credential.md) を参照。コントラクトコードはまだ実装していません。

## 概要

市区町村が発行する、譲渡不可の**接種券**NFTで、`Issued`(接種対象、未接種)と`Vaccinated`(接種済み)という2段階のライフサイクルを持ちます。これまでのアイデンティティ系クレデンシャルとは異なり、接種が行われた際にステータスを変更するのは、発行主体の市区町村ではなく**病院**です。この権限は、市区町村が、既に(医療法人としての)有効な法人登録を保有しているアドレスにのみ付与します。これは法人設計に続き、実質的なオンチェーンの可変状態(状態フィールド)を必要とする2例目のクレデンシャルであり、発行主体だけが権限を持つのではなく、三者間(発行主体、更新者、保有者)の認可モデルを必要とする初めてのクレデンシャルです。

## スコープ

**対象:** 市区町村が自らの住民に発行する接種券で、市区町村が実施する任意のワクチンの種類について、病院側での接種完了のマーキングを含む。

**対象外:**
- 医学的な順序ロジック(接種順序、最小間隔、年齢・資格要件、医学的禁忌) — 接種を行う市区町村の現実の臨床上の責任のまま。
- 状態フィールド以外のデータ(接種日、ロット番号、実施医療機関の識別情報等) — 市区町村・病院それぞれの記録にオフチェーンで残す。

## オンチェーン/オンライン/オフラインの内訳

(規約は[`docs/operations/README.md`](../../../operations/README.md)参照)

**オンチェーン:**
- mint(市区町村の管理者ロールに限定)。受領者が、発行市区町村**自身**の`ResidentLink`コントラクトで有効な`ResidentLink`NFTを保有していることを要件とする(申告パラメータなし — [アーキテクチャ](#residentlinkの前提条件市区町村は常に本人自身の居住先)参照)。
- `markVaccinated`(`VACCINATOR_ROLE`を保有するアドレスのみ呼び出し可能)、接種券のステータスを`Issued`から`Vaccinated`に変更する。
- `VACCINATOR_ROLE`の付与(市区町村の管理者ロールに限定)。候補のアドレスが有効な法人登録NFTを保有していることをオンチェーンで確認する。
- burn(市区町村の管理者ロールに限定)。接種券が`Issued`の間**のみ**可能。
- 譲渡不可の所有権(`tokenId ↔ アドレス`)に加えて状態フィールド — 法人を除き、トークンごとの実質的な状態を持つ唯一のクレデンシャル。

**オンライン:**
- 市区町村の、公式に証明された`VaccinationCoupon`コントラクトアドレス。`.lg.jp`配下で公表 — `ResidentLink`と同じ仕組み。

**オフライン:**
- どの病院と契約し`VACCINATOR_ROLE`を付与するかという市区町村のデューデリジェンス — 登録法人であることはオンチェーンの必要条件だが、この実質的な審査の代わりにはならない。
- 実際の接種行為そのもの(接種の実施、資格・タイミングに関する臨床判断)。
- 接種スケジュール、間隔、医学的な順序。

## アーキテクチャ

### コントラクト: `VaccinationCoupon`(市区町村がワクチンの種類ごとに発行)

譲渡不可のERC-721ベースのトークンですが、法人を除く他の全てのクレデンシャルとは異なり、トークンごとの実質的な状態を持ちます。

- **トークンごとに1つの状態フィールド**: `enum Status { Issued, Vaccinated }` — 公的証明全体のフィールドを持たないというルールへの、意図的で正当な例外です。2段階の接種券→接種完了というライフサイクルは、それ以外の方法では表現できないためです。
- **市区町村×ワクチンの種類ごとに1コントラクト** — 例: 「A市 COVID-19ワクチン接種券」「A市 麻疹ワクチン接種券」を別々に発行。免許証・健康保険証の単一コントラクトへの集約とは異なり、どのワクチンを受けたかを確認すること自体が目的であることが多いため、卒業証明のより細かい粒度の考え方を踏襲します。
- **譲渡不可(Soulbound)** — 他のクレデンシャルとの一貫性のためだけでなく、予防接種の予約枠の転売・スキャルピングを防止するという明示的な目的のためです。
- **それ以外のトークンごとのデータはなし** — 接種日、ロット番号、実施医療機関の識別情報はオンチェーンに載せず、市区町村・病院それぞれの記録に残します。

### ライフサイクル

上記の英語版の図を参照してください(内容は同一です)。

- **複数回接種＝複数の別々の接種券。** 各接種(初回シリーズ、ブースター等)は、同じワクチン種類のコントラクトからの新しいmintであり、それぞれ独立して`Issued`→`Vaccinated`を辿ります。完全に接種を終えた人は、時間とともに複数の恒久的な`Vaccinated`トークンを蓄積します — 接種履歴は、保有者のトークンとその状態を列挙することで導出でき、専用の「接種回数」フィールドは不要です。
- **`Vaccinated`は恒久的 — 決してburnしません。** burnできるのは市区町村による`Issued`(未使用)の接種券のみです(例: 期限切れ、プログラム中止、事務的な整理)。
- **自主バーン・自己更新はなし** — 市区町村(mint/burn)と、ロールを持つ病院(`markVaccinated`)のみが接種券に対して操作できます。

### 接種実施者の認可: 三者間モデル

これは、発行主体(市区町村)だけがトークンに対して操作できるわけではない、初めてのクレデンシャルです。

- 市区町村が、特定の病院のアドレスに`VACCINATOR_ROLE`を付与します。
- **オンチェーンの前提条件**: そのアドレスは、付与時点で、有効な法人登録NFT([法人設計](../../corporations/)による、特殊な規制対象法人としての医療法人登録)を保有している必要があります — `ResidentLink`の確認と同じ一般的なパターンで、クロスコントラクトの呼び出しにより確認します。
- **オフチェーンの責任**: その病院が実際に正当で適切な資格を持つ医療機関であり、市区町村が契約したい相手かどうかは、市区町村自身のデューデリジェンスです — 法人登録を保有していることは、オンチェーンの必要条件ではありますが、十分条件ではありません。
- `VACCINATOR_ROLE`を持つ者は、その市区町村のそのワクチンの種類のコントラクトにある、任意の`Issued`状態の接種券に対して`markVaccinated`を呼び出せます。

### `ResidentLink`の前提条件: 市区町村は常に本人自身の居住先

卒業証明・免許証・健康保険証(発行主体(学校、都道府県、保険者)が必ずしも本人の特定の市区町村に紐づかないため、申請者がどの`ResidentLink`コントラクトを確認するか申告する)とは異なり、接種券の発行市区町村は、定義上、受領者**自身**の居住市区町村です。したがって`VaccinationCoupon`コントラクトは、申告パラメータなしに、デプロイした市区町村自身の`ResidentLink`コントラクトを直接参照できます — このクレデンシャルの構造に特有の簡略化です。

## 今後の課題

このクレデンシャル固有のものはありません。これで、当初挙げられていた6つの証明の例(パスポート、卒業証明、免許証、健康保険証、社員証、接種証明)が全て出揃いました。

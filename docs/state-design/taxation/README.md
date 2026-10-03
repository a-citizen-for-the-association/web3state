# Taxation: Payment (納税)

**Status: 🟢 Spec drafted.** Conceptual and architecture questions resolved through discussion with the user; see [`discussion-log.md`](discussion-log.md) for the full reasoning and [`docs/decisions/0004-taxation-payment-rail.md`](../../decisions/0004-taxation-payment-rail.md) for the formal ADR. No contract code written yet (none is expected to be needed — see [Architecture](#architecture)).

## Summary

This feature covers only the **payment rail** for taxes an individual (natural person) owes: moving an already-determined amount from the taxpayer to the correct tax authority, using an existing JPY-pegged stablecoin. It deliberately does **not** cover: computing how much is owed, proving that amount is correct, refunds/overpayment, or corporate taxes (to be designed separately).

The mechanism: a resident pays directly from their [`ResidentLink`](../citizenship/) NFT-holding address to a verified, officially-published receiving address for the specific tax and authority involved. The amount itself is determined the same way it is today — through the existing real-world filing/assessment process (確定申告, 年末調整, etc.) — entirely outside this system.

## Scope

**In scope:** any tax an individual pays *directly, by their own initiative* — e.g. 住民税 (普通徴収), 固定資産税, 自動車税, 所得税 (確定申告分), 相続税, 贈与税.

**Out of scope (see [`docs/BACKLOG.md`](../../BACKLOG.md) for tracking):**
- Corporate taxes — a separate feature.
- Tax amount calculation and correctness verification — determined off-chain via existing legal processes, exactly as today.
- Refunds, overpayment, underpayment, late-payment penalties (延滞税) — follow-on concerns of calculation/correctness, same exclusion.
- **Source-withheld taxes** (住民税特別徴収, 所得税源泉徴収) — these involve the employer as a withholding agent remitting on an employee's behalf, a materially different process from an individual paying directly. This project's position is **not** to design an on-chain equivalent of employer withholding, but to treat withholding itself as something to eventually *eliminate* — once financial-product tokenization (insurance, loans — tracked in [`docs/BACKLOG.md`](../../BACKLOG.md)) makes deduction data derivable on-chain, and once the legal requirement for employers to withhold is removed. Until then, withheld income stays entirely outside this project, handled off-chain as it is today. (Interim note: before that transition, on-chain-visible salary may be net-of-withholding under current practice — this spec does not model that transition period, only the eventual steady state.)

## On-chain / Online / Offline breakdown

(See [`docs/operations/README.md`](../../operations/README.md) for the convention.)

**On-chain:**
- The payment itself: a standard token transfer (e.g. ERC-20 `transfer`) of an existing JPY-pegged stablecoin, from the taxpayer's `ResidentLink` address to the tax authority's published receiving address.
- Nothing else. No tax-specific contract, no on-chain amount/status tracking.

**Online:**
- Each (tax type, authority) pair's officially-attested receiving address, published at a well-known URI under the authority's own vetted government domain (extending the mechanism from the citizenship design).

**Offline:**
- The taxpayer determines the amount owed via the existing real-world process (確定申告, 年末調整, assessment notices, etc.), unchanged by this project.
- Reconciliation — matching a specific on-chain payment to a specific taxpayer's obligation, verifying the asset received was a legitimate recognized stablecoin and not a worthless look-alike token, handling any discrepancy — is entirely the tax authority's existing off-chain process. This project does not add on-chain enforcement for any of it.

## Architecture

### No dedicated smart contract

Given the scope above, this feature needs no bespoke contract. The entire mechanism is:

1. The relevant authority (municipality, prefecture, or national body) publishes a verified receiving address for each tax type it collects.
2. The taxpayer calls the stablecoin's standard `transfer()` from their `ResidentLink` address to that published address.

### Receiving-address attestation (extends the citizenship design)

Reuses the exact mechanism from [citizenship's official-contract attestation](../citizenship/README.md#proving-an-official-municipality-contract), generalized:

- **Municipalities and prefectures** (both 地方公共団体) publish under their own `.lg.jp` domain — no new mechanism needed; covers 住民税, 固定資産税, 自動車税, etc.
- **National bodies** (e.g. 国税庁, nta.go.jp) publish under `.go.jp` — the same principle (a well-known URI under an institutionally-vetted government domain), applied to a different root domain. Covers 所得税 (self-assessed), 相続税, 贈与税.
- **Schema:** rather than a separate announcement format per feature, extend the same well-known JSON each authority already publishes (e.g. `https://<authority-domain>/.well-known/web3state-registry.json`) with a tax-type → receiving-address mapping, so one authority handling multiple tax types (e.g. 国税庁) publishes one address per tax type — letting the destination address itself signal which tax a payment is for, just as the sender address signals which resident paid.
- **No accepted-token allowlist.** An address can technically receive any token; whether a received token is a legitimate, valuable stablecoin is checked by the authority during its existing off-chain reconciliation process, the same way amount-correctness already is — no on-chain restriction needed.

### Relationship to the citizenship design

Payment is made from the taxpayer's `ResidentLink` address, the same address used to prove residency. This is a **deliberate choice, not an oversight**: it means anyone can observe a given (pseudonymous but persistent) resident's approximate income and tax payments on-chain. The user's explicit position: this is acceptable because the real person is not identified by it — only the address is. It also gives a side benefit with no extra mechanism: the sending address itself serves as the payer's reference, the on-chain equivalent of the reference number on a real-world 納付書.

## Open items for later

Tracked in [`docs/BACKLOG.md`](../../BACKLOG.md), not just here:
- Financial-product (insurance, loan) tokenization enabling on-chain deduction data.
- Official-issuer attestation for private regulated financial institutions (banks, insurers) — likely anchored to a regulator such as 金融庁, since neither `.lg.jp` nor `.go.jp` applies to them.
- Privacy review for insurance/loan tokens once designed.
- Abolition of employer withholding, contingent on the above plus legal reform.
- Implementing the `.go.jp`-anchored attestation for 国税庁 specifically (principle resolved; just needs doing at implementation time).

---

# 納税(日本語)

**ステータス: 🟢 設計確定。** ユーザーとの議論を通じて概念・アーキテクチャ上の論点は解決済み。詳細な議論の経緯は [`discussion-log.md`](discussion-log.md)、正式なADRは [`docs/decisions/0004-taxation-payment-rail.md`](../../decisions/0004-taxation-payment-rail.md) を参照。コントラクトコードはまだ実装していません(そもそも必要ない見込みです — [アーキテクチャ](#アーキテクチャ)を参照)。

## 概要

この機能がカバーするのは、個人(自然人)が支払う税の**決済レールのみ**です: 既に決まった金額を、既存のJPYペッグのステーブルコインを使って、納税者から正しい徴収主体へ移動させること。意図的に対象外としているのは: 金額の計算、その正確性の証明、還付・過不足、そして法人税(別途設計予定)です。

仕組み: 住民は[`ResidentLink`](../citizenship/)NFTを保有するアドレスから、その税・その主体について公式に証明・公表された受取アドレスへ直接支払います。金額そのものは、今日と全く同じ方法(確定申告、年末調整など、既存の現実のプロセス)で、このシステムの外側で決まります。

## スコープ

**対象:** 個人が自らの意思で直接支払う税 — 例: 住民税(普通徴収)、固定資産税、自動車税、所得税(確定申告分)、相続税、贈与税。

**対象外(追跡は[`docs/BACKLOG.md`](../../BACKLOG.md)参照):**
- 法人税 — 別機能として設計。
- 税額の計算・正確性の検証 — 今日と同じく既存の法制度上のプロセスでオフチェーンで決定。
- 還付・過不足・延滞税 — 計算・正確性に付随する論点として同様に対象外。
- **源泉徴収される税**(住民税特別徴収、所得税源泉徴収) — 雇用主が源泉徴収義務者として従業員に代わって納付する、個人の直接支払いとは全く異なるプロセスです。本プロジェクトの方針は、雇用主の源泉徴収をオンチエーンで再現することでは**なく**、源泉徴収そのものをいずれ**廃止すべきもの**として扱うことです — 金融商品(保険・ローン、[`docs/BACKLOG.md`](../../BACKLOG.md)で追跡)のトークン化によって控除データがオンチェーンから入手可能になり、かつ雇用主の源泉徴収義務をなくす法改正が行われた時点で、です。それまでは、源泉徴収される所得は本プロジェクトの対象外とし、今まで通りオフチェーンで扱います。(移行期の注記: その移行が完了するまでは、オンチェーンで見える給与は現行の慣行上、源泉徴収後の手取り額になりうります。本設計書は、その移行期間ではなく、最終的な定常状態のみを対象としています。)

## オンチェーン/オンライン/オフラインの内訳

(規約は[`docs/operations/README.md`](../../operations/README.md)参照)

**オンチェーン:**
- 支払いそのもの: 既存のJPYペッグのステーブルコインの標準的なトークン送金(例: ERC-20の`transfer`)。納税者の`ResidentLink`アドレスから、徴収主体の公表された受取アドレスへ。
- それ以外は何もありません。税専用のコントラクトも、オンチェーンでの金額・状態の追跡もありません。

**オンライン:**
- (税目, 主体)のペアごとに公式に証明された受取アドレス。主体自身の審査済みの政府ドメイン配下のwell-known URIで公表(citizenship設計の仕組みを拡張)。

**オフライン:**
- 納税者は既存の現実のプロセス(確定申告、年末調整、賦課決定通知など、本プロジェクトによって変更されない)で納付額を決定します。
- 照合 — 特定のオンチエーン支払いを特定の納税者の納税義務に対応づけること、受け取った資産が正規の認められたステーブルコインであり偽物でないことの確認、不一致への対応 — は全て徴収主体の既存のオフチェーンプロセスです。本プロジェクトはこれらのいずれにもオンチェーンでの強制を追加しません。

## アーキテクチャ

### 専用スマートコントラクトなし

上記のスコープを前提にすると、この機能に独自のコントラクトは不要です。仕組み全体は以下の2ステップです。

1. 関連する主体(市区町村、都道府県、または国の機関)が、徴収する税目ごとに検証済みの受取アドレスを公表する。
2. 納税者が、自分の`ResidentLink`アドレスから、公表されたアドレスへ、ステーブルコインの標準的な`transfer()`を呼ぶ。

### 受取アドレスの証明(citizenship設計の拡張)

[citizenshipの公式コントラクト証明の仕組み](../citizenship/README.md#proving-an-official-municipality-contract)と全く同じ仕組みを、一般化して流用します。

- **市区町村・都道府県**(いずれも地方公共団体)は、自身の`.lg.jp`ドメイン配下で公表します — 新しい仕組みは不要。住民税、固定資産税、自動車税などをカバーします。
- **国の機関**(例: 国税庁、nta.go.jp)は`.go.jp`配下で公表します — 原理は同じ(審査済みの政府ドメイン配下のwell-known URI)で、ルートドメインが異なるだけです。所得税(申告分)、相続税、贈与税をカバーします。
- **スキーマ:** 機能ごとに別の発表フォーマットを作るのではなく、各主体が既に公表しているのと同じwell-known JSON(例: `https://<主体のドメイン>/.well-known/web3state-registry.json`)に、税目→受取アドレスのマッピングを追加します。これにより、複数の税目を扱う単一の主体(例: 国税庁)は税目ごとに1つのアドレスを公表でき、受取アドレス自体が「どの税の支払いか」を示すことになります(送金元アドレスが「どの住民が払ったか」を示すのと対になります)。
- **受け付けトークンの許可リストはなし。** アドレスは技術的にはどんなトークンでも受け取れます。受け取ったトークンが正規の価値あるステーブルコインかどうかは、金額の正確性と同様、主体の既存のオフチェーン照合プロセスで確認されます。オンチェーンでの制限は不要です。

### citizenship設計との関係

支払いは、住民であることを証明するのと同じ`ResidentLink`アドレスから行われます。これは**見落としではなく意図的な選択**です: つまり、誰でもある(匿名だが永続的な)住民のおおよその収入・納税額をオンチェーンで観測できることになります。ユーザーの明確な立場: 実在の人物そのものが特定されるわけではないので、これは許容できる、というものです。また、追加の仕組みなしに副次的な利点もあります: 送金元アドレス自体が納税者の参照番号として機能し、現実世界の納付書の整理番号に相当します。

## 今後の課題

ここだけでなく[`docs/BACKLOG.md`](../../BACKLOG.md)でも追跡:
- オンチェーンの控除データを可能にする金融商品(保険・ローン)のトークン化。
- 銀行・保険会社といった民間の規制対象金融機関向けの公式発行体証明(`.lg.jp`も`.go.jp`も直接は使えないため、金融庁のような規制当局を起点にする想定)。
- 保険・ローントークン設計時のプライバシーレビュー。
- 上記と法改正を前提とした、雇用主の源泉徴収の廃止。
- 国税庁向けの`.go.jp`に基づく証明の実装(原理は解決済み、実装時にやるだけ)。

# Unemployment insurance (雇用保険)

**Status: 🟢 Spec drafted.** Screened with the on-chain value test and resolved through discussion with the user; see [`discussion-log.md`](discussion-log.md) for the reasoning and [ADR 0026](../../decisions/0026-unemployment-insurance-model.md) for the formal decision. No contract code written yet.

## Summary

**No new contract.** Unemployment insurance combines three earlier designs: premiums follow pension ([ADR 0024](../../decisions/0024-pension-model.md)), benefits follow benefits ([ADR 0025](../../decisions/0025-benefits-model.md)), and the training benefit and the employer-side subsidies follow subsidies ([ADR 0023](../../decisions/0023-subsidies-model.md)). What is new is that the most common fraud, **working while receiving benefit, becomes visible**: a salary arriving at the recipient's address, or a new `EmployeeID` minted to it, is flagged.

## Scope

**In scope:** unemployment-insurance premiums and benefits: the job-seeker's benefit (基本手当), childcare-leave benefit (育児休業給付), education and training benefit (教育訓練給付), and the others.

**Out of scope:**
- The employment adjustment subsidy and other 二事業 subsidies to employers: they follow the subsidies design (ADR 0023).
- Workers' accident compensation (労災保険): recorded in [`docs/BACKLOG.md`](../../BACKLOG.md).
- Job placement, the unemployment check and job-search activity: off-chain judgement.

## On-chain / Online / Offline breakdown

(See [`docs/operations/README.md`](../../operations/README.md) for the convention.)

**On-chain (all existing):**
- One unemployment-insurance `PublicTreasury` ([ADR 0019](../../decisions/0019-treasury-model.md)), today's 労働保険特別会計 雇用勘定.
- Personal premiums: transfers from each insured employee's `ResidentLink` address. The 二事業 part: transfers from the employer's corporate address.
- `EmployeeID` mint and burn ([ADR 0010](../../decisions/0010-employee-id-credential.md)); salaries ([ADR 0020](../../decisions/0020-certified-address-stablecoin.md)).
- Benefits: `pay()` to the recipient's `ResidentLink` address with the shared social-security budget code.
- Training fees: transfers from the trainee to the registered provider.
- Hashes of the employer's statement of the reason for leaving and of Hello Work's decisions, in the labour bureau's `DocumentRegistry` ([ADR 0017](../../decisions/0017-executive-document-anchoring-v1.md)).

**Online:**
- Monthly totals per kind of benefit (as in ADR 0025).
- Applications that compute each person's insured months and benefit amount from public data.

**Offline:**
- The reason for leaving, the unemployment check, job-search activity, and disputes.
- Flags for working while receiving, under the consent rule of ADR 0025.
- Detection of training-fee kickbacks and of employers that do not enrol staff.

## Rules

1. **Premiums.** The employee pays the whole insurance part from their own `ResidentLink` address; the employer's former half of that part is added to pay. The employer alone pays the 二事業 part from its corporate address. Both go to the same treasury; the sender's kind tells them apart (Round 2 adjustment).
2. **Insured months** are computed from the premium transfers (oldest unpaid month first, as for pension) and the `EmployeeID` mint and burn. This replaces the employment-period part of the separation notice.
3. **The reason for leaving** is a judgement: the employer's statement and Hello Work's decision are anchored by hash; disputes are settled off-chain.
4. **Benefits** use the shared social-security budget code (ADR 0025). The amount depends on wages before leaving, which are on-chain, so the person can recompute it.
5. **Working while receiving** is checked with consent, during the receipt period only. For the job-seeker's benefit, any salary inflow or new `EmployeeID` is flagged. For the childcare-leave benefit, only employer pay above the legal limit during leave is flagged (Round 2 adjustment). The person still reports; the chain checks the report.
6. **Training benefit:** fees must be paid in the JPY stablecoin to the registered provider's address; cash-paid fees are not eligible. Money flowing back from the provider to the trainee is flagged off-chain.

## Known limits

- Cash work is invisible, as today.
- Whether a person is genuinely seeking work, and the reason for leaving, remain judgements.
- Employees can fall into arrears, as with pension.

---

# 雇用保険(日本語)

**ステータス: 🟢 設計確定。** オンチェーン価値テストで選別し、ユーザーとの議論で解決した。理由は[`discussion-log.md`](discussion-log.md)、正式な決定は[ADR 0026](../../decisions/0026-unemployment-insurance-model.md)を参照。コントラクトコードはまだない。

## 概要

**新しいコントラクトは作らない。** 雇用保険は、これまでの3つの設計の組み合わせである。保険料は年金([ADR 0024](../../decisions/0024-pension-model.md))に、給付は各種手当([ADR 0025](../../decisions/0025-benefits-model.md))に、教育訓練給付と雇用主向けの助成金は補助金([ADR 0023](../../decisions/0023-subsidies-model.md))に従う。新しいのは、最も多い不正である**受給中の就労が見えるようになる**ことである。受給者のアドレスに給与が入ったり、新しい`EmployeeID`がmintされたりすれば検知される。

## スコープ

**対象:** 雇用保険の保険料と給付。基本手当、育児休業給付、教育訓練給付、その他。

**対象外:**
- 雇用調整助成金などの雇用主向けの二事業の助成金: 補助金の設計(ADR 0023)に従う。
- 労災保険: [`docs/BACKLOG.md`](../../BACKLOG.md)に記録する。
- 職業紹介、失業認定、求職活動: オフチェーンの判断。

## オンチェーン/オンライン/オフラインの内訳

(区分の考え方は[`docs/operations/README.md`](../../operations/README.md)を参照。)

**オンチェーン(すべて既存):**
- 雇用保険の`PublicTreasury`を1つ([ADR 0019](../../decisions/0019-treasury-model.md))。現在の労働保険特別会計 雇用勘定にあたる。
- 個人の保険料: 被保険者である各従業員の`ResidentLink`アドレスからの送金。二事業の部分: 雇用主の法人アドレスからの送金。
- `EmployeeID`のmintとburn([ADR 0010](../../decisions/0010-employee-id-credential.md))、給与([ADR 0020](../../decisions/0020-certified-address-stablecoin.md))。
- 給付: 受給者の`ResidentLink`アドレスへの`pay()`。社会保障の共通予算コードを使う。
- 受講料: 受講者から登録済みの提供者への送金。
- 雇用主による離職理由の申し立てと、ハローワークの決定のハッシュ。労働局の`DocumentRegistry`([ADR 0017](../../decisions/0017-executive-document-anchoring-v1.md))に記録する。

**オンライン:**
- 給付の種類ごとの毎月の合計(ADR 0025と同じ)。
- 公開データから各人の被保険者期間と給付額を計算するアプリケーション。

**オフライン:**
- 離職理由、失業認定、求職活動、争い。
- ADR 0025の同意のルールのもとでの、受給中の就労の検知。
- 受講料のキックバックと、従業員を加入させない雇用主の検出。

## ルール

1. **保険料。** 従業員は労使負担の部分の全額を自分の`ResidentLink`アドレスから払う。その部分の以前の雇用主負担分は給与に上乗せする。二事業の部分は雇用主だけが法人アドレスから払う。どちらも同じ国庫に払い、送信元の種類で区別する(Round 2の調整)。
2. **被保険者期間**は、保険料の送金(年金と同じく未納の最も古い月から充てる)と`EmployeeID`のmint・burnから計算する。これで離職票の雇用期間の部分は不要になる。
3. **離職理由**は判断の問題である。雇用主の申し立てとハローワークの決定はハッシュでアンカリングし、争いはオフチェーンで解決する。
4. **給付**は社会保障の共通予算コード(ADR 0025)を使う。金額は離職前の給与で決まり、それはオンチェーンにあるので、本人が再計算できる。
5. **受給中の就労**は、同意に基づき、受給期間中に限って確認する。基本手当では、給与の入金や新しい`EmployeeID`をすべて検知する。育児休業給付では、休業中に法律の上限を超える雇用主からの給与だけを検知する(Round 2の調整)。本人は引き続き申告し、チェーンがその申告を確かめる。
6. **教育訓練給付:** 受講料は円建てステーブルコインで登録済みの提供者のアドレスに支払わなければならず、現金で支払った受講料は対象外とする。提供者から受講者に戻るお金はオフチェーンで検知する。

## 既知の限界

- 現金での就労は、今と同じく見えない。
- 本当に求職しているか、離職理由は何かは、判断の問題として残る。
- 年金と同じく、従業員の滞納が起こりうる。

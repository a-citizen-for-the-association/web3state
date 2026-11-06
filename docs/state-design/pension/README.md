# Pension (年金)

**Status: 🟢 Spec drafted.** Screened with the on-chain value test and resolved through discussion with the user; see [`discussion-log.md`](discussion-log.md) for the reasoning and [ADR 0024](../../decisions/0024-pension-model.md) for the formal decision. No contract code written yet.

## Summary

**No new contract.** A pension contribution is a stablecoin transfer from the insured person's own `ResidentLink` address to the pension `PublicTreasury`, and **that transfer is the contribution record**. It cannot be lost, mis-entered or credited to someone else, so the 2007 "lost pensions" problem disappears structurally. Employees pay their whole Employees' Pension premium themselves; the employer's half becomes part of pay, consistent with the project's direction of eliminating withholding. Benefits are ordinary treasury payments, and stop automatically when a registered death burns the recipient's `ResidentLink`. Anyone can recompute a person's entitlement from public data plus that person's anchored decisions.

## Scope

**In scope:** the public pensions, i.e. the National Pension (国民年金) and Employees' Pension (厚生年金): contributions, contribution records, entitlement decisions and benefit payments (old-age, survivors', disability).

**Out of scope:**
- Reserve-fund investment (GPIF): a financial-market function, already disclosed (🚫 as a sub-part, like government bonds in [ADR 0019](../../decisions/0019-treasury-model.md)).
- Private and corporate pensions (iDeCo, DB/DC): private financial products, under the financial-infrastructure theme in [`docs/BACKLOG.md`](../../BACKLOG.md).
- Pension policy itself (rates, benefit formulas, finances): political.

## On-chain / Online / Offline breakdown

(See [`docs/operations/README.md`](../../operations/README.md) for the convention.)

**On-chain (all existing):**
- Two `PublicTreasury` contracts for the pension special account: one for the National Pension, one for Employees' Pension ([ADR 0019](../../decisions/0019-treasury-model.md)).
- Contributions: transfers from each insured person's `ResidentLink` address to the relevant treasury.
- Salaries, which determine Employees' Pension premiums: certified-address transfers ([ADR 0020](../../decisions/0020-certified-address-stablecoin.md)).
- Benefits: `pay()` from the pension treasury to the recipient's `ResidentLink` address, with one generic pension budget code.
- Hashes of award decisions (裁定), exemption and deferral decisions, and category 3 determinations, in the pension body's `DocumentRegistry` ([ADR 0017](../../decisions/0017-executive-document-anchoring-v1.md)).

**Online:**
- The two treasury addresses, published under the pension body's `.go.jp` domain.
- Totals of benefits per kind (old-age, survivors', disability), for audit.
- Applications that compute each person's month-by-month record and entitlement from public data (replacing the paper 年金定期便).

**Offline:**
- Eligibility, exemptions, category 3 status and award decisions (the person keeps the documents).
- Existence checks for unreported deaths.
- Analysis: employers paying salaries to `EmployeeID` holders who make no or too small Employees' Pension contributions; pension addresses that receive but never spend.
- Reminders and enforcement for unpaid premiums.

## Rules

1. **The contribution record is the transfer.** Premiums are paid only from the insured person's own `ResidentLink` address. The sending address identifies the person ([ADR 0004](../../decisions/0004-taxation-payment-rail.md)); the receiving treasury identifies the scheme.
2. **Employees pay their whole premium themselves** (Issue 3(a)). The employer's former half is part of gross pay. The premium is computed from pay, which is itself on-chain, so under-declaring pay cannot be hidden.
3. **Allocation to months is fixed by law:** each payment covers the oldest unpaid month first. Anyone computes the same record from the transfers.
4. **Decisions that change entitlement but cannot be derived from the chain** (exemptions, deferrals, category 3, awards) are anchored by hash only. Their content stays private; the person can later prove them.
5. **One budget code for all pension benefits,** so a payment does not reveal disability or widowhood.
6. **Everything on-chain is public,** per address, like every other payment to or from an individual ([ADR 0019](../../decisions/0019-treasury-model.md)).
7. **Death:** a registered death burns the `ResidentLink`, and later payments revert. Pension still owed at death (未支給年金) is paid to the survivors' addresses as an ordinary payment.
8. **Address changes:** a move keeps the same address. Key loss or other replacement goes through successor migration ([ADR 0020](../../decisions/0020-certified-address-stablecoin.md)), whose on-chain link carries the contribution history over.
9. **Unpaid premiums,** including an employee who does not pay, are handled like category 1 delinquency: reminder, then enforcement through [ADR 0018](../../decisions/0018-judiciary-model.md)'s address identification.

## Known limits

- Unreported deaths are still found by off-chain existence checks; analysis can only flag suspicious addresses.
- Employees can now fall into arrears, which withholding prevented.
- Contribution and benefit amounts per address are public. The address is pseudonymous, but this covers almost every adult.
- Records from before the transition are not on-chain; they stay in the old system.

---

# 年金(日本語)

**ステータス: 🟢 設計確定。** オンチェーン価値テストで選別し、ユーザーとの議論で解決した。理由は[`discussion-log.md`](discussion-log.md)、正式な決定は[ADR 0024](../../decisions/0024-pension-model.md)を参照。コントラクトコードはまだない。

## 概要

**新しいコントラクトは作らない。** 年金の保険料は、被保険者自身の`ResidentLink`アドレスから年金の`PublicTreasury`へのステーブルコインの送金であり、**その送金が納付記録である**。消えることも、入力を誤ることも、他人のものとされることもないので、2007年の「消えた年金」は構造的に起こらなくなる。会社員は厚生年金の保険料を全額自分で払い、雇用主負担分は給与の一部になる。これは源泉徴収を廃止するというプロジェクトの方向と一致する。年金給付は通常の歳出の支払いであり、届出済みの死亡で受給者の`ResidentLink`がburnされると自動的に止まる。誰でも、公開データと本人のアンカーされた決定から、その人の年金額を再計算できる。

## スコープ

**対象:** 公的年金、すなわち国民年金と厚生年金の保険料、納付記録、裁定、年金給付(老齢・遺族・障害)。

**対象外:**
- 積立金の運用(GPIF): 金融市場の機能で、すでに公開されている(部分として🚫。[ADR 0019](../../decisions/0019-treasury-model.md)の国債と同じ)。
- 私的・企業年金(iDeCo、DB/DC): 民間の金融商品で、[`docs/BACKLOG.md`](../../BACKLOG.md)の金融基盤のテーマに含まれる。
- 年金政策そのもの(保険料率、給付の算式、財政): 政治の問題。

## オンチェーン/オンライン/オフラインの内訳

(区分の考え方は[`docs/operations/README.md`](../../operations/README.md)を参照。)

**オンチェーン(すべて既存):**
- 年金特別会計の2つの`PublicTreasury`: 国民年金用と厚生年金用([ADR 0019](../../decisions/0019-treasury-model.md))。
- 保険料: 各被保険者の`ResidentLink`アドレスから該当する国庫への送金。
- 厚生年金の保険料を決める給与: 認定アドレス間の送金([ADR 0020](../../decisions/0020-certified-address-stablecoin.md))。
- 年金給付: 年金の国庫から受給者の`ResidentLink`アドレスへの`pay()`。年金共通の予算コードを1つだけ使う。
- 裁定、免除・猶予の決定、第3号の認定のハッシュ。年金を扱う機関の`DocumentRegistry`([ADR 0017](../../decisions/0017-executive-document-anchoring-v1.md))に記録する。

**オンライン:**
- 2つの国庫のアドレス。年金を扱う機関の`.go.jp`ドメインで公表する。
- 監査のための、種類ごと(老齢・遺族・障害)の給付の合計。
- 公開データから各人の月ごとの記録と年金額を計算するアプリケーション(紙の年金定期便に代わる)。

**オフライン:**
- 受給資格、免除、第3号の認定、裁定(本人が文書を保管する)。
- 未届の死亡の現況確認。
- 分析: `EmployeeID`保有者に給与を払っているのに、その従業員の厚生年金の保険料がない、または少なすぎる雇用主。年金を受け取るのにまったく使われないアドレス。
- 未納の保険料の督促と強制徴収。

## ルール

1. **納付記録は送金そのもの。** 保険料は被保険者自身の`ResidentLink`アドレスからのみ払う。送信元アドレスが本人を([ADR 0004](../../decisions/0004-taxation-payment-rail.md))、受け取る国庫が制度を示す。
2. **会社員は保険料を全額自分で払う**(論点3(a))。以前の雇用主負担分は額面の給与に含まれる。保険料はそれ自体オンチェーンにある給与から計算されるので、報酬の過少申告は隠せない。
3. **何月分に充てるかは法律で固定する:** 各支払いは未納の最も古い月に充てる。誰が計算しても送金から同じ記録になる。
4. **年金額を変えるがチェーンから導けない決定**(免除、猶予、第3号、裁定)は、ハッシュだけをアンカリングする。内容は非公開のままで、本人は後から証明できる。
5. **年金給付の予算コードは1つ**にし、支払いから障害や死別がわからないようにする。
6. **オンチェーンにあるものはすべて公開**で、個人へのまたは個人からのほかの支払いと同じくアドレス単位である([ADR 0019](../../decisions/0019-treasury-model.md))。
7. **死亡:** 届出済みの死亡で`ResidentLink`がburnされ、その後の支払いはrevertする。死亡時に未払いの年金(未支給年金)は、遺族のアドレスへの通常の支払いとする。
8. **アドレスの変更:** 転居では同じアドレスのまま。鍵の紛失などによる交代は承継移転([ADR 0020](../../decisions/0020-certified-address-stablecoin.md))を通り、そのオンチェーンのつながりによって納付の履歴が引き継がれる。
9. **未納の保険料**(払わない従業員を含む)は第1号の滞納と同じに扱う: 督促、その後は[ADR 0018](../../decisions/0018-judiciary-model.md)のアドレス特定による強制徴収。

## 既知の限界

- 未届の死亡は引き続きオフチェーンの現況確認で見つける。分析は不審なアドレスを示せるだけである。
- 源泉徴収では起こらなかった、会社員の滞納が起こりうる。
- アドレスごとの保険料と給付の額は公開される。アドレスは仮名だが、ほぼすべての成人が対象になる。
- 移行前の記録はオンチェーンになく、旧制度に残る。

# Subsidies / grants disbursement (補助金・交付金)

**Status: 🟢 Spec drafted.** Screened with the on-chain value test and resolved through discussion with the user; see [`discussion-log.md`](discussion-log.md) for the reasoning and [ADR 0023](../../decisions/0023-subsidies-model.md) for the formal decision. No contract code written yet.

## Summary

**No new contract.** A subsidy is an approval document (the grant decision) plus treasury payments, both of which already exist. The new rule is about evidence: **subsidised expenses must be paid in the JPY stablecoin to certified addresses**, and the expense report lists those on-chain transactions instead of paper receipts. Fake receipts become impossible. Kickbacks (money flowing back from a vendor) and duplicate claims (the same transaction in two reports) become visible to off-chain analysis of fully public data.

## Scope

**In scope:** subsidies to businesses and organisations (補助金); grants from the national government to local governments (交付金).

**Out of scope:**
- Payments to individuals (child allowances, welfare): the separate "Benefits" item.
- Judging eligibility, or whether a grant's use was wise: off-chain.

## On-chain / Online / Offline breakdown

(See [`docs/operations/README.md`](../../operations/README.md) for the convention.)

**On-chain (all existing):**
- The grant decision, anchored as an approval document in the granting body's `DocumentRegistry` ([ADR 0017](../../decisions/0017-executive-document-anchoring-v1.md)).
- Payments from the granting body's `PublicTreasury` ([ADR 0019](../../decisions/0019-treasury-model.md)), with a budget code naming the programme and the grant.
- The recipient's expense payments to vendors, which are certified-address transfers ([ADR 0020](../../decisions/0020-certified-address-stablecoin.md)).
- The hash of each expense report, anchored in the granting body's `DocumentRegistry` (Round 2 adjustment).

**Online:**
- Every grant (programme, recipient, amount) and every expense report is published, including grants to sole proprietors.

**Offline:**
- Application review and eligibility.
- Checking each expense report against the listed transactions.
- Analysis: kickbacks (vendor → recipient flows), duplicate claims (one transaction in several reports), and the use of grants by local governments.
- Repayment and penalties when fraud is found; kickbacks are illegal.

## Rules

1. **Evidence is on-chain.** Subsidised expenses must be paid in the JPY stablecoin to certified addresses. The expense report lists those transactions. **Cash-paid expenses are not eligible.**
2. **Everything is public:** grants, reports, recipients (including individuals), and amounts.
3. **Budget-code convention:** each payment names the programme and the individual grant (Round 2 adjustment).
4. **Advance payments:** any unspent amount is returned to the granting treasury as an ordinary, visible transfer (Round 2 adjustment).
5. **Grants to local governments:** when a local government spends a national grant, its treasury payments cite the grant in their budget code, so each grant's final use is traceable by anyone.

## Known limits

- Fraud in the *application* (e.g. false statements about eligibility) is still judged off-chain; some facts, such as revenue, may later be computable from on-chain commerce data.
- Collusion paid in cash or non-JPY tokens is outside the code and covered by law.
- Whether a grant was used wisely is a judgement, not a record-integrity problem.

---

# 補助金・交付金(日本語)

**ステータス: 🟢 設計確定。** オンチェーン価値テストで選別し、ユーザーとの議論で解決した。理由は[`discussion-log.md`](discussion-log.md)、正式な決定は[ADR 0023](../../decisions/0023-subsidies-model.md)を参照。コントラクトコードはまだない。

## 概要

**新しいコントラクトは作らない。** 補助金は、決裁文書(交付決定)と国庫の支払いでできており、どちらもすでに存在する。新しいのは証拠についてのルールで、**補助対象の経費は円建てステーブルコインで認定アドレスに支払わなければならず**、実績報告は紙の領収書の代わりにそのオンチェーンの取引を列挙する。偽造の領収書は不可能になる。キックバック(業者から戻るお金)と重複受給(2つの報告に同じ取引)は、完全に公開されたデータのオフチェーンの分析で見えるようになる。

## スコープ

**対象:** 事業者・団体への補助金、国から自治体への交付金。

**対象外:**
- 個人への支払い(児童手当、生活保護): 別項目の「給付」。
- 受給資格や、交付金の使い道が賢明だったかの判断: オフチェーン。

## オンチェーン/オンライン/オフラインの内訳

(区分の考え方は[`docs/operations/README.md`](../../operations/README.md)を参照。)

**オンチェーン(すべて既存):**
- 交付決定。交付する機関の`DocumentRegistry`([ADR 0017](../../decisions/0017-executive-document-anchoring-v1.md))に決裁文書としてアンカーする。
- 交付する機関の`PublicTreasury`([ADR 0019](../../decisions/0019-treasury-model.md))からの支払い。予算コードで制度と交付を示す。
- 受給者から業者への経費の支払い。認定アドレス間の送金である([ADR 0020](../../decisions/0020-certified-address-stablecoin.md))。
- 各実績報告のハッシュ。交付する機関の`DocumentRegistry`にアンカーする(Round 2の調整)。

**オンライン:**
- すべての交付(制度、受給者、金額)とすべての実績報告を公表する。個人事業主への交付も含む。

**オフライン:**
- 申請の審査と受給資格。
- 各実績報告と列挙された取引の照合。
- 分析: キックバック(業者→受給者の流れ)、重複受給(複数の報告にある1つの取引)、自治体による交付金の使い道。
- 不正が見つかった場合の返還と罰則。キックバックは違法である。

## ルール

1. **証拠はオンチェーン。** 補助対象の経費は円建てステーブルコインで認定アドレスに支払わなければならない。実績報告はその取引を列挙する。**現金で支払った経費は対象外とする。**
2. **すべて公開:** 交付、報告、受給者(個人を含む)、金額。
3. **予算コードの約束事:** 各支払いは制度と個々の交付を示す(Round 2の調整)。
4. **概算払:** 使わなかった額は、通常の見える送金として交付した国庫に返還する(Round 2の調整)。
5. **交付金:** 自治体が国の交付金を使うとき、その国庫の支払いは予算コードでその交付金を参照する。各交付金の最終的な使い道を誰でも追える。

## 既知の限界

- *申請*における不正(受給資格についての虚偽など)は引き続きオフチェーンで判断する。売上などの一部の事実は、将来オンチェーンの商取引のデータから計算できるかもしれない。
- 現金や円以外のトークンで払われる共謀はコードの外にあり、法律で扱う。
- 交付金が賢明に使われたかは判断の問題であり、記録の完全性の問題ではない。

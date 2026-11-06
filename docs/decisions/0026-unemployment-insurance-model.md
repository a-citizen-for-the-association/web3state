# 0026. Unemployment insurance model: no new contract; pension, benefits and subsidies patterns combined; working while receiving made visible

**Date:** 2026-11-07
**Status:** Accepted

## Context

Unemployment insurance was screened with the on-chain value test ([ADR 0014](0014-legislative-process-scope.md)). The main fraud is working while receiving benefit, which the office checks only through self-reports. Other problems are employment adjustment subsidy fraud (2020–22), underpaid benefits caused by flawed wage statistics (2019), disputes over the reason for leaving, training-fee kickbacks, and non-enrolment. Every needed element already exists: the pension premium pattern ([ADR 0024](0024-pension-model.md)), the benefits payment and consent rules ([ADR 0025](0025-benefits-model.md)), the subsidies evidence rule ([ADR 0023](0023-subsidies-model.md)), and `EmployeeID` plus on-chain salaries. See the [log](../state-design/unemployment-insurance/discussion-log.md).

## Decision

- **No new contract** (option A).
- **Premiums** (option (a)): the employee pays the whole insurance part from their own `ResidentLink` address; the employer alone pays the 二事業 part from its corporate address. Both go to one unemployment-insurance `PublicTreasury`, told apart by the sender's kind.
- **Insured months** are computed from premium transfers and the `EmployeeID` mint and burn; the reason for leaving is an anchored, off-chain judgement.
- **Benefits** use the shared social-security code (ADR 0025).
- **Working while receiving** is flagged, with consent and during receipt only: any salary or new `EmployeeID` for the job-seeker's benefit; employer pay above the legal limit for the childcare-leave benefit.
- **Training fees** must be paid on-chain to the registered provider; kickbacks are detected off-chain.
- **Employer subsidies** follow ADR 0023; **workers' accident compensation** and **official statistics computed from chain data** go to the backlog.

## Consequences

- The most common unemployment-insurance fraud becomes detectable without a new mechanism.
- Benefit amounts become recomputable by the recipient, and the wage averages they depend on become computable from public data.
- Social Welfare is complete. Its three designs together add no contract, only rules and off-chain applications over the existing rail.
- Cash work and judgements about job search and the reason for leaving stay off-chain.

---

# 0026. 雇用保険モデル: 新しいコントラクトは作らない。年金・各種手当・補助金の型を組み合わせる。受給中の就労を見えるようにする(日本語)

**日付:** 2026-11-07
**ステータス:** Accepted

## 背景

雇用保険をオンチェーン価値テスト([ADR 0014](0014-legislative-process-scope.md))で選別した。主な不正は受給中の就労で、窓口は自己申告でしか確認できない。ほかの問題として、雇用調整助成金の不正(2020〜22年)、誤った賃金統計による給付の過少(2019年)、離職理由をめぐる争い、受講料のキックバック、未加入がある。必要な要素はすべてすでにある: 年金の保険料の型([ADR 0024](0024-pension-model.md))、各種手当の支払いと同意のルール([ADR 0025](0025-benefits-model.md))、補助金の証拠のルール([ADR 0023](0023-subsidies-model.md))、そして`EmployeeID`とオンチェーンの給与である。[議論ログ](../state-design/unemployment-insurance/discussion-log.md)を参照。

## 決定

- **新しいコントラクトは作らない**(選択肢A)。
- **保険料**(選択肢(a)): 従業員は労使負担の部分の全額を自分の`ResidentLink`アドレスから払う。二事業の部分は雇用主だけが法人アドレスから払う。どちらも雇用保険の`PublicTreasury`1つに払い、送信元の種類で区別する。
- **被保険者期間**は保険料の送金と`EmployeeID`のmint・burnから計算する。離職理由は、アンカリングしたうえでのオフチェーンの判断とする。
- **給付**は社会保障の共通コード(ADR 0025)を使う。
- **受給中の就労**は、同意に基づき受給期間中に限って検知する: 基本手当では給与や新しい`EmployeeID`すべて、育児休業給付では法律の上限を超える雇用主からの給与。
- **受講料**は登録済みの提供者へオンチェーンで支払わなければならない。キックバックはオフチェーンで検出する。
- **雇用主向けの助成金**はADR 0023に従う。**労災保険**と**チェーンのデータから計算する公式統計**はバックログへ。

## 結果

- 雇用保険で最も多い不正が、新しい仕組みなしに検知できるようになる。
- 給付額を受給者が再計算できるようになり、その基になる平均賃金も公開データから計算できるようになる。
- 社会保障が完了する。その3つの設計は合わせてもコントラクトを1つも増やさず、既存の基盤の上にルールとオフチェーンのアプリケーションを加えるだけである。
- 現金での就労と、求職活動や離職理由についての判断はオフチェーンに残る。

# 0024. Pension model: no new contract; the contribution transfer is the record; employees pay their whole premium

**Date:** 2026-11-07
**Status:** Accepted. The single pension budget code is widened to one code shared by all social-security payments to individuals by [ADR 0025](0025-benefits-model.md).

## Context

The public pensions (National Pension and Employees' Pension) were screened with the on-chain value test ([ADR 0014](0014-legislative-process-scope.md)). The core problem is record-keeping: in 2007 about 50 million contribution records could not be matched to anyone ("lost pensions"), and outsourced data entry caused wrong payments in 2018. Other problems are payments after unreported deaths, and employers who do not enrol staff or under-declare pay. Payments already go through the treasury ([ADR 0019](0019-treasury-model.md)) only to genuine `ResidentLink` holders; salaries are on-chain under the certified-address rule ([ADR 0020](0020-certified-address-stablecoin.md)); and the taxation design aims to eliminate employer withholding rather than replicate it. See the [log](../state-design/pension/discussion-log.md).

## Decision

- **No new contract** (option A). Contributions are plain transfers to two pension `PublicTreasury` contracts (National Pension, Employees' Pension); benefits are `pay()` from them.
- **The contribution transfer is the record.** Premiums are paid only from the insured person's own `ResidentLink` address. Allocation to months follows a fixed legal rule (oldest unpaid month first), so anyone computes the same record.
- **Employees pay their whole Employees' Pension premium themselves** (option (a)); the employer's half becomes part of gross pay. Unpaid premiums are handled like category 1 delinquency.
- **Decisions that change entitlement** (awards, exemptions, deferrals, category 3) are anchored by hash only ([ADR 0017](0017-executive-document-anchoring-v1.md)); content stays private.
- **One generic budget code for all pension benefits,** so payments do not reveal disability or widowhood; per-kind totals are published off-chain.
- **Everything on-chain is public per address.** Registered deaths stop payments through the `ResidentLink` burn; unreported deaths and employer evasion are detected off-chain.
- **GPIF investment is excluded; private and corporate pensions are out of scope.**

## Consequences

- "Lost pensions" become structurally impossible for new contributions, and entitlements become independently recomputable.
- Under-declaring pay cannot be hidden, because premiums are computed from on-chain pay.
- Employees can fall into arrears, which withholding prevented.
- Almost every adult's contribution and benefit amounts become public per pseudonymous address.
- Benefits (各種手当) and unemployment insurance will reuse this pattern: treasury payments, anchored private decisions, generic budget codes for sensitive kinds.

---

# 0024. 年金モデル: 新しいコントラクトは作らない。保険料の送金が記録になる。会社員は保険料を全額自分で払う(日本語)

**日付:** 2026-11-07
**ステータス:** Accepted。年金共通の予算コードは、[ADR 0025](0025-benefits-model.md)で個人への社会保障の支払いすべてに共通のコードに広げられた。

## 背景

公的年金(国民年金と厚生年金)をオンチェーン価値テスト([ADR 0014](0014-legislative-process-scope.md))で選別した。中核の問題は記録管理である。2007年には約5000万件の納付記録が誰のものか特定できず(「消えた年金」)、2018年には外部委託のデータ入力が誤った支払いを引き起こした。ほかの問題として、届けられない死亡の後の支給と、従業員を加入させない、あるいは給与を過少に届け出る雇用主がある。支払いはすでに歳出・予算([ADR 0019](0019-treasury-model.md))を通り、本物の`ResidentLink`保有者にだけ出る。給与は認定アドレス制([ADR 0020](0020-certified-address-stablecoin.md))によりオンチェーンにある。納税の設計は、雇用主の源泉徴収を再現するのではなく廃止をめざしている。[議論ログ](../state-design/pension/discussion-log.md)を参照。

## 決定

- **新しいコントラクトは作らない**(選択肢A)。保険料は年金の2つの`PublicTreasury`(国民年金、厚生年金)への単純な送金で、給付はそこからの`pay()`である。
- **保険料の送金が記録になる。** 保険料は被保険者自身の`ResidentLink`アドレスからのみ払う。何月分に充てるかは法律で固定したルール(未納の最も古い月から)に従うので、誰が計算しても同じ記録になる。
- **会社員は厚生年金の保険料を全額自分で払う**(選択肢(a))。雇用主負担分は額面の給与の一部になる。未納の保険料は第1号の滞納と同じに扱う。
- **年金額を変える決定**(裁定、免除、猶予、第3号)はハッシュだけをアンカリングする([ADR 0017](0017-executive-document-anchoring-v1.md))。内容は非公開のまま。
- **年金給付の予算コードは1つ**にし、支払いから障害や死別がわからないようにする。種類ごとの合計はオフチェーンで公表する。
- **オンチェーンにあるものはすべてアドレス単位で公開。** 届出済みの死亡では`ResidentLink`のburnで支払いが止まる。未届の死亡と雇用主の逃れはオフチェーンで検出する。
- **GPIFの運用は対象外、私的・企業年金はスコープ外。**

## 結果

- 新しい保険料については「消えた年金」が構造的に起こらなくなり、年金額を誰でも独立に再計算できるようになる。
- 保険料はオンチェーンの給与から計算されるので、報酬の過少申告は隠せない。
- 源泉徴収では起こらなかった、会社員の滞納が起こりうる。
- ほぼすべての成人の保険料と給付の額が、仮名のアドレスごとに公開される。
- 各種手当と雇用保険はこのパターン(歳出の支払い、アンカーした非公開の決定、慎重を要する種類には共通の予算コード)を再利用することになる。

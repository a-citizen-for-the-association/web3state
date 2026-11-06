# 0025. Benefits model: no new contract; one shared social-security budget code; consented income checks only

**Date:** 2026-11-07
**Status:** Accepted

## Context

Cash benefits to individuals (child allowance, child-rearing allowance, disability allowances, public assistance, universal one-off payments) were screened with the on-chain value test ([ADR 0014](0014-legislative-process-scope.md)). The real problems are undeclared income in public assistance, poverty businesses, payments to wrongly registered accounts (2023), slow universal payments (2020), and a payer withholding assistance (2023). Under-take-up and stigma are social, but the design must not worsen them: public payments per address ([ADR 0019](0019-treasury-model.md)) could mark an address as a public-assistance recipient. Pension ([ADR 0024](0024-pension-model.md)) already used a single budget code to hide the kind of pension. See the [log](../state-design/benefits/discussion-log.md).

## Decision

- **No new contract** (option A). Benefits are `pay()` from the paying body's `PublicTreasury` to the recipient's own `ResidentLink` address (housing assistance may go to the landlord); decisions are anchored by hash only ([ADR 0017](0017-executive-document-anchoring-v1.md)).
- **One shared budget code for all social-security payments to individuals** (option (b)): pension, every benefit and later unemployment insurance. This widens ADR 0024's single pension code. Universal payments keep their own code. Per-kind totals are published monthly per paying body.
- **Income analysis only for applicants and recipients, with consent** (option (a)), limited to the application and receipt period plus the legal overpayment-investigation period. No routine analysis of residents' finances to find possible recipients.
- **Children need no `ResidentLink`;** child-related eligibility is decided off-chain.
- **Duplicates, poverty businesses and undeclared income** are handled by off-chain analysis.
- **Medical and care assistance are out of scope** and recorded in the backlog under the medical-claims system.

## Consequences

- Wrong-account payments become impossible, and recipients can verify every payment.
- A payment no longer reveals the kind of social-security benefit; amounts and timing remain a residual hint.
- Welfare offices gain a view of recipients' non-cash income without a new mechanism, bounded by consent and period.
- Cash income, under-take-up and the judgement of exploitation remain off-chain problems.
- Unemployment insurance will use the shared code.

---

# 0025. 各種手当モデル: 新しいコントラクトは作らない。社会保障の共通予算コードを1つにする。収入確認は同意がある場合のみ(日本語)

**日付:** 2026-11-07
**ステータス:** Accepted

## 背景

個人への現金給付(児童手当、児童扶養手当、障害者向けの手当、生活保護、一時的な一律給付)をオンチェーン価値テスト([ADR 0014](0014-legislative-process-scope.md))で選別した。実際の問題は、生活保護での収入の未申告、貧困ビジネス、誤って登録された口座への支払い(2023年)、一律給付の遅さ(2020年)、支払う側による保護費の留保(2023年)である。捕捉率とスティグマは社会の問題だが、設計がそれを悪化させてはならない。アドレスごとの公開の支払い([ADR 0019](0019-treasury-model.md))は、あるアドレスを生活保護の受給者として示してしまいうる。年金([ADR 0024](0024-pension-model.md))では、すでに予算コードを1つにして年金の種類を隠している。[議論ログ](../state-design/benefits/discussion-log.md)を参照。

## 決定

- **新しいコントラクトは作らない**(選択肢A)。給付は支払う機関の`PublicTreasury`から受給者本人の`ResidentLink`アドレスへの`pay()`である(住宅扶助は家主へ支払ってもよい)。決定はハッシュだけをアンカリングする([ADR 0017](0017-executive-document-anchoring-v1.md))。
- **個人への社会保障の支払いすべてに共通の予算コードを1つ使う**(選択肢(b)): 年金、すべての給付、後の雇用保険。ADR 0024の年金共通コードを広げる。一律給付は独自のコードを使う。種類ごとの合計を支払う機関ごとに毎月公表する。
- **収入の分析は申請者と受給者に限り、同意に基づいて行う**(選択肢(a))。期間は申請から受給まで、と法定の過払い調査の期間。受給資格がありそうな人を見つけるための住民の財務の日常的な分析はしない。
- **子どもに`ResidentLink`は求めない。** 子どもに関する受給資格はオフチェーンで判断する。
- **重複、貧困ビジネス、収入の未申告**はオフチェーン分析で扱う。
- **医療扶助・介護扶助はスコープ外**とし、診療報酬の仕組みとしてバックログに記録する。

## 結果

- 誤った口座への支払いは不可能になり、受給者はすべての支払いを確認できる。
- 支払いから社会保障の給付の種類はわからなくなる。金額と時期は推測の手がかりとして残る。
- 福祉事務所は、新しい仕組みなしに、受給者の現金以外の収入を見られるようになる。範囲は同意と期間で限られる。
- 現金の収入、捕捉率、搾取かどうかの判断は、オフチェーンの問題として残る。
- 雇用保険は共通コードを使うことになる。

# 0022. Procurement model: commit–reveal sealed bidding, committed ceiling price, all bids public, one record per contract

**Date:** 2026-10-24
**Status:** Accepted

## Context

Public procurement was screened with the on-chain value test ([ADR 0014](0014-legislative-process-scope.md)). Real problems include bid rigging (e.g. the 2023 Olympic test-event indictments), official-involved rigging and ceiling-price leaks, negotiated or single-bidder contracts where competition was possible, and increases after award. Electronic bidding exists, but the procuring body runs it and can see bids before opening. Re-delegation is already traceable through the treasury ([ADR 0019](0019-treasury-model.md)); bidders are identified by certification ([ADR 0020](0020-certified-address-stablecoin.md)). See the [log](../state-design/procurement/discussion-log.md).

## Decision

- **Each procurement is a `Tender` contract** from the body's `TenderFactory`. Negotiated contracts use the same factory, so every contract of a body is recorded in one place.
- **Commit–reveal sealed bidding:** bid hashes before the deadline, reveals afterwards, deposits forfeited to the body's treasury on non-reveal. Bidders are certified corporations or sole proprietors (`ResidentLink`).
- **The ceiling price is committed as a hash** before the deadline and revealed at opening; it is not published in advance.
- **All bids are public at opening,** losers included.
- **Lowest-price awards are checked on-chain;** comprehensive evaluation commits its criteria and publishes the score sheet, and judging stays off-chain.
- **Contracts and change contracts are appended** to the tender; treasury payments cite the tender in their budget code.
- **Rigging detection is off-chain analysis** of the complete public data.

## Consequences

- Peeking at bids, altering bids after the deadline, adjusting the ceiling after seeing bids, and awarding to someone other than the lowest bidder become impossible or immediately visible.
- A complete, permanent dataset of every bid exists for detecting rigging, joinable with donations, officers and payments.
- A leak before the deadline and collusion among bidders are not prevented; they become easier to detect.
- `TenderFactory` joins the ADR 0020 registrars, since tenders hold deposits.
- The lowest-price check is a deliberate, small exception to the "off-chain if it can be" principle, justified by a real enforcement need.

---

# 0022. 公共調達モデル: コミット・リビールによる封印入札、コミットされた予定価格、全入札の公開、契約ごとに1つの記録(日本語)

**日付:** 2026-10-24
**ステータス:** Accepted

## 背景

公共調達をオンチェーン価値テスト([ADR 0014](0014-legislative-process-scope.md))で選別した。実際の問題として、談合(2023年の五輪テスト大会をめぐる起訴など)、官製談合と予定価格の漏洩、競争が可能だったのに使われる随意契約や一者応札、落札後の増額がある。電子入札はあるが、調達する機関が運用しており、開札前に入札を見られる。再委託は国庫([ADR 0019](0019-treasury-model.md))ですでに追跡でき、入札者は認定([ADR 0020](0020-certified-address-stablecoin.md))で特定できる。[ログ](../state-design/procurement/discussion-log.md)を参照。

## 決定

- **各調達は、機関の`TenderFactory`から作る`Tender`コントラクトとする。** 随意契約も同じファクトリを使い、機関のすべての契約を1か所に記録する。
- **コミット・リビールによる封印入札:** 締切前に入札のハッシュを提出し、締切後に明かす。明かさなかった場合、保証金は機関の国庫に没収される。入札者は認定済みの法人または個人事業主(`ResidentLink`)とする。
- **予定価格はハッシュとしてコミットする。** 締切前にコミットし、開札時に明かす。事前公表はしない。
- **すべての入札を開札時に公開する。** 落札しなかった者も含む。
- **最低価格による落札はオンチェーンで確認する。** 総合評価は基準をコミットし、評価表を公開し、判断はオフチェーンに残す。
- **契約と変更契約は入札案件に追記する。** 国庫の支払いは予算コードで入札案件を参照する。
- **談合の検出は、完全な公開データのオフチェーンの分析で行う。**

## 結果

- 入札の盗み見、締切後の入札の書き換え、入札を見た後の予定価格の調整、最低価格の入札者以外への落札は、不可能になるか、すぐに見えるようになる。
- 談合を検出するための、すべての入札の完全で永続的なデータができ、献金、役員、支払いと結びつけられる。
- 締切前の漏洩と入札者どうしの共謀は防げない。検出しやすくなるだけである。
- 入札案件は保証金を持つので、`TenderFactory`はADR 0020の登録者に加わる。
- 最低価格の確認は、実際の強制の必要によって正当化される、「オフチェーンでできることはオフチェーンで」の意図的な小さな例外である。

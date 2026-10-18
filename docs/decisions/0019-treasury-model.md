# 0019. Treasury model: per-body treasury contracts, identified payees, public off-chain exits; "off-chain if it can be"

**Date:** 2026-10-18
**Status:** Accepted

## Context

Treasury / public finance was screened with the on-chain value test ([ADR 0014](0014-legislative-process-scope.md)). Budget formulation is public and political. Spending execution is not transparent: "parked funds" (預け金) were found at suppliers from 2006, there have been fictitious trips and activity-expense fraud, and in 2020 the business-continuity benefit was re-delegated through several layers. Settlement accounts are annual, aggregated, and stop at the first recipient. Procurement, subsidies, pensions and benefits are separate items that will spend through whatever is designed here.

In the discussion ([log](../state-design/treasury/discussion-log.md)), the user set two principles. Whatever is not on-chain must be checked thoroughly off-chain. Whatever can be done off-chain should not be put on-chain.

## Decision

- **One `PublicTreasury` contract per public body**: the `PoliticalFund` idea ([ADR 0015](0015-political-donations-model.md)) applied to the state itself. Taxes are paid to it (it serves as the attested receiving address of [ADR 0004](0004-taxation-payment-rail.md)). Every payment leaves from it, and transfers between bodies are contract-to-contract.
- **Identified payees only:** a genuine `ResidentLink` holder, a registered corporation, or another `PublicTreasury`, checked through `OfficialContractRegistry`, which gains a `PublicTreasury` kind.
- **Budget codes are tags, not caps:** overspending is caught by audit, not by the contract.
- **No re-delegation mechanism:** stablecoin payments are traceable past the first recipient by anyone.
- **Payments to individuals are public,** including public servants' pay and legislators' activity expenses. Activity expenses go to the legislator's own `ResidentLink` address and are analysed off-chain.
- **Secret spending is allowed, but its exit is public:** cash or special accounts only via a payment tagged `OffChainExit` to a registered corporation. Amount and timing are public. Whether the payee is a financial institution, and how the money is used, are checked off-chain.
- **Project-wide principle:** *whatever can be done off-chain is not put on-chain.* Contracts do only what needs a chain; checks, classification and analysis that an application can do from public chain data stay off-chain.

## Consequences

- Public money becomes traceable end to end in real time, by anyone, without bespoke mechanisms.
- Procurement, subsidies, pensions and benefits inherit this rail. Their designs mostly decide *what* is paid to *whom*, not how it flows.
- Enforcement is weaker than a capped design: the budget is checked by audit. Off-chain money is only as accountable as off-chain checks.
- Every public servant's address and pay become public, a privacy cost accepted by the user. Benefits will face the same question about individual recipients.
- `OfficialContractRegistry` gains a third kind (`PublicTreasury`), and 総務省 now attests public treasuries too.
- The new principle applies to all later designs, and pushes towards simpler contracts plus off-chain analysis applications.

---

# 0019. 国庫モデル: 機関ごとの国庫コントラクト、身元の分かる支払先、公開されたオフチェーンへの出口、「オフチェーンでできることはオフチェーンで」(日本語)

**日付:** 2026-10-18
**ステータス:** Accepted

## 背景

歳出・予算をオンチェーン価値テスト([ADR 0014](0014-legislative-process-scope.md))で選別した。予算編成は公開されており、政治の問題である。支出の執行は透明ではない。2006年頃から業者への「預け金」が発覚し、カラ出張や政務活動費の不正があり、2020年には持続化給付金が何層にも再委託された。決算は年1回の集計で、最初の受取人で止まる。公共調達、補助金、年金、給付は別項目であり、ここで設計するものを通して支出することになる。

議論([ログ](../state-design/treasury/discussion-log.md))で、ユーザーは2つの方針を示した。オンチェーンでない部分は、オフチェーンで徹底してチェックしなければならない。オフチェーンでできることは、オンチェーン化しない。

## 決定

- **公的機関ごとに1つの`PublicTreasury`コントラクト**を置く。`PoliticalFund`の考え方([ADR 0015](0015-political-donations-model.md))を国家自身に適用したものである。税金はここに支払われる([ADR 0004](0004-taxation-payment-rail.md)の証明された受け取りアドレスになる)。すべての支払いはここから出ていき、機関の間の移転はコントラクト間で行う。
- **支払先は身元の分かる相手だけ:** 本物の`ResidentLink`の保有者、登記済みの法人、別の`PublicTreasury`。`OfficialContractRegistry`で確認し、レジストリには`PublicTreasury`の種類を加える。
- **予算コードは上限ではなくタグ:** 超過はコントラクトではなく検査で見つける。
- **再委託のための仕組みは作らない:** ステーブルコインの支払いは、誰でも最初の受取人より先まで追える。
- **個人への支払いは公開する。** 公務員の給与と議員の政務活動費を含む。政務活動費は議員自身の`ResidentLink`アドレスに支払い、オフチェーンで分析する。
- **秘密の支出は認めるが、出口は公開する:** 現金や特殊な口座は、`OffChainExit`のタグを付けた登記済み法人への支払いを通す場合に限る。金額と時期は公開する。支払先が金融機関かどうか、お金がどう使われたかは、オフチェーンで確認する。
- **プロジェクト全体の方針:** *オフチェーンでできることは、オンチェーン化しない。* コントラクトはチェーンが必要なことだけを行い、公開されたチェーンのデータからアプリケーションでできる確認・分類・分析はオフチェーンに置く。

## 結果

- 公金が、特別な仕組みなしに、誰にでも、リアルタイムで、最後まで追えるようになる。
- 公共調達、補助金、年金、給付はこの基盤を引き継ぐ。それらの設計は主に、*誰に何を*支払うかを決めることになり、お金の流れ方を決める必要はほとんどない。
- 上限付きの設計より強制力は弱い: 予算は検査で照合する。オフチェーンのお金の説明責任は、オフチェーンのチェックの強さに依存する。
- 各公務員のアドレスと給与が公開される。ユーザーが受け入れたプライバシーのコストである。給付も、個人の受取人について同じ問題に直面する。
- `OfficialContractRegistry`は3つ目の種類(`PublicTreasury`)を持ち、総務省は公的な国庫も証明するようになる。
- 新しい方針は以後のすべての設計に適用され、より単純なコントラクトとオフチェーンの分析アプリケーションの組み合わせへと設計を向かわせる。

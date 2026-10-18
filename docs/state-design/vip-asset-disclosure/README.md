# VIP / politician asset disclosure (要人の資産公開)

**Status: 🟢 Spec drafted.** Screened with the on-chain value test and resolved through discussion with the user; see [`discussion-log.md`](discussion-log.md) for the reasoning and [ADR 0021](../../decisions/0021-vip-asset-disclosure.md) for the formal decision. No contract code written yet. Builds on the certified-address stablecoin ([ADR 0020](../../decisions/0020-certified-address-stablecoin.md)), which this discussion produced.

## Summary

**No new contract.** A VIP's money lives on their one `ResidentLink` address, which is published, and under the certified-address rule no JPY stablecoin can sit anywhere uncertified. So a VIP's balances, income and spending are visible continuously to anyone, through off-chain analysis applications. What remains off-chain (assets that are not on-chain, and non-JPY tokens) is declared, checked thoroughly, and an omission is punished severely.

## Who is a VIP (Issue 1)

National and local legislators, heads of government (governors, mayors), ministers and vice-ministers. **Civil servants are not VIPs.** Family members are not required to declare (Issue 4).

## On-chain / Online / Offline breakdown

(See [`docs/operations/README.md`](../../operations/README.md) for the convention.)

**On-chain:** nothing new. The VIP's `ResidentLink` address, and everything paid to and from it, already exist ([ADR 0019](../../decisions/0019-treasury-model.md)). Corporate officer names are already public ([ADR 0005](../../decisions/0005-corporate-registration-model.md)).

**Online:**
- The assembly or office publishes each VIP's `ResidentLink` address (as already done for activity expenses).
- Off-chain asset declarations are published online.

**Offline:**
- **Declarations:** off-chain assets, including ordinary deposits (excluded under today's law); any holdings of non-JPY tokens or foreign stablecoins (which also trigger enhanced monitoring, [ADR 0020](../../decisions/0020-certified-address-stablecoin.md)).
- **Thorough checking** of the declarations. Apart from cash, nearly all assets are intended to be on-chain eventually (e.g. the real estate registry), which shrinks what must be checked.
- **Penalty:** an omitted declaration is punished severely, e.g. **permanent exclusion from politics**.
- **Analysis applications** over the public chain data: balances, income and spending over time, and who the payees are.

## Lifecycle

- **Taking office:** the VIP's `ResidentLink` address is published.
- **Leaving office (Issue 5):** the person switches to a new `ResidentLink` address through the light successor path ([ADR 0020](../../decisions/0020-certified-address-stablecoin.md)), and the old address stops being monitored as a VIP's. The transfer from the old address to the new one is itself visible, so a determined observer can keep following. This is **accepted**: being a politician demands that commitment, and it should deter people who only want to profit from office (S8).

## Known limits

- Cash and assets not yet on-chain depend on declarations and off-chain checks.
- Non-JPY tokens can still move to uncertified addresses; only the law covers them.
- Family members' assets are not covered.
- **Corporations controlled as a shareholder** (with others as officers) are not linked to the VIP on-chain. For now the shares are declared, and omission is punished severely; the gap mostly closes once securities are on-chain (Round 5).

---

# 要人の資産公開(日本語)

**ステータス: 🟢 設計確定。** オンチェーン価値テストで選別し、ユーザーとの議論で解決した。理由は[`discussion-log.md`](discussion-log.md)、正式な決定は[ADR 0021](../../decisions/0021-vip-asset-disclosure.md)を参照。コントラクトコードはまだない。この議論から生まれた認定アドレス制のステーブルコイン([ADR 0020](../../decisions/0020-certified-address-stablecoin.md))を土台とする。

## 概要

**新しいコントラクトは作らない。** 要人のお金は、公表される1つの`ResidentLink`アドレスにある。認定アドレス制のルールの下では、円建てステーブルコインは認定外のどこにも置けない。したがって要人の残高、収入、支出は、オフチェーンの分析アプリケーションを通じて、誰でも継続的に見られる。オフチェーンに残るもの(オンチェーンにない資産と、円以外のトークン)は申告させ、徹底して確認し、申告漏れには厳罰を科す。

## 誰が要人か(論点1)

国会議員と地方議員、首長(知事、市区町村長)、大臣と副大臣。**公務員は要人に含めない。** 家族には申告を求めない(論点4)。

## オンチェーン/オンライン/オフラインの内訳

(区分の考え方は[`docs/operations/README.md`](../../operations/README.md)を参照。)

**オンチェーン:** 新しいものはない。要人の`ResidentLink`アドレスと、そこへの支払い・そこからの支払いはすでに存在する([ADR 0019](../../decisions/0019-treasury-model.md))。法人の役員名はすでに公開されている([ADR 0005](../../decisions/0005-corporate-registration-model.md))。

**オンライン:**
- 議会や役所が、各要人の`ResidentLink`アドレスを公表する(政務活動費ですでに行っているとおり)。
- オフチェーンの資産の申告をオンラインで公表する。

**オフライン:**
- **申告:** オフチェーンの資産。普通預金(現行法では除外されている)を含む。円以外のトークンや外国のステーブルコインの保有(これらは監視強化の対象にもなる、[ADR 0020](../../decisions/0020-certified-address-stablecoin.md))。
- 申告の**徹底した確認**。現金を除き、ほぼすべての資産はいずれオンチェーンにするつもりであり(不動産登記など)、確認すべき範囲は小さくなっていく。
- **罰則:** 申告漏れには厳罰を科す。たとえば**政治の世界からの永久追放**。
- 公開されたチェーンのデータに対する**分析アプリケーション**: 残高、収入、支出の推移と、支払先が誰か。

## ライフサイクル

- **就任:** 要人の`ResidentLink`アドレスを公表する。
- **退任(論点5):** 軽い承継の手続き([ADR 0020](../../decisions/0020-certified-address-stablecoin.md))で新しい`ResidentLink`アドレスに切り替え、古いアドレスは要人のものとしての監視を終える。古いアドレスから新しいアドレスへの移転そのものは見えるので、追い続けようとする人は追える。これは**受け入れる**: 政治家になるにはそれくらいの覚悟が必要であり、利権を得たいだけの人を遠ざける効果も期待できる(S8)。

## 既知の限界

- 現金と、まだオンチェーンにない資産は、申告とオフチェーンの確認に依存する。
- 円以外のトークンは引き続き認定外のアドレスに送れる。それらを扱えるのは法律だけである。
- 家族の資産は対象にならない。
- **株主として支配する法人**(他人が役員)は、オンチェーンでは要人と結びつかない。当面は株式を申告させ、申告漏れには厳罰を科す。有価証券がオンチェーン化されれば、この抜け道はほぼ塞がる(Round 5)。

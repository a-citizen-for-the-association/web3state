# VIP / politician asset disclosure (要人の資産公開)

**Status: 🟢 Spec drafted.** Screened with the on-chain value test and resolved through discussion with the user; see [`discussion-log.md`](discussion-log.md) for the reasoning and [ADR 0021](../../decisions/0021-vip-asset-disclosure.md) for the formal decision. No contract code written yet. Builds on the certified-address stablecoin ([ADR 0020](../../decisions/0020-certified-address-stablecoin.md)), which this discussion produced; its transfer rule is now [ADR 0031](../../decisions/0031-registered-address-transfer-rule.md). Updated for the cross-feature consistency review ([ADR 0032](../../decisions/0032-consistency-review-decisions.md)).

## Summary

**No new contract.** A VIP's money lives on their one `ResidentLink` address, which is published. That address carries a **VIP flag** in `OfficialContractRegistry`, and its cap for sending to unregistered addresses is **zero**: it can send JPY only to registered addresses ([ADR 0031](../../decisions/0031-registered-address-transfer-rule.md)). So a VIP's balances, income and spending are visible continuously to anyone, through off-chain analysis applications. Real estate ([ADR 0029](../../decisions/0029-real-estate-registry-model.md)) and shares ([ADR 0030](../../decisions/0030-securities-model.md)) held at the address are visible from it too. What remains off-chain (assets that are not on-chain, and non-JPY tokens) is declared, checked thoroughly, and an omission is punished severely.

## Who is a VIP (Issue 1)

National and local legislators, heads of government (governors, mayors), ministers and vice-ministers. **Civil servants are not VIPs.** Family members are not required to declare (Issue 4).

## On-chain / Online / Offline breakdown

(See [`docs/operations/README.md`](../../operations/README.md) for the convention.)

**On-chain:** no new contract. The VIP's `ResidentLink` address, and everything paid to and from it, already exist ([ADR 0019](../../decisions/0019-treasury-model.md)). The VIP flag with its zero cap is held in `OfficialContractRegistry` ([ADR 0031](../../decisions/0031-registered-address-transfer-rule.md)). Real-estate and share tokens at the address are visible from it ([ADRs 0029](../../decisions/0029-real-estate-registry-model.md), [0030](../../decisions/0030-securities-model.md)). Corporate officer and beneficial-owner names are already public ([ADR 0005](../../decisions/0005-corporate-registration-model.md), [ADR 0030](../../decisions/0030-securities-model.md)).

**Online:**
- The assembly or office publishes each VIP's `ResidentLink` address (as already done for activity expenses).
- Off-chain asset declarations are published online.

**Offline:**
- **Declarations:** off-chain assets, including ordinary deposits (excluded under today's law); any holdings of non-JPY tokens or foreign stablecoins (which also trigger enhanced monitoring, [ADR 0020](../../decisions/0020-certified-address-stablecoin.md)).
- **Thorough checking** of the declarations. Real estate and shares are now visible from the VIP's address ([ADRs 0029](../../decisions/0029-real-estate-registry-model.md), [0030](../../decisions/0030-securities-model.md)); apart from cash, nearly all assets are intended to be on-chain eventually, which shrinks what must be checked.
- **Penalty:** an omitted declaration is punished severely, e.g. **permanent exclusion from politics**.
- **Analysis applications** over the public chain data: balances, income and spending over time, and who the payees are.

## Lifecycle

- **Taking office:** the VIP's `ResidentLink` address is published and gets the VIP flag ([ADR 0031](../../decisions/0031-registered-address-transfer-rule.md)).
- **Leaving office (Issue 5):** the VIP flag stays on the address for a legal period (e.g. one year) after leaving office. Switching to a new `ResidentLink` address through the light successor path ([ADR 0020](../../decisions/0020-certified-address-stablecoin.md)) is **optional**: it hides nothing, since the transfer from the old address to the new one is itself visible, so a determined observer can keep following (consistency review R5.9, [ADR 0032](../../decisions/0032-consistency-review-decisions.md)). This is **accepted**: being a politician demands that commitment, and it should deter people who only want to profit from office (S8).

## Known limits

- Cash and assets not yet on-chain depend on declarations and off-chain checks.
- Non-JPY tokens can still move to unregistered addresses; only the law covers them.
- A VIP can still send JPY to registered relatives or acquaintances who each forward within their own caps; every first hop is public and found afterwards by analysis ([ADR 0031](../../decisions/0031-registered-address-transfer-rule.md)).
- Family members' assets are not covered. Regular transfers to family members, and family members acting as real-estate agents, mark their addresses; this is an **accepted cost of office**. VIPs are recommended (not required) to use professional real-estate agents (consistency review R5.6, [ADR 0032](../../decisions/0032-consistency-review-decisions.md)).
- **Corporations controlled as a shareholder** (with others as officers): with shares on-chain, the VIP's shares are visible from their address, and beneficial owners (25% or more) are named in the corporate record ([ADR 0030](../../decisions/0030-securities-model.md)).

---

# 要人の資産公開(日本語)

**ステータス: 🟢 設計確定。** オンチェーン価値テストで選別し、ユーザーとの議論で解決した。理由は[`discussion-log.md`](discussion-log.md)、正式な決定は[ADR 0021](../../decisions/0021-vip-asset-disclosure.md)を参照。コントラクトコードはまだない。この議論から生まれた認定アドレス制のステーブルコイン([ADR 0020](../../decisions/0020-certified-address-stablecoin.md))を土台とする。その送金ルールは今は[ADR 0031](../../decisions/0031-registered-address-transfer-rule.md)にある。機能間の整合性レビュー([ADR 0032](../../decisions/0032-consistency-review-decisions.md))に合わせて更新した。

## 概要

**新しいコントラクトは作らない。** 要人のお金は、公表される1つの`ResidentLink`アドレスにある。そのアドレスには`OfficialContractRegistry`で**要人の印**が付き、未登録のアドレスへの送金の上限は**0**である: 円は登録済みのアドレスにしか送れない([ADR 0031](../../decisions/0031-registered-address-transfer-rule.md))。したがって要人の残高、収入、支出は、オフチェーンの分析アプリケーションを通じて、誰でも継続的に見られる。そのアドレスにある不動産([ADR 0029](../../decisions/0029-real-estate-registry-model.md))と株式([ADR 0030](../../decisions/0030-securities-model.md))もそこから見える。オフチェーンに残るもの(オンチェーンにない資産と、円以外のトークン)は申告させ、徹底して確認し、申告漏れには厳罰を科す。

## 誰が要人か(論点1)

国会議員と地方議員、首長(知事、市区町村長)、大臣と副大臣。**公務員は要人に含めない。** 家族には申告を求めない(論点4)。

## オンチェーン/オンライン/オフラインの内訳

(区分の考え方は[`docs/operations/README.md`](../../operations/README.md)を参照。)

**オンチェーン:** 新しいコントラクトはない。要人の`ResidentLink`アドレスと、そこへの支払い・そこからの支払いはすでに存在する([ADR 0019](../../decisions/0019-treasury-model.md))。上限0の要人の印は`OfficialContractRegistry`が持つ([ADR 0031](../../decisions/0031-registered-address-transfer-rule.md))。そのアドレスにある不動産と株式のトークンはそこから見える([ADR 0029](../../decisions/0029-real-estate-registry-model.md)、[0030](../../decisions/0030-securities-model.md))。法人の役員と実質的支配者の氏名はすでに公開されている([ADR 0005](../../decisions/0005-corporate-registration-model.md)、[ADR 0030](../../decisions/0030-securities-model.md))。

**オンライン:**
- 議会や役所が、各要人の`ResidentLink`アドレスを公表する(政務活動費ですでに行っているとおり)。
- オフチェーンの資産の申告をオンラインで公表する。

**オフライン:**
- **申告:** オフチェーンの資産。普通預金(現行法では除外されている)を含む。円以外のトークンや外国のステーブルコインの保有(これらは監視強化の対象にもなる、[ADR 0020](../../decisions/0020-certified-address-stablecoin.md))。
- 申告の**徹底した確認**。不動産と株式は今では要人のアドレスから見える([ADR 0029](../../decisions/0029-real-estate-registry-model.md)、[0030](../../decisions/0030-securities-model.md))。現金を除き、ほぼすべての資産はいずれオンチェーンにするつもりであり、確認すべき範囲は小さくなっていく。
- **罰則:** 申告漏れには厳罰を科す。たとえば**政治の世界からの永久追放**。
- 公開されたチェーンのデータに対する**分析アプリケーション**: 残高、収入、支出の推移と、支払先が誰か。

## ライフサイクル

- **就任:** 要人の`ResidentLink`アドレスを公表し、要人の印を付ける([ADR 0031](../../decisions/0031-registered-address-transfer-rule.md))。
- **退任(論点5):** 要人の印は退任後も法定の期間(例: 1年)アドレスに残る。軽い承継の手続き([ADR 0020](../../decisions/0020-certified-address-stablecoin.md))で新しい`ResidentLink`アドレスに切り替えるのは**任意**である: 古いアドレスから新しいアドレスへの移転そのものは見えるので、切り替えても何も隠せず、追い続けようとする人は追える(整合性レビューR5.9、[ADR 0032](../../decisions/0032-consistency-review-decisions.md))。これは**受け入れる**: 政治家になるにはそれくらいの覚悟が必要であり、利権を得たいだけの人を遠ざける効果も期待できる(S8)。

## 既知の限界

- 現金と、まだオンチェーンにない資産は、申告とオフチェーンの確認に依存する。
- 円以外のトークンは引き続き未登録のアドレスに送れる。それらを扱えるのは法律だけである。
- 要人は、登録済みの親族や知人に円を送り、それぞれがその上限の範囲で転送することはできる。最初の送金はすべて公開され、後から分析で見つかる([ADR 0031](../../decisions/0031-registered-address-transfer-rule.md))。
- 家族の資産は対象にならない。家族への定期的な送金や、家族が不動産の代理人になることで、家族のアドレスが知られうる。これは**公職の代償として受け入れる**。要人には不動産の代理人に専門家を使うよう勧める(義務ではない)(整合性レビューR5.6、[ADR 0032](../../decisions/0032-consistency-review-decisions.md))。
- **株主として支配する法人**(他人が役員): 株式がオンチェーンになったので、要人の株式はそのアドレスから見え、実質的支配者(25%以上)は法人の記録に氏名が載る([ADR 0030](../../decisions/0030-securities-model.md))。

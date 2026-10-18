# 0021. VIP asset disclosure: no new contract; published address plus off-chain declarations with severe penalties

**Date:** 2026-10-18
**Status:** Accepted

## Context

Under the Diet members' asset disclosure law, reports are self-declared and unverified, ordinary and current deposits are excluded, and the reports are paper snapshots. In this project, legislators' `ResidentLink` addresses are already published, because their pay and activity expenses are paid to them ([ADR 0019](0019-treasury-model.md)). The certified-address stablecoin ([ADR 0020](0020-certified-address-stablecoin.md)), decided in the same discussion ([log](../state-design/vip-asset-disclosure/discussion-log.md)), means no JPY can sit at an undeclared address.

## Decision

- **VIPs** are national and local legislators, heads of government, ministers and vice-ministers. Civil servants are not VIPs. Family members are not required to declare.
- **No new contract.** The VIP's published `ResidentLink` address shows balances, income and spending continuously; off-chain applications analyse it.
- **Off-chain declarations** cover assets not on-chain (including ordinary deposits) and holdings of non-JPY tokens. They are published online and checked thoroughly. **An omission is punished severely**, e.g. permanent exclusion from politics.
- **After leaving office** the person switches to a new `ResidentLink` address through the light successor path. The visible link between the old and new addresses is accepted as part of the commitment a politician makes.

## Consequences

- VIP asset disclosure becomes continuous and verifiable for everything in JPY, at no contract cost.
- Its strength rests on ADR 0020. Without the certified-address rule, a second address would defeat it.
- Off-chain assets and non-JPY tokens remain declaration-based until more assets move on-chain (e.g. the real estate registry).
- Former VIPs remain followable by determined observers, which is intentionally accepted.

---

# 0021. 要人の資産公開: 新しいコントラクトは作らない。公表されたアドレスと、厳罰付きのオフチェーンの申告(日本語)

**日付:** 2026-10-18
**ステータス:** Accepted

## 背景

国会議員の資産公開法では、報告は自己申告で検証されず、普通預金と当座預金は除外され、報告は紙のスナップショットである。このプロジェクトでは、議員の報酬と政務活動費が議員の`ResidentLink`アドレスに支払われるので、そのアドレスはすでに公表されている([ADR 0019](0019-treasury-model.md))。同じ議論([ログ](../state-design/vip-asset-disclosure/discussion-log.md))で決まった認定アドレス制のステーブルコイン([ADR 0020](0020-certified-address-stablecoin.md))により、円は申告されていないアドレスに置けなくなる。

## 決定

- **要人**は、国会議員と地方議員、首長、大臣と副大臣とする。公務員は要人に含めない。家族には申告を求めない。
- **新しいコントラクトは作らない。** 公表された要人の`ResidentLink`アドレスが、残高、収入、支出を継続的に示す。オフチェーンのアプリケーションがそれを分析する。
- **オフチェーンの申告**は、オンチェーンにない資産(普通預金を含む)と円以外のトークンの保有を対象とする。オンラインで公表し、徹底して確認する。**申告漏れには厳罰を科す**。たとえば政治の世界からの永久追放。
- **退任後**は、軽い承継の手続きで新しい`ResidentLink`アドレスに切り替える。古いアドレスと新しいアドレスの見える結びつきは、政治家が負う覚悟の一部として受け入れる。

## 結果

- 要人の資産公開は、円のすべてについて継続的かつ検証可能になり、コントラクトのコストはかからない。
- その強さはADR 0020に依存する。認定アドレス制のルールがなければ、2つ目のアドレスで抜けられてしまう。
- オフチェーンの資産と円以外のトークンは、より多くの資産がオンチェーンに移るまで(不動産登記など)、申告に依存する。
- 元要人は、追い続けようとする人には追われうる。これは意図的に受け入れる。

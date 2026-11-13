# 0029. Real estate registry model: the token is the right; owner plus agent to transfer; no parcel on-chain; no foreign ownership

**Date:** 2026-11-14
**Status:** Accepted. Extends [ADR 0020](0020-certified-address-stablecoin.md) (new certified kind `NonResidentOwner`) and [ADR 0028](0028-personal-data-model.md) (new `AnchorRegistry` kind).

## Context

Kept in the scope triage ([ADR 0027](0027-remaining-scope-triage.md)) for two problems a chain solves well: **impersonation of owners** (地面師; Sekisui House lost about ¥5.5 billion in 2017) and **unknown owners** (所有者不明土地, more than the area of Kyushu), caused by registry records that lose their link to the living person. Today the registry also publishes owners' names and home addresses. On a public chain, linking a parcel to an address would expose the owner's whole financial history. The user set the starting line as a state built on web3 from zero, with no migration from today's registry. See the [log](../state-design/real-estate/discussion-log.md).

## Decision

- **Real estate is tokenised** by the Legal Affairs Bureau in one `RealEstateToken` contract (parcels, buildings, condominium units, co-ownership shares). **Moving the token is the transfer of the right.**
- **Dealings are off-chain.** The parties check and exchange what they need off-chain and settle all conditions there; the token transfer is the last step. Optional atomic settlement against the stablecoin.
- **The token carries no lot number**, only a salted hash. Parcels held by corporations, public bodies and VIPs are published by the bureau; for individuals, the link is given only to parties with a legitimate interest.
- **Owner plus agent.** Owners appoint agents per token, publicly on-chain (only addresses are visible); a transfer, and a change of agents, needs the owner and at least one agent. Individuals must have agents; corporations use their multisig.
- **Without the owner's signature:** inheritance and key loss through ADR 0020's heavy successor path, moving money and property together; auction, judgment, prescription, expropriation and forced sales by the bureau, citing the hash of a registered decision.
- **Mortgages on-chain** as a lien that blocks transfer without the lender's consent; other rights off-chain, hashes anchored in `AnchorRegistry`.
- **Co-ownership:** one token per share.
- **Who may own:** residents, domestic corporations, public bodies, and Japanese nationals living abroad (new certified kind `NonResidentOwner`). **Foreign corporations and non-residents without Japanese nationality may not own land**; leases are allowed; ownership lost by inheritance or departure must be sold within a legal period.
- **Fixed-asset tax:** the municipality reads the owner on 1 January from the chain.

## Consequences

- Forged documents can no longer transfer land; an attacker needs the keys of both the owner and an agent.
- Moves never make the record stale, and an unhandled inheritance is visible on-chain.
- Individual owners' names stop being public: a privacy gain over today.
- The VIP-disclosure backlog item is half-closed: a VIP's real estate is visible from their address. Securities remain.
- The foreign-ownership ban can be bypassed through domestic corporations until the securities design traces ownership to the final individual.
- One new contract (`RealEstateToken`), one new certified kind, and one new `AnchorRegistry` kind.

---

# 0029. 不動産登記モデル: トークンが権利そのもの。移転は所有者と代理人で。土地はオンチェーンに載せない。外国人の所有は認めない(日本語)

**日付:** 2026-11-14
**ステータス:** Accepted。[ADR 0020](0020-certified-address-stablecoin.md)(新しい認定の種類`NonResidentOwner`)と[ADR 0028](0028-personal-data-model.md)(`AnchorRegistry`の新しい種類)を拡張する。

## 背景

スコープの振り分け([ADR 0027](0027-remaining-scope-triage.md))で、チェーンがうまく解決できる2つの問題のために残された: **所有者へのなりすまし**(地面師。2017年に積水ハウスが約55億円を失った)と**所有者不明土地**(九州より広い)。どちらも、登記の記録が生きている本人とのつながりを失うことから起きる。現在の登記は所有者の氏名と住所も公開している。公開のチェーン上で土地とアドレスを結びつけると、所有者の収支の履歴がすべてさらされる。ユーザーは、ゼロからweb3で作る国家をスタートラインとし、現在の登記からの移行は想定しないとした。[議論ログ](../state-design/real-estate/discussion-log.md)を参照。

## 決定

- **不動産をトークン化する。** 法務局が1つの`RealEstateToken`コントラクトで発行する(土地、建物、区分所有建物の専有部分、共有持分)。**トークンの移転が権利の移転である。**
- **取引はオフチェーンで。** 当事者は必要なことをオフチェーンで確認・交換し、条件もそこでまとめる。トークンの移転は最後の手順。ステーブルコインとの任意のアトミック決済を用意する。
- **トークンは地番を持たず**、ソルト付きハッシュだけを持つ。法人、公的機関、要人が持つ土地は法務局が公開する。個人については、対応を正当な利害関係者にだけ伝える。
- **所有者と代理人。** 所有者はトークンごとに代理人を設定し、オンチェーンで公開する(見えるのはアドレスだけ)。移転と代理人の変更には、所有者と1人以上の代理人が必要。個人は代理人を置かなければならない。法人はマルチシグを使う。
- **所有者の署名のない移転:** 相続と鍵の紛失はADR 0020の重い承継の手続きで、資金と不動産をまとめて移す。競売、判決、時効取得、収用、強制的な売却は、登録された決定のハッシュを示して法務局が行う。
- **抵当権はオンチェーン**の担保とし、貸し手の同意なしには移転できない。その他の権利はオフチェーンで、ハッシュを`AnchorRegistry`にアンカリングする。
- **共有:** 持分ごとに1つのトークン。
- **所有資格:** 住民、国内法人、公的機関、海外に住む日本国籍の人(新しい認定の種類`NonResidentOwner`)。**外国法人と日本国籍を持たない非居住者は土地を所有できない。** 借地は認める。相続や出国で所有資格を失った場合は法定期間内に売却する。
- **固定資産税:** 市区町村は1月1日の所有者をチェーンから読む。

## 結果

- 偽造書類で土地を移転することはできなくなる。攻撃者には所有者と代理人の両方の鍵が必要になる。
- 引っ越しで記録が古くなることはなく、処理されない相続はオンチェーンで見える。
- 個人の所有者の氏名は公開されなくなる。現在よりプライバシーが向上する。
- 要人の資産公開のバックログ項目は半分閉じる: 要人の不動産はそのアドレスから見える。有価証券が残る。
- 外国人による所有の禁止は、有価証券の設計が最終的な個人まで所有を追跡するまで、国内法人を通じて回避できる。
- 新しいコントラクト1つ(`RealEstateToken`)、新しい認定の種類1つ、`AnchorRegistry`の新しい種類1つ。

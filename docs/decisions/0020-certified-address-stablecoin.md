# 0020. Certified-address JPY stablecoin: transfers only between state-certified addresses; frozen balances leave only to certified successors

**Date:** 2026-10-18
**Status:** Accepted. Extends [ADR 0004](0004-taxation-payment-rail.md) (payment rail) and [ADR 0015](0015-political-donations-model.md) (`OfficialContractRegistry`).

## Context

While designing VIP asset disclosure, the obvious evasion was holding money at an undeclared second address. The user answered it at the root, with a new legal premise: receiving income at, or funds from, an address not linked to a `ResidentLink` is illegal. The user also proposed a technical rule: the FSA-licensed JPY stablecoin should not be able to reach any address the state has not certified.

Forces ([log](../state-design/vip-asset-disclosure/discussion-log.md), Rounds 2–4):

- **Confiscation** would need a state power to move funds inside the stablecoin.
- **Addresses lose certification** on a move gap, a key loss, a death, or a corporate dissolution.
- **ADR 0018 refused** to give the court power over wallets inside the stablecoin.
- **A per-transfer check** cannot query ~1,700 municipal contracts.
- **People without a `ResidentLink`** (visitors) exist.
- **Other tokens** cannot be bound by this contract.

## Decision

- **Transfers revert unless both sender and recipient are certified.** Certified means: a `ResidentLink` holder, a registered corporation, a registered public or official contract, or a valid visitor pass. Nothing is confiscated.
- **One aggregated certified-address list** in `OfficialContractRegistry`, written by registrars for their own kind only (identity contracts on mint and burn; 総務省 and approved factories for public contracts; the visitor-pass contract).
- **Every money-holding contract must be registered.** Unregistered contracts cannot hold the stablecoin.
- **Successor migration** is the only way out of a decertified address, and only to certified successors. An active address can never be touched, which keeps ADR 0018's refusal intact.
  - **Light path** (the owner signs; the municipality confirms): voluntary address changes, such as a VIP leaving office.
  - **Heavy path** (no owner signature: key loss, death, residue after dissolution): the municipality certifies the case and examines the address's past flows; a court approves; the multisig of both the municipality and the court is required; a public waiting period follows, during which the old address can veto by signing. It is deliberately tedious, so that criminals will not want to attempt it.
- **Visitor pass:** issued by the Immigration Services Agency at entry, with a legal duration limit and balance cap held in the registry. Its expiry is enforced on-chain.
- **Off-chain law:** domestic payment use of foreign stablecoins that lack this rule is prohibited; holding them, or other tokens, triggers enhanced monitoring. The native gas token is not bound by the contract.

## Consequences

- The entire JPY economy becomes traceable by identity. Every unit of the stablecoin sits at an address that is a resident, a corporation, a public contract or a visitor. Hiding money in a second address becomes impossible for JPY.
- Every earlier design that holds money must register its contracts: `PublicTreasury`, `PoliticalFund`, corporate multisigs, and future escrow and crowdfunding contracts. DeFi is effectively excluded from the JPY rail.
- Balances freeze during certification gaps (e.g. a move), so municipalities must keep reissuance quick.
- The stablecoin now contains one narrowly-scoped forced-transfer power. Its multisig keys (municipality and court) become high-value targets, covered by the existing multisig-standard backlog item.
- Visitors and cross-border payments depend on certified exchange operators.
- **The cross-feature consistency review must revisit earlier designs under this premise** (tracked in the backlog).

---

# 0020. 認定アドレス制の円建てステーブルコイン: 国家が認定したアドレスの間でのみ送金できる。凍結された残高は認定済みの承継先にのみ出ていける(日本語)

**日付:** 2026-10-18
**ステータス:** Accepted。[ADR 0004](0004-taxation-payment-rail.md)(決済レール)と[ADR 0015](0015-political-donations-model.md)(`OfficialContractRegistry`)を拡張する。

## 背景

要人の資産公開を設計する中で、最も分かりやすい抜け道は、申告しない2つ目のアドレスにお金を置くことだった。ユーザーはこれに根本から答え、新しい法的な前提を置いた。`ResidentLink`と結びついていないアドレスで所得を受け取ること、またはそうしたアドレスから資金を受け取ることは違法とする。さらに技術的なルールも提案した。金融庁が認可する円建てステーブルコインは、国家が認定していないアドレスには届かないようにする。

考慮すべき事情([ログ](../state-design/vip-asset-disclosure/discussion-log.md)、Round 2〜4):

- **没収**には、ステーブルコインの中でお金を動かす国家の権限が必要になる。
- **アドレスが認定を失う**場合がある: 転居の空白期間、鍵の紛失、死亡、法人の解散。
- **ADR 0018は**、ステーブルコインの中で裁判所がウォレットに権限を持つことを退けた。
- **送金ごとの確認**で、約1,700の自治体のコントラクトを照会することはできない。
- **`ResidentLink`を持たない人**(旅行者)がいる。
- **他のトークン**は、このコントラクトでは縛れない。

## 決定

- **送金は、送金元と受取人の両方が認定済みでなければリバートする。** 認定済みとは、`ResidentLink`の保有者、登記済みの法人、登録された公的・公式のコントラクト、有効な旅行者パスのいずれかである。没収はしない。
- **`OfficialContractRegistry`に、認定アドレスを集約した1つの一覧**を置く。登録者は自分の種類だけを書き込む(本人確認のコントラクトはmintとburnのとき、総務省と承認されたファクトリは公的なコントラクトについて、旅行者パスのコントラクト)。
- **お金を持つすべてのコントラクトは登録しなければならない。** 登録されていないコントラクトはステーブルコインを持てない。
- **承継の移転**だけが、認定を失ったアドレスからの唯一の出口であり、認定済みの承継先にだけ移せる。有効なアドレスには決して手を出せないので、ADR 0018の判断はそのまま守られる。
  - **軽い手続き**(持ち主が署名し、役所が確認する): 要人の退任など、任意のアドレス変更。
  - **重い手続き**(持ち主の署名なし: 鍵の紛失、死亡、解散後の残り): 役所が事案を認定し、アドレスの過去の流れを調べる。裁判所が承認し、役所と裁判所の両方のマルチシグが必要になる。その後に公開の待機期間があり、その間、古いアドレスは署名で拒否できる。犯罪者がやりたくないと思うよう、意図的に面倒にしてある。
- **旅行者パス:** 出入国在留管理庁が入国時に発行する。法定の期間の上限と残高の上限をレジストリが持ち、期限はオンチェーンで強制する。
- **オフチェーンの法律:** このルールを持たない外国のステーブルコインの国内での決済利用は禁止する。それらや他のトークンの保有は監視強化の対象となる。ガス用のネイティブトークンはコントラクトでは縛らない。

## 結果

- 円の経済全体が、本人と結びついた形で追跡可能になる。ステーブルコインのすべての単位は、住民、法人、公的なコントラクト、旅行者のいずれかのアドレスにある。円について、2つ目のアドレスにお金を隠すことは不可能になる。
- お金を持つこれまでのすべての設計は、そのコントラクトを登録しなければならない: `PublicTreasury`、`PoliticalFund`、法人のマルチシグ、今後のエスクローやクラウドファンディングのコントラクト。DeFiは事実上、円のレールから外れる。
- 認定の空白期間(転居など)には残高が凍結されるので、自治体は再発行を迅速に行う必要がある。
- ステーブルコインは、範囲を狭く絞った強制移転の権限を1つ持つことになる。そのマルチシグの鍵(役所と裁判所)は価値の高い攻撃対象になる。これは既存のマルチシグ規格のBACKLOG項目で扱う。
- 旅行者と国境を越える支払いは、認定された交換事業者に依存する。
- **機能間の整合性レビューでは、この前提の下でこれまでの設計を見直す必要がある**(BACKLOGで管理)。

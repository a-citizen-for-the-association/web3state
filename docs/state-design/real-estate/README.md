# Real estate registry (不動産登記)

**Status: 🟢 Spec drafted.** Kept in the scope triage ([ADR 0027](../../decisions/0027-remaining-scope-triage.md)), screened with the on-chain value test and resolved through discussion; see [`discussion-log.md`](discussion-log.md) for the reasoning and [ADR 0029](../../decisions/0029-real-estate-registry-model.md) for the formal decision. No contract code written yet.

## Summary

Every land parcel, building, condominium unit and co-ownership share is a **token issued by the Legal Affairs Bureau (法務局)**, held at the owner's certified address. **Moving the token is the transfer of the right.** The parties check and exchange everything they need off-chain, settle all conditions there, and the token transfer is the last step, so no personal data reaches the chain.

- **Impersonation (地面師) becomes structurally impossible:** a transfer needs the owner's signature **and at least one agent's** (代理人), not papers.
- **Owners cannot become unknown:** the owner is an address, which does not change on a move, and a death is visible when the `ResidentLink` is burned.
- **The token does not show which parcel it is.** Only parcels held by corporations, public bodies and VIPs are published.

This design assumes a state built on web3 from the start; there is no migration from an existing registry.

## Scope

**In scope:** ownership (甲区) of land, buildings, condominium units, and co-ownership shares; its transfer and settlement; mortgages; transfers without the owner's signature; who may own.

**Out of scope:**
- The title section (表題部: location, lot number, area, land category), maps and boundaries (筆界): off-chain, kept and published by the bureau.
- Valuation and the amount of fixed-asset tax: off-chain ([ADR 0004](../../decisions/0004-taxation-payment-rail.md)).
- The management of vacant houses: institutional; helped indirectly because owners are always known.
- Fractional or tokenised investment in property: the securities item.
- Foreign-controlled domestic corporations: left to the securities design ([`docs/BACKLOG.md`](../../BACKLOG.md)).

## On-chain / Online / Offline breakdown

(See [`docs/operations/README.md`](../../operations/README.md) for the convention.)

**On-chain:**
- **New: `RealEstateToken`**, one contract run by the bureau: the tokens, agent sets, mortgages, settlement and forced transfers.
- **New certified kind `NonResidentOwner`** in `OfficialContractRegistry` ([ADR 0020](../../decisions/0020-certified-address-stablecoin.md)).
- Existing: `ResidentLink`, `OfficialContractRegistry`, the JPY stablecoin, `AnchorRegistry` ([ADR 0028](../../decisions/0028-personal-data-model.md)).

**Online:**
- The bureau's public list of parcels held by corporations, public bodies and VIPs, with the salt for each, so anyone can check it against the token.
- The bureau's lookup service that tells parties with a legitimate interest which token is which parcel.

**Offline:**
- All negotiation, due diligence and the exchange of personal data between buyer and seller.
- The title section, maps and boundaries; valuation; fixed-asset tax amounts.
- Leases, easements and other rights (only their hashes are anchored).
- Permission decisions (e.g. farmland) and court decisions.
- Nationality checks for `NonResidentOwner`.

## Architecture

### `RealEstateToken` (one contract, run by the Legal Affairs Bureau)

Each token holds:
- `parcelHash`: a salted hash of the lot number (or building / unit number). **No lot number on-chain.**
- `share`: the fraction for a co-ownership share (1/1 for sole ownership).
- `needsApproval`: set by the bureau for parcels whose transfer needs a permission (e.g. farmland).
- `lien`: the lender's address and the hash of the mortgage contract, if any.
- `agents`: the addresses of the owner's agents for this token, **in plain view**.

The contract holds the stablecoin during settlement, so it is registered in `OfficialContractRegistry` (ADR 0020).

### Agents

- **Agents are set per token** (Round 5): an owner may choose different agents for different properties.
- **Agents are public** (Round 5): only addresses are visible. Whether an address is linked to a person is the person's own matter; web3state treats this kind of information as something that can be seen, not something to hide.
- Agents must be certified addresses other than the owner (family, a judicial scrivener, a bank).
- **Changing a token's agents** needs the owner and at least one current agent of that token.
- **First agents:** the new owner names the token's agents **as part of receiving it** (in the transfer, the settlement or the forced transfer, signed by the new owner) *(spec-time adjustment)*. An individual's token cannot be received without at least one agent. Corporations need none (their multisig does the same job).
- **No valid agent left** (an agent's `ResidentLink` burned, key lost): an agent counts only while certified at signing time. If none remains, the owner sets a new one with the municipality's confirmation (as ADR 0020's light path).
- **Owner's key lost:** agents cannot transfer alone; recovery is ADR 0020's heavy successor path, which moves tokens together with funds.

### Transfers

`transfer(tokenId, to, newAgents, agentSignature)`, called by the owner, with `newAgents` signed by the recipient. It reverts unless:
- the signature comes from one of the token's agents (owner is an individual), or the call comes from the corporate multisig;
- `to` is an **eligible owner** (below) and, if an individual, names at least one agent;
- if `lien` is set, the lender has consented (signature);
- if `needsApproval` is set, the bureau has approved this transfer.

**Settlement (optional, atomic):** the buyer deposits the price in the stablecoin for a list of tokens and a deadline; the owner's call with an agent's signature moves the tokens and releases the money in one transaction. The buyer can withdraw after the deadline. Transfers without payment (gifts) use `transfer` directly. A co-owned parcel is sold as a list of share tokens in one settlement.

### Eligible owners

- `ResidentLink` holders (Japanese or foreign residents).
- Registered domestic corporations and public bodies.
- **`NonResidentOwner`:** certified by the bureau after an off-chain check of identity and **Japanese nationality** (e.g. via the passport credential). A citizen moving abroad switches to it **on the same address** before the `ResidentLink` is burned; on return, the municipality mints the `ResidentLink` again and the bureau removes the certification. The address can also hold the stablecoin (receive rent and sale proceeds, pay fixed-asset tax), which adds one kind to ADR 0020's list.
- **Not eligible:** foreign corporations, non-residents without Japanese nationality, and visitor passes. **Leases are allowed** to anyone (off-chain).
- **Losing eligibility** (a foreign heir living abroad; a foreign resident leaving): the token must be sold within a legal period; after that, the court orders a sale and the bureau carries it out as a forced transfer.

### Transfers without the owner's signature

- **Inheritance and the owner's key loss:** ADR 0020's heavy successor path (municipality + court multisig, public waiting period). The path's multisig is authorised on `RealEstateToken`, so money and property move in one procedure. A token at an address whose `ResidentLink` was burned is visible on-chain, so an unhandled inheritance shows by itself.
- **Auction, judgment, prescription, expropriation, forced sale:** `forceTransfer(tokenId, to, decisionHash, kind)`, callable only by the bureau. It emits a public event with the hash of the decision in `CaseRecordRegistry` ([ADR 0018](../../decisions/0018-judiciary-model.md)) or, for expropriation, the anchored decision of the expropriating body. **The contract does not look the decision up on-chain**; anyone can check it off-chain *(adjustment, "off-chain if it can be")*. A forced sale on foreclosure clears the lien.

### Mortgages and other rights

- `setLien(tokenId, lender, contractHash)`: the owner (with an agent) and the lender sign. `releaseLien(tokenId)`: only the lender.
- Leases, easements and other rights stay in the bureau's off-chain registry. **Their hashes are anchored in `AnchorRegistry`** under a new kind `RealEstateRight` *(adjustment: reuse instead of a new registry)*.

### Disclosure of parcels

- For tokens held by corporations, public bodies and VIPs, the bureau publishes the lot number **and the salt** online, so anyone can check them against `parcelHash` *(adjustment: published off-chain, not in an event)*. This closes the real-estate half of the VIP-disclosure backlog item.
- For individuals, the bureau's public registry shows only "owned by an individual". The token–parcel link is given to parties with a legitimate interest (a buyer before a sale, a lender, a neighbour in a boundary matter, a court, the municipality).
- **Fixed-asset tax:** the bureau gives each municipality the mapping for its area; the municipality reads the owner at the last block of 1 January and is paid as in ADR 0004.

## Spec-time adjustments (accepted in Round 6)

1. *(Withdrawn in Round 5: agents are per token and public.)*
2. *(Withdrawn in Round 5.)*
3. The new owner names the token's first agents as part of receiving it.
4. `forceTransfer` records the decision hash in an event; the contract does not check it on-chain.
5. Other rights are anchored in the existing `AnchorRegistry` (new kind `RealEstateRight`).
6. Parcels of corporations, public bodies and VIPs are published off-chain with their salt.

## Known limits

- A buyer must trust the bureau's off-chain answer about which token is which parcel; the bureau stays a trusted party for the title section.
- An owner and an agent who both lose their keys to the same attacker (e.g. a shared device) are not protected.
- The foreign-ownership ban can be bypassed through a domestic corporation until the securities design traces ownership.
- Sale proceeds owed to a foreign heir abroad need a cross-border payment path, which is still open ([`docs/BACKLOG.md`](../../BACKLOG.md)).
- Transfers and settlement amounts are public, as for all stablecoin payments; the parcel is not.

---

# 不動産登記(日本語)

**ステータス: 🟢 設計確定。** スコープの振り分け([ADR 0027](../../decisions/0027-remaining-scope-triage.md))で残され、オンチェーン価値テストで選別し、議論で解決した。理由は[`discussion-log.md`](discussion-log.md)、正式な決定は[ADR 0029](../../decisions/0029-real-estate-registry-model.md)を参照。コントラクトコードはまだない。

## 概要

土地の各筆、建物、区分所有建物の専有部分、共有持分のそれぞれが、**法務局が発行するトークン**であり、所有者の認定アドレスに置かれる。**トークンの移転が権利の移転である。** 当事者は必要なことをすべてオフチェーンで確認・交換し、条件もそこでまとめる。トークンの移転は最後の手順なので、個人情報はチェーンに載らない。

- **なりすまし(地面師)は構造的に不可能になる:** 移転に必要なのは書類ではなく、所有者の署名**と1人以上の代理人の署名**である。
- **所有者は不明にならない:** 所有者はアドレスであり、引っ越しでは変わらない。死亡は`ResidentLink`のburnで見える。
- **トークンはどの土地かを示さない。** 公開するのは、法人、公的機関、要人が持つ土地だけ。

この設計は最初からweb3で作られた国家を前提とし、既存の登記からの移行はない。

## スコープ

**対象:** 土地、建物、区分所有建物の専有部分、共有持分の所有権(甲区)。その移転と決済。抵当権。所有者の署名のない移転。誰が所有できるか。

**対象外:**
- 表題部(所在、地番、地積、地目)、地図と筆界: オフチェーンで、法務局が保管・公開する。
- 評価と固定資産税の額: オフチェーン([ADR 0004](../../decisions/0004-taxation-payment-rail.md))。
- 空き家の管理: 制度の問題。所有者が常にわかることで間接的に助けられる。
- 不動産の小口化・トークン化投資: 有価証券の項目。
- 外国人が支配する国内法人: 有価証券の設計に委ねる([`docs/BACKLOG.md`](../../BACKLOG.md))。

## オンチェーン/オンライン/オフラインの内訳

(区分の考え方は[`docs/operations/README.md`](../../operations/README.md)を参照。)

**オンチェーン:**
- **新規: `RealEstateToken`。** 法務局が運用するコントラクトを1つ: トークン、代理人の集合、抵当権、決済、強制的な移転。
- **新しい認定の種類`NonResidentOwner`**を`OfficialContractRegistry`に([ADR 0020](../../decisions/0020-certified-address-stablecoin.md))。
- 既存: `ResidentLink`、`OfficialContractRegistry`、円建てステーブルコイン、`AnchorRegistry`([ADR 0028](../../decisions/0028-personal-data-model.md))。

**オンライン:**
- 法人、公的機関、要人が持つ土地の、法務局による公開の一覧。各土地のソルト付きで、誰でもトークンと照合できる。
- 正当な利害関係者に、どのトークンがどの土地かを教える法務局の照会サービス。

**オフライン:**
- 買主と売主の間の交渉、調査、個人情報のやり取りのすべて。
- 表題部、地図と筆界。評価。固定資産税の額。
- 賃借権、地役権などの権利(ハッシュだけをアンカリング)。
- 許可の判断(例: 農地)と裁判所の決定。
- `NonResidentOwner`のための国籍の確認。

## アーキテクチャ

### `RealEstateToken`(法務局が運用するコントラクトを1つ)

各トークンが持つもの:
- `parcelHash`: 地番(または家屋番号・専有部分の番号)のソルト付きハッシュ。**地番はオンチェーンに載らない。**
- `share`: 共有持分の割合(単独所有なら1/1)。
- `needsApproval`: 移転に許可が必要な土地(例: 農地)に法務局が設定する。
- `lien`: 抵当権がある場合、貸し手のアドレスと抵当権設定契約のハッシュ。
- `agents`: このトークンについての所有者の代理人のアドレス。**公開で見える**。

このコントラクトは決済の間ステーブルコインを保持するので、`OfficialContractRegistry`に登録する(ADR 0020)。

### 代理人

- **代理人はトークンごとに設定する**(Round 5): 所有者は不動産ごとに別の代理人を選べる。
- **代理人は公開する**(Round 5): 見えるのはアドレスだけである。あるアドレスが誰のものかを公表するかは本人の問題である。web3stateでは、この種の情報は隠すものではなく、見えても問題ないものとして扱う。
- 代理人は、所有者以外の認定アドレスでなければならない(家族、司法書士、銀行)。
- **トークンの代理人の変更**には、所有者と、そのトークンの現在の代理人の1人以上が必要。
- **最初の代理人:** 新しい所有者は、**トークンを受け取る手続きの中で**(移転、決済、強制的な移転の中で、新しい所有者の署名つきで)そのトークンの代理人を指定する(*仕様作成時の調整*)。個人は、代理人を1人以上指定しなければトークンを受け取れない。法人は不要(マルチシグが同じ役割を果たす)。
- **有効な代理人がいなくなった場合**(代理人の`ResidentLink`のburn、鍵の紛失): 代理人は署名の時点で認定されているときだけ数えられる。誰も残っていなければ、所有者は市区町村の確認を得て新しく設定する(ADR 0020の軽い手続きと同様)。
- **所有者の鍵の紛失:** 代理人だけでは移転できない。回復はADR 0020の重い承継の手続きで、資金と一緒にトークンも移す。

### 移転

`transfer(tokenId, to, newAgents, agentSignature)`を所有者が呼ぶ。`newAgents`には受け取る側が署名する。次の場合を除きrevertする:
- 署名がそのトークンの代理人の1人からのものである(所有者が個人の場合)、または法人のマルチシグからの呼び出しである。
- `to`が**所有資格のある者**(下記)であり、個人の場合は代理人を1人以上指定している。
- `lien`がある場合、貸し手が同意している(署名)。
- `needsApproval`がある場合、法務局がこの移転を承認している。

**決済(任意、アトミック):** 買主がトークンの一覧と期限を指定してステーブルコインで代金を預ける。所有者が代理人の署名つきで呼び出すと、トークンが移り、代金が1つのトランザクションで支払われる。期限を過ぎれば買主は引き出せる。支払いのない移転(贈与)は`transfer`を直接使う。共有の土地は、持分のトークンの一覧として1回の決済で売る。

### 所有資格のある者

- `ResidentLink`の保有者(日本人と外国人の住民)。
- 登録された国内法人と公的機関。
- **`NonResidentOwner`:** オフチェーンで本人と**日本国籍**を確認したうえで(例: パスポートのクレデンシャル)、法務局が認定する。海外に引っ越す国民は、`ResidentLink`がburnされる前に**同じアドレスのまま**これに切り替える。帰国すれば市区町村が再び`ResidentLink`をmintし、法務局が認定を外す。このアドレスはステーブルコインも持てる(賃料や売却代金を受け取り、固定資産税を払う)。これはADR 0020の一覧に種類を1つ加える。
- **所有資格のない者:** 外国法人、日本国籍を持たない非居住者、ビジターパス。**借地は誰にでも認める**(オフチェーン)。
- **所有資格を失った場合**(海外に住む外国籍の相続人、出国する外国人の住民): 法定期間内にトークンを売らなければならない。過ぎれば裁判所が売却を命じ、法務局が強制的な移転として実行する。

### 所有者の署名のない移転

- **相続と所有者の鍵の紛失:** ADR 0020の重い承継の手続き(市区町村と裁判所のマルチシグ、公開の待機期間)。この手続きのマルチシグに`RealEstateToken`での権限を与え、資金と不動産を1つの手続きで移す。`ResidentLink`がburnされたアドレスにあるトークンはオンチェーンで見えるので、処理されない相続はそれだけで浮かび上がる。
- **競売、判決、時効取得、収用、強制的な売却:** `forceTransfer(tokenId, to, decisionHash, kind)`。法務局だけが呼べる。`CaseRecordRegistry`([ADR 0018](../../decisions/0018-judiciary-model.md))にある決定のハッシュ、収用の場合は収用する機関のアンカリングされた決定のハッシュを付けて、公開のイベントを出す。**コントラクトはオンチェーンで決定を確認しない**。誰でもオフチェーンで確認できる(*調整、「オフチェーンでできることはオフチェーンで」*)。担保の実行による強制的な売却は、抵当権を消す。

### 抵当権とその他の権利

- `setLien(tokenId, lender, contractHash)`: 所有者(と代理人)と貸し手が署名する。`releaseLien(tokenId)`: 貸し手だけ。
- 賃借権、地役権などの権利は法務局のオフチェーンの登記に残す。**そのハッシュを`AnchorRegistry`に新しい種類`RealEstateRight`でアンカリングする**(*調整: 新しいレジストリを作らず再利用*)。

### 土地の開示

- 法人、公的機関、要人が持つトークンについては、法務局が地番**とソルト**をオンラインで公開し、誰でも`parcelHash`と照合できるようにする(*調整: イベントではなくオフチェーンで公開*)。これで要人の資産公開のバックログ項目のうち不動産の部分が閉じる。
- 個人については、法務局の公開の登記には「個人所有」とだけ示す。トークンと土地の対応は、正当な利害関係者(売買前の買主、貸し手、境界の問題での隣人、裁判所、市区町村)に伝える。
- **固定資産税:** 法務局は各市区町村にその区域の対応を渡す。市区町村は1月1日の最後のブロックでの所有者を読み、ADR 0004のとおり支払いを受ける。

## 仕様作成時の調整(Round 6で了承)

1. *(Round 5で取り下げ: 代理人はトークンごと、公開。)*
2. *(Round 5で取り下げ。)*
3. 新しい所有者は、受け取る手続きの中でトークンの最初の代理人を指定する。
4. `forceTransfer`は決定のハッシュをイベントに記録し、コントラクトはオンチェーンで確認しない。
5. その他の権利は既存の`AnchorRegistry`にアンカリングする(新しい種類`RealEstateRight`)。
6. 法人、公的機関、要人の土地は、ソルトとともにオフチェーンで公開する。

## 既知の限界

- 買主は、どのトークンがどの土地かについて法務局のオフチェーンの回答を信頼しなければならない。表題部については、法務局は信頼される当事者のままである。
- 所有者と代理人が同じ攻撃者に鍵を奪われた場合(例: 共有の端末)は守られない。
- 外国人による所有の禁止は、有価証券の設計が所有を追跡するまで、国内法人を通じて回避できる。
- 海外に住む外国籍の相続人への売却代金には、国境を越える支払いの経路が必要で、これはまだ決まっていない([`docs/BACKLOG.md`](../../BACKLOG.md))。
- 移転と決済の金額は、ほかのステーブルコインの支払いと同じく公開される。土地は公開されない。

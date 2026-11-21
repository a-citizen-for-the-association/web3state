# Payment rail: certified-address JPY stablecoin (認定アドレス制の円建てステーブルコイン)

**Status: 🟢 Spec drafted.** Raised and resolved during the [VIP asset disclosure discussion](../vip-asset-disclosure/discussion-log.md) (Rounds 2–4); formal decision in [ADR 0020](../../decisions/0020-certified-address-stablecoin.md). Its transfer rule is replaced by [ADR 0031](../../decisions/0031-registered-address-transfer-rule.md), and its registry and successor paths are amended by the cross-feature consistency review ([ADR 0032](../../decisions/0032-consistency-review-decisions.md)). The name is kept from ADR 0020; "registered" replaces "certified" in the text. No contract code written yet. This is a **project-wide premise**: it extends the payment rail of [ADR 0004](../../decisions/0004-taxation-payment-rail.md) and applies to every design that moves money.

## Summary

Each resident and each corporation has **one registered address**. Every JPY stablecoin licensed by the Financial Services Agency lets a registered address send to an unregistered address only up to a **cumulative amount per sender per period** (a legal parameter); splitting a payment does not help, because the contract counts the sender's total. This cap is the "cash-like" zone. VIP addresses have a cap of zero. Licensed exchangers and the issuer are exempt from the cap, but may send to an unregistered address only when exchanging the recipient's own foreign currency or cash. Public treasuries pay only registered addresses. Nothing else is blocked: transfers from unregistered addresses are free, public, and checked afterwards ([ADR 0031](../../decisions/0031-registered-address-transfer-rule.md)). Nothing is confiscated. An address that loses its registration is not frozen; it becomes an unregistered address. Land and shares at such an address, anything at a suspended address, and anything behind a lost key move only through a deliberately heavy successor path (registrar, review of past flows, court, multisig, public waiting period, owner veto).

**Legal premise (user):** receiving income at an address not linked to a `ResidentLink` (or another registered kind) is illegal; dealings with unregistered addresses within the cap are lawful and checked afterwards (ADR 0031). Domestic payment use of foreign stablecoins that do not implement this rule is prohibited, and holding them is grounds for enhanced monitoring.

## Scope

**In scope:** the transfer rule, including the cap on sending to unregistered addresses; the canonical definition of `OfficialContractRegistry`; suspension and successor migration.

**Out of scope (off-chain law and monitoring):** the native gas token, foreign stablecoins and other tokens. The contract cannot bind them.

## On-chain / Online / Offline breakdown

(See [`docs/operations/README.md`](../../operations/README.md) for the convention.)

**On-chain:**
- The transfer check in each licensed stablecoin, with each registered sender's running total sent to unregistered addresses in the current period.
- `OfficialContractRegistry` ([ADR 0015](../../decisions/0015-political-donations-model.md)), defined once [below](#officialcontractregistry-canonical-definition): official contract kinds, registered addresses (one flag per kind and registrar), the VIP and suspension marks, and legal parameters.
- `SuccessorMigration`: proposals, approvals, waiting periods, vetoes and executions.

**Online:**
- 総務省 publishes the registry address; the FSA publishes which stablecoins are licensed.

**Offline:**
- Who is entitled to a registration (municipalities, supervising authorities, 外務省, the FSA, 総務省).
- A licensed exchanger's identity check (e.g. passport) and records when it sends JPY to an unregistered address in exchange for the recipient's own foreign currency or cash.
- The registrar's examination of an address's past flows, and the court's approval, in the heavy path.
- The inheritance procedure that fixes heirs and shares.
- After-the-fact analysis of public flows (e.g. a round trip from a VIP through registered people), and enforcement of the law on exchangers, other tokens and foreign stablecoins.

## Architecture

### `OfficialContractRegistry`: canonical definition

One registry, operated by 総務省. This is its only definition; other specs point here (consistency review R1.2, [ADR 0032](../../decisions/0032-consistency-review-decisions.md)). It has two lookups.

**Lookup A: official contract kinds.** `kindOf(contract) → None | ResidentLink | CorporateRegistration | PublicTreasury | …` tells other contracts which contracts are genuine official ones, for automated contract-to-contract checks ([ADR 0015](../../decisions/0015-political-donations-model.md), [ADR 0019](../../decisions/0019-treasury-model.md)). Written **by 総務省 only**, after checking the issuer's own off-chain attestation; every change emits an event. The registry also holds legal parameters: the accepted stablecoins, the cap on sending to unregistered addresses and its period, and other caps set by law (e.g. political donations).

**Lookup B: registered addresses.** One **flag per kind and registrar** (consistency review R1.1, [ADR 0032](../../decisions/0032-consistency-review-decisions.md)); an address is registered if any flag is set, so removing one registration does not unregister an address that still holds another (e.g. a corporation with several registration NFTs). Each registrar writes only its own flag, on registration and removal. One lookup per transfer replaces checking ~1,700 municipal contracts (S4).

| Kind | Registrar (writes the flag) | Covers |
|---|---|---|
| Resident | Each allowlisted `ResidentLink` contract (municipalities), on mint and burn | Residents |
| Corporation | The supervising authority (`CorporateRegistration`, one per authority), on mint and burn | Registered corporations; foreign companies' branches, with a foreign flag (R2.3) |
| PublicContract | 総務省 | `PublicTreasury` contracts (one per body per account, R1.6), `RealEstateToken`, public bodies' controlling multisigs (R1.3, R1.4) |
| `NationalAbroad` | 外務省 | Japanese nationals living abroad; renamed from `NonResidentOwner` and no longer tied to land (R2.2) |
| `ForeignInvestor` | FSA | Foreign investors, for shares only (R2.3) |
| FinancialVehicle | FSA | `ClearingContract`, trusts, partnerships, funds (R1.3) |
| (each factory's own flag) | Approved factories (e.g. `PoliticalFundFactory`, `TenderFactory`) | The contracts they deploy (`PoliticalFund`, `Tender`) |

Among private contracts, only supervised financial vehicles may register; other private contracts may stay unregistered and are then reached only within senders' caps (R1.3, ADR 0031). The `Visitor` kind is abolished (decision D1, ADR 0031).

**Marks on registered addresses:**
- **VIP flag:** written by the election boards. A VIP-flagged address has a cap of zero (ADR 0031). The flag stays for a legal period (e.g. one year) after leaving office (R5.9).
- **Suspended:** set by the municipality on a key-theft report ([below](#successor-migration-successormigration), R3.1).
- **Licensed exchanger / issuer:** marks the addresses exempt from the cap (ADR 0031).

**`AnchorRegistry` kinds.** The event-only `AnchorRegistry` accepts anchors from any registered address (R1.4). The author of a document anchors it from its own registered address; the contract does not restrict kinds, since obligations are law and checked afterwards (R4.2). The kind list is kept here, and can be extended:
- `ApprovalDocument`, `Evidence`, `AccessLog`, `RealEstateRight`, `CorporateResolution`, `TradeReport`, `ExpenseReport`, `LeavingStatement`.

### Transfer rule (in every licensed JPY stablecoin)

[ADR 0031](../../decisions/0031-registered-address-transfer-rule.md) replaces ADR 0020's "both ends certified" rule:

- **Registered → unregistered:** allowed only while the sender's cumulative total sent to unregistered addresses in the current period (e.g. a month), plus the amount, stays within the cap held in the registry. Splitting into small payments does not help.
- **VIP-flagged sender:** cap zero; it cannot send to unregistered addresses at all.
- **Licensed exchangers and the issuer:** exempt from the cap, but may send JPY to an unregistered address **only when exchanging the recipient's own foreign currency or cash**, after an off-chain identity check (e.g. passport) and with records. Forwarding JPY to an unregistered address on behalf of a registered customer is prohibited, because it would bypass a VIP's zero cap; violations are punished up to licence revocation. Issuance and redemption follow the same rule.
- **Public treasuries** pay only registered addresses (the payee check in `PublicTreasury.pay`, [treasury spec](../treasury/README.md), R2.1).
- **Suspended sender:** nothing can leave except by the heavy path (R3.1).
- **Everything else is free:** registered → registered, unregistered → registered and unregistered → unregistered. These transfers are public and checked afterwards.

### Successor migration (`SuccessorMigration`)

Moves value out of an address whose owner cannot, or must not, sign for it. It works **only** on an address whose registration has ended or that is suspended, and pays **only** to registered successors, so an active address can never be touched. This keeps [ADR 0018](../../decisions/0018-judiciary-model.md)'s refusal of court power over wallets (S3).

An address that loses its registration is **no longer frozen** (ADR 0031): whoever holds its key can still move its JPY, as with cash in a drawer, and inheritance law applies off-chain. **Land and shares** at such an address move only by the heavy path. The heavy-path multisig is authorised on **every asset-token contract** (`RealEstateToken`, `ShareToken`), stated once here; operator approvals and allowances lapse when the holder's registration ends or the address is suspended (consistency review R3.2, [ADR 0032](../../decisions/0032-consistency-review-decisions.md)).

| Case | Path |
|---|---|
| Move | The new municipality mints first and the old one burns afterwards, so there is no gap; the move-out declaration replaces the `everIssued` check (R3.8). Nothing to migrate |
| Emigration | Before the `ResidentLink` is burned, 外務省 registers the **same address** as `NationalAbroad`; the address keeps its JPY, land and shares, and pensions are paid abroad (R2.2). On return, the municipality mints again and 外務省 removes its flag |
| Voluntary address change (e.g. a VIP leaving office, now optional, R5.9) | **Light path:** the old address signs, naming the new registered address; the municipality confirms. No court and no waiting period |
| Merger | **Light path:** a transfer to the acquirer, signed by both corporations' multisigs and confirmed by the bureau (R3.5) |
| Key loss | **Heavy path** (below) |
| Key theft | The owner reports in person; the municipality marks the address **suspended** instead of burning the `ResidentLink`. Nothing can leave it except by the heavy path, and it cannot veto. The suspension lapses unless a court approves within a set period (e.g. two weeks) (R3.1) |
| Death | The registration ends. Whoever holds the key can still move the JPY; inheritance law applies off-chain (ADR 0031). Land and shares take the **heavy path**, with heirs and shares fixed by the inheritance procedure; so does the JPY if nobody holds the key |
| Corporate dissolution | Before the registration NFT is burned, the liquidator burns the corporation's issued credentials, cancels its share classes and distributes its assets, checked by the registrar from public data; any residue takes the heavy path (R3.5) |

**Heavy path** (user, Round 4: "so tedious that criminals would not want to attempt it"):
1. The person (or heirs) reports to the **registrar of the address's kind**: the municipality, 外務省, the corporation's registrar or the FSA (R3.4). The registrar certifies the case and examines the address's past inflows and outflows for anything suspicious (off-chain).
2. The registrar proposes the migration on-chain: old address, successors, shares, and, for land, each receiving heir's real-estate agents, signed by that heir. Land shared among heirs is re-issued by the bureau as co-ownership share tokens, each with its holder's agents (R3.9).
3. A **court** approves. Execution requires the multisig of **both** the registrar and the court.
4. **Public waiting period** (a legal parameter). During it, the old address can **veto** by signing, which defeats impersonation at the office (Round 4 adjustment). A suspended address cannot veto (R3.1).
5. After the waiting period, anyone can trigger execution. The JPY and asset tokens move to the successors, who must be registered.

## Known limits

- Other tokens and foreign stablecoins are policed by law, not code.
- An address's registration is only as good as the registrar's off-chain identity check.
- A VIP can still send to registered relatives or acquaintances who each forward within their own caps. Every first hop is public and VIP omissions are punished severely ([ADR 0021](../../decisions/0021-vip-asset-disclosure.md)); a round trip such as VIP → registered person → the VIP's own business is found afterwards by analysis (ADR 0031).
- The exchangers' rule (only the recipient's own foreign currency or cash) is enforced by records and licence law, not by the contract.
- Private contracts (e.g. DeFi) may stay unregistered; registered addresses can then reach them only within the sender's cap (ADR 0031).

---

# 決済レール: 認定アドレス制の円建てステーブルコイン(日本語)

**ステータス: 🟢 設計確定。** [要人の資産公開の議論](../vip-asset-disclosure/discussion-log.md)(Round 2〜4)の中で提起され、解決した。正式な決定は[ADR 0020](../../decisions/0020-certified-address-stablecoin.md)。その送金ルールは[ADR 0031](../../decisions/0031-registered-address-transfer-rule.md)で置き換えられ、レジストリと承継の手続きは機能間の整合性レビュー([ADR 0032](../../decisions/0032-consistency-review-decisions.md))で修正された。名前はADR 0020のものを残し、本文では「認定」を「登録」に改めた。コントラクトコードはまだない。これは**プロジェクト全体の前提**であり、[ADR 0004](../../decisions/0004-taxation-payment-rail.md)の決済レールを拡張し、お金を動かすすべての設計に適用される。

## 概要

住民と法人は、それぞれ**登録済みのアドレスを1つ**持つ。金融庁が認可するすべての円建てステーブルコインでは、登録済みのアドレスから未登録のアドレスへの送金は、**送り手ごと・期間ごとの合計額**の上限(法定のパラメータ)までしかできない。コントラクトが送り手の合計を数えるので、小分けにしても意味がない。この上限が「現金のように使える範囲」である。要人のアドレスの上限は0である。免許を受けた両替業者と発行者は上限の対象外だが、未登録のアドレスに送れるのは受取人本人の外貨や現金を両替する場合だけである。国庫は登録済みのアドレスにだけ支払う。それ以外は止めない: 未登録のアドレスからの送金は自由で、公開されており、後から確認する([ADR 0031](../../decisions/0031-registered-address-transfer-rule.md))。没収はしない。登録を失ったアドレスは凍結されず、未登録のアドレスになるだけである。そのアドレスにある土地と株式、停止中のアドレスにあるもの、紛失した鍵の先にあるものは、意図的に重い承継の手続き(登録者、過去の流れの調査、裁判所、マルチシグ、公開の待機期間、持ち主の拒否権)でしか動かない。

**法的な前提(ユーザー):** `ResidentLink`(またはその他の登録の種類)と結びついていないアドレスで所得を受け取ることは違法である。上限の範囲での未登録のアドレスとの取引は適法で、後から確認する(ADR 0031)。このルールを実装しない外国のステーブルコインの国内での決済利用は禁止し、その保有は監視強化の対象とする。

## スコープ

**対象:** 送金のルール(未登録のアドレスへの送金の上限を含む)、`OfficialContractRegistry`の正本の定義、停止と承継の移転。

**対象外(オフチェーンの法律と監視):** ガス用のネイティブトークン、外国のステーブルコイン、その他のトークン。コントラクトでは縛れない。

## オンチェーン/オンライン/オフラインの内訳

(区分の考え方は[`docs/operations/README.md`](../../operations/README.md)を参照。)

**オンチェーン:**
- 認可された各ステーブルコインの送金時の確認。登録済みの送り手ごとに、今の期間に未登録のアドレスへ送った累計を持つ。
- `OfficialContractRegistry`([ADR 0015](../../decisions/0015-political-donations-model.md))。定義は[下](#officialcontractregistry-正本の定義)に1か所だけ置く: 公式のコントラクトの種類、登録済みのアドレス(種類と登録者ごとに1つのフラグ)、要人と停止の印、法定のパラメータ。
- `SuccessorMigration`: 提案、承認、待機期間、拒否、実行。

**オンライン:**
- 総務省はレジストリのアドレスを公表し、金融庁はどのステーブルコインが認可されているかを公表する。

**オフライン:**
- 誰が登録の資格を持つか(市区町村、監督官庁、外務省、金融庁、総務省)。
- 免許を受けた両替業者が、受取人本人の外貨や現金と引き換えに未登録のアドレスへ円を送るときの本人確認(例: パスポート)と記録。
- 重い手続きにおける、登録者によるアドレスの過去の流れの調査と、裁判所の承認。
- 相続人と持分を確定する相続の手続き。
- 公開された流れの事後の分析(例: 要人から登録済みの人を経由する往復)と、両替業者、他のトークン、外国のステーブルコインに関する法律の執行。

## アーキテクチャ

### `OfficialContractRegistry`: 正本の定義

総務省が運用するレジストリは1つである。定義はここだけに置き、他の仕様はここを指す(整合性レビューR1.2、[ADR 0032](../../decisions/0032-consistency-review-decisions.md))。照会は2つある。

**照会A: 公式のコントラクトの種類。** `kindOf(contract) → None | ResidentLink | CorporateRegistration | PublicTreasury | …`は、どのコントラクトが本物の公式のコントラクトかを他のコントラクトに示し、コントラクト間の自動の確認に使う([ADR 0015](../../decisions/0015-political-donations-model.md)、[ADR 0019](../../decisions/0019-treasury-model.md))。書き込むのは**総務省だけ**で、発行者自身のオフチェーンの証明を確認してから書き込み、変更のたびにイベントを発行する。レジストリは法定のパラメータも持つ: 受け入れるステーブルコイン、未登録のアドレスへの送金の上限とその期間、法律で定めるその他の上限(例: 政治献金)。

**照会B: 登録済みのアドレス。** **種類と登録者ごとに1つのフラグ**を持つ(整合性レビューR1.1、[ADR 0032](../../decisions/0032-consistency-review-decisions.md))。どれかが立っていれば登録済みなので、1つの登録を外しても、別の登録を持つアドレスは登録済みのままである(例: 登録NFTを複数持つ法人)。各登録者は自分のフラグだけを、登録と取消しのときに書き込む。約1,700の市区町村のコントラクトを確認する代わりに、送金ごとに1回の照会で済む(S4)。

| 種類 | 登録者(フラグを書き込む者) | 対象 |
|---|---|---|
| Resident | 許可リストにある各`ResidentLink`コントラクト(市区町村)が、mintとburnのとき | 住民 |
| Corporation | 監督官庁(`CorporateRegistration`、官庁ごとに1つ)が、mintとburnのとき | 登録された法人。外国会社の支店は外国の印付き(R2.3) |
| PublicContract | 総務省 | `PublicTreasury`のコントラクト(機関ごと・勘定ごとに1つ、R1.6)、`RealEstateToken`、公的機関の管理用マルチシグ(R1.3、R1.4) |
| `NationalAbroad` | 外務省 | 海外に住む日本国籍の人。`NonResidentOwner`から改名し、土地と切り離した(R2.2) |
| `ForeignInvestor` | 金融庁 | 外国の投資家。株式のためだけ(R2.3) |
| FinancialVehicle | 金融庁 | `ClearingContract`、信託、組合、ファンド(R1.3) |
| (ファクトリーごとのフラグ) | 承認されたファクトリー(例: `PoliticalFundFactory`、`TenderFactory`) | それがデプロイするコントラクト(`PoliticalFund`、`Tender`) |

民間のコントラクトで登録できるのは監督下の金融の器だけである。その他の民間のコントラクトは未登録でもよく、その場合は送り手の上限の範囲でしか届かない(R1.3、ADR 0031)。種類`Visitor`は廃止した(決定D1、ADR 0031)。

**登録済みのアドレスに付ける印:**
- **要人の印:** 選挙管理委員会が書き込む。要人の印の付いたアドレスの上限は0である(ADR 0031)。印は退任後も法定の期間(例: 1年)残す(R5.9)。
- **停止:** 鍵の盗難の届出で市区町村が付ける([下](#承継の移転successormigration)、R3.1)。
- **免許を受けた両替業者・発行者:** 上限の対象外のアドレスを示す(ADR 0031)。

**`AnchorRegistry`の種類。** イベントだけの`AnchorRegistry`は、登録済みのアドレスならどこからでもアンカーを受け付ける(R1.4)。文書を作った者が自分の登録済みアドレスからアンカーする。コントラクトは種類を制限しない。義務は法律で定め、後から確認する(R4.2)。種類の一覧はここに置き、追加できる:
- `ApprovalDocument`、`Evidence`、`AccessLog`、`RealEstateRight`、`CorporateResolution`、`TradeReport`、`ExpenseReport`、`LeavingStatement`。

### 送金のルール(認可されたすべての円建てステーブルコイン)

[ADR 0031](../../decisions/0031-registered-address-transfer-rule.md)が、ADR 0020の「両端とも認定済み」のルールを置き換える:

- **登録済み → 未登録:** 送り手が今の期間(例: 1か月)に未登録のアドレスへ送った累計に金額を足しても、レジストリにある上限を超えない場合だけ認める。小分けにしても意味がない。
- **要人の印の付いた送り手:** 上限は0。未登録のアドレスには一切送れない。
- **免許を受けた両替業者と発行者:** 上限の対象外だが、未登録のアドレスに円を送れるのは**受取人本人の外貨や現金を両替する場合だけ**で、オフチェーンの本人確認(例: パスポート)と記録を要する。登録済みの客に代わって未登録のアドレスへ円を転送することは、要人の上限0の回避になるので禁止する。違反は免許取消しまでの罰則の対象。発行と償還も同じルールに従う。
- **国庫**は登録済みのアドレスにだけ支払う(`PublicTreasury.pay`の支払先の確認、[歳出・予算の仕様](../treasury/README.md)、R2.1)。
- **停止中の送り手:** 重い手続き以外では何も出せない(R3.1)。
- **それ以外は自由:** 登録済み → 登録済み、未登録 → 登録済み、未登録 → 未登録。これらの送金は公開されており、後から確認する。

### 承継の移転(`SuccessorMigration`)

持ち主が署名できない、または署名してはならないアドレスから価値を移す。登録が外れたか停止中のアドレスに**だけ**働き、登録済みの承継先に**だけ**支払うので、有効なアドレスには決して手を出せない。これにより、ウォレットに対する裁判所の権限を退けた[ADR 0018](../../decisions/0018-judiciary-model.md)の判断が守られる(S3)。

登録を失ったアドレスは**もう凍結されない**(ADR 0031): 鍵を持つ者なら、引き出しの中の現金と同じように円を動かせ、相続の法律はオフチェーンで適用される。そのアドレスにある**土地と株式**は重い手続きでしか動かない。重い手続きのマルチシグには**すべての資産トークンのコントラクト**(`RealEstateToken`、`ShareToken`)での権限を与え、ここで一度だけ定める。保有者の登録が外れるか停止されたら、オペレーターの承認とallowanceは失効する(整合性レビューR3.2、[ADR 0032](../../decisions/0032-consistency-review-decisions.md))。

| 場合 | 手続き |
|---|---|
| 転居 | 転入先の市区町村が先にmintし、転出元が後でburnするので、空白はない。`everIssued`の確認は転出届の確認に替える(R3.8)。移転するものはない |
| 海外への転出 | `ResidentLink`がburnされる前に、外務省が**同じアドレス**を`NationalAbroad`として登録する。アドレスは円、土地、株式を保ち、年金は海外にも払う(R2.2)。帰国すれば市区町村が再びmintし、外務省は自分のフラグを外す |
| 任意のアドレス変更(要人の退任など。今は任意、R5.9) | **軽い手続き:** 古いアドレスが署名して新しい登録済みアドレスを指定し、市区町村が確認する。裁判所も待機期間も要らない |
| 合併 | **軽い手続き:** 取得する法人への移転。両社のマルチシグが署名し、法務局が確認する(R3.5) |
| 鍵の紛失 | **重い手続き**(下記) |
| 鍵の盗難 | 本人が来所して届け出る。市区町村は`ResidentLink`をburnせず、アドレスに**停止**の印を付ける。重い手続き以外では何も出せず、拒否もできない。一定期間内(例: 2週間)に裁判所が承認しなければ停止は解除される(R3.1) |
| 死亡 | 登録が外れる。鍵を持つ者なら円は動かせ、相続の法律はオフチェーンで適用される(ADR 0031)。土地と株式は**重い手続き**を通り、相続人と持分は相続の手続きで確定する。鍵を持つ者がいなければ円も同じ |
| 法人の解散 | 登録NFTのburnの前に、清算人は法人が発行したクレデンシャルをburnし、株式の種類を消却し、資産を分配する。登録者が公開データで確認する。残りがあれば重い手続きを通る(R3.5) |

**重い手続き**(ユーザー、Round 4:「犯罪者がとてもやりたくないと思うほど面倒に」):
1. 本人(または相続人)が**アドレスの種類の登録者**に申し出る: 市区町村、外務省、法人の登録者、金融庁(R3.4)。登録者は事案を認定し、そのアドレスの過去の着金と送金に疑わしい点がないかを調べる(オフチェーン)。
2. 登録者がオンチェーンで移転を提案する: 古いアドレス、承継先、持分、そして土地については受け取る相続人それぞれの不動産の代理人(その相続人の署名つき)。相続人で分ける土地は、法務局が持分のトークンとして発行し直し、それぞれに保有者の代理人を付ける(R3.9)。
3. **裁判所**が承認する。実行には、登録者と裁判所の**両方**のマルチシグが必要である。
4. **公開の待機期間**(法定のパラメータ)。その間、古いアドレスは署名によって**拒否**でき、役所でのなりすましを防ぐ(Round 4の調整)。停止中のアドレスは拒否できない(R3.1)。
5. 待機期間の後、誰でも実行を起動できる。円と資産トークンは、登録済みでなければならない承継先に移る。

## 既知の限界

- 他のトークンと外国のステーブルコインは、コードではなく法律で取り締まる。
- アドレスの登録の確かさは、登録者のオフチェーンの本人確認の確かさに依存する。
- 要人は、登録済みの親族や知人に送り、それぞれがその上限の範囲で転送することはできる。最初の送金はすべて公開され、要人の申告漏れは重く罰せられる([ADR 0021](../../decisions/0021-vip-asset-disclosure.md))。要人 → 登録済みの人 → 要人自身の事業、のような往復は後から分析で見つかる(ADR 0031)。
- 両替業者のルール(受取人本人の外貨や現金だけ)は、コントラクトではなく記録と免許の法律で守らせる。
- 民間のコントラクト(DeFiなど)は未登録でもよい。その場合、登録済みのアドレスからは送り手の上限の範囲でしか届かない(ADR 0031)。

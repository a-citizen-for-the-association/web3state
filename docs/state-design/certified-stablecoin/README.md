# Payment rail: certified-address JPY stablecoin (認定アドレス制の円建てステーブルコイン)

**Status: 🟢 Spec drafted.** Raised and resolved during the [VIP asset disclosure discussion](../vip-asset-disclosure/discussion-log.md) (Rounds 2–4); formal decision in [ADR 0020](../../decisions/0020-certified-address-stablecoin.md). No contract code written yet. This is a **project-wide premise**: it extends the payment rail of [ADR 0004](../../decisions/0004-taxation-payment-rail.md) and applies to every design that moves money.

## Summary

Every JPY stablecoin licensed by the Financial Services Agency can move only **between addresses the state has certified**: `ResidentLink` holders, registered corporations, registered public or official contracts, and holders of a temporary visitor pass. Any other transfer reverts. Nothing is confiscated. When an address loses its certification, its balance is frozen. The balance can leave only to a certified successor: through a light procedure if the owner can still sign, or through a deliberately heavy one (municipality, review of past flows, court, multisig, public waiting period, owner veto) if not.

**Legal premise (user):** receiving income at, or receiving funds from, an address not linked to a `ResidentLink` (or another certified kind) is illegal. Domestic payment use of foreign stablecoins that do not implement this rule is prohibited, and holding them is grounds for enhanced monitoring.

## Scope

**In scope:** the transfer rule; the aggregated certified-address list; successor migration; the visitor pass.

**Out of scope (off-chain law and monitoring):** the native gas token, foreign stablecoins and other tokens. The contract cannot bind them.

## On-chain / Online / Offline breakdown

(See [`docs/operations/README.md`](../../operations/README.md) for the convention.)

**On-chain:**
- The transfer check in each licensed stablecoin.
- The **certified-address list**, part of `OfficialContractRegistry` ([ADR 0015](../../decisions/0015-political-donations-model.md)).
- `SuccessorMigration`: proposals, approvals, waiting periods, vetoes and executions.
- `VisitorPass` tokens with expiry; the duration limit and balance cap as registry parameters.

**Online:**
- 総務省 publishes the registry address; the FSA publishes which stablecoins are licensed.

**Offline:**
- Who is entitled to an identity (as before: municipalities, registration authorities, immigration).
- The municipality's examination of an address's past flows, and the court's approval, in the heavy path.
- The inheritance procedure that fixes heirs and shares.
- Enforcement of the law on other tokens and foreign stablecoins.

## Architecture

### Certified-address list (in `OfficialContractRegistry`, operated by 総務省)

- `certifiedKind(address) → None | Resident | Corporation | PublicContract | Visitor`, with an expiry for `Visitor`.
- **Registrars** write to it, each only for its own kind:
  - each allowlisted `ResidentLink` contract, on mint and burn;
  - each corporate-registration contract, on mint and burn;
  - 総務省 and approved factories (e.g. `PoliticalFundFactory`), for public and official money-holding contracts (`PublicTreasury`, `PoliticalFund`, and future escrow or crowdfunding contracts);
  - the `VisitorPass` contract.
- One lookup per transfer, instead of checking ~1,700 municipal contracts (S4).

### Transfer rule (in every licensed JPY stablecoin)

- `transfer`/`transferFrom` revert unless **both** sender and recipient are certified (S1; sender check: Round 4 adjustment). Visitor addresses are also checked against expiry and the balance cap on receipt.
- Issuance and redemption by the licensed issuer go only to and from certified addresses.

### Successor migration (`SuccessorMigration`)

The only way a balance leaves a decertified address. It works **only** on an address whose certification has been removed, and pays **only** to certified successors, so an active address can never be touched. This keeps [ADR 0018](../../decisions/0018-judiciary-model.md)'s refusal of court power over wallets (S3).

| Case | Path |
|---|---|
| Move | The same address is usually reissued by the new municipality. Frozen during the gap; nothing to migrate |
| Voluntary address change (e.g. a VIP leaving office) | **Light path:** the old address signs, naming the new certified address; the municipality confirms. No court and no waiting period |
| Key loss | **Heavy path** (below) |
| Death | **Heavy path**, with successors and shares fixed by the inheritance procedure |
| Corporate dissolution | The liquidator distributes with the corporation's own keys before deregistration; any residue takes the heavy path |

**Heavy path** (user, Round 4: "so tedious that criminals would not want to attempt it"):
1. The person (or heirs) reports to the municipality. The municipality certifies the case and examines the address's past inflows and outflows for anything suspicious (off-chain).
2. The municipality proposes the migration on-chain: old address, successors, shares.
3. A **court** approves. Execution requires the multisig of **both** the municipality and the court.
4. **Public waiting period** (a legal parameter). During it, the old address can **veto** by signing, which defeats impersonation at the office (Round 4 adjustment).
5. After the waiting period, anyone can trigger execution. The balance moves to the successors, who must be certified.

### Visitor pass (`VisitorPass`)

- Issued by the Immigration Services Agency at entry, to a visitor-chosen address. Soulbound, with an expiry.
- The **duration limit** and **balance cap** are legal parameters in the registry. Exchange to and from cash or foreign currency goes through certified operators (registered corporations).
- The expiry is actively enforced, a further justified on-chain date exception (after the voting period, the donation year and the petition period).
- What happens to a balance left after expiry: [`docs/BACKLOG.md`](../../BACKLOG.md).

## Known limits

- Other tokens and foreign stablecoins are policed by law, not code.
- An address's certification is only as good as the issuer's off-chain identity check.
- A balance is frozen while its address is decertified, e.g. during a move's gap.
- Every money-holding contract must be registered; unregistered smart contracts (e.g. DeFi) cannot hold the stablecoin.

---

# 決済レール: 認定アドレス制の円建てステーブルコイン(日本語)

**ステータス: 🟢 設計確定。** [要人の資産公開の議論](../vip-asset-disclosure/discussion-log.md)(Round 2〜4)の中で提起され、解決した。正式な決定は[ADR 0020](../../decisions/0020-certified-address-stablecoin.md)。コントラクトコードはまだない。これは**プロジェクト全体の前提**であり、[ADR 0004](../../decisions/0004-taxation-payment-rail.md)の決済レールを拡張し、お金を動かすすべての設計に適用される。

## 概要

金融庁が認可するすべての円建てステーブルコインは、**国家が認定したアドレスの間でしか**動かせない。認定されるのは、`ResidentLink`の保有者、登記済みの法人、登録された公的・公式のコントラクト、一時的な旅行者パスの保有者である。それ以外への送金はリバートし、没収はしない。アドレスが認定を失うと、その残高は凍結される。残高は認定済みの承継先にしか出ていけない。持ち主がまだ署名できれば軽い手続きで、できなければ意図的に重い手続き(役所、過去の流れの調査、裁判所、マルチシグ、公開の待機期間、持ち主の拒否権)で移す。

**法的な前提(ユーザー):** `ResidentLink`(またはその他の認定の種類)と結びついていないアドレスで所得を受け取ること、またはそうしたアドレスから資金を受け取ることは違法である。このルールを実装しない外国のステーブルコインの国内での決済利用は禁止し、その保有は監視強化の対象とする。

## スコープ

**対象:** 送金のルール、認定アドレスを集約した一覧、承継の移転、旅行者パス。

**対象外(オフチェーンの法律と監視):** ガス用のネイティブトークン、外国のステーブルコイン、その他のトークン。コントラクトでは縛れない。

## オンチェーン/オンライン/オフラインの内訳

(区分の考え方は[`docs/operations/README.md`](../../operations/README.md)を参照。)

**オンチェーン:**
- 認可された各ステーブルコインの送金時の確認。
- `OfficialContractRegistry`([ADR 0015](../../decisions/0015-political-donations-model.md))の一部としての**認定アドレスの一覧**。
- `SuccessorMigration`: 提案、承認、待機期間、拒否、実行。
- 期限付きの`VisitorPass`トークン。期間と残高の上限はレジストリのパラメータ。

**オンライン:**
- 総務省はレジストリのアドレスを公表し、金融庁はどのステーブルコインが認可されているかを公表する。

**オフライン:**
- 誰が本人確認の資格を持つか(これまでどおり: 自治体、登記の当局、出入国管理)。
- 重い手続きにおける、役所によるアドレスの過去の流れの調査と、裁判所の承認。
- 相続人と持分を確定する相続の手続き。
- 他のトークンや外国のステーブルコインに関する法律の執行。

## アーキテクチャ

### 認定アドレスの一覧(`OfficialContractRegistry`内、総務省が運用)

- `certifiedKind(address) → None | Resident | Corporation | PublicContract | Visitor`。`Visitor`には期限がある。
- **登録者**がこれに書き込む。それぞれ自分の種類だけ:
  - 許可リストにある各`ResidentLink`コントラクトが、mintとburnのとき。
  - 各法人登記コントラクトが、mintとburnのとき。
  - 総務省と承認されたファクトリ(`PoliticalFundFactory`など)が、公的・公式のお金を持つコントラクト(`PublicTreasury`、`PoliticalFund`、今後のエスクローやクラウドファンディングのコントラクト)について。
  - `VisitorPass`コントラクト。
- 約1,700の自治体のコントラクトを確認する代わりに、送金ごとに1回の照会で済む(S4)。

### 送金のルール(認可されたすべての円建てステーブルコイン)

- `transfer`/`transferFrom`は、送金元と受取人の**両方**が認定済みでなければリバートする(S1。送金元の確認はRound 4の調整)。旅行者のアドレスは、受け取りの際に期限と残高の上限も確認する。
- 認可された発行者による発行と償還は、認定済みのアドレスとの間でだけ行う。

### 承継の移転(`SuccessorMigration`)

認定を失ったアドレスから残高が出ていく唯一の方法である。認定が外されたアドレスに**だけ**働き、認定済みの承継先に**だけ**支払うので、有効なアドレスには決して手を出せない。これにより、ウォレットに対する裁判所の権限を退けた[ADR 0018](../../decisions/0018-judiciary-model.md)の判断が守られる(S3)。

| 場合 | 手続き |
|---|---|
| 転居 | 通常、新しい自治体が同じアドレスに再発行する。空白期間は凍結され、移転するものはない |
| 任意のアドレス変更(要人の退任など) | **軽い手続き:** 古いアドレスが署名して新しい認定済みアドレスを指定し、役所が確認する。裁判所も待機期間も要らない |
| 鍵の紛失 | **重い手続き**(下記) |
| 死亡 | **重い手続き**。承継先と持分は相続の手続きで確定する |
| 法人の解散 | 清算人が登記の抹消前に法人自身の鍵で分配する。残りがあれば重い手続きを通る |

**重い手続き**(ユーザー、Round 4:「犯罪者がとてもやりたくないと思うほど面倒に」):
1. 本人(または相続人)が役所に申し出る。役所は事案を認定し、そのアドレスの過去の着金と送金に疑わしい点がないかを調べる(オフチェーン)。
2. 役所がオンチェーンで移転を提案する: 古いアドレス、承継先、持分。
3. **裁判所**が承認する。実行には、役所と裁判所の**両方**のマルチシグが必要である。
4. **公開の待機期間**(法定のパラメータ)。その間、古いアドレスは署名によって**拒否**でき、役所でのなりすましを防ぐ(Round 4の調整)。
5. 待機期間の後、誰でも実行を起動できる。残高は、認定済みでなければならない承継先に移る。

### 旅行者パス(`VisitorPass`)

- 出入国在留管理庁が入国時に、旅行者が選んだアドレスに発行する。譲渡不可で、期限がある。
- **期間の上限**と**残高の上限**は、レジストリの法定のパラメータとする。現金や外貨との交換は、認定された事業者(登記済み法人)を通す。
- 期限はコントラクトが能動的に強制するので、正当化されたオンチェーンの日付の例外がもう1つ増える(投票期間、献金の年、署名の収集期間に続く)。
- 期限切れの後に残った残高の扱い: [`docs/BACKLOG.md`](../../BACKLOG.md)。

## 既知の限界

- 他のトークンと外国のステーブルコインは、コードではなく法律で取り締まる。
- アドレスの認定の確かさは、発行者のオフチェーンの本人確認の確かさに依存する。
- アドレスが認定を失っている間(転居の空白期間など)、残高は凍結される。
- お金を持つすべてのコントラクトは登録が必要で、登録されていないスマートコントラクト(DeFiなど)はステーブルコインを持てない。

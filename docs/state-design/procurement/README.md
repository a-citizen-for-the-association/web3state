# Public procurement / bidding (公共調達・入札)

**Status: 🟢 Spec drafted.** Screened with the on-chain value test and resolved through discussion with the user; see [`discussion-log.md`](discussion-log.md) for the reasoning and [ADR 0022](../../decisions/0022-procurement-model.md) for the formal decision. No contract code written yet.

## Summary

Every procurement, competitive or negotiated, is a `Tender` contract created by the procuring body. In a competitive tender, bidders commit a hash of their bid before the deadline and reveal it afterwards. The body commits a hash of its ceiling price the same way. Nobody, including the body, can see a bid before opening; nothing can change after the deadline; and every bid, losers included, becomes public at opening. The award, the contract and every change contract are appended to the same record, and treasury payments cite it. Rigging is detected by off-chain analysis of this complete public dataset.

## Scope

**In scope:** sealed bidding and opening; ceiling-price commitment; awards; contracts and change contracts; negotiated contracts.

**Out of scope:**
- Bidder qualification: off-chain; bidders are already identified by certification ([ADR 0020](../../decisions/0020-certified-address-stablecoin.md)).
- Judging whether a negotiated contract or comprehensive-evaluation score was justified: off-chain.
- Detecting rigging: off-chain analysis of public data.
- Re-delegation after award: already traceable through the treasury ([ADR 0019](../../decisions/0019-treasury-model.md)).

## On-chain / Online / Offline breakdown

(See [`docs/operations/README.md`](../../operations/README.md) for the convention.)

**On-chain:**
- `TenderFactory` (one per procuring body) and one `Tender` per procurement: tender-document hash, ceiling-price commitment, deadlines, deposits, bid commitments and reveals, award, contract hash, change contracts.

**Online:**
- The body publishes its factory address under its `.go.jp`/`.lg.jp` domain, and the tender documents whose hash is on-chain.

**Offline:**
- Setting the ceiling price, and keeping it secret until opening (a leak before the deadline is a crime handled off-chain).
- Comprehensive-evaluation judging; the reasons for negotiated contracts and their review.
- Analysis applications: winner rotation, winning rates near the ceiling, links between bidders, donations ([ADR 0015](../../decisions/0015-political-donations-model.md)) and officers, contracted versus paid amounts.

## Architecture

### `TenderFactory` (one per procuring body)

- `createTender(...)`: callable by the body's multisig only.
- An approved registrar under ADR 0020, so that each `Tender` (which holds deposits) is a certified address.

### `Tender` (one per procurement)

**Fixed at creation:** `method` (`LowestPrice` / `Comprehensive` / `Negotiated`), `specHash` (the tender documents), `ceilingCommit` (hash of the ceiling price and a salt), `criteriaHash` (comprehensive evaluation only), `bidDeadline`, `revealDeadline`, `deposit`, and `treasury` (the body's `PublicTreasury`).

**Competitive flow:**
1. `submitBid(commitHash)`: before `bidDeadline`, from a certified corporation or `ResidentLink` holder (Round 2 adjustment). One bid per bidder; the deposit is paid in.
2. `revealBid(amount, salt)`: between `bidDeadline` and `revealDeadline`. The deposit is returned. Each revealed bid and its bidder are public (Issue 6).
3. `revealCeiling(amount, salt)`: by the body, at opening; it must match `ceilingCommit` (Issue 3).
4. After `revealDeadline`, a non-revealed bid's deposit is forfeited to `treasury`, and the non-reveal is recorded.
5. `award(winner, contractHash)`: by the body.
   - `LowestPrice`: accepted **only** if `winner` holds the lowest revealed bid at or below the revealed ceiling (Round 2 adjustment).
   - `Comprehensive`: the body also publishes `scoreSheetHash`; the judgement is reviewed off-chain.
   - If no valid bid exists, `markFailed()` records the failed tender (不調).

**Negotiated contracts:** `method = Negotiated`; no bidding. `award(contractor, contractHash, reasonHash)` directly (Round 2 adjustment).

**After award (all methods):** `appendChange(changeHash, newAmount)` by the body. Append-only, so every increase after award is visible (Issue 5).

### Linking to payments

Treasury payments for a contract cite the `Tender` address in their budget code ([ADR 0019](../../decisions/0019-treasury-model.md)). Comparing contracted and paid amounts is off-chain analysis.

### Dates on-chain

`bidDeadline` and `revealDeadline` are actively enforced, the same kind of justified exception as the petition collection period.

## Known limits

- A ceiling-price leak before the deadline is not prevented, only made pointless to cover up afterwards.
- Collusion among bidders happens off-chain; the design provides the complete data to detect it, not prevention.
- A bidder who declines to reveal loses only the deposit; repeated non-reveals are a signal for off-chain analysis.

---

# 公共調達・入札(日本語)

**ステータス: 🟢 設計確定。** オンチェーン価値テストで選別し、ユーザーとの議論で解決した。理由は[`discussion-log.md`](discussion-log.md)、正式な決定は[ADR 0022](../../decisions/0022-procurement-model.md)を参照。コントラクトコードはまだない。

## 概要

競争入札か随意契約かを問わず、すべての調達は、調達する機関が作成する`Tender`コントラクトになる。競争入札では、入札者は締切前に入札額のハッシュをコミットし、締切後に中身を明かす。機関も同じ方法で予定価格のハッシュをコミットする。機関を含め誰も開札前に入札を見られず、締切後には何も変えられず、落札しなかった者も含めすべての入札が開札時に公開される。落札、契約、すべての変更契約は同じ記録に追記され、国庫の支払いはそれを参照する。談合は、この完全な公開データをオフチェーンで分析して検出する。

## スコープ

**対象:** 封印入札と開札、予定価格のコミット、落札、契約と変更契約、随意契約。

**対象外:**
- 入札参加資格: オフチェーン。入札者は認定([ADR 0020](../../decisions/0020-certified-address-stablecoin.md))によってすでに特定できる。
- 随意契約や総合評価の点数が妥当だったかの判断: オフチェーン。
- 談合の検出: 公開データのオフチェーンの分析。
- 落札後の再委託: 国庫([ADR 0019](../../decisions/0019-treasury-model.md))ですでに追跡できる。

## オンチェーン/オンライン/オフラインの内訳

(区分の考え方は[`docs/operations/README.md`](../../operations/README.md)を参照。)

**オンチェーン:**
- `TenderFactory`(調達する機関ごとに1つ)と、調達ごとに1つの`Tender`: 入札書類のハッシュ、予定価格のコミット、締切、保証金、入札のコミットとリビール、落札、契約のハッシュ、変更契約。

**オンライン:**
- 機関は、ファクトリのアドレスを`.go.jp`/`.lg.jp`ドメインで公表し、ハッシュがオンチェーンにある入札書類を公表する。

**オフライン:**
- 予定価格の設定と、開札までの秘匿(締切前の漏洩はオフチェーンで扱う犯罪)。
- 総合評価の審査、随意契約の理由とその検証。
- 分析アプリケーション: 落札者の持ち回り、予定価格に近い落札率、入札者・献金([ADR 0015](../../decisions/0015-political-donations-model.md))・役員の結びつき、契約額と支払額の比較。

## アーキテクチャ

### `TenderFactory`(調達する機関ごとに1つ)

- `createTender(...)`: 機関のマルチシグだけが呼び出せる。
- ADR 0020の承認された登録者であり、各`Tender`(保証金を持つ)は認定アドレスになる。

### `Tender`(調達ごとに1つ)

**作成時に固定:** `method`(`LowestPrice` / `Comprehensive` / `Negotiated`)、`specHash`(入札書類)、`ceilingCommit`(予定価格とソルトのハッシュ)、`criteriaHash`(総合評価のみ)、`bidDeadline`、`revealDeadline`、`deposit`、`treasury`(機関の`PublicTreasury`)。

**競争入札の流れ:**
1. `submitBid(commitHash)`: `bidDeadline`の前に、認定済みの法人または`ResidentLink`の保有者から(Round 2の調整)。入札者1者につき1件。保証金を払い込む。
2. `revealBid(amount, salt)`: `bidDeadline`から`revealDeadline`までの間。保証金は返還される。明かされた各入札とその入札者は公開される(論点6)。
3. `revealCeiling(amount, salt)`: 機関が開札時に行う。`ceilingCommit`と一致しなければならない(論点3)。
4. `revealDeadline`の後、明かされなかった入札の保証金は`treasury`に没収され、明かさなかったことが記録される。
5. `award(winner, contractHash)`: 機関が行う。
   - `LowestPrice`: `winner`が、明かされた予定価格以下で最も低い、明かされた入札を持つ場合に**限り**受け付ける(Round 2の調整)。
   - `Comprehensive`: 機関は`scoreSheetHash`も公開する。判断はオフチェーンで検証する。
   - 有効な入札がなければ、`markFailed()`で不調を記録する。

**随意契約:** `method = Negotiated`。入札はない。`award(contractor, contractHash, reasonHash)`で直接行う(Round 2の調整)。

**落札後(すべての方式):** 機関が`appendChange(changeHash, newAmount)`を行う。追記専用なので、落札後のすべての増額が見える(論点5)。

### 支払いとの結びつき

契約に対する国庫の支払いは、予算コードで`Tender`のアドレスを参照する([ADR 0019](../../decisions/0019-treasury-model.md))。契約額と支払額の比較は、オフチェーンの分析で行う。

### オンチェーンの日付

`bidDeadline`と`revealDeadline`はコントラクトが能動的に強制する。署名の収集期間と同じ種類の、正当化された例外である。

## 既知の限界

- 締切前の予定価格の漏洩は防げない。後から隠しても意味がなくなるだけである。
- 入札者どうしの共謀はオフチェーンで起こる。この設計が提供するのは、それを検出するための完全なデータであり、防止ではない。
- 明かすのをやめた入札者が失うのは保証金だけである。繰り返し明かさないことは、オフチェーンの分析にとってのシグナルになる。

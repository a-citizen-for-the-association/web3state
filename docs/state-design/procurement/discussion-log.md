# Discussion Log: Public procurement / bidding (公共調達・入札)

Records the back-and-forth on this feature's design, in order. See [`docs/state-design/citizenship/discussion-log.md`](../citizenship/discussion-log.md) for the format this follows.

---

## Round 1 — 2026-10-24 (Claude)

### Background: the current system

Public bodies buy works, goods and services mainly by competitive bidding. Open competitive bidding is the default; designated-bidder tenders and negotiated (single-source) contracts are exceptions. The body sets a confidential ceiling price (予定価格). Bids are opened, and the lowest valid bid at or below the ceiling wins, or the best combined price-and-quality score under comprehensive evaluation. Many bodies run electronic bidding systems and publish the results.

Known problems:
- **Bid rigging (談合)** among bidders, e.g. the 2023 indictments over the Tokyo Olympic test-event tenders.
- **Official-involved rigging (官製談合)** and **leaks of the ceiling price** to a favoured bidder, a recurring cause of arrests of local officials. A dedicated law against official-involved rigging has existed since 2003.
- **Single-bidder tenders and negotiated contracts** used where competition was possible.
- **Price increases after award** through change contracts.

### On-chain value test ([ADR 0014](../../decisions/0014-legislative-process-scope.md)), sub-part by sub-part

| Sub-part | Q1 problem | Q2 keeper | Q3 technical | Q4 no record | Q5 combination | Result |
|---|---|---|---|---|---|---|
| **Sealed bids and opening** | **Yes**: peeking at bids, accepting late or altered bids, adjusting the ceiling price after seeing bids | **Yes**: the procuring body runs the system | **Yes** for the process's integrity (timing, immutability); a leak by a person is not technical | Partial: e-bidding exists, run by the same body | **Strong**: bidders are certified corporations ([ADR 0020](../../decisions/0020-certified-address-stablecoin.md)) | **Candidate (core)** |
| **All bid amounts, over time** | **Yes**: rigging leaves patterns (rotation of winners, winning rates near the ceiling) | Yes | No for the collusion itself; **yes** for complete, unalterable data | Partial: results are published per tender, not as one complete dataset | **Strong**: with political donations, corporate officers, treasury payments | **Candidate**: publish all bids; detection by off-chain analysis |
| **Contract and change contracts** | **Yes**: increases after award | Yes | Yes | Partial | **Strong**: treasury payments can cite the contract | **Candidate** (light) |
| Negotiated contracts and single bids | Yes | Yes | **No**: justification is a judgement | Partial | Moderate | Record reasons with the contract; judgement off-chain |
| Bidder qualification (入札参加資格) | Weak | — | — | Partial | — | Off-chain; corporate registration already identifies bidders |
| Re-delegation after award | — | — | — | — | — | Already traceable through the treasury ([ADR 0019](../../decisions/0019-treasury-model.md)) |

### Issues raised

1. **Screening result.** Core: sealed bidding and opening; plus publishing all bids and anchoring contracts and change contracts. Detection of rigging is off-chain analysis.
2. **Sealed-bid mechanism** (the one place where a chain does real work here):
   - (a) **Commit–reveal:** bidders submit a hash of their bid before the deadline, then reveal it. The body cannot see any bid until opening, and no bid can change after the deadline. A bidder could refuse to reveal after seeing others; this is countered by a deposit forfeited on non-reveal, and the non-reveal is recorded publicly.
   - (b) **Threshold encryption**, reusing voting's trustee machinery ([ADR 0013](../../decisions/0013-voting-model.md)): all bids are decrypted together after the deadline, so there is no reveal step to game. Stronger, but heavier.
   - (c) **Off-chain e-bidding plus hash anchoring:** lightest, but the body still holds the bids before opening, so peeking is not prevented.
3. **Ceiling price.** Commit its hash before the bid deadline, and reveal it at opening, so it cannot be adjusted after bids are seen. A leak *before* the deadline is still possible, which is a crime handled off-chain. Alternatively, publish the ceiling price in advance (some local governments already do), which removes the leak incentive but tends to push winning bids towards the ceiling.
4. **Who may bid.** Only certified corporations (and sole proprietors via `ResidentLink`?). Every bidder is then identified, and off-chain analysis can join bids with donations and officers.
5. **Contract record.** The award, the contract hash and each change contract are appended to the tender. Treasury payments cite the contract identifier in their budget code, so anyone can compare the contracted amount with the amount paid. Negotiated contracts record their stated reason.
6. **Publishing all bids.** Every bid amount and bidder, losers included, becomes public at opening. This is the data rigging detection needs.

### Status

Awaiting the user's response.

---

## Round 2 — 2026-10-24 (user + Claude)

### User's decisions

Issues 1–6 **as proposed**; Issue 2: **(a) commit–reveal**. Issue 3: the ceiling price is committed as a hash before the deadline and revealed at opening (not published in advance).

### Adjustments made while writing the spec (flagged for review)

- **Sole proprietors may bid** from their `ResidentLink` address (Issue 4 left this as a question). Both kinds are certified under [ADR 0020](../../decisions/0020-certified-address-stablecoin.md), and individuals can bid today.
- **The lowest-price award is checked on-chain.** Under the lowest-price method, `award()` accepts only the lowest revealed bid at or below the revealed ceiling. This is a real enforcement need: it stops the body from awarding to someone else. It is cheap, so it is an exception to "off-chain if it can be". Under comprehensive evaluation the award is a judgement: the scoring criteria are committed at creation, the score sheet is published at award, and judging stays off-chain.
- **Deposits.** Tender contracts hold bid deposits in the JPY stablecoin, so `TenderFactory` is an approved registrar under ADR 0020. A forfeited deposit goes to the procuring body's `PublicTreasury`.
- **Negotiated contracts use the same factory** (type `Negotiated`: no bidding, award directly with the stated reason). Then every contract of a body, competitive or not, appears in one place.

### Status

All issues resolved. Spec written ([`README.md`](README.md)); ADR: [0022](../../decisions/0022-procurement-model.md).

---

## Round 3 — 2026-10-24 (user)

The user **confirmed all four Round 2 adjustments**. No open points remain.

---

# 議論ログ: 公共調達・入札(日本語)

この機能の設計に関するやり取りを順に記録する。形式は[`docs/state-design/citizenship/discussion-log.md`](../citizenship/discussion-log.md)に従う。

---

## Round 1 — 2026-10-24(Claude)

### 前提: 現行制度

公的機関は、工事・物品・役務を主に競争入札で調達する。一般競争入札が原則で、指名競争入札と随意契約は例外である。機関は非公開の予定価格を定める。入札を開札し、予定価格以下の最低価格の有効な入札が落札する。総合評価方式では、価格と品質を合わせた評価が最も高い者が落札する。多くの機関が電子入札システムを運用し、結果を公表している。

知られている問題:
- 入札者どうしの**談合**。たとえば2023年の東京五輪テスト大会の入札をめぐる起訴。
- **官製談合**と、特定の業者への**予定価格の漏洩**。地方の職員が逮捕される典型的な原因である。官製談合防止法は2003年から施行されている。
- 競争が可能だったのに使われる**一者応札や随意契約**。
- 変更契約による**落札後の増額**。

### オンチェーン価値テスト([ADR 0014](../../decisions/0014-legislative-process-scope.md))の部分ごとの適用

| 部分 | 問1 問題 | 問2 管理者 | 問3 技術 | 問4 記録なし | 問5 組み合わせ | 結果 |
|---|---|---|---|---|---|---|
| **封印入札と開札** | **はい**: 入札の盗み見、遅れた・書き換えた入札の受理、入札を見た後の予定価格の調整 | **はい**: 調達する機関がシステムを運用する | 手続きの完全性(時刻、改ざん不可)は**はい**。人による漏洩は技術の問題ではない | 一部: 電子入札はあるが、同じ機関が運用する | **強い**: 入札者は認定済みの法人([ADR 0020](../../decisions/0020-certified-address-stablecoin.md)) | **候補(中核)** |
| **すべての入札額の蓄積** | **はい**: 談合はパターンを残す(落札者の持ち回り、予定価格に近い落札率) | はい | 談合そのものはいいえ。完全で改ざんできないデータは**はい** | 一部: 結果は案件ごとに公表されるが、1つの完全なデータとしてはない | **強い**: 政治献金、法人の役員、国庫の支払いと結びつく | **候補**: すべての入札を公開し、検出はオフチェーンの分析で行う |
| **契約と変更契約** | **はい**: 落札後の増額 | はい | はい | 一部 | **強い**: 国庫の支払いが契約を参照できる | **候補**(軽い) |
| 随意契約と一者応札 | はい | はい | **いいえ**: 理由の妥当性は判断の問題 | 一部 | 中程度 | 理由を契約とともに記録し、判断はオフチェーン |
| 入札参加資格 | 弱い | — | — | 一部 | — | オフチェーン。入札者は法人登記ですでに特定できる |
| 落札後の再委託 | — | — | — | — | — | 国庫([ADR 0019](../../decisions/0019-treasury-model.md))ですでに追跡できる |

### 提起した論点

1. **選別の結果。** 中核は封印入札と開札。加えて、すべての入札の公開と、契約・変更契約のアンカリング。談合の検出はオフチェーンの分析で行う。
2. **封印入札の仕組み**(ここでチェーンが本当に働く唯一の場所):
   - (a) **コミット・リビール:** 入札者は締切前に入札額のハッシュを提出し、その後に中身を明かす。機関は開札まで入札を見られず、締切後に入札は変えられない。入札者が他者の入札を見てから明かすのをやめることはできるが、明かさなければ没収される保証金で抑止し、明かさなかったことも公開で記録する。
   - (b) **閾値暗号**。投票の信頼主体の仕組み([ADR 0013](../../decisions/0013-voting-model.md))を再利用し、締切後にすべての入札を一斉に復号する。明かす段階がないので駆け引きの余地がない。より強いが、より重い。
   - (c) **オフチェーンの電子入札とハッシュのアンカリング:** 最も軽いが、開札前に機関が入札を持っているので、盗み見は防げない。
3. **予定価格。** 入札締切前にハッシュをコミットし、開札時に明かす。入札を見た後で調整できなくなる。締切*前*の漏洩は依然として可能で、オフチェーンで扱う犯罪である。別案として、予定価格を事前に公表する(すでに行っている自治体もある)。漏洩の動機はなくなるが、落札額が予定価格に張りつきやすくなる。
4. **誰が入札できるか。** 認定済みの法人だけ(個人事業主は`ResidentLink`で?)。すべての入札者が特定され、オフチェーンの分析で入札を献金や役員と結びつけられる。
5. **契約の記録。** 落札、契約のハッシュ、各変更契約を、その入札案件に追記する。国庫の支払いは予算コードで契約の識別子を参照するので、誰でも契約額と支払額を比べられる。随意契約は、示された理由を記録する。
6. **すべての入札の公開。** 落札しなかった者も含め、すべての入札額と入札者を開札時に公開する。談合の検出に必要なデータである。

### ステータス

ユーザーの回答待ち。

---

## Round 2 — 2026-10-24(ユーザー + Claude)

### ユーザーの決定

論点1〜6は**提案どおり**。論点2は**(a) コミット・リビール**。論点3: 予定価格は締切前にハッシュをコミットし、開札時に明かす(事前公表はしない)。

### 仕様作成時に加えた調整(レビュー対象)

- **個人事業主も`ResidentLink`アドレスから入札できる**(論点4では問いとして残していた)。どちらも[ADR 0020](../../decisions/0020-certified-address-stablecoin.md)で認定されており、現在も個人は入札できる。
- **最低価格による落札はオンチェーンで確認する。** 最低価格方式では、`award()`は、明かされた予定価格以下で最も低い、明かされた入札だけを受け付ける。機関が別の者に落札させることを防ぐ、実際の強制の必要があり、コストも小さいので、「オフチェーンでできることはオフチェーンで」の例外とする。総合評価方式では落札は判断の問題である。評価基準は作成時にコミットし、評価表は落札時に公開し、判断はオフチェーンに残す。
- **保証金。** 入札コントラクトは入札の保証金を円建てステーブルコインで持つので、`TenderFactory`はADR 0020の承認された登録者とする。没収された保証金は、調達する機関の`PublicTreasury`に入る。
- **随意契約も同じファクトリを使う**(種類`Negotiated`: 入札なしで、示された理由とともに直接落札させる)。これで、競争の有無にかかわらず、機関のすべての契約が1か所に現れる。

### ステータス

すべての論点が解決。仕様を作成([`README.md`](README.md))。ADR: [0022](../../decisions/0022-procurement-model.md)。

---

## Round 3 — 2026-10-24(ユーザー)

ユーザーは**Round 2の4つの調整をすべて了承した**。未決の点は残っていない。

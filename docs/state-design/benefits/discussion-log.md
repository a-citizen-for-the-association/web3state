# Discussion Log: Benefits (児童手当・生活保護等)

Records the back-and-forth on this feature's design, in order. See [`docs/state-design/citizenship/discussion-log.md`](../citizenship/discussion-log.md) for the format this follows.

---

## Round 1 — 2026-11-07 (Claude)

### Background: the current system

- **Cash benefits to individuals** are paid mostly by municipalities: child allowance (児童手当), child-rearing allowance for single parents (児童扶養手当), disability allowances, public assistance (生活保護), and one-off payments such as the 2020 special fixed-sum payment (特別定額給付金, ¥100,000 per person).
- **Eligibility** is decided on application (申請主義). Public assistance requires a means test, and recipients must report income every month; the welfare office (福祉事務所) checks it.
- **Medical and long-term-care assistance** within public assistance is paid directly to providers through the medical-claims system, not to the recipient.

Known problems:
- **Unreported income in public assistance:** tens of thousands of fraud cases a year, the largest share being undeclared earnings. The office cannot see a recipient's income directly.
- **Poverty businesses (貧困ビジネス):** operators house recipients and take most of their assistance as rent and fees.
- **Wrong destination accounts:** in 2023, many "public-money receiving accounts" (公金受取口座) linked to My Number turned out to be registered in someone else's name, often a family member's.
- **Slow universal payments:** the 2020 ¥100,000 payment took months in many municipalities, mostly because of application processing and bank-account checks.
- **Stigma and under-take-up:** only a minority of eligible households are thought to receive public assistance; fear of being known as a recipient is one reason.
- **Mistreatment by the payer:** in 2023 a city was found to have paid some recipients their assistance in small daily instalments, withholding the rest.

### What already exists in this project

- Payments leave a `PublicTreasury` only to a genuine `ResidentLink` holder ([ADR 0019](../../decisions/0019-treasury-model.md)). **The payee is the person's own address,** so a "wrong account" cannot happen.
- A registered death burns the `ResidentLink`, and later payments revert; a move keeps the same address ([ADR 0020](../../decisions/0020-certified-address-stablecoin.md)).
- Under the certified-address rule, **every JPY payment into a recipient's address is on-chain**, including earnings. Cash still exists through certified exchange operators.
- Pension ([ADR 0024](../../decisions/0024-pension-model.md)) set the pattern: private decisions anchored by hash only, and **one generic budget code** so that a payment does not reveal a sensitive status.
- The municipality minted each resident's `ResidentLink`, so it already knows which address belongs to which resident. Nobody else does.

### On-chain value test ([ADR 0014](../../decisions/0014-legislative-process-scope.md)), sub-part by sub-part

| Sub-part | Q1 problem | Q2 keeper | Q3 technical | Q4 no record | Q5 combination | Result |
|---|---|---|---|---|---|---|
| **Payment destination and timing** | **Yes**: wrong accounts, slow payments, withheld instalments | Partial | **Yes**: identity linkage | Partial | **Strong**: `ResidentLink` as payee | Covered by the treasury; payments become verifiable by the recipient |
| **Income check for public assistance** | **Yes**: undeclared earnings | **Yes**: self-reported | **Yes**: income visibility | **Yes** | **Strong**: certified-address earnings | **Candidate**: off-chain analysis by the welfare office |
| **Poverty businesses** | **Yes** | Yes | **Partly**: the money flow is technical; the exploitation is a judgement | Yes | **Strong**: recipient outflows | **Candidate**: off-chain detection |
| Duplicate receipt across municipalities | Yes | Partial | **Yes** | Partial | Moderate | Off-chain cross-check by municipalities |
| Eligibility decisions | Partial | — | **Mostly no**: judgement and family facts | — | Moderate | Off-chain; decisions anchored by hash |
| Medical and care assistance | Yes: over-billing by providers | — | Partly | — | — | **Out of scope**: part of the medical-claims system (new backlog item) |
| Under-take-up and stigma | **Yes** | — | **Mostly no**: social | — | — | Not solvable by recording; see Issues 3 and 4 so the design does not make it worse |

### Proposal in line with "off-chain if it can be" ([ADR 0019](../../decisions/0019-treasury-model.md))

**No new contract,** as for pension. Benefits are `pay()` from the paying body's `PublicTreasury` to the recipient's `ResidentLink` address; decisions are anchored by hash; income checks, poverty-business detection and duplicate checks are off-chain analysis of public data. A universal payment (like the 2020 ¥100,000) is just a batch of `pay()` calls by each municipality to its own residents. A pull-style "claim" contract was considered and is not needed.

### Issues raised

1. **Screening result.** Scope: cash benefits paid to individuals by public bodies (child allowance, child-rearing allowance, disability allowances, the cash parts of public assistance, one-off universal payments). Out of scope: medical and care assistance (medical-claims system; new backlog item), unemployment insurance (separate item), in-kind services.
2. **New contract or not.** (A) No new contract, as above. (B) A `BenefitProgram` contract per programme with an on-chain recipient list. Proposal: **(A)**.
3. **Publication and the budget code: the central privacy issue.** Benefit payments are public per address, like every payment to an individual. The question is whether a payment reveals *which* benefit:
   - (a) A separate budget code per benefit. Audit is easiest, but an address receiving public assistance is visibly marked as such.
   - (b) **One generic code for all social-security payments to individuals,** shared by pension, every benefit and, later, unemployment insurance. A payment shows only "social security from body X". Per-kind totals are published off-chain for audit. This extends ADR 0024's single pension code to a single code across the whole category.
   - (c) Hide the payments (shielded transfers). Rejected: it breaks the certified-address and treasury designs and needs new cryptography.

   Proposal: **(b)**. Amounts and timing can still hint at the kind; that residual risk is accepted, with the address itself pseudonymous.
4. **Income checks for public assistance.** The welfare office knows the recipient's address and can read its inflows, replacing much of the monthly self-report. Should the state also analyse *non-recipients'* finances to find people who may be eligible (push-type notification)?
   - (a) **Only for applicants and recipients, with consent given in the application.** The state does not routinely profile residents' finances.
   - (b) Proactively for all residents, to reduce under-take-up.

   Proposal: **(a)**, following the principle that individuals get stronger privacy ([ADR 0012](../../decisions/0012-onchain-scope-philosophy.md)). Cash earnings remain a limit, as today.
5. **Poverty businesses.** Housing assistance can be paid directly to the landlord corporation as an ordinary `pay()`, which is then public. Operators whose income consists mostly of many recipients' assistance can be flagged by off-chain analysis of recipients' outflows. No on-chain mechanism.
6. **Child-related eligibility.** Whether a child exists, lives with the claimant and is resident is decided off-chain from the resident register; children are not required to hold a `ResidentLink` (that belongs to the vital-records item). The decision is anchored by hash; payment goes to the claimant's address.
7. **Duplicates, moves and death.** On a move the address stays the same, so the old and new municipalities can see whether both are paying it. With code (b), this check is done by the municipalities using their own private records, not by the public. A registered death stops payments automatically.

### Status

Awaiting the user's response.

---

## Round 2 — 2026-11-07 (user + Claude)

### User's decisions

Issues 1–7 **as proposed**: Issue 2 **(A)**, no new contract; Issue 3 **(b)**, one generic code for all social-security payments to individuals; Issue 4 **(a)**, income analysis only for applicants and recipients, with consent.

### Adjustments made while writing the spec (flagged for review)

- **Universal payments keep their own budget code.** A payment made to every resident (like the 2020 ¥100,000) reveals nothing about the recipient, so it does not need the shared code, and its own code makes it easy to audit that everyone was paid.
- **The consented income analysis is limited to the application and receipt period.** It covers the address's flows from the application until the benefit ends (plus the period the law already allows for investigating overpayments), and the consent lapses after that.
- **Per-kind totals are published monthly per paying body,** so the shared code does not weaken audit of each programme's spending.

### Status

All issues resolved. Spec written ([`README.md`](README.md)); ADR: [0025](../../decisions/0025-benefits-model.md). The shared code widens ADR 0024's single pension code. The three adjustments were confirmed in Round 3.

---

## Round 3 — 2026-11-07 (user)

The user **confirmed all three Round 2 adjustments**. No open points remain.

---

# 議論ログ: 各種手当(児童手当・生活保護等)(日本語)

この機能の設計に関するやり取りを順に記録する。形式は[`docs/state-design/citizenship/discussion-log.md`](../citizenship/discussion-log.md)に従う。

---

## Round 1 — 2026-11-07(Claude)

### 背景: 現在の制度

- **個人への現金給付**は主に市区町村が支払う。児童手当、ひとり親向けの児童扶養手当、障害者向けの手当、生活保護、そして2020年の特別定額給付金(1人10万円)のような一時的な給付がある。
- **受給資格**は申請に基づいて決まる(申請主義)。生活保護には資力調査があり、受給者は毎月収入を申告し、福祉事務所が確認する。
- 生活保護のうち**医療扶助と介護扶助**は、受給者ではなく、診療報酬の仕組みを通じて提供者に直接支払われる。

知られている問題:
- **生活保護での収入の未申告:** 毎年数万件の不正受給があり、最も多いのは稼働収入の無申告である。福祉事務所は受給者の収入を直接見ることができない。
- **貧困ビジネス:** 事業者が受給者を住まわせ、保護費の大半を家賃や手数料として取る。
- **誤った振込先口座:** 2023年、マイナンバーに紐づけた「公金受取口座」の多くが、本人以外(多くは家族)の名義で登録されていたことがわかった。
- **一律給付の遅さ:** 2020年の10万円給付は多くの市区町村で数か月かかった。主な原因は申請の処理と口座の確認だった。
- **スティグマと捕捉率の低さ:** 受給資格のある世帯のうち、生活保護を受けているのは少数と考えられている。受給者だと知られることへの恐れが理由の一つである。
- **支払う側による不当な扱い:** 2023年、ある市が一部の受給者に保護費を毎日少額ずつ渡し、残りを渡していなかったことがわかった。

### このプロジェクトに既にあるもの

- 支払いは`PublicTreasury`から本物の`ResidentLink`保有者にだけ出る([ADR 0019](../../decisions/0019-treasury-model.md))。**支払先は本人のアドレス**なので、「誤った口座」は起こりえない。
- 届出済みの死亡で`ResidentLink`がburnされ、その後の支払いはrevertする。転居ではアドレスは変わらない([ADR 0020](../../decisions/0020-certified-address-stablecoin.md))。
- 認定アドレス制により、**受給者のアドレスへの円の支払いはすべてオンチェーン**にあり、稼働収入も含まれる。現金は認定された交換事業者を通じて引き続き存在する。
- 年金([ADR 0024](../../decisions/0024-pension-model.md))で型ができた: 非公開の決定はハッシュだけをアンカリングし、**予算コードは共通の1つ**にして、支払いから慎重を要する状態がわからないようにする。
- 各住民の`ResidentLink`を発行したのは市区町村なので、どのアドレスがどの住民のものかを市区町村はすでに知っている。それ以外は誰も知らない。

### オンチェーン価値テスト([ADR 0014](../../decisions/0014-legislative-process-scope.md))、部分ごと

| 部分 | Q1 問題 | Q2 管理者 | Q3 技術的 | Q4 記録なし | Q5 組み合わせ | 結果 |
|---|---|---|---|---|---|---|
| **支払先と支払時期** | **あり**: 誤った口座、遅い支払い、分割での留保 | 一部 | **あり**: 本人との紐づけ | 一部 | **強い**: `ResidentLink`が支払先 | 歳出・予算で対応済み。受給者が支払いを確認できるようになる |
| **生活保護の収入確認** | **あり**: 稼働収入の無申告 | **あり**: 自己申告 | **あり**: 収入の可視性 | **あり** | **強い**: 認定アドレスでの収入 | **候補**: 福祉事務所によるオフチェーン分析 |
| **貧困ビジネス** | **あり** | あり | **一部**: お金の流れは技術の問題、搾取かどうかは判断 | あり | **強い**: 受給者からの支出 | **候補**: オフチェーンで検出 |
| 市区町村をまたぐ重複受給 | あり | 一部 | **あり** | 一部 | 中程度 | 市区町村によるオフチェーンの照合 |
| 受給資格の決定 | 一部 | — | **ほぼなし**: 判断と家族の事実 | — | 中程度 | オフチェーン。決定はハッシュでアンカリング |
| 医療扶助・介護扶助 | あり: 提供者の過剰請求 | — | 一部 | — | — | **スコープ外**: 診療報酬の仕組みの一部(新しいバックログ項目) |
| 捕捉率とスティグマ | **あり** | — | **ほぼなし**: 社会の問題 | — | — | 記録では解決できない。設計で悪化させないよう論点3・4を参照 |

### 「オフチェーンでできることはオフチェーンで」([ADR 0019](../../decisions/0019-treasury-model.md))に沿った提案

年金と同じく**新しいコントラクトは作らない。** 給付は支払う機関の`PublicTreasury`から受給者の`ResidentLink`アドレスへの`pay()`で、決定はハッシュでアンカリングする。収入確認、貧困ビジネスの検出、重複の確認は、公開データのオフチェーン分析で行う。一律給付(2020年の10万円のようなもの)は、各市区町村が自らの住民へ`pay()`をまとめて実行するだけである。受給者が自分で受け取りにいく「請求型」のコントラクトも検討したが、必要ない。

### 提起した論点

1. **ふるい分けの結果。** スコープ: 公的機関が個人に支払う現金給付(児童手当、児童扶養手当、障害者向けの手当、生活保護の現金部分、一時的な一律給付)。スコープ外: 医療扶助・介護扶助(診療報酬の仕組み。新しいバックログ項目)、雇用保険(別項目)、現物のサービス。
2. **新しいコントラクトを作るか。** (A) 上記のとおり作らない。(B) 制度ごとに、受給者の一覧をオンチェーンで持つ`BenefitProgram`コントラクトを作る。提案: **(A)**。
3. **公開範囲と予算コード: プライバシーの中心の論点。** 給付の支払いは、個人へのほかの支払いと同じくアドレスごとに公開される。問題は、支払いから*どの*給付かがわかるかどうかである:
   - (a) 給付ごとに別の予算コードを使う。監査は最も容易だが、生活保護を受けているアドレスがそれとわかってしまう。
   - (b) **個人への社会保障の支払いすべてに共通のコードを1つ使う。** 年金、すべての給付、そして後の雇用保険で共有する。支払いからわかるのは「機関Xからの社会保障」だけになる。監査のため種類ごとの合計をオフチェーンで公表する。ADR 0024の年金共通コードを、カテゴリ全体の共通コードに広げることになる。
   - (c) 支払いを隠す(シールドされた送金)。不採用: 認定アドレス制と歳出・予算の設計を壊し、新しい暗号技術が必要になる。

   提案: **(b)**。金額や時期から種類が推測できる余地は残るが、アドレス自体が仮名であることを前提に、その残るリスクは受け入れる。
4. **生活保護の収入確認。** 福祉事務所は受給者のアドレスを知っており、その入金を読めるので、毎月の自己申告の多くを置き換えられる。では、受給資格がありそうな人を見つけるために、国が*受給者以外*の財務も分析すべきか(プッシュ型の通知)?
   - (a) **申請者と受給者に限り、申請時の同意に基づいて行う。** 国は住民の財務を日常的にプロファイリングしない。
   - (b) 捕捉率を上げるため、すべての住民について積極的に行う。

   提案: **(a)**。個人にはより強いプライバシーを与えるという原則([ADR 0012](../../decisions/0012-onchain-scope-philosophy.md))に従う。現金での稼働収入は、今と同じく限界として残る。
5. **貧困ビジネス。** 住宅扶助は、家主の法人へ通常の`pay()`で直接支払える(代理納付)。その支払いは公開される。多数の受給者の保護費が収入の大半を占める事業者は、受給者からの支出のオフチェーン分析で検知できる。オンチェーンの仕組みは作らない。
6. **子どもに関する受給資格。** 子どもが存在するか、申請者と同居しているか、住民かは、住民基本台帳からオフチェーンで判断する。子どもに`ResidentLink`の保有は求めない(それは戸籍・出生等の項目の問題)。決定はハッシュでアンカリングし、支払いは申請者のアドレスへ行う。
7. **重複、転居、死亡。** 転居してもアドレスは変わらないので、転出元と転入先の市区町村は、両方がそのアドレスに支払っていないかを確認できる。コード(b)の場合、この確認は一般の人ではなく、市区町村が自らの非公開の記録を使って行う。届出済みの死亡では支払いが自動的に止まる。

### ステータス

ユーザーの回答待ち。

---

## Round 2 — 2026-11-07(ユーザー＋Claude)

### ユーザーの決定

論点1〜7は**提案どおり**。論点2は**(A)**で新しいコントラクトは作らない。論点3は**(b)**で、個人への社会保障の支払いすべてに共通のコードを1つ使う。論点4は**(a)**で、収入の分析は申請者と受給者に限り、同意に基づいて行う。

### 仕様を書く際に加えた調整(確認待ち)

- **一律給付は独自の予算コードを使う。** すべての住民に支払う給付(2020年の10万円のようなもの)は受給者について何も明かさないので、共通コードは要らない。独自のコードがあれば、全員に支払われたかを監査しやすい。
- **同意に基づく収入の分析は、申請から受給の期間に限る。** 申請から給付の終了まで(と、過払いの調査のため法律がすでに認めている期間)のアドレスの流れを対象とし、その後は同意が失効する。
- **種類ごとの合計を、支払う機関ごとに毎月公表する。** 共通コードにしても、各制度の支出の監査が弱まらないようにする。

### ステータス

すべての論点が解決。仕様を作成([`README.md`](README.md))。ADR: [0025](../../decisions/0025-benefits-model.md)。共通コードはADR 0024の年金共通コードを広げるものである。3つの調整はRound 3で了承された。

---

## Round 3 — 2026-11-07(ユーザー)

ユーザーは**Round 2の3つの調整をすべて了承した**。未決の点は残っていない。

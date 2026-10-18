# Discussion Log: Treasury / public finance (歳出・予算)

Records the back-and-forth on this feature's design, in order. See [`docs/state-design/citizenship/discussion-log.md`](../citizenship/discussion-log.md) for the format this follows.

---

## Round 1 — 2026-10-18 (Claude)

### Background: the current system

Budget formulation (the executive drafts) → approval by the Diet or assembly → execution (each agency commits and pays within its appropriations) → settlement accounts (決算), audited by the Board of Audit (会計検査院) or local audit commissioners → reported to the legislature. Budgets and settlement accounts are public, but settlement comes once a year, in aggregate, and stops at the first recipient. Reserve funds (予備費) need only after-the-fact approval.

Procurement, subsidies, pensions and benefits are separate items in [`docs/FEATURES.md`](../../FEATURES.md). This item is the **foundation they all spend through**: where public money sits and how it leaves.

### On-chain value test ([ADR 0014](../../decisions/0014-legislative-process-scope.md)), sub-part by sub-part

| Sub-part | Q1 problem | Q2 keeper | Q3 technical | Q4 no record | Q5 combination | Result |
|---|---|---|---|---|---|---|
| Budget formulation and approval | No: public and debated | No | **No**: political | **No**: budget documents are published | Weak | 🚫 (but see Issue 3: approved budget lines as on-chain caps) |
| **Spending execution** (支出) | **Yes**: "parked funds" (預け金) at suppliers found from 2006 (Nagasaki) and in a nationwide audit of prefectures in 2007–08; fictitious business trips; assembly members' activity-expense fraud (e.g. Toyama city assembly, 2016) | **Yes**: agencies keep their own books | **Yes**: traceability | **Partial**: settlement accounts are annual, aggregated, and stop at the first recipient | **Strong**: tax receipts ([ADR 0004](../../decisions/0004-taxation-payment-rail.md)), corporate registration, `ResidentLink`, `OfficialContractRegistry` | **Candidate (core)** |
| **Re-delegation chains** (再委託・中抜き) | **Yes**: the 2020 business-continuity benefit: a ¥76.9bn contract largely re-delegated to a major ad agency through an intermediary body, with further layers | **Yes** | **Yes**: traceability past the first recipient | **Yes**: no public record of the chain | Strong | **Candidate** (overlaps procurement; Issue 5) |
| **Funds and reserve funds** (基金・予備費) | **Yes**: idle balances in funds; reserve-fund use approved only afterwards and hard to trace to the final spend | **Yes** | **Yes** | Partial | Strong | **Candidate** (part of spending) |
| Intergovernmental transfers (地方交付税・国庫支出金) | Partial | — | Yes | Partial | **Strong**: becomes contract-to-contract | Part of spending |
| Settlement accounts and audit (決算・会計検査) | — | — | — | — | — | Not a separate design: real-time on-chain data feeds audit; judgement stays with auditors |
| Government bonds / debt management (国債) | No | — | — | — | — | 🚫 for now: a financial-market function |

### Issues raised

1. **Screening result.** Agree that the core is spending execution (including funds, reserve funds and transfers), with re-delegation as a candidate, and budget formulation / bonds 🚫?
2. **Treasury structure.** Proposal: every public body (national ministries, prefectures, municipalities) holds public money in its own **treasury contract**, the `PoliticalFund` pattern ([ADR 0015](../../decisions/0015-political-donations-model.md)) applied to the state itself. Tax receipts land there; every outflow leaves from it; transfers between bodies are contract-to-contract. Controlled by the accounting officer's multisig.
3. **Budget lines on-chain.** (a) The approved budget is loaded as on-chain **appropriation lines with caps**, and every payment must cite a line and cannot exceed it; supplementary budgets and reserve-fund use are new, public line entries. (b) Payments are only *tagged* with a budget code, and overspending is caught by audit. (a) enforces "spend only what was approved"; (b) is simpler.
4. **Who can be paid.** Proposal: as with political donations, only addresses holding a genuine `ResidentLink` or corporate registration (checked through `OfficialContractRegistry`), or another public treasury. No payment to an unidentified address.
5. **Following money past the first recipient.** (a) Stop at the first recipient; (b) public-contract money goes into a **dedicated contract at the contractor**, so its re-delegation payments are also traced. This decides the principle; the details belong to procurement.
6. **Payments to individuals.** Salaries of public servants, honoraria, refunds: paying from a public treasury to a `ResidentLink` address publishes "this address received this amount from this body". Options: (a) public, as with everything else; (b) individual payments go through a payroll path that publishes only totals. Benefits (welfare, child allowances) will face the same question later.
7. **Assembly members' activity expenses (政務活動費).** Include them here, requiring legislators to spend through a traced contract like `PoliticalFund`?

### Status

Awaiting the user's response.

---

## Round 2 — 2026-10-18 (user + Claude)

### User's decisions

| # | Decision |
|---|---|
| 1 | **Accepted.** |
| 2 | **Accepted**: a treasury contract per public body. |
| 3 | **(b)**: payments are tagged with a budget code; overspending is caught by audit. No on-chain caps. |
| 4 | **Accepted**: only genuine `ResidentLink` holders, registered corporations, or other public treasuries can be paid. |
| 5 | **No special mechanism.** Payments are stablecoin transfers, and the chain already lets anyone follow the money past the first recipient, individual or corporation. Some secrecy is tolerated: cash or special financial-institution accounts may be used where secrecy is needed (e.g. the Cabinet Secretariat's discretionary fund, 官房機密費). The goal is a society where whatever is **not** on-chain is checked thoroughly by off-chain mechanisms. |
| 6 | **(a)**: payments to individuals are public, like everything else. |
| 7 | **Same as 5**: activity expenses are paid in stablecoin. A politician's address is public, so anyone can see where the money went, how much, and whether the payee is a plausible corporation or a suspicious individual. |

### Follow-up points raised by Claude before writing the spec

- **F1. Visible exits to off-chain.** Proposal: money that leaves the chain for secret use must be paid to a registered financial institution (a corporation, so Issue 4 already allows it) with an explicit `OffChainExit` tag. The *use* stays secret, but the **amount and timing of every exit** stay public, so total secret spending per body is always known and the off-chain checks know exactly what to check.
- **F2. Which address receives activity expenses.** (a) The legislator's own `ResidentLink` address. It is simple and already public for VIPs, but activity spending mixes with personal spending, so nobody can tell which outflows were activity expenses. (b) A **dedicated activity address** registered for each legislator (named, public), used only for activity expenses. Payments and spending are then cleanly separable. For (b), the treasury's payee check must accept such registered addresses.

### Status

Awaiting the user's response to F1–F2.

---

## Round 3 — 2026-10-18 (user + Claude)

### User's decisions

- **F1: as proposed.** Exits to off-chain carry an `OffChainExit` tag; amount and timing are public, use is not.
- **F2: (a)**, the legislator's own `ResidentLink` address. The user wants complex mechanisms kept out. Activity expenses can be classified by their source (the treasury payment), and an off-chain application can easily analyse where the money went from that address.
- **New design principle (user):** *whatever can be done off-chain is not put on-chain.* On-chain logic is kept to what genuinely needs a chain; analysis, classification and checks that an off-chain application can do from public chain data stay off-chain.

### Adjustments made while writing the spec (flagged for review)

- **`OfficialContractRegistry` gains a `PublicTreasury` kind,** so a treasury can check on-chain that a payee is another public treasury (Issue 4). This is the minimal addition: without it, transfers between bodies (e.g. local allocation tax) could not pass the payee check.
- **Whether an `OffChainExit` payee is really a financial institution is checked off-chain,** not in the contract. The payee must still be a registered corporation (Issue 4). Following the new principle, the "is it a bank?" check is done from public data.

### Status

All issues resolved. Spec written ([`README.md`](README.md)); ADR: [0019](../../decisions/0019-treasury-model.md).

---

# 議論ログ: 歳出・予算(日本語)

この機能の設計に関するやり取りを順に記録する。形式は[`docs/state-design/citizenship/discussion-log.md`](../citizenship/discussion-log.md)に従う。

---

## Round 1 — 2026-10-18(Claude)

### 前提: 現行制度

予算編成(行政が作成) → 国会・議会の議決 → 執行(各機関が予算の範囲内で支出負担行為を行い支払う) → 決算(会計検査院または地方の監査委員が検査) → 議会に報告。予算と決算は公開されているが、決算は年1回で、集計値であり、最初の受取人までしか追えない。予備費は事後承諾だけで使える。

公共調達、補助金、年金、給付は[`docs/FEATURES.md`](../../FEATURES.md)の別項目である。この項目は、それらすべてが支出に使う**土台**、つまり公金がどこにあり、どう出ていくかを扱う。

### オンチェーン価値テスト([ADR 0014](../../decisions/0014-legislative-process-scope.md))の部分ごとの適用

| 部分 | 問1 問題 | 問2 管理者 | 問3 技術 | 問4 記録なし | 問5 組み合わせ | 結果 |
|---|---|---|---|---|---|---|
| 予算編成・議決 | いいえ: 公開され議論されている | いいえ | **いいえ**: 政治の問題 | **いいえ**: 予算書が公開されている | 弱い | 🚫(ただし論点3: 議決された予算の項目をオンチェーンの上限にする) |
| **支出の執行** | **はい**: 業者に公金を預ける「預け金」が2006年頃に長崎県などで発覚し、2007〜08年の全国の都道府県の検査でも見つかった。カラ出張。議員の政務活動費の不正(2016年の富山市議会など) | **はい**: 各機関が自分の帳簿を管理している | **はい**: 追跡可能性 | **一部**: 決算は年1回の集計で、最初の受取人で止まる | **強い**: 税の受け取り([ADR 0004](../../decisions/0004-taxation-payment-rail.md))、法人登記、`ResidentLink`、`OfficialContractRegistry` | **候補(中核)** |
| **再委託の連鎖(中抜き)** | **はい**: 2020年の持続化給付金。約769億円の委託契約が、中間の団体を経て大手広告会社に大部分再委託され、さらに下の層があった | **はい** | **はい**: 最初の受取人より先の追跡可能性 | **はい**: 連鎖の公的な記録がない | 強い | **候補**(公共調達と重複。論点5) |
| **基金・予備費** | **はい**: 基金に使われない残高が積み上がる。予備費は事後承諾だけで、最終的な使い道まで追いにくい | **はい** | **はい** | 一部 | 強い | **候補**(支出の一部として) |
| 政府間の移転(地方交付税・国庫支出金) | 一部 | — | はい | 一部 | **強い**: コントラクト間の移転になる | 支出の一部として |
| 決算・会計検査 | — | — | — | — | — | 独立した設計は不要: オンチェーンのリアルタイムのデータが検査に使われ、判断は検査する側に残る |
| 国債・債務管理 | いいえ | — | — | — | — | 当面🚫: 金融市場の機能 |

### 提起した論点

1. **選別の結果。** 中核は支出の執行(基金、予備費、政府間の移転を含む)、再委託は候補、予算編成と国債は🚫でよいか?
2. **国庫の構造。** 提案: すべての公的機関(省庁、都道府県、市区町村)は、公金を自らの**国庫コントラクト**に置く。`PoliticalFund`の仕組み([ADR 0015](../../decisions/0015-political-donations-model.md))を国家自身に適用したものである。税の受け取りはここに入り、すべての支出はここから出る。機関の間の移転はコントラクト間で行う。会計管理者のマルチシグが管理する。
3. **予算の項目をオンチェーンに載せるか。** (a) 議決された予算を、上限付きの**予算項目**としてオンチェーンに載せる。すべての支払いは項目を指定しなければならず、上限を超えられない。補正予算と予備費の使用は、新しい公開の項目として追加する。(b) 支払いには予算コードを*付ける*だけにし、超過は検査で見つける。(a)は「議決された分しか使えない」を強制でき、(b)はより単純である。
4. **誰に支払えるか。** 提案: 政治献金と同じく、本物の`ResidentLink`か法人登記を持つアドレス(`OfficialContractRegistry`で確認)、または別の公的な国庫だけに支払える。身元の分からないアドレスには支払えない。
5. **最初の受取人より先を追うか。** (a) 最初の受取人で止める。(b) 公共契約のお金は**受注者側の専用コントラクト**に入れ、再委託の支払いも追跡する。ここでは原則を決め、詳細は公共調達で扱う。
6. **個人への支払い。** 公務員の給与、謝金、還付など。公的な国庫から`ResidentLink`アドレスに支払うと、「このアドレスがこの機関からこの額を受け取った」ことが公開される。選択肢: (a) 他と同じく公開する。(b) 個人への支払いは、合計だけを公開する給与用の経路を通す。給付(生活保護、児童手当など)も後で同じ問題に直面する。
7. **議員の政務活動費。** ここに含め、議員に`PoliticalFund`のような追跡されるコントラクトを通して支出させるか?

### ステータス

ユーザーの回答待ち。

---

## Round 2 — 2026-10-18(ユーザー + Claude)

### ユーザーの決定

| # | 決定 |
|---|---|
| 1 | **了承。** |
| 2 | **了承**: 公的機関ごとに国庫コントラクトを置く。 |
| 3 | **(b)**: 支払いには予算コードを付け、超過は検査で見つける。オンチェーンの上限は設けない。 |
| 4 | **了承**: 支払えるのは、本物の`ResidentLink`の保有者、登記済みの法人、別の公的な国庫だけ。 |
| 5 | **特別な仕組みは不要。** 支払いはステーブルコインの送金であり、個人でも法人でも、最初の受取人より先も誰でもチェーン上で追える。秘密にしたいものについては、一部、現金や金融機関の特殊な口座の利用を許容する(官房機密費などのため)。目指すのは、オンチェーンで**ない**部分を、オフチェーンの仕組みで徹底してチェックする社会である。 |
| 6 | **(a)**: 個人への支払いも、他と同じく公開する。 |
| 7 | **5と同じ**: 政務活動費もステーブルコインで支払う。政治家のアドレスは公開されているので、誰でも、どこにいくら支払われたか、支払先が納得感のある法人か怪しい個人かを判別できる。 |

### 仕様作成前にClaudeが提起した確認点

- **F1. オフチェーンへの出口を見えるようにする。** 提案: 秘密の用途のためにチェーンの外に出るお金は、登記済みの金融機関(法人なので論点4ですでに支払える)に、明示的な`OffChainExit`のタグを付けて支払わなければならない。*使い道*は秘密のままだが、**すべての出口の金額と時期は公開**されるので、機関ごとの秘密の支出の総額は常に分かり、オフチェーンのチェックも何を調べればよいかが正確に分かる。
- **F2. 政務活動費をどのアドレスで受け取るか。** (a) 議員自身の`ResidentLink`アドレス。単純で、要人としてすでに公開されているが、活動の支出と私的な支出が混ざり、どの支出が政務活動費だったかを誰も見分けられない。(b) 議員ごとに登録する**専用の活動用アドレス**(名前付きで公開)を、政務活動費だけに使う。受け取りと支出をきれいに分けられる。(b)の場合、国庫の支払先の確認で、こうした登録済みアドレスも受け付ける必要がある。

### ステータス

F1〜F2へのユーザーの回答待ち。

---

## Round 3 — 2026-10-18(ユーザー + Claude)

### ユーザーの決定

- **F1: 提案どおり。** オフチェーンへの出口には`OffChainExit`のタグを付ける。金額と時期は公開し、使い道は公開しない。
- **F2: (a)**、議員自身の`ResidentLink`アドレス。ユーザーは複雑な仕組みを極力排除したい。政務活動費は送金元(国庫からの支払い)で分類でき、そのアドレスからの行き先を分析するアプリケーションはオフチェーンで容易に実装できる。
- **新しい設計方針(ユーザー):** *オフチェーンでできることは、極力オンチェーン化しない。* オンチェーンのロジックは本当にチェーンが必要なものに限る。公開されたチェーンのデータからオフチェーンのアプリケーションでできる分析・分類・チェックは、オフチェーンに置く。

### 仕様作成時に加えた調整(レビュー対象)

- **`OfficialContractRegistry`に`PublicTreasury`の種類を加える。** 国庫が、支払先が別の公的な国庫であることをオンチェーンで確認できるようにするため(論点4)。これは最小限の追加で、これがないと機関の間の移転(地方交付税など)が支払先の確認を通らない。
- **`OffChainExit`の支払先が本当に金融機関かどうかは、コントラクトではなくオフチェーンで確認する。** 支払先は引き続き登記済みの法人でなければならない(論点4)。新しい方針に従い、「銀行かどうか」の確認は公開データから行う。

### ステータス

すべての論点が解決。仕様を作成([`README.md`](README.md))。ADR: [0019](../../decisions/0019-treasury-model.md)。

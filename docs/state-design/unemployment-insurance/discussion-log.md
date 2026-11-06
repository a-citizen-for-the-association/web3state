# Discussion Log: Unemployment insurance (雇用保険)

Records the back-and-forth on this feature's design, in order. See [`docs/state-design/citizenship/discussion-log.md`](../citizenship/discussion-log.md) for the format this follows.

---

## Round 1 — 2026-11-07 (Claude)

### Background: the current system

- **Premiums** are a percentage of pay. The insurance part is shared by employer and employee; a further part, the "two employment programmes" (雇用保険二事業), is paid by the employer alone and funds employer-side subsidies such as the employment adjustment subsidy (雇用調整助成金). The employer withholds the employee's share and remits everything.
- **Benefits:** the job-seeker's benefit (基本手当) after losing a job, childcare-leave benefit (育児休業給付), education and training benefit (教育訓練給付), and others. The job-seeker's benefit requires enough insured months, a separation notice (離職票) issued by the employer, and a check of unemployment (失業認定) at Hello Work every four weeks.
- **The reason for leaving** (dismissal or own choice) changes the waiting period and the length of benefit.

Known problems:
- **Working while receiving benefit:** the most common kind of fraud. The office relies on self-reports.
- **Employment adjustment subsidy fraud (2020–22):** a large number of fraudulent claims during COVID, for leave that never happened or employees who did not exist.
- **Wrong benefit amounts from flawed statistics (2019):** irregularities in the Monthly Labour Survey (毎月勤労統計) led to underpayment of unemployment benefits to many people over years, because benefit limits are indexed to those statistics.
- **Disputes over the reason for leaving:** employers recording dismissals as voluntary departures.
- **Training-benefit kickbacks:** providers returning part of the fee to the trainee.
- **Non-enrolment** by employers, as with pension.

### What already exists in this project

- **Pension pattern** ([ADR 0024](../../decisions/0024-pension-model.md)): the employee pays their own premium from their `ResidentLink` address, the transfer is the record, months are allocated by a fixed rule.
- **Benefits pattern** ([ADR 0025](../../decisions/0025-benefits-model.md)): payment to the recipient's own address with the shared social-security code; private decisions anchored by hash; income checks only for applicants and recipients, with consent.
- **Subsidies** ([ADR 0023](../../decisions/0023-subsidies-model.md)): expenses must be paid on-chain; kickbacks are detected off-chain.
- **`EmployeeID`** ([ADR 0010](../../decisions/0010-employee-id-credential.md)) is minted on hiring and burned when employment ends, with the reason kept off-chain. Salaries are on-chain ([ADR 0020](../../decisions/0020-certified-address-stablecoin.md)).

### On-chain value test ([ADR 0014](../../decisions/0014-legislative-process-scope.md)), sub-part by sub-part

| Sub-part | Q1 problem | Q2 keeper | Q3 technical | Q4 no record | Q5 combination | Result |
|---|---|---|---|---|---|---|
| Premiums and insured months | Yes: non-enrolment | Yes | **Yes** | Yes | **Strong**: pension pattern | **Candidate**: reuse the pension pattern |
| **Working while receiving** | **Yes**: the main fraud | **Yes**: self-report | **Yes**: income and hiring are visible | **Yes** | **Very strong**: salary inflows, new `EmployeeID` | **Candidate (core)**: off-chain flag |
| Benefit amount | **Yes**: the 2019 statistics error | Yes | **Yes**: wages before leaving are on-chain | Partial | Strong | Recomputable by anyone; off-chain |
| Reason for leaving | Yes: disputes | — | **No**: a judgement | — | Weak | Off-chain; decision anchored by hash |
| Training benefit | Yes: kickbacks | — | **Yes**: fee flows | — | Strong: subsidies pattern | **Candidate**: fees paid on-chain |
| Employment adjustment subsidy (二事業) | **Yes** | — | — | — | — | **Already covered** by subsidies (ADR 0023) |
| Unemployment check (失業認定), job-search activity | Partial | — | **No**: judgement | — | — | Off-chain |

### Proposal in line with "off-chain if it can be" ([ADR 0019](../../decisions/0019-treasury-model.md))

**No new contract.** This item is almost entirely a combination of the pension, benefits and subsidies designs. The new value is that the most common fraud, working while receiving benefit, becomes visible: a salary arriving at the recipient's address, or a new `EmployeeID` minted to it.

### Issues raised

1. **Screening result.** Scope: unemployment-insurance premiums and benefits (job-seeker's, childcare-leave, education and training, and the others). The employment adjustment subsidy and other 二事業 subsidies follow the subsidies design (ADR 0023). Workers' accident compensation (労災保険), which is not in the feature list, is out of scope; Claude proposes adding it to the backlog.
2. **New contract or not.** (A) No new contract. (B) An `UnemploymentClaim` contract recording claims and checks on-chain. Proposal: **(A)**.
3. **Premium payment.** Following pension's option (a):
   - (a) **The employee pays the whole insurance part from their own `ResidentLink` address** to a dedicated unemployment-insurance `PublicTreasury` (today's 労働保険特別会計 雇用勘定); the employer's half of that part is added to pay. **The 二事業 part stays an employer-only payment from the corporate address,** because it belongs to no individual's record and funds employer-side subsidies.
   - (b) The employee pays everything, including the 二事業 part.

   Proposal: **(a)**.
4. **Insured months and the separation notice.** Insured months are computed from the premium transfers (oldest unpaid month first, as for pension), together with the `EmployeeID` mint and burn. This replaces the employment-period part of the separation notice. The reason for leaving stays a judgement: the employer's statement and Hello Work's decision are anchored by hash in the labour bureau's `DocumentRegistry`, and disputes are settled off-chain.
5. **Working while receiving.** Under the consent rule of ADR 0025, Hello Work's tooling flags a recipient's address when a salary arrives or an `EmployeeID` is minted to it. The person still reports; the chain checks the report. Cash work remains a limit.
6. **Payment and amount.** Benefits are `pay()` with the shared social-security code (ADR 0025). The amount depends on wages before leaving, which are on-chain, so the person can recompute it. A side effect worth noting: the average wages that index benefit limits can be computed directly from public salary flows, which would have exposed the 2019 statistics error. Whether to compute official wage statistics that way belongs to a future statistics discussion, not to this item.
7. **Training benefit.** As in subsidies, fees must be paid in the JPY stablecoin to the registered provider's address (cash not eligible), and money flowing back from the provider to the trainee is flagged off-chain.

### Status

Awaiting the user's response.

---

## Round 2 — 2026-11-07 (user + Claude)

### User's decisions

Issues 1–7 **as proposed**: Issue 2 **(A)**, no new contract; Issue 3 **(a)**, the employee pays the whole insurance part, the employer alone pays the 二事業 part; workers' accident compensation goes to the backlog.

### Adjustments made while writing the spec (flagged for review)

- **One receiving treasury is enough.** Unlike pension, both parts go to the same unemployment-insurance `PublicTreasury`. The sender's kind already tells them apart: a transfer from a `ResidentLink` address is a personal premium; a transfer from a corporate address is the 二事業 part.
- **The "working while receiving" check depends on the benefit.** For the job-seeker's benefit, any salary inflow or new `EmployeeID` is flagged. For the childcare-leave benefit, the person still holds their `EmployeeID` by design, so only pay from the employer above the level the law allows during leave is flagged.
- **Official statistics computed from chain data:** the future discussion that Issue 6 pointed to is linked to the existing backlog row on statistics.

### Status

All issues resolved. Spec written ([`README.md`](README.md)); ADR: [0026](../../decisions/0026-unemployment-insurance-model.md). The three adjustments await the user's confirmation.

---

# 議論ログ: 雇用保険(日本語)

この機能の設計に関するやり取りを順に記録する。形式は[`docs/state-design/citizenship/discussion-log.md`](../citizenship/discussion-log.md)に従う。

---

## Round 1 — 2026-11-07(Claude)

### 背景: 現在の制度

- **保険料**は給与に対する割合で決まる。失業等給付などの部分は労使で負担し、さらに「雇用保険二事業」の部分は雇用主だけが負担して、雇用調整助成金のような雇用主向けの助成金の財源になる。雇用主が従業員負担分を天引きし、全額を納める。
- **給付:** 離職後の基本手当、育児休業給付、教育訓練給付などがある。基本手当には、十分な被保険者期間、雇用主が発行する離職票、そして4週ごとのハローワークでの失業認定が必要である。
- **離職理由**(会社都合か自己都合か)によって、給付制限の期間と給付日数が変わる。

知られている問題:
- **受給中の就労:** 最も多い不正。窓口は自己申告に頼っている。
- **雇用調整助成金の不正(2020〜22年):** コロナ禍で、実際には行われなかった休業や存在しない従業員について、多数の不正受給があった。
- **誤った統計による給付額の誤り(2019年):** 毎月勤労統計の不適切な調査により、長年にわたって多くの人の雇用保険の給付が過少になった。給付の上限額などがこの統計に連動しているためである。
- **離職理由をめぐる争い:** 解雇を自己都合の退職として記録する雇用主。
- **教育訓練給付のキックバック:** 講座の提供者が受講料の一部を受講者に戻す。
- **雇用主の未加入**。年金と同じ問題。

### このプロジェクトに既にあるもの

- **年金の型**([ADR 0024](../../decisions/0024-pension-model.md)): 従業員は自分の`ResidentLink`アドレスから自分で保険料を払い、送金が記録になり、何月分かは固定したルールで決まる。
- **各種手当の型**([ADR 0025](../../decisions/0025-benefits-model.md)): 本人のアドレスへ社会保障の共通コードで支払う。非公開の決定はハッシュでアンカリングする。収入確認は申請者と受給者に限り、同意に基づく。
- **補助金**([ADR 0023](../../decisions/0023-subsidies-model.md)): 経費はオンチェーンで支払わなければならず、キックバックはオフチェーンで検出する。
- **`EmployeeID`**([ADR 0010](../../decisions/0010-employee-id-credential.md))は採用時にmintされ、雇用の終了時にburnされる。理由はオフチェーンに置く。給与はオンチェーンにある([ADR 0020](../../decisions/0020-certified-address-stablecoin.md))。

### オンチェーン価値テスト([ADR 0014](../../decisions/0014-legislative-process-scope.md))、部分ごと

| 部分 | Q1 問題 | Q2 管理者 | Q3 技術的 | Q4 記録なし | Q5 組み合わせ | 結果 |
|---|---|---|---|---|---|---|
| 保険料と被保険者期間 | あり: 未加入 | あり | **あり** | あり | **強い**: 年金の型 | **候補**: 年金の型を再利用 |
| **受給中の就労** | **あり**: 主な不正 | **あり**: 自己申告 | **あり**: 収入と採用が見える | **あり** | **非常に強い**: 給与の入金、新しい`EmployeeID` | **候補(中核)**: オフチェーンで検知 |
| 給付額 | **あり**: 2019年の統計の誤り | あり | **あり**: 離職前の給与がオンチェーン | 一部 | 強い | 誰でも再計算できる。オフチェーン |
| 離職理由 | あり: 争い | — | **なし**: 判断 | — | 弱い | オフチェーン。決定はハッシュでアンカリング |
| 教育訓練給付 | あり: キックバック | — | **あり**: 受講料の流れ | — | 強い: 補助金の型 | **候補**: 受講料をオンチェーンで支払う |
| 雇用調整助成金(二事業) | **あり** | — | — | — | — | 補助金(ADR 0023)で**対応済み** |
| 失業認定、求職活動 | 一部 | — | **なし**: 判断 | — | — | オフチェーン |

### 「オフチェーンでできることはオフチェーンで」([ADR 0019](../../decisions/0019-treasury-model.md))に沿った提案

**新しいコントラクトは作らない。** この項目は、ほぼ年金、各種手当、補助金の設計の組み合わせである。新しい価値は、最も多い不正である受給中の就労が見えるようになることだ。受給者のアドレスに給与が入る、あるいは新しい`EmployeeID`がmintされれば、それとわかる。

### 提起した論点

1. **ふるい分けの結果。** スコープ: 雇用保険の保険料と給付(基本手当、育児休業給付、教育訓練給付、その他)。雇用調整助成金などの二事業の助成金は補助金の設計(ADR 0023)に従う。機能一覧にない労災保険はスコープ外とし、Claudeはバックログへの追加を提案する。
2. **新しいコントラクトを作るか。** (A) 作らない。(B) 申請と確認をオンチェーンで記録する`UnemploymentClaim`コントラクトを作る。提案: **(A)**。
3. **保険料の支払い。** 年金の選択肢(a)にならう:
   - (a) **従業員が、労使負担の部分の全額を自分の`ResidentLink`アドレスから**雇用保険専用の`PublicTreasury`(現在の労働保険特別会計 雇用勘定)に払う。その部分の雇用主負担分は給与に上乗せする。**二事業の部分は、引き続き雇用主だけが法人アドレスから払う。** 個人の記録に属さず、雇用主向けの助成金の財源だからである。
   - (b) 二事業の部分も含めて、すべて従業員が払う。

   提案: **(a)**。
4. **被保険者期間と離職票。** 被保険者期間は、保険料の送金(年金と同じく未納の最も古い月から充てる)と`EmployeeID`のmint・burnから計算する。これで離職票の雇用期間の部分は不要になる。離職理由は判断の問題として残る。雇用主の申し立てとハローワークの決定は労働局の`DocumentRegistry`にハッシュでアンカリングし、争いはオフチェーンで解決する。
5. **受給中の就労。** ADR 0025の同意のルールのもとで、ハローワークのツールは、受給者のアドレスに給与が入ったり`EmployeeID`がmintされたりしたら、そのアドレスを検知する。本人は引き続き申告し、チェーンがその申告を確かめる。現金での就労は限界として残る。
6. **支払いと金額。** 給付は社会保障の共通コード(ADR 0025)を付けた`pay()`で行う。金額は離職前の給与で決まり、それはオンチェーンにあるので、本人が再計算できる。付け加えると、給付の上限額などの基になる平均賃金は、公開された給与の流れから直接計算でき、そうしていれば2019年の統計の誤りは表に出ていたはずである。公式の賃金統計をそうして計算するかどうかは、この項目ではなく、将来の統計の議論に属する。
7. **教育訓練給付。** 補助金と同じく、受講料は円建てステーブルコインで登録済みの提供者のアドレスに支払わなければならず(現金は対象外)、提供者から受講者に戻るお金はオフチェーンで検知する。

### ステータス

ユーザーの回答待ち。

---

## Round 2 — 2026-11-07(ユーザー＋Claude)

### ユーザーの決定

論点1〜7は**提案どおり**。論点2は**(A)**で新しいコントラクトは作らない。論点3は**(a)**で、労使負担の部分は従業員が全額を払い、二事業の部分は雇用主だけが払う。労災保険はバックログへ。

### 仕様を書く際に加えた調整(確認待ち)

- **受け取る国庫は1つで足りる。** 年金と違い、両方の部分を同じ雇用保険の`PublicTreasury`に払う。送信元の種類で区別できるからである: `ResidentLink`アドレスからの送金は個人の保険料、法人アドレスからの送金は二事業の部分である。
- **「受給中の就労」の確認は給付によって変える。** 基本手当では、給与の入金や新しい`EmployeeID`をすべて検知する。育児休業給付では、本人は制度上`EmployeeID`を持ったままなので、休業中に法律が認める水準を超える雇用主からの給与だけを検知する。
- **チェーンのデータから計算する公式統計:** 論点6で触れた将来の議論を、統計についての既存のバックログ項目に結びつける。

### ステータス

すべての論点が解決。仕様を作成([`README.md`](README.md))。ADR: [0026](../../decisions/0026-unemployment-insurance-model.md)。3つの調整はユーザーの確認待ち。

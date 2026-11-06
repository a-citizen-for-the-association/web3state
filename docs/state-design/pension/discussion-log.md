# Discussion Log: Pension (年金)

Records the back-and-forth on this feature's design, in order. See [`docs/state-design/citizenship/discussion-log.md`](../citizenship/discussion-log.md) for the format this follows.

---

## Round 1 — 2026-11-07 (Claude)

### Background: the current system

- **Two tiers of public pension.** The National Pension (国民年金, basic pension) covers every resident aged 20–59. Self-employed people, students and the unemployed (category 1) pay a flat premium themselves. Employees (category 2) are also enrolled in Employees' Pension (厚生年金). Its premium is proportional to pay, split half and half with the employer, and the employer withholds and remits it. Dependent spouses of employees (category 3) pay nothing.
- **Records** are kept by the Japan Pension Service (日本年金機構), which also decides each person's entitlement (裁定) and pays the benefit every two months. The reserve fund is invested by GPIF.
- **Exemptions and deferrals** (免除・猶予) for low income are decided case by case, and exempt periods count partially towards the benefit.

Known problems:
- **"Lost pensions" (消えた年金, 2007):** about 50 million contribution records could not be matched to anyone. The cause was record-keeping: several pension numbers per person, and transcription errors. Many people received less than they were owed.
- **Data-entry outsourcing (2018):** a contractor re-subcontracted data entry, against the contract, and input errors led to wrong payments for many pensioners.
- **Payments after death:** the 2010 "missing elderly" cases (所在不明高齢者). In one case a man had been dead for about 30 years while his family kept receiving his pension. Unreported deaths still cause improper payments.
- **Employer evasion:** businesses that should enrol staff in Employees' Pension do not (the government has estimated over a million affected workers), or they declare lower pay than they actually pay, to reduce premiums.
- **A data leak (2015):** about 1.25 million personal records leaked from the Japan Pension Service after a cyber attack.

### What already exists in this project

- **Payments** leave through a `PublicTreasury` ([ADR 0019](../../decisions/0019-treasury-model.md)) only to a genuine `ResidentLink` holder. A deceased person's `ResidentLink` is burned, so a payment to their address reverts with no extra code.
- **Payments to individuals are public** (ADR 0019), and paying from one's own `ResidentLink` address makes the sending address the payer's reference ([ADR 0004](../../decisions/0004-taxation-payment-rail.md)).
- **Salaries are on-chain** under the certified-address rule ([ADR 0020](../../decisions/0020-certified-address-stablecoin.md)), and `EmployeeID` ([ADR 0010](../../decisions/0010-employee-id-credential.md)) shows who is employed where.
- **The address survives a move** (the new municipality reissues to the same address), and a lost key or death goes through successor migration (ADR 0020), which leaves an on-chain link from the old address to the new one.
- **Employer withholding** is to be eliminated, not replicated on-chain ([taxation spec](../taxation/README.md)).

### On-chain value test ([ADR 0014](../../decisions/0014-legislative-process-scope.md)), sub-part by sub-part

| Sub-part | Q1 problem | Q2 keeper | Q3 technical | Q4 no record | Q5 combination | Result |
|---|---|---|---|---|---|---|
| **Contribution records** (納付記録) | **Yes**: lost records, entry errors | **Yes**: one body, errors found decades later | **Yes**: identity linkage, record integrity | **Yes**: the person cannot check independently | **Strong**: `ResidentLink` address as the reference | **Candidate (core)** |
| **Employer enrolment and declared pay** | **Yes**: non-enrolment, under-declaration | Yes | **Yes**: salaries are visible | Yes | **Strong**: `EmployeeID` + salary flows | **Candidate**: detection by off-chain analysis |
| Benefit payment | Partial | — | — | — | — | Already covered by the treasury |
| **Stopping on death** | **Yes**: payments after death | Partial | **Partly**: registered deaths are technical; unreported deaths are not | — | **Strong**: `ResidentLink` burn | Registered deaths: automatic; unreported deaths: off-chain (existence checks) |
| Entitlement calculation (裁定) | Partial: errors | — | **Mostly no**: complex legal rules | — | Moderate | Off-chain; **anyone can recompute** from public data |
| Exemptions, category 3 status | — | — | No: case-by-case decisions | — | — | Off-chain decisions; see Issue 5 |
| Reserve-fund investment (GPIF) | No major problem | No: already disclosed quarterly | No | No | Weak | **Excluded** (a financial-market function, like government bonds in ADR 0019) |
| Private and corporate pensions (iDeCo, DB/DC) | — | — | — | — | — | **Out of scope**: private financial products (financial-infrastructure backlog) |

### Proposal in line with "off-chain if it can be" ([ADR 0019](../../decisions/0019-treasury-model.md))

**No new contract.** The contribution record *is* the stablecoin payment itself: a transfer from the insured person's `ResidentLink` address to the pension body's `PublicTreasury`. A record that is a payment from your own address cannot be lost, mis-entered or attributed to someone else, so the "lost pensions" problem disappears structurally. Benefits are ordinary treasury payments. Entitlement calculation, employer checks and existence checks are off-chain applications over public data.

### Issues raised

1. **Screening result.** Scope: public pensions (National Pension and Employees' Pension): contributions, entitlement and payment. GPIF investment is excluded (🚫 as a sub-part); private and corporate pensions are out of scope.
2. **New contract or not.** (A) No new contract: contributions are plain transfers to the pension body's `PublicTreasury`, benefits are `pay()` with a pension budget code, everything else is off-chain. (B) A `PensionAccount` contract that keeps per-person contribution totals on-chain. Proposal: **(A)**. Totals can be summed from the transfers by any application.
3. **Who pays the Employees' Pension premium, and from which address.** Today the employer withholds the employee's half and remits both halves. Options:
   - (a) **The employee pays the whole premium from their own `ResidentLink` address**; the employer's half is added to gross pay. This follows the taxation design's direction of eliminating withholding, and makes every contribution record "from your own address".
   - (b) The employee pays their half from their own address, and the employer pays its half from the corporate address with the employee's address as a reference tag. The employer's share stays visibly the employer's, but a reference-tagged transfer is a new mechanism.
   - (c) As today: the employer remits both halves with a per-employee breakdown off-chain. This keeps the lost-records risk for employees.

   Proposal: **(a)**. It needs a legal change (the employer's half becomes part of pay), which is consistent with the withholding direction already taken.
4. **Publication.** Contributions and benefits are public, per address, like every other payment to or from an individual (ADR 0004, ADR 0019). Anyone can see roughly what an address pays in and receives. This is the same privacy cost the user accepted for taxes and public pay, but it now covers almost every adult. Proposal: **public**, unchanged from the earlier principle.
5. **Exemptions and category 3.** These change the entitlement but cannot be derived from the chain. Proposal: the pension body anchors each decision by hash in its `DocumentRegistry` ([ADR 0017](../../decisions/0017-executive-document-anchoring-v1.md)); the person keeps the document. Only a hash goes on-chain, so the decision itself stays private, but the person can later prove it was made and not altered. With this, a person's whole entitlement can be recomputed from the chain plus their own documents.
6. **Death and unreported deaths.** A registered death burns the `ResidentLink`, so payments revert automatically. Unpaid pension owed at death (未支給年金) goes to the survivors' addresses as an ordinary payment. Unreported deaths remain an off-chain problem (existence checks), but a pension address that receives money and never spends it, or whose spending pattern changes abruptly, can be flagged by off-chain analysis. No on-chain mechanism.
7. **Employer evasion.** Detected off-chain: a corporation that pays salaries to `EmployeeID` holders while those employees make no Employees' Pension contribution (under 3(a)), or contribute less than their visible pay implies. Under 3(a), under-declaration of pay becomes impossible to hide, because the premium is computed from pay that is itself on-chain.

### Status

Awaiting the user's response.

---

## Round 2 — 2026-11-07 (user + Claude)

### User's decisions

Issues 1, 2 and 4–7 **as proposed**; Issue 2: **(A)**, no new contract; Issue 3: **(a)**, the employee pays the whole premium from their own `ResidentLink` address, and the employer's half is added to gross pay.

### Adjustments made while writing the spec (flagged for review)

- **Two receiving treasuries.** The pension special account has two `PublicTreasury` contracts, one for the National Pension and one for Employees' Pension (mirroring today's 国民年金勘定 and 厚生年金勘定). A plain transfer carries no memo, so the pair "sending address + receiving treasury" identifies whose contribution it is and to which scheme.
- **Allocation to months is fixed by law: oldest unpaid month first.** A transfer does not say which month it pays for (late payments are allowed up to two years, prepayment is possible). With a fixed rule, anyone can compute the same month-by-month record from the transfers, so the pension body keeps no separate ledger that could diverge.
- **Award decisions (裁定) are anchored too,** by hash, like exemptions (Issue 5). The person can check the computation against their own on-chain contributions and anchored decisions.
- **One generic budget code for all pension benefits.** Old-age, survivors' and disability pensions are paid with the same budget code, so a payment does not reveal that its recipient is disabled or widowed. The kind of pension is in the anchored, private decision. The body publishes totals per kind off-chain for audit.
- **An employee who does not pay is treated like a category 1 delinquent** (reminder, then enforcement through the existing address-identification route of [ADR 0018](../../decisions/0018-judiciary-model.md)). Under withholding this could not happen; it is the cost of option (a).

### Status

All issues resolved. Spec written ([`README.md`](README.md)); ADR: [0024](../../decisions/0024-pension-model.md). The five adjustments await the user's confirmation.

---

# 議論ログ: 年金(日本語)

この機能の設計に関するやり取りを順に記録する。形式は[`docs/state-design/citizenship/discussion-log.md`](../citizenship/discussion-log.md)に従う。

---

## Round 1 — 2026-11-07(Claude)

### 背景: 現在の制度

- **公的年金は2階建て。** 国民年金(基礎年金)は20〜59歳のすべての住民が加入する。自営業者・学生・無職の人(第1号被保険者)は定額の保険料を自分で納める。会社員(第2号被保険者)は厚生年金にも加入する。その保険料は給与に比例し、雇用主と折半で、雇用主が天引きして納める。会社員に扶養される配偶者(第3号被保険者)は保険料を払わない。
- **記録**は日本年金機構が管理する。機構は各人の受給権を決定(裁定)し、2か月ごとに年金を支払う。積立金はGPIFが運用する。
- **免除・猶予**は低所得の場合に個別に決定され、免除期間は年金額に一部反映される。

知られている問題:
- **「消えた年金」(2007年):** 約5000万件の納付記録が誰のものか特定できなかった。原因は記録管理で、1人に複数の年金番号があったことや転記ミスである。多くの人が本来より少ない年金しか受け取っていなかった。
- **データ入力の外部委託(2018年):** 委託先が契約に反して入力作業を再委託し、入力ミスによって多くの受給者に誤った額が支払われた。
- **死亡後の支給:** 2010年の「所在不明高齢者」問題。ある事例では、男性が約30年前に亡くなっていたのに家族が年金を受け取り続けていた。死亡が届けられないことによる不正受給は今もある。
- **雇用主による逃れ:** 厚生年金に加入させるべき事業所が加入させない(政府は影響を受ける労働者を100万人超と推計)、あるいは実際より低い給与を届け出て保険料を減らす。
- **情報漏洩(2015年):** サイバー攻撃により、日本年金機構から約125万件の個人情報が流出した。

### このプロジェクトに既にあるもの

- **支払い**は`PublicTreasury`([ADR 0019](../../decisions/0019-treasury-model.md))から、本物の`ResidentLink`保有者にだけ出る。亡くなった人の`ResidentLink`はburnされるので、そのアドレスへの支払いは追加のコードなしでrevertする。
- **個人への支払いは公開**であり(ADR 0019)、自分の`ResidentLink`アドレスから支払うと、送信元アドレスが支払者の識別番号の役割を果たす([ADR 0004](../../decisions/0004-taxation-payment-rail.md))。
- 認定アドレス制([ADR 0020](../../decisions/0020-certified-address-stablecoin.md))により**給与はオンチェーン**にあり、`EmployeeID`([ADR 0010](../../decisions/0010-employee-id-credential.md))で誰がどこに雇われているかがわかる。
- **アドレスは転居しても変わらない**(転入先の市区町村が同じアドレスに再発行する)。鍵の紛失や死亡の場合は承継移転(ADR 0020)を通り、旧アドレスから新アドレスへのつながりがオンチェーンに残る。
- **雇用主による源泉徴収**はオンチェーンで再現せず、廃止をめざす([納税の仕様](../taxation/README.md))。

### オンチェーン価値テスト([ADR 0014](../../decisions/0014-legislative-process-scope.md))、部分ごと

| 部分 | Q1 問題 | Q2 管理者 | Q3 技術的 | Q4 記録なし | Q5 組み合わせ | 結果 |
|---|---|---|---|---|---|---|
| **納付記録** | **あり**: 記録の消失、入力ミス | **あり**: 一機関が管理、誤りが数十年後に発覚 | **あり**: 本人との紐づけ、記録の完全性 | **あり**: 本人が独立に確認できない | **強い**: `ResidentLink`アドレスが識別番号になる | **候補(中核)** |
| **雇用主の加入・報酬の届出** | **あり**: 未加入、過少申告 | あり | **あり**: 給与が見える | あり | **強い**: `EmployeeID`＋給与の流れ | **候補**: オフチェーン分析で検出 |
| 年金の支払い | 一部 | — | — | — | — | 歳出・予算で対応済み |
| **死亡時の停止** | **あり**: 死亡後の支給 | 一部 | **一部**: 届出済みの死亡は技術で対応できるが、未届の死亡はできない | — | **強い**: `ResidentLink`のburn | 届出済み: 自動、未届: オフチェーン(現況確認) |
| 年金額の計算(裁定) | 一部: 誤り | — | **ほぼなし**: 複雑な法律上のルール | — | 中程度 | オフチェーン。公開データから**誰でも再計算できる** |
| 免除、第3号の認定 | — | — | なし: 個別の判断 | — | — | オフチェーンの決定。論点5を参照 |
| 積立金の運用(GPIF) | 大きな問題なし | なし: 四半期ごとに公開済み | なし | なし | 弱い | **対象外**(ADR 0019の国債と同じく金融市場の機能) |
| 私的・企業年金(iDeCo、DB/DC) | — | — | — | — | — | **スコープ外**: 民間の金融商品(金融基盤のバックログ) |

### 「オフチェーンでできることはオフチェーンで」([ADR 0019](../../decisions/0019-treasury-model.md))に沿った提案

**新しいコントラクトは作らない。** 納付記録とは、ステーブルコインの支払いそのもの、つまり被保険者の`ResidentLink`アドレスから年金を扱う機関の`PublicTreasury`への送金である。自分のアドレスからの支払いである記録は、消えることも、入力を誤ることも、他人のものとされることもないので、「消えた年金」は構造的に起こらなくなる。年金の給付は通常の歳出の支払いである。年金額の計算、雇用主のチェック、現況確認は、公開データを使うオフチェーンのアプリケーションで行う。

### 提起した論点

1. **ふるい分けの結果。** スコープ: 公的年金(国民年金と厚生年金)の保険料・裁定・支払い。GPIFの運用は対象外(部分として🚫)。私的・企業年金はスコープ外。
2. **新しいコントラクトを作るか。** (A) 作らない: 保険料は年金を扱う機関の`PublicTreasury`への単純な送金、給付は年金の予算コードを付けた`pay()`、それ以外はオフチェーン。(B) 個人ごとの納付累計をオンチェーンで保持する`PensionAccount`コントラクトを作る。提案: **(A)**。累計はどのアプリケーションでも送金から合計できる。
3. **厚生年金の保険料を誰が、どのアドレスから払うか。** 現在は雇用主が従業員負担分を天引きし、労使両方の分を納めている。選択肢:
   - (a) **従業員が自分の`ResidentLink`アドレスから全額を払う。** 雇用主負担分は額面の給与に上乗せする。納税の設計で決めた源泉徴収廃止の方向に沿い、すべての納付記録が「自分のアドレスから」になる。
   - (b) 従業員は自分の負担分を自分のアドレスから払い、雇用主は自分の負担分を法人アドレスから、従業員のアドレスを参照タグとして付けて払う。雇用主負担分が雇用主のものとして見えるが、参照タグ付きの送金という新しい仕組みが必要になる。
   - (c) 現在と同じ: 雇用主が両方の分を納め、従業員ごとの内訳はオフチェーン。会社員の記録が消えるリスクが残る。

   提案: **(a)**。法改正(雇用主負担分を給与の一部にする)が必要だが、すでに決めた源泉徴収の方向と一致する。
4. **公開範囲。** 保険料と年金給付は、個人への・個人からのほかの支払いと同じく、アドレスごとに公開する(ADR 0004、ADR 0019)。誰でも、あるアドレスがおおよそいくら払い、いくら受け取っているかがわかる。納税や公務員の給与でユーザーが受け入れたのと同じプライバシーのコストだが、今回はほぼすべての成人に及ぶ。提案: これまでの原則どおり**公開**。
5. **免除と第3号。** これらは年金額を変えるが、チェーンからは導けない。提案: 年金を扱う機関が各決定のハッシュを自らの`DocumentRegistry`([ADR 0017](../../decisions/0017-executive-document-anchoring-v1.md))にアンカリングし、本人が文書を保管する。オンチェーンに載るのはハッシュだけなので決定の内容は秘密のままだが、本人は後から、その決定が行われ、改ざんされていないことを証明できる。これにより、各人の年金額全体を、チェーンと本人の文書から再計算できる。
6. **死亡と未届の死亡。** 届出済みの死亡では`ResidentLink`がburnされるので、支払いは自動的にrevertする。死亡時に未払いの年金(未支給年金)は、遺族のアドレスへの通常の支払いとする。未届の死亡はオフチェーンの問題(現況確認)のままだが、年金を受け取るのにまったく使われないアドレスや、使い方が急に変わったアドレスは、オフチェーン分析で検知できる。オンチェーンの仕組みは作らない。
7. **雇用主による逃れ。** オフチェーンで検出する: `EmployeeID`保有者に給与を払っている法人で、その従業員が厚生年金の保険料を払っていない(3(a)の場合)、あるいは見えている給与から想定されるより少ない額しか払っていない場合。3(a)なら、保険料はそれ自体オンチェーンにある給与から計算されるので、報酬の過少申告は隠せなくなる。

### ステータス

ユーザーの回答待ち。

---

## Round 2 — 2026-11-07(ユーザー＋Claude)

### ユーザーの決定

論点1、2、4〜7は**提案どおり**。論点2は**(A)**で新しいコントラクトは作らない。論点3は**(a)**で、従業員が自分の`ResidentLink`アドレスから全額を払い、雇用主負担分は額面の給与に上乗せする。

### 仕様を書く際に加えた調整(確認待ち)

- **受け取る国庫は2つ。** 年金特別会計に、国民年金用と厚生年金用の2つの`PublicTreasury`を置く(現在の国民年金勘定と厚生年金勘定に対応)。単純な送金にはメモが付かないので、「送信元アドレス＋受け取る国庫」の組で、誰の、どちらの制度への保険料かがわかる。
- **何月分に充てるかは法律で固定する: 未納の最も古い月から。** 送金はどの月の分かを示さない(2年までの後納や前納がある)。ルールを固定すれば、誰でも送金から同じ月ごとの記録を計算でき、年金を扱う機関がずれうる別の台帳を持つ必要がない。
- **裁定もアンカリングする。** 免除(論点5)と同じくハッシュで。本人は、自分のオンチェーンの保険料とアンカーされた決定から計算を確認できる。
- **年金給付の予算コードは1つにする。** 老齢・遺族・障害年金を同じ予算コードで支払い、支払いから受給者が障害者や遺族であることがわからないようにする。年金の種類はアンカーされた非公開の決定に記載する。機関は監査のため種類ごとの合計をオフチェーンで公表する。
- **保険料を払わない従業員は第1号の滞納と同じに扱う**(督促、その後は[ADR 0018](../../decisions/0018-judiciary-model.md)の既存のアドレス特定の経路による強制徴収)。源泉徴収のもとでは起こらなかったことで、選択肢(a)のコストである。

### ステータス

すべての論点が解決。仕様を作成([`README.md`](README.md))。ADR: [0024](../../decisions/0024-pension-model.md)。5つの調整はユーザーの確認待ち。

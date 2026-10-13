# Discussion Log: Political donations

Records the back-and-forth on this feature's design, in order. See [`docs/state-design/citizenship/discussion-log.md`](../citizenship/discussion-log.md) for the format this follows.

---

## Round 1 — 2026-10-13 (Claude)

### On-chain value test ([ADR 0014](../../decisions/0014-legislative-process-scope.md))

Passes on every question. Q1: real fraud (the 2023–24 faction party-ticket slush-fund scandal). Q2: politicians keep their own books. Q3: the gap is traceability. Q4: income/expenditure reports (政治資金収支報告書) exist, but they are paper, delayed, and self-reported. Q5: joins with `ResidentLink`, corporate registration, and stablecoin payments.

### Issues raised before writing the spec

1. **(Foundational) Who is a recipient?** Parties, political fund-raising bodies (政治資金団体), and legislators' fund-management bodies (資金管理団体) must be registered on-chain. Proposal: a "political organization registration NFT" issued by the election board, in the same shape as corporate registration ([ADR 0005](../../decisions/0005-corporate-registration-model.md)). Representative names and affiliated legislators are public, following ADR 0012's open-information principle for VIPs.
2. **(Foundational) Receipts outside the chain.** A contract cannot physically stop a cash hand-off. Proposal: a political organization may legally receive funds **only** by on-chain transfer to its registered address. Spending also goes out from that address, so both income and expenditure become public automatically, and any spending not explained by on-chain income is suspicious by construction.
3. **Donor privacy.** ADR 0012 gives individuals strong privacy, and corporations and VIPs open information. Current law publishes the names of donors giving more than ¥50,000 a year. Proposal: corporate donors are always public; small individual donations show only the `ResidentLink` address, and name disclosure applies above a threshold.
4. **Enforce limits and prohibitions in a contract?** Rules include annual caps, corporations donating to parties only, and the ban on foreign donations. Taxation used no dedicated contract ([ADR 0004](../../decisions/0004-taxation-payment-rail.md)). Enforcing these rules needs one. Proposal: a dedicated contract that checks `ResidentLink` and corporate registration and rejects violating donations at the point of transfer.
5. **Party tickets (パーティー券).** The scandal's vector was ticket revenue being classed as "not a donation", with looser disclosure. Proposal: every inflow to a political organization goes through the same rail, whatever it is called.
6. **Legislators' roll-call vote records** (added by ADR 0014). Who records them, and how legislators are linked to their fund-management bodies' addresses.

### Status

Awaiting the user's response, especially to the foundational Issues 1 and 2.

---

## Round 2 — 2026-10-13 (Claude + user)

### User's response

- Issues 1, 2, 3, 5: **accepted** as proposed.
- Issue 4: the user wants the **receiving side to be required to use a dedicated contract**. A purpose-built political-donation receiving contract is provided, and receipt caps and other required conditions are checked inside it. The user asked whether this is feasible.
- Issue 6: the user asked for a more detailed explanation.

### Claude's response on Issue 4: feasible, with four sub-issues

Feasible. Each registered political organization's receiving address *is* a fund contract, deployed from a single factory by the election board at registration time, so every organization runs the same audited code. Donations enter through `donate()`, which checks donor eligibility and caps, then pulls the stablecoin via `transferFrom`. Spending leaves via a function callable only by the organization's registered representative(s).

Sub-issues that must be settled:

- **4a. Caps that span recipients.** Current law also caps a donor's *total* across all recipients, not only per recipient. A per-organization contract cannot see donations to other organizations. Proposal: one shared `DonationLedger` contract that every fund contract calls to record donations and check per-donor, per-year totals; the funds themselves stay in the per-organization contracts.
- **4b. Direct transfers bypass `donate()`.** ERC-20 has no receive hook, so anyone can call `stablecoin.transfer(fundContract, x)` directly and skip all checks. This cannot be prevented, but it can be neutralized. Proposal: the contract tracks an `accountedBalance` (the sum received via `donate()`), and spending is allowed only up to it. Any excess is "unaccounted" funds that cannot be spent and can only be returned or forfeited to the treasury through a public, logged function.
- **4c. The foreign-donation ban needs a nationality signal that does not exist on-chain.** `ResidentLink` is nationality-neutral ([ADR 0003](../../decisions/0003-resident-link-identity-model.md)), and nationality is verified off-chain ([ADR 0006](../../decisions/0006-passport-credential.md)). Voting solved this with per-election eligibility grants from the election board ([ADR 0013](../../decisions/0013-voting-model.md)), but no *standing* "eligible to donate" flag exists. A similar question exists for foreign-controlled corporations, since corporate registration does not record ownership.
- **4d. "Per year" needs a date.** Annual caps require deriving the year from `block.timestamp`: a second justified on-chain date exception after the voting period.

### Claude's explanation of Issue 6

What it is: for each bill, a public record of how each individual legislator voted (yes / no / abstain / absent). Today, many local assemblies vote by standing, so this record does not exist.

Pieces to design:

- **Who records the vote.** (a) The assembly secretariat posts the per-member result; or (b) each legislator signs their own vote from their own address; or (c) legislators vote on an electronic device that signs, and the secretariat finalizes. Option (b)/(c) is non-repudiable: a legislator cannot later claim they were mis-recorded. The House of Councillors already uses push-button electronic voting.
- **Legislator identity.** A "seat" credential issued by the election board when an election result is certified, which connects naturally to the voting design. Legislators are VIPs, so name ↔ address is public.
- **Link to money.** The legislator's fund-management body's fund contract registers that legislator as representative, so "donations into X's fund" and "X's votes" join on-chain.
- **Bill anchor.** Each recorded vote needs a bill identifier and text hash. This is the only sliver of the excluded legislative core that is needed.
- **What stays off-chain.** Judging which bills "benefit" which donor is analysis by journalists and citizens, not contract logic.
- **Caveats.** Party discipline (党議拘束) means most members vote with their party, so much of the signal is at party level. Some assembly votes are legally secret (e.g. electing the speaker); those would use the voting primitive, not roll call.

### Status

Awaiting the user's decisions on 4a–4d and on Issue 6's recording method.

---

## Round 3 — 2026-10-13 (user + Claude)

### User's decisions

- **4a. Caps spanning recipients: no shared ledger.** Every donation is already recorded on-chain, so cross-recipient totals can be checked by aggregating that data after the fact. Each fund contract enforces only its own per-recipient cap; total caps are an **after-the-fact audit** item.
- **4b. Direct transfers: accepted.** Spending is limited to `accountedBalance`. Unaccounted funds can only be returned or forfeited to the treasury.
- **4c. Foreign-donation ban: after-the-fact audit**, not enforced in the contract. No standing "eligible to donate" credential is created, and the deferred nationality credential stays deferred.
- **4d. Year derived from `block.timestamp`: accepted** as the second justified on-chain date exception.
- **Issue 6. Legislators' roll-call records: not on-chain.** The user judged that this can be handled off-chain (consistent with value-test Q3: it is fixable by institutional rule alone). This reverses the roll-call part of [ADR 0014](../../decisions/0014-legislative-process-scope.md). It will be recorded as a partial supersession in this feature's ADR.

### Resulting enforcement split

| Rule | Where it is enforced |
|---|---|
| Donor is identifiable (`ResidentLink` holder or registered corporation) | In the contract |
| Corporations may donate to parties only | In the contract |
| Per-recipient annual cap | In the contract |
| Spending limited to accounted funds | In the contract |
| Total annual cap across recipients | After-the-fact audit of on-chain data |
| Foreign individuals / foreign-controlled corporations banned | After-the-fact audit |

### Remaining question raised by Claude

Issue 3 agreed that individual donors' names are disclosed above a threshold, but no mechanism was fixed: `ResidentLink` carries no name. Options: (a) the donor declares their name in `donate()` once their annual total to that recipient crosses the threshold, and the contract rejects the donation without it (false declarations are an audit offense); (b) the political organization reports names off-chain, keyed by transaction hash; (c) no on-chain names at all; investigators request the address → person mapping from the municipality.

### Status

Awaiting the user's choice on the name-disclosure mechanism; then the spec and ADR can be written.

---

# 議論ログ: 政治献金(日本語)

この機能の設計に関するやり取りを順番に記録します。形式は [`docs/state-design/citizenship/discussion-log.md`](../citizenship/discussion-log.md) に従います。

---

## Round 1 — 2026-10-13(Claude)

### オンチェーン価値テスト([ADR 0014](../../decisions/0014-legislative-process-scope.md))

すべての問いを満たす。問1: 実際の不正(2023〜24年の派閥パーティー券裏金事件)。問2: 政治家が自分で帳簿をつけている。問3: 問題は追跡可能性の欠落。問4: 政治資金収支報告書はあるが、紙で、遅く、自己申告である。問5: `ResidentLink`、法人登記、ステーブルコイン決済と結合できる。

### 仕様作成前に提起する論点

1. **(土台)受け取る側は誰か。** 政党、政治資金団体、資金管理団体をオンチェーンで登録する必要がある。提案: 法人登記([ADR 0005](../../decisions/0005-corporate-registration-model.md))と同じ形で、選挙管理委員会が発行する「政治団体登録NFT」を作る。ADR 0012の「要人の情報は公開」という原則に従い、代表者名や所属議員は公開する。
2. **(土台)オンチェーン以外の受け取り。** コントラクトで現金の手渡しを物理的に止めることはできない。提案: 政治団体が資金を受け取ってよいのは、登録アドレスへのオンチェーン送金**だけ**とする。支出もそのアドレスから行うので、収入と支出の両方が自動で公開され、オンチェーンの収入で説明できない支出は、それだけで疑わしいと分かる。
3. **献金者のプライバシー。** ADR 0012では、個人のプライバシーは強く、法人と要人は公開である。現行法では年5万円を超える献金者の氏名が公開される。提案: 法人の献金は常に公開する。個人の少額献金は`ResidentLink`アドレスのみとし、一定額を超えたら氏名まで公開する。
4. **上限・禁止ルールをコントラクトで強制するか。** 年間上限、法人は政党にのみ献金可、外国人献金の禁止などのルールがある。納税は専用コントラクトなしだった([ADR 0004](../../decisions/0004-taxation-payment-rail.md))が、これらを強制するには専用コントラクトが必要になる。提案: `ResidentLink`と法人登記を照会し、違反する献金を送金時点で拒否する専用コントラクトを置く。
5. **パーティー券。** 裏金事件の原因は、券の売上が「献金ではない」扱いで、公開基準も緩かったことである。提案: 名目を問わず、政治団体に入るお金はすべて同じ仕組みを通す。
6. **議員の記名採決記録**(ADR 0014で追加)。誰が記録するか、議員と資金管理団体のアドレスをどう結びつけるか。

### ステータス

ユーザーの回答待ち。特に土台となる論点1・2。

---

## Round 2 — 2026-10-13(Claude + ユーザー)

### ユーザーの回答

- 論点1・2・3・5: 提案どおり**了承**。
- 論点4: **受け取る側に専用コントラクトの使用を義務づけたい**。政治献金を受け取る専用コントラクトを用意し、受け取り上限や必要な条件のチェックをその中で行う。実現可能かを質問。
- 論点6: より詳しい説明を求めた。

### 論点4へのClaudeの回答: 実現可能。ただし4つの小論点がある

実現可能である。登録された政治団体の受け取りアドレスそのものを資金コントラクトにする。登録時に選挙管理委員会が単一のファクトリーからデプロイするので、すべての団体が同じ監査済みコードで動く。献金は`donate()`経由で受け付け、献金者の資格と上限を確認してから`transferFrom`でステーブルコインを引き取る。支出は、団体の登録代表者だけが呼べる関数から行う。

決める必要がある小論点:

- **4a. 受取先をまたぐ上限。** 現行法には受取先ごとの上限だけでなく、献金者の全受取先への*合計*上限もある。団体ごとのコントラクトからは他団体への献金が見えない。提案: 共有の`DonationLedger`コントラクトを1つ置き、すべての資金コントラクトがそこに献金を記録し、献金者ごと・年ごとの合計を確認する。資金そのものは各団体のコントラクトに置く。
- **4b. `donate()`を迂回する直接送金。** ERC-20には受け取り時のフックがないため、誰でも`stablecoin.transfer(fundContract, x)`を直接呼んでチェックを迂回できる。これは防げないが、無害化できる。提案: `donate()`経由で受け取った合計を`accountedBalance`として管理し、支出はその範囲内に限る。超過分は「出所不明の資金」として使えず、公開・記録される関数で返金するか国庫に没収することしかできない。
- **4c. 外国人献金の禁止には、オンチェーンに存在しない国籍情報が必要。** `ResidentLink`は国籍中立であり([ADR 0003](../../decisions/0003-resident-link-identity-model.md))、国籍はオフチェーンで確認する([ADR 0006](../../decisions/0006-passport-credential.md))。投票では選挙管理委員会による選挙ごとの資格付与で解決した([ADR 0013](../../decisions/0013-voting-model.md))が、*継続的な*「献金資格」フラグは存在しない。外資支配の法人についても同じ問題がある。法人登記は株主構成を記録していないためである。
- **4d. 「年間」には日付が必要。** 年間上限を確認するには、`block.timestamp`から年を求める必要がある。投票期間に続く、2つ目の正当化されたオンチェーン日付の例外になる。

### 論点6のClaudeによる説明

これは、議案ごとに各議員がどう投票したか(賛成/反対/棄権/欠席)を公開記録することである。現在、多くの地方議会は起立採決のため、この記録が存在しない。

設計すべき部分:

- **誰が記録するか。** (a) 議会事務局が議員ごとの結果を記録する、(b) 各議員が自分のアドレスから自分の票に署名する、(c) 議員は署名機能付きの電子端末で投票し、事務局が確定させる。(b)/(c)は否認できない。議員が後から「誤って記録された」と主張できない。参議院はすでに押しボタン式の電子投票を使っている。
- **議員の本人性。** 選挙結果の確定時に選挙管理委員会が発行する「議席」証明。投票設計と自然につながる。議員は要人なので、氏名とアドレスの対応は公開する。
- **お金との結びつけ。** 議員の資金管理団体の資金コントラクトに、その議員を代表者として登録する。これで「Xの資金への献金」と「Xの投票」がオンチェーンで結合できる。
- **議案の識別。** 記録する票ごとに、議案IDと条文ハッシュが必要になる。対象外とした立法本体のうち、必要なのはこの部分だけである。
- **オフチェーンに残すもの。** どの議案がどの献金者の利益になるかの判断は、記者や市民による分析であり、コントラクトのロジックではない。
- **注意点。** 党議拘束があるため、多くの議員は党の方針どおりに投票し、意味のある情報の多くは政党単位になる。一部の議会内投票(議長選挙など)は法律上無記名であり、記名採決ではなく投票プリミティブを使う。

### ステータス

4a〜4dと、論点6の記録方法についてのユーザーの判断待ち。

---

## Round 3 — 2026-10-13(ユーザー + Claude)

### ユーザーの決定

- **4a. 受取先をまたぐ上限: 共有台帳は置かない。** すべての献金はすでにオンチェーンに記録されているので、受取先をまたぐ合計は事後に集計すれば確認できる。各資金コントラクトは自団体への上限だけを強制し、合計上限は**事後監査**の対象とする。
- **4b. 直接送金: 了承。** 支出は`accountedBalance`の範囲内に限る。出所不明の資金は返金か国庫への没収しかできない。
- **4c. 外国人献金の禁止: 事後監査**とし、コントラクトでは強制しない。継続的な「献金資格」の証明は作らず、保留中の国籍証明も引き続き保留とする。
- **4d. `block.timestamp`から年を求める: 了承。** 2つ目の正当化されたオンチェーン日付の例外とする。
- **論点6. 議員の記名採決記録: オンチェーン化しない。** ユーザーは、これはオフチェーンでも対応可能と判断した(価値テストの問3「制度のルールだけでも直せる」と整合する)。これは[ADR 0014](../../decisions/0014-legislative-process-scope.md)の記名採決の部分を覆すもので、この機能のADRで部分的な上書きとして記録する。

### 強制の分担

| ルール | 強制する場所 |
|---|---|
| 献金者が特定可能(`ResidentLink`保有者または登記済み法人) | コントラクト内 |
| 法人は政党にのみ献金可 | コントラクト内 |
| 受取先ごとの年間上限 | コントラクト内 |
| 支出は記録済み資金の範囲内 | コントラクト内 |
| 受取先をまたぐ年間合計上限 | オンチェーンデータの事後監査 |
| 外国人・外資支配法人の献金禁止 | 事後監査 |

### Claudeが提起した残りの論点

論点3で「個人献金者は一定額を超えたら氏名を公開する」と合意したが、その仕組みは決めていない。`ResidentLink`は氏名を持たない。選択肢: (a) その受取先への年間合計が基準を超える時点で、献金者が`donate()`で氏名を申告し、申告がなければコントラクトが献金を拒否する(虚偽申告は監査で処罰)、(b) 政治団体がトランザクションハッシュと紐づけてオフチェーンで氏名を報告する、(c) オンチェーンには氏名を一切載せず、捜査機関が市区町村にアドレスと人物の対応を照会する。

### ステータス

氏名公開の仕組みについてユーザーの選択待ち。その後、仕様とADRを作成する。

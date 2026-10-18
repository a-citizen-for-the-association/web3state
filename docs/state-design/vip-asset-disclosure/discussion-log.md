# Discussion Log: VIP / politician asset disclosure (要人の資産公開)

Records the back-and-forth on this feature's design, in order. See [`docs/state-design/citizenship/discussion-log.md`](../citizenship/discussion-log.md) for the format this follows. The user chose the Political Transparency category; this item is taken first, then procurement and subsidies.

---

## Round 1 — 2026-10-18 (Claude)

### Background: the current system

Under the Diet members' asset disclosure law (1992), members file an asset report on taking office and annual income and related-company reports. Anyone may ask the Speaker to inspect or copy them. Ministers, governors, mayors and local legislators have similar rules by code or ordinance.

Known weaknesses:
- **Ordinary and current deposits are excluded** from the deposits that must be reported, which is where most cash sits.
- The reports are **self-declared** and **not verified**. Proposals to add penalties for false or missing reports have been made, but no penalty clause appears in the current text.
- The reports are snapshots on paper, available on request, not a continuous record.

### What this project already has

- Legislators' `ResidentLink` addresses are **already public**: activity expenses and pay are paid to them from public treasuries ([ADR 0019](../../decisions/0019-treasury-model.md)), and the assembly publishes which address is whose.
- Every stablecoin balance and flow on that address is therefore **already visible**, continuously, to anyone.
- Donations reach legislators through their fund-management body's `PoliticalFund` ([ADR 0015](../../decisions/0015-political-donations-model.md)); corporate officer names are public ([ADR 0005](../../decisions/0005-corporate-registration-model.md)).

### On-chain value test ([ADR 0014](../../decisions/0014-legislative-process-scope.md)), sub-part by sub-part

| Sub-part | Q1 problem | Q2 keeper | Q3 technical | Q4 no record | Q5 combination | Result |
|---|---|---|---|---|---|---|
| **On-chain assets** (stablecoin balances and flows) | **Yes**: deposits excluded, self-declared, unverified | **Yes**: the VIP reports on themself | **Yes**: holdings on a known address are verifiable by anyone | **Yes**: no continuous record today | **Strong**: treasury pay, donations, corporate officers | **Candidate, mostly already done** |
| **Other addresses the VIP controls** | **Yes**: the obvious evasion is a second, undeclared address | Yes | Partial: whether an address is "theirs" is a declaration | Yes | Strong | **Candidate** (declaration, Issue 2) |
| Off-chain assets (real estate, securities, cash, accounts at banks) | Yes | Yes | **No** for now: not on-chain | Partial: current reports | Weak until the real estate registry exists | Keep current reports off-chain; revisit with the real estate registry |
| Family members' assets | Yes: moving assets to a spouse is the classic evasion | Yes | Partial | Partial | Moderate | Decision needed (Issue 4) |
| Income and gifts | Partial | — | Yes for on-chain income | Partial | Strong | Mostly covered by on-chain flows |

### Proposal in line with "off-chain if it can be" ([ADR 0019](../../decisions/0019-treasury-model.md))

**No new contract.** On-chain assets are already public on a published address. An off-chain application can show any VIP's balance, income and spending over time. The design only needs rules about **which addresses** count.

### Issues raised

1. **Who is a VIP.** Proposal: national and local legislators, heads of government (governors, mayors), ministers and vice-ministers. Senior civil servants (e.g. vice-ministers of ministries, 事務次官)?
2. **Declaring all controlled addresses.** A VIP must declare every address they control, and prove control by signing a message from each (verifiable by anyone off-chain). Published off-chain by the assembly or office, like the `ResidentLink` mapping. An undeclared address later found to be theirs (by chain analysis) is the violation that off-chain checks look for.
3. **Off-chain assets.** Keep the current reports (with ordinary deposits **included**, since this is a thought experiment), published online. Revisit real estate when the real estate registry is designed.
4. **Family.** Extend the address declaration to spouse and dependants? It closes the classic evasion, but exposes people who did not run for office.
5. **After leaving office.** Keep the declared addresses public for some years after leaving office (to catch post-office windfalls), or stop at the end of the term?

### Status

Awaiting the user's response.

---

## Round 2 — 2026-10-18 (user + Claude)

### User's decisions

- **Issue 1:** civil servants are **not** VIPs. VIPs are legislators (national and local), heads of government, ministers and vice-ministers.
- **Issue 2 → a new premise.** Receiving income at, or receiving funds from, an address **not linked to a `ResidentLink`** is illegal. The user also wants to consider a technical rule: the FSA-licensed JPY stablecoin, when sent to any address the state has not certified (anything other than a `ResidentLink` holder, a corporate contract, or a national/local public contract), is **forcibly moved to the treasury**.
- **Issue 3:** off-chain assets are checked and managed thoroughly. Apart from cash, the user intends nearly all assets to be managed on-chain (to be designed later). **An omitted declaration is punished severely**, e.g. permanent exclusion from politics.
- **Issue 4:** family members are **not** required to declare.
- **Issue 5:** after leaving office, the person **switches to a new `ResidentLink` address**, ending public monitoring.

### Claude's analysis of the certified-address stablecoin rule

This is a project-wide premise, not a VIP-only rule. It changes the payment rail ([ADR 0004](../../decisions/0004-taxation-payment-rail.md)) and reaches every design that holds money. It is technically feasible, because a stablecoin contract can check the recipient on every transfer. Points to settle:

- **S1. Confiscate or reject.** Rejecting (reverting) the transfer achieves the same goal (money never reaches an uncertified address) without seizing anything, and a typo costs nothing. Confiscation adds a deterrent, but needs a state power to move funds inside the stablecoin.
- **S2. Addresses that lose certification.** `ResidentLink` is burned on a move (and reissued by the new municipality), on death, and on key loss (reissued to a new address); corporations dissolve. Under a "send to uncertified = confiscate" rule, salary arriving during a move's gap would be seized, and a deceased person's balance would bypass inheritance. These need a defined treatment (freeze, authority-mediated transfer, or sweep).
- **S3. Conflict with ADR 0018.** The judiciary rejected giving the court power over wallets inside the stablecoin. Confiscation (S1) or authority-mediated moves (S2) put exactly that kind of power into the stablecoin. This needs to be decided consistently.
- **S4. Lookup.** A stablecoin cannot check ~1,700 municipal `ResidentLink` contracts per transfer. It needs **one aggregated certified-address list** (an extension of `OfficialContractRegistry`) that identity contracts update on mint and burn.
- **S5. Which contracts count.** Every contract that holds money (`PublicTreasury`, `PoliticalFund`, corporate multisigs, and future escrow or crowdfunding contracts) must be registered. Unregistered smart contracts (e.g. DeFi) cannot hold the stablecoin at all.
- **S6. People without a `ResidentLink`.** Tourists, non-residents and foreign businesses cannot hold the stablecoin at all. They would need cash or a certified gateway (a bank or exchange, which is a registered corporation).
- **S7. Other assets.** The rule binds only the JPY stablecoin. The native gas token, foreign stablecoins and other tokens can still move to uncertified addresses; only the law (off-chain) covers them.
- **S8. Issue 5 and visible links.** Moving the balance from the old, public address to the new one is itself an on-chain transfer, so anyone can follow it and keep watching the new address. Either accept that, or define a way of switching that does not create a direct visible link.

### Status

Awaiting the user's response to S1–S8.

---

## Round 3 — 2026-10-18 (user + Claude)

### User's decisions

- **S1: reject.** A transfer to an uncertified address reverts; nothing is confiscated.
- **S2: successor procedures in the contract.** After a move, a key loss or a death, the next address is always determined (the new address, or the heirs). The procedure that moves the balance to it is done through the contract.
- **S3:** the user asked for a fuller explanation.
- **S4: one aggregated certified-address list.**
- **S5: accepted.** Every money-holding contract must be registered. For tourists and other special cases, a **temporary, non-`ResidentLink` method** will be designed, limited in **duration** and in **maximum balance**, so that it cannot become a channel for crime.
- **S6/S7:** accepted. Holding foreign stablecoins is in itself grounds for **enhanced monitoring**, and domestic payment use of foreign stablecoins that do not implement this rule is **prohibited** (law, off-chain).
- **S8: accepted.** Being a politician demands that level of commitment, which should also discourage people who only want to profit from office.

### Claude's explanation of S3

ADR 0018 rejected option (a): a court order that the stablecoin itself executes, moving money out of a debtor's wallet. The reason was that the stablecoin would then contain a function that moves funds **out of an address without the owner's signature**, and that power could reach every wallet.

S2 needs a function of exactly that technical kind. After a key loss or a death, nobody can sign for the old address, so an authority (the municipality, or the inheritance procedure) must move the balance without the owner's signature.

The two are compatible if the power is narrowed. Proposal: the forced move works **only on an address that has lost its certification** (its `ResidentLink` burned), and **only to the certified successor address(es)** recorded by the procedure. An active, certified address can never be touched, so ADR 0018's concern (power over living people's wallets) still holds, and judgment enforcement stays off-chain.

### Status

Awaiting the user's confirmation of the S3 narrowing.

---

## Round 4 — 2026-10-18 (user + Claude)

### User's decision

The narrowing is accepted, and the user added the procedure for key loss. The person reports to the municipality. Moving the balance must be **so complicated and tedious that criminals would not want to attempt it**: the municipality certifies the case, examines the address's past incoming and outgoing transfers for anything suspicious, and only if a **court** approves can a **multisig** execute the forced move.

### Adjustments made while writing the specs (flagged for review)

- **Public waiting period and owner veto.** After approval, the move waits for a public timelock period. During it, the old address itself can cancel the move by signing. This stops the main attack, in which someone impersonates a victim at the office and claims a "lost key" to redirect the victim's money: the real owner still holds the key and can veto.
- **Death uses the same heavy path,** with the successors (heirs and shares) fixed by the inheritance procedure.
- **A light path when the owner still holds the key.** Switching to a new address after leaving office (Issue 5), or any voluntary address change, is signed by the old address and confirmed by the municipality; no court and no waiting period. The heavy path is only for moves *without* the owner's signature.
- **Senders are checked too.** Both sender and recipient must be certified. A decertified address (e.g. during a move's gap) is therefore frozen until it is certified again or its balance is migrated. This also enforces the legal premise that receiving funds from an uncertified address is illegal.
- **Visitor pass defaults.** The pass is issued by the Immigration Services Agency at entry. Its duration and balance cap are legal parameters held in the registry. Handling a balance left when a pass expires is left to the backlog.
- **The VIP declaration shrinks.** Uncertified addresses cannot hold the JPY stablecoin, and each person has exactly one `ResidentLink` address. So a VIP's on-chain declaration is just that address; corporate roles are already public. What remains to declare is off-chain assets (including ordinary deposits) and any non-JPY tokens.

### Status

All issues resolved. Specs written: [`README.md`](README.md) and [`../certified-stablecoin/README.md`](../certified-stablecoin/README.md). ADRs: [0020](../../decisions/0020-certified-address-stablecoin.md), [0021](../../decisions/0021-vip-asset-disclosure.md).

---

## Round 5 — 2026-10-18 (user + Claude)

- Round 4 adjustments 1–5 **confirmed**. On adjustment 6 (the declaration shrinks), the user asked for an explanation.
- Claude explained it, and raised a remaining gap: a corporation the VIP **controls as a shareholder** (with relatives or associates as officers) can hold JPY at its own certified address, unlinked to the VIP on-chain. Bribes can arrive as "consulting fees", the company can pay the VIP's living costs, public contracts can be steered to it, and wealth can accumulate there until after office.
- **Decision: option (a).** For now, shareholdings are an off-chain asset to declare, and omission is punished severely. The user intends to put **real estate and securities on-chain** later; once shareholdings are on-chain, the link from the VIP's address to the controlled corporation becomes visible and the gap mostly closes (borrowed-name shareholdings remain an off-chain matter). Recorded in [`docs/BACKLOG.md`](../../BACKLOG.md), and a new 🔴 item "Securities / shareholdings" was added to [`docs/FEATURES.md`](../../FEATURES.md).

---

# 議論ログ: 要人の資産公開(日本語)

この機能の設計に関するやり取りを順に記録する。形式は[`docs/state-design/citizenship/discussion-log.md`](../citizenship/discussion-log.md)に従う。ユーザーは「政治の透明性」のカテゴリを選んだ。この項目を最初に扱い、次に公共調達、補助金の順とする。

---

## Round 1 — 2026-10-18(Claude)

### 前提: 現行制度

国会議員の資産公開法(1992年)により、議員は就任時に資産等報告書を、毎年所得等報告書と関連会社等報告書を提出する。誰でも議長に閲覧や写しの交付を請求できる。大臣、知事、市長、地方議員にも、規範や条例で同様の仕組みがある。

知られている弱点:
- 報告すべき預金から**普通預金と当座預金が除外**されている。現金の大半はここにある。
- 報告は**自己申告**で、**検証されない**。虚偽報告や不提出に罰則を加える改正案は出されてきたが、現行の条文に罰則の規定は見当たらない。
- 報告は紙のスナップショットで、請求すれば見られるが、継続的な記録ではない。

### このプロジェクトにすでにあるもの

- 議員の`ResidentLink`アドレスは**すでに公開されている**: 政務活動費や報酬が公的な国庫から支払われ([ADR 0019](../../decisions/0019-treasury-model.md))、どのアドレスが誰のものかを議会が公表する。
- したがって、そのアドレス上のステーブルコインの残高と流れは、**すでに誰でも継続的に見られる**。
- 議員への献金は資金管理団体の`PoliticalFund`を通る([ADR 0015](../../decisions/0015-political-donations-model.md))。法人の役員名は公開されている([ADR 0005](../../decisions/0005-corporate-registration-model.md))。

### オンチェーン価値テスト([ADR 0014](../../decisions/0014-legislative-process-scope.md))の部分ごとの適用

| 部分 | 問1 問題 | 問2 管理者 | 問3 技術 | 問4 記録なし | 問5 組み合わせ | 結果 |
|---|---|---|---|---|---|---|
| **オンチェーンの資産**(ステーブルコインの残高と流れ) | **はい**: 預金の除外、自己申告、検証なし | **はい**: 要人が自分について報告する | **はい**: 既知のアドレスの保有は誰でも検証できる | **はい**: 現在は継続的な記録がない | **強い**: 国庫からの報酬、献金、法人役員 | **候補。ほぼ実現済み** |
| **要人が管理する他のアドレス** | **はい**: 申告しない第2のアドレスが最も分かりやすい抜け道 | はい | 一部: アドレスが「本人のもの」かは申告による | はい | 強い | **候補**(申告、論点2) |
| オフチェーンの資産(不動産、有価証券、現金、銀行口座) | はい | はい | 当面**いいえ**: オンチェーンにない | 一部: 現行の報告書 | 不動産登記ができるまでは弱い | 現行の報告はオフチェーンのまま。不動産登記の設計時に見直す |
| 家族の資産 | はい: 配偶者に資産を移すのが典型的な抜け道 | はい | 一部 | 一部 | 中程度 | 判断が必要(論点4) |
| 所得と贈与 | 一部 | — | オンチェーンの所得ははい | 一部 | 強い | オンチェーンの流れでほぼ網羅される |

### 「オフチェーンでできることはオフチェーンで」([ADR 0019](../../decisions/0019-treasury-model.md))に沿った提案

**新しいコントラクトは作らない。** オンチェーンの資産は、公表されたアドレス上ですでに公開されている。オフチェーンのアプリケーションで、どの要人の残高・収入・支出も時系列で示せる。設計で決める必要があるのは、**どのアドレスを対象とするか**のルールだけである。

### 提起した論点

1. **誰が要人か。** 提案: 国会議員と地方議員、首長(知事、市区町村長)、大臣と副大臣。上級公務員(事務次官など)も含めるか?
2. **管理するすべてのアドレスの申告。** 要人は自分が管理するすべてのアドレスを申告し、各アドレスからメッセージに署名して管理していることを証明する(誰でもオフチェーンで検証できる)。`ResidentLink`の対応と同じく、議会や役所がオフチェーンで公表する。後に(チェーンの分析で)本人のものと判明した未申告のアドレスが、オフチェーンのチェックが探す違反になる。
3. **オフチェーンの資産。** 現行の報告は残す(思考実験なので普通預金も**含める**)。オンラインで公表する。不動産は不動産登記の設計時に見直す。
4. **家族。** アドレスの申告を配偶者と扶養家族にも広げるか?典型的な抜け道は塞げるが、立候補していない人を公開することになる。
5. **退任後。** 申告したアドレスを退任後も数年間公開し続けるか(退任後の不自然な収入を見つけるため)、任期の終わりで止めるか?

### ステータス

ユーザーの回答待ち。

---

## Round 2 — 2026-10-18(ユーザー + Claude)

### ユーザーの決定

- **論点1:** 公務員は要人に**含めない**。要人は、議員(国・地方)、首長、大臣と副大臣。
- **論点2 → 新しい前提。** **`ResidentLink`と結びついていないアドレス**で所得を受け取ること、またはそうしたアドレスから資金を受け取ることは違法とする。ユーザーはさらに技術的なルールも検討したい: 金融庁が認可する円建てステーブルコインは、国家が認定していないアドレス(`ResidentLink`の保有者、法人のコントラクト、国・自治体が管理するコントラクト以外)に送られた場合、**国庫などに強制的に移転される**。
- **論点3:** チェーン外の資産は徹底して確認・管理する。ユーザーは、現金を除き、ほぼすべての資産をオンチェーンで管理するつもりである(後で設計する)。**申告漏れには厳罰**を科す。たとえば政治の世界から永久に追放する。
- **論点4:** 家族には申告を**求めない**。
- **論点5:** 退任後は**新しい`ResidentLink`アドレスに切り替える**ことで、公開の監視を終える。

### 認定アドレス制のステーブルコインについてのClaudeの分析

これは要人だけのルールではなく、プロジェクト全体の前提である。決済レール([ADR 0004](../../decisions/0004-taxation-payment-rail.md))を変え、お金を扱うすべての設計に及ぶ。ステーブルコインのコントラクトは送金ごとに受取人を確認できるので、技術的には実現できる。決めるべき点:

- **S1. 没収か拒否か。** 送金を拒否(リバート)すれば、没収せずに同じ目的(お金が認定外のアドレスに届かない)を果たせ、宛先の打ち間違いでも損をしない。没収は抑止力を加えるが、ステーブルコインの中に、資金を動かす国家の権限が必要になる。
- **S2. 認定を失うアドレス。** `ResidentLink`は転居(新しい自治体が再発行する)、死亡、鍵の紛失(新しいアドレスに再発行)でburnされ、法人は解散する。「認定外への送金は没収」のルールでは、転居の空白期間に届いた給与が没収され、死亡した人の残高は相続を経ずに国庫へ行ってしまう。凍結、当局による移転、国庫への回収など、扱いを定める必要がある。
- **S3. ADR 0018との衝突。** 司法の設計では、ステーブルコインの中で裁判所がウォレットに権限を持つことを退けた。没収(S1)や当局による移転(S2)は、まさにその種の権限をステーブルコインに入れることになる。一貫した判断が必要である。
- **S4. 照会の方法。** ステーブルコインは、送金ごとに約1,700の自治体の`ResidentLink`コントラクトを確認することはできない。**認定アドレスを集約した1つの一覧**(`OfficialContractRegistry`の拡張)が必要で、本人確認のコントラクトがmintとburnのたびにそれを更新する。
- **S5. どのコントラクトを認めるか。** お金を持つすべてのコントラクト(`PublicTreasury`、`PoliticalFund`、法人のマルチシグ、今後のエスクローやクラウドファンディングのコントラクト)を登録する必要がある。登録されていないスマートコントラクト(DeFiなど)はステーブルコインを一切保有できない。
- **S6. `ResidentLink`を持たない人。** 旅行者、非居住者、海外の事業者は、ステーブルコインを一切保有できない。現金か、認定された窓口(登記済み法人である銀行や交換業者)が必要になる。
- **S7. 他の資産。** ルールが縛るのは円建てステーブルコインだけである。ガス用のネイティブトークン、外国のステーブルコイン、その他のトークンは、引き続き認定外のアドレスに送れる。それらは法律(オフチェーン)でしか扱えない。
- **S8. 論点5と見える結びつき。** 公開された古いアドレスから新しいアドレスへの残高の移動自体がオンチェーンの送金なので、誰でもたどれ、新しいアドレスを見続けられる。これを受け入れるか、直接の見える結びつきを作らない切り替え方を定めるか。

### ステータス

S1〜S8へのユーザーの回答待ち。

---

## Round 3 — 2026-10-18(ユーザー + Claude)

### ユーザーの決定

- **S1: 拒否。** 認定外のアドレスへの送金はリバートする。没収はしない。
- **S2: 承継の手続きをコントラクトで行う。** 転居、鍵の紛失、死亡のいずれでも、次のアドレス(新しいアドレス、または相続人)は必ず決まる。残高をそこへ移す手続きは、コントラクトを通して行う。
- **S3:** ユーザーはより詳しい説明を求めた。
- **S4: 認定アドレスを集約した1つの一覧を作る。**
- **S5: 了承。** お金を持つすべてのコントラクトは登録が必要。旅行者などの特別な場合には、**`ResidentLink`ではない一時的な方式**を設計する。**期間**と**保有できる残高の上限**を制限し、犯罪の経路にならないようにする。
- **S6/S7:** 了承。外国のステーブルコインを保有すること自体が**監視強化**の対象になり、このルールを実装しない外国のステーブルコインの国内での決済利用は**禁止**する(法律、オフチェーン)。
- **S8: 受け入れる。** 政治家になるにはそれくらいの覚悟が必要であり、利権を得たいだけの人が政治家になることを抑える効果も期待できる。

### S3のClaudeによる説明

ADR 0018は選択肢(a)を退けた。裁判所の命令をステーブルコイン自体が実行し、債務者のウォレットからお金を移すものである。理由は、ステーブルコインの中に**持ち主の署名なしにアドレスからお金を移す**機能ができ、その権限がすべてのウォレットに及びうることだった。

S2には、技術的にまさにその種の機能が必要になる。鍵の紛失や死亡の後は、古いアドレスのために署名できる人がいないので、当局(自治体や相続の手続き)が持ち主の署名なしに残高を移さなければならない。

権限を絞れば両立する。提案: 強制的な移転は、**認定を失ったアドレス**(`ResidentLink`がburnされたもの)に**だけ**働き、手続きで記録された**認定済みの承継先アドレスにだけ**移せる。有効で認定されたアドレスには決して手を出せないので、ADR 0018の懸念(生きている人のウォレットに対する権限)は引き続き守られ、判決の執行もオフチェーンのままとなる。

### ステータス

S3の絞り込みについて、ユーザーの確認待ち。

---

## Round 4 — 2026-10-18(ユーザー + Claude)

### ユーザーの決定

絞り込みを了承し、鍵を紛失した場合の手続きを加えた。本人は役所に申し出る。残高の移転は、**犯罪者が「とてもやりたくない」と思うほど複雑で面倒な処理**を経なければできないようにする。役所が事案を認定し、そのアドレスの過去の着金・送金に疑わしい点がないかを調べ、**裁判所**が認定した場合に限り、**マルチシグ**で強制移転を実行できる。

### 仕様作成時に加えた調整(レビュー対象)

- **公開の待機期間と持ち主の拒否権。** 承認の後、移転は公開の待機期間(タイムロック)を待つ。その間、古いアドレス自身が署名すれば移転を取り消せる。これで主な攻撃を防ぐ。役所で被害者になりすまし、「鍵をなくした」と申し出て被害者のお金を横取りする攻撃である。本当の持ち主は鍵を持っているので拒否できる。
- **死亡も同じ重い手続きを使う。** 承継先(相続人とその持分)は相続の手続きで確定する。
- **持ち主が鍵を持っている場合の軽い手続き。** 退任後の新しいアドレスへの切り替え(論点5)や、任意のアドレス変更は、古いアドレスが署名し、役所が確認する。裁判所も待機期間も要らない。重い手続きは、持ち主の署名*なし*の移転に限る。
- **送金元も確認する。** 送金元と受取人の両方が認定済みでなければならない。そのため認定を失ったアドレス(転居の空白期間など)は、再び認定されるか残高が移されるまで凍結される。これは、認定外のアドレスから資金を受け取ることは違法という法的な前提も強制する。
- **旅行者パスの既定案。** 出入国在留管理庁が入国時に発行する。期間と残高の上限は、レジストリが持つ法定のパラメータとする。パスの期限切れ時に残った残高の扱いはBACKLOGに回す。
- **要人の申告が小さくなる。** 認定外のアドレスは円建てステーブルコインを持てず、各人は`ResidentLink`アドレスをちょうど1つ持つ。したがって要人のオンチェーンの申告はそのアドレスだけになる。法人の役職はすでに公開されている。残る申告は、オフチェーンの資産(普通預金を含む)と、円以外のトークンの保有である。

### ステータス

すべての論点が解決。仕様を作成: [`README.md`](README.md)と[`../certified-stablecoin/README.md`](../certified-stablecoin/README.md)。ADR: [0020](../../decisions/0020-certified-address-stablecoin.md)、[0021](../../decisions/0021-vip-asset-disclosure.md)。

---

## Round 5 — 2026-10-18(ユーザー + Claude)

- Round 4の調整1〜5を**了承**。調整6(申告が小さくなる)について、ユーザーは説明を求めた。
- Claudeが説明し、残る抜け道を提起した: 要人が**株主として支配する法人**(役員は親族や知人)は、自らの認定アドレスに円を持てるが、オンチェーンでは要人と結びつかない。賄賂を「コンサル料」として受け取る、会社が要人の生活費を払う、公共契約をそこへ回す、退任後まで富をそこに貯める、といったことができる。
- **決定: 選択肢(a)。** 当面、株式は申告すべきオフチェーンの資産とし、申告漏れには厳罰を科す。ユーザーは**不動産と有価証券を後でオンチェーン化する**つもりである。株式がオンチェーンになれば、要人のアドレスから支配する法人へのつながりが見えるようになり、抜け道はほぼ塞がる(名義を借りた株式はオフチェーンの問題として残る)。[`docs/BACKLOG.md`](../../BACKLOG.md)に記録し、[`docs/FEATURES.md`](../../FEATURES.md)に新しい🔴項目「有価証券・株主の記録」を追加した。

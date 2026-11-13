# Discussion Log: Securities and shareholdings (有価証券・株主の記録)

Records the back-and-forth on this feature's design, in order. See [`docs/state-design/citizenship/discussion-log.md`](../citizenship/discussion-log.md) for the format this follows.

---

## Round 0 — 2026-11-14 (user)

The last item left by the scope triage ([ADR 0027](../../decisions/0027-remaining-scope-triage.md)). The user started it right after the real estate registry ([ADR 0029](../../decisions/0029-real-estate-registry-model.md)).

Context from earlier discussions ([`docs/BACKLOG.md`](../../BACKLOG.md)):
- **VIP disclosure** ([ADR 0021](../../decisions/0021-vip-asset-disclosure.md)): once shares are on-chain, a VIP's shareholdings, including corporations they control through shares, become visible from their address. The real estate half is done.
- **"Glass-box corporations"** (2026-10-18): the root problem is opacity, not corporations. The design should (1) make layered ownership (corporations owning corporations) traceable on-chain to the final individual, and (2) handle borrowed-name shareholdings by off-chain investigation and severe penalties.
- **Beneficial ownership** ([ADR 0005](../../decisions/0005-corporate-registration-model.md)): the corporate record names officers but not the people who ultimately own the corporation.
- **Foreign-controlled domestic corporations** ([ADR 0029](../../decisions/0029-real-estate-registry-model.md)): the ban on foreign land ownership can be bypassed through a domestic corporation.
- [`docs/FEATURES.md`](../../FEATURES.md): the item is about **recording who holds which shares, not trading**, since [ADR 0012](../../decisions/0012-onchain-scope-philosophy.md) excludes high-frequency trading and personal wealth-accumulation vehicles.

---

## Round 1 — 2026-11-14 (Claude)

### Background: the current situation

- **Listed shares** (about 4,000 companies) have been book-entry only since 2009. Holdings sit in a chain of accounts: the central depository (証券保管振替機構) → securities firms → investors. The issuing company learns its shareholders only at record dates. Holders of 5% or more must file a public large-shareholding report (大量保有報告書).
- **Unlisted companies** (almost all of the roughly 3 million corporations) keep their own shareholder register. It is not public. A list of major shareholders is filed with the Legal Affairs Bureau only when a registration needs a shareholders' resolution (since 2016), and it is not public either.
- **Beneficial owners:** since 2022 the Legal Affairs Bureau keeps a list of beneficial owners (実質的支配者リスト), but filing is **voluntary**. The FATF's 2021 evaluation of Japan criticised the weak transparency of who ultimately owns corporations.
- **Member interests in LLCs** (合同会社の持分) are recorded nowhere public. LLCs are cheap to set up and are often used as shells.

Known problems (the pattern matters more than the numbers):
- **Shell companies and hidden control:** corporations whose real owner is hidden behind other corporations, trusts or partnerships are used for fraud and money laundering, and corporate bank accounts of shell companies are used for phone scams.
- **Borrowed-name shares (名義株):** shares registered in a relative's or employee's name. Common in family firms; a frequent cause of inheritance and control disputes, and a way to hide control.
- **Unreliable registers in small companies:** disputes over who owns how many shares, because the register is kept by the company itself, often on paper.
- **Vote counting at shareholders' meetings:** in 2020 trust banks acting as share-register agents were found to have left uncounted, for years, postal votes that arrived on the last day.

### What already exists in this project

- **Corporations have contract addresses** governed by officers' multisigs, and their names, purpose, capital and officer names are public on-chain ([ADR 0005](../../decisions/0005-corporate-registration-model.md)).
- **Every address that holds value is certified** ([ADR 0020](../../decisions/0020-certified-address-stablecoin.md)); all JPY flows of corporations are already visible.
- **VIPs publish their address** ([ADR 0021](../../decisions/0021-vip-asset-disclosure.md)).
- **The real estate pattern** ([ADR 0029](../../decisions/0029-real-estate-registry-model.md)): one registry contract run by the Legal Affairs Bureau; the token is the right; dealings are off-chain and the transfer is the last step; eligible holders only.
- **Address-only information may be public** (user, real estate Round 5): who holds what at which address is not something to hide.

### On-chain value test ([ADR 0014](../../decisions/0014-legislative-process-scope.md)), sub-part by sub-part

| Sub-part | Q1 problem | Q2 keeper | Q3 technical | Q4 no record | Q5 combination | Result |
|---|---|---|---|---|---|---|
| **Holders of unlisted companies and LLCs** | **Yes**: borrowed names, disputes, shells | **Yes**: the company itself | **Yes** | **Yes**: not public | **Strong**: certified addresses, corporate addresses | **Candidate (core)** |
| **Layered ownership to the final individual** | **Yes**: hidden control, laundering | **Yes** | **Yes**: holdings at corporate addresses chain together | **Partly**: voluntary list only | **Strong**: real estate, VIP disclosure | **Candidate (core)** |
| **Holders of listed companies** | Moderate | No: the depository is trusted | Yes | Partly: 5% reports | **Strong**: one record for listed and unlisted; VIPs | **Candidate** |
| Matching of trades on exchanges | Market manipulation | — | **No**: surveillance, institutional | Yes: exchanges exist | — | **Off-chain** (ADR 0012) |
| Dividends | — | — | — | — | Already stablecoin payments to the holder's address | **No new design** |
| Voting at shareholders' meetings | **Yes**: uncounted votes (2020) | Partly | Yes | — | Moderate | Candidate, but see Issue 8 |
| Bonds, government bonds, other debt | Weak: no control rights | No | — | — | Weak | **Out of scope** |
| Insider trading, unfair trading | Yes | — | **No**: detection is analysis | — | Public holdings help analysis | Off-chain analysis of public data |

### Proposal

**Shares and member interests become tokens in one registry run by the Legal Affairs Bureau**, following the real estate pattern: the token is the share; it can be held only at an eligible certified address. Because corporations have addresses too, **a corporation's holdings in another corporation are visible, and the chain can be followed to the final individual's address** by any off-chain application. Nothing about control is computed on-chain.

### Issues raised

1. **Scope.** Proposal: shares of all stock companies (listed and unlisted), member interests in LLCs and other 持分会社, and the units of any vehicle that holds them (Issue 5). Bonds, government bonds and other debt are out of scope.

2. **The token and its contract.** Proposal:
   - One shared **`ShareRegistry`** run by the Legal Affairs Bureau, one token class per corporation and share class. **Moving the token is the transfer of the share** (as in [ADR 0029](../../decisions/0029-real-estate-registry-model.md)).
   - **Issuance and cancellation** (new shares, buybacks, splits) only by the corporation's multisig, citing the hash of the resolution anchored in `AnchorRegistry`.
   - **Transfer-restricted shares** (譲渡制限株式, the norm in small companies) need the corporation's approval before the transfer, like `needsApproval` for farmland.
   - Do share tokens also need the owner + agent rule of real estate? Proposal: **no**. A single holding is usually far smaller than a house, and corporations already use multisigs. An individual may set agents voluntarily.

3. **Listed shares and trading.** Holdings must sit at the holder's own address, or tracing breaks. But [ADR 0012](../../decisions/0012-onchain-scope-philosophy.md) refuses to build infrastructure for high-frequency trading. Options:
   - (a) Every trade settles on-chain individually.
   - (b) **Exchanges keep matching off-chain; brokers settle on-chain once a day, net, to each final holder's address.** Positions opened and closed within a day never reach the chain.
   - (c) Brokers hold shares for clients at the broker's address (omnibus accounts), as today. This hides the final holder and breaks tracing.

   Proposal: **(b)**.

4. **Naming beneficial owners.** Addresses show the chain of ownership, but not who the final person is. Options:
   - (a) No names; investigators ask the municipality who is behind an address.
   - (b) **Following ADR 0005 (officers' names public, never linked to an address): the corporate record also lists by name the individuals who ultimately hold 25% or more of the voting rights** (the threshold used today for beneficial owners), without linking names to addresses.

   Proposal: **(b)**. It makes the voluntary beneficial-owner list mandatory and public.

5. **Trusts, partnerships and funds.** The classic way to hide an owner is to put a trust, partnership (組合, 匿名組合) or fund between the person and the shares. Proposal: **such a vehicle can hold shares only at a registered contract address, and its own participants are recorded in `ShareRegistry` in the same way** (their units are tokens too). Otherwise the chain of ownership stops at the vehicle.

6. **Foreign holders.** Foreign investors hold about 30% of listed shares today, but they have no certified address. Two questions:
   - (a) **May foreigners hold shares?** Proposal: **yes**, unlike land. A "foreign investor" certified kind, issued by the Financial Services Agency after an off-chain identity check (directly or through a licensed foreign custodian that registers each final holder, not an omnibus account).
   - (b) **Which domestic corporations count as foreign-controlled for land?** Proposal: a corporation in which foreign holders, **traced through all layers**, hold **more than 50% of the voting rights** is treated like a foreign corporation and cannot own land. An application computes this from public holdings; the Legal Affairs Bureau checks it when land is transferred to a corporation.

7. **Borrowed-name shares.** The chain cannot see that a holder is holding for someone else. Proposal, following the backlog direction: **off-chain investigation and severe penalties**, helped by the chain, which shows who actually paid for the shares (the stablecoin flows).

8. **Shareholders' meetings.** Dividends need no new design (they are stablecoin payments to holders' addresses). On-chain voting would fix uncounted votes, but it is a second feature on top of the record. Proposal: **put it in the backlog**, to be taken up after the initial design if wanted.

9. **VIPs.** With shareholdings at the VIP's published address, their shares and the corporations they control become visible; the off-chain declaration ([ADR 0021](../../decisions/0021-vip-asset-disclosure.md)) shrinks to cash outside the chain and non-JPY tokens. Proposal: adopt; this closes the VIP backlog item.

### Status

Answered in Round 2.

---

## Round 2 — 2026-11-14 (user + Claude)

### User's decisions

- **Issues 1, 2 and 4–9: accepted as proposed, for now** ("一旦OK").
- **Issue 3: trading goes on-chain, including matching** (the user chose "matching on-chain too" when asked whether only settlement was meant). Orders and their matching run in contracts; the exchange itself becomes a contract.

### Remaining issues raised by this choice (Claude)

A. **Relation to ADR 0012.** [ADR 0012](../../decisions/0012-onchain-scope-philosophy.md) excludes high-frequency trading as something the state builds infrastructure for. Proposal: **ADR 0012 excludes infrastructure for *speed competition*, not markets.** If matching is done in a way that gives no advantage to speed (B), an on-chain exchange is consistent with it, and in fact removes high-frequency trading. A new ADR records this reading; ADR 0012's status notes it.

B. **How orders are matched.** On a public chain, a naive order book lets others see an order before it is executed and trade ahead of it (front-running). Proposal: **sealed batch auctions.** Orders are submitted as hashes during a short round (e.g. a few seconds to a minute), revealed afterwards, and all orders of the round are executed at **one clearing price**. This reuses the commit–reveal pattern of procurement ([ADR 0022](../../decisions/0022-procurement-model.md)). Arriving a millisecond earlier gains nothing, so speed competition disappears. Settlement against the stablecoin is atomic inside the same contract.

C. **Who runs the exchange and the market rules.** Proposal:
   - **Licensed exchanges operate their own registered exchange contracts** (they hold money during settlement, so they must be registered, [ADR 0020](../../decisions/0020-certified-address-stablecoin.md)). Listing and delisting, trading halts, and daily price limits (値幅制限) are operator functions recorded as public events.
   - **Investors trade from their own address**; a broker is no longer needed for access, since every address is already certified. Brokers may still offer advice and tools.
   - **Market surveillance** (manipulation, insider trading) stays off-chain with the regulator, now working on a complete public record.

D. **Short selling and margin trading.** They need lending of shares and money. Proposal: **out of scope for the initial design** (spot trading only); put in the backlog.

E. **Scale.** Listed markets execute millions of trades a day. Batch auctions shrink this (one clearing per round per stock), but the chain's capacity still matters. Proposal: record it as a constraint for the mainnet chain choice (an open question in `docs/PROJECT_STATUS.md`), not solve it here.

Unlisted shares are unaffected: dealings are bilateral and off-chain, and the token transfer is the last step, as in real estate.

### Status

Superseded by the user's proposal in Round 3.

---

## Round 3 — 2026-11-14 (user + Claude)

Claude explained Issue B (front-running on a public chain, and sealed batch auctions as the cure) at the user's request. The user then proposed a different approach:

> The exchange mechanism stays off-chain, as today, in principle. Securities firms are responsible for recording trade and execution reports on-chain. Firms that fail to do so are severely punished.

Claude's assessment: this removes the front-running problem (only results reach the chain), leaves [ADR 0012](../../decisions/0012-onchain-scope-philosophy.md) untouched (speed competition stays inside today's exchanges; the state builds only the record), and keeps exchanges as they are. Points raised:
1. **The record is the transfer:** the broker's on-chain record is itself the movement of share tokens (and stablecoin) between the holders' addresses, so the record and the holdings cannot disagree. Investors give their broker authority to move listed shares and the price.
2. **Granularity:** (a) every execution on-chain; (b) **holdings move once a day, net, and each day's executions are anchored as a Merkle root**, so any execution can later be proved (the access-log pattern of [ADR 0028](../../decisions/0028-personal-data-model.md)).
3. **Detection:** exchanges also anchor a daily root of their executions; a mismatch with a broker's records, or a missing day, is a violation.
4. **Penalties** up to licence revocation; details are law.

Consequences: issues A and B of Round 2 fall away; C shrinks to the exchange's daily anchor; short selling and margin trading (D) can stay inside the off-chain market, since only the settled result must be real at the addresses; scale (E) becomes much lighter with (b).

### User's decision

**1–3 as proposed; 2 is (b).** All issues are resolved.

### Status

All issues resolved. Spec written ([`README.md`](README.md)); ADR: [0030](../../decisions/0030-securities-model.md). Spec-time adjustments are listed in the spec and await the user's confirmation.

---

# 議論ログ: 有価証券・株主の記録(日本語)

この機能の設計に関するやり取りを順に記録する。形式は[`docs/state-design/citizenship/discussion-log.md`](../citizenship/discussion-log.md)に従う。

---

## Round 0 — 2026-11-14(ユーザー)

スコープの振り分け([ADR 0027](../../decisions/0027-remaining-scope-triage.md))で残った最後の項目。不動産登記([ADR 0029](../../decisions/0029-real-estate-registry-model.md))のすぐ後にユーザーが開始した。

これまでの議論からの前提([`docs/BACKLOG.md`](../../BACKLOG.md)):
- **要人の資産公開**([ADR 0021](../../decisions/0021-vip-asset-disclosure.md)): 株式がオンチェーンになれば、要人の保有株式と、株式を通じて支配する法人が、そのアドレスから見えるようになる。不動産の部分は完了済み。
- **「ガラス張りの法人」**(2026-10-18): 根本の問題は法人ではなく不透明さである。設計は(1)法人が法人を持つ重層的な所有を、最終的な個人までオンチェーンでたどれるようにし、(2)名義株はオフチェーンの捜査と重い罰則で扱う。
- **実質的支配者**([ADR 0005](../../decisions/0005-corporate-registration-model.md)): 法人の記録は役員を示すが、最終的に法人を所有する人は示さない。
- **外国人が支配する国内法人**([ADR 0029](../../decisions/0029-real-estate-registry-model.md)): 外国人による土地所有の禁止は、国内法人を通じて回避できる。
- [`docs/FEATURES.md`](../../FEATURES.md): この項目は**取引ではなく、誰がどの株式を持つかの記録**である。[ADR 0012](../../decisions/0012-onchain-scope-philosophy.md)が高頻度取引と個人の資産形成の手段を対象外としているため。

---

## Round 1 — 2026-11-14(Claude)

### 背景: 現在の状況

- **上場株式**(約4,000社)は2009年から電子化されている。保有は口座の連なりの中にある: 証券保管振替機構 → 証券会社 → 投資家。発行会社が株主を知るのは基準日だけである。5%以上の保有者は、公開の大量保有報告書を提出しなければならない。
- **非上場会社**(約300万の法人のほぼすべて)は、自社で株主名簿を管理する。公開されていない。株主総会の決議を要する登記のときだけ主要株主のリストを法務局に提出するが(2016年から)、これも公開されていない。
- **実質的支配者:** 2022年から法務局が実質的支配者リストを保管しているが、提出は**任意**である。FATFの2021年の対日審査は、誰が最終的に法人を所有しているかの透明性が弱いと指摘した。
- **合同会社の持分**は、公開の記録にどこにも載らない。合同会社は安く設立でき、ペーパーカンパニーによく使われる。

知られている問題(数字よりパターンが重要):
- **ペーパーカンパニーと隠れた支配:** 本当の所有者がほかの法人、信託、組合の後ろに隠れた法人が、詐欺やマネーロンダリングに使われる。ペーパーカンパニーの法人口座が特殊詐欺に使われる。
- **名義株:** 親族や従業員の名義で登録された株式。同族会社に多く、相続や支配をめぐる争いのよくある原因であり、支配を隠す手段でもある。
- **小さな会社の信頼できない名簿:** 名簿を会社自身が(しばしば紙で)管理するため、誰が何株を持つかで争いになる。
- **株主総会の集計:** 2020年、株主名簿管理人である信託銀行が、最終日に届いた郵送の議決権行使書を長年集計していなかったことが判明した。

### このプロジェクトに既にあるもの

- **法人はコントラクトのアドレスを持ち**、役員のマルチシグで管理される。商号、目的、資本金、役員名はオンチェーンで公開されている([ADR 0005](../../decisions/0005-corporate-registration-model.md))。
- **価値を持つアドレスはすべて認定済み**([ADR 0020](../../decisions/0020-certified-address-stablecoin.md))。法人の円の流れはすべてすでに見える。
- **要人はアドレスを公開する**([ADR 0021](../../decisions/0021-vip-asset-disclosure.md))。
- **不動産の型**([ADR 0029](../../decisions/0029-real-estate-registry-model.md)): 法務局が運用するレジストリのコントラクトを1つ。トークンが権利そのもの。取引はオフチェーンで、移転が最後の手順。所有資格のある者だけ。
- **アドレスだけの情報は公開してよい**(ユーザー、不動産のRound 5): どのアドレスが何を持つかは隠すものではない。

### オンチェーン価値テスト([ADR 0014](../../decisions/0014-legislative-process-scope.md))、部分ごとに

| 部分 | Q1 問題 | Q2 記録者 | Q3 技術 | Q4 記録なし | Q5 組み合わせ | 結果 |
|---|---|---|---|---|---|---|
| **非上場会社と合同会社の保有者** | **あり**: 名義、争い、ペーパーカンパニー | **あり**: 会社自身 | **あり** | **あり**: 非公開 | **強い**: 認定アドレス、法人のアドレス | **候補(中核)** |
| **最終的な個人までの重層的な所有** | **あり**: 隠れた支配、ロンダリング | **あり** | **あり**: 法人のアドレスでの保有がつながる | **一部**: 任意のリストだけ | **強い**: 不動産、要人の資産公開 | **候補(中核)** |
| **上場会社の保有者** | 中程度 | なし: 保管振替機構は信頼されている | あり | 一部: 5%の報告 | **強い**: 上場・非上場で1つの記録。要人 | **候補** |
| 取引所での売買の約定 | 相場操縦 | — | **なし**: 監視、制度の問題 | あり: 取引所がある | — | **オフチェーン**(ADR 0012) |
| 配当 | — | — | — | — | すでに保有者のアドレスへのステーブルコインの支払い | **新しい設計は不要** |
| 株主総会の議決権行使 | **あり**: 未集計(2020年) | 一部 | あり | — | 中程度 | 候補。ただし論点8 |
| 社債、国債、その他の債券 | 弱い: 支配権がない | なし | — | — | 弱い | **対象外** |
| インサイダー取引、不公正取引 | あり | — | **なし**: 検知は分析 | — | 公開の保有が分析を助ける | 公開データのオフチェーンの分析 |

### 提案

**株式と持分を、法務局が運用する1つのレジストリのトークンにする。** 不動産の型に従う: トークンが株式そのもので、所有資格のある認定アドレスにしか置けない。法人もアドレスを持つので、**ある法人がほかの法人の株式を持っていることが見え、最終的な個人のアドレスまで**、どのオフチェーンのアプリケーションでもたどれる。支配についての計算はオンチェーンでは何もしない。

### 提起する論点

1. **スコープ。** 提案: すべての株式会社(上場・非上場)の株式、合同会社などの持分会社の持分、それらを持つ器の持分(論点5)。社債、国債、その他の債券は対象外。

2. **トークンとコントラクト。** 提案:
   - 法務局が運用する共有の**`ShareRegistry`**を1つ。法人と株式の種類ごとに1つのトークンの種類。**トークンの移転が株式の移転である**([ADR 0029](../../decisions/0029-real-estate-registry-model.md)と同じ)。
   - **発行と消却**(新株発行、自己株式の取得、株式分割)は、その法人のマルチシグだけが、`AnchorRegistry`にアンカリングした決議のハッシュを示して行う。
   - **譲渡制限株式**(小さな会社では普通)は、農地の`needsApproval`と同じく、移転の前に法人の承認が必要。
   - 株式のトークンにも不動産の「所有者＋代理人」のルールが必要か? 提案: **不要**。1件の保有はふつう家よりずっと小さく、法人はすでにマルチシグを使う。個人は任意で代理人を設定できる。

3. **上場株式と取引。** 保有は保有者自身のアドレスになければ、追跡が途切れる。しかし[ADR 0012](../../decisions/0012-onchain-scope-philosophy.md)は高頻度取引のための基盤を作らないとしている。選択肢:
   - (a) すべての売買を1件ずつオンチェーンで決済する。
   - (b) **取引所は約定をオフチェーンのまま行い、証券会社が1日1回、差し引きして、最終的な保有者それぞれのアドレスにオンチェーンで決済する。** 1日の中で売り買いした分はチェーンに載らない。
   - (c) 今と同じく、証券会社が顧客の株式を証券会社のアドレスでまとめて持つ(オムニバス口座)。最終的な保有者が隠れ、追跡が途切れる。

   提案: **(b)**。

4. **実質的支配者の氏名。** アドレスは所有のつながりを示すが、最終的な人が誰かは示さない。選択肢:
   - (a) 氏名は出さない。捜査機関がアドレスの背後の人を市区町村に照会する。
   - (b) **ADR 0005(役員の氏名は公開、アドレスとは決して結びつけない)に従い、議決権の25%以上を最終的に持つ個人の氏名も法人の記録に載せる**(現在の実質的支配者の基準)。氏名とアドレスは結びつけない。

   提案: **(b)**。任意の実質的支配者リストが、義務かつ公開になる。

5. **信託、組合、ファンド。** 所有者を隠す典型的な方法は、人と株式の間に信託、組合(民法上の組合、匿名組合)、ファンドを挟むことである。提案: **そうした器は登録されたコントラクトのアドレスでしか株式を持てず、その参加者も`ShareRegistry`に同じ方法で記録する**(その持分もトークン)。そうしなければ、所有のつながりが器のところで止まる。

6. **外国人の保有者。** 現在、外国人投資家は上場株式の約30%を持つが、彼らには認定アドレスがない。2つの問い:
   - (a) **外国人は株式を持てるか?** 提案: 土地と違い**持てる**。金融庁がオフチェーンの本人確認の後に発行する「外国人投資家」の認定の種類(直接、または最終的な保有者を1人ずつ登録する認可を受けた海外のカストディアンを通じて。オムニバス口座は不可)。
   - (b) **どの国内法人を、土地について外国人が支配する法人とみなすか?** 提案: **すべての層をたどった**外国人の保有者が**議決権の50%超**を持つ法人は外国法人と同じに扱い、土地を所有できない。公開の保有からアプリケーションが計算し、法人への土地の移転のときに法務局が確認する。

7. **名義株。** ある保有者が他人のために持っていることは、チェーンからは見えない。提案(バックログの方向に従う): **オフチェーンの捜査と重い罰則**。誰が実際に株式の代金を払ったか(ステーブルコインの流れ)がチェーンで見えることが助けになる。

8. **株主総会。** 配当は新しい設計を要しない(保有者のアドレスへのステーブルコインの支払い)。オンチェーンの議決権行使は未集計を防ぐが、記録の上に乗る2つ目の機能である。提案: **バックログに入れ**、望むなら初期設計の後に取り上げる。

9. **要人。** 保有株式が要人の公開アドレスにあるので、その株式と支配する法人が見えるようになり、オフチェーンの申告([ADR 0021](../../decisions/0021-vip-asset-disclosure.md))はチェーン外の現金と円以外のトークンに縮小する。提案: 採用。これで要人のバックログ項目が閉じる。

### ステータス

Round 2で回答された。

---

## Round 2 — 2026-11-14(ユーザー＋Claude)

### ユーザーの決定

- **論点1、2、4〜9: ひとまず提案どおり了承**(「一旦OK」)。
- **論点3: 取引をオンチェーンにする。約定も含む**(決済だけかを尋ねたところ、ユーザーは「約定もオンチェーン」を選んだ)。注文と約定はコントラクトで行い、取引所そのものがコントラクトになる。

### この選択から生じる残りの論点(Claude)

A. **ADR 0012との関係。** [ADR 0012](../../decisions/0012-onchain-scope-philosophy.md)は、国家が基盤を作るものとしての高頻度取引を対象外としている。提案: **ADR 0012が対象外とするのは*速さを競う*ための基盤であって、市場ではない。** 速さが有利にならない方法で約定するなら(B)、オンチェーンの取引所はADR 0012と矛盾せず、むしろ高頻度取引をなくす。新しいADRにこの解釈を記録し、ADR 0012のステータスに注記する。

B. **注文の約定の方法。** 公開のチェーンでは、単純な板では、注文が実行される前に他人がそれを見て先回りできる(フロントランニング)。提案: **封印したバッチオークション。** 注文は短い回(例: 数秒から1分)の間にハッシュで出し、後で開示し、その回のすべての注文を**1つの約定価格**で執行する。これは公共調達のコミット・リビールの型([ADR 0022](../../decisions/0022-procurement-model.md))の再利用である。1ミリ秒早く着いても何も得られないので、速さの競争がなくなる。ステーブルコインとの決済は同じコントラクトの中でアトミックに行う。

C. **取引所を誰が運営するか、市場のルール。** 提案:
   - **免許を受けた取引所が、登録された自分の取引所コントラクトを運営する**(決済の間に資金を持つので登録が必要、[ADR 0020](../../decisions/0020-certified-address-stablecoin.md))。上場と上場廃止、売買停止、値幅制限は運営者の機能で、公開のイベントとして記録する。
   - **投資家は自分のアドレスから取引する。** すべてのアドレスがすでに認定済みなので、取引の入口としての証券会社は不要になる。証券会社は助言やツールを提供できる。
   - **市場の監視**(相場操縦、インサイダー取引)は規制当局がオフチェーンで行い、完全な公開の記録を使えるようになる。

D. **空売りと信用取引。** 株式やお金の貸し借りを要する。提案: **初期設計では対象外**(現物取引のみ)とし、バックログに入れる。

E. **規模。** 上場市場では1日に数百万件の約定がある。バッチオークションはこれを減らす(銘柄ごとに1回の約定ごとに1つ)が、チェーンの処理能力は依然として重要である。提案: ここでは解決せず、メインネットのチェーン選定(`docs/PROJECT_STATUS.md`の未解決の論点)の制約として記録する。

非上場株式は影響を受けない: 取引は当事者間でオフチェーンで行い、不動産と同じくトークンの移転が最後の手順である。

### ステータス

Round 3のユーザーの提案で置き換えられた。

---

## Round 3 — 2026-11-14(ユーザー＋Claude)

ユーザーの求めに応じて、Claudeが論点B(公開チェーンでのフロントランニングと、その対策としての封印したバッチオークション)を説明した。その後、ユーザーが別の方法を提案した:

> 取引所の仕組みは原則として今のオフチェーンのままとする。一方で、取引報告、約定報告などは証券会社が責任を持ってオンチェーンに記録するものとする。それを怠った企業は、厳罰に処するようにする。

Claudeの評価: これでフロントランニングの問題はなくなる(チェーンに載るのは結果だけ)。[ADR 0012](../../decisions/0012-onchain-scope-philosophy.md)にも手を入れずに済む(速さの競争は今の取引所の中に残り、国家が作るのは記録だけ)。取引所も今のままでよい。提起した点:
1. **記録が移転そのもの:** 証券会社のオンチェーンの記録そのものを、保有者のアドレス間の株式のトークン(とステーブルコイン)の移動とする。記録と保有が食い違えない。投資家は、上場株式と代金を動かす権限を証券会社に与える。
2. **粒度:** (a) すべての約定をオンチェーンに。(b) **保有は1日1回差し引きで動かし、その日の約定はマークルルートでアンカリングする。** どの約定も後から証明できる([ADR 0028](../../decisions/0028-personal-data-model.md)のアクセスログの型)。
3. **検知:** 取引所も約定の毎日のルートをアンカリングする。証券会社の記録との不一致や、日の欠落は違反。
4. **罰則**は免許取消しまで。詳細は法律。

結果: Round 2の論点AとBは不要になる。Cは取引所の毎日のアンカーだけに縮む。空売りと信用取引(D)は、決済された結果がアドレスで実在すればよいので、オフチェーンの市場の中に置ける。規模(E)は(b)で大きく軽くなる。

### ユーザーの決定

**1〜3は提案どおり。2は(b)。** すべての論点が解決した。

### ステータス

すべての論点が解決。仕様を作成([`README.md`](README.md))。ADR: [0030](../../decisions/0030-securities-model.md)。仕様作成時の調整は仕様に列挙し、ユーザーの確認待ち。

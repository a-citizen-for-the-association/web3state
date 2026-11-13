# Discussion Log: Real estate registry (不動産登記)

Records the back-and-forth on this feature's design, in order. See [`docs/state-design/citizenship/discussion-log.md`](../citizenship/discussion-log.md) for the format this follows.

---

## Round 0 — 2026-11-14 (user)

After the scope triage ([ADR 0027](../../decisions/0027-remaining-scope-triage.md)), two items remained: the real estate registry and securities. The user chose **the real estate registry first**.

Context from earlier discussions:
- [ADR 0027](../../decisions/0027-remaining-scope-triage.md) kept this item because it solves two real problems that a chain solves well: **impersonation of owners** and **unknown owners**.
- [`docs/BACKLOG.md`](../../BACKLOG.md): once real estate is on-chain, a VIP's real estate should be visible from their address, and the off-chain declaration ([ADR 0021](../../decisions/0021-vip-asset-disclosure.md)) shrinks.

---

## Round 1 — 2026-11-14 (Claude)

### Background: the current situation

- The registry is kept by the Legal Affairs Bureaus (法務局). Each land parcel (筆) and building has a **title section** (表題部: location, lot number, land category, area) and a **rights section** (権利部): ownership (甲区) and other rights such as mortgages and leases (乙区).
- **The registry is public.** Anyone can obtain a certificate showing the owner's **name and home address** (with an exception for victims of domestic violence and similar cases).
- **Registration is not what transfers ownership.** Ownership moves by agreement (民法176条); registration only makes it enforceable against third parties (177条). The registrar checks documents, not the truth of the transaction.
- In a sale, a judicial scrivener (司法書士) checks identities and documents, and the price is paid and the registration filed on the same day to limit settlement risk.

Known problems (the pattern matters more than the numbers):
- **Impersonation of owners (地面師).** Fraudsters impersonate the owner with forged ID documents and sell land they do not own. The best-known case is Sekisui House (2017), which lost about ¥5.5 billion. Paper and plastic ID documents cannot prove that the person in the room is the owner.
- **Unknown owners (所有者不明土地).** Land whose owner cannot be found or contacted, because inheritance was never registered or the registered address is out of date. A 2017 government study estimated its area at about 4.1 million ha, more than Kyushu; land-survey samples find it in about a quarter of parcels. It blocks public works, disaster recovery and the reuse of vacant houses (about 9 million vacant homes in 2023).
- Recent fixes show the cause is stale records: **inheritance registration has been mandatory since April 2024**, and **registration of address changes since April 2026**, with the bureau allowed to update addresses itself from the resident registry. These are paper-era patches for a missing link between the registry and the living person.

### What already exists in this project

- **The `ResidentLink` address does not change when a person moves** ([ADR 0003](../../decisions/0003-resident-link-identity-model.md)): the new municipality mints to the same address. Only the municipality knows which address belongs to which person.
- **A death burns the `ResidentLink`**, which is visible on-chain. Funds at a decertified address leave only to certified successors through the **heavy successor path** (municipality + court multisig, public waiting period) of [ADR 0020](../../decisions/0020-certified-address-stablecoin.md).
- **Payments are in the certified-address JPY stablecoin** ([ADR 0020](../../decisions/0020-certified-address-stablecoin.md)); every money-holding contract must be registered in `OfficialContractRegistry`.
- **Corporations** have contract addresses and public officer names ([ADR 0005](../../decisions/0005-corporate-registration-model.md)). **VIPs** publish their address ([ADR 0021](../../decisions/0021-vip-asset-disclosure.md)).
- **Courts** register judgments in `CaseRecordRegistry` ([ADR 0018](../../decisions/0018-judiciary-model.md)); the court has no power inside the stablecoin.
- **Fixed-asset tax** is paid from the owner's `ResidentLink` address ([ADR 0004](../../decisions/0004-taxation-payment-rail.md)).

### On-chain value test ([ADR 0014](../../decisions/0014-legislative-process-scope.md)), sub-part by sub-part

| Sub-part | Q1 problem | Q2 keeper | Q3 technical | Q4 no record | Q5 combination | Result |
|---|---|---|---|---|---|---|
| **Ownership and its transfer** (who may sell) | **Yes**: impersonation | **Partly**: the bureau is trusted, but cannot check the person behind the documents | **Yes**: a signature from the owner's address | No: the registry exists | **Strong**: `ResidentLink`, certified addresses | **Candidate (core)** |
| **Keeping the owner known** (moves, deaths) | **Yes**: unknown owners | — | **Yes**: the missing link to the living person | No | **Strong**: the address survives moves; the burn shows a death | **Candidate (core)** |
| **Paying the price** (settlement) | Moderate: settlement risk, handled by scriveners today | — | **Yes**: an atomic swap | — | **Strong**: stablecoin | **Candidate** |
| **Mortgages** (抵当権) | Moderate | — | **Yes** | No | **Strong**: lenders are certified corporations; repayments already on-chain | **Candidate** |
| Leases, easements and other rights | Weak | — | Partly | No | Weak | Off-chain (see Issue 5) |
| Title section: location, area, maps, boundaries (筆界) | Yes: maps are incomplete | — | **No**: a surveying problem | — | — | **Off-chain** |
| Use and management of vacant houses | Yes | — | **No**: institutional | — | Indirect: owners become known | Off-chain; helped by the core |
| Valuation and the amount of fixed-asset tax | — | — | No | — | — | Off-chain (ADR 0004); the owner on 1 January is read from the chain |
| Fractional or tokenised investment in property | — | — | — | — | — | Belongs to the securities item, not here |

### Proposal

Ownership of each parcel and building becomes a **transferable token issued by the Legal Affairs Bureau**, held at the owner's certified address. **Only the owner's signature can move it**, so impersonation needs the owner's key, not forged papers. Because the owner is an address and not a home address, **moves no longer make the record stale**, and **a death is visible on-chain the moment the `ResidentLink` is burned**, so an unregistered inheritance can no longer stay hidden. The title section stays off-chain.

### Issues raised

1. **On-chain registration decides ownership.** Today ownership moves by agreement and registration only perfects it. Proposal: **in this design the token is the ownership**: a sale takes effect when the token moves. This is what makes impersonation structurally impossible; otherwise the paper agreement and the chain could disagree. The token can only be held at a certified address (the same rule as the stablecoin, [ADR 0020](../../decisions/0020-certified-address-stablecoin.md)).

2. **Privacy of individual owners. This is the central tension.** Today the owner's name and home address are public. On a chain, linking a parcel to an address would let anyone walk to the house, read the nameplate and so learn whose address it is, exposing **that person's whole income and spending history**. This breaks the rule that individuals get stronger privacy ([ADR 0012](../../decisions/0012-onchain-scope-philosophy.md)), the same tension [ADR 0005](../../decisions/0005-corporate-registration-model.md) solved by never linking an officer's name to their address. Options:
   - (a) **Fully public:** the parcel, its token and the owner address are all public. Simple, but deanonymises every individual homeowner.
   - (b) **Asymmetric, following the project's rule (corporations and VIPs open, individuals private):** each token carries only a **salted hash of the parcel number**. For tokens held by corporations, public bodies and VIPs, the bureau publishes the parcel number openly. For individuals, the bureau's public registry says only "owned by an individual", and the parcel–token link is disclosed off-chain to people with a legitimate interest (a buyer before a sale, a lender, a neighbour in a boundary matter, a court, the municipality). The owner's name stops being public, which is a privacy gain over today.
   - (c) A separate certified "property address" per person. It does not work: paying the price from the main address links the two on a public chain.

   Proposal: **(b)**. It also closes the VIP-disclosure backlog item: a VIP's land and buildings become visible from their published address.

3. **How a sale works.** Proposal:
   - The token contract has a **settlement function**: the buyer deposits the price in the stablecoin, the seller signs, and the token and the money swap in one transaction. If either side is missing, nothing happens. The contract holds money, so it must be registered (ADR 0020).
   - Where the law requires a permission (e.g. farmland under the Agricultural Land Act), the bureau **approves the transfer first**; otherwise the bureau is not needed.
   - **A waiting period against key theft:** a stolen key is now the only way to impersonate the owner, and land is valuable. Every transfer of a token held by an individual waits **a short public period (e.g. 7 days)**, during which the municipality can stop it if the owner reports a lost or stolen key. Corporations protect themselves with their multisig.

   Is this the intended balance?

4. **Transfers without the owner's signature.** Some transfers have no owner signature by nature: inheritance, a court-ordered auction (競売), a judgment, acquisition by prescription (時効取得), and expropriation for public works (収用). Proposal:
   - **Inheritance reuses the heavy successor path of ADR 0020**: money and property of a deceased person move together, in one procedure, to certified heirs. A token at an address whose `ResidentLink` was burned is visible on-chain, so an inheritance that is not handled within the legal deadline (three years today) shows up by itself.
   - **The other cases:** the bureau may move a token **only by citing the hash of a court decision registered in `CaseRecordRegistry`** (or, for expropriation, an anchored decision of the expropriating body). Each forced transfer is a public event. Unlike the stablecoin, the court does not get power over tokens; the bureau acts on its order, as it does today.

5. **Mortgages and other rights.** Proposal:
   - **Mortgages on-chain:** a certified lender records a lien on the token. A token with a lien cannot be transferred unless the lender releases it or consents. Repayment ends with the lender's release. Foreclosure follows Issue 4 (a court order).
   - **Leases, easements and other rights stay in the bureau's off-chain registry**; only the hash of each registration is anchored, so that it cannot be rewritten later.

6. **Owners without a `ResidentLink`.** Non-residents (Japanese living abroad, foreign individuals and foreign corporations) own land too. The certified-address rule means they would need a certified address. Options:
   - (a) **The bureau issues a certified "non-resident owner" address**, after an off-chain identity check, registered in `OfficialContractRegistry` as its own kind. It can hold property tokens and pay fixed-asset tax.
   - (b) Non-residents must hold land through a domestic corporation.

   Proposal: **(a)**. (b) is a policy decision about foreign ownership, which is not this project's question.

7. **Moving existing records.** There are hundreds of millions of parcels and buildings, many with unknown owners. Minting all of them at once is impossible and pointless. Proposal: **migrate lazily.** A token is minted at the next event that touches the record (a sale, an inheritance, a new mortgage) or when the owner asks. From a fixed date, every such event must be done on-chain. Records with unknown owners are minted when a court or the bureau resolves them under existing procedures.

8. **What stays off-chain.** Proposal: the title section (location, area, category, maps and boundaries), valuation, the amount of fixed-asset tax, and the management of vacant houses. For fixed-asset tax, the municipality reads the owner on 1 January from the chain, sends the notice to the owner (through the person linked to the address), and receives payment as in ADR 0004.

### Status

Answered in Round 2.

---

## Round 2 — 2026-11-14 (user + Claude)

### User's decisions

- **Real estate is tokenised**, and **moving the token is the transfer of the right** (Issue 1 as proposed).
- **Privacy (Issue 2): the parties check and exchange whatever they need off-chain.** All conditions are settled off-chain; the token transfer is the last step. No unnecessary personal data reaches the chain. This replaces options (a)–(c).
- **Key theft (Issue 3): agents instead of a waiting period.** The owner can appoint several agents (代理人). A transfer needs the owner **and at least one agent**. The waiting period is dropped.

### Remaining issues (Claude)

Issues 1 and 2 are resolved; the waiting period in Issue 3 is replaced. What remains:

A. **What the token itself shows.** Even with all dealings off-chain, if a token publicly carries its lot number, anyone can see which address owns which parcel, and the nameplate on the house gives away the owner's whole financial history. Proposal: **the token carries no lot number** (an opaque ID plus a salted hash). A buyer, lender, court or the municipality learns which token is which parcel from the Legal Affairs Bureau, off-chain, which fits the user's off-chain approach. **Exception:** for tokens held by corporations, public bodies and VIPs, the bureau publishes the parcel openly (the project's asymmetry; this also closes the VIP-disclosure backlog item). Agree?

B. **Details of the agent rule.**
   1. **Who can be an agent:** any certified address (family members, a judicial scrivener, a bank). Proposal: adopt.
   2. **Changing agents** needs the owner **and at least one current agent**; otherwise a thief with the owner's key could replace the agents first.
   3. **An owner with no agent:** then the owner's key alone could move the token, and the protection is gone. Proposal: **individuals must have at least one agent**; a corporation's multisig already serves this purpose, so agents are optional for corporations.
   4. **The last agent is lost** (death, key loss): an agent whose `ResidentLink` is burned stops counting automatically. If no valid agent remains, the owner can appoint a new one **only with the municipality's confirmation** (as in ADR 0020's light path).
   5. **The owner's key is lost:** the agents alone cannot transfer. Recovery goes through **ADR 0020's heavy successor path**, which moves the tokens with the funds to the owner's new address.
   6. **Agent addresses are visible on the token** and reveal the owner's relationships. Proposal: store **only a hash of the agent set**; an agent shows that they are in the set when signing.

C. **Paying the price.** Proposal: the token contract offers an **optional atomic settlement**: the buyer deposits the stablecoin, and the owner's and an agent's signatures release the token and the money in one transaction. Transfers without payment (gifts, transfers inside a family) are still possible. Agree?

D. **Transfers that need a permission** (e.g. farmland): the Legal Affairs Bureau approves before the transfer, as proposed in Issue 3.

E. **Transfers without the owner's signature** (Issue 4, unchanged): inheritance through ADR 0020's heavy path; auction, judgment, prescription and expropriation by the bureau, only on the hash of a registered decision.

F. **Mortgages and other rights** (Issue 5, unchanged): mortgages on-chain as a lien that blocks transfer without the lender's consent; other rights off-chain with anchored hashes.

G. **Co-ownership (共有). New issue.** Many parcels have several owners, often heirs, and this is a main cause of unknown owners. Proposal: **one token per co-owner's share**, recording the fraction. Each share can be transferred under the same owner + agent rule. Decisions that need all co-owners (selling the whole parcel) are made off-chain, and the shares are then transferred together.

H. **Non-residents** (Issue 6, unchanged): a certified "non-resident owner" address issued by the bureau.

I. **Moving existing records** (Issue 7, unchanged): mint on the next sale, inheritance or mortgage, or on request.

J. **Off-chain items and fixed-asset tax** (Issue 8, unchanged). The bureau gives the municipality the token–parcel mapping, so the municipality can find the owner on 1 January.

### Status

Awaiting the user's response on A–J.

---

# 議論ログ: 不動産登記(日本語)

この機能の設計に関するやり取りを順に記録する。形式は[`docs/state-design/citizenship/discussion-log.md`](../citizenship/discussion-log.md)に従う。

---

## Round 0 — 2026-11-14(ユーザー)

スコープの振り分け([ADR 0027](../../decisions/0027-remaining-scope-triage.md))の後、不動産登記と有価証券の2項目が残っていた。ユーザーは**不動産登記を先に**選んだ。

これまでの議論からの前提:
- [ADR 0027](../../decisions/0027-remaining-scope-triage.md)がこの項目を残したのは、チェーンがうまく解決できる2つの本物の問題を解決するから: **所有者へのなりすまし**と**所有者不明**。
- [`docs/BACKLOG.md`](../../BACKLOG.md): 不動産がオンチェーンになれば、要人の不動産はその人のアドレスから見えるようになり、オフチェーンの申告([ADR 0021](../../decisions/0021-vip-asset-disclosure.md))は縮小する。

---

## Round 1 — 2026-11-14(Claude)

### 背景: 現在の状況

- 登記は法務局が管理する。土地の各筆と各建物に、**表題部**(所在、地番、地目、地積)と**権利部**がある。権利部は所有権(甲区)と、抵当権や賃借権などのそれ以外の権利(乙区)に分かれる。
- **登記は公開されている。** 誰でも登記事項証明書を取得でき、そこには所有者の**氏名と住所**が載る(DV被害者などの例外を除く)。
- **登記によって所有権が移るのではない。** 所有権は合意で移り(民法176条)、登記は第三者に対抗するためのもの(177条)。登記官は書類を確認するが、取引が本当かどうかは確認しない。
- 売買では司法書士が本人と書類を確認し、決済リスクを抑えるため、代金の支払いと登記申請を同じ日に行う。

知られている問題(数字よりパターンが重要):
- **所有者へのなりすまし(地面師)。** 偽造した本人確認書類で所有者になりすまし、自分のものではない土地を売る。最もよく知られているのは積水ハウスの事件(2017年)で、約55億円を失った。紙やプラスチックの本人確認書類では、その場にいる人が所有者であることを証明できない。
- **所有者不明土地。** 相続登記がされていない、または登記上の住所が古いために、所有者を見つけられない、連絡できない土地。2017年の政府の研究会の推計では面積は約410万haで九州より広い。地籍調査の抽出では筆数の約4分の1に及ぶ。公共事業、災害復旧、空き家(2023年に約900万戸)の再利用を妨げている。
- 最近の対策を見ると、原因が古い記録であることがわかる: **相続登記は2024年4月から義務化**され、**住所変更登記は2026年4月から義務化**された(法務局が住民基本台帳をもとに職権で住所を更新できる仕組みつき)。これらは、登記と生きている本人とのつながりが欠けていることに対する、紙の時代の継ぎはぎである。

### このプロジェクトに既にあるもの

- **`ResidentLink`のアドレスは引っ越しでは変わらない**([ADR 0003](../../decisions/0003-resident-link-identity-model.md)): 転入先の市区町村が同じアドレスにmintする。どのアドレスが誰のものかを知っているのは市区町村だけ。
- **死亡すると`ResidentLink`はburnされ**、それはオンチェーンで見える。認定が外れたアドレスの資金は、[ADR 0020](../../decisions/0020-certified-address-stablecoin.md)の**重い承継の手続き**(市区町村と裁判所のマルチシグ、公開の待機期間)を通じて、認定済みの承継先にしか出られない。
- **支払いは認定アドレス制の円建てステーブルコイン**([ADR 0020](../../decisions/0020-certified-address-stablecoin.md))。資金を保持するコントラクトはすべて`OfficialContractRegistry`への登録が必要。
- **法人**はコントラクトのアドレスを持ち、役員名は公開([ADR 0005](../../decisions/0005-corporate-registration-model.md))。**要人**はアドレスを公開する([ADR 0021](../../decisions/0021-vip-asset-disclosure.md))。
- **裁判所**は判決を`CaseRecordRegistry`に登録する([ADR 0018](../../decisions/0018-judiciary-model.md))。裁判所はステーブルコインの中の権限を持たない。
- **固定資産税**は所有者の`ResidentLink`アドレスから払う([ADR 0004](../../decisions/0004-taxation-payment-rail.md))。

### オンチェーン価値テスト([ADR 0014](../../decisions/0014-legislative-process-scope.md))、部分ごとに

| 部分 | Q1 問題 | Q2 記録者 | Q3 技術 | Q4 記録なし | Q5 組み合わせ | 結果 |
|---|---|---|---|---|---|---|
| **所有権とその移転**(誰が売れるか) | **あり**: なりすまし | **一部**: 法務局は信頼されているが、書類の背後の人物は確認できない | **あり**: 所有者のアドレスからの署名 | なし: 登記は存在する | **強い**: `ResidentLink`、認定アドレス | **候補(中核)** |
| **所有者がわかる状態を保つ**(引っ越し、死亡) | **あり**: 所有者不明 | — | **あり**: 生きている本人とのつながりの欠如 | なし | **強い**: アドレスは引っ越しでも変わらず、burnが死亡を示す | **候補(中核)** |
| **代金の支払い**(決済) | 中程度: 決済リスク。今は司法書士が対応 | — | **あり**: アトミックな交換 | — | **強い**: ステーブルコイン | **候補** |
| **抵当権** | 中程度 | — | **あり** | なし | **強い**: 貸し手は認定済みの法人で、返済はすでにオンチェーン | **候補** |
| 賃借権、地役権などの権利 | 弱い | — | 一部 | なし | 弱い | オフチェーン(論点5) |
| 表題部: 所在、地積、地図、筆界 | あり: 地図が不完全 | — | **なし**: 測量の問題 | — | — | **オフチェーン** |
| 空き家の利用と管理 | あり | — | **なし**: 制度の問題 | — | 間接的: 所有者がわかるようになる | オフチェーン。中核が助けになる |
| 評価と固定資産税の額 | — | — | なし | — | — | オフチェーン(ADR 0004)。1月1日の所有者はチェーンから読む |
| 不動産の小口化・トークン化投資 | — | — | — | — | — | ここではなく有価証券の項目に属する |

### 提案

土地の各筆と各建物の所有権を、**法務局が発行する譲渡可能なトークン**にし、所有者の認定アドレスに置く。**動かせるのは所有者の署名だけ**なので、なりすましには偽造書類ではなく所有者の鍵が必要になる。所有者を表すのは住所ではなくアドレスなので、**引っ越しで記録が古くならない**。そして**`ResidentLink`がburnされた瞬間に死亡がオンチェーンで見える**ので、相続の未登記を隠しておけなくなる。表題部はオフチェーンのまま。

### 提起する論点

1. **オンチェーンの登記が所有権を決める。** 現在は所有権は合意で移り、登記はそれを対抗できるようにするだけ。提案: **この設計ではトークンが所有権そのもの**であり、売買はトークンが動いた時点で効力を持つ。これによってなりすましが構造的に不可能になる。そうしなければ、紙の合意とチェーンが食い違いうる。トークンは認定アドレスにしか置けない(ステーブルコインと同じルール、[ADR 0020](../../decisions/0020-certified-address-stablecoin.md))。

2. **個人の所有者のプライバシー。ここが中心的な緊張関係。** 現在は所有者の氏名と住所が公開されている。チェーン上で土地とアドレスを結びつけると、誰でもその家まで行って表札を見れば、そのアドレスが誰のものかがわかり、**その人の収入と支出の履歴がすべて**さらされる。これは個人のプライバシーをより強くするという原則([ADR 0012](../../decisions/0012-onchain-scope-philosophy.md))を壊す。[ADR 0005](../../decisions/0005-corporate-registration-model.md)が役員の氏名とアドレスを決して結びつけないことで解決したのと同じ緊張関係である。選択肢:
   - (a) **完全に公開:** 土地、トークン、所有者のアドレスがすべて公開。単純だが、個人の住宅所有者全員の匿名性が失われる。
   - (b) **非対称。プロジェクトの原則(法人と要人は公開、個人は非公開)に従う:** 各トークンには**地番のソルト付きハッシュ**だけを持たせる。法人、公的機関、要人が持つトークンについては、法務局が地番を公開する。個人については、法務局の公開の登記には「個人所有」とだけ載せ、土地とトークンの対応は正当な利害関係者(売買前の買主、貸し手、境界の問題での隣人、裁判所、市区町村)にオフチェーンで開示する。所有者の氏名は公開されなくなり、現在よりプライバシーが向上する。
   - (c) 個人ごとに別の認定済み「不動産用アドレス」を持つ。これは機能しない: 代金を主アドレスから払うと、公開のチェーン上で2つが結びつく。

   提案: **(b)**。これで要人の資産公開のバックログ項目も解決する: 要人の土地と建物は、公開されたアドレスから見えるようになる。

3. **売買の流れ。** 提案:
   - トークンのコントラクトに**決済の機能**を持たせる: 買主がステーブルコインで代金を預け、売主が署名し、トークンと代金が1つのトランザクションで交換される。どちらかが欠ければ何も起きない。このコントラクトは資金を保持するので登録が必要(ADR 0020)。
   - 法律で許可が必要な場合(例: 農地法による農地)は、**法務局が先に移転を承認する**。それ以外は法務局は関与しない。
   - **鍵の盗難に対する待機期間:** 所有者になりすます方法は鍵を盗むことだけになり、しかも土地は高価。個人が持つトークンの移転はすべて**短い公開の待機期間(例: 7日)**を置き、その間に所有者が鍵の紛失・盗難を届け出れば市区町村が止められる。法人はマルチシグで自らを守る。

   この程度の釣り合いでよいか?

4. **所有者の署名のない移転。** 性質上、所有者の署名がない移転がある: 相続、裁判所による競売、判決、時効取得、公共事業のための収用。提案:
   - **相続はADR 0020の重い承継の手続きを再利用する:** 亡くなった人の資金と不動産を、1つの手続きでまとめて認定済みの相続人に移す。`ResidentLink`がburnされたアドレスにあるトークンはオンチェーンで見えるので、法定の期限(現在は3年)内に処理されない相続はそれだけで浮かび上がる。
   - **それ以外の場合:** 法務局がトークンを動かせるのは、**`CaseRecordRegistry`に登録された裁判所の決定のハッシュを示したときだけ**(収用の場合は、収用する機関のアンカリングされた決定)。強制的な移転はそれぞれ公開のイベントになる。ステーブルコインと違い、裁判所にトークンへの権限は与えない。今と同じく、法務局が裁判所の命令に基づいて動かす。

5. **抵当権とその他の権利。** 提案:
   - **抵当権はオンチェーン:** 認定済みの貸し手がトークンに担保を記録する。担保のついたトークンは、貸し手が抹消するか同意しない限り移転できない。返済が終われば貸し手が抹消する。担保の実行は論点4(裁判所の命令)に従う。
   - **賃借権、地役権などのその他の権利は法務局のオフチェーンの登記に残す。** 各登記のハッシュだけをアンカリングし、後から書き換えられないようにする。

6. **`ResidentLink`を持たない所有者。** 非居住者(海外在住の日本人、外国人個人、外国法人)も土地を持つ。認定アドレス制のもとでは、彼らにも認定アドレスが必要になる。選択肢:
   - (a) **法務局が、オフチェーンの本人確認の後、認定済みの「非居住所有者」アドレスを発行する。** `OfficialContractRegistry`に独自の種類として登録する。不動産のトークンを持ち、固定資産税を払える。
   - (b) 非居住者は国内の法人を通じてしか土地を持てない。

   提案: **(a)**。(b)は外国人による土地所有についての政策判断であり、このプロジェクトの問いではない。

7. **既存の記録の移行。** 土地と建物は数億件あり、所有者不明のものも多い。一度にすべてmintするのは不可能で、意味もない。提案: **必要になったときに移行する。** 記録に触れる次の出来事(売買、相続、新しい抵当権)のとき、または所有者が求めたときにトークンをmintする。ある日付以降、そうした出来事はすべてオンチェーンで行わなければならない。所有者不明の記録は、既存の手続きで裁判所や法務局が解決したときにmintする。

8. **オフチェーンに残すもの。** 提案: 表題部(所在、地積、地目、地図と筆界)、評価、固定資産税の額、空き家の管理。固定資産税については、市区町村が1月1日の所有者をチェーンから読み、(アドレスに結びついた本人を通じて)所有者に通知し、ADR 0004のとおり支払いを受ける。

### ステータス

Round 2で回答された。

---

## Round 2 — 2026-11-14(ユーザー＋Claude)

### ユーザーの決定

- **不動産をトークン化し**、**トークンの移転を権利の移転とする**(論点1は提案どおり)。
- **プライバシー(論点2): 必要な情報の確認と交換は取引者の間でオフチェーンで行う。** 条件はすべてオフチェーンでまとめ、トークンの移転を最後の手順とする。不要な個人情報をチェーンに載せない。選択肢(a)〜(c)はこれで置き換える。
- **鍵の流出(論点3): 待機期間ではなく代理人。** 所有者は複数の代理人を設定できる。移転には所有者**と1人以上の代理人**の賛成が必要。待機期間はやめる。

### 残っている論点(Claude)

論点1と2は解決し、論点3の待機期間は置き換えられた。残るもの:

A. **トークン自体が示すもの。** 取引がすべてオフチェーンでも、トークンが地番を公開で持っていれば、どのアドレスがどの土地を持つかが誰にでもわかり、家の表札から所有者の収支の履歴がすべてさらされる。提案: **トークンに地番を持たせない**(不透明なIDとソルト付きハッシュだけ)。どのトークンがどの土地かは、買主、貸し手、裁判所、市区町村が法務局からオフチェーンで知る。これはユーザーのオフチェーンの方針に合う。**例外:** 法人、公的機関、要人が持つトークンについては、法務局が土地を公開する(プロジェクトの非対称の原則。要人の資産公開のバックログ項目もこれで閉じる)。これでよいか?

B. **代理人のルールの詳細。**
   1. **誰が代理人になれるか:** 認定アドレスなら誰でも(家族、司法書士、銀行)。提案: 採用。
   2. **代理人の変更**には、所有者**と現在の代理人の1人以上**が必要。そうしないと、所有者の鍵を盗んだ者がまず代理人を入れ替えてしまう。
   3. **代理人のいない所有者:** その場合は所有者の鍵だけでトークンが動き、保護がなくなる。提案: **個人は代理人を1人以上置かなければならない**。法人はマルチシグが同じ役割を果たすので、代理人は任意。
   4. **最後の代理人がいなくなった場合**(死亡、鍵の紛失): `ResidentLink`がburnされた代理人は自動的に数えられなくなる。有効な代理人が残っていなければ、所有者は**市区町村の確認があるときに限り**新しい代理人を設定できる(ADR 0020の軽い手続きと同様)。
   5. **所有者の鍵を紛失した場合:** 代理人だけでは移転できない。回復は**ADR 0020の重い承継の手続き**で行い、資金と一緒にトークンも所有者の新しいアドレスに移す。
   6. **代理人のアドレスがトークン上で見えると**、所有者の人間関係がわかってしまう。提案: **代理人の集合のハッシュだけを保存し**、代理人は署名するときに自分がその集合に含まれることを示す。

C. **代金の支払い。** 提案: トークンのコントラクトに**任意のアトミック決済**を用意する: 買主がステーブルコインを預け、所有者と代理人の署名で、トークンと代金が1つのトランザクションで交換される。支払いのない移転(贈与、家族内の移転)も引き続き可能。これでよいか?

D. **許可が必要な移転**(例: 農地): 論点3の提案どおり、移転の前に法務局が承認する。

E. **所有者の署名のない移転**(論点4、変更なし): 相続はADR 0020の重い手続きで。競売、判決、時効取得、収用は、登録された決定のハッシュを示したときに限り法務局が行う。

F. **抵当権とその他の権利**(論点5、変更なし): 抵当権はオンチェーンの担保とし、貸し手の同意なしには移転できない。その他の権利はオフチェーンで、ハッシュをアンカリング。

G. **共有。新しい論点。** 多くの土地には複数の所有者がいて(相続人であることが多い)、これが所有者不明の大きな原因になっている。提案: **共有者の持分ごとに1つのトークン**とし、割合を記録する。各持分は同じ「所有者＋代理人」のルールで移転できる。共有者全員の同意が必要な判断(土地全体の売却)はオフチェーンで行い、その後に持分をまとめて移転する。

H. **非居住者**(論点6、変更なし): 法務局が発行する認定済みの「非居住所有者」アドレス。

I. **既存の記録の移行**(論点7、変更なし): 次の売買、相続、抵当権の設定のとき、または求めがあったときにmintする。

J. **オフチェーンに残すものと固定資産税**(論点8、変更なし)。法務局はトークンと土地の対応を市区町村に渡し、市区町村が1月1日の所有者を見つけられるようにする。

### ステータス

A〜Jについてユーザーの回答待ち。

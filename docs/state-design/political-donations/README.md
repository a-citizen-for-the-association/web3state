# Political donations (政治献金)

**Status: 🟢 Spec drafted.** Resolved through discussion with the user; see [`discussion-log.md`](discussion-log.md) for the reasoning and [ADR 0015](../../decisions/0015-political-donations-model.md) for the formal decision. No contract code written yet.

## Summary

Every political organization (party, political fund-raising body, legislator's fund-management body, other political organization) is registered on-chain by the election board. Its **only** lawful receiving address is a dedicated fund contract deployed from a common factory. Money can enter that contract only from an address that holds a genuine `ResidentLink` or is a genuinely registered corporation, so **every donor is traceable**. Some rules are enforced inside the contract (identifiable donor, corporations → parties only, per-recipient annual cap). The rest are checked after the fact by auditing the fully public on-chain record (cross-recipient totals, foreign donors). All spending leaves from the same contract, so income and expenditure are both public by construction.

**Goal, precisely stated:** make covert political money (e.g. the 2023–24 party-ticket slush-fund scandal) structurally hard to hide by making every inflow and outflow traceable. Publishing donors' names is *not* the goal.

## Scope

**In scope:** registration of political organizations; all inflows to them (donations, party-ticket sales, membership fees, other income), all treated alike; all outflows; on-chain enforcement of the rules listed under [Enforcement split](#enforcement-split).

**Out of scope:**
- Legislators' roll-call vote records: handled off-chain (Round 3; partially supersedes [ADR 0014](../../decisions/0014-legislative-process-scope.md)).
- Donor names on-chain: never recorded (Round 4).
- Checking whether spending purposes are legitimate: off-chain audit, as today.
- Political activity by individuals that involves no political organization.

## On-chain / Online / Offline breakdown

(See [`docs/operations/README.md`](../../operations/README.md) for the convention.)

**On-chain:**
- `OfficialContractRegistry`: the allowlist of genuine `ResidentLink` and corporate-registration contracts, plus the accepted stablecoin(s) and the legal cap parameters.
- `PoliticalOrgRegistration` NFTs: organization name, type, representative/treasurer names, affiliated legislator name (for fund-management bodies). Public, per ADR 0012's open-information principle for VIPs.
- `PoliticalFund` contracts: every contribution (donor address, which identity contract, category, amount, year) and every expenditure.

**Online:**
- 総務省 publishes the `OfficialContractRegistry` address under `.go.jp`. Each election board publishes its `PoliticalOrgRegistration` contract address under its own domain. This is the same attestation pattern as earlier designs.

**Offline:**
- The election board vets a political organization's registration documents.
- 総務省 confirms each registry entry against the issuer's own off-chain attestation (`.lg.jp` for municipalities, `.go.jp` for corporate-registration authorities) before adding it.
- Investigators resolve a donor's `ResidentLink` address to a person through the municipality, by legal process.
- After-the-fact audit: cross-recipient totals, foreign donors and foreign-controlled corporations, legitimacy of spending.

## Architecture

### `OfficialContractRegistry` (one, operated by 総務省)

- `kindOf(address) → None | ResidentLink | CorporateRegistration`. Entries are added and removed only by 総務省's controlling address, and every change emits an event.
- Also holds the list of accepted stablecoin(s) and the cap parameters (per donor type × recipient type × category), since these are legal parameters that change by law, not per organization.
- It is the trust anchor for **automated** contract-to-contract checks. The root of trust is still off-chain (ADR 0003): 総務省 only mirrors attestations that already exist.
- Reusable by later features that need the same automated check.

### `PoliticalOrgRegistration` (one per election board)

- Soulbound, authority-updatable NFT, the same shape as corporate registration ([ADR 0005](../../decisions/0005-corporate-registration-model.md)).
- Fields: name, type (`Party` / `FundRaisingBody` / `FundManagementBody` / `Other`), representative and treasurer names, affiliated legislator name (fund-management bodies only). Names only, never personal addresses, following ADR 0005's rule.
- Registration flow: the election board calls `PoliticalFundFactory.createFund(controller)`, then mints the registration NFT **to the new fund contract's address**. The fund contract *is* the organization's on-chain identity.
- Dissolution: the election board burns the NFT, and the fund contract stops accepting contributions.

### `PoliticalFund` (one per organization, deployed from `PoliticalFundFactory`)

- **Controller:** the organization's multisig (the same approach as corporate addresses; which audited multisig standard to use is already in the backlog).
- **`contribute(amount, category, identityContract)`** is the only accounted way in:
  1. `registry.kindOf(identityContract)` must not be `None`.
  2. `identityContract.balanceOf(msg.sender) > 0`. For `ResidentLink` the donor is a resident; for `CorporateRegistration` the donor is the corporation's own address, which holds its registration NFT.
  3. If the donor is a corporation, this organization's type must be `Party`.
  4. The donor's running total to **this** organization, for this year and category, plus `amount`, must not exceed the cap.
  5. `transferFrom` the accepted stablecoin, increase `accountedBalance`, and emit `Contribution(donor, identityContract, category, amount, year)`.
- **Categories:** `Donation`, `PartyTicket`, `MembershipFee`, `Other`. Every inflow uses the same entry point whatever it is called (Issue 5). Caps are set per category.
- **Year:** the Japanese calendar year derived from `block.timestamp` (UTC+9). This is the second justified on-chain date exception after the voting period.
- **`spend(to, amount, purpose)`:** controller only, `amount ≤ accountedBalance`, and an event is emitted.
- **Unaccounted funds** (the token balance above `accountedBalance`, which arrives through direct transfers that bypass `contribute`) cannot be spent. `forfeitUnaccounted()` sends them to the treasury only. A genuine mistaken sender claims a refund from the treasury off-chain. A "refund to anyone" path is deliberately absent, because it would launder untraceable money through the fund (Round 5).

### Enforcement split

| Rule | Enforced |
|---|---|
| Donor holds a genuine `ResidentLink` or is a registered corporation | In the contract (with the registry) |
| Corporations may donate to parties only | In the contract |
| Per-recipient annual cap, per category | In the contract |
| Spending limited to accounted funds; unaccounted funds go to the treasury only | In the contract |
| Total annual cap across recipients | After-the-fact audit of on-chain data |
| Foreign individuals / foreign-controlled corporations banned | After-the-fact audit |
| Legitimacy of spending purposes | After-the-fact audit |

### Why no donor names (Round 4)

Every donor address is either a `ResidentLink` holder, verified in person by a municipality, or a registered corporation with public officer names. Large donations are therefore trivially traceable: query the chain, then resolve the address through the municipality by legal process. Putting names on-chain would add nothing to traceability and would cost individual privacy (ADR 0012).

## Open items for later

- Disposition of remaining funds when an organization dissolves (tracked in [`docs/BACKLOG.md`](../../BACKLOG.md)).
- Key governance for 総務省's registry controller: a compromise would let fake identity contracts in. Covered by the existing backlog item on selecting an audited multisig standard.
- Data to support the foreign-controlled-corporation audit: corporate registration does not record ownership. Related to the existing backlog item on beneficial-ownership transparency.

---

# 政治献金(日本語)

**ステータス: 🟢 設計確定。** ユーザーとの議論で決定した。理由は[`discussion-log.md`](discussion-log.md)、正式な決定は[ADR 0015](../../decisions/0015-political-donations-model.md)を参照。コントラクトコードはまだない。

## 概要

すべての政治団体(政党、政治資金団体、議員の資金管理団体、その他の政治団体)は、選挙管理委員会がオンチェーンで登録する。適法な受け取りアドレスは、共通のファクトリーからデプロイされた専用の資金コントラクト**だけ**である。このコントラクトにお金を入れられるのは、本物の`ResidentLink`を持つアドレスか、本当に登記された法人のアドレスだけなので、**すべての献金者が追跡可能**になる。一部のルールはコントラクト内で強制する(献金者が特定できること、法人は政党にのみ献金可、受取先ごとの年間上限)。残りは、完全に公開されたオンチェーン記録を事後に監査して確認する(受取先をまたぐ合計、外国人献金)。支出もすべて同じコントラクトから行うので、収入と支出の両方が仕組みとして公開される。

**目的の正確な表現:** すべての資金の出入りを追跡可能にすることで、隠れた政治資金(例: 2023〜24年のパーティー券裏金事件)を構造的に隠しにくくする。献金者の氏名を公開することは目的では*ない*。

## スコープ

**対象:** 政治団体の登録。政治団体へのすべての収入(献金、パーティー券売上、会費、その他)を同じ扱いにすること。すべての支出。[強制の分担](#強制の分担)に挙げたルールのオンチェーンでの強制。

**対象外:**
- 議員の記名採決記録: オフチェーンで扱う(Round 3。[ADR 0014](../../decisions/0014-legislative-process-scope.md)を部分的に上書き)。
- 献金者の氏名のオンチェーン記録: 一切記録しない(Round 4)。
- 支出目的が正当かどうかの確認: 現在と同じくオフチェーンの監査で行う。
- 政治団体を介さない個人の政治活動。

## オンチェーン/オンライン/オフラインの内訳

(規約は[`docs/operations/README.md`](../../operations/README.md)を参照。)

**オンチェーン:**
- `OfficialContractRegistry`: 本物の`ResidentLink`と法人登記コントラクトの許可リスト。受け入れるステーブルコインと法定の上限値も保持する。
- `PoliticalOrgRegistration` NFT: 団体名、種別、代表者・会計責任者の氏名、関係する議員の氏名(資金管理団体の場合)。ADR 0012の「要人の情報は公開」という原則に従い公開する。
- `PoliticalFund`コントラクト: すべての収入(献金者アドレス、どの本人確認コントラクトか、区分、金額、年)とすべての支出。

**オンライン:**
- 総務省は`OfficialContractRegistry`のアドレスを`.go.jp`で公開する。各選挙管理委員会は自分の`PoliticalOrgRegistration`コントラクトのアドレスを自分のドメインで公開する。これまでの設計と同じ証明パターンである。

**オフライン:**
- 選挙管理委員会が政治団体の登録書類を審査する。
- 総務省は、各エントリーを追加する前に、発行者自身のオフチェーンの証明(市区町村なら`.lg.jp`、法人登記の所管官庁なら`.go.jp`)と照合する。
- 捜査機関は、法的手続きにより市区町村を通じて、献金者の`ResidentLink`アドレスから人物を特定する。
- 事後監査: 受取先をまたぐ合計、外国人と外資支配法人の献金、支出の正当性。

## アーキテクチャ

### `OfficialContractRegistry`(1つ、総務省が運用)

- `kindOf(address) → None | ResidentLink | CorporateRegistration`。エントリーの追加・削除は総務省の管理アドレスだけが行え、変更のたびにイベントを発行する。
- 受け入れるステーブルコインの一覧と上限値(献金者の種別 × 受取団体の種別 × 区分)も保持する。これらは団体ごとではなく、法律で変わる法定のパラメータだからである。
- コントラクト間の**自動**検証のための信頼の起点となる。信頼の根は引き続きオフチェーンにある(ADR 0003)。総務省はすでに存在する証明を写すだけである。
- 同じ自動検証を必要とする今後の機能でも再利用できる。

### `PoliticalOrgRegistration`(選挙管理委員会ごとに1つ)

- 譲渡不可で、発行者が更新できるNFT。法人登記([ADR 0005](../../decisions/0005-corporate-registration-model.md))と同じ形である。
- 項目: 名称、種別(`Party` / `FundRaisingBody` / `FundManagementBody` / `Other`)、代表者・会計責任者の氏名、関係する議員の氏名(資金管理団体のみ)。ADR 0005のルールに従い、氏名のみを載せ、個人のアドレスは載せない。
- 登録の流れ: 選挙管理委員会が`PoliticalFundFactory.createFund(controller)`を呼び、登録NFTを**新しい資金コントラクトのアドレスに**発行する。資金コントラクトがそのまま団体のオンチェーン上の本体になる。
- 解散: 選挙管理委員会がNFTをバーンし、資金コントラクトは収入の受け付けを停止する。

### `PoliticalFund`(団体ごとに1つ、`PoliticalFundFactory`からデプロイ)

- **管理者:** 団体のマルチシグ(法人アドレスと同じ考え方。どの監査済みマルチシグ規格を使うかはすでにBACKLOGにある)。
- **`contribute(amount, category, identityContract)`** が記録される唯一の入口である:
  1. `registry.kindOf(identityContract)`が`None`でないこと。
  2. `identityContract.balanceOf(msg.sender) > 0`であること。`ResidentLink`なら献金者は住民であり、`CorporateRegistration`なら献金者は登記NFTを保有する法人自身のアドレスである。
  3. 献金者が法人なら、この団体の種別が`Party`であること。
  4. **この**団体への、その年・その区分の献金者の累計に`amount`を足しても上限を超えないこと。
  5. 受け入れ対象のステーブルコインを`transferFrom`し、`accountedBalance`を増やし、`Contribution(donor, identityContract, category, amount, year)`を発行する。
- **区分:** `Donation`、`PartyTicket`、`MembershipFee`、`Other`。名目を問わず、すべての収入が同じ入口を通る(論点5)。上限は区分ごとに設定する。
- **年:** `block.timestamp`から求めた日本の暦年(UTC+9)。投票期間に続く、2つ目の正当化されたオンチェーン日付の例外である。
- **`spend(to, amount, purpose)`:** 管理者のみが呼べ、`amount ≤ accountedBalance`であること。イベントを発行する。
- **出所不明の資金**(`accountedBalance`を超えるトークン残高。`contribute`を迂回した直接送金で入ってくる)は使えない。`forfeitUnaccounted()`で国庫に送ることしかできない。誤って送金した本来の送金者は、オフチェーンで国庫に返金を請求する。「誰にでも返金できる」経路は意図的に設けない。追跡できない資金をコントラクト経由で洗浄する手段になるためである(Round 5)。

### 強制の分担

| ルール | 強制する場所 |
|---|---|
| 献金者が本物の`ResidentLink`を保有している、または登記済み法人である | コントラクト内(レジストリと併用) |
| 法人は政党にのみ献金可 | コントラクト内 |
| 受取先ごと・区分ごとの年間上限 | コントラクト内 |
| 支出は記録済み資金の範囲内、出所不明の資金は国庫へのみ | コントラクト内 |
| 受取先をまたぐ年間合計上限 | オンチェーンデータの事後監査 |
| 外国人・外資支配法人の献金禁止 | 事後監査 |
| 支出目的の正当性 | 事後監査 |

### 献金者の氏名を載せない理由(Round 4)

献金者のアドレスは必ず、市区町村が対面で本人確認した`ResidentLink`の保有者か、役員名が公開された登記済み法人のどちらかである。そのため巨額献金は簡単に追跡できる。チェーンを調べ、法的手続きで市区町村を通じてアドレスから人物を特定すればよい。氏名をオンチェーンに載せても追跡可能性は増えず、個人のプライバシー(ADR 0012)を損なうだけである。

## 今後の課題

- 団体解散時の残余資金の扱い([`docs/BACKLOG.md`](../../BACKLOG.md)で管理)。
- 総務省のレジストリ管理者の鍵管理: 漏えいすると偽の本人確認コントラクトが入り込める。監査済みマルチシグ規格を選ぶという既存のBACKLOG項目で扱う。
- 外資支配法人を監査するためのデータ: 法人登記は株主構成を記録していない。実質的支配者の透明性に関する既存のBACKLOG項目と関連する。

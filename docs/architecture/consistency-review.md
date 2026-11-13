# Cross-feature consistency review (2026-11)

Living document. The initial design of every non-⏸ item in [`docs/FEATURES.md`](../FEATURES.md) was completed on 2026-11-14 ([ADR 0030](../decisions/0030-securities-model.md)). Per [ADR 0017](../decisions/0017-executive-document-anchoring-v1.md), the whole design is reviewed for cross-feature consistency before any Solidity is written.

**Method.** Five read-only reviews ran in parallel, one per dimension: (1) the certified-address premise of [ADR 0020](../decisions/0020-certified-address-stablecoin.md); (2) the contract inventory and overlaps; (3) lifecycle events (move, emigration, death, key loss and theft, dissolution, officer change, leaving office, visitor expiry); (4) the privacy model; (5) documentation. Claude merged duplicates, checked the main findings against the text, and added a proposal for each. Each issue is then discussed with the user and fixed; the **Status** column tracks this.

Severity: **High** = a contradiction, or value or rights that get stuck; **Medium** = an undefined case or an unstated gap; **Low** = wording or naming.

## R1. The certified-address registry (`OfficialContractRegistry`)

| ID | Sev. | Issue | Proposal | Status |
|---|---|---|---|---|
| R1.1 | High | An address can hold **only one certified kind** (`certifiedKind(address) → None \| Resident \| …`), and each registrar writes on mint and burn. Burning a `ResidentLink` on emigration wipes `NonResidentOwner` ([ADR 0029](../decisions/0029-real-estate-registry-model.md)); burning one of a corporation's several registration NFTs ([ADR 0005](../decisions/0005-corporate-registration-model.md)) decertifies a corporation that is still registered; visitor → resident has the same problem. | **One flag per kind (and per registrar)**; an address is certified if any flag is set. | Open |
| R1.2 | Medium | The registry's lookups, kinds and writers are defined three ways (ADR 0015 `kindOf`, ADR 0019 adds `PublicTreasury`, ADR 0020 `certifiedKind` with registrars). `NonResidentOwner`, `ForeignInvestor`, the Legal Affairs Bureau, the FSA and `TenderFactory` are missing from the lists. | One **canonical registry section** in the certified-stablecoin spec: both lookups (contract kinds vs. certified addresses), every kind, and the registrar of each. | Open |
| R1.3 | Medium | Some money-holding contracts have no registrar: `ClearingContract`, trust/partnership/fund addresses ([ADR 0030](../decisions/0030-securities-model.md)), `RealEstateToken`. | Name one: 総務省 for public bodies' contracts (incl. the bureau's); the FSA for the clearing contract and investment vehicles. | Open |
| R1.4 | Medium | `AnchorRegistry.anchor` accepts only certified corporate or public addresses, but a public body's only certified address is its `PublicTreasury` (which only exposes `pay()`), and sole proprietors are `Resident` kind. Both must anchor ([ADR 0028](../decisions/0028-personal-data-model.md), ADR 0029). | Certify each public body's controlling multisig as a public-body kind; allow `Resident` callers for sole proprietors. | Open |
| R1.5 | Medium | Pre-ADR 0020 texts still say "no on-chain registry" (citizenship, corporations), "no allowlist of accepted tokens" (ADR 0004, taxation), and the political fund's registration omits the certified list. | Add in-place notes pointing to ADR 0020. | Open |
| R1.6 | Medium | "One `PublicTreasury` per body" (ADR 0019) vs. one receiving address per tax type (ADR 0004) and two pension contracts (ADR 0024). Extra addresses must themselves be certified. | Change to **one treasury per body per account**; tax receiving addresses are `PublicTreasury` contracts. | Open |

## R2. People and bodies without a `ResidentLink`

| ID | Sev. | Issue | Proposal | Status |
|---|---|---|---|---|
| R2.1 | High | The treasury payee check (ADR 0019) accepts only `ResidentLink`, `CorporateRegistration` or `PublicTreasury`. It rejects payments into `RealEstateToken` settlement (a public body buying land), to `NonResidentOwner`, `ForeignInvestor`, and to a `PoliticalFund` (party grants have no route at all). ADR 0020 already makes the stablecoin refuse uncertified recipients. | Payee check = **"certified, any kind except `Visitor`"**; add a `PublicGrant` category to the political fund. | Open |
| R2.2 | High | **Emigration is missing from the stablecoin design.** `NonResidentOwner` exists only for land owners, so a national abroad without land has no certified address: they cannot hold JPY, receive a pension or survivors' payment, or inherit. | Make `NonResidentOwner` a **general kind for nationals abroad** (rename, e.g. `NationalAbroad`), not tied to land; add an emigration row to ADR 0020; decide whether pensions are paid abroad. | Open |
| R2.3 | Medium | No certified kind for: `EmployeeID` holders who never lived in Japan (ADR 0010); foreign corporations and foreign non-residents paying rent (leases are allowed to anyone, ADR 0029); foreign companies' branches (ADR 0005 is silent). | Decide per case: a certified-operator route (cross-border payment, backlog) or a new kind; state it in ADRs 0005 and 0010. | Open |

## R3. Lifecycle events

| ID | Sev. | Issue | Proposal | Status |
|---|---|---|---|---|
| R3.1 | High | In the heavy successor path, "the old address can veto by signing". After **key theft** the thief holds that key and can block recovery forever. | A theft reported in person turns a veto into court review instead of ending the migration. | Open |
| R3.2 | High | **Shares have no successor path** (real estate has one), and a broker's operator approval and allowance outlive the holder's death, key loss or decertification. | Authorise the heavy-path multisig on **every asset-token contract** (state it once in ADR 0020); approvals lapse when the holder is decertified. | Open |
| R3.3 | High | **Mint-once credentials cannot follow a new address** (key loss, VIP leaving office): the diploma is "mint-once, no renewal"; `Vaccinated` is never burned. | Credentials-wide rule: the issuer burns and re-issues to the successor address, citing the migration record. | Open |
| R3.4 | Medium | The heavy path assumes a municipality proposes it; undefined for a dissolved corporation's residue, `NonResidentOwner`, `ForeignInvestor`, visitors. | The **registrar of the address's kind** proposes. | Open |
| R3.5 | Medium | Dissolution and merger: issued employee IDs and health-insurance tokens stay live (and corrupt insured months in unemployment insurance); share classes need the corporation's own multisig to cancel; merger is absent from ADR 0020. | Before the registration NFT is burned, the corporation burns outstanding credentials and cancels its share classes; a merger is a light-path transfer to the acquirer. | Open |
| R3.6 | Medium | **A corporation's multisig signer rotation is undefined** (officer death, key loss, emigration). If the threshold cannot be met, its money, land and shares freeze. | Specify rotation, with an authority override, and whether a decertified signer still counts. | Open |
| R3.7 | Medium | A granted voting right can never be revoked: an old key, a thief or a dead person's address can still vote (petitions have `removeEligible`). | Re-check `ResidentLink` at `castBallot`, or add `revokeVotingRight`. | Open |
| R3.8 | Medium | The gap during a move (burn → re-mint) looks like a death: treasury payments revert, the real estate design reads it as an unhandled inheritance, and one reverting delivery could fail the whole daily clearing batch. | Retry rule for payments; each clearing delivery fails on its own; death is signalled by more than a burn. | Open |
| R3.9 | Medium | Heirs cannot receive land: a token cannot be received without agents, but the heavy-path proposal has no agent field. | Add the new owners' agents to the proposal. | Open |
| R3.10 | Low | Death is not a burn reason for passports and licences; nationals abroad cannot prove their age (the age check requires a valid `ResidentLink`). | Add death as a burn reason; accept the R2.2 kind (or the passport) for age checks. | Open |

## R4. Overlapping registries and naming

| ID | Sev. | Issue | Proposal | Status |
|---|---|---|---|---|
| R4.1 | Medium | Four hash-anchoring registries: `DocumentRegistry` (stores), `EvidenceRegistry` (stores), `CaseRecordRegistry` (stores, and must reject disposal), `AnchorRegistry` (event-only, because nobody reads anchors from a contract). The same reasoning applies to the first two. | **Make `DocumentRegistry` and `EvidenceRegistry` kinds of `AnchorRegistry`**; keep `CaseRecordRegistry` (it needs stored state). Record in an ADR. | Open |
| R4.2 | Medium | No rule for which registry a document goes to; `DocumentRegistry` was limited to approval documents (ADR 0017) but later designs put subsidy reports and employers' statements in it. | Follows from R4.1: everything anchors in `AnchorRegistry` with a kind; keep a **kind list** there. | Open |
| R4.3 | Low | Naming and standards drift: `RealEstateToken` vs. `ShareRegistry` (same pattern); no token standard named for them; unnamed election factory; visitor expiry stored twice; the corporate-registration contract is never named. | One naming and standards pass. | Open |

## R5. Privacy

The principle being applied: address-only information may be public (real estate, Round 5), but **a design must not let third parties link an address to a person** without that person's own act.

| ID | Sev. | Issue | Proposal | Status |
|---|---|---|---|---|
| R5.1 | High | **One-officer corporations link the officer's name to their address**: officer names are public, and the multisig signers are the officers' own addresses. With one officer the pairing is exact. | User decision: accept it as part of running a corporation (as for VIPs), or sign with a per-corporation key (rejected once before). | Open |
| R5.2 | High | **Beneficial owners:** with one 25%+ owner (the normal case in owner-run companies), the single published name is the single address found by tracing; the count check makes it explicit. ADR 0030 says names are "never linked". | Declare beneficial owners a **public class like VIPs** (consistent with "corporations open"), or drop the names and leave the check to the regulator. | Open |
| R5.3 | High | Real estate: when a token passes between a published holder (corporation, VIP) and an individual, the published lot number and salt reveal the individual's address and home (e.g. a developer selling a new house). | The bureau **re-mints with a new ID and salt** when a token passes between published and unpublished holders, and states the remaining limit (the settlement still pairs the two addresses). | Open |
| R5.4 | High | Personal data: the delivery label carries the buyer's **chain address** on a box at their door, and the carrier builds an address-to-home map. | Label with a **one-time order code**, never the chain address. | Open |
| R5.5 | Medium | Age-threshold credentials are minted on the day the person reaches the age, which reveals the birth date. | Mint in **monthly or yearly batches**, or let the person claim it. | Open |
| R5.6 | Medium | VIPs: regular transfers to family and family members as real estate agents mark family addresses. | State as an accepted cost of office, and recommend professional agents. | Open |
| R5.7 | Low | Grants to sole proprietors and pay to office-holders named by role can join names to addresses through published grant records or unique budget codes. | Individuals appear only by address in grant records; no budget code unique to one named person. | Open |
| R5.8 | Low | "Only the municipality knows which address is which person" is no longer true (carriers, creditors, counterparties); ADR 0005 contradicts itself on officer addresses. | Restate as "no public link; others learn it only through the person's own act or legal process"; fix ADR 0005's wording. | Open |
| R5.9 | — | **Simplification candidates** under the new principle: a standing nationality/voter roll instead of per-election and per-petition lists (would also let the donation contract enforce the foreign-donation ban); the shared social-security budget code (keep, but give stigma as the reason); the VIP's switch to a new address on leaving office (hides nothing). | User decision, item by item. | Open |

## R6. Documentation (no design decision needed)

Mechanical fixes Claude can make directly:
- **Missing Japanese translations:** ADRs 0001–0013, `docs/decisions/template.md`, the citizenship discussion log; the credentials discussion log has its Japanese part out of order; the diploma log's English Round 1 lacks a Status; `CHANGELOG.md` and the feature template have none.
- **Stale status text:** credentials overview ("🟡 Discussing"), legislative spec (direct-demand "🔴 Not started"), `docs/state-design/README.md` ("first function under discussion"), `docs/PROJECT_STATUS.md` open questions and "key documents" wording.
- **Back-references:** ADR 0015 ← 0020, ADR 0028 ← 0029/0030, ADR 0012 ← 0027, the ADR index entry for 0014 (partly superseded), and a Japanese index in `docs/decisions/README.md`.
- **Backlog:** close or restate rows whose prerequisites are met (political fund dissolution, financial infrastructure, shareholder voting); fix the dangling "cross-border payment item above"; tidy closed rows.
- **Small fixes:** one broken anchor in the vaccination spec; the FEATURES footer still lists beneficial ownership as open; README's wealth-services status cell; CHANGELOG order.

| ID | Status |
|---|---|
| R6 | Open |

---

# 機能間の整合性レビュー(2026-11)(日本語)

生きたドキュメントです。[`docs/FEATURES.md`](../FEATURES.md)の⏸以外のすべての項目の初期設計は、2026-11-14に完了した([ADR 0030](../decisions/0030-securities-model.md))。[ADR 0017](../decisions/0017-executive-document-anchoring-v1.md)に従い、Solidityを書く前に設計全体の機能間の整合性をレビューする。

**方法。** 観点ごとに1つ、計5つの読み取り専用のレビューを並行して行った: (1) [ADR 0020](../decisions/0020-certified-address-stablecoin.md)の認定アドレス制の前提、(2) コントラクトの一覧と重なり、(3) ライフサイクルの出来事(転居、海外への転出、死亡、鍵の紛失と盗難、解散、役員の交代、退任、ビジターパスの失効)、(4) プライバシーの扱い、(5) ドキュメント。Claudeが重複をまとめ、主な指摘を原文で確認し、それぞれに提案を付けた。各論点はユーザーと議論してから修正し、**ステータス**の列で追跡する。

重大度: **High** = 矛盾、または価値や権利が動かせなくなる。**Medium** = 定義されていない場合、または書かれていない抜け。**Low** = 表現や命名。

## R1. 認定アドレスのレジストリ(`OfficialContractRegistry`)

| ID | 重大度 | 論点 | 提案 | ステータス |
|---|---|---|---|---|
| R1.1 | High | 1つのアドレスは**認定の種類を1つしか持てず**(`certifiedKind(address) → None \| Resident \| …`)、各登録者はmintとburnのときに書き込む。海外への転出で`ResidentLink`をburnすると`NonResidentOwner`([ADR 0029](../decisions/0029-real-estate-registry-model.md))が消える。法人が持つ複数の登録NFTの1つをburnすると([ADR 0005](../decisions/0005-corporate-registration-model.md))、まだ登録されている法人の認定が外れる。ビジターから住民になる場合も同じ問題がある。 | **種類ごと(登録者ごと)に1つのフラグ**。どれかが立っていれば認定済み。 | 未決 |
| R1.2 | Medium | レジストリの照会、種類、書き込む者が3通りに定義されている(ADR 0015の`kindOf`、ADR 0019が`PublicTreasury`を追加、ADR 0020の`certifiedKind`と登録者)。`NonResidentOwner`、`ForeignInvestor`、法務局、金融庁、`TenderFactory`が一覧から抜けている。 | 認定ステーブルコインの仕様に**正本となるレジストリの節**を1つ: 2つの照会(コントラクトの種類と認定アドレス)、すべての種類、それぞれの登録者。 | 未決 |
| R1.3 | Medium | 登録者のいない、資金を持つコントラクトがある: `ClearingContract`、信託・組合・ファンドのアドレス([ADR 0030](../decisions/0030-securities-model.md))、`RealEstateToken`。 | 登録者を定める: 公的機関のコントラクト(法務局のものを含む)は総務省、清算コントラクトと投資の器は金融庁。 | 未決 |
| R1.4 | Medium | `AnchorRegistry.anchor`は認定された法人か公的なアドレスしか受け付けないが、公的機関の認定アドレスは`PublicTreasury`だけで(`pay()`しかない)、個人事業主は`Resident`の種類である。どちらもアンカリングしなければならない([ADR 0028](../decisions/0028-personal-data-model.md)、ADR 0029)。 | 各公的機関の管理用マルチシグを公的機関の種類として認定する。個人事業主のために`Resident`の呼び出しを認める。 | 未決 |
| R1.5 | Medium | ADR 0020より前の文書が、今も「オンチェーンのレジストリはない」(国民・住民、法人)、「受け付けるトークンの許可リストはない」(ADR 0004、納税)と書いており、政治資金の登録には認定リストが出てこない。 | ADR 0020を指す注記をその場に加える。 | 未決 |
| R1.6 | Medium | 「公的機関ごとに`PublicTreasury`を1つ」(ADR 0019)と、税目ごとの受取アドレス(ADR 0004)、年金の2つのコントラクト(ADR 0024)が食い違う。追加のアドレスはそれ自体が認定されていなければならない。 | **公的機関ごと・勘定ごとに国庫を1つ**に改める。税の受取アドレスは`PublicTreasury`のコントラクトとする。 | 未決 |

## R2. `ResidentLink`を持たない人と組織

| ID | 重大度 | 論点 | 提案 | ステータス |
|---|---|---|---|---|
| R2.1 | High | 国庫の支払先チェック(ADR 0019)は`ResidentLink`、`CorporateRegistration`、`PublicTreasury`しか受け付けない。`RealEstateToken`の決済(公的機関の土地の購入)、`NonResidentOwner`、`ForeignInvestor`、`PoliticalFund`への支払い(政党交付金の経路がそもそもない)を拒否する。ADR 0020ですでにステーブルコイン自体が認定されていない受取人を拒む。 | 支払先チェックは**「認定済みで、`Visitor`以外の種類」**。政治資金に`PublicGrant`の区分を加える。 | 未決 |
| R2.2 | High | **海外への転出がステーブルコインの設計にない。** `NonResidentOwner`は土地の所有者にしかないので、土地を持たない海外の国民には認定アドレスがない: 円を持てず、年金や遺族への支払いを受けられず、相続もできない。 | `NonResidentOwner`を土地と切り離し、**海外に住む国民の一般的な種類**にする(例: `NationalAbroad`に改名)。ADR 0020に海外転出の行を加える。年金を海外に払うかを決める。 | 未決 |
| R2.3 | Medium | 認定の種類がない: 日本に住んだことのない`EmployeeID`の保有者(ADR 0010)。賃料を払う外国法人と外国人の非居住者(借地は誰にでも認めた、ADR 0029)。外国会社の支店(ADR 0005は触れていない)。 | 場合ごとに決める: 認定された事業者の経路(国境を越える支払い、バックログ)か、新しい種類か。ADR 0005と0010に記す。 | 未決 |

## R3. ライフサイクルの出来事

| ID | 重大度 | 論点 | 提案 | ステータス |
|---|---|---|---|---|
| R3.1 | High | 重い承継の手続きでは「古いアドレスは署名で拒否できる」。**鍵の盗難**の後は盗んだ者がその鍵を持ち、回復を永久に止められる。 | 窓口で届け出た盗難の場合、拒否は手続きを終わらせず、裁判所の審査に回す。 | 未決 |
| R3.2 | High | **株式には承継の経路がない**(不動産にはある)。証券会社のオペレーターの承認とallowanceが、保有者の死亡、鍵の紛失、認定の喪失の後も残る。 | 重い手続きのマルチシグに**すべての資産トークンのコントラクト**での権限を与える(ADR 0020で一度だけ定める)。保有者の認定が外れたら承認は失効する。 | 未決 |
| R3.3 | High | **一度しかmintしないクレデンシャルは新しいアドレスに移れない**(鍵の紛失、要人の退任): 卒業証明は「一度だけmint、更新なし」、`Vaccinated`は決してburnされない。 | クレデンシャル全体のルール: 発行者がburnし、承継の記録を示して承継先のアドレスに再発行する。 | 未決 |
| R3.4 | Medium | 重い手続きは市区町村が提案する前提である。解散した法人の残余、`NonResidentOwner`、`ForeignInvestor`、ビジターでは定義されていない。 | そのアドレスの**種類の登録者**が提案する。 | 未決 |
| R3.5 | Medium | 解散と合併: 発行済みの社員証や健康保険証が有効なまま残り(雇用保険の被保険者期間を狂わせる)、株式の種類の消却には法人自身のマルチシグが必要で、合併はADR 0020にない。 | 登録NFTをburnする前に、法人は発行済みのクレデンシャルをburnし、株式の種類を消却する。合併は取得する法人への軽い手続きの移転とする。 | 未決 |
| R3.6 | Medium | **法人のマルチシグの署名者の交代が定義されていない**(役員の死亡、鍵の紛失、海外転出)。必要数に届かなくなると、資金、土地、株式が動かせなくなる。 | 交代の手続きを定める(監督官庁による上書きを含む)。認定の外れた署名者を数えるかも定める。 | 未決 |
| R3.7 | Medium | 付与した投票権は取り消せない: 古い鍵、盗んだ者、亡くなった人のアドレスでも投票できる(直接請求には`removeEligible`がある)。 | `castBallot`で`ResidentLink`を再確認する、または`revokeVotingRight`を加える。 | 未決 |
| R3.8 | Medium | 転居の間の空白(burn → 再mint)が死亡と同じに見える: 国庫の支払いはrevertし、不動産の設計は未処理の相続と読み、1件の受け渡しのrevertが毎日の清算全体を失敗させうる。 | 支払いの再試行のルール。清算の受け渡しは1件ずつ失敗する。死亡はburn以外でも示す。 | 未決 |
| R3.9 | Medium | 相続人が土地を受け取れない: 代理人なしではトークンを受け取れないが、重い手続きの提案に代理人の欄がない。 | 提案に新しい所有者の代理人を加える。 | 未決 |
| R3.10 | Low | パスポートと免許証のburnの理由に死亡がない。海外の国民は年齢を証明できない(年齢の確認に有効な`ResidentLink`が必要)。 | 死亡をburnの理由に加える。年齢の確認にR2.2の種類(またはパスポート)を認める。 | 未決 |

## R4. 重なるレジストリと命名

| ID | 重大度 | 論点 | 提案 | ステータス |
|---|---|---|---|---|
| R4.1 | Medium | ハッシュをアンカリングするレジストリが4つある: `DocumentRegistry`(保存する)、`EvidenceRegistry`(保存する)、`CaseRecordRegistry`(保存し、廃棄を拒否しなければならない)、`AnchorRegistry`(イベントだけ。コントラクトからアンカーを読む者がいないため)。同じ理由が最初の2つにも当てはまる。 | **`DocumentRegistry`と`EvidenceRegistry`を`AnchorRegistry`の種類にする。** `CaseRecordRegistry`は残す(保存された状態が必要)。ADRに記録する。 | 未決 |
| R4.2 | Medium | どの文書をどのレジストリに入れるかのルールがない。`DocumentRegistry`は決裁文書に限っていたが(ADR 0017)、後の設計が補助金の報告や雇用主の証明を入れている。 | R4.1から導かれる: すべて種類を付けて`AnchorRegistry`にアンカリングする。そこに**種類の一覧**を置く。 | 未決 |
| R4.3 | Low | 命名と規格のずれ: `RealEstateToken`と`ShareRegistry`(同じ型)、どちらもトークンの規格を定めていない、名前のない選挙のファクトリー、ビジターの有効期限が2か所に保存される、法人登録のコントラクトに名前がない。 | 命名と規格を一度にそろえる。 | 未決 |

## R5. プライバシー

適用する原則: アドレスだけの情報は公開してよい(不動産、Round 5)。ただし**本人の行為なしに、第三者がアドレスを人物と結びつけられる設計にしてはならない**。

| ID | 重大度 | 論点 | 提案 | ステータス |
|---|---|---|---|---|
| R5.1 | High | **役員が1人の法人では、役員の氏名とアドレスが結びつく**: 役員の氏名は公開で、マルチシグの署名者は役員自身のアドレスである。1人なら対応は確定する。 | ユーザーの判断: 法人を営むことの一部として受け入れる(要人と同様)か、法人ごとの鍵で署名する(以前に不採用)か。 | 未決 |
| R5.2 | High | **実質的支配者:** 25%以上の所有者が1人の場合(オーナー経営の会社では普通)、公開された1つの氏名は、たどって見つかる1つのアドレスである。人数の照合がそれを明示する。ADR 0030は氏名を「決して結びつけない」としている。 | 実質的支配者を**要人と同じ公開の層**とする(「法人は公開」と整合)か、氏名をやめて照合を規制当局に任せるか。 | 未決 |
| R5.3 | High | 不動産: 公開される保有者(法人、要人)と個人の間でトークンが移ると、公開された地番とソルトから、個人のアドレスと住まいがわかる(例: 開発業者が新築の家を個人に売る)。 | 公開と非公開の保有者の間を移るとき、法務局が**新しいIDとソルトで再mintする**。残る限界(決済が2つのアドレスを結ぶ)を明記する。 | 未決 |
| R5.4 | High | 個人情報: 配送ラベルに購入者の**チェーンのアドレス**が載り、玄関先の箱に付く。配送業者はアドレスと住まいの対応表を作れる。 | ラベルには**1回限りの注文コード**を使い、チェーンのアドレスは使わない。 | 未決 |
| R5.5 | Medium | 年齢の基準のクレデンシャルは、その年齢に達した日にmintされ、生年月日がわかる。 | **月ごとか年ごとにまとめてmint**する、または本人が請求する。 | 未決 |
| R5.6 | Medium | 要人: 家族への定期的な送金や、不動産の代理人としての家族が、家族のアドレスを特定させる。 | 公職の代償として受け入れると明記し、専門家の代理人を勧める。 | 未決 |
| R5.7 | Low | 個人事業主への補助金や、役職で特定される公職者への報酬は、公開の交付の記録や一意の予算コードを通じて氏名とアドレスを結びつけうる。 | 交付の記録では個人はアドレスだけで示す。名前のわかる1人だけに対応する予算コードを作らない。 | 未決 |
| R5.8 | Low | 「どのアドレスが誰かを知るのは市区町村だけ」はもう正しくない(配送業者、債権者、取引の相手方)。ADR 0005は役員のアドレスについて自己矛盾している。 | 「公開の結びつきはない。他者が知るのは本人の行為か法的な手続きによってだけ」と言い直す。ADR 0005の表現を直す。 | 未決 |
| R5.9 | — | 新しい原則のもとでの**簡素化の候補**: 選挙や直接請求ごとのリストの代わりに常設の国籍・選挙人の名簿(政治献金のコントラクトが外国人からの献金の禁止を自ら執行できるようにもなる)。社会保障の共通の予算コード(残すが、理由は偏見を避けるためとする)。要人の退任時の新しいアドレスへの切り替え(何も隠していない)。 | ユーザーの判断、項目ごと。 | 未決 |

## R6. ドキュメント(設計の判断は不要)

Claudeが直接直せる機械的な修正:
- **日本語訳の欠落:** ADR 0001〜0013、`docs/decisions/template.md`、国民・住民の議論ログ。公的証明の議論ログは日本語部分の順序が逆。卒業証明のログは英語のRound 1にステータスがない。`CHANGELOG.md`と機能のテンプレートには日本語がない。
- **古いステータスの記述:** 公的証明の総論(「🟡 議論中」)、立法の仕様(直接請求が「🔴 未着手」)、`docs/state-design/README.md`(「最初に議論する機能」)、`docs/PROJECT_STATUS.md`の未解決の論点と「主要な文書」という表現。
- **相互参照:** ADR 0015 ← 0020、ADR 0028 ← 0029/0030、ADR 0012 ← 0027、ADRの索引の0014(一部上書き)、`docs/decisions/README.md`の日本語の索引。
- **バックログ:** 前提が満たされた行(政治団体の解散時の資金、金融の基盤、株主総会の議決権行使)を閉じるか言い直す。宙に浮いた「上の国境を越える支払いの項目」を直す。閉じた行を整える。
- **細かい修正:** 接種証明の仕様の壊れたアンカー1つ。FEATURESの末尾が実質的支配者をまだ未決としている。READMEの富裕層向け金融サービスのステータス欄。CHANGELOGの順序。

| ID | ステータス |
|---|---|
| R6 | 未決 |

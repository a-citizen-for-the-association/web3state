# Cross-feature consistency review (2026-11)

Living document. The initial design of every non-⏸ item in [`docs/FEATURES.md`](../FEATURES.md) was completed on 2026-11-14 ([ADR 0030](../decisions/0030-securities-model.md)). Per [ADR 0017](../decisions/0017-executive-document-anchoring-v1.md), the whole design is reviewed for cross-feature consistency before any Solidity is written.

**Method.** Five read-only reviews ran in parallel, one per dimension: (1) the certified-address premise of [ADR 0020](../decisions/0020-certified-address-stablecoin.md); (2) the contract inventory and overlaps; (3) lifecycle events (move, emigration, death, key loss and theft, dissolution, officer change, leaving office, visitor expiry); (4) the privacy model; (5) documentation. Claude merged duplicates, checked the main findings against the text, and added a proposal for each. Each issue is then discussed with the user and fixed; the **Status** column tracks this.

Severity: **High** = a contradiction, or value or rights that get stuck; **Medium** = an undefined case or an unstated gap; **Low** = wording or naming.

## R1. The certified-address registry (`OfficialContractRegistry`)

| ID | Sev. | Issue | Proposal | Status |
|---|---|---|---|---|
| R1.1 | High | An address can hold **only one certified kind** (`certifiedKind(address) → None \| Resident \| …`), and each registrar writes on mint and burn. Burning a `ResidentLink` on emigration wipes `NonResidentOwner` ([ADR 0029](../decisions/0029-real-estate-registry-model.md)); burning one of a corporation's several registration NFTs ([ADR 0005](../decisions/0005-corporate-registration-model.md)) decertifies a corporation that is still registered; visitor → resident has the same problem. | **One flag per kind (and per registrar)**; an address is certified if any flag is set. | **Accepted** (2026-11-21) |
| R1.2 | Medium | The registry's lookups, kinds and writers are defined three ways (ADR 0015 `kindOf`, ADR 0019 adds `PublicTreasury`, ADR 0020 `certifiedKind` with registrars). `NonResidentOwner`, `ForeignInvestor`, the Legal Affairs Bureau, the FSA and `TenderFactory` are missing from the lists. | One **canonical registry section** in the certified-stablecoin spec: both lookups (contract kinds vs. certified addresses), every kind, and the registrar of each. | **Accepted** (2026-11-21) |
| R1.3 | Medium | Some money-holding contracts have no registrar: `ClearingContract`, trust/partnership/fund addresses ([ADR 0030](../decisions/0030-securities-model.md)), `RealEstateToken`. | Name one: 総務省 for public bodies' contracts (incl. the bureau's); the FSA for the clearing contract and investment vehicles. | **Accepted** (2026-11-21); confirmed under D1: only supervised financial vehicles may register among private contracts |
| R1.4 | Medium | `AnchorRegistry.anchor` accepts only certified corporate or public addresses, but a public body's only certified address is its `PublicTreasury` (which only exposes `pay()`), and sole proprietors are `Resident` kind. Both must anchor ([ADR 0028](../decisions/0028-personal-data-model.md), ADR 0029). | Certify each public body's controlling multisig as a public-body kind; allow `Resident` callers for sole proprietors. | **Accepted** (2026-11-21) |
| R1.5 | Medium | Pre-ADR 0020 texts still say "no on-chain registry" (citizenship, corporations), "no allowlist of accepted tokens" (ADR 0004, taxation), and the political fund's registration omits the certified list. | Add in-place notes pointing to ADR 0020. | **Accepted** (2026-11-21) |
| R1.6 | Medium | "One `PublicTreasury` per body" (ADR 0019) vs. one receiving address per tax type (ADR 0004) and two pension contracts (ADR 0024). Extra addresses must themselves be certified. | Change to **one treasury per body per account**; tax receiving addresses are `PublicTreasury` contracts. | **Accepted** (2026-11-21) |

## R2. People and bodies without a `ResidentLink`

| ID | Sev. | Issue | Proposal | Status |
|---|---|---|---|---|
| R2.1 | High | The treasury payee check (ADR 0019) accepts only `ResidentLink`, `CorporateRegistration` or `PublicTreasury`. It rejects payments into `RealEstateToken` settlement (a public body buying land), to `NonResidentOwner`, `ForeignInvestor`, and to a `PoliticalFund` (party grants have no route at all). ADR 0020 already makes the stablecoin refuse uncertified recipients. | Payee check = **"certified, any kind except `Visitor`"**; add a `PublicGrant` category to the political fund. | **Accepted** (2026-11-21) |
| R2.2 | High | **Emigration is missing from the stablecoin design.** `NonResidentOwner` exists only for land owners, so a national abroad without land has no certified address: they cannot hold JPY, receive a pension or survivors' payment, or inherit. | Make `NonResidentOwner` a **general kind for nationals abroad** (rename, e.g. `NationalAbroad`), not tied to land; add an emigration row to ADR 0020; decide whether pensions are paid abroad. | **Accepted** (2026-11-21; issuer moved to 外務省, renamed `NationalAbroad`); confirmed under D1 (2026-11-21) |
| R2.3 | Medium | No certified kind for: `EmployeeID` holders who never lived in Japan (ADR 0010); foreign corporations and foreign non-residents paying rent (leases are allowed to anyone, ADR 0029); foreign companies' branches (ADR 0005 is silent). | Decide per case: a certified-operator route (cross-border payment, backlog) or a new kind; state it in ADRs 0005 and 0010. | **Accepted, revised under D1** (2026-11-21): no `ForeignParty` kind; payments above the cap go through licensed exchangers or banks (also for the treasury's lump-sum withdrawal payments); `ForeignInvestor` kept for shares only; foreign companies' branches registered as corporations with a foreign flag |

## Decision D1 (2026-11-21): the transfer rule is relaxed — [ADR 0031](../decisions/0031-registered-address-transfer-rule.md)

While discussing R2.3, the user judged that the review had gone in the wrong direction: ADR 0020's "both ends certified" rule blocked too much. New rule (provisional, revisited after the proofs of concept): one registered address per resident and corporation; sending from a registered to an unregistered address is capped by a cumulative amount per sender per period; VIPs' cap is zero; licensed exchangers and the issuer are exempt; public treasuries pay only registered addresses; everything else is checked afterwards from public data.

**Items to re-examine under D1:** R1.3 (confirmed: only supervised financial vehicles may register among private contracts), R2.2 (confirmed: `NationalAbroad` kept), R2.3 (revised: no `ForeignParty`), the visitor pass (**abolished**, 2026-11-21; exchangers may send to unregistered addresses only when exchanging the recipient's own foreign currency or cash), and R3.4 and R3.8 (decertified addresses are no longer frozen; handled with R3).

## R3. Lifecycle events

| ID | Sev. | Issue | Proposal | Status |
|---|---|---|---|---|
| R3.1 | High | In the heavy successor path, "the old address can veto by signing". After **key theft** the thief holds that key and can block recovery forever. | A theft reported in person turns a veto into court review instead of ending the migration. | **Accepted, revised under D1** (2026-11-21): a theft report does not burn the `ResidentLink`; the municipality marks the address **suspended** (nothing can leave it except by the heavy path); a suspended address cannot veto; suspension needs the owner in person and lapses unless a court approves within a set period (e.g. two weeks) |
| R3.2 | High | **Shares have no successor path** (real estate has one), and a broker's operator approval and allowance outlive the holder's death, key loss or decertification. | Authorise the heavy-path multisig on **every asset-token contract** (state it once in ADR 0020); approvals lapse when the holder is decertified. | **Accepted, extended under D1** (2026-11-21): the heavy path is authorised on every asset-token contract (stated once in ADR 0020); operator approvals and allowances lapse when the holder's registration ends or the address is suspended; land and shares at an address that lost its registration move only by the heavy path |
| R3.3 | High | **Mint-once credentials cannot follow a new address** (key loss, VIP leaving office): the diploma is "mint-once, no renewal"; `Vaccinated` is never burned. | Credentials-wide rule: the issuer burns and re-issues to the successor address, citing the migration record. | **Accepted** (2026-11-21): credentials-wide rule — after a recorded address succession, each issuer may burn and re-issue to the successor address (on the person's request, checking the on-chain record); a successor body re-issues for closed issuers; the diploma's no-reissue and vaccination's never-burn rules yield in this case |
| R3.4 | Medium | The heavy path assumes a municipality proposes it; undefined for a dissolved corporation's residue, `NonResidentOwner`, `ForeignInvestor`, visitors. | The **registrar of the address's kind** proposes. | **Accepted** (2026-11-21): the registrar of the address's kind proposes the heavy path (municipality, 外務省, the corporation's registrar, the FSA); court approval and waiting period unchanged |
| R3.5 | Medium | Dissolution and merger: issued employee IDs and health-insurance tokens stay live (and corrupt insured months in unemployment insurance); share classes need the corporation's own multisig to cancel; merger is absent from ADR 0020. | Before the registration NFT is burned, the corporation burns outstanding credentials and cancels its share classes; a merger is a light-path transfer to the acquirer. | **Accepted** (2026-11-21): before the registration NFT is burned, the corporation (liquidator) burns its issued credentials, cancels its share classes and distributes assets, checked by the registrar from public data; leftovers via the heavy path (R3.4); a merger is a light-path transfer signed by both multisigs and confirmed by the bureau (employee IDs re-issued, shares exchanged and cancelled); the vaccinator's registration is checked at every `markVaccinated` |
| R3.6 | Medium | **A corporation's multisig signer rotation is undefined** (officer death, key loss, emigration). If the threshold cannot be met, its money, land and shares freeze. | Specify rotation, with an authority override, and whether a decertified signer still counts. | **Accepted** (2026-11-21): normal rotation by the multisig itself alongside the registered officer change; if the threshold cannot be met, the registrar replaces signers on a registered officer change after a public waiting period (objections go to a court); decertified or suspended signers do not count (`NationalAbroad` officers still count) |
| R3.7 | Medium | A granted voting right can never be revoked: an old key, a thief or a dead person's address can still vote (petitions have `removeEligible`). | Re-check `ResidentLink` at `castBallot`, or add `revokeVotingRight`. | **Accepted** (2026-11-21): `castBallot` re-checks a valid `ResidentLink` and no suspension; after a recorded succession the board grants the right to the new address on request |
| R3.8 | Medium | The gap during a move (burn → re-mint) looks like a death: treasury payments revert, the real estate design reads it as an unhandled inheritance, and one reverting delivery could fail the whole daily clearing batch. | Retry rule for payments; each clearing delivery fails on its own; death is signalled by more than a burn. | **Accepted** (2026-11-21): on a domestic move the new municipality mints first and the old one burns afterwards (no gap; the move-out declaration replaces the `everIssued` check); clearing deliveries fail one by one and are retried; failed treasury payments stay owed and are retried; an address with no registration left now means death or similar |
| R3.9 | Medium | Heirs cannot receive land: a token cannot be received without agents, but the heavy-path proposal has no agent field. | Add the new owners' agents to the proposal. | **Accepted** (2026-11-21): the succession proposal carries each receiving individual's agents (signed by that heir); land shared among heirs is re-issued by the bureau as co-ownership share tokens, each with its holder's agents |
| R3.10 | Low | Death is not a burn reason for passports and licences; nationals abroad cannot prove their age (the age check requires a valid `ResidentLink`). | Add death as a burn reason; accept the R2.2 kind (or the passport) for age checks. | **Accepted** (2026-11-21): credentials-wide rule — issuers burn on death, informed off-chain by the municipality; age checks accept `NationalAbroad` in place of `ResidentLink` |

## R4. Overlapping registries and naming

| ID | Sev. | Issue | Proposal | Status |
|---|---|---|---|---|
| R4.1 | Medium | Four hash-anchoring registries: `DocumentRegistry` (stores), `EvidenceRegistry` (stores), `CaseRecordRegistry` (stores, and must reject disposal), `AnchorRegistry` (event-only, because nobody reads anchors from a contract). The same reasoning applies to the first two. | **Make `DocumentRegistry` and `EvidenceRegistry` kinds of `AnchorRegistry`**; keep `CaseRecordRegistry` (it needs stored state). Record in an ADR. | **Accepted** (2026-11-21): `DocumentRegistry` and `EvidenceRegistry` become kinds of `AnchorRegistry` (`previousId` and evidence status carried in events); `CaseRecordRegistry` stays; recorded in a new ADR |
| R4.2 | Medium | No rule for which registry a document goes to; `DocumentRegistry` was limited to approval documents (ADR 0017) but later designs put subsidy reports and employers' statements in it. | Follows from R4.1: everything anchors in `AnchorRegistry` with a kind; keep a **kind list** there. | **Accepted** (2026-11-21): the author of a document anchors it from its own registered address; one kind list kept with the registry's canonical section; the contract does not restrict kinds (obligations are law, checked afterwards) |
| R4.3 | Low | Naming and standards drift: `RealEstateToken` vs. `ShareRegistry` (same pattern); no token standard named for them; unnamed election factory; visitor expiry stored twice; the corporate-registration contract is never named. | One naming and standards pass. | **Accepted** (2026-11-21): asset tokens are "…Token" (`ShareRegistry` → `ShareToken`), lists and records "…Registry"; `RealEstateToken` ERC-721-style, `ShareToken` and age credentials ERC-1155-style (age thresholds as token types in one contract), with transfer restrictions; `CorporateRegistration` (one per supervising authority) and `ElectionFactory` named; libraries chosen at implementation |

## R5. Privacy

The principle being applied: address-only information may be public (real estate, Round 5), but **a design must not let third parties link an address to a person** without that person's own act.

| ID | Sev. | Issue | Proposal | Status |
|---|---|---|---|---|
| R5.1 | High | **One-officer corporations link the officer's name to their address**: officer names are public, and the multisig signers are the officers' own addresses. With one officer the pairing is exact. | User decision: accept it as part of running a corporation (as for VIPs), or sign with a per-corporation key (rejected once before). | **Decided: (a) accept** (2026-11-21): becoming an officer means accepting that one's personal address may become known (one's own act, like a VIP); signers stay the officers' own addresses |
| R5.2 | High | **Beneficial owners:** with one 25%+ owner (the normal case in owner-run companies), the single published name is the single address found by tracing; the count check makes it explicit. ADR 0030 says names are "never linked". | Declare beneficial owners a **public class like VIPs** (consistent with "corporations open"), or drop the names and leave the check to the regulator. | **Decided: (a) accept** (2026-11-21): beneficial owners are a public class like officers; ADR 0030's "never linked" is changed to "may be linked, accepted" |
| R5.3 | High | Real estate: when a token passes between a published holder (corporation, VIP) and an individual, the published lot number and salt reveal the individual's address and home (e.g. a developer selling a new house). | The bureau **re-mints with a new ID and salt** when a token passes between published and unpublished holders, and states the remaining limit (the settlement still pairs the two addresses). | **Decided: (a) accept** (2026-11-21): buying from a published holder may reveal the buyer's home; to be examined in the proofs of concept. (Claude's first proposal, re-minting, was found ineffective: the burn and the new mint happen in the same visible transaction.) |
| R5.4 | High | Personal data: the delivery label carries the buyer's **chain address** on a box at their door, and the carrier builds an address-to-home map. | Label with a **one-time order code**, never the chain address. | **Accepted** (2026-11-21): labels carry a one-time order code, never the chain address; the buyer gives the code and the physical address to the carrier only |
| R5.5 | Medium | Age-threshold credentials are minted on the day the person reaches the age, which reveals the birth date. | Mint in **monthly or yearly batches**, or let the person claim it. | **Accepted** (2026-11-21): age credentials are minted monthly in a batch on the 1st (revealing only the birth month); a person may claim earlier on request, accepting that the date may become known; until then, off-chain checks without copies |
| R5.6 | Medium | VIPs: regular transfers to family and family members as real estate agents mark family addresses. | State as an accepted cost of office, and recommend professional agents. | **Accepted** (2026-11-21): stated as an accepted cost of office; VIPs are recommended (not required) to use professional agents for real estate |
| R5.7 | Low | Grants to sole proprietors and pay to office-holders named by role can join names to addresses through published grant records or unique budget codes. | Individuals appear only by address in grant records; no budget code unique to one named person. | **Accepted** (2026-11-21): grant records show individuals (sole proprietors) by address only, corporations by name; no budget code corresponds to a single named person |
| R5.8 | Low | "Only the municipality knows which address is which person" is no longer true (carriers, creditors, counterparties); ADR 0005 contradicts itself on officer addresses. | Restate as "no public link; others learn it only through the person's own act or legal process"; fix ADR 0005's wording. | **Accepted** (2026-11-21): principle restated — no public link between address and person; others learn it only through the person's own act or legal process; ADR 0005 gets a status note (officer addresses appear as signers), its spec is rewritten |
| R5.9 | — | **Simplification candidates** under the new principle: a standing nationality/voter roll instead of per-election and per-petition lists (would also let the donation contract enforce the foreign-donation ban); the shared social-security budget code (keep, but give stigma as the reason); the VIP's switch to a new address on leaving office (hides nothing). | User decision, item by item. | **Decided item by item** (2026-11-21): (1) a standing voter credential was adopted, then **withdrawn in follow-up F1** (eligibility stays per election and per petition); the foreign-donation ban stays an after-the-fact audit; (2) the shared social-security budget code is kept, its reason restated as avoiding stigma and discrimination; per-programme totals published off-chain; (3) the VIP's switch to a new address on leaving office becomes optional; the VIP flag stays for a legal period (e.g. one year) after leaving office |

## R6. Documentation (no design decision needed)

Mechanical fixes Claude can make directly:
- **Missing Japanese translations:** ADRs 0001–0013, `docs/decisions/template.md`, the citizenship discussion log; the credentials discussion log has its Japanese part out of order; the diploma log's English Round 1 lacks a Status; `CHANGELOG.md` and the feature template have none.
- **Stale status text:** credentials overview ("🟡 Discussing"), legislative spec (direct-demand "🔴 Not started"), `docs/state-design/README.md` ("first function under discussion"), `docs/PROJECT_STATUS.md` open questions and "key documents" wording.
- **Back-references:** ADR 0015 ← 0020, ADR 0028 ← 0029/0030, ADR 0012 ← 0027, the ADR index entry for 0014 (partly superseded), and a Japanese index in `docs/decisions/README.md`.
- **Backlog:** close or restate rows whose prerequisites are met (political fund dissolution, financial infrastructure, shareholder voting); fix the dangling "cross-border payment item above"; tidy closed rows.
- **Small fixes:** one broken anchor in the vaccination spec; the FEATURES footer still lists beneficial ownership as open; README's wealth-services status cell; CHANGELOG order.

| ID | Status |
|---|---|
| R6 | **Done** (2026-11-21) |

## Follow-ups found while applying the decisions (2026-11-21)

**Need a user decision:**

| ID | Issue | Proposal | Status |
|---|---|---|---|
| F1 | Without per-election grants, nothing says which voters may vote in a local election; districts smaller than a municipality cannot be expressed. | The voter credential's token type is the **electoral district**; `Election` and `Petition` list the district types they accept. | **Decided** (2026-11-21): keep today's flow — eligibility per election and per petition from resident information at that time, issued as NFTs; the standing voter credential of R5.9(1) is withdrawn; issuance at scale (batch or Merkle root) is an implementation choice |
| F2 | The residence requirement (e.g. three months in the municipality) is no longer checked on-chain. | The municipality issues the district-typed credential only after the residence period (off-chain check), and burns it on moving out. | **Dissolved** by F1 |
| F3 | With per-petition lists gone, signatures of voters who later move out can no longer be dropped (the old rule F2 of direct demand). | The count is "signatures from addresses still holding a matching credential at the close", checked from public data. | **Dissolved** by F1 |
| F4 | After a succession, an old address that already voted plus a re-issued credential could vote twice in one election. | Re-issue of the voter credential to a successor address takes effect only after elections open at that moment have closed. | **Accepted, revised** (2026-11-21): on succession the old voting NFT is burned and a new one issued, but not for an election in which the old address has already voted (checked on-chain) |
| F5 | Re-issuing a vaccination coupon in `Vaccinated` status is a new power for the municipality; burning `Vaccinated` coupons on death follows the credentials-wide rule. | Confirm both. | **Accepted** (2026-11-21): for succession re-issue only, the municipality may issue a coupon directly in `Vaccinated` status; coupons are burned on death |

**Gaps Claude proposes to fill directly (consistent with the decisions):** the suspended mark lives in `OfficialContractRegistry` and is set by the registrar of the address's kind; the VIP flag is written by the body that confirms the office and follows an optional address switch; the exchanger mark is written by the FSA; a `PublicTreasury.grant()` call makes `PublicGrant` contributions; on emigration 外務省 sets `NationalAbroad` before the burn; merger and light-path confirmations are by the registrar of the kind; a `NationalAbroad` holder's death is reported through 外務省, which removes the flag; the `AnchorRegistry` event carries `previousId` and extra fields; remaining "certified address" wording in specs becomes "registered address".

| ID | Status |
|---|---|
| F-gaps | **Delegated to Claude** (2026-11-21); filled as proposed |

---

# 機能間の整合性レビュー(2026-11)(日本語)

生きたドキュメントです。[`docs/FEATURES.md`](../FEATURES.md)の⏸以外のすべての項目の初期設計は、2026-11-14に完了した([ADR 0030](../decisions/0030-securities-model.md))。[ADR 0017](../decisions/0017-executive-document-anchoring-v1.md)に従い、Solidityを書く前に設計全体の機能間の整合性をレビューする。

**方法。** 観点ごとに1つ、計5つの読み取り専用のレビューを並行して行った: (1) [ADR 0020](../decisions/0020-certified-address-stablecoin.md)の認定アドレス制の前提、(2) コントラクトの一覧と重なり、(3) ライフサイクルの出来事(転居、海外への転出、死亡、鍵の紛失と盗難、解散、役員の交代、退任、ビジターパスの失効)、(4) プライバシーの扱い、(5) ドキュメント。Claudeが重複をまとめ、主な指摘を原文で確認し、それぞれに提案を付けた。各論点はユーザーと議論してから修正し、**ステータス**の列で追跡する。

重大度: **High** = 矛盾、または価値や権利が動かせなくなる。**Medium** = 定義されていない場合、または書かれていない抜け。**Low** = 表現や命名。

## R1. 認定アドレスのレジストリ(`OfficialContractRegistry`)

| ID | 重大度 | 論点 | 提案 | ステータス |
|---|---|---|---|---|
| R1.1 | High | 1つのアドレスは**認定の種類を1つしか持てず**(`certifiedKind(address) → None \| Resident \| …`)、各登録者はmintとburnのときに書き込む。海外への転出で`ResidentLink`をburnすると`NonResidentOwner`([ADR 0029](../decisions/0029-real-estate-registry-model.md))が消える。法人が持つ複数の登録NFTの1つをburnすると([ADR 0005](../decisions/0005-corporate-registration-model.md))、まだ登録されている法人の認定が外れる。ビジターから住民になる場合も同じ問題がある。 | **種類ごと(登録者ごと)に1つのフラグ**。どれかが立っていれば認定済み。 | **了承**(2026-11-21) |
| R1.2 | Medium | レジストリの照会、種類、書き込む者が3通りに定義されている(ADR 0015の`kindOf`、ADR 0019が`PublicTreasury`を追加、ADR 0020の`certifiedKind`と登録者)。`NonResidentOwner`、`ForeignInvestor`、法務局、金融庁、`TenderFactory`が一覧から抜けている。 | 認定ステーブルコインの仕様に**正本となるレジストリの節**を1つ: 2つの照会(コントラクトの種類と認定アドレス)、すべての種類、それぞれの登録者。 | **了承**(2026-11-21) |
| R1.3 | Medium | 登録者のいない、資金を持つコントラクトがある: `ClearingContract`、信託・組合・ファンドのアドレス([ADR 0030](../decisions/0030-securities-model.md))、`RealEstateToken`。 | 登録者を定める: 公的機関のコントラクト(法務局のものを含む)は総務省、清算コントラクトと投資の器は金融庁。 | **了承**(2026-11-21)。D1のもとで維持。民間のコントラクトで登録できるのは監督下の金融の器だけ |
| R1.4 | Medium | `AnchorRegistry.anchor`は認定された法人か公的なアドレスしか受け付けないが、公的機関の認定アドレスは`PublicTreasury`だけで(`pay()`しかない)、個人事業主は`Resident`の種類である。どちらもアンカリングしなければならない([ADR 0028](../decisions/0028-personal-data-model.md)、ADR 0029)。 | 各公的機関の管理用マルチシグを公的機関の種類として認定する。個人事業主のために`Resident`の呼び出しを認める。 | **了承**(2026-11-21) |
| R1.5 | Medium | ADR 0020より前の文書が、今も「オンチェーンのレジストリはない」(国民・住民、法人)、「受け付けるトークンの許可リストはない」(ADR 0004、納税)と書いており、政治資金の登録には認定リストが出てこない。 | ADR 0020を指す注記をその場に加える。 | **了承**(2026-11-21) |
| R1.6 | Medium | 「公的機関ごとに`PublicTreasury`を1つ」(ADR 0019)と、税目ごとの受取アドレス(ADR 0004)、年金の2つのコントラクト(ADR 0024)が食い違う。追加のアドレスはそれ自体が認定されていなければならない。 | **公的機関ごと・勘定ごとに国庫を1つ**に改める。税の受取アドレスは`PublicTreasury`のコントラクトとする。 | **了承**(2026-11-21) |

## R2. `ResidentLink`を持たない人と組織

| ID | 重大度 | 論点 | 提案 | ステータス |
|---|---|---|---|---|
| R2.1 | High | 国庫の支払先チェック(ADR 0019)は`ResidentLink`、`CorporateRegistration`、`PublicTreasury`しか受け付けない。`RealEstateToken`の決済(公的機関の土地の購入)、`NonResidentOwner`、`ForeignInvestor`、`PoliticalFund`への支払い(政党交付金の経路がそもそもない)を拒否する。ADR 0020ですでにステーブルコイン自体が認定されていない受取人を拒む。 | 支払先チェックは**「認定済みで、`Visitor`以外の種類」**。政治資金に`PublicGrant`の区分を加える。 | **了承**(2026-11-21) |
| R2.2 | High | **海外への転出がステーブルコインの設計にない。** `NonResidentOwner`は土地の所有者にしかないので、土地を持たない海外の国民には認定アドレスがない: 円を持てず、年金や遺族への支払いを受けられず、相続もできない。 | `NonResidentOwner`を土地と切り離し、**海外に住む国民の一般的な種類**にする(例: `NationalAbroad`に改名)。ADR 0020に海外転出の行を加える。年金を海外に払うかを決める。 | **了承**(2026-11-21。認定は外務省へ、名前は`NationalAbroad`)。D1のもとで維持を確認(2026-11-21) |
| R2.3 | Medium | 認定の種類がない: 日本に住んだことのない`EmployeeID`の保有者(ADR 0010)。賃料を払う外国法人と外国人の非居住者(借地は誰にでも認めた、ADR 0029)。外国会社の支店(ADR 0005は触れていない)。 | 場合ごとに決める: 認定された事業者の経路(国境を越える支払い、バックログ)か、新しい種類か。ADR 0005と0010に記す。 | **D1のもとで修正して了承**(2026-11-21): `ForeignParty`は作らない。上限を超える支払いは免許を受けた両替業者や銀行を通す(国庫の脱退一時金も同じ)。`ForeignInvestor`は株式のためだけに残す。外国会社の日本支店は外国会社の印付きで法人として登録 |

## 決定D1(2026-11-21): 送金ルールを緩める — [ADR 0031](../decisions/0031-registered-address-transfer-rule.md)

R2.3の議論の中で、ユーザーはレビューの方向が間違っていたと判断した: ADR 0020の「両端とも認定済み」のルールは止めすぎていた。新しいルール(暫定。実証実験の後に再考する): 住民と法人は登録済みのアドレスを1つ。登録済みから未登録のアドレスへの送金は、送り手ごと・期間ごとの合計額で上限。要人の上限は0。免許を受けた両替業者と発行者は対象外。国庫は登録済みのアドレスにだけ払う。それ以外は公開データで後から確認する。

**D1のもとで見直す項目:** R1.3(維持: 民間のコントラクトで登録できるのは監督下の金融の器だけ)、R2.2(維持: `NationalAbroad`を残す)、R2.3(修正: `ForeignParty`は作らない)、ビジターパス(**廃止**、2026-11-21。両替業者が未登録のアドレスに送れるのは、受取人本人の外貨や現金を両替する場合だけ)、R3.4とR3.8(認定の外れたアドレスはもう凍結されない。R3で扱う)。

## R3. ライフサイクルの出来事

| ID | 重大度 | 論点 | 提案 | ステータス |
|---|---|---|---|---|
| R3.1 | High | 重い承継の手続きでは「古いアドレスは署名で拒否できる」。**鍵の盗難**の後は盗んだ者がその鍵を持ち、回復を永久に止められる。 | 窓口で届け出た盗難の場合、拒否は手続きを終わらせず、裁判所の審査に回す。 | **D1のもとで修正して了承**(2026-11-21): 盗難の届出では`ResidentLink`をburnせず、市区町村がアドレスに**停止**の印を付ける(重い手続き以外では何も出せない)。停止中のアドレスは拒否できない。停止には本人の来所が必要で、一定期間内(例: 2週間)に裁判所が承認しなければ解除 |
| R3.2 | High | **株式には承継の経路がない**(不動産にはある)。証券会社のオペレーターの承認とallowanceが、保有者の死亡、鍵の紛失、認定の喪失の後も残る。 | 重い手続きのマルチシグに**すべての資産トークンのコントラクト**での権限を与える(ADR 0020で一度だけ定める)。保有者の認定が外れたら承認は失効する。 | **D1のもとで拡張して了承**(2026-11-21): 重い手続きにすべての資産トークンのコントラクトでの権限を与える(ADR 0020で一度だけ定める)。保有者の登録が外れるか停止されたら、オペレーターの承認とallowanceは失効する。登録の外れたアドレスにある土地と株式は重い手続きでしか動かない |
| R3.3 | High | **一度しかmintしないクレデンシャルは新しいアドレスに移れない**(鍵の紛失、要人の退任): 卒業証明は「一度だけmint、更新なし」、`Vaccinated`は決してburnされない。 | クレデンシャル全体のルール: 発行者がburnし、承継の記録を示して承継先のアドレスに再発行する。 | **了承**(2026-11-21): クレデンシャル共通のルール — アドレスの承継が記録されたら、各発行者は古いものをburnし承継先へ再発行できる(本人の申し出により、チェーン上の記録を確認)。発行者がない場合は記録を引き継いだ機関が再発行。卒業証明の再発行なし、接種証明のburnなしは、この場合に限り例外 |
| R3.4 | Medium | 重い手続きは市区町村が提案する前提である。解散した法人の残余、`NonResidentOwner`、`ForeignInvestor`、ビジターでは定義されていない。 | そのアドレスの**種類の登録者**が提案する。 | **了承**(2026-11-21): アドレスの種類の登録者が重い手続きを提案する(市区町村、外務省、法人の登録者、金融庁)。裁判所の承認と待機期間は同じ |
| R3.5 | Medium | 解散と合併: 発行済みの社員証や健康保険証が有効なまま残り(雇用保険の被保険者期間を狂わせる)、株式の種類の消却には法人自身のマルチシグが必要で、合併はADR 0020にない。 | 登録NFTをburnする前に、法人は発行済みのクレデンシャルをburnし、株式の種類を消却する。合併は取得する法人への軽い手続きの移転とする。 | **了承**(2026-11-21): 登録NFTのburnの前に、法人(清算人)は発行したクレデンシャルをburnし、株式の種類を消却し、資産を分配する。登録者が公開データで確認する。残りは重い手続き(R3.4)。合併は両社のマルチシグが署名し法務局が確認する軽い手続きの移転(社員証は再発行、株式は交換して消却)。接種の記録のたびに病院の登録を確認 |
| R3.6 | Medium | **法人のマルチシグの署名者の交代が定義されていない**(役員の死亡、鍵の紛失、海外転出)。必要数に届かなくなると、資金、土地、株式が動かせなくなる。 | 交代の手続きを定める(監督官庁による上書きを含む)。認定の外れた署名者を数えるかも定める。 | **了承**(2026-11-21): 通常の交代は登録された役員の変更に合わせてマルチシグ自身が行う。署名数に届かない場合は、登録された役員の変更に基づき、公開の待機期間の後に登録者が署名者を入れ替える(異議は裁判所へ)。登録の外れた、または停止中の署名者は数えない(`NationalAbroad`の役員は数える) |
| R3.7 | Medium | 付与した投票権は取り消せない: 古い鍵、盗んだ者、亡くなった人のアドレスでも投票できる(直接請求には`removeEligible`がある)。 | `castBallot`で`ResidentLink`を再確認する、または`revokeVotingRight`を加える。 | **了承**(2026-11-21): `castBallot`で有効な`ResidentLink`と停止のないことを再確認する。承継が記録されたら、申し出により委員会が新しいアドレスに投票権を与える |
| R3.8 | Medium | 転居の間の空白(burn → 再mint)が死亡と同じに見える: 国庫の支払いはrevertし、不動産の設計は未処理の相続と読み、1件の受け渡しのrevertが毎日の清算全体を失敗させうる。 | 支払いの再試行のルール。清算の受け渡しは1件ずつ失敗する。死亡はburn以外でも示す。 | **了承**(2026-11-21): 国内の転居では転入先が先にmintし、転出元が後でburnする(空白なし。`everIssued`の確認は転出届の確認に替える)。清算の受け渡しは1件ずつ失敗し再試行。国庫の失敗した支払いは未払いとして残し再試行。登録がすべてなくなったアドレスは死亡などを意味する |
| R3.9 | Medium | 相続人が土地を受け取れない: 代理人なしではトークンを受け取れないが、重い手続きの提案に代理人の欄がない。 | 提案に新しい所有者の代理人を加える。 | **了承**(2026-11-21): 承継の提案に、受け取る個人それぞれの代理人(その相続人の署名つき)を含める。相続人で分ける土地は、法務局が持分のトークンとして発行し直し、それぞれに保有者の代理人を付ける |
| R3.10 | Low | パスポートと免許証のburnの理由に死亡がない。海外の国民は年齢を証明できない(年齢の確認に有効な`ResidentLink`が必要)。 | 死亡をburnの理由に加える。年齢の確認にR2.2の種類(またはパスポート)を認める。 | **了承**(2026-11-21): クレデンシャル共通のルール — 本人の死亡で発行者がburnする(市区町村がオフチェーンで伝える)。年齢の確認は`ResidentLink`の代わりに`NationalAbroad`も認める |

## R4. 重なるレジストリと命名

| ID | 重大度 | 論点 | 提案 | ステータス |
|---|---|---|---|---|
| R4.1 | Medium | ハッシュをアンカリングするレジストリが4つある: `DocumentRegistry`(保存する)、`EvidenceRegistry`(保存する)、`CaseRecordRegistry`(保存し、廃棄を拒否しなければならない)、`AnchorRegistry`(イベントだけ。コントラクトからアンカーを読む者がいないため)。同じ理由が最初の2つにも当てはまる。 | **`DocumentRegistry`と`EvidenceRegistry`を`AnchorRegistry`の種類にする。** `CaseRecordRegistry`は残す(保存された状態が必要)。ADRに記録する。 | **了承**(2026-11-21): `DocumentRegistry`と`EvidenceRegistry`を`AnchorRegistry`の種類にする(`previousId`と証拠の状態はイベントに含める)。`CaseRecordRegistry`は残す。新しいADRに記録 |
| R4.2 | Medium | どの文書をどのレジストリに入れるかのルールがない。`DocumentRegistry`は決裁文書に限っていたが(ADR 0017)、後の設計が補助金の報告や雇用主の証明を入れている。 | R4.1から導かれる: すべて種類を付けて`AnchorRegistry`にアンカリングする。そこに**種類の一覧**を置く。 | **了承**(2026-11-21): 文書を作った者が自分の登録済みアドレスからアンカーする。種類の一覧はレジストリの正本の節に置く。コントラクトは種類を制限しない(義務は法律で定め、後から確認) |
| R4.3 | Low | 命名と規格のずれ: `RealEstateToken`と`ShareRegistry`(同じ型)、どちらもトークンの規格を定めていない、名前のない選挙のファクトリー、ビジターの有効期限が2か所に保存される、法人登録のコントラクトに名前がない。 | 命名と規格を一度にそろえる。 | **了承**(2026-11-21): 資産のトークンは「…Token」(`ShareRegistry` → `ShareToken`)、一覧と記録は「…Registry」。`RealEstateToken`はERC-721型、`ShareToken`と年齢のクレデンシャルはERC-1155型(年齢の基準は1つのコントラクトの中の種類)で、移転の制限を加える。`CorporateRegistration`(監督官庁ごとに1つ)と`ElectionFactory`と命名。ライブラリは実装時に選ぶ |

## R5. プライバシー

適用する原則: アドレスだけの情報は公開してよい(不動産、Round 5)。ただし**本人の行為なしに、第三者がアドレスを人物と結びつけられる設計にしてはならない**。

| ID | 重大度 | 論点 | 提案 | ステータス |
|---|---|---|---|---|
| R5.1 | High | **役員が1人の法人では、役員の氏名とアドレスが結びつく**: 役員の氏名は公開で、マルチシグの署名者は役員自身のアドレスである。1人なら対応は確定する。 | ユーザーの判断: 法人を営むことの一部として受け入れる(要人と同様)か、法人ごとの鍵で署名する(以前に不採用)か。 | **決定: (a)受け入れる**(2026-11-21): 役員になることは、個人のアドレスが知られうることを受け入れることである(要人と同じく本人の行為)。署名者は役員自身のアドレスのまま |
| R5.2 | High | **実質的支配者:** 25%以上の所有者が1人の場合(オーナー経営の会社では普通)、公開された1つの氏名は、たどって見つかる1つのアドレスである。人数の照合がそれを明示する。ADR 0030は氏名を「決して結びつけない」としている。 | 実質的支配者を**要人と同じ公開の層**とする(「法人は公開」と整合)か、氏名をやめて照合を規制当局に任せるか。 | **決定: (a)受け入れる**(2026-11-21): 実質的支配者は役員と同じく公開の層とする。ADR 0030の「決して結びつけない」を「結びつきうることを受け入れる」に改める |
| R5.3 | High | 不動産: 公開される保有者(法人、要人)と個人の間でトークンが移ると、公開された地番とソルトから、個人のアドレスと住まいがわかる(例: 開発業者が新築の家を個人に売る)。 | 公開と非公開の保有者の間を移るとき、法務局が**新しいIDとソルトで再mintする**。残る限界(決済が2つのアドレスを結ぶ)を明記する。 | **決定: (a)受け入れる**(2026-11-21): 公開される保有者から買うと住まいが知られうる。実証実験で詳しく検討する。(Claudeの最初の提案の再mintは効果がないとわかった: burnと新しいmintが同じ公開のトランザクションで起きるため。) |
| R5.4 | High | 個人情報: 配送ラベルに購入者の**チェーンのアドレス**が載り、玄関先の箱に付く。配送業者はアドレスと住まいの対応表を作れる。 | ラベルには**1回限りの注文コード**を使い、チェーンのアドレスは使わない。 | **了承**(2026-11-21): ラベルには1回限りの注文コードを使い、チェーンのアドレスは使わない。購入者はコードと実際の住所を配送業者にだけ伝える |
| R5.5 | Medium | 年齢の基準のクレデンシャルは、その年齢に達した日にmintされ、生年月日がわかる。 | **月ごとか年ごとにまとめてmint**する、または本人が請求する。 | **了承**(2026-11-21): 年齢のクレデンシャルは毎月1日にまとめてmint(わかるのは生まれた月だけ)。本人の申請で早く発行でき、その場合は日付が知られうることを本人が受け入れる。それまではオフチェーンで写しを取らずに確認 |
| R5.6 | Medium | 要人: 家族への定期的な送金や、不動産の代理人としての家族が、家族のアドレスを特定させる。 | 公職の代償として受け入れると明記し、専門家の代理人を勧める。 | **了承**(2026-11-21): 公職の代償として受け入れると明記する。要人には不動産の代理人に専門家を使うよう勧める(義務ではない) |
| R5.7 | Low | 個人事業主への補助金や、役職で特定される公職者への報酬は、公開の交付の記録や一意の予算コードを通じて氏名とアドレスを結びつけうる。 | 交付の記録では個人はアドレスだけで示す。名前のわかる1人だけに対応する予算コードを作らない。 | **了承**(2026-11-21): 交付の記録では個人(個人事業主)はアドレスだけ、法人は名称で示す。名前のわかる1人だけに対応する予算コードは作らない |
| R5.8 | Low | 「どのアドレスが誰かを知るのは市区町村だけ」はもう正しくない(配送業者、債権者、取引の相手方)。ADR 0005は役員のアドレスについて自己矛盾している。 | 「公開の結びつきはない。他者が知るのは本人の行為か法的な手続きによってだけ」と言い直す。ADR 0005の表現を直す。 | **了承**(2026-11-21): 原則を言い直す — アドレスと本人の対応は公開しない。他者が知るのは本人の行為か法的な手続きによってだけ。ADR 0005はステータス欄に注記(役員のアドレスは署名者として載る)、仕様は書き直す |
| R5.9 | — | 新しい原則のもとでの**簡素化の候補**: 選挙や直接請求ごとのリストの代わりに常設の国籍・選挙人の名簿(政治献金のコントラクトが外国人からの献金の禁止を自ら執行できるようにもなる)。社会保障の共通の予算コード(残すが、理由は偏見を避けるためとする)。要人の退任時の新しいアドレスへの切り替え(何も隠していない)。 | ユーザーの判断、項目ごと。 | **項目ごとに決定**(2026-11-21): (1) 常設の有権者クレデンシャルをいったん採用したが、**追加の論点F1で取り下げ**(資格は選挙ごと・請求ごとのまま)。外国人からの献金の禁止は事後の監査のまま。(2) 社会保障の共通の予算コードは残し、理由を偏見と差別を避けるためと言い直す。制度ごとの合計はオフチェーンで公表。(3) 要人の退任時の新しいアドレスへの切り替えは任意。要人の印は退任後も法定の期間(例: 1年)残す |

## R6. ドキュメント(設計の判断は不要)

Claudeが直接直せる機械的な修正:
- **日本語訳の欠落:** ADR 0001〜0013、`docs/decisions/template.md`、国民・住民の議論ログ。公的証明の議論ログは日本語部分の順序が逆。卒業証明のログは英語のRound 1にステータスがない。`CHANGELOG.md`と機能のテンプレートには日本語がない。
- **古いステータスの記述:** 公的証明の総論(「🟡 議論中」)、立法の仕様(直接請求が「🔴 未着手」)、`docs/state-design/README.md`(「最初に議論する機能」)、`docs/PROJECT_STATUS.md`の未解決の論点と「主要な文書」という表現。
- **相互参照:** ADR 0015 ← 0020、ADR 0028 ← 0029/0030、ADR 0012 ← 0027、ADRの索引の0014(一部上書き)、`docs/decisions/README.md`の日本語の索引。
- **バックログ:** 前提が満たされた行(政治団体の解散時の資金、金融の基盤、株主総会の議決権行使)を閉じるか言い直す。宙に浮いた「上の国境を越える支払いの項目」を直す。閉じた行を整える。
- **細かい修正:** 接種証明の仕様の壊れたアンカー1つ。FEATURESの末尾が実質的支配者をまだ未決としている。READMEの富裕層向け金融サービスのステータス欄。CHANGELOGの順序。

| ID | ステータス |
|---|---|
| R6 | **完了**(2026-11-21) |

## 決定の反映中に見つかった追加の論点(2026-11-21)

**ユーザーの判断が必要:**

| ID | 論点 | 提案 | ステータス |
|---|---|---|---|
| F1 | 選挙ごとの付与がなくなり、地方選挙で誰が投票できるかを定めるものがない。市区町村より小さい選挙区も表せない。 | 有権者クレデンシャルのトークンの種類を**選挙区**にする。`Election`と`Petition`は受け付ける選挙区の種類を列挙する。 | **決定**(2026-11-21): 今の流れを踏襲する — 資格はその時点の住民情報で選挙ごと・請求ごとに決め、NFTで発行する。R5.9(1)の常設の有権者クレデンシャルは取り下げ。大規模な発行(まとめて発行かマークルルート)は実装の選択 |
| F2 | 居住要件(例: 市区町村に3か月)がオンチェーンで確認されなくなった。 | 市区町村は居住期間を満たしてから選挙区の種類のクレデンシャルを発行し(オフチェーンの確認)、転出でburnする。 | **F1により解消** |
| F3 | 請求ごとの名簿がなくなり、後で転出した有権者の署名を除けなくなった(直接請求の旧ルールF2)。 | 数えるのは「締切の時点で対応するクレデンシャルをまだ持つアドレスの署名」とし、公開データで確認する。 | **F1により解消** |
| F4 | 承継の後、すでに投票した古いアドレスと再発行されたクレデンシャルで、1つの選挙に2回投票できうる。 | 承継先への有権者クレデンシャルの再発行は、その時点で進行中の選挙が終わってから有効にする。 | **修正して了承**(2026-11-21): 承継では古い投票のNFTをburnして新しいものを発行する。ただし古いアドレスがすでに投票した選挙については発行しない(オンチェーンで確認) |
| F5 | 接種券を`Vaccinated`の状態で再発行するのは市区町村の新しい権限になる。死亡で`Vaccinated`の接種券をburnするのはクレデンシャル共通のルールに従う。 | 両方を確認する。 | **了承**(2026-11-21): 承継の再発行に限り、市区町村が`Vaccinated`の状態で接種券を発行できる。死亡でburnする |

**Claudeが直接埋めることを提案する抜け(決定と整合):** 停止の印は`OfficialContractRegistry`に置き、アドレスの種類の登録者が付ける。要人の印は公職を確定する機関が書き込み、任意のアドレスの切り替えに伴って移る。両替業者の印は金融庁が書き込む。`PublicGrant`の寄付は`PublicTreasury.grant()`の呼び出しで行う。海外転出では外務省がburnの前に`NationalAbroad`を付ける。合併と軽い手続きの確認は種類の登録者が行う。`NationalAbroad`の保有者の死亡は外務省を通じて届け出られ、外務省が印を外す。`AnchorRegistry`のイベントは`previousId`と追加の項目を運ぶ。仕様に残る「認定アドレス」の表現は「登録済みのアドレス」にする。

| ID | ステータス |
|---|---|
| F-gaps | **Claudeに一任**(2026-11-21)。提案どおり埋めた |

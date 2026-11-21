# 0032. Cross-feature consistency review: decisions

**Date:** 2026-11-21
**Status:** Accepted. Amends ADRs 0003, 0005, 0006, 0007, 0008, 0011, 0013, 0016–0021, 0023–0030 as listed below; the transfer rule itself is in [ADR 0031](0031-registered-address-transfer-rule.md).

## Context

After the initial design was completed ([ADR 0030](0030-securities-model.md)), the whole design was reviewed for cross-feature consistency before any Solidity ([ADR 0017](0017-executive-document-anchoring-v1.md)). Five parallel reviews found 32 issues (R1–R6), recorded with their resolution in [`architecture/consistency-review.md`](../architecture/consistency-review.md). The user decided each one on 2026-11-21. Midway, the user judged that the certified-address rule of ADR 0020 blocked too much and replaced it ([ADR 0031](0031-registered-address-transfer-rule.md), decision D1); several items were then re-examined under the new rule. This ADR records the decisions in one place; the review document keeps the detail.

## Decision

**Registry (R1).**
- `OfficialContractRegistry` keeps **one flag per registration kind and registrar**; an address is registered if any flag is set (R1.1). One canonical registry section in the certified-stablecoin spec defines the two lookups (official contract kinds, written by 総務省 only; registered addresses, written by each kind's registrar), every kind and its registrar (R1.2).
- Kinds: Resident (municipalities), Corporation (the supervising authority; foreign companies' branches with a foreign flag), PublicContract (総務省: treasuries, `RealEstateToken`, public bodies' controlling multisigs), `NationalAbroad` (外務省; renamed from `NonResidentOwner`, no longer tied to land), `ForeignInvestor` (FSA; for shares only), FinancialVehicle (FSA: the clearing contract, trusts, partnerships, funds). The `Visitor` kind is abolished. Among private contracts only supervised financial vehicles may register (R1.3, D1).
- `AnchorRegistry` accepts any registered address (R1.4). Treasuries are one per body **per account**; tax receiving addresses are treasury contracts (R1.6). Pre-ADR 0020 texts get in-place notes (R1.5).

**People and bodies without a `ResidentLink` (R2).** Treasuries pay any registered address; `PoliticalFund.contribute()` gets a `PublicGrant` category callable by treasuries (R2.1). Nationals abroad keep their address as `NationalAbroad`; pensions are paid abroad (R2.2). No `ForeignParty` kind: payments above the cap go through licensed exchangers or banks (R2.3).

**Lifecycle (R3).**
- A key-theft report **suspends** the address instead of burning the `ResidentLink`; only the heavy path can move anything out; a suspended address cannot veto; the suspension lapses unless a court approves within a set period (R3.1).
- The heavy-path multisig is authorised on **every asset-token contract**; operator approvals lapse when the holder's registration ends or the address is suspended; land and shares at an address that lost its registration move only by the heavy path (R3.2). The registrar of the address's kind proposes the heavy path (R3.4); proposals carry receiving heirs' real-estate agents, and land shared among heirs is re-issued as share tokens (R3.9).
- Credentials-wide: issuers re-issue to a successor address after a recorded succession (R3.3) and burn on death (R3.10). Age checks accept `NationalAbroad`.
- Dissolution: credentials burned, share classes cancelled and assets distributed before the registration NFT is burned; merger as a light-path transfer (R3.5). Corporate multisig signers rotate with officer changes; if the threshold cannot be met, the registrar replaces signers after a public waiting period; decertified or suspended signers do not count (R3.6).
- `castBallot` re-checks registration (R3.7). On a domestic move the new municipality mints before the old one burns, replacing the `everIssued` check with the move-out declaration; clearing deliveries and treasury payments fail one by one and are retried (R3.8).

**Registries and naming (R4).** `DocumentRegistry` (ADR 0017) and `EvidenceRegistry` (ADR 0018) become kinds of the event-only `AnchorRegistry`; `CaseRecordRegistry` stays (R4.1). The author of a document anchors it; one kind list is kept with the registry section; the contract does not restrict kinds (R4.2). Naming: asset tokens "…Token" (`ShareRegistry` → `ShareToken`), lists "…Registry"; `RealEstateToken` ERC-721-style, `ShareToken` and age credentials ERC-1155-style; `CorporateRegistration` and `ElectionFactory` named (R4.3).

**Privacy (R5).** Officers and beneficial owners accept that their names may be linked to their addresses (R5.1, R5.2). A buyer from a published real-estate holder may be identified; accepted and left to the proofs of concept (R5.3). Delivery labels carry a one-time order code (R5.4). Age credentials are minted monthly in a batch, or earlier on request (R5.5). VIPs' family exposure is an accepted cost of office (R5.6). Grant records show individuals by address only; no budget code for a single named person (R5.7). Principle restated: no public link between address and person; others learn it only through the person's own act or legal process (R5.8). A standing voter credential was first adopted and then **withdrawn** (follow-up F1): eligibility for votes and petitions stays per election and per petition, from resident information at that time, and issuance at scale is an implementation choice; on succession the old voting right is burned and a new one granted unless the old address already voted (F4); the foreign-donation ban stays an after-the-fact audit; the shared social-security budget code is kept to avoid stigma; the VIP's address switch on leaving office becomes optional, the VIP flag staying for a legal period (R5.9).

**Documentation (R6).** Missing translations added; stale status text, back-references and the backlog fixed.

## Consequences

- Fewer contracts (two registries folded into `AnchorRegistry`; no visitor pass) and fewer special cases; one canonical registry definition.
- New on-chain powers, narrowly bounded: suspension of a reported-stolen address, registrar replacement of corporate signers, both with waiting periods and court involvement.
- More name–address links are accepted (officers, beneficial owners, real-estate buyers from published holders, VIP families); these feed the proofs of concept and the working hypothesis in [`PROJECT_STATUS.md`](../PROJECT_STATUS.md).
- Specs are updated to match; each affected ADR gets a status note pointing here.

---

# 0032. 機能間の整合性レビュー: 決定(日本語)

**日付:** 2026-11-21
**ステータス:** Accepted。以下に挙げるとおりADR 0003、0005、0006、0007、0008、0011、0013、0016〜0021、0023〜0030を修正する。送金ルールそのものは[ADR 0031](0031-registered-address-transfer-rule.md)にある。

## 背景

初期設計が完了した後([ADR 0030](0030-securities-model.md))、Solidityを書く前に設計全体の機能間の整合性をレビューした([ADR 0017](0017-executive-document-anchoring-v1.md))。5つの並行したレビューが32の論点(R1〜R6)を見つけ、その解決とともに[`architecture/consistency-review.md`](../architecture/consistency-review.md)に記録した。ユーザーは2026-11-21にそれぞれを決定した。途中でユーザーは、ADR 0020の認定アドレス制のルールが止めすぎていると判断して置き換えた([ADR 0031](0031-registered-address-transfer-rule.md)、決定D1)。その後、いくつかの項目を新しいルールのもとで見直した。このADRは決定を1か所に記録する。詳細はレビュー文書にある。

## 決定

**レジストリ(R1)。**
- `OfficialContractRegistry`は**登録の種類と登録者ごとに1つのフラグ**を持つ。どれかが立っていれば登録済み(R1.1)。認定ステーブルコインの仕様に正本となるレジストリの節を1つ置き、2つの照会(公式のコントラクトの種類。書き込むのは総務省だけ。登録済みのアドレス。書き込むのは各種類の登録者)、すべての種類とその登録者を定める(R1.2)。
- 種類: Resident(市区町村)、Corporation(監督官庁。外国会社の支店は外国の印付き)、PublicContract(総務省: 国庫、`RealEstateToken`、公的機関の管理用マルチシグ)、`NationalAbroad`(外務省。`NonResidentOwner`から改名し、土地と切り離す)、`ForeignInvestor`(金融庁。株式のためだけ)、FinancialVehicle(金融庁: 清算コントラクト、信託、組合、ファンド)。種類`Visitor`は廃止。民間のコントラクトで登録できるのは監督下の金融の器だけ(R1.3、D1)。
- `AnchorRegistry`は登録済みのアドレスなら誰でも受け付ける(R1.4)。国庫は機関ごと**勘定ごと**に1つ。税の受取アドレスは国庫のコントラクト(R1.6)。ADR 0020より前の文書にはその場に注記を加える(R1.5)。

**`ResidentLink`を持たない人と組織(R2)。** 国庫は登録済みのどのアドレスにも払える。`PoliticalFund.contribute()`に国庫だけが使える`PublicGrant`の区分を加える(R2.1)。海外の国民は`NationalAbroad`としてアドレスを保つ。年金は海外にも払う(R2.2)。種類`ForeignParty`は作らない: 上限を超える支払いは免許を受けた両替業者や銀行を通す(R2.3)。

**ライフサイクル(R3)。**
- 鍵の盗難の届出では`ResidentLink`をburnせず、アドレスを**停止**する。重い手続きでしか何も出せない。停止中のアドレスは拒否できない。一定期間内に裁判所が承認しなければ停止は解除される(R3.1)。
- 重い手続きのマルチシグに**すべての資産トークンのコントラクト**での権限を与える。保有者の登録が外れるか停止されたら、オペレーターの承認は失効する。登録の外れたアドレスにある土地と株式は重い手続きでしか動かない(R3.2)。重い手続きはアドレスの種類の登録者が提案する(R3.4)。提案には受け取る相続人の不動産の代理人を含め、相続人で分ける土地は持分のトークンとして発行し直す(R3.9)。
- クレデンシャル共通: 承継が記録されたら発行者が承継先へ再発行し(R3.3)、死亡でburnする(R3.10)。年齢の確認は`NationalAbroad`も認める。
- 解散: 登録NFTのburnの前に、クレデンシャルをburnし、株式の種類を消却し、資産を分配する。合併は軽い手続きの移転(R3.5)。法人のマルチシグの署名者は役員の交代に合わせて交代する。署名数に届かなければ、公開の待機期間の後に登録者が署名者を入れ替える。登録の外れた、または停止中の署名者は数えない(R3.6)。
- `castBallot`で登録を再確認する(R3.7)。国内の転居では転入先が先にmintし、転出元が後でburnする。`everIssued`の確認は転出届の確認に替える。清算の受け渡しと国庫の支払いは1件ずつ失敗し、再試行する(R3.8)。

**レジストリと命名(R4)。** `DocumentRegistry`(ADR 0017)と`EvidenceRegistry`(ADR 0018)は、イベントだけの`AnchorRegistry`の種類になる。`CaseRecordRegistry`は残す(R4.1)。文書を作った者がアンカーする。種類の一覧はレジストリの節に置く。コントラクトは種類を制限しない(R4.2)。命名: 資産のトークンは「…Token」(`ShareRegistry` → `ShareToken`)、一覧は「…Registry」。`RealEstateToken`はERC-721型、`ShareToken`と年齢のクレデンシャルはERC-1155型。`CorporateRegistration`と`ElectionFactory`と命名(R4.3)。

**プライバシー(R5)。** 役員と実質的支配者は、氏名がアドレスと結びつきうることを受け入れる(R5.1、R5.2)。公開される不動産の保有者から買った人は特定されうる。受け入れ、実証実験に委ねる(R5.3)。配送ラベルには1回限りの注文コード(R5.4)。年齢のクレデンシャルは毎月まとめてmint、または申請で早く(R5.5)。要人の家族が知られうることは公職の代償(R5.6)。交付の記録では個人はアドレスだけ。名前のわかる1人だけの予算コードは作らない(R5.7)。原則の言い直し: アドレスと本人の対応は公開しない。他者が知るのは本人の行為か法的な手続きによってだけ(R5.8)。常設の有権者クレデンシャルはいったん採用したが**取り下げた**(追加の論点F1): 投票と請求の資格は、その時点の住民情報で選挙ごと・請求ごとに決め、大規模な発行は実装の選択とする。承継では古い投票権をburnし、古いアドレスが投票済みでなければ新しいアドレスに付与する(F4)。外国人からの献金の禁止は事後の監査のまま。社会保障の共通の予算コードは偏見を避けるため残す。要人の退任時のアドレスの切り替えは任意とし、要人の印は法定の期間残す(R5.9)。

**ドキュメント(R6)。** 欠けていた翻訳を加え、古いステータスの記述、相互参照、バックログを直した。

## 結果

- コントラクトと特別な場合が減る(2つのレジストリを`AnchorRegistry`に統合、ビジターパスなし)。レジストリの定義は1か所。
- 新しいオンチェーンの権限は狭く限定する: 盗難を届け出たアドレスの停止、登録者による法人の署名者の入れ替え。どちらも待機期間と裁判所の関与を伴う。
- 受け入れる氏名とアドレスの結びつきが増える(役員、実質的支配者、公開される保有者から不動産を買った人、要人の家族)。これらは実証実験と[`PROJECT_STATUS.md`](../PROJECT_STATUS.md)の作業仮説につながる。
- 仕様はこれに合わせて更新し、影響する各ADRのステータス欄にここを指す注記を加える。

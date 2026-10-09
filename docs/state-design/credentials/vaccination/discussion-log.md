# Discussion Log: Vaccination Certificate

Records the back-and-forth on this specific credential, in order. See [`docs/state-design/citizenship/discussion-log.md`](../../citizenship/discussion-log.md) for the format this follows. This is a sub-discussion of [`docs/state-design/credentials/discussion-log.md`](../discussion-log.md).

---

## Round 1 — 2026-10-09 (Claude)

### Issues raised before implementation

**1. Trust-anchor: municipality only — the simplest case yet, no new mechanism.**

Japanese vaccination records (定期接種/routine immunizations, and campaigns like COVID-19 vaccination) are administered under 予防接種法, and the official record ultimately ties back to the person's registered municipality — even doses given at a workplace/university mass-vaccination site (職域接種) were tied to the recipient's resident municipality via the coupon (接種券) system. Proposal: municipalities are the sole issuer type, using the same `.lg.jp` mechanism as `ResidentLink` — no new trust-anchor category at all, the simplest case of any credential so far. Confirm, or state if another issuer type needs covering.

**2. Granularity: one contract per (municipality × vaccine type) — closer to diploma's fine-grained split than license/health-insurance's aggregation.**

Unlike a license (where "has a license" is useful even without knowing the vehicle class) or health insurance (where "is enrolled" is the relevant fact), vaccination checks are usually specifically about *which* vaccine (e.g. "vaccinated against COVID-19" for a travel requirement, "has the MMR vaccine" for school enrollment) — knowing *that* someone has *some* vaccination isn't generally useful on its own. Proposal: one contract per vaccine type, per municipality (e.g. "City A COVID-19 Vaccine," "City A Measles Vaccine," issued separately) — consistent with diploma's reasoning (a natural, functionally-necessary distinction), not license/health-insurance's (where the real document already aggregates detail as off-chain-only text). This does mean more contracts than license/health-insurance, as a direct consequence. Confirm this granularity, or state a preference for a coarser, single-contract-per-municipality approach (sacrificing which-vaccine distinction, mirroring license's choice instead).

**3. Multiple doses: model each dose as a separate mint, no burn in the ordinary case — token count itself reflects dose count.**

This is new: every prior credential represented a single ongoing status (held or not). Vaccination is a *cumulative history* — a person may receive multiple doses of the same vaccine over time (primary series, boosters), each a permanent fact that doesn't get "renewed" or "undone" by a later dose. Proposal: **each dose is minted as a new, separate NFT** to the same recipient address, from the same vaccine-type contract — no burn-and-reissue, no single "has it or not" flag. This means `balanceOf(address)` on a given vaccine-type contract naturally reflects **how many doses** that address has received, without needing any per-token field to record a dose number — reusing plain ERC-721 ownership semantics rather than inventing new state. **Burn is reserved only for rare correction** (wrong recipient, data-entry error) — authority-only, no on-chain reason code, same minimization principle as every other credential. Confirm this model.

**4. `ResidentLink` precondition: proposing yes, same pattern as diploma/license/health-insurance.**

Municipal vaccination programs are tied to resident registration in practice (the 接種券 coupon is sent to your registered address). Proposal: require `ResidentLink` at mint time, checked on-chain via an applicant-declared contract — same pattern as diploma, license, and health insurance. Confirm.

**5. No on-chain medical-sequencing logic.**

This design does not enforce dose ordering, minimum intervals between doses, or eligibility rules (age, prior doses, medical exemptions) — that remains entirely the vaccinating municipality's real-world clinical responsibility, the same way license doesn't enforce the real-world driving test. The contract simply records that a dose was administered, whenever the municipality chooses to mint. Confirm this is understood, not an oversight.

---

## Round 2 — 2026-10-09/10 (User + Claude) — Model corrected and resolved

### User (correction to the initial framing)

The actual intended workflow: the municipality issues a vaccination coupon (接種券) NFT. The resident takes it to a hospital, which administers the vaccine and then **changes the coupon's status to "vaccinated."** If a resident never uses an issued coupon, the municipality can burn it. The coupon is non-transferable, specifically to prevent resale/scalping.

### Claude

Identified this requires a real departure from every other identity-style credential (except corporations): an actual on-chain **status field** (`Issued` / `Vaccinated`), since a two-stage coupon→completion lifecycle can't be represented by mere possession. Also identified a genuinely new mechanism: unlike every prior credential (issuer-only mint/burn), this needs a **third party** (the hospital) to be able to update a token the municipality issued — proposed that the municipality grant hospitals a `VACCINATOR_ROLE` permitting them to flip a coupon's status, with the municipality's own off-chain due diligence determining which hospitals to trust (same as every other authority-verification in this project).

### User (refinements)

- Confirms the status field.
- Confirms the `VACCINATOR_ROLE` grant mechanism.
- **Adds a new on-chain precondition**: granting `VACCINATOR_ROLE` to a hospital address should require that address to already hold a valid corporate registration NFT (as a 医療法人, per the [corporations](../../corporations/) design) — checked on-chain. The hospital's actual legitimacy/licensing beyond being a registered corporation remains an off-chain determination by the municipality.
- Burn applies only to unused (`Issued`) coupons — a coupon already marked `Vaccinated` is never burned; it's a permanent historical record.
- Multiple doses: each new dose gets a fresh coupon NFT, going through its own `Issued` → `Vaccinated` lifecycle independently.
- The original issues (municipality-only trust-anchor, one contract per vaccine type, `ResidentLink` precondition, no on-chain medical-sequencing logic) all stand as proposed.

### Claude (implementation refinement, noted for the spec)

Unlike diploma/license/health-insurance (where the applicant declares which `ResidentLink` contract to check, since the issuing authority isn't necessarily the person's own municipality), a vaccination coupon's issuing municipality *is* inherently the recipient's own municipality — so the `VaccinationCoupon` contract can reference its own deploying municipality's `ResidentLink` contract directly, with no applicant-declared parameter needed.

### Resolution

**All issues resolved**, including the corrected model:

- **Status field**: `Issued` / `Vaccinated`, a justified exception to the zero-fields rule (the second credential to need one, after corporations).
- **Lifecycle**: mint (municipality only) creates a coupon in `Issued` state, requiring the recipient to hold a valid `ResidentLink` NFT on the issuing municipality's own `ResidentLink` contract (no applicant-declared parameter, unlike other credentials). `markVaccinated` (hospitals holding `VACCINATOR_ROLE` only) flips `Issued` → `Vaccinated`. Burn (municipality only) is allowed **only** while a coupon is `Issued`; a `Vaccinated` coupon is never burned.
- **Vaccinator authorization**: the municipality grants `VACCINATOR_ROLE` to a hospital address, which requires (checked on-chain) that the address currently holds a valid corporate registration NFT (as a specially-regulated 医療法人 corporation, per the corporations design). The municipality's actual due diligence on the hospital's legitimacy/licensing stays off-chain.
- **Multiple doses**: each dose is a separate coupon NFT, independently cycling through `Issued` → `Vaccinated`.
- **Non-transferable**, explicitly to prevent resale/scalping.
- **Granularity, trust-anchor, `ResidentLink` requirement, and no on-chain medical sequencing**: confirmed as originally proposed (one contract per municipality × vaccine type; municipality-only issuer; `ResidentLink` required to receive a coupon; dose ordering/intervals/eligibility stay off-chain).

## Summary (2026-10-10)

| # | Issue | Resolution |
|---|---|---|
| 1 | Trust-anchor | Municipality only, `.lg.jp` — no new mechanism. |
| 2 | Granularity | One contract per (municipality × vaccine type). |
| 3 | Lifecycle / multiple doses | Each dose = a new coupon NFT with a status field (`Issued`/`Vaccinated`); hospitals (holding `VACCINATOR_ROLE`) flip status on vaccination; municipality burns only unused (`Issued`) coupons; `Vaccinated` records are permanent. |
| 4 | `ResidentLink` dependency | Required to receive a coupon, checked against the issuing municipality's own `ResidentLink` contract (no applicant-declared parameter, unlike other credentials). |
| 5 | Medical sequencing | Not enforced on-chain — the vaccinating municipality's real-world clinical responsibility. |
| New | Vaccinator authorization | Municipality grants `VACCINATOR_ROLE` to a hospital only if that address holds a valid corporate registration (医療法人) — checked on-chain; actual legitimacy/licensing stays off-chain. |

Next: write the formal design spec (replacing this directory's `README.md` stub) and an ADR capturing the conceptual/architecture decisions above.

---

# 議論ログ: 接種証明(日本語)

形式は [`docs/state-design/citizenship/discussion-log.md`](../../citizenship/discussion-log.md) に準じます。これは [`docs/state-design/credentials/discussion-log.md`](../discussion-log.md) のサブ議論です。

---

## Round 1 — 2026-10-09(Claude)

### 実装前に提起する論点

**1. 信頼の起点: 市区町村のみ — これまでで最も単純なケースで、新しい仕組みは不要です。**

日本の接種記録(定期接種、COVID-19のような接種キャンペーン)は予防接種法に基づいて運営され、公式な記録は最終的に本人の登録市区町村に紐づきます — 職域接種(職場・大学での集団接種)で受けた接種であっても、接種券の仕組みを通じて本人の住民登録先の市区町村に紐づいていました。提案: 市区町村のみを発行主体とし、`ResidentLink`と同じ`.lg.jp`の仕組みを使う — 新しい信頼の起点のカテゴリは一切不要で、これまでで最も単純なケースです。この方針でよいか、それとも他にカバーすべき発行主体の種類があるか確認させてください。

**2. 粒度: 市区町村×ワクチンの種類ごとに1コントラクト — 免許証・健康保険証の集約よりも、卒業証明の細分化に近い形です。**

免許証(区分を知らなくても「免許を持っている」こと自体に意味がある)や健康保険証(「加入している」こと自体が重要な事実)とは異なり、接種の確認は通常、**どのワクチンか**が問題になります(例: 渡航要件のための「COVID-19ワクチン接種済み」、就学のための「MMRワクチン接種済み」)。「何らかのワクチンを受けたことがある」というだけでは、それ単独ではあまり意味がありません。提案: 市区町村ごと・ワクチンの種類ごとに1コントラクト(例: 「A市 COVID-19ワクチン」「A市 麻疹ワクチン」を別々に発行)— 卒業証明の考え方(自然で機能上必要な区別)と一致し、免許証・健康保険証(現実の文書が既に詳細をオフチェーンのテキストとして集約している)とは異なります。これにより、免許証・健康保険証よりもコントラクト数が多くなるのは直接の帰結です。この粒度でよいか、それとも(免許証と同様に)ワクチンの種類を区別しない、より粗い単一コントラクト/市区町村のアプローチを希望するか確認させてください。

**3. 複数回接種: 各接種を別々のmintとしてモデル化し、通常はburnを行いません — トークン数自体が接種回数を反映します。**

これは新しい点です: これまでの全てのクレデンシャルは単一の継続的な状態(持っているか否か)を表していました。接種は**累積的な履歴**です — 1人が同じワクチンを複数回(初回接種シリーズ、ブースター接種)受けることがあり、それぞれが、後の接種によって「更新」されたり「取り消され」たりすることのない、恒久的な事実です。提案: **各接種を、同じ受領者のアドレスに対する、同じワクチン種類のコントラクトからの新しい別々のNFTとしてmintする** — burnして再発行する形ではなく、単一の「持っているか否か」のフラグでもありません。これにより、特定のワクチン種類のコントラクトにおける`balanceOf(アドレス)`が、トークンごとに接種回数を記録するフィールドを持たせることなく、そのアドレスが**何回接種を受けたか**を自然に反映します — 新しい状態を発明せず、通常のERC-721の所有権のセマンティクスを再利用する形です。**burnは稀な訂正(受領者の誤り、データ入力ミス)のためだけに取っておきます** — 発行主体のみ、オンチェーンの理由コードなし、他の全てのクレデンシャルと同じ最小化の原則です。このモデルでよいか確認させてください。

**4. `ResidentLink`の前提条件: 卒業証明・免許証・健康保険証と同じパターンで、必要だと提案します。**

市区町村の接種プログラムは、実務上、住民登録に紐づいています(接種券は登録された住所に送付されます)。提案: mint時に`ResidentLink`を要件とし、申請者が申告したコントラクトに対してオンチェーンで確認します — 卒業証明・免許証・健康保険証と同じパターンです。この方針でよいか確認させてください。

**5. オンチェーンでの医学的な順序ロジックの強制はありません。**

この設計は、接種の順序、接種間隔の最小期間、資格要件(年齢、既往接種歴、医学的な禁忌等)をオンチェーンで強制しません — これは免許証が現実の運転試験を強制しないのと同様、接種を行う市区町村の現実の臨床上の責任のままとします。コントラクトは、市区町村がmintを選択したときに、接種が行われたという事実を記録するだけです。これが見落としではなく意図的なものであることを確認させてください。

---

## Round 2 — 2026-10-09/10(ユーザー + Claude)— モデルを修正の上、解決

### ユーザー(当初の想定への訂正)

実際に想定している流れ: 市区町村が接種券NFTを発行する。住民がそれを持って病院に行き、病院が接種を行った後、**接種券のステータスを「接種済み」に変更する**。住民が発行された接種券を使わなかった場合、市区町村がburnできる。接種券は転売・スキャルピング防止のため譲渡不可とする。

### Claude

これが、法人を除く他の全てのアイデンティティ系クレデンシャルからの本当の逸脱を必要とすることを指摘: 実質的なオンチェーンの**状態フィールド**(`Issued`/`Vaccinated`)が必要になる。単なる保持では2段階の「接種券→接種完了」というライフサイクルを表現できないため。また、新しい仕組みも必要: これまでの全てのクレデンシャル(発行主体のみがmint/burn)とは異なり、**第三者(病院)**が市区町村の発行したトークンを更新できる必要がある — 市区町村が病院に`VACCINATOR_ROLE`を付与し、接種券のステータスを変更できるようにすることを提案。どの病院を信頼するかは、市区町村側のオフチェーンのデューデリジェンス(このプロジェクトの他の全ての発行主体確認と同じ)とする。

### ユーザー(精緻化)

- 状態フィールドを確認。
- `VACCINATOR_ROLE`付与の仕組みを確認。
- **新しいオンチェーンの前提条件を追加**: 病院のアドレスに`VACCINATOR_ROLE`を付与する際、そのアドレスが既に(医療法人としての)有効な法人登録NFT([法人設計](../../corporations/)参照)を保有していることをオンチェーンで確認する。病院が登録法人であること以上の実際の正当性・資格の確認は、市区町村によるオフチェーンの判断とする。
- burnは未使用(`Issued`)の接種券のみに適用 — 既に`Vaccinated`になった接種券は決してburnしない。恒久的な履歴上の記録とする。
- 複数回接種: 新しい接種のたびに新しい接種券NFTを発行し、それぞれが独立して`Issued`→`Vaccinated`のライフサイクルを辿る。
- 元々の論点(市区町村のみを信頼の起点とする、ワクチンの種類ごとに1コントラクト、`ResidentLink`の前提条件、オンチェーンでの医学的順序ロジックの非強制)は提案通り全て維持。

### Claude(実装上の精緻化、設計書に反映)

卒業証明・免許証・健康保険証(申請者がどの`ResidentLink`コントラクトを確認するか申告する — 発行主体が必ずしも本人の居住市区町村ではないため)とは異なり、接種券の発行市区町村は本質的に受領者自身の居住市区町村です — そのため`VaccinationCoupon`コントラクトは、申告パラメータなしに、デプロイした市区町村自身の`ResidentLink`コントラクトを直接参照できます。

### 解決

**修正されたモデルを含め、全論点解決。**

- **状態フィールド**: `Issued`/`Vaccinated`。フィールドを持たないという原則への正当な例外(法人に続き2例目)。
- **ライフサイクル**: mint(市区町村のみ)で`Issued`状態の接種券を作成する。受領者は発行市区町村自身の`ResidentLink`コントラクトで有効な`ResidentLink`NFTを保有している必要がある(他のクレデンシャルと異なり申告パラメータなし)。`markVaccinated`(`VACCINATOR_ROLE`を持つ病院のみ)が`Issued`→`Vaccinated`に変更する。burn(市区町村のみ)は接種券が`Issued`の間**のみ**可能 — `Vaccinated`の接種券は決してburnしない。
- **接種実施者の認可**: 市区町村が病院のアドレスに`VACCINATOR_ROLE`を付与する際、そのアドレスが現在、(法人設計による特殊な規制対象法人としての)有効な医療法人登録NFTを保有していることをオンチェーンで確認する。病院の正当性・資格についての実質的なデューデリジェンスはオフチェーンのまま。
- **複数回接種**: 各接種は別々の接種券NFTとし、独立して`Issued`→`Vaccinated`を辿る。
- **譲渡不可**、転売・スキャルピング防止を明示的な目的とする。
- **粒度、信頼の起点、`ResidentLink`要件、医学的順序の非強制**: 当初提案通り確定(市区町村×ワクチンの種類ごとに1コントラクト、市区町村のみが発行主体、接種券受領には`ResidentLink`が必要、接種間隔・順序・資格要件はオフチェーンのまま)。

## まとめ(2026-10-10)

上記の英語版の表を参照してください(内容は同一です)。

次のステップ: このディレクトリの`README.md`のスタブを正式な設計書に置き換え、上記の概念・アーキテクチャ決定を記録したADRを作成する。
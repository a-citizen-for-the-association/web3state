# Discussion Log: License (Driver's License)

Records the back-and-forth on this specific credential, in order. See [`docs/state-design/citizenship/discussion-log.md`](../../citizenship/discussion-log.md) for the format this follows. This is a sub-discussion of [`docs/state-design/credentials/discussion-log.md`](../discussion-log.md).

---

## Round 1 — 2026-10-06 (Claude)

### Scope confirmation

Proposing 運転免許証 (driver's license) as the concrete example, issued by a prefectural 公安委員会 (Public Safety Commission) — not professional licenses (医師免許, 建築士, etc.), which have a more varied set of issuing bodies and can be designed separately later if needed.

### Issues raised before implementation

**1. Trust-anchor: `.lg.jp`, since 公安委員会 is prefectural, not national.**

Prefectures already fall under `.lg.jp` (established in taxation's Issue 7 — both municipalities and prefectures are 地方公共団体 using `.lg.jp`). No new mechanism needed, just noting which existing one applies.

**2. Granularity: likely one contract per vehicle class/condition, held simultaneously.**

A real driver's license covers distinct classes (普通, 準中型, 中型, 大型, 二輪, 第二種, けん引, etc.) and conditions (AT限定, 眼鏡等). Proposal: one contract per class (a natural, fairly static distinction, same reasoning as diploma's per-faculty/degree contracts) — a holder can hold multiple simultaneously, the same way a corporation can hold multiple registration NFTs. Conditions/restrictions (AT限定, corrective lenses) are a finer-grained, more frequently-reviewed distinction — proposal: treat these as **out of scope for the on-chain credential** (the NFT proves "holds a 普通自動車 license," not the full set of restriction codes printed on the physical card) — confirm, or state a preference for modeling conditions as separate contracts too.

**3. Suspension (停止) vs. revocation (取消): represent both identically on-chain as burn; the real-world distinction stays off-chain.**

This is new relative to passport/diploma: a license can become temporarily inactive (points-based suspension, fixed period, resumes automatically after) without being permanently revoked (requiring a fresh application). Given the project's consistent rule of keeping revocation *reasons* off-chain (citizenship, corporations, passport, diploma all do this), proposal: **don't distinguish suspension from revocation on-chain at all** — both are simply a burn by the authority. The real-world legal distinction (is this temporary or permanent, and under what conditions can it be re-issued) is an off-chain administrative/legal classification, not something this design tracks. This avoids introducing any on-chain status field (which would break the zero-fields rule). Confirm, or state if some on-chain distinction between "temporarily suspended" and "revoked" is actually needed for a concrete reason.

**4. Renewal: burn-and-reissue, same as passport.**

Driver's licenses renew periodically (3 or 5 years), with a vision test and, for violators, a safety lecture. Proposal: identical to passport's renewal model — the authority burns the old NFT and mints a new one after the real-world renewal process completes. No on-chain expiry date.

**5. Should holding a License require `ResidentLink`?**

A Japanese driver's license is tied to a registered address (printed on the physical card, updated when you move), and foreign residents can and do hold them — same reasoning as diploma. Proposal: require `ResidentLink` as a mint precondition (checked on-chain, applicant-declared contract, one-time at mint — the same pattern diploma established), with no nationality distinction. Confirm, or state a reason this should differ from diploma's resolution.

---

## Round 2 — 2026-10-06 (User) — All issues resolved

### User

- **Issue 1: confirmed.** `.lg.jp`.
- **Issue 2: revised.** No per-class contracts — a single license is a single contract. Reasoning: even today, a single physical license card manages multiple classes/conditions at once. On-chain, only "holds an active license or not" is checkable; the specific contents (which classes, which conditions) are assumed to be managed off-chain (by 公安委員会's own records).
- **Issue 3: confirmed.** Burn for both suspension and revocation.
- **Issue 4: confirmed.** Burn-and-reissue for renewal.
- **Issue 5: confirmed.** `ResidentLink` required at mint.

### Resolution

**All issues resolved.** `License` is a single contract per prefecture (not per vehicle class), a soulbound possession-only NFT proving "holds an active driver's license" — no on-chain granularity for class/conditions, which stay entirely in 公安委員会's own off-chain records. Suspension and revocation are both represented as burn, with the real-world distinction (temporary vs. permanent, conditions for re-issuance) kept off-chain. Renewal is burn-and-reissue. Minting requires the recipient to hold a `ResidentLink` NFT, checked on-chain at mint time via an applicant-declared contract (same pattern as diploma) — no nationality distinction.

## Summary (2026-10-06)

| # | Issue | Resolution |
|---|---|---|
| Scope | Driver's license (運転免許証) | Confirmed as the concrete instance; professional licenses deferred. |
| 1 | Trust-anchor | `.lg.jp` (prefectural 公安委員会). |
| 2 | Granularity | Single contract, no per-class split — on-chain proves possession only; class/condition detail stays off-chain. |
| 3 | Suspension vs. revocation | Identical on-chain (burn); real-world distinction and re-issuance conditions stay off-chain. |
| 4 | Renewal | Burn-and-reissue, same as passport. |
| 5 | `ResidentLink` dependency | Required, one-time on-chain check at mint, nationality-neutral — same pattern as diploma. |

Next: write the formal design spec (replacing this directory's `README.md` stub) and an ADR capturing the conceptual/architecture decisions above.

---

# 議論ログ: 免許証(運転免許証)(日本語)

形式は [`docs/state-design/citizenship/discussion-log.md`](../../citizenship/discussion-log.md) に準じます。これは [`docs/state-design/credentials/discussion-log.md`](../discussion-log.md) のサブ議論です。

---

## Round 1 — 2026-10-06(Claude)

### スコープの確認

具体例として運転免許証(都道府県の公安委員会発行)を提案します。専門職免許(医師免許、建築士等、発行主体がより多様)は対象外とし、必要であれば後で別途設計します。

### 実装前に提起する論点

**1. 信頼の起点: `.lg.jp`(公安委員会は都道府県なので国の機関ではない)。**

都道府県は既に`.lg.jp`の対象です(納税設計のIssue 7で、市区町村・都道府県はいずれも地方公共団体として`.lg.jp`を使うと確立済み)。新しい仕組みは不要で、既存のどちらが該当するかを確認するだけです。

**2. 粒度: おそらく車両区分ごとに1つのコントラクトとし、同時に複数保有できるようにします。**

実際の運転免許証は、異なる区分(普通、準中型、中型、大型、二輪、第二種、けん引等)と条件(AT限定、眼鏡等)をカバーします。提案: 区分ごとに1つのコントラクト(自然でかなり静的な区別、卒業証明の学部・学位ごとのコントラクトと同じ考え方) — 保有者は法人が複数の登録NFTを持てるのと同様、複数を同時に保有できます。条件・限定(AT限定、眼鏡等)はより細かく、頻繁に見直される区別です — 提案: これらは**オンチェーンのクレデンシャルの対象外**とする(NFTは「普通自動車免許を保有している」ことを証明するのみで、物理的な免許証に印字される条件コードの全体は証明しない) — この方針でよいか、それとも条件も別コントラクトでモデル化したいか確認させてください。

**3. 停止と取消: オンチェーンでは同一(burn)として扱い、現実の区別はオフチェーンに残します。**

パスポート・卒業証明にはなかった新しい点です: 免許は(点数制度により)一時的に効力を失う(停止、一定期間後に自動的に復活)ことがあり、完全な取消(新規申請が必要)とは異なります。失効の**理由**をオフチェーンに残すという、このプロジェクト一貫のルール(国民・住民、法人、パスポート、卒業証明のいずれも同様)を踏まえ、提案: **停止と取消をオンチェーンでは一切区別しない** — どちらも発行主体によるburnとして扱います。一時的か恒久的か、どのような条件で再発行できるかという現実の法的な区別は、オフチェーンの行政上の分類とし、この設計では追跡しません。これにより、オンチェーンの状態フィールドを導入せずに済み(フィールドを持たないというルールを守れます)。この方針でよいか、それとも具体的な理由で「一時停止中」と「取消済み」をオンチェーンで区別する必要があるか確認させてください。

**4. 更新: パスポートと同じくburnして再発行します。**

運転免許証は定期的に更新され(3年または5年)、視力検査や、違反者向けの講習があります。提案: パスポートの更新モデルと同一 — 発行主体が現実の更新プロセス完了後に旧NFTをburnし、新NFTをmintします。オンチェーンの有効期限フィールドはありません。

**5. 免許証の保有に`ResidentLink`を要件とすべきか?**

運転免許証は登録された住所に紐づいており(物理的な免許証に印字され、転居時に更新される)、外国人住民も取得できます — 卒業証明と同じ理由です。提案: 卒業証明で確立したパターン(mint時に申請者が申告したコントラクトに対するオンチェーンでの一度きりの確認)と同様に、`ResidentLink`をmintの前提条件とし、国籍による区別はしません。この方針でよいか、それとも卒業証明の結論と変える理由があるか確認させてください。

---

## Round 2 — 2026-10-06(ユーザー)— 全論点解決

### ユーザー

- **Issue 1: 確認。** `.lg.jp`。
- **Issue 2: 修正。** 区分ごとの別コントラクトは不要。理由: 現在でも1枚の物理的な免許証で複数の区分・状態を管理している。オンチェーンでは「免許を持っているか否か」のみ確認可能とし、具体的な中身(どの区分か等)はオフチェーン(公安委員会側)の管理を想定する。
- **Issue 3: 確認。** 停止・取消ともburnでよい。
- **Issue 4: 確認。** 更新はburn+再発行でよい。
- **Issue 5: 確認。** mint時に`ResidentLink`を要件とする。

### 解決

**全論点解決。** `License`は都道府県ごとに1つのコントラクト(車両区分ごとではない)とし、「有効な運転免許を保有しているか否か」のみを証明する、譲渡不可・保持のみのNFTとする — 区分・条件の内訳はオンチェーンに一切持たず、公安委員会側のオフチェーン記録で管理する。停止と取消はいずれもburnとして表現し、一時的か恒久的か・再発行の条件といった現実の区別はオフチェーンに残す。更新はburn+再発行。mintには、申請者が申告したコントラクトに対するオンチェーンでの一度きりの確認により、`ResidentLink`NFTの保有を要件とする(卒業証明と同じパターン) — 国籍による区別はしない。

## まとめ(2026-10-06)

上記の英語版の表を参照してください(内容は同一です)。

次のステップ: このディレクトリの`README.md`のスタブを正式な設計書に置き換え、上記の概念・アーキテクチャ決定を記録したADRを作成する。
# Discussion Log: Health Insurance Card

Records the back-and-forth on this specific credential, in order. See [`docs/state-design/citizenship/discussion-log.md`](../../citizenship/discussion-log.md) for the format this follows. This is a sub-discussion of [`docs/state-design/credentials/discussion-log.md`](../discussion-log.md).

---

## Round 1 — 2026-10-09 (Claude)

### Scope clarification

This credential (enrollment in a *public* health insurance scheme) is distinct from the "insurance/loan tokenization" item already in [`docs/BACKLOG.md`](../../../BACKLOG.md), which is about *private* commercial insurance products (life, earthquake, etc.) for tax-deduction-computation purposes, explicitly deferred until later. Proposing this one proceeds now. Confirm this scoping is correct.

### Issues raised before implementation

**1. Trust-anchor mapping per insurer type — no new mechanism needed, but confirm the mapping.**

Japan's public health insurance has several issuer types:

| Insurer type | Nature | Proposed trust-anchor |
|---|---|---|
| 国民健康保険 | Municipality-run | `.lg.jp` — already covered (same as `ResidentLink`) |
| 後期高齢者医療制度 | Prefectural 広域連合 (a special local public entity under 地方自治法) | `.lg.jp` — likely covered by the same municipal/prefectural mechanism |
| 協会けんぽ | A single nationally-organized corporation established by specific statute | Register via the [corporations](../../corporations/) pattern as a specially-regulated corporation (supervised by 厚生労働省) — same treatment as 国立大学法人 in the diploma design |
| 組合健保 | Company/industry health insurance unions, established with 厚生労働大臣 approval | Same corporations-pattern treatment, supervised by 厚生労働省 |
| 共済組合 | Mutual aid associations for public servants, established under their own statutes | Same corporations-pattern treatment, supervised by the relevant ministry (e.g. 財務省 for national civil servants) |

Proposal: no new trust-anchor category needs inventing — every insurer type maps onto a mechanism already established (citizenship's `.lg.jp` pattern, or corporations' specially-regulated-corporation pattern). Confirm this mapping.

**2. Granularity: one contract per insurer, simple possession — mirroring license's resolution, not diploma's.**

Unlike a diploma (which has natural static sub-types like faculty/degree), health insurance doesn't have an equivalent "class" distinction — a person is enrolled in exactly one insurer's scheme at a time, just yes/no. Proposal: one contract per insurer, proving only "currently enrolled," no further detail (plan type, copay rate, etc.) — the same "mirror the real document's own aggregation level" reasoning the user gave for license. Confirm.

**3. Lifecycle: continuous status (like `ResidentLink`), not periodic renewal (like passport/license).**

Health insurance enrollment doesn't expire on a fixed schedule — it changes when circumstances change (job change, aging into 後期高齢者医療制度 at 75, death). Proposal:
- **Mint**: insurer only, upon enrollment.
- **Burn**: insurer only, upon disenrollment (any reason — reason kept off-chain, same minimization principle as every other credential).
- **No self-burn.**
- **No renewal cycle** — switching insurers is just burn (old insurer) + mint (new insurer), the same shape as citizenship's municipality-move pattern, not passport/license's periodic burn-and-reissue.

Confirm this lifecycle model.

**4. `ResidentLink` precondition, same pattern as diploma/license.**

Both Japanese nationals and foreign residents are eligible for Japanese public health insurance if they're registered residents. Proposal: require `ResidentLink` as a mint precondition, checked on-chain at mint time via an applicant-declared contract — same pattern as diploma and license, no nationality distinction. Confirm.

**5. Dependents (扶養家族): no special handling proposed — each dependent is just another enrolled person.**

A primary insured person's family members are often covered as dependents without their own employment-based enrollment. Proposal: a dependent simply receives their own NFT from the same insurer's contract, provided they hold their own `ResidentLink` (this project's citizenship design doesn't appear to exclude minors from holding `ResidentLink` — a guardian would manage the key on a minor's behalf, same as any other asset). No separate "dependent" vs. "primary insured" distinction on-chain. Confirm, or state if this needs to be modeled differently.

---

## Round 2 — 2026-10-09 (User) — All issues resolved

### User

Confirms the scope clarification (by proceeding) and all five issues.

### Resolution

**All issues resolved.**

- **Scope: confirmed.** Public health insurance enrollment is in scope now, distinct from the deferred private-insurance tokenization item in `docs/BACKLOG.md`.
- **Issue 1: RESOLVED.** Every insurer type maps onto an existing trust mechanism: municipalities and prefectural 広域連合 via `.lg.jp`; 協会けんぽ, 組合健保, and 共済組合 via the corporations pattern (specially-regulated corporation, supervised by the relevant ministry) — no new mechanism.
- **Issue 2: RESOLVED.** One contract per insurer; proves "currently enrolled" only, no plan/copay detail.
- **Issue 3: RESOLVED.** Continuous status, same shape as `ResidentLink`: mint on enrollment, burn on disenrollment (reason off-chain), no self-burn, no periodic renewal cycle.
- **Issue 4: RESOLVED.** `ResidentLink` required at mint, one-time on-chain check, nationality-neutral — same pattern as diploma/license.
- **Issue 5: RESOLVED.** No special handling for dependents — each enrolled person (primary insured or dependent) gets their own NFT from the same insurer's contract, provided they hold their own `ResidentLink`.

## Summary (2026-10-09)

| # | Issue | Resolution |
|---|---|---|
| Scope | Public vs. private insurance | Public health insurance is in scope now; private insurance (life, earthquake, etc.) stays deferred in `docs/BACKLOG.md`. |
| 1 | Trust-anchor per insurer type | Municipalities/広域連合 → `.lg.jp`; 協会けんぽ/組合健保/共済組合 → corporations pattern (specially-regulated corporation). No new mechanism. |
| 2 | Granularity | One contract per insurer; possession only, no plan detail. |
| 3 | Lifecycle | Continuous status (mint on enrollment, burn on disenrollment); no periodic renewal, unlike passport/license. |
| 4 | `ResidentLink` dependency | Required, one-time on-chain check at mint, nationality-neutral. |
| 5 | Dependents | No special on-chain distinction — each enrolled person gets their own NFT, same contract. |

Next: write the formal design spec (replacing this directory's `README.md` stub) and an ADR capturing the conceptual/architecture decisions above.

---

# 議論ログ: 健康保険証(日本語)

形式は [`docs/state-design/citizenship/discussion-log.md`](../../citizenship/discussion-log.md) に準じます。これは [`docs/state-design/credentials/discussion-log.md`](../discussion-log.md) のサブ議論です。

---

## Round 1 — 2026-10-09(Claude)

### スコープの確認

このクレデンシャル(**公的**医療保険への加入)は、[`docs/BACKLOG.md`](../../../BACKLOG.md)に既にある「保険・ローンのトークン化」の項目(控除計算を目的とした、生命保険・地震保険等の**民間の**商品で、後日扱う予定として先送り済み)とは別物です。こちらは今進めることを提案します。このスコープの切り分けが正しいか確認させてください。

### 実装前に提起する論点

**1. 保険者の種類ごとの信頼の起点の対応 — 新しい仕組みは不要ですが、対応関係を確認させてください。**

日本の公的医療保険には複数の保険者の種類があります:

| 保険者の種類 | 性質 | 提案する信頼の起点 |
|---|---|---|
| 国民健康保険 | 市区町村が運営 | `.lg.jp` — 既にカバー済み(`ResidentLink`と同じ) |
| 後期高齢者医療制度 | 都道府県の広域連合(地方自治法上の特別地方公共団体) | `.lg.jp` — 市区町村・都道府県と同じ仕組みでカバーできそう |
| 協会けんぽ | 特別の法律により設立された全国単一の法人 | [法人設計](../../corporations/)のパターンで、特殊な規制対象法人として登録(厚生労働省の監督下) — 卒業証明における国立大学法人と同じ扱い |
| 組合健保 | 厚生労働大臣の認可により設立される企業・業界の健康保険組合 | 同じく法人設計のパターン、厚生労働省の監督下 |
| 共済組合 | 公務員向けの共済組合、各省庁の監督下で各々の法律により設立 | 同じく法人設計のパターン、該当する省庁(国家公務員共済組合なら財務省等)の監督下 |

提案: 新しい信頼の起点のカテゴリを発明する必要はなく、全ての保険者の種類が既存の仕組み(国民・住民設計の`.lg.jp`パターン、または法人設計の特殊な規制対象法人パターン)にそのまま当てはまります。この対応関係でよいか確認させてください。

**2. 粒度: 保険者ごとに1コントラクト、単純な保持のみ — 卒業証明ではなく免許証の結論を踏襲します。**

卒業証明(学部・学位という自然な静的な区別がある)とは異なり、健康保険には同様の「区分」はありません — ある時点で1つの保険者の制度に加入しているか否かだけです。提案: 保険者ごとに1コントラクトとし、「現在加入しているか」のみを証明し、それ以上の詳細(保険の種類、自己負担割合等)は持たせません — 免許証でユーザーが示した「現実の文書自体の集約レベルを反映する」という考え方と同じです。この方針でよいか確認させてください。

**3. ライフサイクル: (`ResidentLink`のような)継続的な状態とし、(パスポート・免許証のような)定期更新ではありません。**

健康保険の加入は決まった周期で期限切れになるものではなく、状況の変化(転職、75歳での後期高齢者医療制度への移行、死亡等)によって変わります。提案:

- **mint**: 保険者のみ。加入時に。
- **burn**: 保険者のみ。脱退時(理由を問わない — 理由はオフチェーンに残す、他の全てのクレデンシャルと同じ最小化の原則)。
- **自主バーンなし。**
- **更新サイクルなし** — 保険者の切り替えは、旧保険者のburn＋新保険者のmintというだけで、国民・住民設計の転居パターンと同じ形であり、パスポート・免許証の定期的なburn+再発行とは異なります。

このライフサイクルモデルでよいか確認させてください。

**4. `ResidentLink`の前提条件、卒業証明・免許証と同じパターンです。**

日本国民も、住民登録されている外国人も、日本の公的医療保険の対象になり得ます。提案: mintの前提条件として`ResidentLink`を要件とし、mint時に申請者が申告したコントラクトに対してオンチェーンで確認します — 卒業証明・免許証と同じパターンで、国籍による区別はありません。この方針でよいか確認させてください。

**5. 扶養家族: 特別な対応は提案しません — 各扶養家族も単に別の加入者として扱います。**

被保険者本人の家族は、自身の雇用に基づく加入なしに扶養家族として保険の対象になることがよくあります。提案: 扶養家族も、自身の`ResidentLink`を保有していれば、同じ保険者のコントラクトから自分自身のNFTを受け取るだけとします(この国民・住民設計は、未成年者が`ResidentLink`を保有することを排除していないようです — 未成年者の鍵は、他の資産と同様、保護者が管理することになります)。オンチェーンで「扶養家族」と「被保険者本人」を区別する必要はありません。この方針でよいか、それとも別の形でモデル化する必要があるか確認させてください。

---

## Round 2 — 2026-10-09(ユーザー)— 全論点解決

### ユーザー

スコープの確認(進めることで)と、5つの論点全てを確認。

### 解決

**全論点解決。**

- **スコープ: 確認。** 公的医療保険への加入は今進める。`docs/BACKLOG.md`の先送り済みの民間保険トークン化の項目とは別物。
- **Issue 1: 解決。** 全ての保険者の種類が既存の仕組みに対応する: 市区町村・広域連合は`.lg.jp`、協会けんぽ・組合健保・共済組合は法人設計のパターン(特殊な規制対象法人、該当省庁の監督下) — 新しい仕組みは不要。
- **Issue 2: 解決。** 保険者ごとに1コントラクト、「現在加入しているか」のみ証明、保険の種類・自己負担割合等の詳細は持たない。
- **Issue 3: 解決。** `ResidentLink`と同じ継続的な状態 — mint=加入、burn=脱退(理由はオフチェーン)、自主バーンなし、定期更新サイクルなし。
- **Issue 4: 解決。** mint時に`ResidentLink`を要件とする(一度きりのオンチェーン確認、国籍不問) — 卒業証明・免許証と同じパターン。
- **Issue 5: 解決。** 扶養家族への特別対応なし — 被保険者本人か扶養家族かを問わず、各加入者が自身の`ResidentLink`を保有していれば、同じ保険者のコントラクトから自分自身のNFTを受け取る。

## まとめ(2026-10-09)

上記の英語版の表を参照してください(内容は同一です)。

次のステップ: このディレクトリの`README.md`のスタブを正式な設計書に置き換え、上記の概念・アーキテクチャ決定を記録したADRを作成する。
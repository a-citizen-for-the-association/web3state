# 0009. Health insurance credential: continuous status, multi-issuer-type trust reuse

**Date:** 2026-10-09
**Status:** Accepted. Amended by [ADR 0032](0032-consistency-review-decisions.md): re-issue after a recorded succession (R3.3); burn on death (R3.10).

## Context

Following license (ADR 0008), the fourth concrete instance of the general "credentials" pattern designed was the public health insurance card (健康保険証). Japan's public health insurance system has an unusually wide variety of insurer types — municipalities, prefectural 広域連合 (for elderly care), and several categories of specially-regulated corporation (協会けんぽ, 組合健保, 共済組合). Discussion (see [`docs/state-design/credentials/health-insurance/discussion-log.md`](../state-design/credentials/health-insurance/discussion-log.md)) worked through whether this needs any new trust mechanism, granularity, lifecycle, the `ResidentLink` precondition, and dependent handling — resolving all five issues, plus a scope clarification, in two rounds with no disagreement.

## Decision

- **Scope: public health insurance only, distinct from private insurance.** This credential covers enrollment in 国民健康保険, 後期高齢者医療制度, 協会けんぽ, 組合健保, and 共済組合. *Private* commercial insurance (life, earthquake, etc.) remains a separate, deferred item in [`docs/BACKLOG.md`](../BACKLOG.md) under the "financial infrastructure" theme, for tax-deduction-computation purposes.
- **No new trust-anchor mechanism needed.** Every insurer type maps onto something already established: municipalities and prefectural 広域連合 via `.lg.jp` (the same mechanism as `ResidentLink`); 協会けんぽ, 組合健保, and 共済組合 via the [corporations](0005-corporate-registration-model.md) pattern, registering as a specially-regulated corporation supervised by the relevant ministry (the same treatment diploma gave 国立大学法人).
- **One contract per insurer, no further granularity** — mirroring license's resolution (ADR 0008), not diploma's: a person is enrolled in exactly one scheme at a time, so the NFT proves only "currently enrolled," with no plan/coverage detail.
- **Lifecycle is continuous, not periodically renewed** — a departure from passport/license. Enrollment doesn't expire on a schedule; it changes when circumstances change (job change, aging into 後期高齢者医療制度, death). Mint on enrollment, burn on disenrollment (reason kept off-chain), no self-burn, no renewal cycle — the same shape as citizenship's municipality-move pattern rather than passport/license's burn-and-reissue.
- **Minting requires the recipient to hold a valid `ResidentLink` NFT**, checked on-chain at mint time via an applicant-declared contract — the same pattern as diploma and license, no nationality distinction.
- **No special handling for dependents (扶養家族).** A dependent is simply another enrolled person, receiving their own NFT from the same insurer's contract, provided they hold their own `ResidentLink`. No on-chain distinction between primary insured and dependent.

## Consequences

- This is the first credential whose issuer category spans *both* of the two trust-anchor templates established so far (government-domain-anchored, per citizenship/taxation; corporate-registration-reuse, per diploma) within a single credential type — different insurers use different templates depending on their own institutional nature. Future credential types with similarly varied issuers (e.g., a hypothetical cross-sector credential) should expect to do the same per-issuer-type mapping rather than assume one uniform mechanism.
- This is the first credential with a continuous (non-expiring) lifecycle rather than periodic renewal — establishing that credential lifecycle shape depends on the real-world document's own nature (a license/passport expires; enrollment doesn't), not a one-size-fits-all rule.
- All five issues and the scope clarification were resolved by the user in a single confirming message with no pushback — the fastest resolution of any credential designed so far, suggesting the established patterns (trust-anchor reuse, `ResidentLink` precondition, off-chain reason codes) are now well-understood defaults that mostly need confirming rather than debating.

---

# 0009. 健康保険のクレデンシャル: 継続的な状態、複数の種類の発行者による信頼の再利用(日本語)

**日付:** 2026-10-09
**ステータス:** Accepted。[ADR 0032](0032-consistency-review-decisions.md)で修正: 承継が記録されたら再発行(R3.3)。死亡でburnする(R3.10)。

## 背景

免許(ADR 0008)に続き、汎用の「クレデンシャル」パターンの4つ目の具体例として、公的な健康保険証を設計した。日本の公的な健康保険制度は保険者の種類がきわめて多様である: 市区町村、都道府県の広域連合(高齢者医療)、そして規制対象の法人のいくつかの区分(協会けんぽ、組合健保、共済組合)。議論([`docs/state-design/credentials/health-insurance/discussion-log.md`](../state-design/credentials/health-insurance/discussion-log.md)を参照)では次を検討した: 新しい信頼の仕組みが要るか、粒度、ライフサイクル、`ResidentLink`の前提条件、扶養家族の扱い。5つの論点すべてとスコープの明確化を、2ラウンドで、意見の対立なく解決した。

## 決定

- **スコープ: 公的な健康保険だけで、民間の保険とは別。** このクレデンシャルは国民健康保険、後期高齢者医療制度、協会けんぽ、組合健保、共済組合への加入を扱う。*民間*の商業保険(生命、地震など)は、税の控除計算のための別の保留項目として、[`docs/BACKLOG.md`](../BACKLOG.md)の「金融インフラ」のテーマに残る。
- **新しい信頼の起点の仕組みは不要。** どの種類の保険者もすでに確立したものに対応する: 市区町村と都道府県の広域連合は`.lg.jp`(`ResidentLink`と同じ仕組み)。協会けんぽ、組合健保、共済組合は[法人](0005-corporate-registration-model.md)のパターンで、所管の省庁が監督する規制対象の法人として登録する(卒業証明が国立大学法人に与えたのと同じ扱い)。
- **保険者ごとに1つのコントラクトで、それ以上の粒度はない。** 卒業証明ではなく免許の解決(ADR 0008)にならう: 人は一度に1つの制度にしか加入しないので、NFTは「現在加入している」ことだけを証明する。プランや給付の詳細はない。
- **ライフサイクルは継続的で、定期的な更新はない。** パスポートや免許とは異なる。加入は決まった時期に期限切れにならない。状況が変わったときに変わる(転職、後期高齢者医療制度への移行、死亡)。加入でmintし、脱退でburnする(理由はオフチェーン)。本人によるburnも更新の周期もない。パスポートや免許のburnと再発行ではなく、市民権の市区町村の転居のパターンと同じ形である。
- **mintには受領者が有効な`ResidentLink` NFTを持つことを要件とする。** 申請者が申告したコントラクトを通じて、mint時にオンチェーンで確認する。卒業証明や免許と同じパターンで、国籍の区別はない。
- **扶養家族に特別な扱いはしない。** 扶養家族は単に別の加入者であり、自分の`ResidentLink`を持っていれば、同じ保険者のコントラクトから自分のNFTを受け取る。被保険者本人と扶養家族のオンチェーンの区別はない。

## 結果

- 発行者の区分が、これまで確立した2つの信頼の起点のテンプレート(市民権・課税の政府ドメインに基づくもの、卒業証明の法人登録の再利用)の*両方*に、1つのクレデンシャルの中でまたがる最初のクレデンシャルである。保険者ごとに、その組織の性質に応じて異なるテンプレートを使う。同様に発行者が多様な将来のクレデンシャル(例: 仮定の分野横断的なクレデンシャル)も、1つの統一された仕組みを前提にせず、発行者の種類ごとに同じ対応づけを行うことになる。
- 定期的な更新ではなく継続的な(期限のない)ライフサイクルを持つ最初のクレデンシャルである。クレデンシャルのライフサイクルの形は、一律のルールではなく、現実の文書自体の性質(免許やパスポートは期限が切れ、加入は切れない)で決まることを確立した。
- 5つの論点とスコープの明確化のすべてを、ユーザーが反論なく1つの確認のメッセージで解決した。これまで設計したどのクレデンシャルよりも速い解決である。確立したパターン(信頼の起点の再利用、`ResidentLink`の前提条件、オフチェーンの理由コード)が、議論ではなく確認だけで足りる、よく理解された既定になったことを示している。

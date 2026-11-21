# 0011. Vaccination credential: stateful coupon, three-party authorization

**Date:** 2026-10-10
**Status:** Accepted

## Context

Following employee ID (ADR 0010), the sixth and final originally-listed concrete instance of the general "credentials" pattern designed was the vaccination certificate (接種証明). The initial framing (proposed by Claude) modeled it as a retroactive, possession-only proof of a completed dose, consistent with every other credential's zero-on-chain-fields rule. The user corrected this mid-discussion: the real intended workflow is a **vaccination coupon (接種券)** issued by a municipality *before* vaccination, which a **hospital** — not the municipality — marks as used once the dose is administered. See [`docs/state-design/credentials/vaccination/discussion-log.md`](../state-design/credentials/vaccination/discussion-log.md) for the full reasoning, including this correction.

This forced two genuine departures from every prior identity-style credential (citizenship, passport, diploma, license, health insurance, employee ID): (1) real on-chain mutable state is needed (a two-stage status), and (2) a party other than the issuer needs authorized write access to a token.

## Decision

- **Contract: `VaccinationCoupon`, one per (municipality × vaccine type)** — issued under the same `.lg.jp` trust-anchor as `ResidentLink`, no new mechanism. Granularity follows diploma's fine-grained reasoning (which vaccine matters), not license/health-insurance's aggregation.
- **A status field is introduced as a deliberate, justified exception to the credentials-wide zero-fields rule**: `enum Status { Issued, Vaccinated }` — the second credential (after corporations) to carry real per-token state, because a two-stage coupon→completion lifecycle cannot otherwise be represented.
- **Three-party authorization model**: the municipality (issuer) mints coupons and may burn unused ones; a **hospital**, granted `VACCINATOR_ROLE` by the municipality, flips a coupon's status from `Issued` to `Vaccinated`. This is the first credential where someone other than the issuing authority has write access to an issued token.
- **Granting `VACCINATOR_ROLE` requires an on-chain precondition**: the candidate hospital address must currently hold a valid corporate registration NFT (as a specially-regulated 医療法人, per [corporations](0005-corporate-registration-model.md)), checked via a cross-contract call — the same general pattern as `ResidentLink` checks elsewhere. The hospital's actual legitimacy and medical licensing, beyond being a registered corporation, remains the municipality's off-chain due diligence.
- **`Vaccinated` is permanent — never burned.** Burn is authority-only and applies **only** to unused (`Issued`) coupons (e.g., expiry, program cancellation, cleanup).
- **Multiple doses are multiple separate coupons**: each dose (primary series, booster, etc.) is minted fresh and independently cycles through `Issued` → `Vaccinated`. No dedicated dose-count field — dose history is derivable by enumerating a holder's tokens and their statuses.
- **Soulbound / non-transferable**, explicitly motivated by preventing resale/scalping of vaccination coupons, not merely for consistency with other credentials.
- **`ResidentLink` precondition, resolved specifically for this credential's structure**: since the issuing municipality is, by definition, the recipient's own municipality (unlike diploma/license/health-insurance, where the issuing authority isn't necessarily tied to the person's specific municipality), the contract references its own deploying municipality's `ResidentLink` contract directly — no applicant-declared parameter needed.
- **No on-chain medical-sequencing logic** (dose ordering, intervals, eligibility) — the vaccinating municipality's real-world clinical responsibility, same as license not enforcing the real-world driving test.

## Consequences

- This is the first credential requiring a genuine multi-role permission structure (issuer role + a separately-grantable updater role), establishing a reusable pattern — "authority A grants a role to party B, conditioned on B holding some other already-designed credential" — that future features needing similar delegated-update workflows can reuse.
- Corporations (ADR 0005) and now vaccination are the only two credential-like designs with real on-chain mutable state; every other credential remains a pure possession proof. This confirms that the zero-fields default is a strong preference, not an absolute rule, overridden only when the underlying real-world object has a genuine multi-stage lifecycle a third party must attest to.
- This completes the originally-listed set of six credential examples (passport, diploma, license, health-insurance, employee ID, vaccination). Any further credential types are new scope, not part of the original list.

---

# 0011. 接種証明のクレデンシャル: 状態を持つ接種券、3者による権限(日本語)

**日付:** 2026-10-10
**ステータス:** Accepted

## 背景

社員証(ADR 0010)に続き、汎用の「クレデンシャル」パターンの、最初に挙げた中で6つ目かつ最後の具体例として接種証明を設計した。Claudeが最初に提案した枠組みは、接種済みの1回分を事後に、保有だけで証明するものだった。オンチェーンのフィールドを持たないという他のすべてのクレデンシャルのルールと一貫する。ユーザーは議論の途中でこれを訂正した: 実際に意図するワークフローは、接種の*前*に市区町村が発行する**接種券**であり、接種後に市区町村ではなく**病院**がそれを使用済みにする。この訂正を含む理由の全体は[`docs/state-design/credentials/vaccination/discussion-log.md`](../state-design/credentials/vaccination/discussion-log.md)を参照。

これにより、これまでのすべての本人確認型のクレデンシャル(市民権、パスポート、卒業証明、免許、健康保険、社員証)から、本当の意味で2つの逸脱が生じた: (1) 実際にオンチェーンで変更できる状態が必要になる(2段階の状態)。(2) 発行者以外の者が、トークンへの書き込み権限を必要とする。

## 決定

- **コントラクト: `VaccinationCoupon`、(市区町村 × ワクチンの種類)ごとに1つ。** `ResidentLink`と同じ`.lg.jp`の信頼の起点のもとで発行し、新しい仕組みはない。粒度は免許や健康保険のまとめ方ではなく、卒業証明の細かい考え方(どのワクチンかが重要)にならう。
- **クレデンシャル全体のフィールドなしのルールに対する、意図的で正当な例外として状態フィールドを導入する:** `enum Status { Issued, Vaccinated }`。トークンごとに実際の状態を持つ2つ目のクレデンシャルである(法人に次ぐ)。接種券から接種完了への2段階のライフサイクルは、他の方法では表せないからである。
- **3者による権限のモデル:** 市区町村(発行者)が接種券をmintし、未使用のものをburnできる。市区町村から`VACCINATOR_ROLE`を与えられた**病院**が、接種券の状態を`Issued`から`Vaccinated`に切り替える。発行した権限主体以外の者が、発行済みのトークンへの書き込み権限を持つ最初のクレデンシャルである。
- **`VACCINATOR_ROLE`の付与には、オンチェーンの前提条件がある:** 候補の病院のアドレスは、有効な法人登録のNFTを現在持っていなければならない([法人](0005-corporate-registration-model.md)に従い、規制対象の医療法人として)。クロスコントラクト呼び出しで確認する。他の場所での`ResidentLink`の確認と同じ一般的なパターンである。登録された法人であること以上の、病院の実際の正当性や医療の免許は、市区町村のオフチェーンの審査に残る。
- **`Vaccinated`は恒久的で、決してburnしない。** burnは発行者だけが行え、未使用(`Issued`)の接種券に**だけ**適用する(例: 期限切れ、事業の中止、整理)。
- **複数回の接種は、別々の複数の接種券である。** 各回(初回接種、追加接種など)は新たにmintし、それぞれ独立に`Issued` → `Vaccinated`をたどる。接種回数の専用フィールドはない。接種の履歴は、保有者のトークンとその状態を列挙すれば導ける。
- **譲渡不可**とする。他のクレデンシャルとの一貫性のためだけでなく、接種券の転売を防ぐことを明示的な動機とする。
- **`ResidentLink`の前提条件は、このクレデンシャルの構造に合わせて解決する:** 発行する市区町村は定義上、受領者自身の市区町村である(発行者が本人の特定の市区町村と必ずしも結びつかない卒業証明、免許、健康保険とは異なる)。そのためコントラクトは、自身をデプロイした市区町村の`ResidentLink`コントラクトを直接参照する。申請者が申告するパラメータは不要である。
- **オンチェーンの医学的な順序のロジックはない**(接種の順序、間隔、対象者の資格)。これは接種を行う市区町村の現実の臨床上の責任である。免許が現実の運転試験を強制しないのと同じ。

## 結果

- 本当の意味での複数の役割の権限構造(発行者の役割+別に付与できる更新者の役割)を必要とする最初のクレデンシャルである。再利用できるパターンを確立した: 「権限主体Aが当事者Bに役割を付与する。条件は、Bがすでに設計済みの別のクレデンシャルを持つこと」。同様の委任による更新のワークフローが必要な将来の機能は、これを再利用できる。
- 法人(ADR 0005)と今回の接種証明だけが、実際にオンチェーンで変更できる状態を持つ、クレデンシャルに類する設計である。他のすべてのクレデンシャルは純粋な保有の証明のままである。フィールドなしの既定は強い選好であって絶対のルールではなく、第三者が証明すべき本当の多段階のライフサイクルを現実の対象が持つときだけ覆されることを確認した。
- これで最初に挙げた6つのクレデンシャルの例(パスポート、卒業証明、免許、健康保険、社員証、接種証明)が完了した。これ以上のクレデンシャルの種類は新しいスコープであり、最初のリストには含まれない。

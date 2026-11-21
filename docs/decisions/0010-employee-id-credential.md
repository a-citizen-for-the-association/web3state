# 0010. Employee ID credential: corporate-registration reuse, no ResidentLink dependency

**Date:** 2026-10-09
**Status:** Accepted. Amended by [ADR 0032](0032-consistency-review-decisions.md): overseas hires without a `ResidentLink` are paid above the cap through licensed exchangers or banks (R2.3); outstanding IDs are burned before the employer's registration is burned (R3.5); re-issue after succession and burn on death (R3.3, R3.10).

## Context

Following health insurance (ADR 0009), the fifth concrete instance of the general "credentials" pattern designed was the employee ID (社員証). Its trust-anchor had effectively already been identified when the general credentials pattern was first discussed (any registered corporation can issue from its own existing [corporations](0005-corporate-registration-model.md) registration address, the same way the corporations design let employee IDs piggyback on corporate registration with no new mechanism). Discussion (see [`docs/state-design/credentials/employee-id/discussion-log.md`](../state-design/credentials/employee-id/discussion-log.md)) confirmed this and resolved sole-proprietor scope, granularity, lifecycle, and — the most substantive new point — whether a `ResidentLink` precondition applies, all in a single round with no disagreement.

## Decision

- **Issuer = any registered corporation**, using its existing corporate-registration address — no new trust-anchor mechanism, unlike every prior credential which had a specific authority type (government body, school, insurer).
- **Sole proprietors (個人事業主) cannot issue this credential.** They have no corporate registration address to issue from, per the corporations design's scope exclusion. Their employees simply have no on-chain `EmployeeID` under this design.
- **One contract per company, no further granularity** — mirroring license/health-insurance's resolution: proves only "currently employed here," not department, role, or clearance level.
- **Lifecycle is continuous, not periodically renewed** — same shape as health insurance: mint on hiring, burn on employment ending (any reason, kept off-chain), no self-burn (including for resignation, for the same reason passport's 国籍離脱 self-burn was ultimately rejected — invalidating a controlled credential stays authority-side even when the underlying real-world action is personally initiated), no renewal cycle.
- **No `ResidentLink` precondition** — the first credential independent of `ResidentLink` since passport, and for a related reason: employment at a Japanese-registered company isn't inherently tied to Japanese residency (remote workers, overseas-branch local hires). This is a deliberate departure from diploma, license, and health insurance, all of which are run by Japan-specific institutions for Japan-based individuals.

## Consequences

- This is the first credential whose issuer is "any corporation" rather than a specific authority type or category — establishing that the credentials pattern generalizes cleanly to arbitrary corporate issuers, not just government bodies or specially-regulated institutions.
- This is the first credential since passport to have no `ResidentLink` dependency, confirming that the dependency is a per-credential judgment call tied to whether the underlying real-world institution is Japan-residency-specific, not a default to apply everywhere.
- Sole proprietors remain unable to issue any employment-like credential under this design — if ever needed, a separate mechanism (e.g. letting a sole proprietor issue from their own `ResidentLink` address) would need its own design discussion; not raised as a priority by the user.
- With five concrete credential types now designed (passport, diploma, license, health insurance, employee ID), only vaccination remains from the originally-listed examples.

---

# 0010. 社員証のクレデンシャル: 法人登録の再利用、ResidentLinkへの依存なし(日本語)

**日付:** 2026-10-09
**ステータス:** Accepted。[ADR 0032](0032-consistency-review-decisions.md)で修正: `ResidentLink`のない海外採用の社員への上限を超える支払いは、免許を受けた両替業者や銀行を通す(R2.3)。雇用主の登録のburnの前に発行済みの社員証をburnする(R3.5)。承継後の再発行と死亡でのburn(R3.3、R3.10)。

## 背景

健康保険(ADR 0009)に続き、汎用の「クレデンシャル」パターンの5つ目の具体例として社員証を設計した。その信頼の起点は、汎用のクレデンシャルのパターンを最初に議論したときに実質的にもう特定されていた(登録されたどの法人も、既存の[法人](0005-corporate-registration-model.md)の登録アドレスから発行できる。法人の設計が、新しい仕組みなしに社員証を法人登録に相乗りさせたのと同じ方法である)。議論([`docs/state-design/credentials/employee-id/discussion-log.md`](../state-design/credentials/employee-id/discussion-log.md)を参照)はこれを確認し、個人事業主のスコープ、粒度、ライフサイクル、そして最も実質的な新しい論点である`ResidentLink`の前提条件を適用するかを、1ラウンドで、意見の対立なく解決した。

## 決定

- **発行者 = 登録された任意の法人。** 既存の法人登録のアドレスを使う。新しい信頼の起点の仕組みはない。特定の種類の権限主体(政府機関、学校、保険者)を持っていたこれまでのすべてのクレデンシャルとは異なる。
- **個人事業主はこのクレデンシャルを発行できない。** 法人の設計のスコープ外の規定により、発行に使う法人登録のアドレスがない。その従業員は、この設計ではオンチェーンの`EmployeeID`を持たないだけである。
- **会社ごとに1つのコントラクトで、それ以上の粒度はない。** 免許と健康保険の解決にならう: 「現在ここで雇用されている」ことだけを証明し、部署、役職、権限レベルは証明しない。
- **ライフサイクルは継続的で、定期的な更新はない。** 健康保険と同じ形である: 採用でmintし、雇用の終了でburnする(理由は問わずオフチェーン)。本人によるburnはない(退職の場合も含む。パスポートの国籍離脱での本人によるburnが最終的に退けられたのと同じ理由である。管理されたクレデンシャルの無効化は、現実の行為が本人によって始まる場合でも発行者の側に残す)。更新の周期はない。
- **`ResidentLink`の前提条件はない。** パスポート以来、初めて`ResidentLink`に依存しないクレデンシャルであり、理由も関連する: 日本で登録された会社での雇用は、本質的に日本での居住と結びつかない(リモートワーカー、海外支店の現地採用)。これは卒業証明、免許、健康保険からの意図的な逸脱である。それらはすべて、日本に拠点を置く個人のための日本固有の機関が運用する。

## 結果

- 発行者が特定の種類や区分の権限主体ではなく「任意の法人」である最初のクレデンシャルである。クレデンシャルのパターンが、政府機関や規制対象の機関だけでなく、任意の法人の発行者にきれいに一般化することを確立した。
- パスポート以来、初めて`ResidentLink`に依存しないクレデンシャルである。この依存がどこにでも適用する既定ではなく、現実の機関が日本の居住に固有かどうかに結びついたクレデンシャルごとの判断であることを確認した。
- この設計では、個人事業主は雇用に類するクレデンシャルを何も発行できないままである。必要になれば、別の仕組み(例: 個人事業主が自分の`ResidentLink`アドレスから発行できるようにする)に独自の設計の議論が要る。ユーザーは優先事項として挙げていない。
- 5つの具体的なクレデンシャル(パスポート、卒業証明、免許、健康保険、社員証)を設計したので、最初に挙げた例のうち残るのは接種証明だけである。

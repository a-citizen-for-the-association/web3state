# Discussion Log: Employee ID

Records the back-and-forth on this specific credential, in order. See [`docs/state-design/citizenship/discussion-log.md`](../../citizenship/discussion-log.md) for the format this follows. This is a sub-discussion of [`docs/state-design/credentials/discussion-log.md`](../discussion-log.md).

---

## Round 1 — 2026-10-09 (Claude)

### Issues raised before implementation

**1. Sole proprietors (個人事業主) have no corporate registration to issue from — in scope or not?**

This credential's trust-anchor was already identified when the general credentials pattern was discussed: any registered corporation can issue `EmployeeID` NFTs from its own existing [corporations](../../corporations/) registration address, with no new mechanism needed. But a sole proprietor who employs staff (e.g. a small shop owner with part-time employees) has no corporate registration to issue from — they operate under their own `ResidentLink` identity (per the corporations design's scope exclusion). Proposal: **out of scope for now** — only actual registered corporations can issue `EmployeeID`; a sole proprietor's employees simply don't get an on-chain employee ID under this design. Confirm, or state a preference for letting a sole proprietor issue from their own `ResidentLink` address instead (a different trust model worth its own consideration if wanted).

**2. Granularity: one contract per company, simple possession — mirroring license/health-insurance, not diploma.**

Proposal: a single `EmployeeID` contract per company, proving only "currently employed here," with no department/role/clearance-level detail. Consistent with the recent precedent (license, health-insurance) of mirroring how a single real-world badge/card already aggregates such detail as printed text rather than a separate credential per distinction. Confirm, or state a preference for finer granularity.

**3. Lifecycle: continuous status, same shape as health insurance.**

Employment doesn't expire on a fixed schedule — it ends on specific trigger events (resignation, termination, retirement, fixed-term contract end). Proposal:
- **Mint**: company only, upon hiring.
- **Burn**: company only, upon employment ending (any reason, kept off-chain) — **no self-burn**, even for resignation. Reasoning: although resignation is initiated by the employee in the real world, the actual invalidation of a controlled credential (badge, system access) is still something the issuing organization processes (there may be a notice period, a withdrawal of resignation, handover requirements, etc.) — consistent with how this project has kept credential invalidation authority-side even where the underlying real-world right is personally exercised (see passport's Round 1 discussion of 国籍離脱, ultimately resolved the same way).
- **No renewal cycle.**

Confirm this lifecycle model, or state if self-burn should be allowed for resignation specifically.

**4. `ResidentLink` precondition: proposing this is the first credential where it should *not* apply.**

Diploma, license, and health insurance all required `ResidentLink` because they're run by Japan-specific institutions for Japan-based individuals. Employment is different: a Japanese-registered company can employ people working remotely from abroad, or local hires at an overseas branch, who were never Japan residents. Proposal: **no `ResidentLink` requirement** for `EmployeeID` — closer to passport's independence than diploma/license/health-insurance's dependency. Confirm, or state a reason employment should be gated on residency after all.

---

## Round 2 — 2026-10-09 (User) — All issues resolved

### User

Confirms all four issues.

### Resolution

**All issues resolved.**

- **Issue 1: RESOLVED.** Sole proprietors are out of scope for this credential — only registered corporations can issue `EmployeeID`.
- **Issue 2: RESOLVED.** One contract per company, possession only — no department/role/clearance detail.
- **Issue 3: RESOLVED.** Continuous status: mint on hiring, burn on employment end (any reason, off-chain), no self-burn (including for resignation), no renewal cycle.
- **Issue 4: RESOLVED.** No `ResidentLink` precondition — employment is not gated on Japanese residency, unlike diploma/license/health-insurance.

## Summary (2026-10-09)

| # | Issue | Resolution |
|---|---|---|
| 1 | Sole proprietors | Out of scope — only registered corporations can issue `EmployeeID`. |
| 2 | Granularity | One contract per company; possession only. |
| 3 | Lifecycle | Continuous status (mint on hiring, burn on employment end); no self-burn; no renewal. |
| 4 | `ResidentLink` dependency | None — the first credential independent of `ResidentLink` since passport. |

Next: write the formal design spec (replacing this directory's `README.md` stub) and an ADR capturing the conceptual/architecture decisions above.

---

# 議論ログ: 社員証(日本語)

形式は [`docs/state-design/citizenship/discussion-log.md`](../../citizenship/discussion-log.md) に準じます。これは [`docs/state-design/credentials/discussion-log.md`](../discussion-log.md) のサブ議論です。

---

## Round 1 — 2026-10-09(Claude)

### 実装前に提起する論点

**1. 個人事業主は法人登録を持たないため、発行できるアドレスがありません — 対象に含めるか?**

この証明の信頼の起点は、公的証明の横断的な議論の際に既に特定されていました: 登録された法人であれば、既存の[法人登録](../../corporations/)アドレスからそのまま`EmployeeID`NFTを発行でき、新しい仕組みは不要です。しかし、従業員を雇う個人事業主(例: パート従業員を雇う小さな店舗のオーナー)には、発行元となる法人登録がありません — 法人設計のスコープ上、個人事業主は自身の`ResidentLink`アイデンティティで事業を行います。提案: **今回は対象外**とする — 実際に登録された法人のみが`EmployeeID`を発行でき、個人事業主の従業員はこの設計の下ではオンチェーンの社員証を持たない、とします。この方針でよいか、それとも個人事業主が自身の`ResidentLink`アドレスから発行できるようにしたいか(別の信頼モデルになるため、希望があれば別途検討します)確認させてください。

**2. 粒度: 会社ごとに1コントラクト、単純な保持のみ — 卒業証明ではなく免許証・健康保険証の結論を踏襲します。**

提案: 会社ごとに単一の`EmployeeID`コントラクトとし、「現在ここで雇用されているか」のみを証明し、部署・役職・権限レベルの詳細は持たせません。直近の前例(免許証、健康保険証)と同様、こうした詳細は別のクレデンシャルにするのではなく、現実の1枚の社員証バッジ・カードに印字されたテキストとして既に集約されているのを反映する考え方です。この方針でよいか、それとももっと細かい粒度にしたいか確認させてください。

**3. ライフサイクル: 健康保険証と同じ、継続的な状態です。**

雇用関係は決まった周期で期限切れになるものではなく、特定の契機(退職、解雇、定年、有期契約の満了)で終了します。提案:

- **mint**: 会社のみ。雇用時に。
- **burn**: 会社のみ。雇用終了時(理由を問わない、オフチェーンに残す) — **自主バーンなし**、退職の場合も含めて。理由: 現実には退職は従業員本人の意思で開始されますが、統制されたクレデンシャル(バッジ、システムアクセス)の無効化自体は、発行組織側が処理する事項です(予告期間、退職撤回、引継ぎ要件等があり得るため) — このプロジェクトが、本人が行使する現実の権利であっても、クレデンシャルの無効化権限は発行主体側に残してきたのと一貫しています(パスポートのRound 1での国籍離脱の議論を参照、最終的に同じ結論になりました)。
- **更新サイクルなし。**

このライフサイクルモデルでよいか、それとも退職については自主バーンを認めるべきか確認させてください。

**4. `ResidentLink`の前提条件: これは不要にすべき初めての証明かもしれません。**

卒業証明・免許証・健康保険証はいずれも、日本固有の機関が日本在住者向けに運用するものだったため`ResidentLink`を要件としました。雇用は異なります: 日本で登録された会社が、海外から遠隔で働く人や、海外拠点での現地採用者(日本の住民になったことがない人)を雇用することもあります。提案: `EmployeeID`には**`ResidentLink`を要件としません** — 卒業証明・免許証・健康保険証の依存関係よりも、パスポートの独立性に近い扱いです。この方針でよいか、それとも雇用も住民資格に紐づけるべき理由があるか確認させてください。

---

## Round 2 — 2026-10-09(ユーザー)— 全論点解決

### ユーザー

4つの論点全てを確認。

### 解決

**全論点解決。**

- **Issue 1: 解決。** 個人事業主はこのクレデンシャルの対象外 — 登録された法人のみが`EmployeeID`を発行できる。
- **Issue 2: 解決。** 会社ごとに1コントラクト、保持のみ — 部署・役職・権限レベルの詳細は持たない。
- **Issue 3: 解決。** 継続的な状態: mint=雇用、burn=雇用終了(理由を問わずオフチェーン)、自主バーンなし(退職の場合も含む)、更新サイクルなし。
- **Issue 4: 解決。** `ResidentLink`の前提条件なし — 卒業証明・免許証・健康保険証とは異なり、雇用は日本の住民資格に紐づけない。

## まとめ(2026-10-09)

上記の英語版の表を参照してください(内容は同一です)。

次のステップ: このディレクトリの`README.md`のスタブを正式な設計書に置き換え、上記の概念・アーキテクチャ決定を記録したADRを作成する。
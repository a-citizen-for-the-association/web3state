# Discussion Log: Judiciary / dispute resolution

Records the back-and-forth on this feature's design, in order. See [`docs/state-design/citizenship/discussion-log.md`](../citizenship/discussion-log.md) for the format this follows.

---

## Round 1 — 2026-10-17 (Claude)

### On-chain value test ([ADR 0014](../../decisions/0014-legislative-process-scope.md)), sub-part by sub-part

| Sub-part | Q1 problem | Q2 keeper | Q3 technical | Q4 no record | Q5 combination | Result |
|---|---|---|---|---|---|---|
| **Evidence: custody and inventory** (証拠の保管・証拠目録) | **Yes**: an Osaka special-investigation prosecutor altered a seized floppy disk's data (2010); the Hakamada retrial acquittal (2024) found evidence fabricated by investigators; evidence held by the prosecution can stay undisclosed | **Yes**: investigators hold the evidence; the defence cannot see it | **Partial**: alteration after seizure and hidden evidence are technical; fabrication before seizure is not | **Yes**: no public, fixed inventory of what was seized | Moderate: reuses the executive `DocumentRegistry` pattern ([ADR 0017](../../decisions/0017-executive-document-anchoring-v1.md)) | **Candidate** |
| **Case-record preservation** (事件記録の保存) | **Yes**: courts were found (2022) to have discarded records designated for special preservation, including the 1997 Kobe child-murder case | **Yes**: courts keep and discard their own records | **Partial**: a hash proves a record existed and what it was, and makes disposal visible; it does **not** keep the content | Partial | Weak | **Candidate** (limited) |
| Judgment publication (判決等の公開) | Partial: only a small share of judgments is published | No | **Mostly no**: whether to publish and how to anonymise are institutional | Partial | Weak | Overlaps the Judicial Infrastructure item — see Issue 2 |
| **Judgment enforcement** (判決の執行) | **Yes**: winning a judgment often recovers nothing; for example, only about a quarter to a third of single-mother households receive the child support they are owed | n/a: the problem is debtors hiding assets, not a record-keeper | **Yes**: hiding assets is a traceability problem, and on-chain assets are visible by address | Partial: the asset-disclosure procedure exists but is weak | **Strong**: `ResidentLink`, stablecoin payments, on-chain payroll | **Candidate** (heaviest design) |
| Filing and procedure (訴訟手続) | No | No | — | **No**: civil-procedure digitalisation is already in progress | — | 🚫 |
| Deliberation and judging | No | — | **No**: institutional | — | — | 🚫 |
| Criminal records (前科) | No | — | — | — | — | 🚫: not public today and must not become public; privacy |
| Interrogation recordings (取調べ録音・録画) | Weak: the issue is which cases must be recorded (institutional) | — | Partial | — | — | Fold into evidence anchoring if wanted |
| Supreme Court judge review (国民審査) | — | — | — | — | — | Already covered by [voting](../voting/) |
| Out-of-court / on-chain arbitration (ODR, Kleros-style) | Weak | — | — | — | — | Policy question — see Issue 6 |

### Issues raised

1. **Screening result.** Agree on the three candidates (evidence, case records, enforcement) and the 🚫 items?
2. **Overlap with Judicial Infrastructure.** Proposal: fold "judgment publication" into this item's case-record part; keep "notarization / contract timestamping" as its own item (it is private-law infrastructure used outside court).
3. **Evidence anchoring.** Proposal: at seizure, police and prosecutors register each item (description + hash of the item's photo or data) in their own `DocumentRegistry`-style contract, append-only. Later alteration, and the existence of undisclosed evidence, become checkable by the court and the defence. Fabrication *before* seizure is not addressed.
4. **Case records.** A hash does not preserve content. Proposal: register each record with its retention class, and require **disposal to be registered too**, so destroying a "special preservation" record becomes visible. Whether to also store encrypted content somewhere durable is a separate choice.
5. **Enforcement (the big one).** Options: (a) a court-issued on-chain seizure order that the stablecoin honours. This needs a court role in the stablecoin and touches the payment rail ([ADR 0004](../../decisions/0004-taxation-payment-rail.md)). (b) Only make a debtor's on-chain assets identifiable to the court and creditor, with seizure off-chain. (c) Defer to the redesign phase.
6. **Private/on-chain arbitration.** In scope as a state function, or excluded as "privatised justice"?

### Status

Awaiting the user's response.

---

# 議論ログ: 司法・紛争解決(日本語)

この機能の設計に関するやり取りを順に記録する。形式は[`docs/state-design/citizenship/discussion-log.md`](../citizenship/discussion-log.md)に従う。

---

## Round 1 — 2026-10-17(Claude)

### オンチェーン価値テスト([ADR 0014](../../decisions/0014-legislative-process-scope.md))の部分ごとの適用

| 部分 | 問1 問題 | 問2 管理者 | 問3 技術 | 問4 記録なし | 問5 組み合わせ | 結果 |
|---|---|---|---|---|---|---|
| **証拠の保管・証拠目録** | **はい**: 大阪地検特捜部の検事が押収したフロッピーディスクのデータを改ざん(2010年)。袴田事件の再審無罪判決(2024年)は捜査機関による証拠の捏造を認定。検察が持つ証拠は開示されないままになりうる | **はい**: 捜査機関が証拠を持ち、弁護側は見られない | **一部**: 押収後の改ざんと証拠の隠匿は技術の問題。押収前の捏造はそうではない | **はい**: 押収したものの公開・固定された目録がない | 中程度: 行政の`DocumentRegistry`の仕組み([ADR 0017](../../decisions/0017-executive-document-anchoring-v1.md))を再利用できる | **候補** |
| **事件記録の保存** | **はい**: 特別保存に指定すべき記録を裁判所が廃棄していたことが判明(2022年)。1997年の神戸連続児童殺傷事件を含む | **はい**: 裁判所が自分の記録を保管・廃棄している | **一部**: ハッシュは記録が存在したことと中身を証明し、廃棄を見えるようにする。ただし中身そのものは**保存しない** | 一部 | 弱い | **候補**(限定的) |
| 判決等の公開 | 一部: 公開される判決はごく一部 | いいえ | **ほぼいいえ**: 公開するか、どう匿名化するかは制度の問題 | 一部 | 弱い | 司法インフラの項目と重複 — 論点2を参照 |
| **判決の執行** | **はい**: 勝訴しても何も回収できないことが多い。たとえば、母子世帯で取り決めた養育費を受け取っているのは4分の1〜3分の1程度 | 該当なし: 問題は記録管理者ではなく、債務者の資産隠し | **はい**: 資産隠しは追跡可能性の問題であり、オンチェーンの資産はアドレス単位で見える | 一部: 財産開示手続はあるが弱い | **強い**: `ResidentLink`、ステーブルコインの支払い、オンチェーンの給与 | **候補**(最も重い設計) |
| 訴訟手続 | いいえ | いいえ | — | **いいえ**: 民事訴訟のIT化が進行中 | — | 🚫 |
| 審理・判断そのもの | いいえ | — | **いいえ**: 制度の問題 | — | — | 🚫 |
| 前科の記録 | いいえ | — | — | — | — | 🚫: 現在も公開されておらず、公開すべきでもない。プライバシー |
| 取調べの録音・録画 | 弱い: 問題はどの事件を録画対象にするか(制度) | — | 一部 | — | — | 必要なら証拠のアンカリングに含める |
| 最高裁判所裁判官の国民審査 | — | — | — | — | — | [投票](../voting/)ですでに扱える |
| 裁判外・オンチェーンの仲裁(ODR、Kleros型) | 弱い | — | — | — | — | 方針の問題 — 論点6を参照 |

### 提起した論点

1. **選別の結果。** 3つの候補(証拠、事件記録、執行)と🚫の項目でよいか?
2. **司法インフラとの重複。** 提案: 「判決等の公開」はこの項目の事件記録の部分にまとめる。「公証・契約証明」は独立した項目のままにする(裁判の外で使われる私法上の基盤であるため)。
3. **証拠のアンカリング。** 提案: 押収の時点で、警察と検察が各証拠(説明 + 証拠の写真またはデータのハッシュ)を、自らの`DocumentRegistry`型のコントラクトに追記専用で登録する。後からの改ざんと、開示されていない証拠の存在を、裁判所と弁護側が確認できるようになる。押収*前*の捏造は扱わない。
4. **事件記録。** ハッシュは中身を保存しない。提案: 各記録を保存区分とともに登録し、**廃棄も登録することを義務付ける**。これで「特別保存」の記録の廃棄が見えるようになる。暗号化した中身をどこかに永続的に保存するかは、別の選択とする。
5. **執行(最大の論点)。** 選択肢: (a) 裁判所が発するオンチェーンの差押え命令に、ステーブルコインが従う。ステーブルコインに裁判所の権限が必要になり、決済レール([ADR 0004](../../decisions/0004-taxation-payment-rail.md))に影響する。(b) 債務者のオンチェーン資産を裁判所と債権者が特定できるようにするだけにとどめ、差押えはオフチェーンで行う。(c) 再設計の段階に先送りする。
6. **民間・オンチェーンの仲裁。** 国家機能として扱うか、「司法の民営化」として対象外にするか?

### ステータス

ユーザーの回答待ち。

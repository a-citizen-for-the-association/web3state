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

## Round 2 — 2026-10-17 (user + Claude)

### User's decisions

- Issues 1–4: **accepted** as proposed. Candidates: evidence, case records, enforcement. "Judgment publication" folds into case records; notarization stays its own item.
- Issue 5: **(b)**. A debtor's on-chain assets are made identifiable to the court and creditor; seizure itself stays off-chain. No court role in the stablecoin.
- Issue 6: the user asked for a fuller explanation.

### Claude's explanation of Issue 6

- **What it is.** Disputes settled outside court. Japan already has certified private ADR bodies, the National Consumer Affairs Center's ADR, and arbitration. "On-chain arbitration" (e.g. Kleros) goes further: anonymous jurors who stake a crypto token are drawn at random (weighted by stake), vote, and are rewarded for voting with the majority; a smart contract then executes the result (e.g. releases escrowed funds).
- **Why it is a question.** Three different things hide under the word: (a) leave private arbitration to the market, outside this project; (b) a **state-run** on-chain dispute flow, e.g. buyer's payment held in an escrow contract and released according to a court or certified-ADR decision; (c) giving Kleros-style token-juror rulings official force.
- **Claude's view.** (c) conflicts with this project's foundations: judgement weighted by token holdings (wealth), anonymous jurors with no accountability, and dependence on a speculative token, which the user has already said they are uneasy about. (b) belongs naturally to the everyday-commerce design (escrow for purchases), not to the judiciary core. Proposal: exclude (c) as 🚫, and record (b) as a note for the everyday-commerce item.

### Status

Awaiting the user's decision on Issue 6.

---

## Round 3 — 2026-10-17 (user + Claude)

### User's decision

- Issue 6: **as proposed**. Kleros-style token-juror arbitration with official force is 🚫 excluded. A state-run escrow dispute flow is noted for the everyday-commerce item.

### Adjustments made while writing the spec (flagged for review)

- **Opaque case references.** An evidence inventory that the public can read during an investigation could tip off suspects or accomplices, and could expose a suspect's identity. Each entry therefore uses an **opaque case reference** (a hash of the internal case number with a secret salt) and a rule-based abbreviated description, as for sensitive executive titles. The prosecution discloses the mapping to the court and the defence at indictment. Anyone can then confirm that the inventory has been complete and unchanged since seizure.
- **Interrogation recordings as an evidence type.** The screen said to fold them into evidence anchoring if wanted. The spec includes them as an item type, at no extra design cost.
- **Special preservation cannot be disposed of silently.** `dispose()` is rejected for a record classed as special preservation. The court must first lower the class, which is itself a public event. Physical destruction cannot be stopped by a contract, but destroying such a record without that public trail becomes a provable violation.
- **Enforcement needs no new contract.** With option (b), the on-chain part is only tracing flows that are already public. The new element is an off-chain procedure: under a court order, the municipality discloses the debtor's `ResidentLink` address to the court and the creditor. This is the same legal-process resolution used for donors ([ADR 0015](../../decisions/0015-political-donations-model.md)).

### Status

All issues resolved. Spec written ([`README.md`](README.md)); ADR: [0018](../../decisions/0018-judiciary-model.md).

---

## Round 4 — 2026-10-17 (user)

The user **confirmed all four Round 3 adjustments** (opaque case references, interrogation recordings as an evidence type, guarded disposal of special-preservation records, no new contract for enforcement). No further open points.

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

---

## Round 2 — 2026-10-17(ユーザー + Claude)

### ユーザーの決定

- 論点1〜4: **提案どおり了承**。候補は証拠、事件記録、執行。「判決等の公開」は事件記録にまとめ、公証は独立した項目のままとする。
- 論点5: **(b)**。債務者のオンチェーン資産を裁判所と債権者が特定できるようにする。差押えそのものはオフチェーンで行う。ステーブルコインに裁判所の権限は持たせない。
- 論点6: ユーザーはより詳しい説明を求めた。

### 論点6のClaudeによる説明

- **何か。** 裁判の外で紛争を解決すること。日本にはすでに認証を受けた民間のADR機関、国民生活センターのADR、仲裁がある。「オンチェーンの仲裁」(Klerosなど)はさらに進んだもので、暗号資産トークンを預けた匿名の陪審員が(預けた量に応じた確率で)無作為に選ばれ、投票し、多数派と同じ投票をすると報酬を得る。結果はスマートコントラクトが実行する(預かった資金の払い出しなど)。
- **なぜ論点になるか。** この言葉には3つの異なるものが含まれる。(a) 民間の仲裁は市場に任せ、このプロジェクトの外とする。(b) **国が運営する**オンチェーンの紛争処理。たとえば買い手の支払いをエスクローのコントラクトに預け、裁判所や認証ADRの判断に従って払い出す。(c) Kleros型のトークン陪審員の判断に公的な効力を与える。
- **Claudeの見解。** (c)はこのプロジェクトの土台と相容れない。トークンの保有量(つまり財力)で判断の重みが決まり、陪審員は匿名で責任を負わず、投機的なトークンに依存する。ユーザーはこの点にすでに違和感を示している。(b)は司法の本体ではなく、日常の商取引の設計(購入時のエスクロー)に自然に属する。提案: (c)は🚫対象外とし、(b)は日常の商取引の項目へのメモとして記録する。

### ステータス

論点6についてのユーザーの判断待ち。

---

## Round 3 — 2026-10-17(ユーザー + Claude)

### ユーザーの決定

- 論点6: **提案どおり**。Kleros型のトークン陪審員の仲裁に公的な効力を与えることは🚫対象外とする。国が運営するエスクローの紛争処理は、日常の商取引の項目へのメモとする。

### 仕様作成時に加えた調整(レビュー対象)

- **秘匿化した事件参照。** 捜査中に誰でも読める証拠目録は、被疑者や共犯者に捜査を知らせてしまい、被疑者が誰かを明かしてしまうおそれがある。そのため各登録は、**秘匿化した事件参照**(内部の事件番号を秘密のソルトとともにハッシュ化したもの)と、ルールに基づく略称の説明を使う。行政の機微な名称と同じ扱いである。検察は起訴の時点で、その対応関係を裁判所と弁護側に開示する。そうすれば誰でも、押収以来、目録が完全で変わっていないことを確認できる。
- **取調べの録音・録画を証拠の種類に含める。** 選別では、必要なら証拠のアンカリングに含めるとしていた。追加の設計コストなしで、仕様では証拠の種類の1つとして含める。
- **特別保存の記録は黙って廃棄できない。** 特別保存に区分された記録に対する`dispose()`は拒否される。裁判所はまず区分を下げる必要があり、それ自体が公開のイベントになる。物理的な破棄はコントラクトでは止められないが、その公開の痕跡なしにこうした記録を破棄すれば、証明可能な違反になる。
- **執行に新しいコントラクトは要らない。** 選択肢(b)では、オンチェーンの部分は、すでに公開されている資金の流れをたどることだけである。新しいのはオフチェーンの手続きで、裁判所の命令に基づき、自治体が債務者の`ResidentLink`アドレスを裁判所と債権者に開示する。献金者の特定([ADR 0015](../../decisions/0015-political-donations-model.md))と同じ、法的手続きによる特定である。

### ステータス

すべての論点が解決。仕様を作成([`README.md`](README.md))。ADR: [0018](../../decisions/0018-judiciary-model.md)。

---

## Round 4 — 2026-10-17(ユーザー)

ユーザーは**Round 3の4つの調整をすべて了承した**(秘匿化した事件参照、取調べの録音・録画を証拠の種類に含めること、特別保存の記録の廃棄の制限、執行に新しいコントラクトを作らないこと)。未決の点は残っていない。

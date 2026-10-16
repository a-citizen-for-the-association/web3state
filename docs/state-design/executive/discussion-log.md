# Discussion Log: Executive / administration

Records the back-and-forth on this feature's design, in order. See [`docs/state-design/citizenship/discussion-log.md`](../citizenship/discussion-log.md) for the format this follows.

---

## Round 1 — 2026-10-17 (Claude)

### What "executive" means here

Many executive activities are already separate items in [`docs/FEATURES.md`](../../FEATURES.md): taxation, treasury/spending, procurement, subsidies, pensions and benefits, credentials, vital records, the real estate registry. This screen covers only what is left: how the administration **makes, keeps and discloses its own records and decisions**.

### On-chain value test ([ADR 0014](../../decisions/0014-legislative-process-scope.md)), sub-part by sub-part

| Sub-part | Q1 problem | Q2 keeper | Q3 technical | Q4 no record | Q5 combination | Result |
|---|---|---|---|---|---|---|
| Official documents and approval records (公文書・決裁) | **Yes**: 財務省 rewrote 14 approval documents on the Moritomo case (revealed 2018); SDF daily reports said to be "discarded" were found (2017); 文科省 documents first "could not be confirmed", then found (Kake case, 2017); the cherry-blossom party guest list shredded (2019) | **Yes**: ministries keep their own records | **Partial**: rewriting after creation is technical; not creating or destroying a record is institutional | **Partial**: e-approval systems were introduced after Moritomo, but they are run by the same government | Yes: with the authority registry below, and with information disclosure | **Candidate** |
| Raw statistical data (基幹統計) | **Yes**: 毎月勤労統計 sampled instead of fully surveyed since 2004 (revealed 2018; unemployment benefits underpaid); 国交省 construction-orders survey forms rewritten (revealed 2021) | **Yes** | **Partial**: rewriting collected data is technical; flawed methods are institutional | **Yes**: only aggregates are published | **Strong**: some statistics (e.g. wages) could be computed directly from on-chain payment data, removing the survey step | **Candidate** |
| Information disclosure requests (情報公開請求) | **Yes**: "document does not exist" answers later shown false; deadline extensions | **Yes** | **Partial**: receipt/response dates are technical; redaction judgements are institutional | Partial: annual summary statistics only | **Strong with official documents**: if a document's hash is on-chain, "does not exist" becomes falsifiable | **Candidate, as an extension of official documents** |
| Official-authority registry (who holds which role and key) | **Weak**: no observed fraud; it is a precondition for every authority-issued item already designed | — | — | Partial: GPKI/LGPKI exist off-chain | **Strong** | **Infrastructure, not a state function** |
| Permits and administrative dispositions (許認可・行政処分) | Weak: complaints are about delay and discretion | No | **No**: institutional | — | — | 🚫 (where a permit is a credential, the credentials pattern already applies) |
| Public comment, administrative guidance, personnel decisions | Weak | — | **No**: institutional | — | — | 🚫 |
| Cabinet minutes (閣議議事録) | No | No | — | **No**: published since 2014 | — | 🚫 |

### Cross-cutting limit

A chain proves only that a record **has not changed since it was anchored**. It cannot prove the record was made, or made truthfully. Tampering after the fact becomes detectable, but not creating a record, or falsifying data at collection, does not.

The lever already used for political donations ([ADR 0015](../../decisions/0015-political-donations-model.md): the on-chain fund is the *only lawful* receiving channel) could apply here: **an approval takes effect only once its hash is anchored on-chain.** Then a decision with no anchor is invalid by definition, rather than merely suspicious.

### Issues raised

1. **Screening result.** Is the core excluded (🚫) and the three candidates carved out, as in the legislative case?
2. **How to carve out.** Official documents, statistics and information disclosure share one mechanism (hash + time + who approved). Proposal: one item, "administrative record anchoring" (行政記録のアンカリング). Computing statistics directly from on-chain data is a separate, later idea (it depends on commerce and payroll being on-chain).
3. **Anchoring as a validity condition.** Adopt "no anchor, no effect"? Without it, the design only detects rewriting, not non-creation.
4. **Authority registry.** Treat it as cross-cutting infrastructure (e.g. an extension of `OfficialContractRegistry`, which so far lists contracts, not people's roles) rather than a state function. It may be required by Issue 2 anyway, since each anchor should record who approved it.

### Status

Awaiting the user's response.

---

# 議論ログ: 行政(日本語)

この機能の設計に関するやり取りを順に記録する。形式は[`docs/state-design/citizenship/discussion-log.md`](../citizenship/discussion-log.md)に従う。

---

## Round 1 — 2026-10-17(Claude)

### ここでいう「行政」の範囲

行政の活動の多くは、すでに[`docs/FEATURES.md`](../../FEATURES.md)の別項目になっている。納税、歳出・予算、公共調達、補助金、年金・給付、公的証明、戸籍等、不動産登記である。ここで選別するのは残りの部分、つまり行政が**自らの記録と決定をどう作り、保管し、開示するか**だけである。

### オンチェーン価値テスト([ADR 0014](../../decisions/0014-legislative-process-scope.md))の部分ごとの適用

| 部分 | 問1 問題 | 問2 管理者 | 問3 技術 | 問4 記録なし | 問5 組み合わせ | 結果 |
|---|---|---|---|---|---|---|
| 公文書・決裁記録 | **はい**: 森友学園をめぐる財務省の決裁文書14件の改ざん(2018年発覚)、「廃棄済み」とされた自衛隊の日報の発見(2017年)、文科省の文書が「確認できない」とされた後に見つかった(加計学園、2017年)、桜を見る会の招待者名簿の廃棄(2019年) | **はい**: 省庁が自分の記録を管理している | **一部**: 作成後の書き換えは技術の問題。作らない・廃棄するのは制度の問題 | **一部**: 森友の後に電子決裁が導入されたが、運用しているのは同じ政府 | はい: 下の権限レジストリや情報公開と結びつく | **候補** |
| 統計の原データ(基幹統計) | **はい**: 毎月勤労統計で2004年から全数調査を抽出で済ませていた(2018年発覚、雇用保険などの過少給付)。国交省の建設工事受注統計で調査票を書き換えていた(2021年発覚) | **はい** | **一部**: 集めたデータの書き換えは技術の問題。不適切な手法は制度の問題 | **はい**: 公表されるのは集計値だけ | **強い**: 賃金などの統計は、オンチェーンの支払いデータから直接計算でき、調査そのものが不要になりうる | **候補** |
| 情報公開請求 | **はい**: 後に虚偽とわかった「不存在」の回答、期限の延長 | **はい** | **一部**: 受付・回答の日時は技術の問題。黒塗りの判断は制度の問題 | 一部: 年次の集計統計だけ | **公文書と組み合わせると強い**: 文書のハッシュがオンチェーンにあれば、「不存在」が反証可能になる | **候補(公文書の拡張として)** |
| 行政の権限レジストリ(誰がどの役職・鍵を持つか) | **弱い**: 不正の事例はない。これまで設計した当局発行のものすべての前提である | — | — | 一部: GPKI/LGPKIがオフチェーンにある | **強い** | **国家機能ではなく基盤** |
| 許認可・行政処分 | 弱い: 苦情は遅れと裁量について | いいえ | **いいえ**: 制度の問題 | — | — | 🚫(許認可が証明にあたる場合は、公的証明のパターンがすでに当てはまる) |
| パブリックコメント、行政指導、人事 | 弱い | — | **いいえ**: 制度の問題 | — | — | 🚫 |
| 閣議議事録 | いいえ | いいえ | — | **いいえ**: 2014年から公開されている | — | 🚫 |

### 全体に共通する限界

チェーンが証明できるのは、記録が**アンカーされた後に変わっていない**ことだけである。記録が作られたこと、正しく作られたことは証明できない。事後の改ざんは検出できるようになるが、記録を作らないことや、集める段階でデータを偽ることは検出できない。

政治献金で使った手段([ADR 0015](../../decisions/0015-political-donations-model.md): オンチェーンの資金コントラクトが*唯一の適法な*受け取り経路)がここでも使える。**決裁は、そのハッシュがオンチェーンにアンカーされて初めて効力を持つ**とすれば、アンカーのない決定は、単に疑わしいのではなく定義上無効になる。

### 提起した論点

1. **選別の結果。** 立法と同じく、本体は対象外(🚫)とし、3つの候補を切り出すか?
2. **切り出し方。** 公文書、統計、情報公開は同じ仕組み(ハッシュ + 時刻 + 承認者)を共有する。提案: 1つの項目「行政記録のアンカリング」にまとめる。オンチェーンのデータから統計を直接計算するのは別の、後の構想とする(商取引や給与がオンチェーンにあることが前提になるため)。
3. **アンカーを効力の条件にするか。** 「アンカーなしでは効力なし」を採用するか?採用しなければ、この設計は書き換えを検出するだけで、記録を作らないことは検出できない。
4. **権限レジストリ。** 国家機能ではなく、横断的な基盤として扱う(たとえば`OfficialContractRegistry`の拡張。現在はコントラクトを載せており、人の役職は載せていない)。各アンカーに誰が承認したかを記録するなら、論点2のためにも必要になる可能性が高い。

### ステータス

ユーザーの回答待ち。

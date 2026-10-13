# Discussion Log: Legislative process

Records the back-and-forth on this feature's scoping, in order. See [`docs/state-design/citizenship/discussion-log.md`](../citizenship/discussion-log.md) for the format this follows.

---

## Round 1 — 2026-10-13 (Claude + user)

### What "legislative process" means

Before discussing a design, the user asked what "legislative process" concretely refers to, since they couldn't picture it. Claude explained it as the full path a rule (national law or municipal ordinance, 法律・条例) takes before it has force:

1. **Proposal** — a mayor/legislator submits a bill; residents can also force one via a signature-backed direct demand (直接請求).
2. **Deliberation** — committee and plenary discussion, amendments.
3. **Vote** — legislators vote (or residents, in a referendum).
4. **Promulgation** — the enacted text is published (官報・公報).
5. **Enforcement / amendment / repeal** — the rule takes effect, and is later changed.

Possible on-chain mappings were sketched for each step (proposer/time/text-hash records; per-version text hashes for amendment history; public roll-call records for legislators, with the existing voting primitive from [ADR 0013](../../decisions/0013-voting-model.md) reused for referendums; on-chain hash + effective date of the promulgated text; queryable version history). Claude also noted a key contrast with voting: residents' ballots must be **secret**, but legislators' votes should be **public**, because legislators are accountable to the electorate.

### The user's challenge: where is the actual improvement?

The user said they could not find anywhere in this process that web3 would actually improve, and asked whether the legislative process actually suffers from fraud or serious inefficiency.

Claude agreed: **the core legislative process offers little for on-chain records to fix.**

- An on-chain record adds value where the record-keeper might tamper with it, or where no trusted record-keeper exists. In the legislative core, bills, minutes (会議録), and the official gazette (官報) are already public and watched by the media, opposition parties, and researchers. Covert tampering with enacted text or minutes by an assembly secretariat is essentially unheard of.
- The real inefficiencies (slow or hollow deliberation, bureaucrats effectively drafting bills) are political/institutional, not record-integrity problems. Changing the recording technology does not touch them.
- Version history of statutes already exists (e-Gov 法令検索).

Two **peripheral** problems were identified as genuine:

1. **Forgery of direct-demand petition signatures — an actual, recent fraud.** In the 2020 recall campaign against the Governor of Aichi Prefecture, roughly 83% of the ~435,000 submitted signatures were ruled invalid. Part-time workers had been hired to copy names onto the petition rolls en masse; the campaign leadership was criminally prosecuted. If each signature were an electronic signature made by the resident themself from their `ResidentLink` address, this kind of forgery would be structurally impossible.
2. **Individual legislators' votes often go unrecorded.** Many local assemblies vote by standing (起立採決), so there is no official record of which member voted which way, and voters cannot check their representatives' decisions. This is fixable by institutional rule alone. But an on-chain roll call makes recording the default, and its real value appears when it is **joined with political-donation data**: who funded a legislator, and how that legislator then voted.

### Decision

The user accepted this direction. They specifically wanted forgery like the 2020 Aichi case prevented, and confirmed that direct-demand signatures are to be treated **as an extension of `ResidentLink`, or as a sibling of the voting design (public, non-secret signatures)**.

- The legislative process **as a standalone function is not designed**. It is marked 🚫 Deliberately excluded, with reasons.
- **Direct-demand petition signatures (直接請求の署名)** become their own 🔴 Not-started item under Governance Core, to be designed later.
- **Legislators' roll-call vote records (議員の記名採決記録)** are folded into the scope of the **political donations** design.
- The decision criteria used here are written down as a reusable test ([ADR 0014](../../decisions/0014-legislative-process-scope.md), [spec](README.md)), so the remaining 🔴 candidates (executive, judiciary, …) can be screened the same way.

### Status

Scoping resolved. Next: political donations (政治献金), including legislators' roll-call records.

---

# 議論ログ: 立法プロセス(日本語)

この機能のスコープ決定に関するやり取りを順番に記録します。形式は [`docs/state-design/citizenship/discussion-log.md`](../citizenship/discussion-log.md) に従います。

---

## Round 1 — 2026-10-13(Claude + ユーザー)

### 「立法プロセス」とは何か

設計の議論に入る前に、ユーザーは「立法プロセス」が具体的に何を指すのかイメージが湧かないとして、説明を求めた。Claudeは、ルール(法律・条例)が効力を持つまでの一連の流れとして次のように説明した。

1. **提案** — 首長や議員が議案を提出する。住民も署名を集めて直接請求できる。
2. **審議** — 委員会・本会議での議論と修正。
3. **採決** — 議員が採決する(住民投票なら住民が投票する)。
4. **公布** — 成立した条文を官報・公報で公開する。
5. **施行・改正・廃止** — 効力が発生し、その後に変更される。

各段階のオンチェーン化の例も示した。提案者・日時・条文ハッシュの記録、版ごとの条文ハッシュによる修正履歴、議員の公開記名採決、住民投票での既存の投票プリミティブ([ADR 0013](../../decisions/0013-voting-model.md))の再利用、公布条文のハッシュと発効日の記録、版履歴の参照である。あわせて投票との重要な違いを指摘した。住民の投票は**秘密**でなければならないが、議員は有権者に説明責任を負うので、議員の採決は**公開**であるべきである。

### ユーザーの問題提起: 実際にどこが改善されるのか

ユーザーは、このプロセスの中でweb3が実際に改善できる場所が見当たらないと述べ、立法プロセスで不正や大きな非効率が実際に起きているのかを尋ねた。

Claudeはこれに同意した。**立法プロセスの本体には、オンチェーン記録で直せる問題がほとんどない。**

- オンチェーン記録が価値を持つのは、記録の管理者が改ざんする恐れがある場合か、信頼できる管理者がいない場合である。立法の本体では、議案・会議録・官報はすでに公開されており、メディア、野党、研究者が常に監視している。議会事務局が成立条文や議事録をこっそり書き換えた事件は、ほぼ聞かれない。
- 実際の非効率(審議の遅さや形骸化、官僚による実質的な条文作成)は政治・制度の問題であり、記録の完全性の問題ではない。記録技術を変えても解決しない。
- 法令の版管理はすでに存在する(e-Gov法令検索)。

一方で、**周辺部**に本物の問題が2つあると整理した。

1. **直接請求の署名偽造 — 実際に起きた最近の不正。** 2020年の愛知県知事リコール運動では、提出された約43万5千筆のうち約83%が無効と判定された。アルバイトを雇って署名簿に名前を大量に書き写させていたもので、運動の幹部は刑事訴追された。署名を「住民本人が自分の`ResidentLink`アドレスから行う電子署名」にすれば、この種の偽造は構造的に不可能になる。
2. **議員個人の賛否が記録されないことが多い。** 多くの地方議会は起立採決のため、どの議員がどちらに投票したかが公式に残らず、有権者は代表者の判断を検証できない。これは制度上のルールだけでも直せる。ただしオンチェーンの記名採決にすれば記録されることが標準になり、さらに**政治献金データと突き合わせたとき**に本当の価値が出る。「誰から献金を受けた議員が、どう投票したか」が分かるからである。

### 決定

ユーザーはこの方向性を了承した。特に2020年の愛知県の事件のような偽造は防ぎたいとし、直接請求の署名は**`ResidentLink`の拡張、または投票設計の兄弟機能(秘密ではない公開署名)として扱う**ことを確認した。

- **独立した機能としての立法プロセスは設計しない。** 理由を明記したうえで 🚫 意図的に対象外 とする。
- **直接請求の署名**は、統治の中核カテゴリの独立した 🔴 未着手 項目とし、後で設計する。
- **議員の記名採決記録**は**政治献金**の設計スコープに含める。
- ここで使った判断基準は、再利用できるテストとして明文化した([ADR 0014](../../decisions/0014-legislative-process-scope.md)、[仕様](README.md))。残りの 🔴 候補(行政、司法など)も同じ基準でふるいにかけられるようにするためである。

### ステータス

スコープ決定済み。次は政治献金(議員の記名採決記録を含む)。

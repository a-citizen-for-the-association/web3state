# Discussion Log: Personal data held by companies (企業が保有する個人情報)

Records the back-and-forth on this feature's design, in order. See [`docs/state-design/citizenship/discussion-log.md`](../citizenship/discussion-log.md) for the format this follows.

---

## Round 0 — 2026-11-07 (user)

Added by the user during the scope triage ([ADR 0027](../../decisions/0027-remaining-scope-triage.md)): security incidents involving personal data held by companies are now extremely frequent, and the user wants the project to address them with a blockchain.

Direction set by the user: **companies should basically not hold personal data. Only the items that are needed should be provided as NFTs or dedicated contracts, and a law should make that mandatory.**

---

## Round 1 — 2026-11-07 (Claude)

### Background: the current situation

- Under the Act on the Protection of Personal Information (個人情報保護法), companies may collect personal data for a stated purpose and must protect it; serious leaks must be reported to the Personal Information Protection Commission. Nothing limits *how much* a company may keep, as long as a purpose is stated.
- Companies typically keep name, address, phone, email, date of birth, copies of ID documents (for identity checks), passwords and card numbers.

Known incidents (the pattern matters more than the numbers):
- **Insiders at subcontractors:** Benesse (2014, about 35 million records sold by a subcontractor's engineer); NTT West group (2023, about 9 million records taken by a subcontractor's temporary worker over about ten years).
- **Ransomware:** KADOKAWA (2024); a printing and data-processing contractor serving many municipalities and banks (2024).
- **Web-shop card skimming:** repeated cases where card numbers were taken from checkout pages.
- **Public bodies too:** the Japan Pension Service leak (2015, about 1.25 million records).

Common causes: data that did not need to be kept was kept; many people (especially subcontractors) could access it; misuse went unnoticed for years.

### What already exists in this project

- **Identity and credentials hold no personal data on-chain.** `ResidentLink` proves only "linked to a resident of municipality X" ([ADR 0003](../../decisions/0003-resident-link-identity-model.md)). Passport, diploma, license, health insurance, employee ID and vaccination credentials prove only possession ([ADR 0006](../../decisions/0006-passport-credential.md)–[0011](../../decisions/0011-vaccination-credential.md)).
- **Payments are made from the person's own `ResidentLink` address** in a stablecoin ([ADR 0004](../../decisions/0004-taxation-payment-rail.md), [ADR 0020](../../decisions/0020-certified-address-stablecoin.md)), so **card numbers are no longer needed at all.**
- **Hash anchoring** exists for public bodies (`DocumentRegistry`, [ADR 0017](../../decisions/0017-executive-document-anchoring-v1.md)).
- Only the municipality knows which address belongs to which person.

### An important limit

**Personal data itself must never be put on-chain, not even encrypted.** A public chain cannot forget: a leak there is permanent, and encrypted data can be copied today and decrypted years later. So "NFTs and dedicated contracts" can carry only **claims** ("over 20", "holds a driving licence", "resident of X") issued by an authority, never the underlying data.

### On-chain value test ([ADR 0014](../../decisions/0014-legislative-process-scope.md)), sub-part by sub-part

| Sub-part | Q1 problem | Q2 keeper | Q3 technical | Q4 no record | Q5 combination | Result |
|---|---|---|---|---|---|---|
| **Identity and attribute checks** (age, residence, qualifications) | **Yes**: ID copies kept and leaked | **Yes**: every company keeps its own copy | **Yes**: proof without data | **Yes** | **Strong**: existing credentials | **Candidate (core)**: verify on-chain, keep nothing |
| **Login** | **Yes**: password leaks | Yes | **Yes**: signature instead of password | — | **Strong**: `ResidentLink` address | **Candidate**: wallet-signature login |
| **Payment data** | **Yes**: card skimming | Yes | **Yes** | — | **Strong**: stablecoin | **Already solved** (no card numbers exist) |
| **Delivery address** | **Yes** | Yes | **Partly**: anonymous delivery already exists commercially | — | Moderate | **Candidate**: the merchant never receives it |
| Name, phone, email for contracts and contact | Yes | Yes | **Mostly no**: some contacts genuinely need them | — | Weak | Off-chain, purpose-bound, retention-limited |
| **Detecting misuse** (insiders, long-running theft) | **Yes**: unnoticed for years | **Yes** | **Yes**: tamper-evident access logs | **Yes** | Moderate | **Candidate**: anchored access logs |
| Ransomware, system intrusion | Yes | — | **No**: system security | — | — | Out of reach; minimisation shrinks the damage |

### Proposal

A **"don't hold it" law** with three layers:
1. **What can be proved is not collected.** If a fact can be verified from a credential at the person's address, a company must verify it at the time of use and keep only the result, not the data or a copy of an ID document.
2. **What cannot be proved is minimised.** Login by signature (no passwords); payment by stablecoin (no card numbers); delivery through the carrier without the merchant seeing the address; other data only for a stated purpose and deleted when the purpose ends.
3. **What remains is watched.** Access to the remaining personal data is logged, and the log is anchored on-chain by hash, so a long-running insider theft cannot be hidden by editing the logs.

### Issues raised

1. **Interpreting "provide as NFTs or contracts".** Claude reads the user's direction as: the *person* holds credential NFTs at their own address; companies *read* them when needed and store nothing. Companies themselves never mint NFTs containing customers' data. Is this the intended meaning?
2. **Customer identifier and login.** The customer's identifier at a company is their address, and login is by wallet signature (the established standard, EIP-4361 "Sign-In with Ethereum"). The address is already visible to the merchant whenever the customer pays (ADR 0020), so a leaked customer list adds little. Proposal: adopt.
3. **Attribute credentials.** Companies most often ask for age. No existing credential proves it. Options:
   - (a) **The municipality issues small "age threshold" credentials** (e.g. "18 or over", "20 or over") to the `ResidentLink` address when the person reaches the age. Possession-only, no birth date on-chain.
   - (b) Zero-knowledge proofs over a birth date held by the person. More flexible, but needs new cryptography.

   Proposal: **(a)**; add other thresholds only when a real need appears.
4. **Delivery address.** Options:
   - (a) **The merchant hands the parcel to the carrier with the buyer's address (blockchain address) as the label; the buyer gives their physical address only to the carrier.** This is how anonymous delivery on flea-market apps already works.
   - (b) The merchant receives the address and must delete it after delivery.

   Proposal: **(a)** as the legal default; (b) only where (a) is impossible (e.g. installation work at home).
5. **Data that cannot be avoided** (name on a contract, contact details). Allowed only for a stated purpose, deleted when the purpose ends, with the retention period set by law per kind of data. Proposal: adopt; the details are legislation, not chain design.
6. **Anchoring access logs.** Every company (and contractor) that still holds personal data must anchor the hash of its access log at a fixed interval (e.g. daily). Corporations have no `DocumentRegistry`. Options:
   - (a) **One shared, minimal `AnchorRegistry` contract** where any registered corporation can record a hash with a type tag. It would also cover most of the on-hold notarization item later.
   - (b) Give each corporation its own registry contract.

   Proposal: **(a)**.
7. **Scope.** Proposal: the "don't collect what can be proved" and delivery rules apply to companies; the access-log rule applies to companies **and to public bodies and their contractors**, since the pension and municipal-contractor leaks show the same pattern there. Ransomware defence itself stays out of scope; it is system security.

### Status

Awaiting the user's response.

---

## Round 2 — 2026-11-07 (user + Claude)

### User's decisions

Issues 1–7 **as proposed**: the person holds the credentials and companies only read them (Issue 1); address as customer identifier and signature login (2); municipal age-threshold credentials, option (a) (3); merchants never receive the delivery address, option (a), with (b) only where unavoidable (4); purpose-bound, retention-limited unavoidable data (5); one shared `AnchorRegistry`, option (a) (6); access-log rule also for public bodies and contractors (7).

### Adjustments made while writing the spec (flagged for review)

- **`AnchorRegistry` is event-only.** `anchor(hash, kind)` checks that the caller is a certified corporate or public address and emits an event; it stores nothing. Nobody needs to look anchors up from inside a contract, so storage would be waste ("off-chain if it can be").
- **A missed anchor is itself visible.** Each holder of personal data anchors one Merkle root of its access log per day. A day with no anchor from a company that is required to anchor shows on-chain and is a violation in itself. The log stays with the company; the regulator (or a court) can demand it and check it against the root.
- **Age credentials are never burned on a move,** because an age threshold, once reached, stays true. A verifier checks both a valid `ResidentLink` and the age credential at the same address. On death the `ResidentLink` burn is enough. Visitors (visitor pass) have no age credential; their age is checked off-chain from the passport, without keeping a copy.
- **What a company may keep after a check:** the address, which fact was checked, and the block number at which it was true. Nothing else.

### Status

All issues resolved. Spec written ([`README.md`](README.md)); ADR: [0028](../../decisions/0028-personal-data-model.md). The four adjustments were accepted in Round 3.

---

## Round 3 — 2026-11-07 (user)

The user **accepted the four Round 2 adjustments** ("了解") and asked to pause here. No open points remain.

---

# 議論ログ: 企業が保有する個人情報(日本語)

この機能の設計に関するやり取りを順に記録する。形式は[`docs/state-design/citizenship/discussion-log.md`](../citizenship/discussion-log.md)に従う。

---

## Round 0 — 2026-11-07(ユーザー)

スコープの振り分け([ADR 0027](../../decisions/0027-remaining-scope-triage.md))の際にユーザーが追加した: 企業が持つ個人情報のセキュリティインシデントが近年きわめて多く、そこはブロックチェーンで対応したい。

ユーザーが示した方向: **基本的に企業には個人情報を持たせない。必要な項目だけをNFTや独自コントラクトにして持たせ、それを法律で義務付ける。**

---

## Round 1 — 2026-11-07(Claude)

### 背景: 現在の状況

- 個人情報保護法のもとで、企業は利用目的を示せば個人情報を集めてよく、それを守る義務を負う。重大な漏洩は個人情報保護委員会に報告しなければならない。目的を示しさえすれば、*どれだけ*持つかに制限はない。
- 企業は通常、氏名、住所、電話番号、メールアドレス、生年月日、本人確認書類の写し、パスワード、カード番号を保持している。

知られているインシデント(数字よりパターンが重要):
- **委託先の内部の人間:** ベネッセ(2014年、委託先のエンジニアが約3500万件を売却)、NTT西日本グループ(2023年、委託先の派遣社員が約10年にわたり約900万件を持ち出し)。
- **ランサムウェア:** KADOKAWA(2024年)、多くの自治体や銀行から業務を受託していた印刷・データ処理会社(2024年)。
- **通販サイトでのカード情報の窃取:** 決済画面からカード番号が盗まれる事例が繰り返し起きている。
- **公的機関も同じ:** 日本年金機構の漏洩(2015年、約125万件)。

共通する原因: 持つ必要のないデータを持っていた。多くの人(特に委託先)がアクセスできた。不正が何年も気づかれなかった。

### このプロジェクトに既にあるもの

- **本人確認とクレデンシャルは、オンチェーンに個人情報を持たない。** `ResidentLink`が証明するのは「市区町村Xの住民と結びついている」ことだけである([ADR 0003](../../decisions/0003-resident-link-identity-model.md))。パスポート、卒業証明、免許証、健康保険証、社員証、接種証明のクレデンシャルは、保有していることだけを証明する([ADR 0006](../../decisions/0006-passport-credential.md)〜[0011](../../decisions/0011-vaccination-credential.md))。
- **支払いは本人の`ResidentLink`アドレスからステーブルコインで行う**([ADR 0004](../../decisions/0004-taxation-payment-rail.md)、[ADR 0020](../../decisions/0020-certified-address-stablecoin.md))ので、**カード番号はそもそも不要になる。**
- 公的機関には**ハッシュのアンカリング**がある(`DocumentRegistry`、[ADR 0017](../../decisions/0017-executive-document-anchoring-v1.md))。
- どのアドレスが誰のものかを知っているのは市区町村だけである。

### 重要な限界

**個人情報そのものは、暗号化しても、決してオンチェーンに載せてはならない。** 公開チェーンは忘れることができない。そこでの漏洩は永久に残り、暗号化したデータも今コピーされて何年も後に解読されうる。したがって「NFTや独自コントラクト」に載せられるのは、機関が発行する**事実の証明**(「20歳以上」「運転免許を持っている」「Xの住民」)だけで、その基になるデータではない。

### オンチェーン価値テスト([ADR 0014](../../decisions/0014-legislative-process-scope.md))、部分ごと

| 部分 | Q1 問題 | Q2 管理者 | Q3 技術的 | Q4 記録なし | Q5 組み合わせ | 結果 |
|---|---|---|---|---|---|---|
| **本人確認と属性の確認**(年齢、居住、資格) | **あり**: 本人確認書類の写しが保管され漏れる | **あり**: 各企業がそれぞれ写しを持つ | **あり**: データなしで証明できる | **あり** | **強い**: 既存のクレデンシャル | **候補(中核)**: オンチェーンで確認し、何も保持しない |
| **ログイン** | **あり**: パスワードの漏洩 | あり | **あり**: パスワードの代わりに署名 | — | **強い**: `ResidentLink`アドレス | **候補**: ウォレットの署名でログイン |
| **決済情報** | **あり**: カード情報の窃取 | あり | **あり** | — | **強い**: ステーブルコイン | **解決済み**(カード番号が存在しない) |
| **配送先の住所** | **あり** | あり | **一部**: 匿名配送はすでに商用で存在する | — | 中程度 | **候補**: 販売者が受け取らない |
| 契約や連絡のための氏名、電話、メール | あり | あり | **ほぼなし**: 本当に必要な連絡もある | — | 弱い | オフチェーン。目的に限定し、保存期間を制限 |
| **不正の検知**(内部の人間、長期の持ち出し) | **あり**: 何年も気づかれない | **あり** | **あり**: 改ざんが検知できるアクセスログ | **あり** | 中程度 | **候補**: アクセスログのアンカリング |
| ランサムウェア、システムへの侵入 | あり | — | **なし**: システムのセキュリティ | — | — | 対象外。最小化で被害を小さくする |

### 提案

3層からなる**「持たせない」法律**:
1. **証明できるものは集めない。** ある事実を本人のアドレスにあるクレデンシャルで確認できるなら、企業は利用時にそれを確認し、結果だけを保持する。データや本人確認書類の写しは保持しない。
2. **証明できないものは最小にする。** ログインは署名で(パスワードなし)、支払いはステーブルコインで(カード番号なし)、配送は販売者が住所を見ずに配送業者を通して行う。それ以外のデータは示した目的のためだけに持ち、目的が終われば削除する。
3. **残るものは見張る。** 残った個人情報へのアクセスを記録し、そのログをハッシュでオンチェーンにアンカリングする。長期にわたる内部の持ち出しを、ログの書き換えで隠せなくなる。

### 提起した論点

1. **「NFTや独自コントラクトにして持たせる」の解釈。** Claudeはユーザーの方向を次のように理解した: クレデンシャルのNFTを持つのは*本人*で、自分のアドレスに保有する。企業は必要なときにそれを*読む*だけで、何も保存しない。企業が顧客のデータを含むNFTを自らmintすることはない。この意味で合っているか。
2. **顧客の識別子とログイン。** 企業での顧客の識別子は本人のアドレスとし、ログインはウォレットの署名で行う(確立した標準のEIP-4361「Sign-In with Ethereum」)。顧客が支払うたびにアドレスは販売者にすでに見えているので(ADR 0020)、顧客一覧が漏れても追加の被害は小さい。提案: 採用。
3. **属性のクレデンシャル。** 企業が最もよく求めるのは年齢だが、それを証明する既存のクレデンシャルはない。選択肢:
   - (a) **市区町村が、本人がその年齢に達したときに、小さな「年齢の基準」のクレデンシャル**(例:「18歳以上」「20歳以上」)を`ResidentLink`アドレスに発行する。保有だけを示し、生年月日はオンチェーンに載らない。
   - (b) 本人が持つ生年月日についてのゼロ知識証明。柔軟だが、新しい暗号技術が必要になる。

   提案: **(a)**。ほかの基準は、本当に必要になったときにだけ追加する。
4. **配送先の住所。** 選択肢:
   - (a) **販売者は購入者のアドレス(ブロックチェーンのアドレス)を宛先として荷物を配送業者に渡し、購入者は実際の住所を配送業者にだけ伝える。** フリマアプリの匿名配送はすでにこの仕組みで動いている。
   - (b) 販売者が住所を受け取り、配送後に削除しなければならない。

   提案: 法律上の原則は**(a)**とし、(a)ができない場合(自宅での設置工事など)に限り(b)とする。
5. **避けられないデータ**(契約上の氏名、連絡先)。示した目的のためだけに認め、目的が終われば削除する。保存期間はデータの種類ごとに法律で定める。提案: 採用。詳細は立法の問題で、チェーンの設計ではない。
6. **アクセスログのアンカリング。** 個人情報をまだ持つすべての企業(と委託先)は、アクセスログのハッシュを一定の間隔(例: 毎日)でアンカリングしなければならない。法人には`DocumentRegistry`がない。選択肢:
   - (a) **共有の最小限の`AnchorRegistry`コントラクトを1つ作り**、登記済みの法人なら誰でも種類のタグ付きでハッシュを記録できるようにする。保留中の公証の項目の大部分も、後でこれでまかなえる。
   - (b) 法人ごとに専用のレジストリコントラクトを持たせる。

   提案: **(a)**。
7. **スコープ。** 提案: 「証明できるものは集めない」と配送のルールは企業に適用する。アクセスログのルールは企業に加えて**公的機関とその委託先**にも適用する。年金と自治体の委託先の漏洩が、同じパターンがそこにもあることを示しているからである。ランサムウェアの防御そのものはシステムのセキュリティなのでスコープ外とする。

### ステータス

ユーザーの回答待ち。

---

## Round 2 — 2026-11-07(ユーザー＋Claude)

### ユーザーの決定

論点1〜7は**提案どおり**: クレデンシャルは本人が持ち、企業は読むだけ(論点1)。アドレスを顧客の識別子とし、署名でログイン(2)。市区町村による年齢の基準のクレデンシャル、選択肢(a)(3)。販売者は配送先の住所を受け取らない、選択肢(a)、やむをえない場合だけ(b)(4)。避けられないデータは目的に限定し保存期間を制限(5)。共有の`AnchorRegistry`を1つ、選択肢(a)(6)。アクセスログのルールは公的機関と委託先にも適用(7)。

### 仕様を書く際に加えた調整(確認待ち)

- **`AnchorRegistry`はイベントだけを出す。** `anchor(hash, kind)`は呼び出し元が認定された法人または公的なアドレスであることを確認してイベントを出し、何も保存しない。コントラクトの中からアンカーを参照する必要は誰にもないので、保存は無駄になる(「オフチェーンでできることはオフチェーンで」)。
- **アンカーの欠落自体が見える。** 個人情報を持つ者は、アクセスログのマークルルートを1日1つアンカリングする。義務のある企業からアンカーがない日はオンチェーンでわかり、それ自体が違反となる。ログは企業が保管し、規制当局(または裁判所)が提出を求めてルートと照合できる。
- **年齢のクレデンシャルは転居してもburnしない。** 一度達した年齢の基準はずっと真だからである。確認する側は、同じアドレスで有効な`ResidentLink`と年齢のクレデンシャルの両方を確認する。死亡の場合は`ResidentLink`のburnで足りる。訪問者(訪問者パス)には年齢のクレデンシャルがないので、年齢はパスポートからオフチェーンで確認し、写しは保管しない。
- **確認の後に企業が保持してよいもの:** アドレス、どの事実を確認したか、それが真だったブロック番号。それ以外は保持しない。

### ステータス

すべての論点が解決。仕様を作成([`README.md`](README.md))。ADR: [0028](../../decisions/0028-personal-data-model.md)。4つの調整はRound 3で了承された。

---

## Round 3 — 2026-11-07(ユーザー)

ユーザーは**Round 2の4つの調整を了承し**(「了解」)、ここで中断するよう求めた。未決の点は残っていない。

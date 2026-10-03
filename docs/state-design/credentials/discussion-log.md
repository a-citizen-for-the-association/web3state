# Discussion Log: Credentials Design

Records the back-and-forth on this feature's design, in order. See [`docs/state-design/citizenship/discussion-log.md`](../citizenship/discussion-log.md) for the format this follows.

---

## Round 1 — 2026-10-03 (Claude)

### User's proposal (as given)

- A credential issuer has a corporation-like blockchain address (reusing the [corporations](../corporations/) pattern) and deploys/controls the contract that mints credential NFTs to holders.
- Aim: diplomas (卒業証明), passports (パスポート), licenses (免許証), employee IDs (社員証), health-insurance certificates (医療証), vaccination certificates (接種券), and similar, all issuable and operable this way.

### Issues raised before implementation

**1. These examples span at least four different issuer trust models — one attestation mechanism won't fit all of them.**

Sorting the examples by who issues them:

| Example | Issuer | Natural trust-anchor |
|---|---|---|
| Passport | National government (外務省) | `.go.jp` — already established (taxation design) |
| Driver's/professional license | Government body (公安委員会, etc.) | `.go.jp`/`.lg.jp` — already established |
| Diploma | School (public or private) | `.ac.jp`/`.ed.jp` — a new but structurally identical pattern (also a restricted, vetted TLD) |
| Employee ID | A private employer | **The existing [corporations](../corporations/) registration NFT** — if an address already holds a valid corporate registration naming it "Company X," an employee-ID NFT minted from that same address can be trusted as "issued by Company X" with **no new trust mechanism needed at all** |
| Health-insurance certificate | 健康保険組合 / 協会けんぽ / municipality (for 国民健康保険) | Municipalities are already covered; insurance associations are quasi-public bodies needing their own regulator-anchored mechanism (likely 厚生労働省/`.go.jp`) — same category already flagged in `docs/BACKLOG.md` for private financial institutions |
| Vaccination certificate | Typically a municipality (or workplace campaigns) | Municipalities already covered |

Proposal: don't force one universal attestation mechanism. Reuse `.go.jp`/`.lg.jp` for government issuers (already built), extend the same *principle* to `.ac.jp`/`.ed.jp` for schools, and — notably — **employer-issued credentials can piggyback entirely on the already-designed corporate registration**, since the issuing address's legitimacy as "Company X" is already established there. Confirm this direction.

**2. Data sensitivity varies enormously across these examples — the corporations model (public by design) is the wrong default for most of them.**

Corporations were made fully public on-chain because the *subject* (the company) is itself expected to be transparent. Here, the *subject* of each credential is a **private individual** — the same individual the citizenship design went to great lengths to protect. Sorting by sensitivity:

- **High sensitivity** (should get citizenship-level protection — minimal on-chain data, existence/validity checkable but details not broadcast): passport (core PII — photo, DOB, passport number), health-insurance certificate, vaccination certificate (health data).
- **Moderate** (the bare fact of validity is plausibly public-interest, like verifying a doctor's license today, but ancillary PII like a home address printed on a physical license should not be on-chain): driver's/professional licenses.
- **Lower, but not zero** (often voluntarily shared today, e.g. on a résumé, but making it permanent/immutable/public by default removes the holder's current ability to not disclose it): diploma, employee ID.

Proposal: **default every credential type to the citizenship privacy model** (minimal on-chain data; the holder discloses/proves possession when they choose to, rather than it being broadcast) unless there's a specific, articulated public-interest reason for a given credential type to be more open (e.g., license validity lookups serving consumer protection) — the reverse of how corporations were designed. Confirm this default, since "あらゆるものをブロックチェーン上で発行・運用する" could otherwise be read as putting all this detail on-chain the way corporate data was.

**3. Lifecycle/revocation needs vary by credential type — but the corporations update/burn pattern likely generalizes as a starting template.**

Diplomas are essentially permanent; licenses expire and renew; passports expire; employee IDs end at termination; insurance certificates change when coverage changes. Proposal: reuse the corporations pattern (issuer-only field updates for routine changes like renewal, burn for actual cessation like revocation or termination) as the default template per credential type, tuned per type rather than inventing a new lifecycle model from scratch each time.

**4. Scope check: design one exemplar first, or all six at once?**

Given how different these are, proposal: fully design **one concrete credential type first** to validate the general pattern (trust-anchor generalization, privacy model, lifecycle), then apply the same validated pattern more quickly to the others. Suggest starting with the **passport/nationality credential** specifically, since it was already flagged as a deferred dependency from the citizenship design (Issue 1) and from the voting-prioritization discussion just had — designing it now clears that backlog item and unblocks future voting design. Confirm this starting point, or state a different preference.

---

## Round 2 — 2026-10-03 (User + Claude) — Issues 2 and 4 resolved

### User (Issue 2)

Confirms: an NFT proves only that an address holds it — nothing more goes on-chain, ever.

### Claude

Noted the consequence: since NFTs carry no fields, finer-grained distinctions within one credential type (e.g., which faculty/graduation year for a diploma) must be expressed by **which contract** a holder's NFT comes from, not by data within a shared contract — pushing all classification into contract-per-sub-type granularity.

### User

Confirms, and adds: granularity should be decided per credential type based on practical operational convenience, not a fixed rule — e.g., a diploma likely warrants a separate contract per faculty/graduation year (natural, static distinctions), while an employee ID is better managed as a single contract per company (employment status is fluid — role changes shouldn't require new NFTs), decided case-by-case as each credential type is designed.

### Resolution (Issue 2)

**RESOLVED.** NFTs are pure possession-proof — zero additional on-chain fields, project-wide for this feature. Granularity (one contract per sub-type vs. one contract covering many) is a per-credential-type judgment call based on operational practicality, decided individually as each type is designed — not a fixed rule.

### User (Issue 4 — numbered differently by the user, treated as the same proposal)

Confirms: proceed one credential type at a time, checking for issues at each. Starts with passport.

### Resolution (Issue 4)

**RESOLVED.** Proceeding one credential type at a time. First: passport — see [`passport/discussion-log.md`](passport/discussion-log.md).

### Status

Issues 1–4 (general, cross-cutting) resolved enough to proceed. Issue 1's specific trust-anchor choices and Issue 3's lifecycle details are being worked out per credential type as each is designed, starting with passport.

---

# 議論ログ: 公的証明の設計(続き)(日本語)

## Round 2 — 2026-10-03(ユーザー + Claude)— Issue 2, 4解決

### ユーザー(Issue 2)

確認: NFTが証明するのは保持している事実のみ — それ以上は一切オンチェーンに載せない。

### Claude

帰結を指摘: NFTがフィールドを持たない以上、同じ証明の種類の中での細かい区別(卒業証明の学部・卒業年度等)は、共有コントラクト内のデータではなく、**どのコントラクトのNFTか**によって表現する必要がある — 分類の全てがコントラクト単位の粒度に押し出される。

### ユーザー

確認。さらに追加: 粒度は固定ルールではなく、証明の種類ごとに実運用上の分かりやすさで判断すべき — 例えば卒業証明は学部・卒業年度ごとに別コントラクトが自然(静的で明確な区別)、一方で社員証は会社ごとに1つのコントラクトで管理する方が良い(雇用状況は流動的で、役職変更のたびに新しいNFTを発行すべきではない)。証明の種類ごとに個別に判断する。

### 解決(Issue 2)

**解決。** NFTは純粋な保持の証明のみ — この機能全体を通じて、追加のオンチェーンフィールドは一切持たない。粒度(細分化したコントラクトか、1つのコントラクトでまとめるか)は、証明の種類ごとに実運用上の判断とし、固定ルールにはしない。各証明の種類を設計する際に個別に決定する。

### ユーザー(Issue 4 — ユーザーは別の番号で言及したが、同じ提案として扱う)

確認: 1つずつ、問題の有無を確認しながら進める。パスポートから開始。

### 解決(Issue 4)

**解決。** 証明の種類を1つずつ進める。最初はパスポート — [`passport/discussion-log.md`](passport/discussion-log.md) を参照。

### ステータス

横断的な論点(Issue 1〜4)は、先に進めるのに十分な程度まで解決。Issue 1の具体的な信頼の起点の選択とIssue 3のライフサイクルの詳細は、各証明の種類を設計する際に個別に詰めていく。まずパスポートから。

Awaiting the user's responses to issues 1–4 before writing the spec.

---

# 議論ログ: 公的証明の設計(日本語)

形式は [`docs/state-design/citizenship/discussion-log.md`](../citizenship/discussion-log.md) に準じます。

---

## Round 1 — 2026-10-03(Claude)

### ユーザーの提案(原文のまま)

- 証明の発行主体は、[法人設計](../corporations/)と同じパターンの、法人に類するブロックチェーンアドレスを持ち、証明NFTを発行するコントラクトをデプロイ・管理する。
- 目指す世界: 卒業証明、パスポート、免許証、社員証、健康保険証、ワクチン接種証明等を、全てこの方法で発行・運用できるようにする。

### 実装前に提起する論点

**1. 挙げられた例は、少なくとも4種類の異なる信頼モデルにまたがっており、単一の証明方法では足りません。**

発行主体ごとに整理すると:

| 例 | 発行主体 | 自然な信頼の起点 |
|---|---|---|
| パスポート | 国(外務省) | `.go.jp` — 納税設計で既に確立済み |
| 運転免許証・専門職の免許 | 政府機関(公安委員会等) | `.go.jp`/`.lg.jp` — 既に確立済み |
| 卒業証明 | 学校(公立・私立) | `.ac.jp`/`.ed.jp` — 新規だが構造的には同じパターン(こちらも審査制の制限ドメイン) |
| 社員証 | 民間の雇用主 | **既存の[法人設計](../corporations/)の登録NFT** — あるアドレスが既に「A社」という法人登録を保有していれば、同じアドレスから発行される社員証NFTは「A社が発行したもの」として、**新しい信頼の仕組みを一切作らずに**信頼できる |
| 健康保険証 | 健康保険組合・協会けんぽ・市区町村(国民健康保険) | 市区町村は既にカバー済み。保険組合は準公的な団体であり、独自の規制当局を起点にした仕組み(おそらく厚生労働省/`.go.jp`)が必要 — 納税設計の`docs/BACKLOG.md`で既に指摘した民間の金融機関と同じカテゴリ |
| ワクチン接種証明 | 典型的には市区町村(または職域接種) | 市区町村は既にカバー済み |

提案: 単一の普遍的な証明方法を強制しない。政府発行のものには`.go.jp`/`.lg.jp`(既存)を流用し、学校には同じ原理を`.ac.jp`/`.ed.jp`に拡張する。特筆すべきは、**雇用主が発行する証明は、既存の法人登録にそのまま乗っかれる**ということです。発行アドレスが「A社」であることの正当性は法人設計で既に確立されているためです。この方向性でよいか確認させてください。

**2. データの機微性は例によって大きく異なり、ほとんどの場合、法人モデル(設計上オンチェーンで公開)はデフォルトとして不適切です。**

法人を完全にオンチェーンで公開したのは、法人という**対象そのもの**が透明であるべきという前提があったからです。ここでの各証明の**対象**は**私人個人**であり、国民・住民設計が強く保護してきたのと同じ個人です。機微性で整理すると:

- **機微性が高い**(国民・住民設計と同じレベルの保護が必要 — オンチエーンのデータは最小限にし、有効性は確認できても詳細は公開しない): パスポート(写真、生年月日、パスポート番号等の中核的な個人情報)、健康保険証、ワクチン接種証明(いずれも健康情報)。
- **中程度**(有効性そのものは公益上公開が妥当な場合もある、今日の医師免許検索のようなものと同様だが、現物の免許証に印字された住所等の付随情報はオンチェーンに載せるべきではない): 運転免許証・専門職の免許。
- **低いが、ゼロではない**(今日もレジュメ等で自発的に開示されることが多いが、デフォルトで永続的・不変・公開にしてしまうと、本人が開示しないという選択肢を失う): 卒業証明、社員証。

提案: **全ての証明の種類について、デフォルトは国民・住民設計のプライバシーモデル**(オンチェーンのデータは最小限、本人が選んだときに保有を証明する、広く公開はしない)とし、特定の証明について明確で説明可能な公益上の理由(例: 消費者保護のための免許有効性の検索)がある場合に限り、より開示度を上げる、という形にする — 法人設計とは逆の発想です。「あらゆるものをブロックチェーン上で発行・運用する」という表現が、法人データと同じように全て詳細をオンチェーンに載せる、と読めてしまう可能性があるため、このデフォルトでよいか確認させてください。

**3. ライフサイクル・失効の扱いは証明の種類ごとに異なりますが、法人設計の更新/burnパターンが出発点のテンプレートとして一般化できそうです。**

卒業証明はほぼ永続的、免許証は有効期限があり更新される、パスポートも有効期限がある、社員証は退職時に終了する、保険証は加入状況が変わると変化します。提案: 法人設計のパターン(更新 — 更新のような日常的な変化は発行主体限定のフィールド更新、burn — 失効・取消・退職のような実際の終了)を各証明のデフォルトのテンプレートとして流用し、証明の種類ごとに微調整する、というやり方を提案します。

**4. スコープの確認: まず1つの具体例を設計するか、6つ全てを一度に設計するか?**

これだけ性質が異なる以上、提案: まず**1つの具体的な証明の種類**を完全に設計し(信頼の起点の一般化、プライバシーモデル、ライフサイクル)、その検証済みのパターンを残りに素早く適用する、という進め方を提案します。開始点としては、国民・住民設計のIssue 1と、先ほどの投票機能の優先順位の議論で既に先送りされていた**パスポート/国籍クレデンシャル**を推奨します。これを今設計すればバックログの項目を1つ解消でき、将来の投票機能の設計の前提条件も整います。この開始点でよいか、あるいは別の希望があれば教えてください。

### ステータス

Issue 1〜4についてユーザーの回答待ち。設計書の作成はその後。
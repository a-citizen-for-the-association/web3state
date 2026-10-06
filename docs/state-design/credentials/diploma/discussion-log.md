# Discussion Log: Diploma / Graduation Certificate

Records the back-and-forth on this specific credential, in order. See [`docs/state-design/citizenship/discussion-log.md`](../../citizenship/discussion-log.md) for the format this follows. This is a sub-discussion of [`docs/state-design/credentials/discussion-log.md`](../discussion-log.md).

---

## Round 1 — 2026-10-06 (Claude)

### Issues raised before implementation

**1. Reuse the existing corporations registration for school attestation — probably no new trust-anchor mechanism needed.**

Schools come in several institutional forms: 国立大学法人 (national university corporations, a special independent-administrative-corporation status since 2004), public schools (run by local boards of education), and private schools (学校法人, a special juridical-person category under 私学法, requiring MEXT or prefectural approval to establish). All three are, structurally, just another category of "specially-regulated corporation" already covered by the [corporations](../../corporations/) design (supervised by 文部科学省 and/or prefectural education boards, the same way financial institutions are supervised by 金融庁). Proposal: **don't introduce `.ac.jp`/`.ed.jp`-based attestation as a new mechanism** — instead, a school registers via the existing corporations pattern (as a specially-regulated corporation under MEXT/a prefectural board), and issues diploma NFTs from that same registered address, exactly like the "employee ID piggybacks on corporate registration" case already noted in the general credentials discussion. Confirm this direction, or state a preference for a `.ac.jp`/`.ed.jp`-anchored mechanism instead (also available, since both are real, restricted, vetted Japanese TLDs for academic/educational institutions).

**2. Granularity: contract-per-faculty/degree likely needed, but contract-per-graduation-year may not be.**

The user already stated (credentials-wide discussion) that diplomas likely warrant separate contracts per faculty/degree-level distinction (a natural, static classification). Noting a refinement: **graduation year may not need its own contract**, since — consistent with the citizenship design's Issue 5 reasoning (don't store on-chain what's already recoverable from an event's block data) — the year can be recovered from the mint transaction's timestamp. Confirm this refinement, or state a preference for per-year contracts anyway (e.g., for administrative clarity, a fresh contract each academic year).

**3. Lifecycle is simpler than anything designed so far: essentially permanent, mint-once, rare-burn.**

Unlike passport (which renews) or corporations (which have routinely-changing fields), a diploma doesn't expire or get updated. Proposal:
- **Mint**: authority (the school) only, after conferring the degree through its existing real-world graduation process.
- **Burn**: authority only, reserved for actual degree revocation (rare — e.g. academic fraud findings) — no self-burn, no routine use.
- **No renewal, no field updates** — simpler than every other credential designed so far, since there's nothing that legitimately changes about a conferred degree.

Confirm this is acceptable, or state if anything about degree revocation needs more nuance (e.g., should a revocation reason be recorded anywhere, even off-chain, the way citizenship/corporations keep reasons off-chain?).

**4. No dependency on `ResidentLink`.**

Mirroring passport's independence: a diploma is minted to whatever address the graduate provides, with no requirement to hold a `ResidentLink` NFT (a graduate may be a foreign student who was never a Japanese resident, or may have since moved away). Confirm.

---

## Round 2 — 2026-10-06 (User + Claude) — Issue 4 revised and resolved

### User

Disagrees with Claude's Issue 4 proposal: minting a diploma to an address that doesn't hold `ResidentLink` must not be allowed, reasoning that otherwise someone who isn't a Japanese national could graduate from a Japanese school. Requires `ResidentLink` as a mint precondition; transfer to another person is naturally still disallowed (soulbound, already established). Asks for advice on how to handle foreign nationals.

### Claude

Pointed out a conflation worth resolving: `ResidentLink` is deliberately nationality-neutral (ADR 0003) — both Japanese nationals and foreign residents hold the identical credential. So requiring it doesn't achieve "nationals only"; it achieves "residents only, any nationality." Proposed treating this as the actual, more useful gate: require `ResidentLink` as a precondition for minting, with no special-casing for foreign students — a foreign student who is a registered resident is treated identically to a Japanese national student. This directly answers the foreign-national question: no special handling needed at all, a direct consequence of `ResidentLink`'s nationality-neutral design. Acknowledged scope limitation: a graduate who was never a Japan resident (e.g. fully remote overseas distance learners) falls outside this on-chain system, continuing to rely on a traditional paper diploma — framed as a deliberate scope boundary, not a flaw.

Asked two follow-ups: (a) is this a one-time check at mint time only (so a diploma already issued isn't affected by later losing `ResidentLink`), and (b) should the check be enforced on-chain (applicant declares which municipality's `ResidentLink` contract to check, a cross-contract call mirroring citizenship's Issue 6 deduplication pattern) or verified off-chain only by the school.

### User

Confirms: one-time check at mint time only. The applicant self-declares (their address and which `ResidentLink` contract to check) — i.e., the on-chain cross-contract check option.

### Resolution (Issue 4, revised)

**RESOLVED.** Minting a `Diploma` NFT requires the recipient to hold a valid `ResidentLink` NFT, checked on-chain at mint time only (not an ongoing requirement — a diploma already issued remains valid even if the holder's `ResidentLink` is later burned, e.g. after moving abroad). The applicant declares their address and the specific `ResidentLink` contract (i.e., which municipality) to check; the school's `Diploma` contract performs a cross-contract `balanceOf` check against that declared contract at mint time, mirroring the pattern from citizenship's Issue 6. No special handling for foreign nationals — a registered foreign resident qualifies identically to a Japanese national resident, since `ResidentLink` itself makes no nationality distinction. Graduates who were never Japan residents are out of scope for this on-chain credential.

### Status

Issue 4 resolved (revised from Round 1). Awaiting the user's response to Issues 1–3.

---

## Round 3 — 2026-10-06 (User) — Issues 1–3 resolved, all issues closed

### User

Confirms all three.

### Resolution

- **Issue 1: RESOLVED.** Schools (national university corporations, public schools, private 学校法人) register via the existing [corporations](../../corporations/) pattern (specially-regulated, supervised by MEXT and/or a prefectural board of education) and issue `Diploma` NFTs from that same registered address. No new `.ac.jp`/`.ed.jp`-based trust mechanism.
- **Issue 2: RESOLVED.** Separate contracts per faculty/degree-level (a natural, static distinction). Graduation year is not given its own contract — recoverable from the mint event's block timestamp, consistent with the citizenship design's Issue 5 reasoning.
- **Issue 3: RESOLVED.** Simplest lifecycle designed so far: mint once (authority only, after conferring the degree), no updates, no renewal; burn reserved for rare degree revocation (authority only, no self-burn, no on-chain reason code — same minimization principle as citizenship/corporations).

## Summary: all issues resolved (2026-10-06)

| # | Issue | Resolution |
|---|---|---|
| 1 | School attestation mechanism | Reuses the existing corporations registration (schools are a specially-regulated corporation category) — no new trust-anchor mechanism. |
| 2 | Granularity | Separate contract per faculty/degree; graduation year recoverable from mint timestamp, no separate contract needed. |
| 3 | Lifecycle | Mint-once, no updates/renewal; burn only for rare degree revocation, authority-only, no reason code on-chain. |
| 4 | `ResidentLink` dependency | Required as a one-time, on-chain, applicant-declared cross-contract check at mint time — not an ongoing requirement. No special-casing for foreign residents (treated identically to Japanese national residents, since `ResidentLink` is nationality-neutral). Graduates who were never Japan residents are out of scope. |

Next: write the formal design spec (replacing this directory's `README.md` stub) and an ADR capturing the conceptual/architecture decisions above.

---

# 議論ログ: 卒業証明(日本語)

形式は [`docs/state-design/citizenship/discussion-log.md`](../../citizenship/discussion-log.md) に準じます。これは [`docs/state-design/credentials/discussion-log.md`](../discussion-log.md) のサブ議論です。

---

## Round 1 — 2026-10-06(Claude)

### 実装前に提起する論点

**1. 学校の証明は、既存の法人登録をそのまま流用できそうで、新しい信頼の仕組みは不要かもしれません。**

学校には複数の制度的な形態があります: 国立大学法人(2004年以降の特殊な独立行政法人的地位)、公立学校(地方の教育委員会が運営)、私立学校(学校法人、私学法に基づく特殊な法人格で、設立には文部科学省または都道府県の認可が必要)です。この3つはいずれも、構造的には[法人設計](../../corporations/)で既にカバーしている「特殊な規制対象の法人」の一種にすぎません(文部科学省および/または都道府県の教育委員会の監督下にあり、金融機関が金融庁の監督下にあるのと同じです)。提案: **`.ac.jp`/`.ed.jp`に基づく新しい証明の仕組みを導入せず**、学校は既存の法人設計のパターン(文部科学省/都道府県の教育委員会の監督下にある特殊な規制対象法人として)で登録し、同じ登録済みアドレスから卒業証明NFTを発行する、という形にします。公的証明の横断的な議論で既に触れた「社員証は既存の法人登録にそのまま乗っかれる」のと全く同じ考え方です。この方向でよいか、それとも`.ac.jp`/`.ed.jp`を起点にした仕組みを別途用意したいか確認させてください(こちらも、学術・教育機関向けの実在の審査制限ドメインなので、選択肢として使えます)。

**2. 粒度: 学部・学位ごとのコントラクトはおそらく必要ですが、卒業年度ごとのコントラクトは不要かもしれません。**

ユーザーは既に(公的証明の横断的な議論で)卒業証明は学部・学位という自然で静的な区別ごとに別コントラクトが望ましいと述べています。1点、精緻化を提案したいのですが: **卒業年度は別コントラクトにする必要がないかもしれません**。国民・住民設計のIssue 5と同じ理由(イベントのブロック情報から復元できるものをあえてオンチェーンに持たない)により、年度はmintトランザクションのタイムスタンプから復元できるためです。この精緻化でよいか、それとも実務上の分かりやすさのために年度ごとに別コントラクトを持ちたいか確認させてください。

**3. ライフサイクルは、これまで設計した中で最もシンプルになりそうです: ほぼ永続的、mintは基本的に一度きり、burnは稀。**

パスポート(更新される)や法人(フィールドが日常的に変化する)とは異なり、卒業証明は期限切れも更新もありません。提案:

- **mint**: 発行主体(学校)のみ。既存の現実の卒業プロセスを経て学位を授与した後に行う。
- **burn**: 発行主体のみ。実際の学位取消(稀 — 例えば学術不正が認定された場合)のためだけに取っておく — 自主バーンなし、日常的な用途なし。
- **更新もフィールドの変更もなし** — 授与された学位について正当に変化するものがないため、これまで設計した中で最もシンプルです。

これでよいか、それとも学位取消について何か追加の配慮が必要か(例えば、国民・住民や法人と同様、取消理由をオフチェーンにでも記録すべきか)確認させてください。

**4. `ResidentLink`への依存はなし。**

パスポートの独立性と同様: 卒業証明は卒業生が提供する任意のアドレスにmintし、`ResidentLink`NFTの保有を要件としません(卒業生は、日本の住民になったことがない留学生かもしれませんし、卒業後に転居しているかもしれません)。この理解でよいか確認させてください。

### ステータス

Issue 1〜4についてユーザーの回答待ち。設計書の作成はその後。

---

## Round 2 — 2026-10-06(ユーザー + Claude)— Issue 4修正・解決

### ユーザー

Claudeの当初のIssue 4提案に異論: `ResidentLink`を保有しないアドレスへの卒業証明の発行は認められない。そうしないと日本国民でない人間が日本の学校を卒業できてしまう、という理由。`ResidentLink`をmintの前提条件とする。他人への譲渡が認められないのは当然(譲渡不可、既に確立済み)。外国人の場合の扱いについてアドバイスを求める。

### Claude

解消すべき混同を指摘: `ResidentLink`は(ADR 0003により)意図的に国籍を問わない設計であり、日本国民も外国人住民も同一のクレデンシャルを保有する。したがって`ResidentLink`を要件にしても「国民のみ」にはならず、「国籍を問わず住民のみ」になる。これをむしろ有用なゲートとして採用することを提案: `ResidentLink`をmintの前提条件とし、外国人学生について特別扱いは一切行わない — 住民登録されている外国人学生は、日本人学生と全く同じ扱いになる。これは外国人に関する質問への直接の答えにもなる: 特別な対応は一切不要で、`ResidentLink`が国籍を問わない設計であることの自然な帰結である。スコープの限界も明示: 一度も日本の住民だったことがない卒業生(完全遠隔の海外留学生等)はこのオンチエーンの仕組みの対象外となり、従来の紙の卒業証明に頼ることになる — これは欠陥ではなく意図的なスコープの線引きとする。

2点、追加で確認: (a) mint時点の一度きりのチェックか(既に発行された卒業証明は、後に`ResidentLink`が失効しても影響を受けない、という理解でよいか)、(b) オンチェーンで強制するか(申請者がどの市区町村の`ResidentLink`コントラクトを確認するか申告し、クロスコントラクトで確認する、国民・住民設計のIssue 6の重複防止チェックと同じパターン)、それとも学校がオフチェーンで確認するだけでよいか。

### ユーザー

確認: mint時点の一度きりのチェックでよい。申請者が自分の情報(アドレスと、確認すべき`ResidentLink`コントラクト)を申告する方式 — すなわちオンチェーンのクロスコントラクトチェックを選択。

### 解決(Issue 4、修正版)

**解決。** `Diploma`NFTのmintには、受領者が有効な`ResidentLink`NFTを保有していることを、mint時点でのみオンチェーンで確認することを要件とする(継続的な要件ではない — 既に発行された卒業証明は、保有者の`ResidentLink`が後に(例えば海外転居により)失効しても有効なまま)。申請者は自分のアドレスと、確認すべき具体的な`ResidentLink`コントラクト(＝どの市区町村か)を申告し、学校の`Diploma`コントラクトがmint時にその申告先に対してクロスコントラクトの`balanceOf`チェックを行う — 国民・住民設計のIssue 6のパターンを踏襲する。外国人に対する特別な扱いは一切ない — 住民登録されている外国人は、`ResidentLink`自体が国籍を区別しないため、日本人の住民と全く同じ扱いになる。一度も日本の住民だったことがない卒業生は、このオンチェーンクレデンシャルの対象外。

### ステータス

Issue 4解決(Round 1から修正)。Issue 1〜3への回答待ち。

---

## Round 3 — 2026-10-06(ユーザー)— Issue 1〜3解決、全論点終了

### ユーザー

3点とも確認。

### 解決

- **Issue 1: 解決。** 学校(国立大学法人、公立学校、私立学校(学校法人))は既存の[法人設計](../../corporations/)のパターン(特殊な規制対象法人、文部科学省/都道府県教育委員会の監督下)で登録し、同じ登録済みアドレスから`Diploma`NFTを発行する。新しい`.ac.jp`/`.ed.jp`に基づく信頼の仕組みは不要。
- **Issue 2: 解決。** 学部・学位レベルごとに別コントラクト(自然で静的な区別)。卒業年度は別コントラクトにしない — mintイベントのブロックタイムスタンプから復元可能、国民・住民設計のIssue 5と同じ理由。
- **Issue 3: 解決。** これまで設計した中で最もシンプルなライフサイクル: mintは一度きり(発行主体のみ、学位授与後)、更新なし、更新(renewal)なし。burnは稀な学位取消のためだけに取っておく(発行主体のみ、自主バーンなし、オンチェーンの理由コードなし — 国民・住民・法人設計と同じ最小化の原則)。

## まとめ: 全論点解決(2026-10-06)

上記の英語版の表を参照してください(内容は同一です)。

次のステップ: このディレクトリの`README.md`のスタブを正式な設計書に置き換え、上記の概念・アーキテクチャ決定を記録したADRを作成する。
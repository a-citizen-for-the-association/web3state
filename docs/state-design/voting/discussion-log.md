# Discussion Log: Voting

Records the back-and-forth on this feature's design, in order. See [`docs/state-design/citizenship/discussion-log.md`](../citizenship/discussion-log.md) for the format this follows.

---

## Round 1 — 2026-10-10 (Claude)

### Issues raised before implementation

**1. (Foundational — shapes everything else) Which privacy/anonymity approach?**

Every feature designed so far followed the same shape: an authority mints a soulbound NFT, and that's enough. Voting is different — the core requirement is that anyone can verify an election was run correctly (eligible voters only, one vote each, correct tally) **without** anyone being able to link a specific voter to their specific choice. Real approaches, roughly in increasing order of cryptographic complexity:

- **(a) Practical pseudonymity.** A voter casts their vote from a one-time address with no on-chain link back to their `ResidentLink` address (the link exists only in the election board's private records, or nowhere at all after a one-time credential is issued). Simple to build with plain Solidity, consistent with how this project has used pseudonymity elsewhere (taxation, etc.) — but the anonymity guarantee is only as strong as that link never leaking, not cryptographically enforced.
- **(b) Commit-reveal.** Voters submit a hashed/encrypted vote during the voting period, then reveal it after voting closes. Well-established blockchain pattern, straightforward to implement — but doesn't by itself achieve anonymity (the reveal still shows who revealed what); needs pairing with (a) or a mixing step to hide the voter-choice link.
- **(c) Homomorphic tallying (Helios-style).** Votes are encrypted to a public key; the tally is computed on the encrypted votes directly (addition without decryption) and only the final result is decrypted, with a zero-knowledge proof that the tally was computed correctly. No single party ever sees an individual vote. Moderate cryptographic complexity; [Helios Voting](https://heliosvoting.org/) is a real, published academic/open-source system to reference.
- **(d) Full zero-knowledge voter anonymity (MACI/Semaphore-style).** Voters prove group membership (eligible to vote) via a zero-knowledge proof without revealing *which* eligible voter they are; a "nullifier" prevents double-voting without revealing identity. [MACI](https://maci.pse.dev/) (Minimal Anti-Collusion Infrastructure, from the Ethereum Foundation's Privacy & Scaling Explorations group) additionally supports coercion-resistance (a coerced voter can secretly recast their real vote later, invalidating the coerced one). Strongest guarantees, but real cryptographic engineering — this project would adopt an existing audited implementation rather than build one from scratch, per this project's general preference for proven, widely-used libraries over novel code.

Proposal: given this project's general bias toward starting simple and deferring complexity (seen throughout citizenship/taxation/credentials), **start with (a) or (b) for a first concrete design**, and treat upgrading to (c) or (d) as a tracked future refinement (`docs/BACKLOG.md`) rather than attempting full ZK-based anonymity now. Confirm this direction, or state a preference for starting more ambitiously.

**2. Scope: which concrete election type to design first?**

Japan's actual electoral system includes significant complexity (比例代表 proportional-representation seat allocation, overlapping national/local elections, multi-seat districts). Proposal: design the simplest possible case first — a **single-question referendum (賛成/反対)** — to validate the chosen privacy/anonymity approach, the same way passport validated the general credentials pattern before diploma/license/etc. followed. Confirm, or state a preference for starting with an actual election (e.g. a single-seat local election) instead.

**3. Eligibility verification: resolve the deferred nationality question, scoped to voting only.**

National (and, under current Japanese practice, local) elections require Japanese nationality and a minimum age — neither of which this project tracks on-chain (ADR 0006 deliberately left nationality off-chain; age/birthdate has never been stored anywhere). Proposal: the election board (選挙管理委員会, administered at the municipal level even for national elections) verifies nationality, age, and any other eligibility conditions (e.g. no legal disqualification) **entirely off-chain**, the same way 外務省 verifies nationality off-chain before minting a passport — then issues a voting-right credential to an address that also holds a valid `ResidentLink` NFT (checked on-chain, same cross-contract pattern as diploma/license/health-insurance/vaccination). This resolves eligibility for voting specifically, **without** requiring the general-purpose on-chain Nationality credential that remains deferred in `docs/BACKLOG.md`. Confirm this is sufficient, or state if this is the moment to finally build that deferred credential instead.

**4. Double-voting prevention.**

Mechanism depends on Issue 1's answer: approach (a)/(b) can reuse the `everIssued`/`balanceOf`-style check already established (e.g., a soulbound "voted" marker prevents casting twice); approach (c)/(d) uses dedicated cryptographic constructions (nullifiers). Will finalize once Issue 1 is resolved.

**5. Voting period as a justified on-chain exception to avoiding dates.**

Every other credential avoided storing on-chain timestamps (recoverable from event data, or simply not needed). An election fundamentally has a bounded voting period that must be *actively enforced* (votes outside the window must be rejected), not just passively recorded — proposal: store start/end times as contract-level state (not per-ballot), checked against `block.timestamp` at vote-casting time. Confirm this justified exception.

**6. Tallying and public verifiability.**

How does anyone (not just the election board) verify the published result matches the votes actually cast? Depends on Issue 1: (a)/(b) approaches would rely on the vote-casting events themselves being public and independently countable (straightforward, but doesn't hide individual choices at all under (a) if the casting address is ever linked to a person); (c)/(d) approaches provide cryptographic proof of correct tallying without exposing individual votes. Will finalize once Issue 1 is resolved.

### Status

Awaiting the user's response to Issue 1 especially (it shapes 4 and 6), plus Issues 2, 3, and 5, before writing the spec.

---

## Round 2 — 2026-10-10 (Claude + user)

### Resolving Issue 1

The user asked for background before deciding: why does the law hide *who voted for whom* in the first place? Explanation given: Japanese Constitution Article 15(4) (秘密投票 — ballot secrecy, plus freedom from being held publicly or privately accountable for one's vote) and the academic "二元説" (dual-nature theory of suffrage: voting is both an individual right and a kind of public duty/function). Ballot secrecy exists specifically so that the *duty* side of voting can't be weaponized into pressure or retaliation over how someone exercised the *right* side.

The user then proposed a concrete scheme: the election board publishes a public key; each voter encrypts their own vote off-chain with it and submits the encrypted vote on-chain; the board decrypts with the matching private key and publishes only the result. This was refined into the **Helios Voting** pattern (homomorphic encryption + a zero-knowledge proof that the published tally matches the encrypted ballots + **threshold decryption** split across multiple trustees, so no single party — including the election board itself — ever holds a decryption key alone or can decrypt an individual ballot). Two weaknesses in the user's original version were identified and fixed this way: (1) a single key-holder being bribed or compelled to decrypt individual ballots → solved by threshold decryption (no single point of compromise); (2) no way to verify the board didn't alter the tally during decryption → solved by the zero-knowledge proof of correct tally.

The user accepted this refinement but raised two further questions: (a) they have no cryptography background and worry about making a wrong call here; (b) given voting is arguably a constitutionally-encouraged civic duty (per 二元説) and abstaining feels like it cuts against that spirit, why does *participation* (not just content) need hiding at all?

Response given: (a) recommended using existing, independently audited implementations/libraries (Helios-style or MACI-derived threshold-decryption tooling) rather than any custom cryptography, plus a dedicated external cryptography/security audit at implementation time — consistent with this project's general preference for proven tools over novel code. (b) Reasons participation-hiding is sometimes valued: turnout-based coercion/pressure campaigns, personal privacy, and blockchain's specific risk of a *permanent, cross-election* participation record (unlike a one-off observation of someone entering a polling place today). But noted the real-world counterpoint: even Japan's current paper-ballot system does not strongly protect participation itself (anyone can observe who enters a polling place) — only *content* is rigorously protected by law. On the constitutional question: 二元説 supports voting having a public/duty-like character, but Japan has no compulsory voting, and abstention remains a fully protected legal choice; the duty framing doesn't make non-participation improper. Synthesis offered at this point: keep full cryptographic protection for vote *content* (Helios-style, as above), but treat participation as only pseudonymous rather than fully hidden — and, to limit blockchain's unique permanent-profile risk, proposed having each voter use a **fresh, one-time address per election** rather than their everyday `ResidentLink` address.

The user rejected the fresh-address part of that proposal, reasoning: issuing a fresh per-election address in a way that still prevents double-registration requires the election board/municipality to privately record, off-chain, which disposable address belongs to which resident — and that record would be a **new**, narrowly-purposed, highly attractive target (anyone who bribes or compels a single official for it gets a direct map from "resident" to "their ballot(s)"), worse than reusing data the municipality already has to hold anyway. The user proposed instead voting directly from the resident's existing `ResidentLink` address, explicitly accepting the resulting risk (a lifetime, potentially-correlatable voting-participation history on that one address, if its link to the resident is ever exposed by any means) in exchange for not creating this new concentrated off-chain honeypot.

Agreement reached on this basis, with one clarifying addition: because vote *content* stays protected by the threshold-decryption scheme independently of whether the casting address is known (no one — not the board, not a briber who learns "this `ResidentLink` address belongs to this resident" — can ever decrypt an individual ballot; only the aggregate tally is ever decrypted), reusing `ResidentLink` only exposes the lower-sensitivity fact of *participation*, never *how* someone voted. This mirrors the reuse-rather-than-invent pattern already used in taxation ([ADR 0004](../../decisions/0004-taxation-payment-rail.md)) and in corporations (officers signing with their own personal keys rather than a dedicated signing key, [ADR 0005](../../decisions/0005-corporate-registration-model.md)) — in both cases, avoiding a new off-chain identity-linkage record was preferred over adding one for marginal anonymity gains. The fresh-per-election-address mitigation is dropped.

### Issue 1 — Resolved

- **Vote content:** Helios-style homomorphic encryption + zero-knowledge proof of correct tally + threshold decryption split across multiple trustees (e.g. multiple election-board members); no individual ballot is ever decrypted by anyone, only the aggregate result.
- **Voting address:** the resident's own existing `ResidentLink` address, not a fresh per-election address. Accepted trade-off: that address's participation history (which elections it voted in) could in principle become a permanent, correlatable record if the address-to-resident link is ever exposed — but vote *content* remains protected regardless, and no new off-chain identity↔address mapping is created solely for voting.
- **Implementation stance:** adopt an existing, independently audited implementation (Helios-derived or MACI-derived threshold-decryption tooling) rather than custom cryptography, plus a dedicated external cryptography/security audit before launch.

### Status

Issue 1 resolved. Issues 2 (scope), 3 (eligibility), and 5 (voting period) from Round 1 remain to be explicitly confirmed; Issues 4 (double-voting prevention) and 6 (tallying/verifiability) are now largely determined by the Issue 1 resolution above and will be written up in the spec accordingly.

---

## Round 3 — 2026-10-10 (Claude + user)

### Resolving Issues 2, 3, and 5

The user confirmed Issue 3 (off-chain election-board eligibility check for nationality/age, combined with an on-chain `ResidentLink` check) as originally proposed in Round 1.

For Issue 2, the user rejected the "start with a simple referendum, defer complexity" framing from Round 1 and instead asked for a design that handles **all** election types from the start — not just a simple yes/no referendum, but also candidate elections (single-choice/plurality, proportional representation, multi-seat districts).

This was checked against the Issue 1 cryptography before accepting: a single shared primitive — each ballot is a **one-hot encrypted vector** over a fixed, closed set of options (candidates, parties, or referendum choices), with a zero-knowledge proof that the vector is well-formed (each entry 0 or 1, summing to exactly 1); the contract homomorphically sums each option's column across all ballots; trustees threshold-decrypt only the final per-option totals. This single primitive, with the option set, seat count, and seat-allocation rule as per-election parameters, covers:

- **Referendum**: 2 options (賛成/反対).
- **Single-seat plurality** (e.g. 小選挙区-style): one option per candidate, highest total wins.
- **Multi-seat, single non-transferable vote** (e.g. historical 中選挙区-style): one option per candidate, top-K totals win K seats.
- **Party-list proportional representation**: one option per party (or per candidate, for a non-binding/非拘束名簿式 list), with a seat-allocation method (e.g. ドント式/D'Hondt) applied publicly to the already-decrypted plaintext per-option totals — no additional cryptography needed, since seat allocation is a deterministic calculation over public numbers once the tally is published.

Two election mechanisms were identified as **not** fitting this shared primitive, since they both require examining individual ballots (not just their homomorphic sum) to compute a result, which conflicts with the "no individual ballot is ever decrypted" guarantee from Issue 1:

- **Ranked-choice / single transferable vote (STV)**: counting requires iterative elimination rounds over individual ballots' preference orderings.
- **Write-in candidates**: conflicts with the premise of a fixed, closed option set declared before voting opens.

The user confirmed both are out of scope — consistent with the fact that neither is used in Japan's actual electoral system.

Issue 5 (voting period as a justified on-chain exception to this project's general avoidance of on-chain dates — start/end stored as contract state, checked against `block.timestamp`) was confirmed as originally proposed in Round 1.

### Issues 2, 3, 5 — Resolved

- **Issue 2 (scope):** one generic election primitive — closed option set + one-hot encrypted ballots + homomorphic per-option summation + threshold decryption of only the final totals + a pluggable, publicly-known seat-allocation rule applied to the decrypted totals — covers referendums, single-seat plurality, multi-seat SNTV-style elections, and party-list proportional representation. Ranked-choice/STV and write-in candidates are explicitly out of scope, since Japan's real system doesn't use either and both are structurally incompatible with never decrypting an individual ballot.
- **Issue 3 (eligibility):** the election board verifies nationality, age, and any other eligibility conditions entirely off-chain (same pattern as 外務省 verifying nationality before a passport, [ADR 0006](../../decisions/0006-passport-credential.md)), then grants a voting right to an address that also holds a valid `ResidentLink` NFT, checked on-chain.
- **Issue 5 (voting period):** each election's start/end timestamps are stored as contract-level state and checked against `block.timestamp` at vote-casting time — a deliberate, justified exception to this project's general avoidance of on-chain dates, since a voting window must be *actively enforced*, not just recorded.

### Status

All six Round 1 issues are now resolved. Proceeding to write the formal spec ([`README.md`](README.md)) and ADR 0013.

---

# 議論ログ: 投票(日本語)

形式は [`docs/state-design/citizenship/discussion-log.md`](../citizenship/discussion-log.md) に準じます。

---

## Round 1 — 2026-10-10(Claude)

### 実装前に提起する論点

**1.(根幹 — 他の全てを決定づける)どの匿名性・プライバシーのアプローチを採用するか?**

これまで設計した全ての機能は同じ形でした: 発行主体が譲渡不可NFTを発行すれば十分、というものです。投票は異なります。核心的な要件は、誰でも選挙が正しく実施されたこと(有権者のみ、一人一票、正しい集計)を検証できる一方で、**誰も**特定の投票者と特定の投票内容を結びつけられないことです。現実のアプローチを、暗号学的な複雑さが低い順に挙げます:

- **(a) 実務上の仮名性。** 投票者は、`ResidentLink`アドレスとオンチェーンで紐づかない使い捨てのアドレスから投票します(紐付け情報は選挙管理委員会の非公開記録にのみ存在するか、一度きりのクレデンシャル発行後はどこにも存在しません)。通常のSolidityで構築しやすく、このプロジェクトが他の場面(納税等)で使ってきた仮名性と同じ考え方です — ただし匿名性の保証は、その紐付けが決して漏れないことに依存するだけで、暗号学的に強制されるものではありません。
- **(b) コミット&リビール。** 投票者は投票期間中にハッシュ化・暗号化した投票を提出し、投票終了後に公開します。十分に確立されたブロックチェーンのパターンで実装は単純ですが、それ単独では匿名性を達成しません(公開時に誰が何を公開したか分かってしまいます)。(a)や、投票者と選択内容の紐付けを隠すミキシングの仕組みと組み合わせる必要があります。
- **(c) 準同型集計(Heliosスタイル)。** 投票は公開鍵に対して暗号化され、集計は暗号化されたまま(復号せずに)加算で計算され、最終結果のみが復号されます。集計が正しく行われたことのゼロ知識証明を伴います。個々の投票を単独で見る者は誰もいません。中程度の暗号学的複雑さです。[Helios Voting](https://heliosvoting.org/)が参照可能な実在の学術・オープンソースシステムです。
- **(d) 本格的なゼロ知識投票者匿名性(MACI/Semaphoreスタイル)。** 投票者は、自分が**どの**有権者であるかを明かさずに、グループメンバーシップ(投票資格があること)をゼロ知識証明で証明します。「ナリファイア」が、身元を明かさずに二重投票を防ぎます。[MACI](https://maci.pse.dev/)(Minimal Anti-Collusion Infrastructure、イーサリアム財団のPrivacy & Scaling Explorationsグループによるもの)は、さらに強制・買収耐性もサポートします(強制された投票者は、後で密かに本当の投票をやり直すことができ、強制された投票を無効化できます)。最も強力な保証ですが、本格的な暗号工学が必要です — このプロジェクトであれば、ゼロから構築するのではなく、既存の監査済み実装を採用することになります。独自のコードより実績ある広く使われたライブラリを好むという、このプロジェクトの一般的な方針に沿っています。

提案: このプロジェクトが一貫して持っているシンプルに始めて複雑さを後回しにするという傾向(国民・住民、納税、公的証明のいずれにも見られます)を踏まえ、**最初の具体的な設計としては(a)または(b)から始め**、(c)や(d)への引き上げは`docs/BACKLOG.md`で追跡する将来の改良課題として扱うことを提案します。本格的なZKベースの匿名性を今すぐ目指すのではなく、という形です。この方向でよいか、それとももっと野心的に始めたいか確認させてください。

**2. スコープ: 最初にどの具体的な選挙類型を設計するか?**

日本の実際の選挙制度には大きな複雑さがあります(比例代表の議席配分、国政・地方選挙の重複、複数議席選挙区等)。提案: 選択したプライバシー・匿名性のアプローチを検証するため、最も単純なケース — **単一の論点に対する住民投票(賛成/反対)** — から設計を始めます。パスポートが、その後の卒業証明・免許証等に続く前に公的証明の一般パターンを検証したのと同じ考え方です。この方針でよいか、それとも実際の選挙(例えば単一議席の地方選挙)から始めたいか確認させてください。

**3. 有権者資格の確認: 先送りしていた国籍の論点を、投票に限定して解決する。**

国政選挙(そして現行の日本の実務上、地方選挙も)は日本国籍と一定の年齢を要件としますが、どちらもこのプロジェクトはオンチェーンで追跡していません(ADR 0006で国籍を意図的にオフチェーンのままにしました。生年月日・年齢はこれまでどこにも保存していません)。提案: 選挙管理委員会(国政選挙であっても市区町村レベルで運営されます)が、国籍・年齢・その他の資格要件(法的な欠格事由がないこと等)を**完全にオフチェーンで**確認します — 外務省がパスポート発行前にオフチェーンで国籍を確認するのと同じ考え方です。その上で、有効な`ResidentLink`NFTも保有しているアドレス(オンチェーンで確認、卒業証明・免許証・健康保険証・接種証明と同じクロスコントラクトのパターン)に対して投票権クレデンシャルを発行します。これにより、`docs/BACKLOG.md`で先送りしたままの汎用的なオンチェーン国籍クレデンシャルを必要とせずに、投票に限って資格の問題を解決します。これで十分か、それとも今こそその先送りしていたクレデンシャルを構築すべきタイミングか確認させてください。

**4. 二重投票の防止。**

仕組みは論点1の結論次第です: (a)/(b)のアプローチなら、既に確立した`everIssued`/`balanceOf`スタイルのチェック(例えば譲渡不可の「投票済み」マーカーで二度目の投票を防ぐ)を流用できます。(c)/(d)のアプローチは専用の暗号学的構成(ナリファイア)を使います。論点1が解決してから確定します。

**5. 投票期間 — オンチェーンの日付を避けるという方針への正当な例外。**

これまでの他の全てのクレデンシャルは、オンチェーンのタイムスタンプを(イベントデータから復元可能、あるいは単に不要という理由で)避けてきました。選挙には、本質的に、単に受動的に記録するだけでなく**能動的に強制する**必要がある、区切られた投票期間があります(期間外の投票は拒否されなければなりません)。提案: 開始・終了時刻をコントラクトレベルの状態として保存し(トークンごとではなく)、投票時に`block.timestamp`と照合します。この正当な例外でよいか確認させてください。

**6. 集計と公的な検証可能性。**

選挙管理委員会だけでなく誰でも、公表された結果が実際に投じられた投票と一致することをどう検証できるか? 論点1次第です: (a)/(b)のアプローチは、投票を投じるイベント自体が公開され独立に数えられることに依存します(単純ですが、(a)の場合、投票に使ったアドレスがいつか本人に紐づけられてしまうと、個々の選択を全く隠せません)。(c)/(d)のアプローチは、個々の投票を明かすことなく正しい集計の暗号学的証明を提供します。論点1が解決してから確定します。

### ステータス

特に論点1(論点4・6を左右します)、加えて論点2・3・5についてユーザーの回答待ち。設計書の作成はその後。

---

## Round 2 — 2026-10-10(Claude + ユーザー)

### 論点1の解決

ユーザーはまず、そもそもなぜ法律は「誰が誰に投票したか」を隠すのかという背景を確認しました。回答: 日本国憲法第15条4項(秘密投票 — 投票の秘密、および自己の投票について公的にも私的にも責任を問われないこと)と、学術上の「二元説」(選挙権は個人の権利であると同時に公務的な性格も持つという説)。投票の秘密は、まさにこの「公務」の側面が、「権利」の行使の仕方をめぐる圧力や報復の道具にされないようにするために存在します。

その上でユーザーは具体的な仕組みを提案しました: 選挙管理委員会が公開鍵を公表し、各投票者は自身の投票をオフチェーンでその鍵を使って暗号化してオンチェーンに提出し、委員会が対応する秘密鍵で復号して結果のみを公表するというものです。これを**Helios Voting**のパターン(準同型暗号+公表された集計結果が暗号化された投票と一致するというゼロ知識証明+**閾値復号**(複数の信頼主体に分散し、選挙管理委員会自身を含め、誰も単独では復号鍵を持たず、個々の投票を単独で復号できない))へと発展させました。ユーザーの当初案にあった2つの弱点をこの形で解消しました: (1)単一の鍵保有者が買収・強要されて個々の投票を復号してしまう危険 → 閾値復号により単一の破綻点をなくすことで解決。(2)委員会が復号時に集計を改ざんしていないことを誰も検証できない → 正しい集計のゼロ知識証明により解決。

ユーザーはこの改良案を受け入れつつ、さらに2つの問いを投げかけました: (a)自身には暗号の知識がなく、誤った判断をしてしまわないか心配である。(b)投票は(二元説に照らせば)憲法が奨励する公務的性格を持つとも言えるのに、棄権はその精神に反するようにも思える中で、なぜ(投票内容だけでなく)「参加したこと」自体も隠す必要があるのか。

回答: (a)独自の暗号を作るのではなく、既存の、独立監査を受けた実装・ライブラリ(Heliosスタイル、あるいはMACI系の閾値復号の仕組み)を採用すること、そして実装時には専用の外部暗号・セキュリティ監査を入れることを推奨しました。これは、独自コードより実績あるツールを好むというこのプロジェクトの一般方針とも一致します。(b)参加自体を隠すことが重視される理由として、投票率に基づく圧力・報復キャンペーン、個人のプライバシー、そしてブロックチェーン特有の「今日、投票所に入るのを一度誰かに見られる」のとは異なる**恒久的かつ複数選挙にまたがる**参加履歴が残ってしまうリスクを挙げました。一方で、現実の反証として、現在の日本の紙の投票制度自体も「参加したこと」自体を強く保護してはいない(誰でも投票所に入る人を見ることができる)ことを指摘し、法律が厳格に保護しているのは「投票内容」であることを明らかにしました。憲法上の論点については、二元説は投票が公務的な性格を持つことを支持しますが、日本には投票義務制度はなく、棄権は完全に保護された法的選択であり続けること、公務という位置づけが不参加を不当なものにするわけではないことを説明しました。ここでの統合案として、投票「内容」については上記の通り完全な暗号学的保護を維持しつつ、「参加」については完全に隠すのではなく仮名性にとどめ、ブロックチェーン特有の恒久的なプロフィール形成リスクを抑えるため、選挙ごとに**使い捨ての新しいアドレス**を使うことを提案しました。

ユーザーはこの使い捨てアドレス案を退けました。理由: 二重登録を防ぎながら選挙ごとの使い捨てアドレスを発行するには、結局、選挙管理委員会・市区町村が「どの使い捨てアドレスがどの住民のものか」をオフチェーンで非公開に記録する必要があり、この記録自体が**新しく、用途が極めて限定された、非常に狙われやすい標的**になってしまう(これを買収・強要で入手されれば、「この住民」から「その投票内容」への直接的な地図が手に入ってしまう)— これは、市区町村が元々保持せざるを得ない情報を使い回す場合より悪い、というものです。ユーザーは代わりに、住民が既に持つ`ResidentLink`アドレスからそのまま投票する案を提案し、その結果生じるリスク(そのアドレスと本人の紐付けが何らかの形で明らかになった場合、そのアドレス1本に紐づく生涯分の、相互に照合可能な投票参加履歴が残ってしまうこと)を承知の上で受け入れるとしました。新しい、集中した形のオフチェーンの弱点を作らないことと引き換えに、です。

この方向で合意しました。1点補足を加えています: 投票「内容」は、投票に使ったアドレスが誰のものか分かるかどうかとは無関係に、閾値復号の仕組みによって保護され続けるため(選挙管理委員会を含め、たとえ「このResidentLinkアドレスはこの住民のものだ」と知った買収者であっても、個々の投票を復号することは誰にもできず、復号されるのは常に集計結果のみです)、`ResidentLink`を使い回すことで明らかになるのは、相対的に機微性の低い「参加した」という事実のみであり、「何に投票したか」が明らかになることはありません。これは、納税([ADR 0004](../../decisions/0004-taxation-payment-rail.md))や法人([ADR 0005](../../decisions/0005-corporate-registration-model.md)、役員は専用の署名鍵ではなく自身の個人鍵で署名する)で既に採用してきた「新しく作るより使い回す」というパターンと同じです。いずれも、わずかな匿名性向上のために新しいオフチェーンの身元紐付け記録を作るより、それを作らないことを優先しました。選挙ごとの使い捨てアドレスという緩和策は撤回します。

### 論点1 — 解決

- **投票内容:** 準同型暗号+正しい集計のゼロ知識証明+複数の信頼主体(例: 複数の選挙管理委員)に分散した閾値復号。個々の投票は誰によっても復号されず、復号されるのは常に集計結果のみ。
- **投票に使うアドレス:** 選挙ごとの使い捨てアドレスではなく、住民が既に持つ`ResidentLink`アドレスをそのまま使用。受け入れるトレードオフ: そのアドレスと住民本人の紐付けが何らかの形で明らかになった場合、どの選挙に投票したかという恒久的で相互に照合可能な記録になり得ること。ただし投票「内容」はそれとは無関係に保護され続け、投票のためだけに新しいオフチェーンの身元↔アドレスの紐付けが作られることもない。
- **実装方針:** 独自の暗号は作らず、既存の独立監査済み実装(Helios系またはMACI系の閾値復号ツール)を採用し、リリース前に専用の外部暗号・セキュリティ監査を行う。

### ステータス

論点1は解決。Round 1の論点2(スコープ)・論点3(有権者資格)・論点5(投票期間)はまだ明示的な確認が必要。論点4(二重投票の防止)・論点6(集計と検証可能性)は、論点1の解決内容によっておおむね決まったため、設計書に反映します。

---

## Round 3 — 2026-10-10(Claude + ユーザー)

### 論点2・3・5の解決

ユーザーは論点3(国籍・年齢は選挙管理委員会がオフチェーンで確認し、オンチェーンでは`ResidentLink`保有をチェックする)をRound 1の提案通り確認しました。

論点2については、ユーザーはRound 1の「単純な住民投票から始め、複雑さは後回しにする」という方針を退け、最初から**全ての選挙類型**(単純な賛否だけでなく、単記投票、比例代表、複数議席選挙区を含む候補者選挙)に汎用的に対応する設計を求めました。

これを採用する前に、論点1の暗号方式と整合するか確認しました: 固定・公開された選択肢の集合(候補者、政党、または住民投票の選択肢)に対する**ワンホット暗号化された投票**(各要素が0か1で、合計がちょうど1になることのゼロ知識証明付き)を1つの共通の仕組みとし、コントラクトは各選択肢の列を全投票にわたって準同型で合計、信頼主体が最終的な各選択肢の合計のみを閾値復号する、という単一の原理を使います。選択肢の集合、当選者数、議席配分のルールを選挙ごとのパラメータとすれば、これで以下をカバーできます。

- **住民投票**: 2つの選択肢(賛成/反対)
- **単記投票による単一議席選挙**(小選挙区のようなもの): 候補者ごとに1つの選択肢、最多得票が当選
- **単記非移譲式による複数議席選挙**(かつての中選挙区のようなもの): 候補者ごとに1つの選択肢、得票上位K名が当選
- **比例代表**: 政党ごと(非拘束名簿式なら候補者ごと)に1つの選択肢とし、集計が公表された後、復号済みの平文の得票数に対して議席配分の方法(ドント式等)を公開の場で適用する — 集計公表後は公開の数値に対する決定論的な計算になるため、追加の暗号は不要

この共通の原理に**乗らない**選挙方式として、以下の2つが特定されました。いずれも、結果の計算に(ワンホットの合計だけでなく)個々の投票用紙の内容を参照する必要があり、論点1の「個々の投票は誰も復号しない」という保証と原理的に両立しません。

- **移譲式投票(優先順位投票・STV)**: 個々の投票用紙の優先順位に基づく反復的な票の移譲計算が必要。
- **自書式(書き込み)候補者**: 投票開始前に確定した固定の選択肢集合という前提と矛盾する。

ユーザーはいずれも対象外とすることを確認しました。これは、日本の現実の選挙制度がどちらも採用していないことと整合します。

論点5(オンチェーンの日付を避けるという方針への正当な例外としての投票期間 — 開始・終了時刻をコントラクトの状態として保存し`block.timestamp`と照合する)は、Round 1の提案通り確認されました。

### 論点2・3・5 — 解決

- **論点2(スコープ):** 固定の選択肢集合+ワンホット暗号化された投票+各選択肢の準同型合計+最終的な合計のみの閾値復号+復号済みの合計に適用する、差し替え可能で公開された議席配分ルール、という1つの汎用的な選挙の原理で、住民投票、単記投票による単一議席選挙、単記非移譲式の複数議席選挙、比例代表をカバーします。移譲式投票(STV)と自書式候補者は明示的に対象外とします。日本の実際の制度がどちらも採用しておらず、かつ個々の投票を決して復号しないという前提と構造的に両立しないためです。
- **論点3(有権者資格):** 選挙管理委員会が国籍・年齢・その他の資格要件を完全にオフチェーンで確認し(外務省がパスポート発行前に国籍をオフチェーンで確認するのと同じパターン、[ADR 0006](../../decisions/0006-passport-credential.md))、その上で、有効な`ResidentLink`NFTも保有している(オンチェーンで確認)アドレスに投票権を付与します。
- **論点5(投票期間):** 各選挙の開始・終了時刻をコントラクトレベルの状態として保存し、投票時に`block.timestamp`と照合します。オンチェーンの日付をできるだけ避けるというこのプロジェクトの一般方針への、意図的で正当な例外です。投票期間は単に記録するだけでなく、**能動的に強制する**必要があるためです。

### ステータス

Round 1の6つの論点が全て解決しました。正式な設計書([`README.md`](README.md))とADR 0013の作成に進みます。
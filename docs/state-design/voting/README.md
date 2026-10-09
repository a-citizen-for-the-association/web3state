# Voting (投票)

**Status: 🟢 Spec drafted.** The first state function requiring genuinely new cryptographic machinery, not an extension of the credentials/registration patterns used so far. Conceptual and architecture questions resolved through discussion with the user; see [`discussion-log.md`](discussion-log.md) for the full reasoning and [`docs/decisions/0013-voting-model.md`](../../decisions/0013-voting-model.md) for the formal ADR. No contract code written yet.

## Summary

A single generic election mechanism — covering referendums, single-seat plurality elections, multi-seat single-non-transferable-vote (SNTV) elections, and party-list proportional representation — built on one cryptographic primitive: each ballot is a **one-hot encrypted vote** over a fixed, closed set of options, homomorphically summed per option across all ballots, with the final per-option totals revealed only via **threshold decryption** split across multiple trustees (never any individual ballot) and a zero-knowledge proof that the published totals match the ballots actually cast. Voters cast ballots from their own existing `ResidentLink` address rather than a fresh one-time address.

## Scope

**In scope:**
- Referendums (single-question 賛成/反対).
- Single-seat plurality elections (one winner, most votes).
- Multi-seat, single-non-transferable-vote elections (top-K candidates by vote count win K seats).
- Party-list proportional representation, including both binding (拘束名簿式 — party pre-submits a ranked candidate list) and non-binding (非拘束名簿式 — individual candidate vote totals determine within-party ranking) variants, with a configurable public seat-allocation method (e.g. ドント式/D'Hondt).

**Out of scope (deliberately excluded, see [discussion log](discussion-log.md) Round 3):**
- Ranked-choice / single transferable vote (STV) — counting requires examining individual ballots' preference orderings across elimination rounds, which is structurally incompatible with never decrypting an individual ballot. Not used in Japan's actual system.
- Write-in candidates — conflicts with the premise of a fixed, closed option set declared before voting opens. Not used in Japan's actual system.
- The general-purpose on-chain nationality credential (remains deferred in [`docs/BACKLOG.md`](../../BACKLOG.md)) — eligibility is resolved for voting specifically via off-chain election-board verification instead.
- Selecting the concrete audited cryptographic library/implementation (Helios-derived or MACI-derived threshold-decryption tooling) — a backlog item for the implementation phase, not a design-phase decision.

## On-chain / Online / Offline breakdown

(See [`docs/operations/README.md`](../../operations/README.md) for the convention.)

**On-chain:**
- Deployment of a new `Election` contract instance per election, parameterized with: the closed option list (candidates/parties/referendum choices), seat count `K`, the seat-allocation method, the trustee set's public key material, and `votingStart`/`votingEnd` timestamps.
- Granting a voting right to an address (election-board role only), requiring that address to hold a valid `ResidentLink` NFT (cross-contract check, same pattern as diploma/license/health-insurance/vaccination).
- Casting a ballot: submitting a one-hot encrypted vote vector plus a zero-knowledge proof that it's well-formed, from an address holding a granted, unused voting right, within the voting window.
- Publishing the tally: trustees jointly submit the threshold-decrypted per-option totals plus a zero-knowledge proof that the totals match the homomorphic sum of all cast ballots, after `votingEnd`.
- Computing the result: a public, deterministic function over the published plaintext totals and the election's configured seat-allocation method.

**Online:**
- The election board's officially-attested `Election` contract address for a given election, published the same way other authority-issued contract addresses are (`.lg.jp`/`.go.jp` depending on the election's level).
- Publication of the trustee set and their public key material ahead of the election.

**Offline:**
- Verifying voter eligibility (nationality, age, any legal disqualification) before granting a voting right — the election board's responsibility, entirely off-chain, same pattern as 外務省 verifying nationality before a passport ([ADR 0006](../../decisions/0006-passport-credential.md)).
- Determining and publishing the closed list of candidates/parties before voting opens (candidate registration/nomination process).
- The trustees' individual key-share custody and the threshold-decryption ceremony's operational security.
- Selecting which cryptographic library/implementation to use, and its independent security audit.

## Architecture

### Cryptographic primitive: one-hot encrypted ballots, homomorphic summation, threshold decryption

Every election, regardless of type, uses the same primitive (Helios-style):

1. The election defines a fixed, ordered list of `N` options (candidates, parties, or referendum choices) at creation time. No option can be added after voting opens (rules out write-ins).
2. A voter casts a ballot as a vector of `N` homomorphically-encrypted values, encrypted to the trustees' shared public key, where exactly one entry is `1` and the rest are `0` (the chosen option) — accompanied by a zero-knowledge proof that the ciphertext vector is well-formed (each entry decrypts to 0 or 1, and the entries sum to exactly 1) **without revealing which entry is which**.
3. The contract homomorphically adds each newly-cast ballot's vector into a running per-option encrypted sum. No decryption happens at this stage.
4. After `votingEnd`, the trustees jointly perform **threshold decryption** of the final per-option encrypted sums only (never of any individual ballot) — no single trustee (including the election board) can decrypt alone — and publish the resulting plaintext per-option totals along with a zero-knowledge proof that these totals are the correct decryption of the on-chain encrypted sums.
5. Anyone can verify this proof without trusting the election board or any individual trustee.

This single mechanism, parameterized only by the option list, seat count `K`, and seat-allocation method, covers every in-scope election type (see [Scope](#scope)):

| Election type | Options | Seat-allocation method |
|---|---|---|
| Referendum | 2 (賛成/反対) | Simple majority of the two totals |
| Single-seat plurality | 1 per candidate | Highest total wins the 1 seat |
| Multi-seat SNTV | 1 per candidate | Top-`K` totals win `K` seats |
| Party-list PR (拘束名簿式) | 1 per party | Divisor method (e.g. D'Hondt) on party totals; seats filled from each party's pre-submitted ranked list |
| Party-list PR (非拘束名簿式) | 1 per candidate | Divisor method on summed-per-party totals for seat *counts*; individual candidate totals rank candidates *within* each party's allocated seats |

Seat allocation itself is a deterministic, publicly computable function over the already-decrypted plaintext totals — it requires no additional cryptography, since the privacy-sensitive part (what each ballot contained) is already resolved by the time seat allocation runs.

### Contract: `Election` (one instance per election)

- Deployed fresh per election (factory pattern), not a single long-lived contract — each election has its own option list, timing, and trustee set.
- Constructor parameters: option list, seat count `K`, seat-allocation method identifier, trustee public key material, `votingStart`, `votingEnd`.
- `grantVotingRight(address voter)` — election-board role only; requires `voter` to hold a valid `ResidentLink` NFT (declared contract, same cross-contract pattern as diploma/license/health-insurance/vaccination); may be called any time before `votingEnd` (typically during a pre-election registration window); marks the address as eligible to cast exactly one ballot.
- `castBallot(encryptedVector, zkProof)` — callable only by an address with a granted, not-yet-used voting right, only while `votingStart <= block.timestamp < votingEnd`; verifies the well-formedness proof, adds the vector into the running per-option encrypted sum, and marks that address's voting right as used (**Issue 4: double-voting prevention** — a simple per-address, per-election "has voted" marker, since each voter always votes from the same `ResidentLink` address rather than a fresh one).
- `publishTally(totals[], zkProof)` — callable by the trustee set only, only after `votingEnd`; verifies the proof that `totals` is the correct threshold-decryption of the accumulated encrypted sums; stores the plaintext totals permanently.
- `computeResult()` — a public, pure function over the published `totals` and the configured seat-allocation method; anyone can call it to derive the winner(s)/seat allocation (**Issue 6: tallying and verifiability** — the proof published alongside `totals` lets anyone confirm the totals weren't altered during decryption, independent of trusting the election board).

### Eligibility (Issue 3)

The election board verifies nationality, age, and any other eligibility conditions entirely off-chain — the same pattern 外務省 uses to verify nationality before minting a passport ([ADR 0006](../../decisions/0006-passport-credential.md)) — then calls `grantVotingRight` for each eligible resident, which additionally requires the resident to hold a valid `ResidentLink` NFT, checked on-chain. This resolves voter eligibility for voting specifically without requiring the general-purpose on-chain nationality credential that remains deferred in [`docs/BACKLOG.md`](../../BACKLOG.md).

A national election necessarily involves residents registered across many different municipalities' `ResidentLink` contracts; which specific `ResidentLink` contract to check for a given voter is resolved by the election board during the off-chain verification step, not by the voter declaring it. See [`docs/BACKLOG.md`](../../BACKLOG.md) for the related open item on reducing the operational cost of this at national scale.

### Voting address and participation privacy (Issue 1, restated)

Voters cast ballots from their own existing `ResidentLink` address, not a fresh per-election address — see [discussion log](discussion-log.md) Round 2 for the full reasoning. This means an election's `castBallot` transactions are pseudonymous (address-linked, not identity-linked) rather than fully anonymous: if a `ResidentLink` address is ever publicly linked to a resident, their participation history across elections could in principle be reconstructed. Vote *content* remains protected regardless, since no individual ballot is ever decrypted under the threshold-decryption scheme above — only the aggregate per-option totals are. This was a deliberate trade-off to avoid creating a new, narrowly-purposed off-chain mapping (identity ↔ disposable per-election address) that would otherwise become a concentrated bribery/coercion target.

### Voting period (Issue 5)

`votingStart` and `votingEnd` are stored as contract-level state (set once at construction, not per-ballot) and checked against `block.timestamp` in `castBallot`. This is a deliberate, justified exception to this project's general avoidance of on-chain dates/timestamps: unlike every other credential (where a timestamp would only be passively recorded), a voting window must be *actively enforced* — votes outside it must be rejected by the contract itself.

## Open items for later

- Selecting the concrete audited cryptographic library/implementation (Helios-derived or MACI-derived threshold-decryption tooling) and commissioning an independent cryptography/security audit — deferred to the implementation phase. Tracked in [`docs/BACKLOG.md`](../../BACKLOG.md).
- Reducing the operational cost of per-voter `grantVotingRight` transactions at national-election scale (e.g. a Merkle-root/allow-list-based alternative) — tracked in [`docs/BACKLOG.md`](../../BACKLOG.md) as a future optimization, not a blocker for the design.
- Candidate/party registration (nomination) process itself is assumed to happen entirely off-chain, the same way school/employer/hospital legitimacy is assumed verified off-chain elsewhere in this project — not designed here.

---

# 投票(日本語)

**ステータス: 🟢 設計確定。** これまでの(証明書・登記の)パターンの延長では済まない、本当に新しい暗号学的な仕組みを必要とする初めての国家機能です。ユーザーとの議論を通じて概念・アーキテクチャ上の論点は解決済み。詳細な議論の経緯は [`discussion-log.md`](discussion-log.md)、正式なADRは [`docs/decisions/0013-voting-model.md`](../../decisions/0013-voting-model.md) を参照。コントラクトコードはまだ実装していません。

## 概要

住民投票、単記投票による単一議席選挙、単記非移譲式(SNTV)の複数議席選挙、比例代表をすべてカバーする、単一の汎用的な選挙の仕組みです。核となる暗号の原理は1つ: 各投票は、固定・公開された選択肢の集合に対する**ワンホット暗号化された投票**であり、全投票にわたって選択肢ごとに準同型で合計され、最終的な各選択肢の合計のみが、複数の信頼主体に分散した**閾値復号**によって明らかになります(個々の投票は決して復号されません)。公表された合計が実際に投じられた投票と一致することのゼロ知識証明も伴います。投票者は、選挙ごとの使い捨てアドレスではなく、自身が既に持つ`ResidentLink`アドレスから投票します。

## スコープ

**対象:**
- 住民投票(単一の論点に対する賛成/反対)
- 単記投票による単一議席選挙(最多得票の1名が当選)
- 単記非移譲式の複数議席選挙(得票上位K名がK議席を獲得)
- 比例代表。拘束名簿式(政党が事前に順位付けした候補者名簿を提出)・非拘束名簿式(個々の候補者の得票数が党内の順位を決定)の両方を含み、議席配分の方法(ドント式等)は設定可能とする。

**対象外(意図的に除外 — [議論ログ](discussion-log.md) Round 3参照):**
- 移譲式投票(優先順位投票・STV) — 集計に、反復的な排除ラウンドにわたる個々の投票の優先順位の参照が必要で、「個々の投票を決して復号しない」という前提と構造的に両立しない。日本の実際の制度では採用されていない。
- 自書式(書き込み)候補者 — 投票開始前に確定した固定の選択肢集合という前提と矛盾する。日本の実際の制度では採用されていない。
- 汎用的なオンチェーン国籍クレデンシャル(引き続き[`docs/BACKLOG.md`](../../BACKLOG.md)で先送り) — 投票に限っては、選挙管理委員会によるオフチェーンの確認で資格の問題を解決する。
- 具体的な監査済み暗号ライブラリ・実装(Helios系またはMACI系の閾値復号ツール)の選定 — 実装フェーズのバックログ項目であり、設計フェーズの決定事項ではない。

## オンチェーン/オンライン/オフラインの内訳

(規約は[`docs/operations/README.md`](../../operations/README.md)参照)

**オンチェーン:**
- 選挙ごとに新しい`Election`コントラクトのインスタンスをデプロイ。固定の選択肢リスト(候補者・政党・住民投票の選択肢)、議席数`K`、議席配分の方法、信頼主体集合の公開鍵情報、`votingStart`/`votingEnd`の時刻をパラメータとする。
- アドレスへの投票権の付与(選挙管理委員会のロールに限定)。そのアドレスが有効な`ResidentLink`NFTを保有していることを要件とする(クロスコントラクトでの確認、卒業証明・免許証・健康保険証・接種証明と同じパターン)。
- 投票: ワンホット暗号化された投票ベクトルと、それが正しい形式であることのゼロ知識証明を、付与済みで未使用の投票権を持つアドレスから、投票期間内に提出する。
- 集計の公表: `votingEnd`後、信頼主体が共同で、閾値復号した各選択肢の合計と、その合計が全投票の準同型合計の正しい復号であることのゼロ知識証明を提出する。
- 結果の計算: 公表された平文の合計と、その選挙に設定された議席配分の方法に対する、公開の決定論的な関数。

**オンライン:**
- ある選挙における選挙管理委員会の、公式に証明された`Election`コントラクトアドレス。他の発行主体のコントラクトアドレスと同じ方法(選挙のレベルに応じて`.lg.jp`/`.go.jp`)で公表。
- 信頼主体の集合とその公開鍵情報の、選挙前の公表。

**オフライン:**
- 投票権を付与する前の、有権者資格(国籍・年齢・法的な欠格事由の有無)の確認 — 選挙管理委員会の責任として完全にオフチェーンで行う。外務省がパスポート発行前に国籍をオフチェーンで確認するのと同じパターン([ADR 0006](../../decisions/0006-passport-credential.md))。
- 投票開始前の、候補者・政党の固定リストの確定と公表(立候補・推薦のプロセス)。
- 信頼主体それぞれの鍵シェアの管理と、閾値復号の儀式の運用上のセキュリティ。
- どの暗号ライブラリ・実装を使うかの選定と、その独立したセキュリティ監査。

## アーキテクチャ

### 暗号の原理: ワンホット暗号化された投票、準同型合計、閾値復号

選挙の種類にかかわらず、全ての選挙は同じ原理(Heliosスタイル)を使います。

1. 選挙は作成時に、`N`個の選択肢(候補者、政党、住民投票の選択肢)からなる固定・順序付きのリストを定義します。投票開始後に選択肢を追加することはできません(自書式を排除します)。
2. 投票者は、信頼主体が共有する公開鍵に対して暗号化された`N`個の値からなるベクトルとして投票を投じます。ちょうど1つの要素が`1`(選んだ選択肢)で、残りは`0`です — その暗号文ベクトルが正しい形式であることのゼロ知識証明を伴います(各要素が0か1に復号されること、合計がちょうど1になること)が、**どの要素が選ばれたかは明かしません**。
3. コントラクトは、新たに投じられた各投票のベクトルを、選択肢ごとの暗号化された累計に準同型で加算します。この段階では復号は一切行われません。
4. `votingEnd`後、信頼主体が共同で、最終的な各選択肢の暗号化された合計についてのみ(個々の投票については決して)**閾値復号**を行います — 選挙管理委員会を含め、単一の信頼主体が単独で復号することはできません — その結果の平文の各選択肢の合計を、オンチェーンの暗号化された合計の正しい復号であることのゼロ知識証明とともに公表します。
5. 誰でも、選挙管理委員会や個々の信頼主体を信頼することなく、この証明を検証できます。

この単一の仕組みは、選択肢リスト、議席数`K`、議席配分の方法だけをパラメータとすることで、対象とする全ての選挙類型(「スコープ」参照)をカバーします。

| 選挙類型 | 選択肢 | 議席配分の方法 |
|---|---|---|
| 住民投票 | 2(賛成/反対) | 2つの合計の単純多数決 |
| 単記投票による単一議席選挙 | 候補者ごとに1 | 最多得票が1議席を獲得 |
| 単記非移譲式の複数議席選挙 | 候補者ごとに1 | 得票上位`K`名が`K`議席を獲得 |
| 比例代表(拘束名簿式) | 政党ごとに1 | 政党の合計に除数法(ドント式等)を適用。各政党の事前提出の順位付きリストから議席を充当 |
| 比例代表(非拘束名簿式) | 候補者ごとに1 | 政党ごとに合計した値に除数法を適用して議席*数*を決定。各政党に配分された議席の中での順位は、個々の候補者の得票数で決定 |

議席配分自体は、既に復号済みの平文の合計に対する、決定論的で誰でも計算できる関数です。プライバシーに関わる部分(各投票が何を含んでいたか)は、議席配分の計算が行われる時点で既に解決しているため、追加の暗号は不要です。

### コントラクト: `Election`(選挙ごとに1インスタンス)

- 選挙ごとに新しくデプロイします(ファクトリーパターン)。単一の長期稼働コントラクトではありません — 各選挙は独自の選択肢リスト、タイミング、信頼主体の集合を持ちます。
- コンストラクタのパラメータ: 選択肢リスト、議席数`K`、議席配分方法の識別子、信頼主体の公開鍵情報、`votingStart`、`votingEnd`。
- `grantVotingRight(address voter)` — 選挙管理委員会のロールに限定。`voter`が有効な`ResidentLink`NFTを保有していることを要件とする(申告されたコントラクト、卒業証明・免許証・健康保険証・接種証明と同じクロスコントラクトのパターン)。`votingEnd`より前であればいつでも呼び出せる(通常は選挙前の登録期間中)。そのアドレスに、ちょうど1票を投じる資格があるとマークする。
- `castBallot(encryptedVector, zkProof)` — 付与済みで未使用の投票権を持つアドレスのみが、`votingStart <= block.timestamp < votingEnd`の間のみ呼び出せる。正しい形式であることの証明を検証し、ベクトルを選択肢ごとの暗号化された累計に加算し、そのアドレスの投票権を使用済みとマークする(**論点4: 二重投票の防止** — 各投票者は常に使い捨てではなく同じ`ResidentLink`アドレスから投票するため、アドレスごと・選挙ごとの単純な「投票済み」マーカーで足りる)。
- `publishTally(totals[], zkProof)` — 信頼主体の集合のみが、`votingEnd`後にのみ呼び出せる。`totals`が、累計された暗号化された合計の正しい閾値復号であることの証明を検証し、平文の合計を恒久的に保存する。
- `computeResult()` — 公表された`totals`と設定された議席配分の方法に対する、公開の純粋関数。誰でも呼び出して当選者・議席配分を導出できる(**論点6: 集計と検証可能性** — `totals`とともに公表される証明により、選挙管理委員会を信頼することなく、復号の過程で合計が改ざんされていないことを誰でも確認できる)。

### 有権者資格(論点3)

選挙管理委員会は、国籍・年齢・その他の資格要件を完全にオフチェーンで確認します — 外務省がパスポート発行前に国籍を確認するのと同じパターンです([ADR 0006](../../decisions/0006-passport-credential.md))。その上で、資格のある各住民について`grantVotingRight`を呼び出します。これにはさらに、その住民が有効な`ResidentLink`NFTを保有していることがオンチェーンで要件として確認されます。これにより、`docs/BACKLOG.md`で引き続き先送りされている汎用的なオンチェーン国籍クレデンシャルを必要とせずに、投票に限って有権者資格の問題を解決します。

国政選挙では、必然的に、多くの異なる市区町村の`ResidentLink`コントラクトに登録された住民が関わります。ある投票者についてどの`ResidentLink`コントラクトを確認するかは、投票者自身の申告ではなく、選挙管理委員会がオフチェーンでの確認作業の中で解決します。全国規模でのこの運用コストを下げる関連の未解決項目については[`docs/BACKLOG.md`](../../BACKLOG.md)を参照してください。

### 投票アドレスと参加のプライバシー(論点1、再掲)

投票者は、選挙ごとの使い捨てアドレスではなく、自身が既に持つ`ResidentLink`アドレスから投票します — 詳しい理由は[議論ログ](discussion-log.md)のRound 2を参照してください。これは、選挙の`castBallot`のトランザクションが、完全な匿名ではなく仮名(アイデンティティとは紐づかないが、アドレスとは紐づく)であることを意味します。もし`ResidentLink`アドレスがいつか本人に公に紐づけられれば、複数の選挙にまたがる参加履歴が再構成され得ます。一方で、投票の「内容」は、上記の閾値復号の仕組みの下では個々の投票が決して復号されないため、それとは無関係に保護され続けます。これは、新しく、用途が極めて限定された(身元↔使い捨てアドレスの)オフチェーンの紐付けを作ることで、それが集中した買収・強制の標的になってしまうことを避けるための、意図的なトレードオフです。

### 投票期間(論点5)

`votingStart`と`votingEnd`はコントラクトレベルの状態として保存され(コンストラクタで一度設定、投票ごとではない)、`castBallot`の中で`block.timestamp`と照合されます。これは、オンチェーンの日付・タイムスタンプをできるだけ避けるというこのプロジェクトの一般方針への、意図的で正当な例外です。他の全てのクレデンシャル(タイムスタンプは単に受動的に記録されるだけ)と異なり、投票期間は**能動的に強制**される必要があり、期間外の投票はコントラクト自身によって拒否されなければならないためです。

## 今後の課題

- 具体的な監査済み暗号ライブラリ・実装(Helios系またはMACI系の閾値復号ツール)の選定と、独立した暗号・セキュリティ監査の発注 — 実装フェーズに先送り。[`docs/BACKLOG.md`](../../BACKLOG.md)で追跡。
- 国政選挙規模での、投票者ごとの`grantVotingRight`トランザクションの運用コストを下げる方法(マークルルート・許可リストベースの代替案等) — [`docs/BACKLOG.md`](../../BACKLOG.md)で将来の最適化として追跡。設計のブロッカーではない。
- 候補者・政党の登録(立候補)プロセス自体は、このプロジェクトの他の場所(学校・雇用主・病院の正当性)と同様、完全にオフチェーンで行われることを前提とし、ここでは設計しない。

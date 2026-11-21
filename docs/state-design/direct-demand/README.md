# Direct-demand petition signatures (直接請求の署名)

**Status: 🟢 Spec drafted.** Resolved through discussion with the user; see [`discussion-log.md`](discussion-log.md) for the reasoning and [ADR 0016](../../decisions/0016-direct-demand-petition-model.md) for the formal decision. No contract code written yet. Carved out of the excluded legislative process by [ADR 0014](../../decisions/0014-legislative-process-scope.md).

## Summary

For each direct demand, the election board deploys a dedicated `Petition` contract holding the demand type, a hash of the full text being demanded, the threshold, the collection period, and an explicit list of eligible addresses. Eligible residents sign by calling the contract from their own `ResidentLink` address. The contract **only certifies the count**: everything before deployment and after the count (the formal demand, a recall vote, objections, relief) stays off-chain.

**Goal, precisely stated:** make signature forgery like the 2020 Aichi recall case (~362,000 of ~435,000 signatures suspected invalid) structurally impossible, by removing the collector role and verifying each signer at the moment of signing. Hiding who signed is *not* a goal.

## Scope

**In scope:** all six demand types of the Local Autonomy Act (arts. 74–88): ordinance enactment/amendment/abolition, audit of affairs, assembly dissolution, assembly-member recall, head-of-government recall, senior-official recall. One generic contract covers all of them.

**Out of scope:**
- Triggering the next step automatically (e.g. deploying a recall `Election`): off-chain (Round 2, Issue 8). A resulting vote uses the existing [voting](../voting/) design.
- Withdrawing a signature on-chain: not possible; relief for coerced signers is off-chain (Issue 7).
- Objections: off-chain (Issue 9).
- A paper channel, and the transition from today's system: out of scope for this thought experiment (Issue 10).
- Gas fees: every resident is assumed to hold enough (Issue 11).

## On-chain / Online / Offline breakdown

(See [`docs/operations/README.md`](../../operations/README.md) for the convention.)

**On-chain:**
- One `Petition` contract per demand, deployed from `PetitionFactory` by the election board: demand type, representative address(es), content hash, denominator, threshold, collection period, eligible list, signatures, pause history.
- Every board action (list edit, pause, resume) and every signature emits an event.

**Online:**
- The election board publishes the petition's contract address under its own `.lg.jp` domain. This is how residents tell a genuine petition from a look-alike (Issue 4), the same attestation pattern as earlier designs.
- The full text (the ordinance draft or recall reason, and the summary of the demand) is published by the board; anyone can hash it and compare with the on-chain `contentHash`.

**Offline:**
- The representative's application, and the board's checks before deployment (e.g. the one-year restrictions after an election or a previous recall vote).
- Building the eligible list from the voter roll (Japanese national, 18+, 3+ months' residence; the district's voters for an assembly-member recall).
- Deciding to pause for an election period.
- Objections, and relief for coerced or key-compromised signers.
- The formal demand once the threshold is met, and every step after it.

## Architecture

### `PetitionFactory` (one per election board)

- `createPetition(...)` is callable only by the board's controlling address. Every petition runs the same audited code, so residents only have to check the address, not the logic.

### `Petition` (one per demand)

**Fixed at deployment (never changeable):**

| Field | Meaning |
|---|---|
| `demandType` | `OrdinanceEnactment` / `Audit` / `AssemblyDissolution` / `MemberRecall` / `HeadRecall` / `OfficialRecall` (F5) |
| `representatives` | The representative address(es). Recorded only; they have no on-chain powers |
| `contentHash` | Hash of the full text and summary of the demand (Issue 3) |
| `denominator` | The number of eligible voters the threshold is based on, so anyone can recompute 1/50, 1/3, 1/6, 1/8 (F3) |
| `threshold` | The required signature count (F3) |
| `collectionStart`, `collectionEnd` | The collection period (Issue 5) |

**Board-only functions (until the effective end):**
- `addEligible(address[])`: each address must hold a token from a `ResidentLink` contract allowlisted in `OfficialContractRegistry` ([ADR 0015](../../decisions/0015-political-donations-model.md)), the same check as voting's `grantVotingRight` (Round 3 adjustment).
- `removeEligible(address[])`: e.g. a resident who moved out (Issue 12). If the address has already signed, that signature drops out of the count; it is restored if the address is added back (F2).
- `pause()` / `resume()`: for election periods. Paused time is added to the end automatically (see below).

The board **cannot** change the content hash, the threshold, the denominator, or the end date, and cannot delete a signature (F4).

**Signing:**
- `sign()`: no arguments, since the content is fixed by `contentHash`. Requires the caller to be listed, not to have signed before, the petition not paused, and `collectionStart ≤ block.timestamp < effectiveEnd`. Records the signature and emits `Signed(signer)`. Signer addresses are public (Issue 6). There is no `unsign()` (Issue 7).

**Count and certification:**
- `signatureCount()`: signatures from currently listed addresses (F2).
- `effectiveEnd()`: `collectionEnd + total paused time` (Round 3 adjustment).
- `isFinal()`: true once `block.timestamp ≥ effectiveEnd`. From then on, nothing can change, so `signatureCount()` is the certified count and `signatureCount() ≥ threshold` is the certified result (Issue 8).

### Dates on-chain

The collection period is actively enforced, so it is a justified on-chain date exception of the same kind as voting's voting period ([ADR 0013](../../decisions/0013-voting-model.md)).

### What is public, and why that is accepted

- **Who signed** (by address): accepted as what using web3 means (Issue 6). Today's public inspection (縦覧) already exposes signers' names and addresses, which is more than this does.
- **Who is eligible** (by address): each listed address is publicly signalled as "Japanese national, 18+". Voting's per-election grants already publish the same signal, so this is consistent with existing design. No *standing* nationality credential is created (F1, option (a)).
- **Every board action**: list edits and pauses are visible immediately, which is the check on the board's own power (Issue 12).

### Comparison with today

| Weakness today | With this design |
|---|---|
| Identity not verified when signing | Only a listed address holding a genuine `ResidentLink` can sign |
| Collectors can write in other people's names | No collectors: each resident signs themself |
| Manual checking against the voter roll | The count is computed by the contract |
| Public inspection exposes names and addresses | Only addresses are public |
| The board's checking is a black box | Every list edit and pause is on-chain |

## Open items for later

- Large eligible lists (a prefecture-wide recall can mean millions of addresses): the same cost issue as voting's per-voter grants, tracked in [`docs/BACKLOG.md`](../../BACKLOG.md) (Merkle-root alternative).
- Key governance for the board's controlling address: covered by the existing backlog item on selecting an audited multisig standard.

---

# 直接請求の署名(日本語)

**ステータス: 🟢 設計確定。** ユーザーとの議論で解決した。理由は[`discussion-log.md`](discussion-log.md)、正式な決定は[ADR 0016](../../decisions/0016-direct-demand-petition-model.md)を参照。コントラクトコードはまだない。[ADR 0014](../../decisions/0014-legislative-process-scope.md)で対象外とした立法プロセスから切り出した項目である。

## 概要

選挙管理委員会は、直接請求ごとに専用の`Petition`コントラクトをデプロイする。コントラクトには、請求の種類、請求内容の全文のハッシュ、必要数、収集期間、有資格アドレスの明示的な一覧を持たせる。有資格の住民は、自分の`ResidentLink`アドレスからコントラクトを呼び出して署名する。コントラクトは**署名数の証明だけ**を行う。デプロイ前と集計後のこと(本請求、解職の住民投票、異議申し立て、救済)はすべてオフチェーンで扱う。

**目的を正確に言うと:** 受任者という役割をなくし、署名した時点で各署名者を確認することで、2020年の愛知県リコール(約43万5千筆のうち約36万2千筆に不正の疑い)のような署名偽造を構造的に不可能にする。誰が署名したかを隠すことは目的*ではない*。

## スコープ

**対象:** 地方自治法(74〜88条)の6種類の請求すべて。条例の制定・改廃、事務の監査、議会の解散、議員の解職、首長の解職、主要公務員の解職。1つの汎用コントラクトで扱う。

**対象外:**
- 次の手続きの自動起動(解職の`Election`のデプロイなど): オフチェーン(Round 2、論点8)。その後の投票は既存の[投票](../voting/)の設計を使う。
- オンチェーンでの署名の撤回: できない。圧力で署名させられた人の救済はオフチェーン(論点7)。
- 異議申し立て: オフチェーン(論点9)。
- 紙の窓口と、現行制度からの移行: この思考実験では対象外(論点10)。
- ガス代: 全住民が十分に持つことを前提とする(論点11)。

## オンチェーン/オンライン/オフラインの内訳

(区分の考え方は[`docs/operations/README.md`](../../operations/README.md)を参照。)

**オンチェーン:**
- 請求ごとに1つの`Petition`コントラクト。選管が`PetitionFactory`からデプロイする。請求の種類、代表者のアドレス、全文ハッシュ、分母、必要数、収集期間、有資格一覧、署名、一時停止の履歴を持つ。
- 選管の操作(一覧の編集、一時停止、再開)と署名は、すべてイベントとして記録する。

**オンライン:**
- 選管は、請求のコントラクトアドレスを自らの`.lg.jp`ドメインで公表する。住民はこれで本物の請求とよく似た偽物を見分ける(論点4)。これまでの設計と同じ証明の仕組みである。
- 全文(条例案や解職の理由、請求の要旨)は選管が公表する。誰でもハッシュを計算して、オンチェーンの`contentHash`と照合できる。

**オフライン:**
- 代表者の申し出と、デプロイ前の選管の確認(選挙や前回の解職投票から1年間の制限など)。
- 選挙人名簿から有資格一覧を作ること(日本国籍・18歳以上・3か月以上居住。議員の解職ではその選挙区の有権者)。
- 選挙期間のために一時停止するかの判断。
- 異議申し立てと、圧力で署名させられた人や鍵を盗まれた人の救済。
- 必要数に達した後の本請求と、それ以降のすべての手続き。

## アーキテクチャ

### `PetitionFactory`(選管ごとに1つ)

- `createPetition(...)`は選管の管理アドレスだけが呼び出せる。すべての請求が同じ監査済みのコードで動くので、住民はロジックではなくアドレスだけを確認すればよい。

### `Petition`(請求ごとに1つ)

**デプロイ時に固定(変更不可):**

| フィールド | 意味 |
|---|---|
| `demandType` | `OrdinanceEnactment` / `Audit` / `AssemblyDissolution` / `MemberRecall` / `HeadRecall` / `OfficialRecall`(F5) |
| `representatives` | 代表者のアドレス。記録のみで、オンチェーンの権限は持たない |
| `contentHash` | 請求内容の全文と要旨のハッシュ(論点3) |
| `denominator` | 必要数の基準となる有権者数。誰でも1/50、1/3、1/6、1/8を検算できる(F3) |
| `threshold` | 必要署名数(F3) |
| `collectionStart`、`collectionEnd` | 収集期間(論点5) |

**選管だけが呼べる関数(実効的な終了まで):**
- `addEligible(address[])`: 各アドレスが、`OfficialContractRegistry`([ADR 0015](../../decisions/0015-political-donations-model.md))の許可リストにある`ResidentLink`コントラクトのトークンを持つことを確認する。投票の`grantVotingRight`と同じ確認である(Round 3の調整)。
- `removeEligible(address[])`: 転出した住民など(論点12)。すでに署名していれば、その署名は数から外れる。一覧に戻せば署名も数に戻る(F2)。
- `pause()` / `resume()`: 選挙期間のため。一時停止した時間は自動で終了に加算される(下記)。

選管は、全文ハッシュ、必要数、分母、終了日を変更できず、署名を削除することもできない(F4)。

**署名:**
- `sign()`: 内容は`contentHash`で固定されているので引数はない。呼び出し元が一覧に載っていること、まだ署名していないこと、一時停止中でないこと、`collectionStart ≤ block.timestamp < effectiveEnd`であることを確認する。署名を記録し、`Signed(signer)`を発行する。署名者のアドレスは公開される(論点6)。`unsign()`はない(論点7)。

**署名数と証明:**
- `signatureCount()`: 現在一覧に載っているアドレスの署名の数(F2)。
- `effectiveEnd()`: `collectionEnd + 一時停止の合計時間`(Round 3の調整)。
- `isFinal()`: `block.timestamp ≥ effectiveEnd`になると真。それ以降は何も変わらないので、`signatureCount()`が証明された署名数、`signatureCount() ≥ threshold`が証明された結果になる(論点8)。

### オンチェーンの日付

収集期間はコントラクトが能動的に強制するので、投票の投票期間([ADR 0013](../../decisions/0013-voting-model.md))と同じ種類の、正当化されたオンチェーンの日付の例外である。

### 公開されるものと、それを受け入れる理由

- **誰が署名したか**(アドレス単位): web3を使うとはそういうことだとして受け入れる(論点6)。現在の縦覧はすでに署名者の氏名と住所を公開しており、それより公開範囲は狭い。
- **誰が有資格者か**(アドレス単位): 一覧に載った各アドレスは「18歳以上の日本国籍者」であることを公に示す。投票の選挙ごとの付与もすでに同じ情報を公開しているので、既存の設計と整合する。*常設の*国籍証明は作らない(F1、選択肢(a))。
- **選管のすべての操作**: 一覧の編集と一時停止はすぐに見える。これが選管自身の権限に対する歯止めになる(論点12)。

### 現行制度との比較

| 現行の弱点 | この設計では |
|---|---|
| 署名した時点で本人確認ができない | 一覧に載り、本物の`ResidentLink`を持つアドレスだけが署名できる |
| 受任者が他人の名前を書き込める | 受任者はいない。住民が自分で署名する |
| 選挙人名簿との手作業の照合 | 署名数はコントラクトが計算する |
| 縦覧で氏名と住所が公開される | 公開されるのはアドレスだけ |
| 選管の審査が外から見えない | 一覧の編集と一時停止はすべてオンチェーン |

## 今後の課題

- 大きな有資格一覧(都道府県全体の解職請求では数百万アドレスになりうる): 投票の有権者ごとの付与と同じコストの問題。[`docs/BACKLOG.md`](../../BACKLOG.md)で管理している(Merkle rootによる代替)。
- 選管の管理アドレスの鍵管理: 監査済みマルチシグ規格の選定に関する既存のBACKLOG項目で扱う。

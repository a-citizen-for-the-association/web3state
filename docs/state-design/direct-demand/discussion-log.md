# Discussion Log: Direct-demand petition signatures

Records the back-and-forth on this feature's design, in order. See [`docs/state-design/citizenship/discussion-log.md`](../citizenship/discussion-log.md) for the format this follows. The scope screening that created this item is in [`docs/state-design/legislative/`](../legislative/) and [ADR 0014](../../decisions/0014-legislative-process-scope.md).

---

## Round 1 — 2026-10-17 (user + Claude)

### Background: the current system

Direct demand (直接請求, Local Autonomy Act arts. 74–88) lets residents force a local government to act by collecting signatures:

| Demand | Signatures needed | Addressed to | What happens next |
|---|---|---|---|
| Enact/amend/abolish an ordinance (74) | 1/50 of eligible voters | Head of government | Put to the assembly, which may reject it. Local taxes and fees excluded |
| Audit of affairs (75) | 1/50 | Audit commissioners | Audit and publication |
| Dissolve the assembly (76) | 1/3 (eased above 400,000 voters) | Election board | Resident vote; majority dissolves |
| Recall an assembly member (80) | 1/3 of the district's voters | Election board | Resident vote; majority removes |
| Recall the head of government (81) | 1/3 | Election board | Resident vote; majority removes |
| Recall senior officials (86) | 1/3 | Head of government | Assembly: 2/3 quorum, 3/4 consent |

Current process: the representative obtains a representative certificate from the election board → delegates collection to "collectors" (受任者) → collection on paper with handwritten signatures, in person only, for 2 months (prefectures/designated cities) or 1 month (other municipalities), suspended during elections → submission → the election board checks each signature against the voter roll by hand → public inspection (縦覧) and objections → formal demand.

Weaknesses: identity is not verified at the moment of signing; manual checking is heavy; public inspection exposes signers' personal data; the collector system leaves room for others to write signatures in (the 2020 Aichi recall forgery: ~362,000 of ~435,000 signatures suspected invalid); the post-scandal fix only added a collector-name field to the form.

### User's base design

1. The representative applies to the election board **off-chain**.
2. The election board **deploys a contract dedicated to that petition**, holding the representative's address, the purpose, and other minimal information.
3. Supporters sign by calling that contract.

### Claude's review: 12 issues

The shape matches voting's per-election `Election` contract ([ADR 0013](../../decisions/0013-voting-model.md)), and self-signing removes the collector role, which was the forgery vector.

Gaps:

1. **Eligibility.** `ResidentLink` is nationality-neutral ([ADR 0003](../../decisions/0003-resident-link-identity-model.md)); signers must be on the municipality's voter roll (Japanese national, 18+, 3+ months' residence), or the district's roll for an assembly-member recall.
2. **Threshold denominator.** The required count depends on the voter roll at a point in time; it should be fixed at deployment.
3. **What is being signed.** The full ordinance draft and the summary of the demand must be fixed so they cannot be swapped after signing.
4. **Fake petition contracts.** Anyone can deploy a look-alike.
5. **Period control.** The collection window, including the suspension during elections.

Decisions needed:

6. **Signature visibility.** Signing from a `ResidentLink` address publishes participation per address: retaliation risk, and coercion ("show me you did / didn't sign").
7. **Withdrawal** of a signature.
8. **After the threshold**: automatically trigger the next step (e.g. a recall `Election`), or only certify the count.
9. **Public inspection and objections**: what remains of them.

Operations:

10. **Paper channel** for residents without wallets.
11. **Gas fees**: who pays.
12. **Moving during the collection period.**

### Status

Awaiting the user's decisions.

---

## Round 2 — 2026-10-17 (user + Claude)

### User's decisions

| # | Decision |
|---|---|
| 1 | The petition contract holds an **explicit list of eligible addresses**. The election board is a local government body with access to off-chain resident data, so it can build the list. |
| 2 | Resolved by 1: the threshold is computed from the same list. |
| 3 | **Accepted**: the hash of the full text is stored in the contract. |
| 4 | Authenticity is checked **off-chain** (the election board's official publication). |
| 5 | The **election board controls** the collection period. |
| 6 | **Signer addresses are public.** That is what using web3 means. |
| 7 | **No withdrawal** on-chain. Relief (e.g. a coerced signer) is handled off-chain. |
| 8 | The contract **only certifies the signature count**. The formal demand and later steps stay off-chain. |
| 9 | Objections are handled **off-chain**. |
| 10 | **No paper channel.** This is a thought experiment; the transition problem is out of scope. |
| 11 | **Out of scope.** In a society implemented on web3, every resident is assumed to hold enough gas. The user also noted unease with the native token being an unlimited investment asset today. |
| 12 | The election board has **authority to edit the eligible list**. If it abuses that authority, the abuse is visible on-chain immediately. |

### Follow-up points raised by Claude before writing the spec

- **F1. The eligible list is a nationality signal.** Listing an address means "this `ResidentLink` holder is a Japanese national aged 18+". ADR 0006 and ADR 0015 avoided creating a standing on-chain nationality credential. Voting's `grantVotingRight` already publishes the same signal per election, so this is consistent with existing design, but the petition makes it explicit for the whole roll. Options: (a) accept, a list per petition; (b) one standing per-election-board voter-roll contract, reused by both `Election` and petitions, which is simpler but is effectively the standing credential that was avoided.
- **F2. Removal after signing.** Proposal: if the board removes an address that has already signed (e.g. moved out), that signature drops out of the count. The count is always "signatures from currently listed addresses".
- **F3. Fixed threshold.** Proposal: the required count is written at deployment, together with the denominator, so anyone can recompute 1/50, 1/3, 1/6, 1/8. Later list edits do not change it, so the board cannot move the goalposts.
- **F4. Limits on the board's control.** Proposal: the board can pause/resume (for election periods) and edit the list, but cannot change the content hash, the threshold, or delete signatures. All actions emit events.
- **F5. One generic contract** for all six demand types, with the type as a parameter; for an assembly-member recall, the list is the district's voters.

### Status

Awaiting the user's response to F1–F5.

---

# 議論ログ: 直接請求の署名(日本語)

この機能の設計に関するやり取りを順に記録する。形式は[`docs/state-design/citizenship/discussion-log.md`](../citizenship/discussion-log.md)に従う。この項目を生んだスコープの選別は[`docs/state-design/legislative/`](../legislative/)と[ADR 0014](../../decisions/0014-legislative-process-scope.md)にある。

---

## Round 1 — 2026-10-17(ユーザー + Claude)

### 前提: 現行制度

直接請求(地方自治法74〜88条)は、住民が署名を集めて自治体に行動を義務づける制度である。

| 請求 | 必要署名数 | 請求先 | その後 |
|---|---|---|---|
| 条例の制定・改廃(74条) | 有権者の1/50 | 首長 | 議会に付議。否決できる。地方税・手数料等は対象外 |
| 事務の監査(75条) | 1/50 | 監査委員 | 監査し公表 |
| 議会の解散(76条) | 1/3(40万人超は緩和) | 選挙管理委員会 | 住民投票。過半数で解散 |
| 議員の解職(80条) | 選挙区の有権者の1/3 | 選挙管理委員会 | 住民投票。過半数で失職 |
| 首長の解職(81条) | 1/3 | 選挙管理委員会 | 住民投票。過半数で失職 |
| 主要公務員の解職(86条) | 1/3 | 首長 | 議会: 2/3出席、3/4同意 |

現行の流れ: 代表者が選管から代表者証明書を受ける → 受任者に収集を委任 → 紙に自署、対面のみで、2か月(都道府県・指定都市)または1か月(その他の市町村)収集。選挙期間中は中断 → 提出 → 選管が選挙人名簿と手作業で照合 → 縦覧と異議申し立て → 本請求。

弱点: 署名した時点で本人確認ができない。手作業の審査が重い。縦覧で署名者の個人情報が公開される。受任者の仕組みが他人による書き込みの余地を残す(2020年の愛知県リコールの偽造: 約43万5千筆のうち約36万2千筆に不正の疑い)。事件後の対策は、署名簿に収集者の氏名欄を加えたことにとどまる。

### ユーザーの基本設計

1. 代表者は**オフチェーン**で選挙管理委員会に申し出る。
2. 選管は、**その請求専用のコントラクトをデプロイする**。代表者のアドレス、目的など必要最低限の情報を載せる。
3. 賛成する人はそのコントラクトを使って署名する。

### Claudeのレビュー: 12の論点

投票の選挙ごとの`Election`コントラクト([ADR 0013](../../decisions/0013-voting-model.md))と同じ形であり、本人が自分で署名するので、偽造の入口だった受任者が不要になる。

穴になる点:

1. **署名の資格。** `ResidentLink`は国籍を問わない([ADR 0003](../../decisions/0003-resident-link-identity-model.md))。署名者はその自治体の選挙人名簿(日本国籍・18歳以上・3か月以上居住)、議員の解職なら選挙区の名簿に載っている必要がある。
2. **必要数の分母。** ある時点の名簿で決まるので、デプロイ時に固定すべき。
3. **署名の対象。** 条例案の全文と請求の要旨を、署名後に差し替えられないよう固定する必要がある。
4. **偽の請求コントラクト。** 誰でもよく似たものをデプロイできる。
5. **期間の制御。** 収集期間と、選挙期間中の中断。

判断が必要な点:

6. **署名の公開範囲。** `ResidentLink`アドレスからの署名は、アドレス単位で参加を公開する。報復のおそれと、圧力(「署名した/しなかった証拠を見せろ」)。
7. 署名の**撤回**。
8. **必要数到達後**: 次の手続き(解職の`Election`など)を自動で起動するか、署名数の証明だけにするか。
9. **縦覧と異議申し立て**のうち何を残すか。

運用面:

10. ウォレットを持たない人のための**紙の窓口**。
11. **ガス代**を誰が払うか。
12. **収集期間中の転居**。

### ステータス

ユーザーの判断待ち。

---

## Round 2 — 2026-10-17(ユーザー + Claude)

### ユーザーの決定

| # | 決定 |
|---|---|
| 1 | 請求コントラクトに**有資格アドレスの一覧を明示的に載せる**。選管は地方の行政組織であり、オフチェーンの住民データにアクセスできるので一覧を作れる。 |
| 2 | 1で解決: 必要数は同じ一覧から計算する。 |
| 3 | **提案どおり**: 全文のハッシュをコントラクトに載せる。 |
| 4 | 本物かどうかは**オフチェーン**(選管の公式な発表)で確認する。 |
| 5 | 収集期間は**選管が制御する**。 |
| 6 | **署名者のアドレスは公開する。** web3を使うとはそういうことである。 |
| 7 | オンチェーンでの**撤回は認めない**。救済(圧力で署名させられた人など)はオフチェーンで扱う。 |
| 8 | コントラクトは**署名数の証明だけ**に使う。本請求以降の手続きはオフチェーン。 |
| 9 | 異議申し立ては**オフチェーン**で扱う。 |
| 10 | **紙は残さない。** 思考実験なので、移行期の問題は検討対象外。 |
| 11 | **対象外。** 社会がweb3で実装される世界では、全住民が十分なガスを持つことを前提とする。ユーザーは、現在ネイティブトークンが無制限の投資対象になっていること自体に違和感があるとも述べた。 |
| 12 | 選管に**一覧を編集する権限**を持たせる。選管が不正をしても、オンチェーンであればすぐに確認できる。 |

### 仕様作成前にClaudeが提起した確認点

- **F1. 有資格一覧は国籍のシグナルになる。** 一覧に載ることは「この`ResidentLink`保有者は18歳以上の日本国籍者である」ことを意味する。ADR 0006とADR 0015は、継続的なオンチェーンの国籍証明を作ることを避けた。投票の`grantVotingRight`も選挙ごとに同じシグナルを公開しているので既存設計と矛盾はしないが、請求では名簿全体が明示的に載る。選択肢: (a) 受け入れ、請求ごとに一覧を持つ。(b) 選管ごとに常設の選挙人名簿コントラクトを1つ置き、`Election`と請求の両方で再利用する。こちらは簡潔だが、避けてきた常設の国籍証明に実質的になる。
- **F2. 署名後の削除。** 提案: 選管がすでに署名したアドレスを一覧から削除した場合(転出など)、その署名は数から外れる。署名数は常に「現在一覧に載っているアドレスの署名の数」とする。
- **F3. 必要数の固定。** 提案: 必要数をデプロイ時に分母と一緒に書き込み、誰でも1/50、1/3、1/6、1/8を検算できるようにする。後で一覧を編集しても必要数は変わらないので、選管がゴールを動かすことはできない。
- **F4. 選管の権限の範囲。** 提案: 選管は一時停止・再開(選挙期間用)と一覧の編集はできるが、全文ハッシュ・必要数の変更や署名の削除はできない。すべての操作はイベントとして記録する。
- **F5. 6種類の請求すべてを1つの汎用コントラクト**で扱い、請求の種類をパラメータにする。議員の解職では一覧はその選挙区の有権者とする。

### ステータス

F1〜F5へのユーザーの回答待ち。

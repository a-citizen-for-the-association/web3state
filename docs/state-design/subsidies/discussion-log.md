# Discussion Log: Subsidies / grants disbursement (補助金・交付金)

Records the back-and-forth on this feature's design, in order. See [`docs/state-design/citizenship/discussion-log.md`](../citizenship/discussion-log.md) for the format this follows.

---

## Round 1 — 2026-10-24 (Claude)

### Background: the current system

- **Subsidies (補助金)** go to businesses and organisations. The flow is: application → review → grant decision → the recipient carries out the project → expense report with receipts → amount finalised → payment, usually after the fact, sometimes in advance.
- **Grants to local governments (交付金)** go from the national government to prefectures and municipalities.
- Payments to individuals (child allowances, welfare) are the separate "Benefits" item.

Known problems:
- **Fraudulent claims at scale:** the 2020–21 business-continuity benefit and the COVID special employment-adjustment subsidy led to many fraudulent claims and arrests.
- **Fake or inflated receipts,** and **kickbacks:** a vendor quietly returns part of the subsidised price to the recipient (cases reported in IT-adoption subsidies).
- **Claiming the same expense under several programmes** (duplicate receipt).
- **Questionable uses of grants to local governments.** Whether a use is wise is mainly a judgement call.

### What already exists in this project

- Payment goes through the treasury ([ADR 0019](../../decisions/0019-treasury-model.md)) to an identified payee.
- Under the certified-address rule ([ADR 0020](../../decisions/0020-certified-address-stablecoin.md)), **every JPY payment a recipient makes to its vendors is on-chain**, and so is any money flowing back from a vendor.
- Grant decisions can be anchored like any approval document ([ADR 0017](../../decisions/0017-executive-document-anchoring-v1.md)).

### On-chain value test ([ADR 0014](../../decisions/0014-legislative-process-scope.md)), sub-part by sub-part

| Sub-part | Q1 problem | Q2 keeper | Q3 technical | Q4 no record | Q5 combination | Result |
|---|---|---|---|---|---|---|
| Disbursement | — | — | — | — | — | Already covered by the treasury |
| **Proof of expenses** (実績報告) | **Yes**: fake and inflated receipts | **Yes**: the recipient produces its own evidence | **Yes**: an on-chain payment cannot be faked | **Yes**: paper receipts are unverifiable | **Strong**: certified-address payments | **Candidate (core)** |
| **Kickbacks and duplicate claims** | **Yes** | Yes | **Yes**: the return flow, and a reused payment, are visible | Yes | Strong | **Candidate**: detection by off-chain analysis |
| Eligibility review | Partial | — | **Mostly no**: judgement (some facts, e.g. revenue, may later be computable from on-chain data) | — | Moderate | Off-chain |
| Grants to local governments: use | Partial | — | **No**: whether a use is wise is institutional | Partial | Strong: treasury to treasury | Traceable through codes; judgement off-chain |

### Proposal in line with "off-chain if it can be" ([ADR 0019](../../decisions/0019-treasury-model.md))

No new contract is needed. A contract cannot cheaply read past transactions, so automating "pay only after verified expenses" on-chain would be heavy. What the chain already guarantees (expense payments that cannot be faked, visible flows) is enough. The checks are done off-chain from public data.

### Issues raised

1. **Screening result.** Scope: subsidies to businesses and organisations, and grants to local governments; benefits to individuals are a separate item.
2. **New contract or not.** (A) No new contract: the grant decision is anchored as an approval document; payment is a treasury payment whose budget code names the programme and grant; checks are off-chain. (B) A `SubsidyProgram` contract recording grants and submitted evidence on-chain. Proposal: **(A)**.
3. **Expense evidence = on-chain transactions.** Subsidised expenses must be paid in the JPY stablecoin to certified addresses, and the expense report lists those transactions instead of paper receipts. Cash-paid expenses are not eligible. Fake receipts become impossible.
4. **Publication.** Every grant (programme, recipient, amount) and every expense report is public, including grants to sole proprietors, consistent with public payments to individuals (ADR 0019).
5. **Kickbacks and duplicates.** Detected by off-chain analysis: money flowing back from a vendor to the recipient, and the same transaction listed in more than one expense report. Kickbacks are illegal; detection leads to repayment and penalties.
6. **Grants to local governments.** When a local government spends a national grant, its treasury payments cite the grant in their budget code, so the national level, and anyone else, can trace how each grant was used.

### Status

Awaiting the user's response.

---

# 議論ログ: 補助金・交付金(日本語)

この機能の設計に関するやり取りを順に記録する。形式は[`docs/state-design/citizenship/discussion-log.md`](../citizenship/discussion-log.md)に従う。

---

## Round 1 — 2026-10-24(Claude)

### 前提: 現行制度

- **補助金**は事業者や団体に交付される。流れは次のとおり: 申請 → 審査 → 交付決定 → 受給者が事業を実施 → 領収書を付けた実績報告 → 額の確定 → 支払い(多くは事後の精算払、一部は概算払)。
- **交付金**は国から都道府県・市区町村に交付される。
- 個人への支払い(児童手当、生活保護)は、別項目の「給付」である。

知られている問題:
- **大規模な不正受給:** 2020〜21年の持続化給付金と、コロナ特例の雇用調整助成金では、多くの不正受給と逮捕者が出た。
- **偽造・水増しの領収書**と**キックバック**: 業者が補助対象の代金の一部をひそかに受給者に戻す(IT導入補助金で事例が報じられた)。
- **同じ経費を複数の制度で申請すること**(重複受給)。
- **交付金の疑問のある使い道。** 使い道が賢明かどうかは、主に判断の問題である。

### このプロジェクトにすでにあるもの

- 支払いは国庫([ADR 0019](../../decisions/0019-treasury-model.md))を通して、身元の分かる支払先に行われる。
- 認定アドレス制のルール([ADR 0020](../../decisions/0020-certified-address-stablecoin.md))の下では、**受給者が業者に払う円の支払いはすべてオンチェーン**であり、業者から戻ってくるお金も同様である。
- 交付決定は、他の決裁文書と同じくアンカーできる([ADR 0017](../../decisions/0017-executive-document-anchoring-v1.md))。

### オンチェーン価値テスト([ADR 0014](../../decisions/0014-legislative-process-scope.md))の部分ごとの適用

| 部分 | 問1 問題 | 問2 管理者 | 問3 技術 | 問4 記録なし | 問5 組み合わせ | 結果 |
|---|---|---|---|---|---|---|
| 支払い | — | — | — | — | — | 国庫ですでに扱える |
| **経費の証明**(実績報告) | **はい**: 偽造・水増しの領収書 | **はい**: 受給者が自分で証拠を作る | **はい**: オンチェーンの支払いは偽造できない | **はい**: 紙の領収書は検証できない | **強い**: 認定アドレス間の支払い | **候補(中核)** |
| **キックバックと重複受給** | **はい** | はい | **はい**: 戻りの流れや、使い回された支払いが見える | はい | 強い | **候補**: 検出はオフチェーンの分析 |
| 受給資格の審査 | 一部 | — | **ほぼいいえ**: 判断の問題(売上などの一部の事実は、将来オンチェーンのデータから計算できるかもしれない) | — | 中程度 | オフチェーン |
| 交付金: 使い道 | 一部 | — | **いいえ**: 使い道が賢明かは制度の問題 | 一部 | 強い: 国庫から国庫へ | コードで追跡でき、判断はオフチェーン |

### 「オフチェーンでできることはオフチェーンで」([ADR 0019](../../decisions/0019-treasury-model.md))に沿った提案

新しいコントラクトは要らない。コントラクトは過去の取引を安価に読めないので、「経費を確認してから支払う」をオンチェーンで自動化するのは重い。チェーンがすでに保証していること(偽造できない経費の支払い、見えるお金の流れ)で十分である。確認は公開データからオフチェーンで行う。

### 提起した論点

1. **選別の結果。** 範囲: 事業者・団体への補助金と、自治体への交付金。個人への給付は別項目。
2. **新しいコントラクトを作るか。** (A) 作らない: 交付決定は決裁文書としてアンカーし、支払いは制度と交付を予算コードで示す国庫の支払いとし、確認はオフチェーンで行う。(B) 交付と提出された証拠をオンチェーンに記録する`SubsidyProgram`コントラクトを作る。提案: **(A)**。
3. **経費の証拠 = オンチェーンの取引。** 補助対象の経費は、円建てステーブルコインで認定アドレスに支払わなければならず、実績報告は紙の領収書の代わりにその取引を列挙する。現金で支払った経費は対象外とする。偽造の領収書は不可能になる。
4. **公開。** すべての交付(制度、受給者、金額)とすべての実績報告を公開する。個人事業主への交付も含む。個人への公的な支払いを公開すること(ADR 0019)と整合する。
5. **キックバックと重複。** オフチェーンの分析で検出する: 業者から受給者へ戻るお金と、複数の実績報告に挙げられた同じ取引。キックバックは違法であり、検出されれば返還と罰則につながる。
6. **交付金。** 自治体が国の交付金を使うとき、その国庫の支払いは予算コードでその交付金を参照する。国も、それ以外の誰でも、各交付金がどう使われたかを追える。

### ステータス

ユーザーの回答待ち。

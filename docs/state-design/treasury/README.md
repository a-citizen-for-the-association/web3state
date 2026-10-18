# Treasury / public finance (歳出・予算)

**Status: 🟢 Spec drafted.** Screened with the on-chain value test and resolved through discussion with the user; see [`discussion-log.md`](discussion-log.md) for the reasoning and [ADR 0019](../../decisions/0019-treasury-model.md) for the formal decision. No contract code written yet.

## Summary

Every public body (ministries, prefectures, municipalities, other public bodies) holds its money in its own `PublicTreasury` contract. Taxes and transfers come in; every payment goes out from it as a plain stablecoin transfer, tagged with a budget code, and only to an identified payee. Because the payment is on-chain, anyone can follow the money past the first recipient, whether an individual, a corporation or a subcontractor. No special re-delegation mechanism is needed. Money may leave the chain for legitimately secret uses, but only through a tagged, public exit, so the amount of secret spending is always known.

**Design principle (user, Round 3):** whatever can be done off-chain is not put on-chain. The contract does only what needs a chain; budget checks, classification and analysis are done off-chain from public chain data.

## Scope

**In scope:** holding public money; all spending, including funds (基金), reserve funds (予備費), transfers between bodies, salaries and other payments to individuals, and assembly members' activity expenses (政務活動費).

**Out of scope:**
- Budget formulation and approval: public and political (🚫). Budget documents stay off-chain.
- Government bonds / debt management: a financial-market function (🚫 for now).
- Procurement, subsidies, pensions, benefits: separate items, which spend through this treasury.
- Settlement accounts and audit: not a separate design. Auditors use the on-chain data; judgement stays with them.

## On-chain / Online / Offline breakdown

(See [`docs/operations/README.md`](../../operations/README.md) for the convention.)

**On-chain:**
- One `PublicTreasury` per public body: balances, and every payment with its payee, amount, budget code and tag.
- `OfficialContractRegistry` lists each `PublicTreasury` under a new kind, `PublicTreasury`.

**Online:**
- Each body publishes its treasury address under its own `.go.jp`/`.lg.jp` domain. For taxes, this address is the officially attested receiving address of [ADR 0004](../../decisions/0004-taxation-payment-rail.md).
- Each body publishes its budget and the meaning of its budget codes.

**Offline:**
- Budget formulation and approval.
- Checking payments against the approved budget (overspending, wrong codes): audit and analysis applications.
- Checking that an `OffChainExit` payee is a financial institution, and **thoroughly checking how off-chain money is used** (e.g. the Cabinet Secretariat's discretionary fund).
- Following money past the first recipient, and classifying activity expenses by their source: analysis applications over public chain data.
- Linking a legislator's name to their address: the assembly publishes it.

## Architecture

### `PublicTreasury` (one per public body)

- **Controller:** the body's accounting officer's multisig (the audited multisig standard is an existing backlog item).
- **Receiving:** any incoming stablecoin transfer (taxes, transfers from other treasuries, other revenue). No accounting split is needed, because every inflow to public money is welcome.
- **`pay(to, amount, budgetCode, tag, identityContract)`:** controller only.
  1. **Payee check (Issue 4):** either `registry.kindOf(to) == PublicTreasury`, or `registry.kindOf(identityContract)` is `ResidentLink` or `CorporateRegistration` **and** `identityContract.balanceOf(to) > 0`.
  2. **`tag`:** `Normal` or `OffChainExit` (F1). An `OffChainExit` payee must pass the same check as a corporation; whether it is actually a financial institution is checked off-chain.
  3. **`budgetCode`:** a free code, **not validated on-chain** (Issue 3, option (b)).
  4. Transfers the stablecoin and emits `Paid(to, amount, budgetCode, tag)`.

### Payments to individuals (Issue 6)

Salaries, honoraria and refunds are paid to the recipient's `ResidentLink` address and are public, like every other payment.

### Assembly members' activity expenses (Issue 7, F2)

Paid with `pay()` to the legislator's own `ResidentLink` address, with the activity-expense budget code. The assembly publishes which address belongs to which legislator (legislators are VIPs under [ADR 0012](../../decisions/0012-onchain-scope-philosophy.md)). Where the money then goes, and whether payees look plausible, is analysed off-chain from the address's public outflows. Activity spending and personal spending share one address. This is accepted to keep the design simple.

### Following the money (Issue 5)

Nothing extra. Every payment is a stablecoin transfer, so a contractor's re-delegation payments, and anything further down the chain, are as visible as the first payment.

### Secret spending (Issue 5, F1)

Cash or special financial-institution accounts are allowed only where secrecy is genuinely needed. The exit itself (`OffChainExit`: payee, amount, time, budget code) is public; only the subsequent use is not. Total secret spending per body can always be summed from the chain, and the off-chain checks know exactly which money they must account for.

## Known limits

- Overspending against the budget is detected by audit, not prevented (Issue 3).
- Off-chain money is only as accountable as the off-chain checks.
- Activity expenses and personal spending mix on one address; separating them relies on off-chain analysis.
- Publishing every payment to individuals reveals each public servant's address and pay.

---

# 歳出・予算(日本語)

**ステータス: 🟢 設計確定。** オンチェーン価値テストで選別し、ユーザーとの議論で解決した。理由は[`discussion-log.md`](discussion-log.md)、正式な決定は[ADR 0019](../../decisions/0019-treasury-model.md)を参照。コントラクトコードはまだない。

## 概要

すべての公的機関(省庁、都道府県、市区町村、その他の公的機関)は、自らの`PublicTreasury`コントラクトにお金を置く。税金や移転はここに入り、すべての支払いはここから、予算コードを付けた単純なステーブルコインの送金として、身元の分かる支払先にだけ出ていく。支払いがオンチェーンなので、受取人が個人でも法人でも下請けでも、誰でも最初の受取人より先までお金を追える。再委託のための特別な仕組みは要らない。正当に秘密が必要な用途のためにお金がチェーンの外に出ることはあるが、タグ付きの公開の出口を通る場合に限るので、秘密の支出の額は常に分かる。

**設計方針(ユーザー、Round 3):** オフチェーンでできることは、オンチェーン化しない。コントラクトはチェーンが必要なことだけを行い、予算との照合、分類、分析は、公開されたチェーンのデータからオフチェーンで行う。

## スコープ

**対象:** 公金の保管と、すべての支出。基金、予備費、機関の間の移転、給与など個人への支払い、議員の政務活動費を含む。

**対象外:**
- 予算編成・議決: 公開されており、政治の問題(🚫)。予算書はオフチェーンのまま。
- 国債・債務管理: 金融市場の機能(当面🚫)。
- 公共調達、補助金、年金、給付: 別項目。この国庫を通して支出する。
- 決算・会計検査: 独立した設計はない。検査する側がオンチェーンのデータを使い、判断は検査する側に残る。

## オンチェーン/オンライン/オフラインの内訳

(区分の考え方は[`docs/operations/README.md`](../../operations/README.md)を参照。)

**オンチェーン:**
- 公的機関ごとに1つの`PublicTreasury`: 残高と、支払先・金額・予算コード・タグ付きのすべての支払い。
- `OfficialContractRegistry`は、各`PublicTreasury`を新しい種類`PublicTreasury`として載せる。

**オンライン:**
- 各機関は、国庫のアドレスを自らの`.go.jp`/`.lg.jp`ドメインで公表する。税金については、このアドレスが[ADR 0004](../../decisions/0004-taxation-payment-rail.md)の公式に証明された受け取りアドレスになる。
- 各機関は、予算と予算コードの意味を公表する。

**オフライン:**
- 予算編成と議決。
- 議決された予算との照合(超過、誤ったコード): 検査と分析アプリケーション。
- `OffChainExit`の支払先が金融機関であることの確認と、**オフチェーンに出たお金の使い道の徹底したチェック**(官房機密費など)。
- 最初の受取人より先の追跡と、政務活動費の送金元による分類: 公開されたチェーンのデータに対する分析アプリケーション。
- 議員の名前とアドレスの対応: 議会が公表する。

## アーキテクチャ

### `PublicTreasury`(公的機関ごとに1つ)

- **管理者:** 機関の会計管理者のマルチシグ(監査済みマルチシグ規格は既存のBACKLOG項目)。
- **受け取り:** 入ってくるすべてのステーブルコインの送金(税金、他の国庫からの移転、その他の収入)。公金への入金はすべて歓迎されるので、計上の区別は要らない。
- **`pay(to, amount, budgetCode, tag, identityContract)`:** 管理者のみ。
  1. **支払先の確認(論点4):** `registry.kindOf(to) == PublicTreasury`であるか、または`registry.kindOf(identityContract)`が`ResidentLink`か`CorporateRegistration`で、**かつ**`identityContract.balanceOf(to) > 0`であること。
  2. **`tag`:** `Normal`または`OffChainExit`(F1)。`OffChainExit`の支払先は法人と同じ確認を通らなければならない。本当に金融機関かどうかはオフチェーンで確認する。
  3. **`budgetCode`:** 自由なコードで、**オンチェーンでは検証しない**(論点3、選択肢(b))。
  4. ステーブルコインを送金し、`Paid(to, amount, budgetCode, tag)`を発行する。

### 個人への支払い(論点6)

給与、謝金、還付は受取人の`ResidentLink`アドレスに支払い、他のすべての支払いと同じく公開する。

### 議員の政務活動費(論点7、F2)

`pay()`で、政務活動費の予算コードを付けて、議員自身の`ResidentLink`アドレスに支払う。どのアドレスがどの議員のものかは議会が公表する(議員は[ADR 0012](../../decisions/0012-onchain-scope-philosophy.md)の要人である)。その後お金がどこに行き、支払先が妥当に見えるかは、そのアドレスの公開された送金からオフチェーンで分析する。政務活動の支出と私的な支出は1つのアドレスに混ざる。設計を単純に保つため、これを受け入れる。

### お金を追う(論点5)

追加のものはない。すべての支払いはステーブルコインの送金なので、受注者の再委託の支払いも、その先も、最初の支払いと同じように見える。

### 秘密の支出(論点5、F1)

現金や金融機関の特殊な口座は、本当に秘密が必要な場合にだけ認める。出口そのもの(`OffChainExit`: 支払先、金額、時刻、予算コード)は公開され、その後の使い道だけが公開されない。機関ごとの秘密の支出の総額はいつでもチェーンから合計でき、オフチェーンのチェックは、どのお金について説明を求めるべきかを正確に把握できる。

## 既知の限界

- 予算に対する超過は、防ぐのではなく検査で検出する(論点3)。
- オフチェーンのお金の説明責任は、オフチェーンのチェックの強さに依存する。
- 政務活動費と私的な支出が1つのアドレスで混ざる。両者の区別はオフチェーンの分析に頼る。
- 個人へのすべての支払いを公開するので、各公務員のアドレスと給与が明らかになる。

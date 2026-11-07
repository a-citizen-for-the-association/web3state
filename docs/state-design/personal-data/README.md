# Personal data held by companies (企業が保有する個人情報)

**Status: 🟢 Spec drafted.** Added by the user ([ADR 0027](../../decisions/0027-remaining-scope-triage.md)), screened with the on-chain value test and resolved through discussion; see [`discussion-log.md`](discussion-log.md) for the reasoning and [ADR 0028](../../decisions/0028-personal-data-model.md) for the formal decision. No contract code written yet.

## Summary

A **"don't hold it" law**, backed by the chain. Personal data itself never goes on-chain, not even encrypted. Instead:
1. **What can be proved is not collected.** Facts such as age, residence or a qualification are proved by credentials the person holds at their own address; a company checks them at the time of use and keeps only the result.
2. **What cannot be proved is minimised.** Login by signature (no passwords), payment by stablecoin (no card numbers), delivery addresses given only to the carrier, and any other data kept only for a stated purpose and deleted afterwards.
3. **What remains is watched.** Everyone still holding personal data anchors a daily hash of its access log on-chain, so long-running insider theft cannot be hidden by editing logs.

## Scope

**In scope:** personal data of individuals held by companies; for the access-log rule, also public bodies and their contractors.

**Out of scope:**
- Ransomware defence and system security as such (minimisation only shrinks the damage).
- The legislation's details (retention periods per kind of data, penalties): law, not chain design.

## On-chain / Online / Offline breakdown

(See [`docs/operations/README.md`](../../operations/README.md) for the convention.)

**On-chain:**
- Existing credentials at the person's address: `ResidentLink`, passport, diploma, license, health insurance, employee ID, vaccination.
- **New: age-threshold credentials** (e.g. `Over18`, `Over20`), one contract per municipality, possession-only.
- **New: `AnchorRegistry`**, one shared contract for access-log anchors (and, later, other corporate anchors).

**Online:**
- Wallet-signature login (EIP-4361, "Sign-In with Ethereum").
- Carriers' delivery-address exchange: the buyer gives their physical address to the carrier only.

**Offline:**
- Each company's remaining personal data, its access log, and deletion when the purpose ends.
- The regulator's (or a court's) demand for a log and its check against the anchored root.
- Age checks for visitors, from the passport, without keeping a copy.

## Architecture

### Age-threshold credentials (one contract per municipality)

- Soulbound, possession-only, like the other credentials. No birth date on-chain.
- **Minted by the municipality, without application,** to the person's `ResidentLink` address when they reach the threshold (the municipality already knows the birth date).
- **Never burned on a move** (Round 2 adjustment): a reached threshold stays true. A verifier checks a valid `ResidentLink` and the age credential at the same address; on death, the `ResidentLink` burn is enough.
- Other thresholds are added only when a real need appears.

### `AnchorRegistry` (one shared contract)

- `anchor(bytes32 hash, bytes32 kind)`: the caller must be a certified corporate or public address in `OfficialContractRegistry` ([ADR 0020](../../decisions/0020-certified-address-stablecoin.md)). Emits `Anchored(caller, hash, kind)`. **Stores nothing** (Round 2 adjustment).
- `kind = AccessLog` for the daily access-log root. Other kinds can be added later (e.g. for the on-hold notarization item).

## Rules (the law)

1. **No collecting what can be proved.** If a fact can be verified from a credential at the person's address, a company must verify it at the time of use. It may keep only the address, which fact was checked, and the block number at which it was true (Round 2 adjustment). Keeping copies of ID documents is prohibited.
2. **Customer identifier = the person's address; login by signature.** Companies do not store passwords.
3. **Payment by stablecoin;** companies hold no card numbers (none exist).
4. **Delivery:** the merchant labels the parcel with the buyer's blockchain address, and the buyer gives the physical address only to the carrier. Merchants receive physical addresses only where this is impossible (e.g. installation work at home) and delete them afterwards.
5. **Unavoidable data** (name on a contract, contact details): only for a stated purpose; deleted when it ends; retention periods by law per kind.
6. **Access logs:** every company, public body and contractor holding personal data anchors one Merkle root of its access log per day in `AnchorRegistry`. **A missing daily anchor is visible on-chain and is a violation in itself** (Round 2 adjustment). The log stays with the holder and must be produced on demand.

## Known limits

- Ransomware and intrusions still reach whatever data remains; there is simply less of it.
- An anchored log proves the log was not edited afterwards. It cannot prove the log was complete when written; that depends on the logging system and on audits.
- Insiders with legitimate access are logged, not stopped.
- Using the address as the customer identifier links a person's purchases to an address whose payments are already public (ADR 0020); this adds little, but it is not anonymity.

---

# 企業が保有する個人情報(日本語)

**ステータス: 🟢 設計確定。** ユーザーが追加し([ADR 0027](../../decisions/0027-remaining-scope-triage.md))、オンチェーン価値テストで選別し、議論で解決した。理由は[`discussion-log.md`](discussion-log.md)、正式な決定は[ADR 0028](../../decisions/0028-personal-data-model.md)を参照。コントラクトコードはまだない。

## 概要

チェーンに裏付けられた**「持たせない」法律**。個人情報そのものは、暗号化しても、オンチェーンに載せない。その代わりに:
1. **証明できるものは集めない。** 年齢、居住、資格などの事実は、本人が自分のアドレスに持つクレデンシャルで証明する。企業は利用時にそれを確認し、結果だけを保持する。
2. **証明できないものは最小にする。** ログインは署名で(パスワードなし)、支払いはステーブルコインで(カード番号なし)、配送先の住所は配送業者にだけ渡す。それ以外のデータは示した目的のためだけに持ち、その後は削除する。
3. **残るものは見張る。** 個人情報をまだ持つ者は、アクセスログのハッシュを毎日オンチェーンにアンカリングする。長期の内部の持ち出しを、ログの書き換えで隠せなくなる。

## スコープ

**対象:** 企業が持つ個人の個人情報。アクセスログのルールについては、公的機関とその委託先も対象とする。

**対象外:**
- ランサムウェアの防御とシステムのセキュリティそのもの(最小化は被害を小さくするだけである)。
- 法律の詳細(データの種類ごとの保存期間、罰則): 法律の問題で、チェーンの設計ではない。

## オンチェーン/オンライン/オフラインの内訳

(区分の考え方は[`docs/operations/README.md`](../../operations/README.md)を参照。)

**オンチェーン:**
- 本人のアドレスにある既存のクレデンシャル: `ResidentLink`、パスポート、卒業証明、免許証、健康保険証、社員証、接種証明。
- **新規: 年齢の基準のクレデンシャル**(例: `Over18`、`Over20`)。市区町村ごとに1つのコントラクト、保有だけを示す。
- **新規: `AnchorRegistry`。** アクセスログのアンカー(と、後のほかの法人のアンカー)のための共有コントラクトを1つ。

**オンライン:**
- ウォレットの署名によるログイン(EIP-4361「Sign-In with Ethereum」)。
- 配送業者との配送先の住所のやり取り: 購入者は実際の住所を配送業者にだけ伝える。

**オフライン:**
- 各企業に残る個人情報、そのアクセスログ、目的終了時の削除。
- 規制当局(または裁判所)によるログの提出要求と、アンカーされたルートとの照合。
- 訪問者の年齢確認。パスポートから行い、写しは保管しない。

## アーキテクチャ

### 年齢の基準のクレデンシャル(市区町村ごとに1つのコントラクト)

- ほかのクレデンシャルと同じく、譲渡不可で保有だけを示す。生年月日はオンチェーンに載らない。
- **市区町村が申請なしにmintする。** 本人が基準の年齢に達したときに、その`ResidentLink`アドレスへ発行する(市区町村は生年月日をすでに知っている)。
- **転居してもburnしない**(Round 2の調整): 一度達した基準はずっと真である。確認する側は、同じアドレスで有効な`ResidentLink`と年齢のクレデンシャルを確認する。死亡の場合は`ResidentLink`のburnで足りる。
- ほかの基準は、本当に必要になったときにだけ追加する。

### `AnchorRegistry`(共有コントラクトを1つ)

- `anchor(bytes32 hash, bytes32 kind)`: 呼び出し元は`OfficialContractRegistry`で認定された法人または公的なアドレスでなければならない([ADR 0020](../../decisions/0020-certified-address-stablecoin.md))。`Anchored(caller, hash, kind)`を出す。**何も保存しない**(Round 2の調整)。
- 毎日のアクセスログのルートは`kind = AccessLog`。ほかの種類は後で追加できる(例: 保留中の公証の項目のため)。

## ルール(法律)

1. **証明できるものは集めない。** ある事実を本人のアドレスにあるクレデンシャルで確認できるなら、企業は利用時にそれを確認しなければならない。保持してよいのは、アドレス、どの事実を確認したか、それが真だったブロック番号だけである(Round 2の調整)。本人確認書類の写しの保管は禁止する。
2. **顧客の識別子は本人のアドレス、ログインは署名で。** 企業はパスワードを保存しない。
3. **支払いはステーブルコインで。** 企業はカード番号を持たない(そもそも存在しない)。
4. **配送:** 販売者は購入者のブロックチェーンのアドレスを宛先として荷物に付け、購入者は実際の住所を配送業者にだけ伝える。販売者が実際の住所を受け取るのは、それができない場合(自宅での設置工事など)だけで、その後は削除する。
5. **避けられないデータ**(契約上の氏名、連絡先): 示した目的のためだけに持ち、目的が終われば削除する。保存期間はデータの種類ごとに法律で定める。
6. **アクセスログ:** 個人情報を持つすべての企業、公的機関、委託先は、アクセスログのマークルルートを1日1つ`AnchorRegistry`にアンカリングする。**1日分のアンカーの欠落はオンチェーンでわかり、それ自体が違反となる**(Round 2の調整)。ログは保持者が保管し、求められたら提出しなければならない。

## 既知の限界

- ランサムウェアや侵入は、残っているデータには引き続き届く。その量が少なくなるだけである。
- アンカーされたログは、ログが後から書き換えられていないことを証明する。書かれた時点で完全だったことまでは証明できず、それはログの仕組みと監査に依存する。
- 正当なアクセス権を持つ内部の人間は、記録されるが止められない。
- アドレスを顧客の識別子にすると、ある人の購入が、支払いがすでに公開されているアドレス(ADR 0020)と結びつく。追加される情報は少ないが、匿名ではない。

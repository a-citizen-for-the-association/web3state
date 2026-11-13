# Securities and shareholdings (有価証券・株主の記録)

**Status: 🟢 Spec drafted.** Kept in the scope triage ([ADR 0027](../../decisions/0027-remaining-scope-triage.md)), screened with the on-chain value test and resolved through discussion; see [`discussion-log.md`](discussion-log.md) for the reasoning and [ADR 0030](../../decisions/0030-securities-model.md) for the formal decision. No contract code written yet.

## Summary

Shares and member interests of every corporation are **tokens in one `ShareRegistry` run by the Legal Affairs Bureau (法務局)**, held at the holders' own certified addresses. **Moving the token is the transfer of the share.** Because corporations have addresses too, **who owns whom can be followed to the final individual** by any off-chain application; corporations become "glass boxes".

- **Unlisted shares:** dealings are off-chain; the token transfer is the last step (the real estate pattern, [ADR 0029](../../decisions/0029-real-estate-registry-model.md)).
- **Listed shares:** exchanges stay off-chain as today. **Securities firms record the result on-chain** as the transfer itself: holdings move once a day, net, and each day's executions are anchored as a Merkle root by both firms and exchanges. A missing or mismatching record is severely punished.
- **Beneficial owners** (25% or more) are named in the corporate record; **foreign-controlled corporations** (over 50%, traced through all layers) cannot own land.

## Scope

**In scope:** shares of all stock companies (listed and unlisted); member interests in LLCs and other 持分会社; units of trusts, partnerships and funds that hold them; issuance, transfer and settlement; beneficial-owner names; foreign holders.

**Out of scope:**
- Bonds, government bonds and other debt (no control rights).
- Order matching, short selling and margin trading inside exchanges and firms (off-chain; only the settled result is on-chain).
- Market surveillance (off-chain, by the regulator, using the public record).
- Voting at shareholders' meetings (backlog).
- Dividends need no new design: they are stablecoin payments to holders' addresses.

## On-chain / Online / Offline breakdown

(See [`docs/operations/README.md`](../../operations/README.md) for the convention.)

**On-chain:**
- **New: `ShareRegistry`**, one contract run by the Legal Affairs Bureau.
- **New: `ClearingContract`**, run by the clearing house, for the daily net settlement of listed shares *(spec-time adjustment)*.
- **New certified kind `ForeignInvestor`** in `OfficialContractRegistry` ([ADR 0020](../../decisions/0020-certified-address-stablecoin.md)).
- Existing: `AnchorRegistry` with new kinds `TradeReport` and `CorporateResolution` ([ADR 0028](../../decisions/0028-personal-data-model.md)); corporate records with a new beneficial-owner field ([ADR 0005](../../decisions/0005-corporate-registration-model.md)); the JPY stablecoin.

**Online:**
- Applications that follow holdings through the layers: who controls a corporation, foreign-held share of voting rights, a VIP's holdings.

**Offline:**
- Exchanges' order books and matching; brokers' order handling; securities lending and margin loans.
- Negotiation of unlisted-share deals.
- Identity checks for `ForeignInvestor`; investigation of borrowed-name shares; penalties.

## Architecture

### `ShareRegistry` (one contract, run by the Legal Affairs Bureau)

- **One token class per corporation and share class** (and per vehicle, for units). Balances are held at certified addresses only.
- **Issuance and cancellation** (new shares, buybacks, splits, mergers): only the corporation's multisig, citing the hash of the resolution anchored in `AnchorRegistry` under kind `CorporateResolution` *(adjustment)*.
- **Transfer-restricted shares** (譲渡制限株式): a class flag; each transfer needs the corporation's approval first.
- **Agents:** the owner + agent rule of real estate is **optional** for shares; an individual may set agents per class.
- **Transfer:** by the holder (unlisted shares), or by an authorised broker or the clearing contract (listed shares, below).

### Eligible holders

- `ResidentLink` holders, registered corporations, public bodies, and Japanese nationals abroad (`NonResidentOwner`, [ADR 0029](../../decisions/0029-real-estate-registry-model.md)).
- **`ForeignInvestor`:** certified by the Financial Services Agency after an off-chain identity check, either directly or through a licensed foreign custodian that registers **each final holder** (no omnibus accounts). Can hold shares and the stablecoin needed to pay for them; cannot own land.
- **Trusts, partnerships and funds:** only at a registered contract address, and **their own participants are recorded in `ShareRegistry` as units** in the same way, so the chain of ownership never stops at a vehicle.

### Listed shares: off-chain exchange, on-chain record

1. **Authority:** the investor gives their broker authority to move their listed shares (an operator approval in `ShareRegistry`) and the stablecoin needed to pay (an allowance). Every movement the broker makes is public.
2. **Trading:** exchanges match orders off-chain as today. Short selling and margin trading stay inside the off-chain market.
3. **Daily anchors:** after the close, **each exchange** anchors one Merkle root of its executions, and **each broker** one root of its executions with the client address for each, in `AnchorRegistry` under kind `TradeReport`. A missing day is visible on-chain and is a violation in itself.
4. **Daily net settlement:** net sellers' shares and net buyers' money go into the **clearing house's registered `ClearingContract`**, which then delivers shares to net buyers' addresses and money to net sellers' addresses *(adjustment: settlement through one clearing contract, so brokers need not pair clients with each other)*. Only net results move; positions opened and closed within the day never reach the chain.
5. **Checking:** the regulator can demand the execution data and check it against both roots, and the net transfers against the executions. A mismatch, or settlement that was not recorded, is punished up to licence revocation.

Unlisted shares: dealings are bilateral and off-chain; the holder transfers the token as the last step.

### Beneficial owners and foreign control

- **The corporate record lists by name every individual who ultimately holds 25% or more of the voting rights** (traced through all layers), as officers' names are listed today ([ADR 0005](../../decisions/0005-corporate-registration-model.md)). Names are never linked to addresses. The corporation must file a change; **an application can check that the number of individuals at or above 25% on-chain matches the number of names** *(adjustment)*.
- **Foreign control:** a corporation whose voting rights are held more than 50% by `ForeignInvestor` addresses or foreign-controlled corporations, traced through all layers, is treated as a foreign corporation for land: the Legal Affairs Bureau refuses land transfers to it, and a corporation that becomes foreign-controlled while owning land must sell within a legal period ([ADR 0029](../../decisions/0029-real-estate-registry-model.md)) *(adjustment: the second half)*.

### Borrowed-name shares

The chain cannot see that a holder holds for someone else. Handled by **off-chain investigation and severe penalties**, helped by the stablecoin flows that show who actually paid for the shares.

### VIPs

A VIP's shares, and the corporations they control through shares, are visible from their published address. The off-chain declaration ([ADR 0021](../../decisions/0021-vip-asset-disclosure.md)) shrinks to cash outside the chain and non-JPY tokens.

## Spec-time adjustments (await confirmation)

1. Listed shares settle daily through one `ClearingContract` run by the clearing house.
2. Corporate resolutions for issuance and cancellation are anchored in `AnchorRegistry` (new kind `CorporateResolution`); trade reports use the new kind `TradeReport`.
3. Beneficial-owner names are checked against the on-chain count of individuals at or above 25%.
4. A corporation that becomes foreign-controlled while owning land must sell within a legal period.

## Known limits

- Borrowed-name shares and holdings by relatives remain possible; the chain only makes the money visible.
- Within a day, the chain shows nothing; it relies on the daily anchors and the regulator's checks.
- Brokers hold authority over their clients' listed shares; misuse is visible and punished, not prevented.
- Chain capacity: daily net settlement of all listed shares is still large; a constraint on the mainnet chain choice.
- Addresses and holdings are public; names are public only for officers and beneficial owners, and never linked to addresses.

---

# 有価証券・株主の記録(日本語)

**ステータス: 🟢 設計確定。** スコープの振り分け([ADR 0027](../../decisions/0027-remaining-scope-triage.md))で残され、オンチェーン価値テストで選別し、議論で解決した。理由は[`discussion-log.md`](discussion-log.md)、正式な決定は[ADR 0030](../../decisions/0030-securities-model.md)を参照。コントラクトコードはまだない。

## 概要

すべての法人の株式と持分を、**法務局が運用する1つの`ShareRegistry`のトークン**にし、保有者自身の認定アドレスに置く。**トークンの移転が株式の移転である。** 法人もアドレスを持つので、**誰が誰を所有しているかを最終的な個人まで**、どのオフチェーンのアプリケーションでもたどれる。法人は「ガラス張り」になる。

- **非上場株式:** 取引はオフチェーンで、トークンの移転が最後の手順(不動産の型、[ADR 0029](../../decisions/0029-real-estate-registry-model.md))。
- **上場株式:** 取引所は今のままオフチェーン。**証券会社が結果を移転そのものとしてオンチェーンに記録する:** 保有は1日1回差し引きで動き、その日の約定は証券会社と取引所の両方がマークルルートでアンカリングする。記録の欠落や不一致は厳罰。
- **実質的支配者**(25%以上)は法人の記録に氏名を載せる。**外国人が支配する法人**(すべての層をたどって50%超)は土地を所有できない。

## スコープ

**対象:** すべての株式会社の株式(上場・非上場)。合同会社などの持分会社の持分。それらを持つ信託、組合、ファンドの持分。発行、移転、決済。実質的支配者の氏名。外国人の保有者。

**対象外:**
- 社債、国債、その他の債券(支配権がない)。
- 取引所と証券会社の中での注文の約定、空売り、信用取引(オフチェーン。決済された結果だけがオンチェーン)。
- 市場の監視(規制当局がオフチェーンで、公開の記録を使って行う)。
- 株主総会の議決権行使(バックログ)。
- 配当は新しい設計を要しない: 保有者のアドレスへのステーブルコインの支払い。

## オンチェーン/オンライン/オフラインの内訳

(区分の考え方は[`docs/operations/README.md`](../../operations/README.md)を参照。)

**オンチェーン:**
- **新規: `ShareRegistry`。** 法務局が運用するコントラクトを1つ。
- **新規: `ClearingContract`。** 清算機関が運用し、上場株式の毎日の差し引き決済に使う(*仕様作成時の調整*)。
- **新しい認定の種類`ForeignInvestor`**を`OfficialContractRegistry`に([ADR 0020](../../decisions/0020-certified-address-stablecoin.md))。
- 既存: `AnchorRegistry`に新しい種類`TradeReport`と`CorporateResolution`([ADR 0028](../../decisions/0028-personal-data-model.md))。法人の記録に実質的支配者の新しいフィールド([ADR 0005](../../decisions/0005-corporate-registration-model.md))。円建てステーブルコイン。

**オンライン:**
- 保有を層ごとにたどるアプリケーション: 誰が法人を支配しているか、議決権のうち外国人が持つ割合、要人の保有。

**オフライン:**
- 取引所の板と約定。証券会社の注文の取り扱い。貸株と信用取引の融資。
- 非上場株式の取引の交渉。
- `ForeignInvestor`の本人確認。名義株の捜査。罰則。

## アーキテクチャ

### `ShareRegistry`(法務局が運用するコントラクトを1つ)

- **法人と株式の種類ごとに1つのトークンの種類**(器の持分についても器ごとに)。残高は認定アドレスにしか置けない。
- **発行と消却**(新株発行、自己株式の取得、株式分割、合併): その法人のマルチシグだけが、`AnchorRegistry`に種類`CorporateResolution`でアンカリングした決議のハッシュを示して行う(*調整*)。
- **譲渡制限株式:** 種類のフラグ。移転のたびに、先に法人の承認が必要。
- **代理人:** 不動産の「所有者＋代理人」のルールは株式では**任意**。個人は種類ごとに代理人を設定できる。
- **移転:** 保有者が行う(非上場株式)、または権限を与えられた証券会社か清算コントラクトが行う(上場株式、下記)。

### 保有資格のある者

- `ResidentLink`の保有者、登録された法人、公的機関、海外に住む日本国籍の人(`NonResidentOwner`、[ADR 0029](../../decisions/0029-real-estate-registry-model.md))。
- **`ForeignInvestor`:** 金融庁がオフチェーンの本人確認の後に認定する。直接、または**最終的な保有者を1人ずつ**登録する認可を受けた海外のカストディアンを通じて(オムニバス口座は不可)。株式と、その代金の支払いに必要なステーブルコインを持てる。土地は所有できない。
- **信託、組合、ファンド:** 登録されたコントラクトのアドレスでのみ持てる。**その参加者も`ShareRegistry`に持分として同じ方法で記録する。** 所有のつながりが器で止まることはない。

### 上場株式: オフチェーンの取引所、オンチェーンの記録

1. **権限:** 投資家は、自分の上場株式を動かす権限(`ShareRegistry`でのオペレーターの承認)と、代金の支払いに必要なステーブルコインの権限(allowance)を証券会社に与える。証券会社による移動はすべて公開される。
2. **取引:** 取引所は今と同じくオフチェーンで約定させる。空売りと信用取引はオフチェーンの市場の中にとどまる。
3. **毎日のアンカー:** 取引終了後、**各取引所**は約定のマークルルートを1つ、**各証券会社**は顧客ごとのアドレスを含む約定のルートを1つ、`AnchorRegistry`に種類`TradeReport`でアンカリングする。1日分の欠落はオンチェーンでわかり、それ自体が違反である。
4. **毎日の差し引き決済:** 差し引きで売った人の株式と、差し引きで買った人の代金を、**清算機関の登録された`ClearingContract`**に入れ、そこから株式を買った人のアドレスへ、代金を売った人のアドレスへ渡す(*調整: 1つの清算コントラクトを通すので、証券会社が顧客どうしを組み合わせる必要がない*)。動くのは差し引きの結果だけで、1日の中で売り買いした分はチェーンに載らない。
5. **確認:** 規制当局は約定のデータを提出させて両方のルートと照合し、差し引きの移転を約定と照合できる。不一致や、記録されなかった決済は、免許取消しまでの罰則の対象となる。

非上場株式: 取引は当事者間でオフチェーンで行い、保有者が最後の手順としてトークンを移転する。

### 実質的支配者と外国人による支配

- **法人の記録に、議決権の25%以上を最終的に持つすべての個人の氏名を載せる**(すべての層をたどる)。今の役員の氏名と同じ扱い([ADR 0005](../../decisions/0005-corporate-registration-model.md))。氏名をアドレスと結びつけることはない。法人は変更を届け出なければならない。**オンチェーンで25%以上を持つ個人の数と氏名の数が一致するかを、アプリケーションで確認できる**(*調整*)。
- **外国人による支配:** `ForeignInvestor`のアドレスと外国人が支配する法人が、すべての層をたどって議決権の50%超を持つ法人は、土地について外国法人と同じに扱う: 法務局はその法人への土地の移転を拒否する。土地を持ったまま外国人が支配する法人になった場合は、法定期間内に売らなければならない([ADR 0029](../../decisions/0029-real-estate-registry-model.md))(*調整: 後半*)。

### 名義株

ある保有者が他人のために持っていることは、チェーンからは見えない。**オフチェーンの捜査と重い罰則**で扱い、誰が実際に株式の代金を払ったかを示すステーブルコインの流れが助けになる。

### 要人

要人の株式と、株式を通じて支配する法人が、その公開アドレスから見える。オフチェーンの申告([ADR 0021](../../decisions/0021-vip-asset-disclosure.md))は、チェーン外の現金と円以外のトークンに縮小する。

## 仕様作成時の調整(確認待ち)

1. 上場株式は、清算機関が運用する1つの`ClearingContract`で毎日決済する。
2. 発行と消却のための法人の決議は`AnchorRegistry`にアンカリングする(新しい種類`CorporateResolution`)。約定の報告は新しい種類`TradeReport`を使う。
3. 実質的支配者の氏名は、オンチェーンで25%以上を持つ個人の数と照合する。
4. 土地を持ったまま外国人が支配する法人になった場合は、法定期間内に売らなければならない。

## 既知の限界

- 名義株や親族による保有は依然として可能。チェーンはお金の流れを見えるようにするだけである。
- 1日の中のことはチェーンには何も現れない。毎日のアンカーと規制当局の確認に頼る。
- 証券会社は顧客の上場株式を動かす権限を持つ。不正は見え、罰せられるが、防がれはしない。
- チェーンの処理能力: すべての上場株式の毎日の差し引き決済でも量は大きい。メインネットのチェーン選定の制約となる。
- アドレスと保有は公開される。氏名が公開されるのは役員と実質的支配者だけで、アドレスと結びつけられることはない。

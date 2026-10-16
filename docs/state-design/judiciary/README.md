# Judiciary / dispute resolution (司法・紛争解決)

**Status: 🟢 Spec drafted.** Screened with the on-chain value test and resolved through discussion with the user; see [`discussion-log.md`](discussion-log.md) for the reasoning and [ADR 0018](../../decisions/0018-judiciary-model.md) for the formal decision. No contract code written yet.

## Summary

The judiciary's core (procedure, deliberation, judging) stays off-chain. Three parts are put on-chain or made traceable:

1. **Evidence inventory:** police and prosecutors register each seized item at seizure, append-only, so later alteration and undisclosed evidence become checkable.
2. **Case records:** courts register each record with its retention class and must register its disposal, so improper destruction (as found in 2022) becomes visible. Judgments are records of this kind, which absorbs the Judicial Infrastructure item "judgment publication".
3. **Judgment enforcement:** a debtor's on-chain assets are made identifiable to the court and creditor. Seizure itself stays off-chain, and there is no court role in the stablecoin.

## Scope

**In scope:** the three parts above.

**Out of scope:**
- Filing and procedure: civil-procedure digitalisation already exists (🚫).
- Deliberation and judging: institutional (🚫).
- Criminal records: privacy; not public today and must not become public (🚫).
- **Token-juror arbitration** (Kleros-style rulings given official force): 🚫. Judgement would be weighted by token holdings, jurors would be anonymous and unaccountable, and it would depend on a speculative token.
- A state-run escrow dispute flow for purchases: moved to the everyday-commerce item.
- Supreme Court judge review: already covered by [voting](../voting/).
- Notarization / contract timestamping: stays its own Judicial Infrastructure item.

## On-chain / Online / Offline breakdown

(See [`docs/operations/README.md`](../../operations/README.md) for the convention.)

**On-chain:**
- One `EvidenceRegistry` per investigating body (each prefectural police headquarters, each public prosecutors office).
- One `CaseRecordRegistry` per court.
- Enforcement: nothing new. It traces payment flows that are already public.

**Online:**
- Each body publishes its registry address under its own `.go.jp`/`.lg.jp` domain, the same attestation pattern as the executive `DocumentRegistry` ([ADR 0017](../../decisions/0017-executive-document-anchoring-v1.md)).

**Offline:**
- The evidence and records themselves, and their storage.
- The rule for opaque case references and abbreviated descriptions, and disclosing the case-reference mapping to the court and the defence at indictment.
- The court's decision to lower a record's retention class.
- Enforcement: the court order, the municipality's disclosure of the debtor's `ResidentLink` address, and the seizure itself (for example, an order to an employer to pay part of the salary to the creditor).

## Architecture

### `EvidenceRegistry` (one per investigating body)

The executive `DocumentRegistry` pattern, applied to evidence.

- **Controller:** the body's multisig.
- **`register(caseRef, itemType, description, itemHash, previousId) → id`:** called at seizure. Append-only; a correction is a new registration that references the previous one.
  - `caseRef`: an **opaque case reference**, a hash of the internal case number with a secret salt. A public reader cannot tell which case or suspect it is (Round 3 adjustment).
  - `itemType`: `Physical` (the hash is of its photographs), `Data` (the hash of the data itself), or `InterrogationRecording` (Round 3 adjustment).
  - `description`: a non-identifying, rule-based abbreviation, as for sensitive executive titles.
- **`recordStatus(id, status)`:** `Returned` (to the owner) or `Destroyed`. Emits an event; the entry itself is never removed.
- **What this gives:** at indictment, the prosecution discloses the `caseRef` mapping to the court and the defence. They can then check that every seized item is listed, that nothing was swapped after seizure (hashes match), and that no listed item has gone undisclosed.
- **Known limit:** fabrication *before* seizure, such as planted evidence, is not detected.

### `CaseRecordRegistry` (one per court)

- **Controller:** the court's multisig.
- **`register(caseRef, recordType, recordHash, retentionClass, previousId) → id`:** `recordType` includes `Judgment`, so a later published (anonymised) judgment can be tied to its registered original. `retentionClass`: `Standard`, `SpecialPreservation`, or `Permanent`. No dates are stored.
- **`reclassify(id, newClass)`:** a public event.
- **`dispose(id)`:** records disposal. **Rejected for `SpecialPreservation` and `Permanent`.** The class must be lowered first, which leaves a public trail (Round 3 adjustment).
- **Known limit:** a hash does not keep the content. Preserving the content itself (for example, encrypted durable storage) is tracked in [`docs/BACKLOG.md`](../../BACKLOG.md).

### Judgment enforcement (no new contract)

1. A creditor holding a judgment applies to the court (off-chain).
2. The court orders the debtor's municipality to disclose the debtor's `ResidentLink` address to the court and the creditor (off-chain). This is the same legal-process resolution used to trace donors ([ADR 0015](../../decisions/0015-political-donations-model.md)). A corporation's address is already public.
3. The debtor's balance, income (on-chain payroll) and outgoing transfers are traced on-chain. Moving assets to another address leaves a public trail.
4. Seizure is ordered and carried out off-chain. For example, the employer is ordered to pay part of the salary to the creditor, which the employer does as an ordinary transfer.

**Rejected alternative:** a court-issued on-chain seizure order that the stablecoin itself executes. It would give the court power over every wallet and change the payment rail ([ADR 0004](../../decisions/0004-taxation-payment-rail.md)).

**Known limit:** assets held off-chain (cash, real estate), or moved through channels that break the trail, are not reached.

---

# 司法・紛争解決(日本語)

**ステータス: 🟢 設計確定。** オンチェーン価値テストで選別し、ユーザーとの議論で解決した。理由は[`discussion-log.md`](discussion-log.md)、正式な決定は[ADR 0018](../../decisions/0018-judiciary-model.md)を参照。コントラクトコードはまだない。

## 概要

司法の本体(手続き、審理、判断)はオフチェーンのままとする。3つの部分をオンチェーン化する、または追跡可能にする。

1. **証拠目録:** 警察と検察は、押収した各証拠を押収の時点で追記専用で登録する。後からの改ざんと開示されていない証拠を確認できるようになる。
2. **事件記録:** 裁判所は各記録を保存区分とともに登録し、廃棄も登録しなければならない。2022年に判明したような不当な破棄が見えるようになる。判決はこの種の記録であり、司法インフラの項目「判決等の公開」をここに吸収する。
3. **判決の執行:** 債務者のオンチェーン資産を、裁判所と債権者が特定できるようにする。差押えそのものはオフチェーンで行い、ステーブルコインに裁判所の権限は持たせない。

## スコープ

**対象:** 上の3つの部分。

**対象外:**
- 訴訟手続: 民事訴訟のIT化がすでにある(🚫)。
- 審理・判断: 制度の問題(🚫)。
- 前科の記録: プライバシー。現在も公開されておらず、公開すべきでもない(🚫)。
- **トークン陪審員による仲裁**(Kleros型の判断に公的な効力を与えること): 🚫。トークンの保有量で判断の重みが決まり、陪審員は匿名で責任を負わず、投機的なトークンに依存するため。
- 購入時の、国が運営するエスクローの紛争処理: 日常の商取引の項目に移す。
- 最高裁判所裁判官の国民審査: すでに[投票](../voting/)で扱える。
- 公証・契約証明: 司法インフラの独立した項目のままとする。

## オンチェーン/オンライン/オフラインの内訳

(区分の考え方は[`docs/operations/README.md`](../../operations/README.md)を参照。)

**オンチェーン:**
- 捜査機関(各都道府県警察本部、各検察庁)ごとに1つの`EvidenceRegistry`。
- 裁判所ごとに1つの`CaseRecordRegistry`。
- 執行: 新しいものはない。すでに公開されている支払いの流れをたどる。

**オンライン:**
- 各機関は、自らの`.go.jp`/`.lg.jp`ドメインでレジストリのアドレスを公表する。行政の`DocumentRegistry`([ADR 0017](../../decisions/0017-executive-document-anchoring-v1.md))と同じ証明の仕組みである。

**オフライン:**
- 証拠と記録そのもの、およびその保管。
- 秘匿化した事件参照と略称の説明のルール、および起訴の時点での事件参照の対応関係の裁判所・弁護側への開示。
- 記録の保存区分を下げるという裁判所の判断。
- 執行: 裁判所の命令、自治体による債務者の`ResidentLink`アドレスの開示、差押えそのもの(たとえば、給与の一部を債権者に支払うよう雇用主に命じる)。

## アーキテクチャ

### `EvidenceRegistry`(捜査機関ごとに1つ)

行政の`DocumentRegistry`の仕組みを証拠に適用したもの。

- **管理者:** 機関のマルチシグ。
- **`register(caseRef, itemType, description, itemHash, previousId) → id`:** 押収の時点で呼び出す。追記専用で、訂正は前の登録を参照する新しい登録になる。
  - `caseRef`: **秘匿化した事件参照**。内部の事件番号を秘密のソルトとともにハッシュ化したもの。一般の読み手には、どの事件・どの被疑者かは分からない(Round 3の調整)。
  - `itemType`: `Physical`(ハッシュはその写真のもの)、`Data`(データそのもののハッシュ)、`InterrogationRecording`(Round 3の調整)。
  - `description`: 行政の機微な名称と同じく、ルールに基づく、それとは分からない略称。
- **`recordStatus(id, status)`:** `Returned`(所有者に返還)または`Destroyed`。イベントを発行する。登録そのものは決して削除しない。
- **得られるもの:** 起訴の時点で、検察は`caseRef`の対応関係を裁判所と弁護側に開示する。両者は、押収したすべての証拠が載っていること、押収後に差し替えられていないこと(ハッシュの一致)、載っている証拠で開示されていないものがないことを確認できる。
- **既知の限界:** 押収*前*の捏造(仕込まれた証拠など)は検出できない。

### `CaseRecordRegistry`(裁判所ごとに1つ)

- **管理者:** 裁判所のマルチシグ。
- **`register(caseRef, recordType, recordHash, retentionClass, previousId) → id`:** `recordType`には`Judgment`を含む。後で公開された(匿名化された)判決を、登録済みの原本と結びつけられる。`retentionClass`: `Standard`、`SpecialPreservation`、`Permanent`。日付は持たない。
- **`reclassify(id, newClass)`:** 公開のイベント。
- **`dispose(id)`:** 廃棄を記録する。**`SpecialPreservation`と`Permanent`に対しては拒否する。** まず区分を下げる必要があり、それが公開の痕跡を残す(Round 3の調整)。
- **既知の限界:** ハッシュは中身を残さない。中身そのものの保存(暗号化した永続的な保存など)は[`docs/BACKLOG.md`](../../BACKLOG.md)で管理する。

### 判決の執行(新しいコントラクトなし)

1. 判決を得た債権者が裁判所に申し立てる(オフチェーン)。
2. 裁判所は、債務者の自治体に、債務者の`ResidentLink`アドレスを裁判所と債権者に開示するよう命じる(オフチェーン)。献金者の追跡([ADR 0015](../../decisions/0015-political-donations-model.md))と同じ、法的手続きによる特定である。法人のアドレスはすでに公開されている。
3. 債務者の残高、収入(オンチェーンの給与)、送金先をオンチェーンでたどる。資産を別のアドレスに移しても公開の痕跡が残る。
4. 差押えはオフチェーンで命じられ、実行される。たとえば、雇用主が給与の一部を債権者に支払うよう命じられ、通常の送金として支払う。

**採用しなかった案:** 裁判所が発するオンチェーンの差押え命令を、ステーブルコイン自体が実行する案。裁判所にすべてのウォレットに対する権限を与え、決済レール([ADR 0004](../../decisions/0004-taxation-payment-rail.md))を変えることになる。

**既知の限界:** オフチェーンで保有する資産(現金、不動産)や、痕跡を断つ経路で移された資産には届かない。

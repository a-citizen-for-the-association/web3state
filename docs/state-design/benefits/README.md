# Benefits (児童手当・生活保護等)

**Status: 🟢 Spec drafted.** Screened with the on-chain value test and resolved through discussion with the user; see [`discussion-log.md`](discussion-log.md) for the reasoning and [ADR 0025](../../decisions/0025-benefits-model.md) for the formal decision. No contract code written yet.

## Summary

**No new contract.** A benefit is a private decision, anchored by hash, plus treasury payments to the recipient's own `ResidentLink` address. Paying to the person's own address removes "wrong account" errors and makes every payment verifiable by the recipient. **All social-security payments to individuals share one generic budget code,** so a payment shows only "social security from body X", not whether the recipient is on public assistance, disabled or a single parent. Income checks for public assistance read the recipient's on-chain inflows, with consent, instead of relying only on monthly self-reports.

## Scope

**In scope:** cash benefits paid to individuals by public bodies: child allowance (児童手当), child-rearing allowance (児童扶養手当), disability allowances, the cash parts of public assistance (生活保護: living, housing, education and similar assistance), and one-off universal payments.

**Out of scope:**
- Medical and long-term-care assistance: paid to providers through the medical-claims system ([`docs/BACKLOG.md`](../../BACKLOG.md)).
- Unemployment insurance: separate item.
- In-kind services, and benefit policy itself (amounts, criteria).

## On-chain / Online / Offline breakdown

(See [`docs/operations/README.md`](../../operations/README.md) for the convention.)

**On-chain (all existing):**
- Payments: `pay()` from the paying body's `PublicTreasury` ([ADR 0019](../../decisions/0019-treasury-model.md)) to the recipient's `ResidentLink` address, with the shared social-security budget code.
- Housing assistance paid directly to the landlord (代理納付): an ordinary `pay()` to the landlord's registered address, with the same code.
- Universal payments: batches of `pay()` by each municipality to its own residents, with their own budget code.
- Hashes of eligibility, award, change and termination decisions, in the paying body's `DocumentRegistry` ([ADR 0017](../../decisions/0017-executive-document-anchoring-v1.md)).

**Online:**
- Monthly totals per kind of benefit, per paying body.

**Offline:**
- Applications, eligibility and means tests; the child's residence and household, from the resident register.
- Income checks for applicants and recipients, from the address's public inflows, with consent (below).
- Detection of poverty businesses: operators whose income consists mostly of many recipients' assistance.
- Duplicate checks between municipalities, using their own private records.
- Repayment and penalties when fraud is found.

## Rules

1. **Payee is the person's own address.** Benefits are paid only to the recipient's `ResidentLink` address (or, for housing assistance, to the landlord). A registered death burns the `ResidentLink`, and later payments revert.
2. **One shared budget code for all social-security payments to individuals:** pension ([ADR 0024](../../decisions/0024-pension-model.md)), every benefit, and later unemployment insurance. The kind is in the private, anchored decision.
3. **Universal payments use their own code,** since they reveal nothing about the recipient (Round 2 adjustment).
4. **Per-kind totals are published monthly per paying body,** so each programme stays auditable (Round 2 adjustment).
5. **Income analysis only with consent, only for applicants and recipients,** covering the application and receipt period (plus the legal period for investigating overpayments). The state does not routinely analyse residents' finances to find possible recipients (Issue 4(a), Round 2 adjustment).
6. **Children need no `ResidentLink`.** Child-related eligibility is decided off-chain from the resident register.
7. **No on-chain mechanism** for duplicates, poverty businesses or unreported income: all off-chain analysis of public data.

## Known limits

- Amounts and timing can still hint at the kind of benefit; the address being pseudonymous is the remaining protection.
- Cash earnings stay invisible, as today.
- Under-take-up and stigma are social problems; the design only avoids making them worse.
- Whether a poverty business is exploitative is a judgement; the chain only shows the flows.

---

# 各種手当(児童手当・生活保護等)(日本語)

**ステータス: 🟢 設計確定。** オンチェーン価値テストで選別し、ユーザーとの議論で解決した。理由は[`discussion-log.md`](discussion-log.md)、正式な決定は[ADR 0025](../../decisions/0025-benefits-model.md)を参照。コントラクトコードはまだない。

## 概要

**新しいコントラクトは作らない。** 給付は、ハッシュでアンカリングした非公開の決定と、受給者本人の`ResidentLink`アドレスへの国庫の支払いでできている。本人のアドレスに支払うので「誤った口座」はなくなり、すべての支払いを受給者が確認できる。**個人への社会保障の支払いはすべて共通の予算コードを1つ使う**ので、支払いからわかるのは「機関Xからの社会保障」だけで、受給者が生活保護を受けているか、障害があるか、ひとり親かはわからない。生活保護の収入確認では、毎月の自己申告だけに頼らず、同意を得て受給者のオンチェーンの入金を読む。

## スコープ

**対象:** 公的機関が個人に支払う現金給付。児童手当、児童扶養手当、障害者向けの手当、生活保護の現金部分(生活扶助、住宅扶助、教育扶助など)、一時的な一律給付。

**対象外:**
- 医療扶助・介護扶助: 診療報酬の仕組みを通じて提供者に支払われる([`docs/BACKLOG.md`](../../BACKLOG.md))。
- 雇用保険: 別項目。
- 現物のサービス、給付の政策そのもの(金額、基準)。

## オンチェーン/オンライン/オフラインの内訳

(区分の考え方は[`docs/operations/README.md`](../../operations/README.md)を参照。)

**オンチェーン(すべて既存):**
- 支払い: 支払う機関の`PublicTreasury`([ADR 0019](../../decisions/0019-treasury-model.md))から受給者の`ResidentLink`アドレスへの`pay()`。社会保障の共通予算コードを使う。
- 家主に直接支払う住宅扶助(代理納付): 家主の登録済みアドレスへの通常の`pay()`。同じコードを使う。
- 一律給付: 各市区町村が自らの住民へまとめて実行する`pay()`。独自の予算コードを使う。
- 受給資格、決定、変更、廃止の決定のハッシュ。支払う機関の`DocumentRegistry`([ADR 0017](../../decisions/0017-executive-document-anchoring-v1.md))に記録する。

**オンライン:**
- 支払う機関ごとの、給付の種類ごとの毎月の合計。

**オフライン:**
- 申請、受給資格、資力調査。子どもの居住と世帯は住民基本台帳から判断する。
- 申請者と受給者の収入確認。アドレスの公開された入金から、同意に基づいて行う(下記)。
- 貧困ビジネスの検出: 多数の受給者の保護費が収入の大半を占める事業者。
- 市区町村間の重複の確認。各市区町村の非公開の記録を使う。
- 不正が見つかった場合の返還と罰則。

## ルール

1. **支払先は本人のアドレス。** 給付は受給者の`ResidentLink`アドレス(住宅扶助の場合は家主)にだけ支払う。届出済みの死亡で`ResidentLink`がburnされ、その後の支払いはrevertする。
2. **個人への社会保障の支払いはすべて共通の予算コードを1つ使う:** 年金([ADR 0024](../../decisions/0024-pension-model.md))、すべての給付、後の雇用保険。種類は非公開のアンカーされた決定に記載する。
3. **一律給付は独自のコードを使う。** 受給者について何も明かさないため(Round 2の調整)。
4. **種類ごとの合計を、支払う機関ごとに毎月公表する。** 各制度を監査できるようにする(Round 2の調整)。
5. **収入の分析は同意がある場合に限り、申請者と受給者だけを対象とする。** 期間は申請から受給まで(と、過払いの調査のための法定の期間)。受給資格がありそうな人を見つけるために、国が住民の財務を日常的に分析することはしない(論点4(a)、Round 2の調整)。
6. **子どもに`ResidentLink`は求めない。** 子どもに関する受給資格は住民基本台帳からオフチェーンで判断する。
7. **重複、貧困ビジネス、収入の未申告にオンチェーンの仕組みは作らない。** すべて公開データのオフチェーン分析で扱う。

## 既知の限界

- 金額や時期から給付の種類が推測できる余地は残る。残る保護は、アドレスが仮名であることである。
- 現金での稼働収入は、今と同じく見えない。
- 捕捉率とスティグマは社会の問題であり、この設計はそれを悪化させないことしかできない。
- 貧困ビジネスが搾取的かどうかは判断の問題で、チェーンが示すのは流れだけである。

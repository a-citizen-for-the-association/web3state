# Executive / administration (行政) — v1: approval-document anchoring

**Status: 🟢 Spec drafted (minimal v1).** See [`discussion-log.md`](discussion-log.md) for the screening and reasoning, and [ADR 0017](../../decisions/0017-executive-document-anchoring-v1.md) for the formal decision. No contract code written yet. This is deliberately a first version, to be revisited after implementation and scenario testing. Amended by [ADR 0032](../../decisions/0032-consistency-review-decisions.md): the per-agency `DocumentRegistry` is replaced by the kind `ApprovalDocument` of the shared `AnchorRegistry` (consistency review R4.1).

## Summary

Every agency must register, on-chain, the **title and hash** of each approval document (決裁文書) it produces. The document itself stays off-chain. If the document is later disclosed, anyone can hash it and compare: a document rewritten after approval, as in the 2018 Moritomo case, no longer matches its registered hash.

**Goal, precisely stated:** make rewriting an approved document after the fact detectable. Not creating a record, and falsifying it at creation, are **not** addressed in v1 (see [Known limits](#known-limits)).

## Scope

**In scope:** approval documents of every agency (ministries, prefectures, municipalities, other public bodies).

**Deferred to the redesign phase** (tracked in [`docs/BACKLOG.md`](../../BACKLOG.md)):
- Making registration a validity condition ("no anchor, no effect").
- Other document types beyond approval documents.
- Statistics: anchoring raw data, and computing statistics directly from on-chain data.
- Linking information disclosure requests to registered hashes.
- A registry of individual officials' roles and authority.

**Out of the executive item entirely:** taxation, spending, procurement, subsidies, benefits, credentials, vital records and the real estate registry, which are separate items in [`docs/FEATURES.md`](../../FEATURES.md).

## On-chain / Online / Offline breakdown

(See [`docs/operations/README.md`](../../operations/README.md) for the convention.)

**On-chain:**
- Anchors of kind `ApprovalDocument` in the shared, event-only `AnchorRegistry` ([personal data](../personal-data/README.md); kind list in the [certified-stablecoin spec](../certified-stablecoin/README.md)). Each anchor event carries the title, the document hash, and a reference to the previous version (`previousId`, if any). Nothing is stored in the contract; the block of the event gives its time (consistency review R4.1, [ADR 0032](../../decisions/0032-consistency-review-decisions.md)).
- Each agency's controlling multisig, registered in `OfficialContractRegistry` as a public body's controlling multisig, so that `AnchorRegistry` accepts it (consistency review R1.4, [ADR 0032](../../decisions/0032-consistency-review-decisions.md)).

**Online:**
- Each agency publishes the address of its controlling multisig under its own `.go.jp`/`.lg.jp` domain. This is how anyone tells the agency's genuine anchors from a look-alike's, the same attestation pattern as earlier designs.

**Offline:**
- The obligation to register each approval document at approval time. Enforcement of the obligation is off-chain.
- The abbreviation rule for sensitive titles.
- Keeping the documents themselves (existing records management) and disclosing them.
- Comparing a disclosed document against its registered hash: anyone can do this.

## Architecture

### Approval-document anchors (`AnchorRegistry`, kind `ApprovalDocument`)

`DocumentRegistry` is no longer a separate contract: approval documents are one kind of the shared, event-only `AnchorRegistry` (consistency review R4.1, [ADR 0032](../../decisions/0032-consistency-review-decisions.md)). As with every anchor, nobody needs to read them from a contract, so nothing is stored.

- **Caller:** the agency that made the document anchors it itself, from its registered controlling multisig (the audited multisig standard is already a backlog item) (consistency review R1.4, R4.2, [ADR 0032](../../decisions/0032-consistency-review-decisions.md)).
- **Anchor event:** kind `ApprovalDocument`, with the title, the document hash and `previousId`: none for a first version, or the version it corrects, carried in the event. Anchors are **append-only**: there is no update or delete, so a correction is a new anchor and the revision history is public.
- **Reading:** the event log, filtered by the agency's published address and the kind.

### Sensitive titles

If a title itself is sensitive (e.g. it contains a personal name or a classified matter), the agency registers a **non-identifying abbreviation following a fixed rule** instead of the real title. The rule is defined off-chain. The hash is registered as normal, so the document can still be matched once it is disclosed.

### Registry entry for the anchoring address

`OfficialContractRegistry` ([ADR 0015](../../decisions/0015-political-donations-model.md)) exists for **automated** contract-to-contract checks. v1 first had no entry for a per-agency `DocumentRegistry`, since nothing consumed it automatically. With the shared `AnchorRegistry`, the automated check is `anchor` itself: it accepts any registered address, so the agency's controlling multisig is registered as a public body's controlling multisig (consistency review R1.4, [ADR 0032](../../decisions/0032-consistency-review-decisions.md)). People still tell which agency made an anchor from the address it publishes under its own domain.

## Known limits

- **Non-creation and false creation are not detected.** The chain proves only that a document has not changed since it was registered. If an agency never registers a document, or registers one that was false from the start, v1 cannot show it. The candidate fix ("no anchor, no effect") is deferred to the redesign phase.
- **Only the agency is recorded, not the individual approver.** The official-authority registry is deferred.
- **Matching requires disclosure.** The hash proves nothing about a document's content until the document itself is seen.

---

# 行政 — 第1版: 決裁文書のアンカリング(日本語)

**ステータス: 🟢 設計確定(最小の第1版)。** 選別と理由は[`discussion-log.md`](discussion-log.md)、正式な決定は[ADR 0017](../../decisions/0017-executive-document-anchoring-v1.md)を参照。コントラクトコードはまだない。これは意図的に第1版としており、実装とシナリオテストの後に見直す。[ADR 0032](../../decisions/0032-consistency-review-decisions.md)で修正: 行政機関ごとの`DocumentRegistry`は、共有の`AnchorRegistry`の種類`ApprovalDocument`に置き換える(整合性レビューR4.1)。

## 概要

すべての行政機関は、作成した決裁文書ごとに、その**名称とハッシュ**をオンチェーンに登録しなければならない。文書そのものはオフチェーンに置く。後で文書が開示されれば、誰でもハッシュを計算して照合できる。2018年の森友学園の件のように決裁後に書き換えられた文書は、登録されたハッシュと一致しなくなる。

**目的を正確に言うと:** 決裁済みの文書を後から書き換えたことを検出できるようにする。記録を作らないこと、作成の時点で偽ることは、第1版では扱わ**ない**([既知の限界](#既知の限界)を参照)。

## スコープ

**対象:** すべての行政機関(省庁、都道府県、市区町村、その他の公的機関)の決裁文書。

**再設計の段階に先送り**([`docs/BACKLOG.md`](../../BACKLOG.md)で管理):
- 登録を効力の条件にすること(「アンカーなしでは効力なし」)。
- 決裁文書以外の種類の文書。
- 統計: 原データのアンカリングと、オンチェーンデータからの統計の直接計算。
- 情報公開請求と登録済みハッシュの連携。
- 職員個人の役職と権限のレジストリ。

**行政の項目からそもそも外れるもの:** 納税、歳出、公共調達、補助金、給付、公的証明、戸籍等、不動産登記。これらは[`docs/FEATURES.md`](../../FEATURES.md)の別項目である。

## オンチェーン/オンライン/オフラインの内訳

(区分の考え方は[`docs/operations/README.md`](../../operations/README.md)を参照。)

**オンチェーン:**
- 共有の、イベントだけの`AnchorRegistry`([個人情報](../personal-data/README.md)。種類の一覧は[認定ステーブルコインの仕様](../certified-stablecoin/README.md))に、種類`ApprovalDocument`で記録するアンカー。各アンカーのイベントは、名称、文書のハッシュ、前の版への参照(`previousId`、あれば)を含む。コントラクトには何も保存しない。イベントのブロックが時刻を示す(整合性レビューR4.1、[ADR 0032](../../decisions/0032-consistency-review-decisions.md))。
- 各機関の管理用マルチシグ。`AnchorRegistry`が受け付けるよう、公的機関の管理用マルチシグとして`OfficialContractRegistry`に登録する(整合性レビューR1.4、[ADR 0032](../../decisions/0032-consistency-review-decisions.md))。

**オンライン:**
- 各機関は、自らの`.go.jp`/`.lg.jp`ドメインで管理用マルチシグのアドレスを公表する。誰でもこれで、その機関の本物のアンカーとよく似た偽物のアンカーを見分けられる。これまでの設計と同じ証明の仕組みである。

**オフライン:**
- 決裁の時点で各決裁文書を登録する義務。義務の執行はオフチェーンで行う。
- 機微な名称のための略称のルール。
- 文書そのものの保管(既存の文書管理)と開示。
- 開示された文書と登録済みハッシュの照合: 誰でもできる。

## アーキテクチャ

### 決裁文書のアンカー(`AnchorRegistry`、種類`ApprovalDocument`)

`DocumentRegistry`はもう独立したコントラクトではない。決裁文書は、共有の、イベントだけの`AnchorRegistry`の1つの種類である(整合性レビューR4.1、[ADR 0032](../../decisions/0032-consistency-review-decisions.md))。ほかのアンカーと同じく、コントラクトから読む者はいないので、何も保存しない。

- **呼び出し元:** 文書を作った機関が、登録済みの管理用マルチシグから自らアンカーする(監査済みマルチシグ規格の選定はすでにBACKLOG項目にある)(整合性レビューR1.4、R4.2、[ADR 0032](../../decisions/0032-consistency-review-decisions.md))。
- **アンカーのイベント:** 種類`ApprovalDocument`で、名称、文書のハッシュ、`previousId`を含む。`previousId`は初版ならなし、訂正する場合はその版を指し、イベントに含める。アンカーは**追記のみ**で、更新も削除もない。訂正は新しいアンカーになり、改訂の履歴が公開される。
- **読み取り:** イベントログ。機関の公表アドレスと種類で絞り込む。

### 機微な名称

名称そのものが機微な場合(個人名や秘密指定の事項を含むなど)、機関は実際の名称の代わりに、**一定のルールに従った、それとは分からない略称**を登録する。ルールはオフチェーンで定める。ハッシュは通常どおり登録するので、文書が開示されれば照合できる。

### アンカーするアドレスのレジストリへの登録

`OfficialContractRegistry`([ADR 0015](../../decisions/0015-political-donations-model.md))は、コントラクト間の**自動**検証のためにある。第1版では当初、行政機関ごとの`DocumentRegistry`を自動で利用するコントラクトがなかったので、登録しなかった。共有の`AnchorRegistry`では、`anchor`そのものが自動の検証になる。登録済みのアドレスなら誰でも受け付けるので、機関の管理用マルチシグを公的機関の管理用マルチシグとして登録する(整合性レビューR1.4、[ADR 0032](../../decisions/0032-consistency-review-decisions.md))。どの機関のアンカーかは、引き続き、機関が自らのドメインで公表するアドレスで見分ける。

## 既知の限界

- **記録を作らないこと、偽って作ることは検出できない。** チェーンが証明するのは、登録後に文書が変わっていないことだけである。機関が文書を登録しない場合や、最初から偽りの文書を登録した場合、第1版では示せない。対策の候補(「アンカーなしでは効力なし」)は再設計の段階に先送りする。
- **記録されるのは機関であり、個々の承認者ではない。** 行政の権限レジストリは先送りする。
- **照合には開示が必要。** 文書そのものが見られるまで、ハッシュは内容について何も証明しない。

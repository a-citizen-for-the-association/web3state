# Executive / administration (行政) — v1: approval-document anchoring

**Status: 🟢 Spec drafted (minimal v1).** See [`discussion-log.md`](discussion-log.md) for the screening and reasoning, and [ADR 0017](../../decisions/0017-executive-document-anchoring-v1.md) for the formal decision. No contract code written yet. This is deliberately a first version, to be revisited after implementation and scenario testing.

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
- One `DocumentRegistry` contract per agency, holding each registration: title, document hash, and a reference to the previous version (if any). The block of the registration event gives its time; no date field is stored.

**Online:**
- Each agency publishes its `DocumentRegistry` address under its own `.go.jp`/`.lg.jp` domain. This is how anyone tells a genuine registry from a look-alike, the same attestation pattern as earlier designs.

**Offline:**
- The obligation to register each approval document at approval time. Enforcement of the obligation is off-chain.
- The abbreviation rule for sensitive titles.
- Keeping the documents themselves (existing records management) and disclosing them.
- Comparing a disclosed document against its registered hash: anyone can do this.

## Architecture

### `DocumentRegistry` (one per agency)

- **Controller:** the agency's multisig (the audited multisig standard is already a backlog item).
- **`register(title, docHash, previousId) → id`:** controller only. `previousId` is `0` for a first version, or the id of the version it corrects. Appends a record and emits `DocumentRegistered(id, title, docHash, previousId)`. Records are **append-only**: there is no update or delete, so a correction is a new registration and the revision history is public.
- **Reading:** `recordOf(id)`, and the event log for full history.

### Sensitive titles

If a title itself is sensitive (e.g. it contains a personal name or a classified matter), the agency registers a **non-identifying abbreviation following a fixed rule** instead of the real title. The rule is defined off-chain. The hash is registered as normal, so the document can still be matched once it is disclosed.

### Why no on-chain registry entry

`OfficialContractRegistry` ([ADR 0015](../../decisions/0015-political-donations-model.md)) exists for **automated** contract-to-contract checks. No contract consumes a `DocumentRegistry` automatically in v1; people check it against the agency's published address. Following [ADR 0003](../../decisions/0003-resident-link-identity-model.md), the off-chain attestation is enough until an automated consumer appears.

## Known limits

- **Non-creation and false creation are not detected.** The chain proves only that a document has not changed since it was registered. If an agency never registers a document, or registers one that was false from the start, v1 cannot show it. The candidate fix ("no anchor, no effect") is deferred to the redesign phase.
- **Only the agency is recorded, not the individual approver.** The official-authority registry is deferred.
- **Matching requires disclosure.** The hash proves nothing about a document's content until the document itself is seen.

---

# 行政 — 第1版: 決裁文書のアンカリング(日本語)

**ステータス: 🟢 設計確定(最小の第1版)。** 選別と理由は[`discussion-log.md`](discussion-log.md)、正式な決定は[ADR 0017](../../decisions/0017-executive-document-anchoring-v1.md)を参照。コントラクトコードはまだない。これは意図的に第1版としており、実装とシナリオテストの後に見直す。

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
- 行政機関ごとに1つの`DocumentRegistry`コントラクト。各登録の名称、文書のハッシュ、前の版への参照(あれば)を持つ。登録イベントのブロックが時刻を示すので、日付フィールドは持たない。

**オンライン:**
- 各機関は、自らの`.go.jp`/`.lg.jp`ドメインで`DocumentRegistry`のアドレスを公表する。誰でもこれで本物のレジストリとよく似た偽物を見分けられる。これまでの設計と同じ証明の仕組みである。

**オフライン:**
- 決裁の時点で各決裁文書を登録する義務。義務の執行はオフチェーンで行う。
- 機微な名称のための略称のルール。
- 文書そのものの保管(既存の文書管理)と開示。
- 開示された文書と登録済みハッシュの照合: 誰でもできる。

## アーキテクチャ

### `DocumentRegistry`(行政機関ごとに1つ)

- **管理者:** 機関のマルチシグ(監査済みマルチシグ規格の選定はすでにBACKLOG項目にある)。
- **`register(title, docHash, previousId) → id`:** 管理者のみ。`previousId`は初版なら`0`、訂正する場合はその版のid。記録を追加し、`DocumentRegistered(id, title, docHash, previousId)`を発行する。記録は**追記のみ**で、更新も削除もない。訂正は新しい登録になり、改訂の履歴が公開される。
- **読み取り:** `recordOf(id)`。全履歴はイベントログで見る。

### 機微な名称

名称そのものが機微な場合(個人名や秘密指定の事項を含むなど)、機関は実際の名称の代わりに、**一定のルールに従った、それとは分からない略称**を登録する。ルールはオフチェーンで定める。ハッシュは通常どおり登録するので、文書が開示されれば照合できる。

### オンチェーンのレジストリに載せない理由

`OfficialContractRegistry`([ADR 0015](../../decisions/0015-political-donations-model.md))は、コントラクト間の**自動**検証のためにある。第1版では`DocumentRegistry`を自動で利用するコントラクトはなく、人が機関の公表アドレスと照らして確認する。[ADR 0003](../../decisions/0003-resident-link-identity-model.md)に従い、自動の利用者が現れるまではオフチェーンの証明で足りる。

## 既知の限界

- **記録を作らないこと、偽って作ることは検出できない。** チェーンが証明するのは、登録後に文書が変わっていないことだけである。機関が文書を登録しない場合や、最初から偽りの文書を登録した場合、第1版では示せない。対策の候補(「アンカーなしでは効力なし」)は再設計の段階に先送りする。
- **記録されるのは機関であり、個々の承認者ではない。** 行政の権限レジストリは先送りする。
- **照合には開示が必要。** 文書そのものが見られるまで、ハッシュは内容について何も証明しない。

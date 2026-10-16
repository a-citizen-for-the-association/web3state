# 0017. Executive v1: mandatory title-and-hash registration of approval documents; iterate after implementation

**Date:** 2026-10-17
**Status:** Accepted

## Context

After direct-demand petitions ([ADR 0016](0016-direct-demand-petition-model.md)), the executive was screened with the on-chain value test ([ADR 0014](0014-legislative-process-scope.md)). Many executive activities are already separate items (taxation, spending, procurement, benefits, credentials, registries). What remained was how the administration makes, keeps and discloses its own records. Three candidates passed: official documents and approval records (the 2018 Moritomo document rewriting and similar cases), raw statistical data (the 毎月勤労統計 and construction-orders cases), and information disclosure. An official-authority registry was judged infrastructure rather than a state function. Permits, public comment, guidance, personnel and cabinet minutes did not pass.

A chain can only prove a record has not changed since it was anchored. Preventing non-creation would need anchoring to be a validity condition. The user judged the full problem too hard to settle on paper, and noted that not everything can go on-chain from the start ([log](../state-design/executive/discussion-log.md)).

## Decision

- **v1 scope:** every agency must register the **title and hash** of each **approval document** (決裁文書) in its own append-only `DocumentRegistry`. Corrections are new registrations that reference the previous version. Authenticity is checked through the agency's `.go.jp`/`.lg.jp` publication; no `OfficialContractRegistry` entry is needed yet.
- **Sensitive titles** are replaced by a non-identifying abbreviation following a fixed, off-chain rule.
- **Deferred, not excluded:** "no anchor, no effect"; other document types; statistics; information-disclosure linkage; the official-authority registry. These go to the backlog for the redesign phase, rather than becoming 🚫 exclusions.
- **Workflow change:** the project moves from "resolve everything on paper first" to **initial design → implementation → scenario tests → find issues → redesign**. The initial design still covers **every item in `docs/FEATURES.md`**; then the cross-feature consistency review, then implementation. *(Corrected 2026-10-17: an earlier wording of this ADR said the initial design would stop after Governance Core and leave the remaining 🔴 items until after the first cycle. That misrecorded the user's decision; the user confirmed that all listed items are designed first.)*

## Consequences

- Rewriting an approved document after the fact becomes detectable once the document is disclosed. Non-creation and false creation are knowingly not addressed in v1.
- The executive item stays small and cheap to implement, which is the point: scenario tests will show which deferred piece matters most.
- The 2026-10-03 workflow decision (design everything first, then review, then implement) still holds. What is new is that hard parts of a function may be deferred to the redesign phase after scenario tests, as done here.

---

# 0017. 行政の第1版: 決裁文書の名称とハッシュの登録を義務付ける。実装の後で反復する(日本語)

**日付:** 2026-10-17
**ステータス:** Accepted

## 背景

直接請求の署名([ADR 0016](0016-direct-demand-petition-model.md))の後、行政をオンチェーン価値テスト([ADR 0014](0014-legislative-process-scope.md))で選別した。行政の活動の多くはすでに別項目である(納税、歳出、調達、給付、公的証明、登記など)。残ったのは、行政が自らの記録をどう作り、保管し、開示するかである。3つの候補が通過した: 公文書・決裁記録(2018年の森友学園の文書改ざんなど)、統計の原データ(毎月勤労統計や建設工事受注統計の件)、情報公開。行政の権限レジストリは、国家機能ではなく基盤と判断した。許認可、パブリックコメント、行政指導、人事、閣議議事録は通過しなかった。

チェーンが証明できるのは、記録がアンカーされた後に変わっていないことだけである。記録を作らないことを防ぐには、アンカーを効力の条件にする必要がある。ユーザーは、問題全体を机上で決めきるのは難しすぎると判断し、最初からすべてをオンチェーン化することはできないと述べた([ログ](../state-design/executive/discussion-log.md))。

## 決定

- **第1版の範囲:** すべての行政機関は、各**決裁文書**の**名称とハッシュ**を、自らの追記専用の`DocumentRegistry`に登録しなければならない。訂正は前の版を参照する新しい登録とする。本物かどうかは機関の`.go.jp`/`.lg.jp`での公表で確認する。`OfficialContractRegistry`への登録はまだ必要ない。
- **機微な名称**は、オフチェーンで定める一定のルールに従った、それとは分からない略称に置き換える。
- **対象外ではなく先送り:** 「アンカーなしでは効力なし」、その他の種類の文書、統計、情報公開との連携、行政の権限レジストリ。これらは🚫対象外にはせず、再設計の段階に向けてBACKLOGに入れる。
- **進め方の変更:** プロジェクトは「すべてを先に机上で解決する」から、**初期設計 → 実装 → シナリオテスト → 課題の発見 → 再設計**に移る。初期設計は引き続き**`docs/FEATURES.md`のすべての項目**を対象とする。その後に機能間の整合性レビュー、そして実装に入る。*(2026-10-17訂正: このADRの以前の文言は、初期設計を統治の中核までで終え、残りの🔴項目を最初の一巡の後に回すとしていた。これはユーザーの決定を誤って記録したものであり、ユーザーは掲げた項目すべてを先に設計すると確認した。)*

## 結果

- 決裁済みの文書を後から書き換えたことは、文書が開示されれば検出できるようになる。記録を作らないこと、偽って作ることは、第1版では承知のうえで扱わない。
- 行政の項目は小さく、実装のコストも低い。それが狙いである: どの先送り項目が最も重要かは、シナリオテストで明らかになる。
- 2026-10-03の進め方の決定(すべてを先に設計し、レビューしてから実装する)は引き続き有効である。新しいのは、機能の難しい部分を、シナリオテスト後の再設計の段階に先送りできるようになった点で、今回の行政がその例である。

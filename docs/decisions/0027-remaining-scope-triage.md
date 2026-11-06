# 0027. Remaining scope triage: design only high-value items now, put the rest on hold, add personal-data protection

**Date:** 2026-11-07
**Status:** Accepted

## Context

After Social Welfare was completed ([ADR 0026](0026-unemployment-insurance-model.md)), eleven 🔴 items remained. The user, tiring of the pace, asked whether they could be split into items where a blockchain helps a great deal and items where it adds little, so that only the former are designed now. Until now the rule was to design every listed item before any implementation (2026-10-03, reaffirmed 2026-10-17).

Claude's assessment: earlier designs, above all the certified-address rule ([ADR 0020](0020-certified-address-stablecoin.md)), already make every JPY flow of corporations, NPOs, donors and merchants traceable. For most remaining items the extra value of a dedicated design is small. Two items still solve real problems that only a chain solves well: impersonation of owners and unknown owners in the **real estate registry**, and the **securities** record, which the user explicitly wants and which closes the VIP-disclosure and "glass-box corporation" gaps in [`docs/BACKLOG.md`](../BACKLOG.md).

The user also raised a new concern: security incidents involving personal data held by companies are now very frequent, and the user wants the project to address them with a blockchain.

## Decision

- **High value, designed now:** real estate registry; securities and shareholdings; **personal data held by companies** (new item, new category "Data Protection").
- **On hold (⏸, new status):** donations; social-purpose crowdfunding; NPO and public-interest corporation funds; vital records; public company disclosures; audit trails; notarization and contract timestamping; everyday commerce; wealth-focused financial services. Reasons are recorded per item in `docs/FEATURES.md`. They may be taken up on another occasion.
- **On-hold items no longer block implementation.** Implementation may start once the three high-value items are designed and the cross-feature consistency review is done. This replaces the earlier "design every listed item first" rule for these nine items only.

## Consequences

- The initial design phase ends sooner: three items remain, then the consistency review.
- On-hold items are visible (⏸ plus reasons), not dropped, consistent with [ADR 0012](0012-onchain-scope-philosophy.md)'s practice for exclusions. Unlike 🚫, ⏸ means "not decided against", only postponed.
- The personal-data item must be screened honestly: putting personal data on a public chain makes leaks permanent, so a chain can help only indirectly (e.g. letting companies prove facts without holding the data, or making access to data tamper-evidently logged).

---

# 0027. 残りのスコープの振り分け: 有益性の高い項目だけを今設計し、残りは保留とし、個人情報の保護を追加する(日本語)

**日付:** 2026-11-07
**ステータス:** Accepted

## 背景

社会保障が完了した後([ADR 0026](0026-unemployment-insurance-model.md))、🔴の項目は11件残っていた。ペースに疲れてきたユーザーは、ブロックチェーンが大いに役立つ項目とあまり意味のない項目に分け、前者だけを今設計できないかと尋ねた。これまでは、実装の前に掲げた項目をすべて設計するというルールだった(2026-10-03、2026-10-17に再確認)。

Claudeの評価: これまでの設計、とりわけ認定アドレス制([ADR 0020](0020-certified-address-stablecoin.md))によって、法人、NPO、寄付者、事業者の円の流れはすでにすべて追える。残りの項目の多くは、専用の設計で得られる追加の価値が小さい。2つの項目は、チェーンでなければうまく解決できない本物の問題をまだ解決する: **不動産登記**での所有者へのなりすましと所有者不明、そしてユーザーが明確に望み、[`docs/BACKLOG.md`](../BACKLOG.md)の要人の資産公開と「ガラス張りの法人」の抜け穴を閉じる**有価証券**の記録である。

ユーザーは新たな懸念も挙げた: 企業が持つ個人情報のセキュリティインシデントが近年きわめて多く、そこはブロックチェーンで対応したい。

## 決定

- **有益性が高く、今設計する:** 不動産登記、有価証券・株主の記録、**企業が保有する個人情報**(新しい項目、新しいカテゴリ「データ保護」)。
- **保留(⏸、新しいステータス):** 寄付、社会目的のクラウドファンディング、NPO法人・公益法人の資金管理、戸籍・婚姻・出生等、上場企業の開示書類、会計監査記録、公証・契約の証明、日常の商取引、富裕層向け金融サービス。理由は`docs/FEATURES.md`に項目ごとに記録する。別の機会に取り上げてよい。
- **保留の項目は実装の妨げにならない。** 有益性の高い3項目の設計と機能間の整合性レビューが済めば、実装を始めてよい。これは、これら9項目に限り、以前の「掲げた項目をすべて先に設計する」ルールを置き換える。

## 結果

- 初期設計のフェーズが早く終わる。残りは3項目と、その後の整合性レビューである。
- 保留の項目は削除されず目に見える形(⏸＋理由)で残る。対象外についての[ADR 0012](0012-onchain-scope-philosophy.md)のやり方と一致する。🚫と違い、⏸は「しないと決めた」のではなく、先送りしただけである。
- 個人情報の項目は正直に選別しなければならない。個人情報を公開チェーンに載せると漏洩が永久に残るので、チェーンが役立てるのは間接的な方法に限られる(例: 企業がデータを持たずに事実を証明できるようにする、データへのアクセスを改ざんが検知できる形で記録する)。

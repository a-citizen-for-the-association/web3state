# 0008. License credential: single possession-only contract, suspension and revocation both burn

**Date:** 2026-10-06
**Status:** Accepted. Amended by [ADR 0032](0032-consistency-review-decisions.md): re-issue after a recorded succession (R3.3); burn on death (R3.10).

## Context

Following diploma (ADR 0007), the third concrete instance of the general "credentials" pattern designed was the driver's license (運転免許証), issued by a prefectural 公安委員会. Discussion (see [`docs/state-design/credentials/license/discussion-log.md`](../state-design/credentials/license/discussion-log.md)) worked through trust-anchor (reusing `.lg.jp`, already established for prefectures), granularity, how to represent the real-world distinction between temporary suspension (停止) and permanent revocation (取消), renewal, and whether a `ResidentLink` precondition applies as it does for diploma.

Claude initially proposed one contract per vehicle class (mirroring diploma's per-faculty/degree granularity). The user revised this: a single physical license already manages multiple classes/conditions on one card today, so the on-chain credential should mirror that — a single contract proving only "holds an active license," with class/condition detail left entirely off-chain.

## Decision

- **Single contract per prefecture — no granularity by vehicle class or condition.** Unlike diploma's per-faculty/degree contracts, a `License` NFT proves only "the holder has an active driver's license," not which classes (普通, 中型, 大型, 二輪, etc.) or conditions (AT限定, 眼鏡等, etc.) — those stay entirely in 公安委員会's own off-chain records.
- **Trust-anchor: `.lg.jp`**, since 公安委員会 is a prefectural body — no new mechanism, reusing what taxation (ADR 0004) already established for prefectures.
- **Suspension (停止) and revocation (取消) are both represented identically on-chain as a burn.** No on-chain status field distinguishes "temporarily suspended, will resume automatically" from "permanently revoked, requires a fresh application" — that real-world legal distinction, and the conditions under which re-issuance is possible, stay off-chain, consistent with this project's established practice of keeping revocation *reasons* off-chain (citizenship, corporations, passport, diploma all do this).
- **Renewal is modeled as burn-and-reissue**, same as passport — no on-chain expiry date.
- **Minting requires the recipient to hold a valid `ResidentLink` NFT**, checked on-chain at mint time only via an applicant-declared contract — the same pattern established for diploma (ADR 0007), with no nationality distinction.
- **Authority-only mint/burn — no self-burn**, same as every other credential designed so far.
- No per-token data beyond standard ERC-721 ownership, per the credentials-wide rule.

## Consequences

- This is the first credential where the user explicitly chose *less* on-chain granularity than Claude proposed, on the grounds that the real-world document already aggregates multiple facts onto one card — establishing that "mirror the real-world document's own level of aggregation" is itself a valid, user-directed granularity heuristic, not just "split wherever a natural static distinction exists" (diploma's heuristic). Future credential types should consider both heuristics and ask rather than assume.
- This is also the first credential with a real suspension/revocation distinction; resolving it as "both are burn, real-world meaning stays off-chain" sets a reusable precedent for any future credential with a similar temporary-vs-permanent inactive state (e.g., a professional license with a disciplinary suspension).
- Professional licenses (医師免許, 建築士, etc.) remain undesigned — they have a more varied set of issuing bodies (ministries, self-regulatory bodies with delegated authority) and would need their own issuer-trust analysis if taken up later.

---

# 0008. 免許のクレデンシャル: 保有だけを示す単一のコントラクト。停止も取消しもburnとする(日本語)

**日付:** 2026-10-06
**ステータス:** Accepted。[ADR 0032](0032-consistency-review-decisions.md)で修正: 承継が記録されたら再発行(R3.3)。死亡でburnする(R3.10)。

## 背景

卒業証明(ADR 0007)に続き、汎用の「クレデンシャル」パターンの3つ目の具体例として、都道府県の公安委員会が発行する運転免許証を設計した。議論([`docs/state-design/credentials/license/discussion-log.md`](../state-design/credentials/license/discussion-log.md)を参照)では次を検討した: 信頼の起点(都道府県ですでに確立した`.lg.jp`の再利用)、粒度、一時的な停止と恒久的な取消しという現実の区別をどう表すか、更新、卒業証明と同様に`ResidentLink`を前提条件とするか。

Claudeは当初、車両の種類ごとに1つのコントラクトを提案した(卒業証明の学部・学位ごとの粒度にならった)。ユーザーはこれを修正した: 今日の物理的な免許証はすでに1枚のカードで複数の種類と条件を管理している。そのためオンチェーンのクレデンシャルもそれにならうべきである。つまり「有効な免許を持つ」ことだけを証明する単一のコントラクトとし、種類や条件の詳細は完全にオフチェーンに置く。

## 決定

- **都道府県ごとに単一のコントラクト。車両の種類や条件による粒度はない。** 卒業証明の学部・学位ごとのコントラクトと異なり、`License` NFTは「保有者が有効な運転免許を持つ」ことだけを証明する。どの種類(普通、中型、大型、二輪など)か、どの条件(AT限定、眼鏡等など)かは証明しない。それらは完全に公安委員会自身のオフチェーンの記録に残る。
- **信頼の起点: `.lg.jp`。** 公安委員会は都道府県の機関だからである。新しい仕組みはなく、課税(ADR 0004)が都道府県のためにすでに確立したものを再利用する。
- **停止と取消しは、オンチェーンではどちらも同じburnとして表す。** 「一時的な停止で自動的に復活する」と「恒久的な取消しで新たな申請が必要」を区別するオンチェーンの状態フィールドはない。この現実の法的な区別と、再発行が可能になる条件はオフチェーンに残る。これは取消しの*理由*をオフチェーンに置くという、このプロジェクトで確立した慣行と一貫する(市民権、法人、パスポート、卒業証明のすべてがそうしている)。
- **更新はburnと再発行として表す。** パスポートと同じで、オンチェーンの有効期限はない。
- **mintには受領者が有効な`ResidentLink` NFTを持つことを要件とする。** 申請者が申告したコントラクトを通じて、mint時だけオンチェーンで確認する。卒業証明(ADR 0007)で確立したのと同じパターンで、国籍の区別はない。
- **mintとburnは発行者だけが行い、本人によるburnはない。** これまで設計した他のすべてのクレデンシャルと同じ。
- クレデンシャル全体のルールに従い、標準のERC-721の所有権を超えるトークンごとのデータはない。

## 結果

- ユーザーがClaudeの提案より*少ない*オンチェーンの粒度を明示的に選んだ最初のクレデンシャルである。現実の文書がすでに複数の事実を1枚のカードにまとめていることが理由である。これにより「現実の文書自体のまとめ方にならう」こと自体が、ユーザーが方向づけた有効な粒度の指針となった。「自然で静的な区別があるところで分ける」(卒業証明の指針)だけではない。今後のクレデンシャルでは両方の指針を考慮し、前提にせず尋ねる。
- 停止と取消しという現実の区別を持つ最初のクレデンシャルでもある。これを「どちらもburnで、現実の意味はオフチェーンに残す」と解決したことは、一時的と恒久的という類似の無効状態を持つ将来のクレデンシャル(例: 懲戒による停止がある専門職の免許)に再利用できる先例となる。
- 専門職の免許(医師免許、建築士など)は未設計のままである。発行主体がより多様であり(省庁、権限を委任された自主規制団体)、取り上げるなら独自の発行者の信頼の分析が必要になる。

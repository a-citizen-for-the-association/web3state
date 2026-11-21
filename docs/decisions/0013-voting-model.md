# 0013. Voting model: threshold-decrypted homomorphic tallying, ResidentLink-based participation, generic election primitive

**Date:** 2026-10-10
**Status:** Accepted. Amended by [ADR 0032](0032-consistency-review-decisions.md): a standing voter credential ("Japanese national, 18+") replaces per-election grants (R5.9); `castBallot` re-checks registration (R3.7); the factory is named `ElectionFactory` (R4.3).

## Context

Voting is the first state function that can't be solved by this project's established pattern ("an authority issues a soulbound possession-proof NFT"). The core difficulty is proving an election was run correctly (eligible voters only, one vote each, correct tally) without anyone being able to link a specific voter to their specific choice. This required resolving six interlocking issues: the privacy/anonymity approach, election-type scope, voter-eligibility verification, double-voting prevention, the voting-period time window, and tallying/public verifiability. See [`docs/state-design/voting/discussion-log.md`](../state-design/voting/discussion-log.md) for the full reasoning, including a genuine multi-round design debate (not simple issue-confirmation) about hiding vote content versus hiding participation, and a constitutional-law discussion (Japanese Constitution Article 15(4), the academic "二元説" dual-nature theory of suffrage) the user explicitly requested as background — not raised unprompted, consistent with this project's standing no-legal-feasibility-checks guidance.

## Decision

- **Vote content is protected by a Helios-style scheme**: homomorphic encryption of each ballot, homomorphic summation of ballots per option, a zero-knowledge proof that the published tally matches the encrypted ballots actually cast, and **threshold decryption** split across multiple trustees so no single party — including the election board itself — can ever decrypt an individual ballot. Only the final aggregate per-option totals are ever decrypted.
- **Vote participation uses the resident's own existing `ResidentLink` address**, not a fresh one-time address per election. This was a deliberate choice: generating a fresh per-election address in a way that still prevents double-registration would require the election board/municipality to privately record, off-chain, which disposable address maps to which resident — a **new**, narrowly-purposed, highly attractive bribery/coercion target, worse than reusing data the municipality already holds. The accepted trade-off is that a `ResidentLink` address's voting-participation history could, in principle, become a permanent, cross-election, correlatable record if that address is ever publicly linked to the resident by any means. This does **not** weaken vote-content protection, which is independent of whether the casting address is known.
- **One generic election primitive, not a single hardcoded election type**: a fixed, closed option list + one-hot encrypted ballots (with a zero-knowledge proof of well-formedness) + homomorphic per-option summation + threshold decryption of only the final totals + a pluggable, publicly-known seat-allocation method applied to the decrypted plaintext totals. This single primitive covers referendums, single-seat plurality, multi-seat single-non-transferable-vote elections, and party-list proportional representation (both 拘束名簿式 and 非拘束名簿式), because seat allocation itself is a deterministic calculation over already-public numbers once the tally is published.
- **Ranked-choice/single-transferable-vote (STV) and write-in candidates are explicitly excluded from scope**: both require examining individual ballots (not just their homomorphic sum) to compute a result, which is structurally incompatible with never decrypting an individual ballot. Neither is used in Japan's actual electoral system.
- **Eligibility is verified off-chain by the election board** (nationality, age, any legal disqualification) — the same pattern 外務省 uses to verify nationality before minting a passport ([ADR 0006](0006-passport-credential.md)) — combined with an on-chain `ResidentLink` check at the point a voting right is granted. This resolves eligibility for voting specifically without requiring the general-purpose on-chain nationality credential that remains deferred in [`docs/BACKLOG.md`](../BACKLOG.md).
- **Double-voting prevention** is a simple per-address, per-election "has voted" marker, since every voter always votes from the same `ResidentLink` address (no fresh-address complexity needed).
- **The voting period is a deliberate, justified exception** to this project's general avoidance of on-chain dates: start/end timestamps are stored as contract-level state and actively enforced against `block.timestamp` at vote-casting time, since (unlike every prior credential's passive timestamps) a voting window must be actively enforced, not just recorded.
- **Implementation stance**: adopt an existing, independently audited implementation (Helios-derived or MACI-derived threshold-decryption tooling) rather than custom cryptography, plus a dedicated external cryptography/security audit before launch — deferred to the implementation phase, tracked in [`docs/BACKLOG.md`](../BACKLOG.md).

## Consequences

- This is the first feature where "possession of a soulbound NFT" is not the whole mechanism — the project now also needs genuine cryptographic infrastructure (homomorphic encryption, zero-knowledge proofs, threshold decryption) sourced from an existing audited library rather than built from scratch, consistent with the project's general preference for proven tools over novel code.
- This is the first feature to explicitly accept a *pseudonymity* guarantee (participation visible if the address is ever linked to a person) rather than full anonymity, deliberately trading participation-privacy for avoiding a new, concentrated off-chain identity-linkage record — the same reuse-rather-than-invent instinct already applied in taxation ([ADR 0004](0004-taxation-payment-rail.md)) and corporations ([ADR 0005](0005-corporate-registration-model.md), officers signing with personal keys rather than a dedicated signing key).
- Because the election mechanism is generic and parameterized (option list, seat count, seat-allocation method), a single contract design serves every planned election type in this project, rather than needing a separate bespoke contract per election type.
- Follow-up work created: selecting the concrete cryptographic library and commissioning its audit (implementation phase); reducing the operational cost of per-voter eligibility grants at national-election scale (tracked in [`docs/BACKLOG.md`](../BACKLOG.md) as a future optimization).
- This completes the originally-flagged voting design: all six issues raised in Round 1 of the discussion log are resolved, and the formal spec is written ([`docs/state-design/voting/README.md`](../state-design/voting/README.md)).

---

# 0013. 投票モデル: 閾値復号による準同型の集計、ResidentLinkに基づく参加、汎用の選挙の基本要素(日本語)

**日付:** 2026-10-10
**ステータス:** Accepted。[ADR 0032](0032-consistency-review-decisions.md)で修正: 常設の有権者クレデンシャル(「日本国籍・18歳以上」)が選挙ごとの付与に代わる(R5.9)。`castBallot`で登録を再確認する(R3.7)。ファクトリーは`ElectionFactory`と命名(R4.3)。

## 背景

投票は、このプロジェクトで確立したパターン(「権限主体が譲渡不可の保有証明のNFTを発行する」)では解決できない最初の国家の機能である。中心の難しさは、特定の投票者と特定の選択を誰も結びつけられないようにしたまま、選挙が正しく行われた(資格のある投票者だけ、1人1票、正しい集計)ことを証明することにある。そのため、互いに絡み合う6つの論点を解決する必要があった: プライバシー・匿名性の方式、選挙の種類のスコープ、投票者の資格の確認、二重投票の防止、投票期間の時間枠、集計と公開の検証可能性。理由の全体は[`docs/state-design/voting/discussion-log.md`](../state-design/voting/discussion-log.md)を参照。そこには、投票内容を隠すか参加を隠すかについての本当の意味での複数ラウンドの設計の議論(単なる論点の確認ではない)と、ユーザーが背景として明示的に求めた憲法の議論(日本国憲法第15条第4項、選挙権の学説上の「二元説」)が含まれる。後者は求められずに持ち出したものではなく、法的な実現可能性を確認しないというこのプロジェクトの常設の方針と一貫する。

## 決定

- **投票内容はHelios型の方式で保護する:** 各投票の準同型暗号化、選択肢ごとの投票の準同型の合計、公開した集計が実際に投じられた暗号化された投票と一致することのゼロ知識証明、そして複数の信頼主体に分散した**閾値復号**。これにより、選挙管理委員会自身を含め、単独では誰も個々の投票を復号できない。復号するのは、選択肢ごとの最終的な合計だけである。
- **投票への参加には、住民自身の既存の`ResidentLink`アドレスを使う。** 選挙ごとの新しい使い捨てのアドレスは使わない。これは意図した選択である: 二重登録を防ぎながら選挙ごとに新しいアドレスを生成するには、選挙管理委員会や市区町村が、どの使い捨てのアドレスがどの住民に対応するかをオフチェーンで非公開に記録しなければならない。これは**新しく**、目的が狭く、買収や強要の標的としてきわめて魅力的な記録であり、市区町村がすでに持つデータを再利用するより悪い。受け入れたトレードオフは、`ResidentLink`アドレスが何らかの方法で住民と公に結びつけられた場合、そのアドレスの投票参加の履歴が、原理的には選挙をまたいで照合できる恒久的な記録になりうることである。これは投票内容の保護を**弱めない**。投票内容の保護は、投票したアドレスが知られているかどうかとは独立している。
- **1つの汎用の選挙の基本要素とし、ハードコードした単一の選挙の種類とはしない:** 固定の閉じた選択肢のリスト+ワンホット暗号化された投票(形式の正しさのゼロ知識証明つき)+選択肢ごとの準同型の合計+最終的な合計だけの閾値復号+復号した平文の合計に適用する、差し替え可能で公開された議席配分の方法。この1つの基本要素で、住民投票、小選挙区の相対多数、中選挙区の単記非移譲式の選挙、政党名簿式の比例代表(拘束名簿式と非拘束名簿式の両方)をまかなえる。集計が公開されれば、議席配分そのものはすでに公開された数字に対する決定的な計算だからである。
- **順位付け投票・単記移譲式(STV)と記名投票(候補者名の自由記入)は、明示的にスコープから除外する。** どちらも結果を計算するために、準同型の合計だけでなく個々の投票を調べる必要がある。これは個々の投票を決して復号しないことと構造的に両立しない。どちらも日本の実際の選挙制度では使われていない。
- **資格は選挙管理委員会がオフチェーンで確認する**(国籍、年齢、法的な欠格事由)。外務省がパスポートをmintする前に国籍を確認するのと同じパターンである([ADR 0006](0006-passport-credential.md))。これに、投票権を付与する時点でのオンチェーンの`ResidentLink`の確認を組み合わせる。これにより、[`docs/BACKLOG.md`](../BACKLOG.md)で保留のままの汎用のオンチェーンの国籍のクレデンシャルを必要とせずに、投票に限って資格の問題を解決する。
- **二重投票の防止**は、アドレスごと・選挙ごとの単純な「投票済み」の印とする。投票者は常に同じ`ResidentLink`アドレスから投票するからである(新しいアドレスによる複雑さは不要)。
- **投票期間は、オンチェーンに日付を持たないというこのプロジェクトの一般的な方針に対する、意図的で正当な例外である:** 開始・終了のタイムスタンプをコントラクト全体の状態として保存し、投票時に`block.timestamp`と照らして実際に強制する。(これまでのすべてのクレデンシャルの受動的なタイムスタンプと異なり)投票の時間枠は記録するだけでなく、実際に強制しなければならないからである。
- **実装の方針:** 独自の暗号ではなく、独立に監査された既存の実装(Helios由来またはMACI由来の閾値復号のツール)を採用する。加えて、運用開始の前に専門の外部の暗号・セキュリティ監査を行う。実装の段階に先送りし、[`docs/BACKLOG.md`](../BACKLOG.md)で管理する。

## 結果

- 「譲渡不可のNFTの保有」が仕組みの全体ではない最初の機能である。プロジェクトは今後、本当の意味での暗号の基盤(準同型暗号、ゼロ知識証明、閾値復号)も必要とする。これは一から作るのではなく、既存の監査済みのライブラリから調達する。新しいコードより実績のあるツールを好むというプロジェクトの一般的な方針と一貫する。
- 完全な匿名性ではなく*仮名性*の保証(アドレスが人と結びつけば参加が見える)を明示的に受け入れた最初の機能である。新しく集中したオフチェーンの本人との結びつけの記録を避けるため、参加のプライバシーを意図して引き換えにした。新たに作るより再利用するという、課税([ADR 0004](0004-taxation-payment-rail.md))や法人([ADR 0005](0005-corporate-registration-model.md)、役員は専用の署名鍵ではなく個人の鍵で署名する)ですでに適用した考え方と同じである。
- 選挙の仕組みが汎用でパラメータ化されている(選択肢のリスト、議席数、議席配分の方法)ので、選挙の種類ごとに専用のコントラクトを作る必要はなく、1つのコントラクトの設計で、このプロジェクトが予定するすべての種類の選挙をまかなえる。
- 生じた後続の作業: 具体的な暗号ライブラリの選定とその監査の依頼(実装の段階)。国政選挙の規模での、投票者ごとの資格付与の運用コストの削減(将来の最適化として[`docs/BACKLOG.md`](../BACKLOG.md)で管理)。
- これで最初に挙げた投票の設計が完了した: 議論ログのラウンド1で挙げた6つの論点すべてを解決し、正式な仕様を書いた([`docs/state-design/voting/README.md`](../state-design/voting/README.md))。

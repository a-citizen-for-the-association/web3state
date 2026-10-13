# Legislative process (立法プロセス)

> Scope decision, not a contract design. See the [discussion log](discussion-log.md) and [ADR 0014](../../decisions/0014-legislative-process-scope.md).

## Summary

The legislative process as a whole (proposal → deliberation → vote → promulgation → amendment/repeal) is **deliberately not put on-chain**. Two specific pieces at its edges are kept and designed elsewhere:

| Piece | Where it goes | Why it survives the screen |
|---|---|---|
| Direct-demand petition signatures (直接請求の署名) | Own item under Governance Core (🔴 Not started); an extension of `ResidentLink` / a sibling of [voting](../voting/) using public, non-secret signatures | Real, recent forgery (2020 Aichi recall: ~83% of ~435,000 signatures invalid). Signer identity verification is exactly what `ResidentLink` already provides. |
| Legislators' roll-call vote records (議員の記名採決記録) | Inside the political donations (政治献金) design | Closes a real verifiability gap (standing votes leave no per-member record). Its value multiplies when joined with donation data on the same rail. |

## Decision criteria: the on-chain value test

Screen each candidate function, **sub-part by sub-part rather than all-or-nothing**, with these questions:

1. **Concrete problem.** Is there an observed fraud, forgery, or tampering risk, or a real verifiability gap, that an on-chain record would remove?
2. **Untrusted record-keeper.** Does the record-keeper have both the incentive and the ability to alter the record, without effective existing public scrutiny?
3. **Technical root cause.** Is the problem one of record integrity, identity verification, or traceability, rather than a political or institutional one that changing the record technology cannot touch?
4. **No adequate existing record.** Is there *no* existing public system (gazette, published minutes, e-Gov, etc.) that already serves the purpose?
5. **Combination value.** Does putting it on-chain create value by joining it with data already on-chain (e.g. `ResidentLink`, corporate registration, payments, donations)?

A sub-part is a candidate if question 1 is "yes" **and** at least one of questions 2–5 is "yes". A function whose core fails question 1 is excluded (🚫) with its reasons recorded, and the parts that pass are carved out into their own items.

### Applied to the legislative process

| Sub-part | Q1 problem | Q2 keeper | Q3 technical | Q4 no record | Q5 combination | Result |
|---|---|---|---|---|---|---|
| Bill text, deliberation, minutes, promulgation, version history | No | No | No | No (gazette, minutes, e-Gov) | Weak | 🚫 Excluded |
| Direct-demand petition signatures | **Yes** (forgery) | **Yes** (signature collectors) | **Yes** (signer identity) | **Yes** (paper rolls are not verifiable) | Yes (`ResidentLink`) | Keep → own item |
| Legislators' roll-call votes | **Yes** (no per-member record) | Partial | Partial (also fixable by rule) | **Yes** (standing votes) | **Yes** (donations) | Keep → inside political donations |

## Open items for the direct-demand signature design (not resolved now)

Recorded so they are not lost; to be discussed when that item is taken up:

- Signer eligibility: same as voting eligibility (election-board grant + `ResidentLink` check, [ADR 0013](../../decisions/0013-voting-model.md)), or a lighter check?
- Signature visibility: current law already makes signature rolls available for public inspection (縦覧) so that forgeries can be challenged. Should on-chain signatures be fully public, or protected against retaliation against signers?
- Collection period and thresholds (e.g. one-third of eligible voters for a recall) enforced on-chain, as with voting's period exception?
- Whether the collected-signature count automatically triggers the next step (a recall vote or a bill submission), or only certifies the count.

---

# 立法プロセス(日本語)

> これはコントラクト設計ではなく、スコープの決定です。[議論ログ](discussion-log.md)と[ADR 0014](../../decisions/0014-legislative-process-scope.md)を参照してください。

## 概要

立法プロセス全体(提案 → 審議 → 採決 → 公布 → 改正・廃止)は、**意図的にオンチェーン化しない**。その周辺にある次の2つだけを残し、別の場所で設計する。

| 部分 | 扱い | 基準を通過した理由 |
|---|---|---|
| 直接請求の署名 | 統治の中核カテゴリの独立項目(🔴 未着手)。`ResidentLink`の拡張、または[投票](../voting/)の兄弟機能として、秘密ではない公開署名を用いる | 実際に最近起きた偽造(2020年愛知県知事リコール: 約43万5千筆の約83%が無効)。署名者の本人確認は、まさに`ResidentLink`がすでに提供している機能である。 |
| 議員の記名採決記録 | 政治献金の設計に含める | 実在する検証可能性の欠落を埋める(起立採決では議員ごとの記録が残らない)。同じ基盤上の献金データと結合すると価値が大きくなる。 |

## 判断基準: オンチェーン価値テスト

候補機能は、**全体の可否ではなく部分ごとに**、次の問いでふるいにかける。

1. **具体的な問題。** オンチェーン記録で取り除ける、実際に観測された不正・偽造・改ざんのリスク、または検証可能性の欠落があるか?
2. **信頼できない記録管理者。** 記録の管理者に改ざんする動機と能力の両方があり、かつ既存の有効な公的監視が及んでいないか?
3. **技術的な根本原因。** 問題は記録の完全性・本人確認・追跡可能性の問題か?記録技術を変えても届かない政治・制度の問題ではないか?
4. **既存の十分な記録がない。** その目的をすでに果たしている公的な仕組み(官報、公開会議録、e-Govなど)が*ない*か?
5. **組み合わせの価値。** すでにオンチェーンにあるデータ(`ResidentLink`、法人登記、支払い、献金など)と結合することで価値が生まれるか?

問1が「はい」で、**かつ**問2〜5のいずれか1つ以上が「はい」なら、その部分は候補になる。本体が問1を満たさない機能は、理由を記録したうえで 🚫 対象外 とし、基準を通過した部分だけを独立した項目として切り出す。

### 立法プロセスへの適用

| 部分 | 問1 問題 | 問2 管理者 | 問3 技術 | 問4 記録なし | 問5 組み合わせ | 結果 |
|---|---|---|---|---|---|---|
| 条文・審議・会議録・公布・版履歴 | いいえ | いいえ | いいえ | いいえ(官報、会議録、e-Gov) | 弱い | 🚫 対象外 |
| 直接請求の署名 | **はい**(偽造) | **はい**(署名収集者) | **はい**(署名者の本人確認) | **はい**(紙の署名簿は検証できない) | はい(`ResidentLink`) | 残す → 独立項目 |
| 議員の記名採決 | **はい**(議員ごとの記録がない) | 一部 | 一部(制度のルールでも直せる) | **はい**(起立採決) | **はい**(献金) | 残す → 政治献金に含める |

## 直接請求の署名の設計における未決事項(今は決めない)

失われないよう記録しておき、その項目に着手するときに議論する。

- 署名者の資格: 投票と同じ資格確認(選挙管理委員会による付与 + `ResidentLink`の確認、[ADR 0013](../../decisions/0013-voting-model.md))にするか、より軽い確認にするか?
- 署名の公開範囲: 現行法でも、偽造に異議を申し立てられるよう署名簿は縦覧に供されている。オンチェーンの署名を完全に公開するか、署名者への報復から保護するか?
- 収集期間と必要数(例: リコールなら有権者の3分の1)を、投票期間の例外と同様にオンチェーンで強制するか?
- 必要数に達したら次の手続き(解職投票や議案提出)を自動で起動するか、署名数の証明だけにとどめるか?

# 0014. Legislative process scope: exclude the core, carve out petition signatures and roll-call records, adopt an on-chain value test

**Date:** 2026-10-13
**Status:** Accepted. The roll-call-records bullet is superseded by [ADR 0015](0015-political-donations-model.md). The petition-signature design deferred here is completed in [ADR 0016](0016-direct-demand-petition-model.md).

## Context

After voting ([ADR 0013](0013-voting-model.md)), the next Governance Core candidate was the legislative process: proposal → deliberation → vote → promulgation → amendment/repeal of laws and ordinances. When it was explained concretely, the user could not identify any place where web3 would actually improve it, and asked whether the process suffers from real fraud or serious inefficiency.

Findings:

- The legislative core is already public and heavily scrutinized: bills, minutes (会議録), the official gazette (官報), and statute version history (e-Gov 法令検索). Covert tampering with enacted text or minutes is essentially unheard of. Its real inefficiencies are political/institutional, which recording technology does not reach.
- **Direct-demand petition signatures are a real, recent fraud surface.** In the 2020 recall campaign against the Governor of Aichi Prefecture, about 83% of the ~435,000 submitted signatures were ruled invalid. Hired workers had copied names onto the rolls, and the campaign leadership was criminally prosecuted. Paper signature rolls cannot be verified at the moment of signing.
- **Many local assemblies vote by standing (起立採決)**, leaving no official per-member record of how each legislator voted.

[ADR 0012](0012-onchain-scope-philosophy.md) set the policy direction (put on-chain what gains transparency or fraud resistance; explicitly exclude the rest), but it gave no operational test for deciding this about a specific function.

## Decision

- **The legislative process as a standalone function is deliberately excluded** (🚫 in `docs/FEATURES.md`), with reasons recorded, rather than silently dropped.
- **Direct-demand petition signatures (直接請求の署名) become their own Governance Core item** (🔴 Not started). Each signature is made by the resident themself from their `ResidentLink` address, so the 2020 Aichi type of forgery is structurally impossible. It is treated as an extension of `ResidentLink`, or as a sibling of the voting design that uses **public, non-secret signatures** instead of encrypted ballots. Detailed design is deferred to when the item is taken up.
- **Legislators' roll-call vote records (議員の記名採決記録) are folded into the political donations design**, where joining "who funded this legislator" with "how they voted" gives the record its main value.
- **An on-chain value test is adopted** for screening the remaining candidates, applied sub-part by sub-part: (1) a concrete fraud/tampering/verifiability problem exists; (2) the record-keeper is untrusted and unscrutinized; (3) the root cause is technical (record integrity, identity, traceability), not institutional; (4) no adequate public record already exists; (5) combining it with data already on-chain creates value. A sub-part qualifies if (1) holds and at least one of (2)–(5) holds. The full test and its application are in [`docs/state-design/legislative/README.md`](../state-design/legislative/README.md).

## Consequences

- Governance Core shrinks by one large, low-value design, and gains one small, high-value one (petition signatures).
- The political donations design now has a wider scope: it must also cover legislators' public roll-call records. This is the first place where a **public** vote record (as opposed to voting's secret ballots) is designed.
- The value test gives the remaining 🔴 candidates (executive, judiciary, and others) a consistent screen, so other functions may also end up partly excluded. Exclusions keep being recorded visibly (🚫 + reasons), per ADR 0012.
- Open items for the petition-signature design (eligibility check, signature visibility vs. retaliation risk, on-chain period/threshold enforcement, whether reaching the threshold triggers the next step automatically) are recorded in the legislative spec and are not resolved here.

---

# 0014. 立法プロセスのスコープ: 本体は対象外とし、直接請求の署名と議員の記名採決記録を切り出し、オンチェーン価値テストを採用する(日本語)

**日付:** 2026-10-13
**ステータス:** Accepted。記名採決記録の項目は[ADR 0015](0015-political-donations-model.md)で上書き。ここで先送りした直接請求の署名の設計は[ADR 0016](0016-direct-demand-petition-model.md)で確定。

## 背景

投票([ADR 0013](0013-voting-model.md))の次の統治の中核の候補は、立法プロセス(法律・条例の提案 → 審議 → 採決 → 公布 → 改正・廃止)だった。具体的に説明を受けたユーザーは、web3で実際に改善できる場所を見つけられず、このプロセスで実際に不正や大きな非効率が起きているのかを尋ねた。

検討の結果:

- 立法の本体はすでに公開されており、強い監視を受けている。議案、会議録、官報、法令の版履歴(e-Gov法令検索)がある。成立条文や会議録のひそかな改ざんはほぼ聞かれない。実際の非効率は政治・制度の問題で、記録技術では届かない。
- **直接請求の署名は、実際に最近不正が起きた領域である。** 2020年の愛知県知事リコール運動では、提出された約43万5千筆のうち約83%が無効と判定された。雇われた作業者が署名簿に名前を書き写しており、運動の幹部は刑事訴追された。紙の署名簿は、署名した時点で本人かどうかを検証できない。
- **多くの地方議会は起立採決**のため、各議員がどう投票したかの公式な記録が残らない。

[ADR 0012](0012-onchain-scope-philosophy.md)は方針(透明性や不正耐性が得られるものをオンチェーン化し、それ以外は明示的に対象外とする)を定めたが、個々の機能についてそれを判断する運用上のテストは定めていなかった。

## 決定

- **独立した機能としての立法プロセスは意図的に対象外とする**(`docs/FEATURES.md`で🚫)。黙って削除せず、理由を記録する。
- **直接請求の署名を、統治の中核カテゴリの独立項目とする**(🔴 未着手)。各署名は住民本人が自分の`ResidentLink`アドレスから行うため、2020年の愛知県のような偽造は構造的に不可能になる。`ResidentLink`の拡張、または暗号化投票の代わりに**秘密ではない公開署名**を使う投票設計の兄弟機能として扱う。詳細設計は、この項目に着手するときまで先送りする。
- **議員の記名採決記録は、政治献金の設計に含める。** 「誰がこの議員に献金したか」と「その議員がどう投票したか」を結合できることが、この記録の主な価値である。
- **残りの候補をふるいにかけるため、オンチェーン価値テストを採用する。** 部分ごとに適用する。(1) 具体的な不正・改ざん・検証可能性の問題がある、(2) 記録管理者が信頼できず監視も及んでいない、(3) 根本原因が制度ではなく技術(記録の完全性、本人確認、追跡可能性)にある、(4) 十分な公的記録が既存でない、(5) すでにオンチェーンにあるデータと組み合わせることで価値が生まれる。(1)を満たし、かつ(2)〜(5)のいずれか1つ以上を満たす部分が候補になる。テストの全文と適用結果は[`docs/state-design/legislative/README.md`](../state-design/legislative/README.md)にある。

## 結果

- 統治の中核カテゴリから、大きく価値の低い設計が1つ減り、小さく価値の高い設計(直接請求の署名)が1つ増える。
- 政治献金の設計スコープが広がり、議員の公開記名採決記録も扱う必要がある。投票の秘密投票とは逆の、**公開**の投票記録を設計する最初の場所になる。
- 価値テストにより、残りの🔴候補(行政、司法など)を一貫した基準でふるいにかけられる。他の機能も一部が対象外になる可能性がある。対象外とする場合は、ADR 0012に従い引き続き目に見える形(🚫 + 理由)で記録する。
- 直接請求の署名の設計における未決事項(資格確認、署名の公開範囲と報復リスク、期間・必要数のオンチェーン強制、必要数到達時に次の手続きを自動起動するか)は立法プロセスの仕様に記録し、ここでは決めない。

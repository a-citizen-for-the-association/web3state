# Proof-of-concept themes (candidates)

**Status: Claude's draft; the user judged the direction to be off and will propose the themes (2026-11-28).** Roadmap step 5: choose 10 or more PoCs, each asking whether the design can solve a current social problem ([`PROJECT_STATUS.md`](../PROJECT_STATUS.md)). The PoC method (step 6) is decided after the selection.

## How the candidates were chosen

- Each theme starts from a **real, documented problem** in Japan and maps to a **designed feature and an implemented contract** (`contracts/src/`).
- Each theme is tagged by the **working hypothesis** to test ([`PROJECT_STATUS.md`](../PROJECT_STATUS.md)): **Retail** (ordinary people's everyday economic activity), **Public** (public administration and politics), or **Large-value** (real estate, inheritance, securities). The hypothesis predicts benefits for Retail and drawbacks for Large-value, so the set includes themes that could **refute** it as well as confirm it.
- **Readiness:** A = runnable on the current provisional contracts; B = needs scripts or a small off-chain application (analysis, simulated merchants); C = depends on a part that is stubbed or missing.
- Figures marked † are taken from earlier discussion logs; every figure must be re-checked against a primary source before it goes into the paper.

## Summary

| # | Theme | Social problem | Design / contracts | Class | Readiness |
|---|---|---|---|---|---|
| 1 | Signature forgery in direct demands | Aichi recall 2020: ~83% of ~435,000 signatures invalid† | ADR 0016 / `Petition` | Public | A |
| 2 | Misdirected and delayed benefit payments | Wrong-account payments (e.g. Abu Town, 2022), slow emergency payments | ADRs 0019, 0025 / `PublicTreasury` | Retail | A |
| 3 | Hidden political money | Unrecorded party-ticket income (factions, 2023–24) | ADR 0015 / `PoliticalFund` | Public | A |
| 4 | Tampering with official documents | Rewritten approval documents (Ministry of Finance, 2018) | ADR 0017 / `AnchorRegistry` | Public | A |
| 5 | Tampering with evidence | Altered evidence data (Osaka prosecutors, 2010) | ADR 0018 / `AnchorRegistry`, `CaseRecordRegistry` | Public | A |
| 6 | Bid rigging and leaked ceiling prices | Collusion in public procurement | ADR 0022 / `Tender` | Public | A/B |
| 7 | Subsidy and grant fraud | Fraudulent claims for pandemic subsidies | ADR 0023 / `PublicTreasury` + flow analysis | Public | B |
| 8 | Personal-data leaks from companies | Benesse 2014 (~35M records)†, NTT West group 2023 (~9M)† | ADR 0028 / `AgeCredential`, `AnchorRegistry` | Retail | B |
| 9 | Lost or mismatched pension records | "Missing pension records" (~50M, 2007) | ADR 0024 / `RegisteredJPY`, `PublicTreasury` | Retail | A |
| 10 | Working while receiving unemployment benefits | Undetected fraudulent receipt | ADR 0026 / `SoulboundCredential` (employee ID) + flow analysis | Retail | B |
| 11 | Hiding money through second addresses | Undeclared assets, smurfing, bribery | ADR 0031 / `RegisteredJPY` cap, VIP flag | Retail / Public | A/B |
| 12 | Owner impersonation in land sales (地面師) | Sekisui House 2017, ~¥5.5bn lost† | ADR 0029 / `RealEstateToken` | Large-value | A |
| 13 | Unknown owners and stalled inheritance | Unknown-owner land larger than Kyushu† | ADRs 0020, 0029 / `SuccessorMigration`, `RealEstateToken` | Large-value | A |
| 14 | Identifying home buyers from public data | Privacy cost of on-chain property (review R5.3) | ADR 0029 / `RealEstateToken` + analysis | Large-value | B |
| 15 | Shell companies and hidden beneficial owners | Weak beneficial-ownership transparency (FATF 2021) | ADR 0030 / `ShareToken` + tracing | Large-value | B |
| 16 | Key loss and theft for high-value holdings | Irrecoverable keys vs. paper title | ADRs 0020, 0032 / `SuccessorMigration`, suspension | Large-value | A |
| 17 | Settlement of listed shares at national scale | Settlement risk vs. chain capacity | ADR 0030 / `ShareToken`, `ClearingContract` | Large-value | B |
| 18 | Election integrity | Miscounted votes (trust banks 2020, shareholder votes); counting errors | ADR 0013 / `Election` | Public | C (cryptography stubbed) |

## Themes

### 1. Signature forgery in direct demands (Public, A)
- **Problem:** collectors copied names onto paper rolls; most signatures were invalid and the leaders were prosecuted.
- **What the PoC shows:** only listed residents can sign, once each, from their own address; a forged roll cannot exist. Compare checking effort with today's manual review.
- **Indicators:** forged signatures accepted (target 0); time and cost to certify the count; what becomes public about signers.

### 2. Misdirected and delayed benefit payments (Retail, A)
- **Problem:** wrong-account transfers (a town sent ¥46.3 million to one person by mistake in 2022) and slow emergency payments.
- **What the PoC shows:** payments go only to the recipient's own registered address; a batch with failures continues and retries.
- **Indicators:** misdirected payments possible (target 0); time from decision to receipt; failure handling.

### 3. Hidden political money (Public, A)
- **Problem:** party-ticket income left out of reports.
- **What the PoC shows:** every accounted inflow goes through `contribute`; unaccounted money cannot be spent and is forfeited; caps are enforced.
- **Indicators:** income that can avoid the record (target 0); audit effort; residual evasion routes (cash, other tokens).

### 4. Tampering with official documents (Public, A)
- **Problem:** approval documents were rewritten after the fact.
- **What the PoC shows:** title and hash anchored at approval; any later version is a visible correction.
- **Indicators:** undetected rewrites (target 0); operational burden on agencies.

### 5. Tampering with evidence (Public, A)
- **Problem:** seized digital evidence was altered by a prosecutor.
- **What the PoC shows:** evidence hashes anchored at seizure; returns and destruction are events; court records cannot be disposed of silently.
- **Indicators:** undetected alteration (target 0); disclosure to the defence.

### 6. Bid rigging and leaked ceiling prices (Public, A/B)
- **Problem:** collusion and leaked ceiling prices in public tenders.
- **What the PoC shows:** sealed bids and a committed ceiling; all revealed bids public, so analysis can flag rigging patterns.
- **Indicators:** ceiling leakage possible (target 0); rigging patterns detected in simulated data.

### 7. Subsidy and grant fraud (Public, B)
- **Problem:** fraudulent claims for pandemic-era subsidies.
- **What the PoC shows:** grants and subsidised expenses are on-chain payments between registered addresses; circular flows (grant → supplier → back to recipient) are detectable.
- **Indicators:** share of simulated fraud patterns detected; false positives.

### 8. Personal-data leaks from companies (Retail, B)
- **Problem:** large leaks through subcontractor insiders and long-undetected theft.
- **What the PoC shows:** a simulated shop verifies age by credential and keeps only address, fact and block; signature login; order-code delivery; daily access-log roots.
- **Indicators:** personal data items held per customer (before vs. after); detection of log tampering; customer friction.

### 9. Lost or mismatched pension records (Retail, A)
- **Problem:** tens of millions of contribution records could not be matched to people.
- **What the PoC shows:** every contribution is a transfer from the insured person's own address; records cannot be orphaned.
- **Indicators:** unmatched contributions (target 0); behaviour across moves, emigration and succession.

### 10. Working while receiving unemployment benefits (Retail, B)
- **Problem:** fraudulent receipt is found late or not at all.
- **What the PoC shows:** a new employee-ID credential or salary inflows during the benefit period are visible (with consent).
- **Indicators:** detection rate and delay in simulated cases; privacy cost.

### 11. Hiding money through second addresses (Retail / Public, A/B)
- **Problem:** undeclared assets, splitting payments, bribery through intermediaries.
- **What the PoC shows:** the cumulative cap and the VIP zero cap; the residual route through relatives, and how far analysis of public flows finds it.
- **Indicators:** amount movable outside the record per period; detection rate of round trips; everyday usability ("like cash").

### 12. Owner impersonation in land sales (Large-value, A)
- **Problem:** forged ID documents let fraudsters sell land they do not own.
- **What the PoC shows:** a thief with only the owner's key cannot transfer without an agent; atomic settlement removes settlement risk.
- **Indicators:** successful impersonation (target 0); steps, time and cost of a sale compared with today.

### 13. Unknown owners and stalled inheritance (Large-value, A)
- **Problem:** owners cannot be found because inheritance and address changes were not registered.
- **What the PoC shows:** moves never make the record stale; a death is visible; the heavy path moves land and money to heirs, splitting shares.
- **Indicators:** owner traceability; time and steps of the heavy path; failure cases (heirs abroad, lost keys).

### 14. Identifying home buyers from public data (Large-value, B) — a test that could refute the design
- **Problem:** review R5.3: a buyer from a published holder can be identified.
- **What the PoC shows:** how often public data (published parcels, transfers, timing) identifies individual owners' homes.
- **Indicators:** identification rate; what would reduce it.

### 15. Shell companies and hidden beneficial owners (Large-value, B)
- **Problem:** layered ownership hides who controls a corporation.
- **What the PoC shows:** tracing holdings through corporations, funds and trusts to individuals; the 50% foreign-control test for land.
- **Indicators:** time to identify the final owners; routes that remain (borrowed names).

### 16. Key loss and theft for high-value holdings (Large-value, A) — a test that could refute the design
- **Problem:** a lost key can strand a house; a stolen key can sell it.
- **What the PoC shows:** suspension, the heavy path, agents; how heavy recovery is compared with paper title.
- **Indicators:** recovery time and steps; residual losses; burden on courts and municipalities.

### 17. Settlement of listed shares at national scale (Large-value, B)
- **Problem:** daily net settlement of every listed holding is large; chain capacity is a constraint (ADR 0030).
- **What the PoC shows:** gas and time per daily batch at realistic volumes; failure isolation.
- **Indicators:** cost and duration per day; feasibility on candidate chains.

### 18. Election integrity (Public, C)
- **Problem:** miscounted or uncounted votes, unverifiable tallies.
- **What the PoC shows (limited):** eligibility, double-vote prevention and succession rules now; verifiable encrypted tallying only after a real cryptographic library is integrated.
- **Indicators:** double votes (target 0); everything else deferred.

## Suggested first selection

Twelve themes cover all three classes and can run on the current contracts or with small scripts: **1, 2, 3, 4, 8, 9, 11, 12, 13, 14, 15, 16**. Themes 14 and 16 are included on purpose because they could refute the design, which the working hypothesis predicts for large-value uses. 5, 6, 7, 10 and 17 are good additions; 18 waits for the cryptography.

---

# 実証実験のテーマ(候補)(日本語)

**ステータス: Claudeの案。ユーザーは方向性が違うと判断し、自分でテーマを提案する(2026-11-28)。** ロードマップの段階5: 現在の社会問題を設計で解決できるかを問うPoCを10件以上選ぶ([`PROJECT_STATUS.md`](../PROJECT_STATUS.md))。PoCの方法(段階6)は選んだ後に決める。

## 候補の選び方

- 各テーマは、日本で**実際に記録された問題**から出発し、**設計した機能と実装したコントラクト**(`contracts/src/`)に対応させた。
- 各テーマに、検証する**作業仮説**([`PROJECT_STATUS.md`](../PROJECT_STATUS.md))の区分を付けた: **リテール**(一般庶民の日常の経済活動)、**公的**(行政と政治)、**高額**(不動産、相続、有価証券)。仮説はリテールで利点、高額で欠点を予想するので、仮説を確かめるテーマだけでなく、**覆しうる**テーマも入れた。
- **準備度:** A = 今の仮実装でそのまま動かせる。B = スクリプトや小さなオフチェーンのアプリ(分析、模擬の店舗)が要る。C = 簡易版または未実装の部分に依存する。
- †の数字は以前の議論ログからとった。論文に載せる前に、すべての数字を一次資料で確かめ直す必要がある。

## 一覧

| # | テーマ | 社会問題 | 設計 / コントラクト | 区分 | 準備度 |
|---|---|---|---|---|---|
| 1 | 直接請求の署名の偽造 | 2020年の愛知県知事リコール: 約43万5千筆の約83%が無効† | ADR 0016 / `Petition` | 公的 | A |
| 2 | 給付金の誤送金と遅れ | 誤った口座への振込(例: 2022年の阿武町)、緊急給付の遅れ | ADR 0019、0025 / `PublicTreasury` | リテール | A |
| 3 | 政治資金の裏金 | パーティー券収入の不記載(派閥、2023〜24年) | ADR 0015 / `PoliticalFund` | 公的 | A |
| 4 | 公文書の改ざん | 決裁文書の書き換え(財務省、2018年) | ADR 0017 / `AnchorRegistry` | 公的 | A |
| 5 | 証拠の改ざん | 証拠データの改ざん(大阪地検、2010年) | ADR 0018 / `AnchorRegistry`、`CaseRecordRegistry` | 公的 | A |
| 6 | 談合と予定価格の漏洩 | 公共調達での談合 | ADR 0022 / `Tender` | 公的 | A/B |
| 7 | 補助金・給付金の不正受給 | コロナ禍の補助金の不正申請 | ADR 0023 / `PublicTreasury`と流れの分析 | 公的 | B |
| 8 | 企業からの個人情報の漏洩 | ベネッセ2014年(約3500万件)†、NTT西日本グループ2023年(約900万件)† | ADR 0028 / `AgeCredential`、`AnchorRegistry` | リテール | B |
| 9 | 年金記録の消失・不一致 | 「消えた年金記録」(約5000万件、2007年) | ADR 0024 / `RegisteredJPY`、`PublicTreasury` | リテール | A |
| 10 | 雇用保険の受給中の就労 | 発見されない不正受給 | ADR 0026 / `SoulboundCredential`(社員証)と流れの分析 | リテール | B |
| 11 | 2つ目のアドレスによるお金の隠匿 | 申告しない資産、小分け、賄賂 | ADR 0031 / `RegisteredJPY`の上限、要人の印 | リテール/公的 | A/B |
| 12 | 土地取引でのなりすまし(地面師) | 積水ハウス2017年、約55億円の損失† | ADR 0029 / `RealEstateToken` | 高額 | A |
| 13 | 所有者不明と相続の停滞 | 九州より広い所有者不明土地† | ADR 0020、0029 / `SuccessorMigration`、`RealEstateToken` | 高額 | A |
| 14 | 公開データからの家の買主の特定 | オンチェーンの不動産のプライバシーの代償(レビューR5.3) | ADR 0029 / `RealEstateToken`と分析 | 高額 | B |
| 15 | ペーパーカンパニーと隠れた実質的支配者 | 実質的支配者の透明性の弱さ(FATF 2021年) | ADR 0030 / `ShareToken`と追跡 | 高額 | B |
| 16 | 高額な資産の鍵の紛失と盗難 | 回復できない鍵と紙の権利証 | ADR 0020、0032 / `SuccessorMigration`、停止 | 高額 | A |
| 17 | 全国規模の上場株式の決済 | 決済リスクとチェーンの処理能力 | ADR 0030 / `ShareToken`、`ClearingContract` | 高額 | B |
| 18 | 選挙の公正 | 集計漏れ(2020年の信託銀行、株主の議決権)、数え間違い | ADR 0013 / `Election` | 公的 | C(暗号は簡易版) |

## 各テーマ

### 1. 直接請求の署名の偽造(公的、A)
- **問題:** 受任者が署名簿に名前を書き写し、署名の大半が無効になり、幹部が起訴された。
- **PoCで示すこと:** 名簿に載った住民だけが、自分のアドレスから1回だけ署名できる。偽造した署名簿はそもそも存在しえない。今の手作業の審査と手間を比べる。
- **指標:** 受け付けられた偽造署名(目標0)。署名数の確定までの時間と費用。署名者について何が公開されるか。

### 2. 給付金の誤送金と遅れ(リテール、A)
- **問題:** 誤った口座への振込(2022年にある町が1人に4630万円を誤って送金)や、緊急給付の遅れ。
- **PoCで示すこと:** 支払いは受給者本人の登録済みアドレスにだけ届く。失敗を含むまとめての支払いも止まらず、再試行される。
- **指標:** 誤送金の可能性(目標0)。決定から受け取りまでの時間。失敗の扱い。

### 3. 政治資金の裏金(公的、A)
- **問題:** パーティー券の収入が報告から漏れていた。
- **PoCで示すこと:** 記録される収入はすべて`contribute`を通る。出どころ不明のお金は使えず没収される。上限が守られる。
- **指標:** 記録を避けられる収入(目標0)。監査の手間。残る抜け道(現金、ほかのトークン)。

### 4. 公文書の改ざん(公的、A)
- **問題:** 決裁文書が後から書き換えられた。
- **PoCで示すこと:** 決裁の時点で名称とハッシュをアンカーする。後の版はすべて見える訂正になる。
- **指標:** 見つからない書き換え(目標0)。役所の運用の負担。

### 5. 証拠の改ざん(公的、A)
- **問題:** 押収したデジタルの証拠を検事が改ざんした。
- **PoCで示すこと:** 押収の時点で証拠のハッシュをアンカーする。返還と廃棄はイベントになる。裁判記録はこっそり廃棄できない。
- **指標:** 見つからない改ざん(目標0)。弁護側への開示。

### 6. 談合と予定価格の漏洩(公的、A/B)
- **問題:** 公共入札での談合と予定価格の漏洩。
- **PoCで示すこと:** 封印した入札とコミットした予定価格。開示された入札はすべて公開され、分析で談合のパターンを見つけられる。
- **指標:** 予定価格の漏洩の可能性(目標0)。模擬データで見つかる談合のパターン。

### 7. 補助金・給付金の不正受給(公的、B)
- **問題:** コロナ禍の補助金の不正申請。
- **PoCで示すこと:** 交付と補助対象の経費は、登録済みのアドレスの間のオンチェーンの支払い。循環する流れ(交付 → 業者 → 受給者に戻る)が見つかる。
- **指標:** 模擬の不正パターンを見つけた割合。誤検知。

### 8. 企業からの個人情報の漏洩(リテール、B)
- **問題:** 委託先の内部の人間による大規模な漏洩と、長く気づかれない持ち出し。
- **PoCで示すこと:** 模擬の店舗が年齢をクレデンシャルで確かめ、アドレス、事実、ブロックだけを保持する。署名でログイン。注文コードで配送。アクセスログの毎日のルート。
- **指標:** 顧客ごとに保持する個人情報の項目数(前と後)。ログの改ざんの検知。顧客の手間。

### 9. 年金記録の消失・不一致(リテール、A)
- **問題:** 数千万件の保険料の記録が、本人と結びつけられなかった。
- **PoCで示すこと:** 保険料はすべて被保険者自身のアドレスからの送金。記録が宙に浮くことはない。
- **指標:** 結びつかない保険料(目標0)。転居、海外転出、承継のときの動き。

### 10. 雇用保険の受給中の就労(リテール、B)
- **問題:** 不正受給が遅れて、またはまったく見つからない。
- **PoCで示すこと:** 受給期間中の新しい社員証の発行や給与の入金が(同意に基づき)見える。
- **指標:** 模擬の事例での検知率と遅れ。プライバシーの代償。

### 11. 2つ目のアドレスによるお金の隠匿(リテール/公的、A/B)
- **問題:** 申告しない資産、支払いの小分け、仲介者を通じた賄賂。
- **PoCで示すこと:** 合計額の上限と要人の上限0。親族を通じた残る経路と、公開の流れの分析でどこまで見つかるか。
- **指標:** 期間ごとに記録の外へ動かせる額。往復の検知率。日常の使いやすさ(「現金並み」)。

### 12. 土地取引でのなりすまし(地面師)(高額、A)
- **問題:** 偽造の本人確認書類で、自分のものではない土地を売る。
- **PoCで示すこと:** 所有者の鍵だけを持つ盗人は、代理人なしには移転できない。アトミック決済で決済リスクがなくなる。
- **指標:** なりすましの成功(目標0)。今と比べた売買の手順、時間、費用。

### 13. 所有者不明と相続の停滞(高額、A)
- **問題:** 相続や住所変更が登記されず、所有者が見つからない。
- **PoCで示すこと:** 転居で記録が古くならない。死亡が見える。重い手続きで土地とお金を相続人へ移し、持分に分ける。
- **指標:** 所有者のたどりやすさ。重い手続きの時間と手順。失敗する場合(海外の相続人、鍵の紛失)。

### 14. 公開データからの家の買主の特定(高額、B)— 設計を覆しうるテスト
- **問題:** レビューR5.3: 公開される保有者から買った人は特定されうる。
- **PoCで示すこと:** 公開データ(公開された土地、移転、時期)から、個人の所有者の住まいがどれくらい特定されるか。
- **指標:** 特定率。何がそれを下げるか。

### 15. ペーパーカンパニーと隠れた実質的支配者(高額、B)
- **問題:** 重層的な所有が、誰が法人を支配しているかを隠す。
- **PoCで示すこと:** 法人、ファンド、信託を通じて個人まで保有をたどる。土地についての外国人支配50%の判定。
- **指標:** 最終的な所有者を特定するまでの時間。残る経路(名義株)。

### 16. 高額な資産の鍵の紛失と盗難(高額、A)— 設計を覆しうるテスト
- **問題:** 鍵の紛失で家が動かせなくなり、鍵の盗難で家を売られうる。
- **PoCで示すこと:** 停止、重い手続き、代理人。紙の権利証と比べて回復がどれだけ重いか。
- **指標:** 回復の時間と手順。残る損失。裁判所と市区町村の負担。

### 17. 全国規模の上場株式の決済(高額、B)
- **問題:** すべての上場株式の毎日の差し引き決済は量が大きく、チェーンの処理能力が制約になる(ADR 0030)。
- **PoCで示すこと:** 現実的な量での1日分の決済のガス代と時間。失敗の切り離し。
- **指標:** 1日あたりの費用と所要時間。候補のチェーンでの実現性。

### 18. 選挙の公正(公的、C)
- **問題:** 集計漏れや数え間違い、検証できない集計。
- **PoCで示すこと(限定的):** 今は資格、二重投票の防止、承継のルール。検証できる暗号化された集計は、本物の暗号ライブラリを組み込んでから。
- **指標:** 二重投票(目標0)。それ以外は後回し。

## 最初の選定の提案

今のコントラクトか小さなスクリプトで動き、3つの区分をすべて含む12件: **1、2、3、4、8、9、11、12、13、14、15、16**。14と16は、作業仮説が高額の用途で予想するとおり設計を覆しうるので、意図して入れた。5、6、7、10、17は追加の候補としてよい。18は暗号を待つ。

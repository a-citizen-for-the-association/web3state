# Glossary

Shared vocabulary between real-world state concepts and their technical counterparts in this project. Add an entry whenever a new term is introduced in discussion that isn't obvious from either side alone. Keep entries short; link to `docs/state-design/` for full design detail.

| Term | Real-world meaning | Technical counterpart | Notes |
|---|---|---|---|
| Resident (住民) | A person registered in a municipality's 住民基本台帳, any nationality | `ResidentLink` NFT (soulbound, per-municipality) | See [`docs/state-design/citizenship/`](state-design/citizenship/) |
| National (国民) | A person holding Japanese nationality (国籍法, 戸籍) | *Deliberately has no on-chain credential* — verified off-chain only, wherever it matters (e.g. passport issuance) | Whether to ever represent this on-chain is deferred to a future "foreign residents" topic — see [`docs/BACKLOG.md`](BACKLOG.md) and [ADR 0006](decisions/0006-passport-credential.md) |
| Citizen | (Ambiguous — avoid in design docs; use Resident or National explicitly) | — | This project distinguishes 住民/国民; "citizen" conflates them |
| Corporation (法人) | A juridical person under 会社法 etc. — not a sole proprietor | Authority-issued, soulbound, on-chain registration NFT (a corporation may hold several, one per authority) | See [`docs/state-design/corporations/`](state-design/corporations/), [ADR 0005](decisions/0005-corporate-registration-model.md) |
| Passport (パスポート) | A travel document issued by 外務省 to Japanese nationals | Soulbound, possession-only NFT; nationality verified off-chain at mint time, no on-chain fields | See [`docs/state-design/credentials/passport/`](state-design/credentials/passport/), [ADR 0006](decisions/0006-passport-credential.md) |
| Diploma (卒業証明) | A degree/graduation certificate issued by a school | Soulbound, possession-only NFT issued from the school's existing corporate-registration address; requires holding `ResidentLink` at mint time (any nationality) | See [`docs/state-design/credentials/diploma/`](state-design/credentials/diploma/), [ADR 0007](decisions/0007-diploma-credential.md) |
| License (免許証) | A driver's license issued by a prefectural 公安委員会 | Soulbound, possession-only NFT (single contract per prefecture, no per-vehicle-class split); suspension and revocation both represented as burn; requires `ResidentLink` at mint time | See [`docs/state-design/credentials/license/`](state-design/credentials/license/), [ADR 0008](decisions/0008-license-credential.md) |
| Health insurance card (健康保険証) | Proof of enrollment in a public health insurance scheme (国民健康保険, 協会けんぽ, 組合健保, etc.) | Soulbound, possession-only NFT (one contract per insurer); continuous status (mint on enrollment, burn on disenrollment), not periodically renewed; requires `ResidentLink` at mint time | See [`docs/state-design/credentials/health-insurance/`](state-design/credentials/health-insurance/), [ADR 0009](decisions/0009-health-insurance-credential.md) |
| Employee ID (社員証) | Proof of current employment at a company | Soulbound, possession-only NFT issued from the employer's existing corporate-registration address (sole proprietors can't issue it); continuous status; **no** `ResidentLink` requirement | See [`docs/state-design/credentials/employee-id/`](state-design/credentials/employee-id/), [ADR 0010](decisions/0010-employee-id-credential.md) |
| Vaccination coupon (接種券) | A municipality-issued voucher entitling a resident to a specific vaccine; hospitals mark it administered | Soulbound NFT **with a status field** (`Issued`/`Vaccinated`) — the first credential besides corporations with real on-chain state; hospitals holding `VACCINATOR_ROLE` (gated on holding a corporate registration) flip the status; `Vaccinated` is never burned | See [`docs/state-design/credentials/vaccination/`](state-design/credentials/vaccination/), [ADR 0011](decisions/0011-vaccination-credential.md) |
| Voting / Election (投票・選挙) | Casting and tallying votes for a referendum or a candidate/party election | A generic `Election` contract: one-hot encrypted ballots, homomorphic per-option summation, threshold decryption of only the final totals; voter casts from their existing `ResidentLink` address | See [`docs/state-design/voting/`](state-design/voting/), [ADR 0013](decisions/0013-voting-model.md) |
| Threshold decryption (閾値復号) | A decryption key split across multiple trustees so no single party can decrypt alone | Used to reveal only the final aggregate per-option vote totals — never an individual ballot | See [`docs/state-design/voting/`](state-design/voting/), [ADR 0013](decisions/0013-voting-model.md) |
| Constitution | The foundational rules a state operates under | *TBD — likely maps to immutable/hard-to-upgrade contract logic and project governance* | — |

*(This table is intentionally sparse — it grows as real design work in `docs/state-design/` happens.)*

---

# 用語集(日本語)

国家の概念と、このプロジェクトにおける技術的な対応物との共通語彙集です。どちらか一方だけでは自明でない新しい用語が議論で出てきたら追加してください。エントリは簡潔に保ち、詳細設計は `docs/state-design/` にリンクします。

| 用語 | 現実世界での意味 | 技術的な対応物 | 備考 |
|---|---|---|---|
| 住民(Resident) | 市区町村の住民基本台帳に登録された者(国籍を問わない) | `ResidentLink` NFT(譲渡不可、市区町村ごとに発行) | [`docs/state-design/citizenship/`](state-design/citizenship/) 参照 |
| 国民(National) | 日本国籍を有する者(国籍法、戸籍) | *意図的にオンチェーンのクレデンシャルを持たない* — 必要な場面(パスポート発行等)では常にオフチェーンでのみ確認する | いつかオンチェーンで表現すべきかは、将来の「外国人」検討項目として先送り — [`docs/BACKLOG.md`](BACKLOG.md)、[ADR 0006](decisions/0006-passport-credential.md) 参照 |
| 市民(Citizen) | (曖昧な用語 — 設計文書での使用は避ける。住民/国民を明示的に使う) | — | 本プロジェクトは住民/国民を区別するため、両者を混同する「市民」は使わない |
| 法人(Corporation) | 会社法等に基づく法人格を持つ主体 — 個人事業主は含まない | 発行主体ごとの、譲渡不可・オンチェーンの登録NFT(法人は主体ごとに複数保有可) | [`docs/state-design/corporations/`](state-design/corporations/)、[ADR 0005](decisions/0005-corporate-registration-model.md) 参照 |
| パスポート(Passport) | 外務省が日本国民に発行する渡航文書 | 譲渡不可、保持のみを証明するNFT。mint時に国籍をオフチェーンで確認、オンチェーンのフィールドはなし | [`docs/state-design/credentials/passport/`](state-design/credentials/passport/)、[ADR 0006](decisions/0006-passport-credential.md) 参照 |
| 卒業証明(Diploma) | 学校が発行する学位・卒業証明 | 学校の既存の法人登録アドレスから発行する、譲渡不可・保持のみを証明するNFT。mint時に`ResidentLink`の保有を要件とする(国籍を問わない) | [`docs/state-design/credentials/diploma/`](state-design/credentials/diploma/)、[ADR 0007](decisions/0007-diploma-credential.md) 参照 |
| 免許証(License) | 都道府県の公安委員会が発行する運転免許証 | 譲渡不可・保持のみを証明するNFT(都道府県ごとに1コントラクト、車両区分での分割なし)。停止・取消はいずれもburnとして表現。mint時に`ResidentLink`を要件とする | [`docs/state-design/credentials/license/`](state-design/credentials/license/)、[ADR 0008](decisions/0008-license-credential.md) 参照 |
| 健康保険証(Health Insurance Card) | 公的医療保険(国民健康保険、協会けんぽ、組合健保等)への加入の証明 | 譲渡不可・保持のみを証明するNFT(保険者ごとに1コントラクト)。継続的な状態(mint=加入、burn=脱退)で、定期更新ではない。mint時に`ResidentLink`を要件とする | [`docs/state-design/credentials/health-insurance/`](state-design/credentials/health-insurance/)、[ADR 0009](decisions/0009-health-insurance-credential.md) 参照 |
| 社員証(Employee ID) | 会社における現在の雇用の証明 | 雇用主の既存の法人登録アドレスから発行する、譲渡不可・保持のみを証明するNFT(個人事業主は発行不可)。継続的な状態。`ResidentLink`の要件は**なし** | [`docs/state-design/credentials/employee-id/`](state-design/credentials/employee-id/)、[ADR 0010](decisions/0010-employee-id-credential.md) 参照 |
| 接種券(Vaccination Coupon) | 市区町村が発行する、住民に特定のワクチンを受ける権利を与える引換券。病院が接種済みとしてマーキングする | **状態フィールドを持つ**譲渡不可のNFT(`Issued`/`Vaccinated`) — 法人を除き、実質的なオンチェーンの状態を持つ初めてのクレデンシャル。`VACCINATOR_ROLE`を持つ病院(法人登録の保有が条件)がステータスを変更する。`Vaccinated`は決してburnしない | [`docs/state-design/credentials/vaccination/`](state-design/credentials/vaccination/)、[ADR 0011](decisions/0011-vaccination-credential.md) 参照 |
| 投票・選挙(Voting / Election) | 住民投票や候補者・政党選挙における投票の実施・集計 | 汎用的な`Election`コントラクト: ワンホット暗号化された投票、選択肢ごとの準同型合計、最終的な合計のみの閾値復号。投票者は既存の`ResidentLink`アドレスから投票する | [`docs/state-design/voting/`](state-design/voting/)、[ADR 0013](decisions/0013-voting-model.md) 参照 |
| 閾値復号(Threshold decryption) | 復号鍵を複数の信頼主体に分散し、単独では誰も復号できないようにする仕組み | 最終的な各選択肢の得票合計のみを明らかにするために使用 — 個々の投票を復号することは決してない | [`docs/state-design/voting/`](state-design/voting/)、[ADR 0013](decisions/0013-voting-model.md) 参照 |
| 憲法(Constitution) | 国家が従う根本規則 | *未定 — おそらく不変/アップグレードしにくいコントラクトロジックとプロジェクトガバナンスに対応* | — |

*(このテーブルは意図的に空に近い状態にしてあります。`docs/state-design/` での実際の設計作業が進むにつれて増えていきます。)*

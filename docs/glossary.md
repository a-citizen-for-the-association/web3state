# Glossary

Shared vocabulary between real-world state concepts and their technical counterparts in this project. Add an entry whenever a new term is introduced in discussion that isn't obvious from either side alone. Keep entries short; link to `docs/state-design/` for full design detail.

| Term | Real-world meaning | Technical counterpart | Notes |
|---|---|---|---|
| Resident (住民) | A person registered in a municipality's 住民基本台帳, any nationality | `ResidentLink` NFT (soulbound, per-municipality) | See [`docs/state-design/citizenship/`](state-design/citizenship/) |
| National (国民) | A person holding Japanese nationality (国籍法, 戸籍) | *Deliberately has no on-chain credential* — verified off-chain only, wherever it matters (e.g. passport issuance) | Whether to ever represent this on-chain is deferred to a future "foreign residents" topic — see [`docs/BACKLOG.md`](BACKLOG.md) and [ADR 0006](decisions/0006-passport-credential.md) |
| Citizen | (Ambiguous — avoid in design docs; use Resident or National explicitly) | — | This project distinguishes 住民/国民; "citizen" conflates them |
| Corporation (法人) | A juridical person under 会社法 etc. — not a sole proprietor | Authority-issued, soulbound, on-chain registration NFT (a corporation may hold several, one per authority) | See [`docs/state-design/corporations/`](state-design/corporations/), [ADR 0005](decisions/0005-corporate-registration-model.md) |
| Passport (パスポート) | A travel document issued by 外務省 to Japanese nationals | Soulbound, possession-only NFT; nationality verified off-chain at mint time, no on-chain fields | See [`docs/state-design/credentials/passport/`](state-design/credentials/passport/), [ADR 0006](decisions/0006-passport-credential.md) |
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
| 憲法(Constitution) | 国家が従う根本規則 | *未定 — おそらく不変/アップグレードしにくいコントラクトロジックとプロジェクトガバナンスに対応* | — |

*(このテーブルは意図的に空に近い状態にしてあります。`docs/state-design/` での実際の設計作業が進むにつれて増えていきます。)*

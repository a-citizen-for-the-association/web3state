# Glossary

Shared vocabulary between real-world state concepts and their technical counterparts in this project. Add an entry whenever a new term is introduced in discussion that isn't obvious from either side alone. Keep entries short; link to `docs/state-design/` for full design detail.

| Term | Real-world meaning | Technical counterpart | Notes |
|---|---|---|---|
| Resident (住民) | A person registered in a municipality's 住民基本台帳, any nationality | `ResidentLink` NFT (soulbound, per-municipality) | See [`docs/state-design/citizenship/`](state-design/citizenship/) |
| National (国民) | A person holding Japanese nationality (国籍法, 戸籍) | *Not yet designed — deliberately separate from the Resident NFT; a future purpose-specific credential* | The base `ResidentLink` NFT makes no nationality claim — see [ADR 0003](decisions/0003-resident-link-identity-model.md) |
| Citizen | (Ambiguous — avoid in design docs; use Resident or National explicitly) | — | This project distinguishes 住民/国民; "citizen" conflates them |
| Constitution | The foundational rules a state operates under | *TBD — likely maps to immutable/hard-to-upgrade contract logic and project governance* | — |

*(This table is intentionally sparse — it grows as real design work in `docs/state-design/` happens.)*

---

# 用語集(日本語)

国家の概念と、このプロジェクトにおける技術的な対応物との共通語彙集です。どちらか一方だけでは自明でない新しい用語が議論で出てきたら追加してください。エントリは簡潔に保ち、詳細設計は `docs/state-design/` にリンクします。

| 用語 | 現実世界での意味 | 技術的な対応物 | 備考 |
|---|---|---|---|
| 住民(Resident) | 市区町村の住民基本台帳に登録された者(国籍を問わない) | `ResidentLink` NFT(譲渡不可、市区町村ごとに発行) | [`docs/state-design/citizenship/`](state-design/citizenship/) 参照 |
| 国民(National) | 日本国籍を有する者(国籍法、戸籍) | *未設計 — 意図的にResident NFTとは別物とする。将来の目的別クレデンシャルとして設計予定* | ベースとなる `ResidentLink` NFTは国籍を一切主張しない。[ADR 0003](decisions/0003-resident-link-identity-model.md) 参照 |
| 市民(Citizen) | (曖昧な用語 — 設計文書での使用は避ける。住民/国民を明示的に使う) | — | 本プロジェクトは住民/国民を区別するため、両者を混同する「市民」は使わない |
| 憲法(Constitution) | 国家が従う根本規則 | *未定 — おそらく不変/アップグレードしにくいコントラクトロジックとプロジェクトガバナンスに対応* | — |

*(このテーブルは意図的に空に近い状態にしてあります。`docs/state-design/` での実際の設計作業が進むにつれて増えていきます。)*

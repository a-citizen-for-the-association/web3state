# Documentation Map

This project is expected to grow large (a nation-state's institutional functions, implemented as smart contracts, is a big design space). This directory is organized so that two questions are always answerable:

1. **Where are we right now?** → [`PROJECT_STATUS.md`](PROJECT_STATUS.md)
2. **Why did we get here?** → [`decisions/`](decisions/) (ADRs — immutable, dated decision records)

## Structure

| Path | Purpose |
|---|---|
| [`PROJECT_STATUS.md`](PROJECT_STATUS.md) | Living document: current phase, what's decided, open questions, next steps. Updated often. |
| [`decisions/`](decisions/) | Architecture Decision Records (ADRs). Immutable once accepted — superseded by new ADRs, never edited in place. |
| [`architecture/`](architecture/) | System design: how contracts, frontend, and chains fit together. |
| [`state-design/`](state-design/) | Mapping real-world state functions (law, administration, governance) to on-chain/off-chain design. |
| [`operations/`](operations/) | Convention for classifying work as online / on-chain / offline, and tracking it. |
| [`glossary.md`](glossary.md) | Shared vocabulary between real-world state concepts and their technical counterparts. |

## Why this split (ADR vs. STATUS vs. CHANGELOG)

These three serve different, non-overlapping purposes — don't merge them:

- **`CHANGELOG.md`** (repo root): *what* changed, chronologically. Code-level.
- **`decisions/*.md`**: *why* a non-trivial choice was made, at the time it was made. Never rewritten after acceptance — if a decision changes, write a new ADR that supersedes the old one.
- **`PROJECT_STATUS.md`**: *where things stand right now* — a snapshot, expected to be rewritten often.

---

# ドキュメントマップ(日本語)

このプロジェクトは大規模化することが予想されます(国家の仕組みをスマートコントラクトとして実装するというデザイン空間は広大です)。このディレクトリは、常に次の2つの問いに答えられるように構成されています。

1. **今どこにいるか?** → [`PROJECT_STATUS.md`](PROJECT_STATUS.md)
2. **なぜここに至ったか?** → [`decisions/`](decisions/)(ADR — 日付付きの不変な決定記録)

## 構成

| パス | 目的 |
|---|---|
| [`PROJECT_STATUS.md`](PROJECT_STATUS.md) | 生きたドキュメント。現在のフェーズ、決定済み事項、未解決の論点、次のステップ。頻繁に更新される。 |
| [`decisions/`](decisions/) | ADR(Architecture Decision Record)。一度確定したら書き換えず、変更する場合は新しいADRで上書き(supersede)する。 |
| [`architecture/`](architecture/) | システム設計: コントラクト・フロントエンド・対象チェーンの関係。 |
| [`state-design/`](state-design/) | 現実の国家機能(法律・行政・統治)をオンチェーン/オフチェーン設計へマッピングする。 |
| [`operations/`](operations/) | オンライン/オンチェーン/オフラインの作業分類の規約とトラッキング方法。 |
| [`glossary.md`](glossary.md) | 国家の概念と技術的実装の対応表(共通語彙集)。 |

## なぜADR・STATUS・CHANGELOGを分けるか

それぞれ役割が異なり重複しません。混ぜないでください:

- **`CHANGELOG.md`**(リポジトリ直下): *何が*変わったか、時系列で。コードレベル。
- **`decisions/*.md`**: *なぜ*その時点でその重要な選択をしたか。確定後は書き換えない。変更する場合は上書きする新しいADRを書く。
- **`PROJECT_STATUS.md`**: *今どういう状態か* のスナップショット。頻繁に書き換えられる想定。

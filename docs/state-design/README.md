# State Design

This directory holds the mapping from real-world nation-state functions — law, public administration, political decision-making — to their on-chain/off-chain implementation design.

**Status: initial design complete (2026-11-14).** Every non-⏸ item in [`docs/FEATURES.md`](../FEATURES.md) has a spec; the cross-feature consistency review is in [`docs/architecture/consistency-review.md`](../architecture/consistency-review.md). See `docs/FEATURES.md` for the status of every function.

## Convention

One subdirectory per state function (e.g. [`citizenship/`](citizenship/), [`real-estate/`](real-estate/)), containing:
- `discussion-log.md` — the back-and-forth with the user, round by round (the format follows [`citizenship/discussion-log.md`](citizenship/discussion-log.md));
- `README.md` — the spec, written once the issues are resolved.

A function with several sub-features may nest them (e.g. [`credentials/`](credentials/) with one subdirectory per credential type).

Each spec should, at minimum:
1. Describe the real-world function being modeled (and its legal/institutional reference, if any).
2. State what is implemented on-chain vs. what stays online or offline, and why (see [`docs/operations/README.md`](../operations/README.md)).
3. Link to the relevant contract module(s) once they exist.
4. Link to any ADR that fixed a hard-to-reverse design choice for this function.

Every document has a Japanese translation below the English.

---

# 国家機能の設計(日本語)

このディレクトリには、現実の国家機能(法律・行政・政治的意思決定)を、オンチェーン/オフチェーンの実装設計へマッピングした内容を格納する。

**ステータス: 初期設計は完了(2026-11-14)。** [`docs/FEATURES.md`](../FEATURES.md)の⏸以外のすべての項目に仕様がある。機能間の整合性レビューは[`docs/architecture/consistency-review.md`](../architecture/consistency-review.md)にある。各機能のステータスは`docs/FEATURES.md`を参照。

## 規約

国家機能ごとに1つのサブディレクトリ(例: [`citizenship/`](citizenship/)、[`real-estate/`](real-estate/))を置き、次を入れる:
- `discussion-log.md` — ユーザーとのやり取りをRoundごとに記録する(形式は[`citizenship/discussion-log.md`](citizenship/discussion-log.md)に従う)。
- `README.md` — 論点が解決した後に書く仕様。

複数の下位機能を持つ機能は、入れ子にしてよい(例: [`credentials/`](credentials/)の下に証明の種類ごとのサブディレクトリ)。

各仕様には最低限以下を記載する:
1. モデル化する現実の機能の説明(該当する法制度・制度上の参照があれば)。
2. 何をオンチェーンで実装し、何をオンラインまたはオフラインに残すか、その理由([`docs/operations/README.md`](../operations/README.md)参照)。
3. 実装後、関連するコントラクトモジュールへのリンク。
4. その機能について後戻りしにくい設計判断を行った場合、該当ADRへのリンク。

すべての文書は、英語の下に日本語訳を置く。

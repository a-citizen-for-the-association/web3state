# State Design

This directory will hold the mapping from real-world nation-state functions — law, public administration, political decision-making — to their on-chain/off-chain implementation design.

**Status: in progress.** See [`docs/FEATURES.md`](../FEATURES.md) for the up-to-date status of every function. First function under discussion: [`citizenship/`](citizenship/) (国民・住民).

## Suggested convention (to confirm once the first function is scoped)

One file (or subdirectory, if it grows large) per state function, e.g.:

- `citizenship.md` — identity, registration, eligibility
- `legislative.md` — proposal, deliberation, enactment of rules
- `executive.md` — administration, enforcement
- `judiciary.md` — dispute resolution, appeals
- `treasury.md` — public funds, taxation, spending

Each should, at minimum:
1. Describe the real-world function being modeled (and its legal/institutional reference, if any).
2. State what is implemented on-chain vs. what must stay off-chain, and why (see [`docs/operations/README.md`](../operations/README.md)).
3. Link to the relevant contract module(s) once they exist.
4. Link to any ADR that fixed a hard-to-reverse design choice for this function.

Do not create these files speculatively — add one only when a function is actually being designed.

---

# 国家機能の設計(日本語)

このディレクトリには、現実の国家機能(法律・行政・政治的意思決定)を、オンチェーン/オフチェーンの実装設計へマッピングした内容を格納します。

**ステータス: 進行中。** 各機能の最新ステータスは [`docs/FEATURES.md`](../FEATURES.md) を参照してください。現在議論中の最初の機能: [`citizenship/`](citizenship/)(国民・住民)。

## 想定する規約(最初の機能がスコープされた時点で確定)

国家機能ごとに1ファイル(肥大化する場合はサブディレクトリ)、例:

- `citizenship.md` — 本人確認、登録、資格
- `legislative.md` — 提案、審議、制定
- `executive.md` — 行政、執行
- `judiciary.md` — 紛争解決、不服申立て
- `treasury.md` — 公的資金、課税、支出

各ファイルには最低限以下を記載します:
1. モデル化する現実の機能の説明(該当する法制度・制度上の参照があれば)。
2. 何をオンチェーンで実装し、何をオフチェーンに残すか、その理由([`docs/operations/README.md`](../operations/README.md) 参照)。
3. 実装後、関連するコントラクトモジュールへのリンク。
4. その機能について後戻りしにくい設計判断を行った場合、該当ADRへのリンク。

先回りしてファイルを作らず、実際にその機能を設計するタイミングで追加してください。

# Contributing

This project moves by discussion and trial-and-error. These conventions exist so that decisions and history stay legible to people who join later.

## Before you start

1. Read [`docs/PROJECT_STATUS.md`](docs/PROJECT_STATUS.md) for the current phase and open questions.
2. Skim [`docs/decisions/`](docs/decisions/) for past decisions and their rationale.
3. For contract work, see [`contracts/README.md`](contracts/README.md). For frontend work, see [`frontend/README.md`](frontend/README.md).

## Recording decisions

Any non-trivial, hard-to-reverse decision (architecture, chain selection, contract module boundaries, data model) should get an **Architecture Decision Record (ADR)** in `docs/decisions/`, using [`docs/decisions/template.md`](docs/decisions/template.md). Small, easily reversible choices don't need one.

## Commit messages

```
<type>: <description>

<optional body>
```

Types: `feat`, `fix`, `refactor`, `docs`, `test`, `chore`, `perf`, `ci`.

## Pull requests

1. Keep PRs scoped to one logical change.
2. Update `CHANGELOG.md` under `[Unreleased]`.
3. If the change affects a decision already recorded in `docs/decisions/`, add a new ADR that supersedes the old one rather than editing history.
4. Update `docs/PROJECT_STATUS.md` if the change moves the project into a new phase or resolves/raises an open question.

## Classifying work: online / on-chain / offline

Because this project models real institutional functions, every feature should be clear about which parts are:
- **on-chain** (smart contract state/logic),
- **online** (the web app / any off-chain server logic), and
- **offline** (actions a human must take in the physical/legal world — filing paperwork, a vote happening in person, etc.).

See [`docs/operations/README.md`](docs/operations/README.md) for the convention and a template.

---

# コントリビュート(日本語)

このプロジェクトは議論と試行錯誤を重ねながら進みます。以下のルールは、後から参加する人にも決定の経緯や現状が分かるようにするためのものです。

## 始める前に

1. [`docs/PROJECT_STATUS.md`](docs/PROJECT_STATUS.md) で現在のフェーズと未解決の論点を確認してください。
2. [`docs/decisions/`](docs/decisions/) で過去の決定とその理由を確認してください。
3. コントラクト作業は [`contracts/README.md`](contracts/README.md)、フロントエンド作業は [`frontend/README.md`](frontend/README.md) を参照してください。

## 決定の記録

アーキテクチャ、チェーン選定、コントラクトのモジュール境界、データモデルなど、後から覆しにくい重要な決定は [`docs/decisions/template.md`](docs/decisions/template.md) を使って `docs/decisions/` にADR(Architecture Decision Record)として記録してください。小さく後から簡単に覆せる選択には不要です。

## コミットメッセージ

```
<type>: <description>

<任意の本文>
```

type: `feat`, `fix`, `refactor`, `docs`, `test`, `chore`, `perf`, `ci`

## プルリクエスト

1. 1つのPRは1つの論理的な変更にスコープを絞る。
2. `CHANGELOG.md` の `[Unreleased]` を更新する。
3. 既に記録されているADRの内容を変更する場合は、過去の記録を書き換えるのではなく、それを上書き(supersede)する新しいADRを追加する。
4. プロジェクトが新しいフェーズに進んだり、未解決の論点が増減した場合は `docs/PROJECT_STATUS.md` を更新する。

## 作業の分類: オンライン・オンチェーン・オフライン

このプロジェクトは現実の国家機能をモデル化するため、各機能について以下を明確にしてください:
- **オンチェーン**(スマートコントラクトの状態・ロジック)
- **オンライン**(Webアプリ・オフチェーンのサーバーロジック)
- **オフライン**(人間が現実世界・法制度上で行う必要がある行為)

詳細は [`docs/operations/README.md`](docs/operations/README.md) を参照してください。

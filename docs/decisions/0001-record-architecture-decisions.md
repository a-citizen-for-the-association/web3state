# 0001. Record architecture decisions

**Date:** 2026-10-03
**Status:** Accepted

## Context

This project is expected to grow into a large, long-running effort (modeling the institutional functions of a nation-state as smart contracts), with people joining after major decisions have already been made. Without a record, the reasoning behind past choices gets lost, and the project risks re-litigating settled questions or silently drifting from its original intent.

## Decision

We will use lightweight Architecture Decision Records (ADRs), stored in `docs/decisions/`, for any decision that is expensive to reverse. Each ADR is numbered sequentially, dated, and immutable once accepted — changes are made by superseding, not editing.

## Consequences

- Anyone joining the project can read `docs/decisions/` in order to understand how the current architecture came to be.
- Decisions carry an explicit paper trail separate from code history (git log) and from the living status snapshot (`docs/PROJECT_STATUS.md`).
- Adds a small amount of process overhead for significant decisions; day-to-day implementation choices are explicitly exempted (see `docs/decisions/README.md`).

---

# 0001. アーキテクチャ上の決定を記録する(日本語)

**日付:** 2026-10-03
**ステータス:** Accepted

## 背景

このプロジェクトは、大規模で長く続く取り組み(国家の制度的な機能をスマートコントラクトとしてモデル化する)に育つと見込まれ、主要な決定がなされた後から人が加わる。記録がなければ、過去の選択の理由は失われる。決着済みの問題を蒸し返したり、気づかないうちに当初の意図からずれたりするおそれがある。

## 決定

覆すのにコストがかかる決定には、軽量なArchitecture Decision Record(ADR)を使い、`docs/decisions/`に保存する。各ADRは連番を振り、日付を付け、承認後は変更しない。変更は編集ではなく、後継のADRで置き換えて行う。

## 結果

- プロジェクトに加わる人は誰でも、`docs/decisions/`を順に読めば、現在のアーキテクチャがどう形づくられたかを理解できる。
- 決定には、コードの履歴(git log)とも、随時更新される状況のスナップショット(`docs/PROJECT_STATUS.md`)とも別の、明示的な記録が残る。
- 重要な決定には少しの手続きの負担が増える。日々の実装上の選択は明示的に対象外とする(`docs/decisions/README.md`を参照)。

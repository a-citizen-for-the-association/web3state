# Architecture Decision Records (ADRs)

This directory records significant, hard-to-reverse decisions, in the order they were made, together with the reasoning at the time.

## Rules

- **Never edit an accepted ADR's decision after the fact.** If circumstances change, write a new ADR that supersedes it, and mark the old one's status as `Superseded by ADR-00NN`.
- Number sequentially: `0001-`, `0002-`, ...
- Use [`template.md`](template.md).
- Not every decision needs one — reserve these for things that are expensive to reverse (chain selection, contract module boundaries, data model, governance model, major dependency choices). Day-to-day implementation choices don't need an ADR.

## Index

| # | Title | Status |
|---|---|---|
| [0001](0001-record-architecture-decisions.md) | Record architecture decisions | Accepted |
| [0002](0002-initial-stack-and-structure.md) | Initial stack and repository structure | Accepted |
| [0003](0003-resident-link-identity-model.md) | Resident-link identity model for citizenship/residency | Accepted |
| [0004](0004-taxation-payment-rail.md) | Taxation payment rail: direct, resident-initiated payments only, no dedicated contract | Accepted |
| [0005](0005-corporate-registration-model.md) | Corporate registration model: authority-issued, on-chain, officer-name-only NFT | Accepted |
| [0006](0006-passport-credential.md) | Passport credential: pure travel document, nationality verified off-chain | Accepted |

---

# ADR(日本語)

このディレクトリには、後から覆すのにコストがかかる重要な決定を、決定した順番とその時点での理由とともに記録します。

## ルール

- **一度確定(Accepted)したADRの決定内容は後から書き換えない。** 状況が変わった場合は、それを上書き(supersede)する新しいADRを書き、古い方のステータスを `Superseded by ADR-00NN` にする。
- 番号は連番: `0001-`, `0002-`, ...
- [`template.md`](template.md) を使用する。
- 全ての決定にADRが必要なわけではない。後から覆すコストが高いもの(チェーン選定、コントラクトのモジュール境界、データモデル、ガバナンスモデル、主要な依存関係の選定)に限定する。日々の実装上の選択は不要。

# Credentials (公的証明: 卒業証明・パスポート・免許証・社員証・医療証・接種証明等)

**Status: 🟡 Discussing.** Not yet specified — see [`discussion-log.md`](discussion-log.md) for the open issues raised before implementation.

## One-line summary of the user's proposal (as of 2026-10-03)

Any issuer of a public certification (school, government licensing body, employer, health insurer, etc.) has a corporation-like blockchain address (reusing the pattern from [corporations](../corporations/)), and deploys/controls the contract that mints the relevant credential NFT to a holder. The aim: diplomas, passports, licenses, employee IDs, health-insurance certificates, vaccination certificates, and similar documents can all eventually be issued and managed this way.

## Why this isn't specified yet

See [`discussion-log.md`](discussion-log.md) — the listed examples span very different issuer trust models (government bodies, accredited schools, private employers, quasi-public insurance associations) and very different data-sensitivity levels (a diploma vs. a vaccination record), so a single undifferentiated "put it all on an NFT" design likely needs to branch by credential type rather than being one uniform mechanism.

---

# 公的証明(日本語)

**ステータス: 🟡 議論中。** まだ仕様は確定していません。実装前に提起した論点は [`discussion-log.md`](discussion-log.md) を参照してください。

## ユーザー提案の要約(2026-10-03時点)

公的証明の発行主体(学校、免許を所管する官公庁、雇用主、健康保険組合等)は、[法人設計](../corporations/)と同じパターンの、法人に類するブロックチェーンアドレスを持ち、該当する証明NFTを発行するコントラクトをデプロイ・管理する。目指す世界: 卒業証明、パスポート、免許証、社員証、健康保険証、ワクチン接種証明等を、全てこの方法で発行・運用できるようにする。

## まだ仕様化していない理由

[`discussion-log.md`](discussion-log.md) を参照してください。挙げられた例は、発行主体の信頼モデル(政府機関、認定された学校、民間の雇用主、準公的な保険組合)も、データの機微性(卒業証明とワクチン接種記録では全く違う)も大きく異なるため、「全てを一律にNFT化する」という単一の仕組みでは足りず、証明の種類ごとに枝分かれした設計が必要になりそうです。

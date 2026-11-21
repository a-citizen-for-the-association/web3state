# Credentials (公的証明: 卒業証明・パスポート・免許証・社員証・医療証・接種証明等)

**Status: 🟢 Spec drafted (per credential type).** The general pattern was resolved in [`discussion-log.md`](discussion-log.md); each credential type has its own spec: [passport](passport/), [diploma](diploma/), [license](license/), [health insurance](health-insurance/), [employee ID](employee-id/), [vaccination](vaccination/) (ADRs 0006–0011). The age-threshold credentials are specified in [personal data](../personal-data/) ([ADR 0028](../../decisions/0028-personal-data-model.md)). Credentials-wide rules added by the [consistency review](../../architecture/consistency-review.md): re-issue to a successor address after a recorded succession (R3.3); burn on death (R3.10).

## One-line summary of the user's proposal (as of 2026-10-03)

Any issuer of a public certification (school, government licensing body, employer, health insurer, etc.) has a corporation-like blockchain address (reusing the pattern from [corporations](../corporations/)), and deploys/controls the contract that mints the relevant credential NFT to a holder. The aim: diplomas, passports, licenses, employee IDs, health-insurance certificates, vaccination certificates, and similar documents can all eventually be issued and managed this way.

## Why it is specified per credential type

See [`discussion-log.md`](discussion-log.md) — the listed examples span very different issuer trust models (government bodies, accredited schools, private employers, quasi-public insurance associations) and very different data-sensitivity levels (a diploma vs. a vaccination record), so the design branches by credential type rather than being one uniform mechanism.

---

# 公的証明(日本語)

**ステータス: 🟢 設計確定(証明の種類ごと)。** 共通の型は[`discussion-log.md`](discussion-log.md)で解決し、種類ごとに仕様がある: [パスポート](passport/)、[卒業証明](diploma/)、[免許証](license/)、[健康保険証](health-insurance/)、[社員証](employee-id/)、[接種証明](vaccination/)(ADR 0006〜0011)。年齢の基準のクレデンシャルは[個人情報](../personal-data/)([ADR 0028](../../decisions/0028-personal-data-model.md))に定める。[整合性レビュー](../../architecture/consistency-review.md)で加えたクレデンシャル共通のルール: 承継が記録されたら承継先のアドレスに再発行する(R3.3)。死亡でburnする(R3.10)。

## ユーザー提案の要約(2026-10-03時点)

公的証明の発行主体(学校、免許を所管する官公庁、雇用主、健康保険組合等)は、[法人設計](../corporations/)と同じパターンの、法人に類するブロックチェーンアドレスを持ち、該当する証明NFTを発行するコントラクトをデプロイ・管理する。目指す世界: 卒業証明、パスポート、免許証、社員証、健康保険証、ワクチン接種証明等を、全てこの方法で発行・運用できるようにする。

## 証明の種類ごとに仕様化した理由

[`discussion-log.md`](discussion-log.md) を参照してください。挙げられた例は、発行主体の信頼モデル(政府機関、認定された学校、民間の雇用主、準公的な保険組合)も、データの機微性(卒業証明とワクチン接種記録では全く違う)も大きく異なるため、「全てを一律にNFT化する」という単一の仕組みではなく、証明の種類ごとに枝分かれした設計にしている。

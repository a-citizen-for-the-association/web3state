# Feature Breakdown Template

Copy this into a feature's design doc under `docs/state-design/` and fill it in. Delete this instruction line.

```markdown
## <Feature name>

**Summary:** <one sentence: what real-world state function this covers>

**On-chain:**
- <state or logic enforced by the smart contract, e.g. "eligibility check before a vote is recorded">

**Online:**
- <logic in the web app / off-chain server, e.g. "renders proposal text and current tally">

**Offline:**
- <action a human must take outside the system, e.g. "applicant submits a notarized identity document to the registrar">

**Open questions:**
- <anything undecided about this feature>

**Related ADRs:** <links, if any>
**Related contract module(s):** <links, once they exist>
```

---

# 機能分解テンプレート(日本語)

これを`docs/state-design/`の下にある機能の設計書にコピーし、記入する。この説明の行は削除する。

```markdown
## <機能名>

**概要:** <一文で: これが担う現実の国家機能>

**オンチェーン:**
- <スマートコントラクトが強制する状態やロジック。例: 「投票を記録する前の資格確認」>

**オンライン:**
- <ウェブアプリやオフチェーンのサーバーのロジック。例: 「議案の本文と現在の集計を表示する」>

**オフライン:**
- <システムの外で人が行う必要がある行為。例: 「申請者が公証された本人確認書類を登録担当者に提出する」>

**未解決の問い:**
- <この機能について未決定のこと>

**関連するADR:** <リンク、あれば>
**関連するコントラクトモジュール:** <リンク、できたら>
```

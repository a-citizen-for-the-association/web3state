# Operations: Online / On-chain / Offline

This project models institutional functions that, in the real world, involve a mix of digital systems and human/physical/legal action. To keep that mix explicit (instead of implicitly assuming everything can be automated on-chain), every feature should classify its parts into three categories:

| Category | Meaning | Example |
|---|---|---|
| **On-chain** | Logic/state enforced by smart contracts | A vote tally, a token balance, an access-control rule |
| **Online** | Logic running in the web app or any off-chain server, but not on a blockchain | Displaying contract state, form validation, notifications |
| **Offline** | Requires a human to act in the physical/legal world | Filing a legal document, a notarized signature, an in-person identity check |

A single feature often has parts in all three. Being explicit about this prevents two failure modes: (1) assuming something can be "just put on-chain" when it legally/practically can't, and (2) losing track of offline steps that a future contributor won't see anywhere in the code.

## When to use this

Whenever a feature is designed in [`docs/state-design/`](../state-design/), include a short breakdown using the template below.

## Template

```markdown
## <Feature name>

**On-chain:**
- ...

**Online:**
- ...

**Offline:**
- ...
```

See [`feature-template.md`](feature-template.md) for a filled-in skeleton.

---

# 運用: オンライン・オンチェーン・オフライン(日本語)

このプロジェクトがモデル化する国家機能は、現実にはデジタルシステムと人間/物理/法制度上の行為が混ざり合っています。「すべてオンチェーンで自動化できる」という暗黙の前提を避けるため、各機能は以下の3カテゴリに分類して明示してください。

| カテゴリ | 意味 | 例 |
|---|---|---|
| **オンチェーン** | スマートコントラクトで強制されるロジック・状態 | 投票集計、トークン残高、アクセス制御ルール |
| **オンライン** | Webアプリやオフチェーンサーバー上で動くが、ブロックチェーン上ではないロジック | コントラクト状態の表示、フォームバリデーション、通知 |
| **オフライン** | 人間が物理世界・法制度上で行う必要がある行為 | 法的書類の提出、公証付き署名、対面での本人確認 |

1つの機能が3カテゴリ全てにまたがることも珍しくありません。これを明示することで、(1)法的・実務的に不可能なことを「オンチェーンに載せればいい」と誤認すること、(2)オフラインのステップがコード上どこにも記録されず後から参加した人に見えなくなること、の2つの失敗を防ぎます。

## 使いどころ

[`docs/state-design/`](../state-design/) で機能を設計する際は、必ず下記テンプレートで内訳を記載してください。

## テンプレート

上記の英語版のテンプレートを参照してください(形式は言語に依存しません)。

記入例は [`feature-template.md`](feature-template.md) を参照してください。

# System Overview

> Status: placeholder. This will be expanded once the first concrete state function is scoped (see [`docs/state-design/README.md`](../state-design/README.md)).

## Components

```
                ┌─────────────────────────┐
                │        Citizens /       │
                │          Users          │
                └────────────┬────────────┘
                             │
                ┌────────────▼────────────┐
                │   frontend/ (Next.js)   │
                │   deployed on Vercel     │
                └────────────┬────────────┘
                             │ reads/writes via wallet + RPC
                ┌────────────▼────────────┐
                │   contracts/ (Solidity,  │
                │   built with Foundry)    │
                └────────────┬────────────┘
                             │ deployed to
                ┌────────────▼────────────┐
                │  Ethereum (Sepolia now,  │
                │  mainnet TBD)            │
                │  — or —                  │
                │  Polkadot Hub (EVM-      │
                │  compatible, TBD)        │
                └─────────────────────────┘
```

- See [`blockchain.md`](blockchain.md) for how chain targeting works.
- See [`frontend.md`](frontend.md) for frontend conventions.
- There is currently no off-chain backend/server beyond the Next.js app itself. Add one only when a concrete feature requires it (e.g., indexing events, sending notifications) — see [`docs/PROJECT_STATUS.md`](../PROJECT_STATUS.md) open questions.

---

# システム概要(日本語)

> ステータス: プレースホルダー。最初の具体的な国家機能がスコープされ次第、詳細化します([`docs/state-design/README.md`](../state-design/README.md) 参照)。

## コンポーネント構成

上記の英語版の図を参照してください(図は言語に依存しません)。

- チェーンの切り替え方式は [`blockchain.md`](blockchain.md) を参照。
- フロントエンドの規約は [`frontend.md`](frontend.md) を参照。
- 現時点ではNext.jsアプリ以外のオフチェーンバックエンドは存在しません。具体的な機能要件(イベントのインデクシング、通知送信など)が出てから追加します([`docs/PROJECT_STATUS.md`](../PROJECT_STATUS.md) の未解決の論点を参照)。

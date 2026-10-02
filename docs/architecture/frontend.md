# Frontend Architecture

> Status: placeholder — `frontend/` has not been bootstrapped yet. This documents the intended conventions for when it is.

## Framework conventions

- Next.js, **App Router only** (no Pages Router).
- React Server Components by default; Client Components (`"use client"`) only where interactivity (wallet connection, forms, live state) requires it.
- Server Actions for mutations where possible, instead of hand-rolled API routes, except where a true API endpoint is needed (e.g., webhooks).
- All routes under `app/`; any API routes under `app/api/`.

## Planned directory structure (inside `frontend/`)

```
frontend/
├── app/          # routing (App Router)
├── components/   # reusable UI
├── lib/          # utilities
└── server/       # server-only logic (never imported by Client Components)
```

## Chain configuration

The frontend must support multiple target chains without a rebuild-per-chain:

- `NEXT_PUBLIC_DEFAULT_CHAIN` selects the active chain (`sepolia` initially).
- Contract addresses are namespaced per chain (e.g., `NEXT_PUBLIC_SEPOLIA_CONTRACT_ADDRESS`, `NEXT_PUBLIC_POLKADOT_HUB_TESTNET_CONTRACT_ADDRESS`).
- Anything secret (API keys, RPC URLs with embedded keys) must stay server-side — never prefixed with `NEXT_PUBLIC_`. See [`frontend/.env.example`](../../frontend/.env.example).

## Data fetching

- Native `fetch`, explicit caching strategy per request (`force-cache` / `no-store` / `revalidate`) — no axios unless a concrete need arises.
- On-chain reads go through a thin, chain-aware client layer (to be designed) so that components don't hardcode a single chain's RPC/contract details.

---

# フロントエンドアーキテクチャ(日本語)

> ステータス: プレースホルダー — `frontend/` はまだブートストラップされていません。今後実装する際の規約を記載しています。

## フレームワーク規約

- Next.js、**App Routerのみ**(Pages Routerは使用しない)。
- デフォルトはReact Server Components。インタラクティブ性(ウォレット接続、フォーム、ライブ状態)が必要な箇所のみClient Component(`"use client"`)。
- 可能な限りServer Actionsをミューテーションに使用し、真にAPIエンドポイントが必要な場合(webhook等)を除き、独自のAPI routeは作らない。
- 全てのルートは `app/` 配下、APIルートは `app/api/` 配下。

## 想定ディレクトリ構成(`frontend/` 内)

上記の英語版を参照してください。

## チェーン設定

フロントエンドはチェーンごとの再ビルドなしに複数の対象チェーンをサポートする必要があります。

- `NEXT_PUBLIC_DEFAULT_CHAIN` で有効なチェーンを選択(初期値は `sepolia`)。
- コントラクトアドレスはチェーンごとに名前空間を分ける(例: `NEXT_PUBLIC_SEPOLIA_CONTRACT_ADDRESS`, `NEXT_PUBLIC_POLKADOT_HUB_TESTNET_CONTRACT_ADDRESS`)。
- 秘密情報(APIキー、キーを含むRPC URL)は常にサーバーサイドに留め、`NEXT_PUBLIC_` を付けない。[`frontend/.env.example`](../../frontend/.env.example) 参照。

## データフェッチ

- 標準の `fetch` を使用し、リクエストごとにキャッシュ戦略(`force-cache` / `no-store` / `revalidate`)を明示。具体的な必要性がない限りaxiosは使わない。
- オンチェーンの読み取りは、コンポーネントが単一チェーンのRPC/コントラクト詳細をハードコードしないよう、薄いチェーン対応クライアント層(今後設計)を経由する。

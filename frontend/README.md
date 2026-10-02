# frontend/

Next.js web application for web3state, deployed on [Vercel](https://vercel.com/).

> Status: placeholder. `create-next-app` has not been run yet — this directory currently only holds planned conventions and an env template. See [`docs/PROJECT_STATUS.md`](../docs/PROJECT_STATUS.md).

## Conventions

See [`docs/architecture/frontend.md`](../docs/architecture/frontend.md) for the full rationale. Summary:

- Next.js, **App Router only**.
- React Server Components by default; `"use client"` only where needed.
- All routes under `app/`, API routes under `app/api/`.
- Planned layout: `app/`, `components/`, `lib/`, `server/`.
- Native `fetch` with explicit caching strategy; no axios unless a concrete need arises.
- No secrets in client-side code — see [`.env.example`](.env.example).

## Chain configuration

The app is meant to support multiple target chains via environment variables rather than hardcoding one chain — see [`docs/architecture/blockchain.md`](../docs/architecture/blockchain.md). `NEXT_PUBLIC_DEFAULT_CHAIN` defaults to `sepolia`.

## Getting started (once the app is bootstrapped)

```sh
npx create-next-app@latest . --typescript --app
cp .env.example .env.local   # then fill in values
npm run dev
```

---

# frontend/(日本語)

web3state のWebアプリケーション(Next.js)。[Vercel](https://vercel.com/) にデプロイ。

> ステータス: プレースホルダー。まだ `create-next-app` は実行していません — 現時点では想定する規約と環境変数テンプレートのみを格納しています。[`docs/PROJECT_STATUS.md`](../docs/PROJECT_STATUS.md) 参照。

## 規約

詳細な理由は [`docs/architecture/frontend.md`](../docs/architecture/frontend.md) を参照。要約:

- Next.js、**App Routerのみ**。
- デフォルトはReact Server Components。必要な箇所のみ `"use client"`。
- 全てのルートは `app/` 配下、APIルートは `app/api/` 配下。
- 想定レイアウト: `app/`, `components/`, `lib/`, `server/`。
- 標準の `fetch` を使い、キャッシュ戦略を明示。具体的な必要性がない限りaxiosは使わない。
- クライアントサイドのコードに秘密情報を含めない — [`.env.example`](.env.example) 参照。

## チェーン設定

このアプリは単一チェーンのハードコードではなく、環境変数による複数チェーン対応を想定しています — [`docs/architecture/blockchain.md`](../docs/architecture/blockchain.md) 参照。`NEXT_PUBLIC_DEFAULT_CHAIN` の初期値は `sepolia`。

## 始め方(アプリのブートストラップ後)

```sh
npx create-next-app@latest . --typescript --app
cp .env.example .env.local   # その後、値を設定
npm run dev
```

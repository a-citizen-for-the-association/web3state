# 0002. Initial stack and repository structure

**Date:** 2026-10-03
**Status:** Accepted

## Context

The project needs to begin from a concrete scaffold before feature design can be discussed productively. Several choices had to be made up front: how to lay out the repository, which smart contract tooling to use, which chains to target during testing vs. mainnet, which documentation language to use, and what license to apply.

Key constraints:
- The application is composed of on-chain smart contracts plus a web frontend.
- Two chains are candidates for the system: Ethereum and Polkadot Hub. Both are EVM-compatible (Polkadot Hub supports Solidity contracts via PolkaVM / `pallet-revive`), so a single Solidity codebase can target either.
- Sepolia must be usable preferentially during testing; the mainnet chain choice is a separate, later decision.
- Frontend is Next.js, deployed on Vercel (given, not reconsidered here).
- The project is expected to become large and will have contributors joining after the fact, who may need to work offline (outside the web app and outside the chain) on some tasks.

## Decision

- **Repository layout:** a single repository with two independent, self-contained top-level directories — `contracts/` and `frontend/` — with no workspace tool (pnpm workspaces, Turborepo, etc.) linking them. Simpler to reason about; nothing today requires sharing code or build pipelines between them. Revisit if/when real duplication appears (YAGNI).
- **Smart contract tooling:** [Foundry](https://getfoundry.sh/). Actively maintained, fast, widely adopted, and lets contracts and tests both be written in Solidity.
- **Chain targeting:** both chains are EVM-compatible, so the contract codebase itself does not need to branch per chain. Network selection happens at the deploy/config layer — Foundry named RPC endpoints (`[rpc_endpoints]` in `foundry.toml`) and environment variables — not in contract code. Sepolia is configured as the default/priority network now; mainnet endpoint(s) are left as placeholders pending ADR for mainnet chain choice.
- **Documentation language:** English as the primary language, with Japanese included alongside for key documents (README, CONTRIBUTING, docs index, project status, ADRs). Rationale: this project models state/legal structures where precision matters, and English keeps it accessible to a broader open-source audience; Japanese keeps it accessible to the project's current core contributors.
- **License:** MIT — the most widely used permissive license, minimizing friction for contributors and future adopters.
- **History/state tracking convention:** three separate, non-overlapping documents — `CHANGELOG.md` (what changed, code-level), `docs/decisions/*.md` (why a significant decision was made, immutable), and `docs/PROJECT_STATUS.md` (where things stand right now, a frequently-updated snapshot).
- **Online / on-chain / offline classification:** because this project models real institutional functions, every feature is expected to document which parts run on-chain, which run in the web app (online), and which require a human to act in the physical/legal world (offline). Convention lives in `docs/operations/`.

## Consequences

- Contract code can be written once and deployed to either candidate chain by changing configuration, not code — but this has not been validated against real Polkadot Hub deployment yet; treat as an assumption to verify once contracts exist.
- Mainnet chain selection remains an open question (tracked in `docs/PROJECT_STATUS.md`) and will get its own ADR when decided.
- No CI, no workspace tooling, and no actual contract/frontend code exist yet — this ADR covers structure and tooling choices only, not feature scope.
- Because `contracts/` and `frontend/` are independent, there is currently no enforced shared TypeScript config, linting, or versioning between them; this is an accepted tradeoff for simplicity today.

---

# 0002. 初期の技術スタックとリポジトリ構成(日本語)

**日付:** 2026-10-03
**ステータス:** Accepted

## 背景

機能の設計を実のある形で議論する前に、具体的な土台から始める必要がある。いくつかの選択を最初に決めなければならなかった: リポジトリの構成、使うスマートコントラクトのツール、テスト時とメインネットで対象とするチェーン、ドキュメントの言語、適用するライセンスである。

主な制約:
- アプリケーションは、オンチェーンのスマートコントラクトとWebのフロントエンドで構成される。
- システムのチェーンの候補は2つ: EthereumとPolkadot Hub。どちらもEVM互換である(Polkadot HubはPolkaVM / `pallet-revive`を通じてSolidityのコントラクトに対応する)。そのため、1つのSolidityのコードベースでどちらも対象にできる。
- テスト時はSepoliaを優先して使えなければならない。メインネットのチェーン選定は、後の別の決定とする。
- フロントエンドはNext.jsで、Vercelにデプロイする(前提であり、ここでは再検討しない)。
- プロジェクトは大きくなると見込まれ、後から参加する貢献者が出る。彼らは一部の作業をオフライン(Webアプリの外、チェーンの外)で行う必要があるかもしれない。

## 決定

- **リポジトリ構成:** 1つのリポジトリに、独立して自己完結した2つのトップレベルのディレクトリ`contracts/`と`frontend/`を置く。両者をつなぐワークスペースのツール(pnpm workspaces、Turborepoなど)は使わない。考えやすく、現時点で両者の間でコードやビルドのパイプラインを共有する必要はない。実際に重複が出てきたら見直す(YAGNI)。
- **スマートコントラクトのツール:** [Foundry](https://getfoundry.sh/)。活発に保守され、速く、広く採用されており、コントラクトとテストの両方をSolidityで書ける。
- **チェーンの対象:** どちらのチェーンもEVM互換なので、コントラクトのコードベース自体をチェーンごとに分ける必要はない。ネットワークの選択はコントラクトのコードではなく、デプロイと設定の層で行う。Foundryの名前付きRPCエンドポイント(`foundry.toml`の`[rpc_endpoints]`)と環境変数を使う。現時点ではSepoliaを既定かつ優先のネットワークとして設定する。メインネットのエンドポイントは、メインネットのチェーン選定のADRが出るまでプレースホルダーのままとする。
- **ドキュメントの言語:** 英語を主な言語とし、主要なドキュメント(README、CONTRIBUTING、docsの目次、プロジェクトの状況、ADR)には日本語を併記する。理由: このプロジェクトは正確さが重要な国家や法の構造をモデル化しており、英語ならより広いオープンソースの読者に届く。日本語なら現在の中心的な貢献者に届く。
- **ライセンス:** MIT。最も広く使われている寛容なライセンスで、貢献者や将来の採用者にとっての障壁が最も小さい。
- **履歴と状況の管理の慣行:** 重ならない3つの別々のドキュメントを使う。`CHANGELOG.md`(コードの水準で何が変わったか)、`docs/decisions/*.md`(重要な決定がなぜなされたか、変更しない)、`docs/PROJECT_STATUS.md`(今どういう状況か、頻繁に更新するスナップショット)である。
- **オンライン/オンチェーン/オフラインの分類:** このプロジェクトは現実の制度的な機能をモデル化するので、どの機能も、どの部分がオンチェーンで動き、どの部分がWebアプリ(オンライン)で動き、どの部分が物理的・法的な世界で人が行動する必要があるか(オフライン)を記載する。慣行は`docs/operations/`に置く。

## 結果

- コントラクトのコードは一度書けば、コードではなく設定を変えるだけでどちらの候補のチェーンにもデプロイできる。ただし、実際のPolkadot Hubへのデプロイではまだ検証していない。コントラクトができたら確かめるべき仮定として扱う。
- メインネットのチェーン選定は未解決の課題のまま(`docs/PROJECT_STATUS.md`で管理)で、決まった時点で独自のADRを作る。
- CI、ワークスペースのツール、実際のコントラクトやフロントエンドのコードはまだない。このADRは構成とツールの選択だけを扱い、機能の範囲は扱わない。
- `contracts/`と`frontend/`は独立しているので、現時点では両者の間で共有され強制されるTypeScriptの設定、lint、バージョン管理はない。今の簡潔さのために受け入れたトレードオフである。

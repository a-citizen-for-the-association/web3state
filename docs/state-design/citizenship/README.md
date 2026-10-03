# Citizenship / Residency (国民・住民): Resident-Link NFT

**Status: 🟢 Spec drafted.** Conceptual and architecture questions resolved through discussion with the user; see [`discussion-log.md`](discussion-log.md) for the full reasoning and [`docs/decisions/0003-resident-link-identity-model.md`](../../decisions/0003-resident-link-identity-model.md) for the formal ADR. No contract code written yet.

## Legal status (read this first)

> Under current Japanese law, no municipality has legal authority to issue blockchain-based tokens as an official instrument of residency or nationality certification. This design is a hypothetical implementation within web3state — an explicitly thought-experiment project — exploring what such a system could look like, not a claim that it is operative under, or sanctioned by, current law.

## Summary

A municipality (example: "City A") deploys its own NFT contract. A resident registers in person at city hall and submits a wallet address; city hall mints them a **non-transferable (soulbound), nationality-neutral** token linking that address to "a person registered as a resident of City A," without putting any personal information on-chain. The municipality separately, off-chain, attests that this contract is its official one, anchored to its `.lg.jp` domain. Anyone can then prove residency by disclosing only their address.

**This token proves residency only — it makes no claim about nationality.** Nationality-dependent needs (e.g. a passport) are separate, future credentials issued by whichever authority is responsible for that specific claim (see [Relationship to other credentials](#relationship-to-other-credentials)).

## On-chain / Online / Offline breakdown

(See [`docs/operations/README.md`](../../operations/README.md) for the convention.)

**On-chain:**
- Token issuance (mint) and revocation (burn), restricted to the issuing municipality's admin role.
- Token ownership (`tokenId ↔ address`), standard ERC-721/soulbound semantics.
- A persistent `everIssued(address)` flag per address (never cleared by burn), used to prove past-residency/departure.
- No personal data, no status field beyond token existence, no on-chain reason codes.

**Online:**
- The municipality's official declaration of its contract's address, published at a well-known URI under its `.lg.jp` domain.
- The project's (non-authoritative) frontend list of known municipality contracts, for convenience/discovery only.

**Offline:**
- Personal information (identity, proof of residency) is registered and managed entirely by the municipality, off-chain, exactly as it is today.
- In-person identity verification at city hall, for both initial issuance and any re-issuance.
- Deduplication beyond a single declared prior municipality relies on the existing (assumed) inter-municipal network among municipalities (today: 住基ネット/マイナンバー), or, historically, a paper-based equivalent.
- The actual reason for a revocation (moved, died, correction, fraud) stays in the municipality's private records — never disclosed on-chain.

## Architecture

### Contract: `ResidentLink` (one instance per municipality)

A non-transferable (soulbound) ERC-721-based token, deployed independently by each participating municipality. All instances share identical, audited code — only constructor parameters (name, symbol, municipality identifier, initial admin) differ per municipality. (Whether deployment goes through a shared factory contract, or each municipality deploys independently from the same source, is an implementation detail to decide when writing the Solidity — not a conceptual blocker.)

**State (per contract):**

| Item | Scope | Notes |
|---|---|---|
| `tokenId ↔ owner` | Per-token | Standard ERC-721 ownership. `tokenId` is a meaningless sequential counter — never derived from personal data. |
| `everIssued(address) → bool` | Per-address | Set `true` at mint; **never cleared by burn**. Used to prove "this address was once a resident here" (see Deduplication below). |
| `municipalityCode` | Contract-level | Japan's 地方公共団体コード (JIS X 0402), immutable. Used to cross-reference the `.lg.jp` official announcement. |
| Admin role(s) | Contract-level | e.g. OpenZeppelin `AccessControl`, a `MUNICIPALITY_ADMIN_ROLE`. Should be held by a municipality-controlled multisig, not a single EOA — a real-world key-management requirement, not something the contract can enforce. |

**No per-token data beyond the above** — no timestamps (recoverable from the mint `Transfer` event's block data if ever needed), no hashes of personal data, no personalized metadata. `tokenURI`, if implemented, returns identical content for every token.

**Functions (indicative, not final Solidity):**

- `mint(address resident) onlyRole(MUNICIPALITY_ADMIN_ROLE)` — issues a new token. Reverts if the address already holds one (`balanceOf(resident) != 0`).
- `burn(uint256 tokenId) onlyRole(MUNICIPALITY_ADMIN_ROLE)` — revokes (destroys) a token. **No self-burn by the holder.** No reason code parameter — the reason is recorded only in the municipality's own off-chain system.
- `everIssued(address) view returns (bool)` — public, used by this or another municipality's off-chain/admin tooling to check prior-residency history (see Deduplication).
- Transfers disabled: `transferFrom`, `safeTransferFrom`, `approve`, `setApprovalForAll` all revert (soulbound). Consider implementing [ERC-5192](https://eips.ethereum.org/EIPS/eip-5192) (`locked(uint256)` always returns `true`, plus `Locked` event at mint) for standard wallet/explorer compatibility.
- Built on OpenZeppelin Contracts (pin to the latest audited stable release at implementation time).

### Proving an "official" municipality contract

Resolving "who vouches for City A's contract being the real one" cannot be done on-chain without moving the same question up one level (who vouches for a registry). Instead:

- Each municipality publishes its contract address(es) and chain ID(s) at a well-known URI under its own `.lg.jp` domain — a restricted TLD that already requires institutional vetting as a legitimate Japanese local government to register. Example convention: `https://<city>.lg.jp/.well-known/web3state-registry.json`.
- Optionally, this announcement can be signed using the municipality's LGPKI (地方公共団体組織認証基盤) certificate for a cryptographically verifiable attestation, rather than relying on HTTPS/TLS trust alone.
- **No on-chain registry contract in v1** (YAGNI — it would add convenience, not trust, since the root of trust is off-chain either way). The project's frontend may keep a clearly-labeled, non-authoritative convenience list of known municipality contracts, cross-checked against each municipality's own `.lg.jp` announcement; any verifier should be able to check the primary source directly rather than trust this list blindly.

### Lifecycle

```
[not registered] --mint (municipality only, in-person verification)--> [Active: token exists]
[Active]          --burn (municipality only; reason kept off-chain)----> [not registered, but everIssued stays true]
[not registered, everIssued=true] --mint again (re-verification)------> [Active]
```

- Only the municipality's admin role can mint or burn. **No self-burn.**
- "Revoked" = burned. There is no separate status field — validity is simply token existence (`balanceOf(address) > 0`). This also means a once-revoked address can be re-issued a fresh token cleanly, with no leftover state to reconcile.
- Re-issuance (lost key, correction, or a new municipality after a move) uses the same in-person verification process as initial issuance — no new mechanism needed.

### Deduplication across municipalities

- **On-chain:** for someone declaring a move from a specific previous municipality, the new municipality (or its off-chain tooling) can check `everIssued(resident) == true && balanceOf(resident) == 0` on the *previously declared* municipality's contract — a trustless, forgery-proof, on-chain equivalent of a paper 転出証明書 (move-out certificate).
- **Off-chain:** anything beyond the single declared prior municipality (i.e., proving no *undisclosed* active token exists elsewhere) is assumed to be handled the way it is in the real world today — an inter-municipal network among municipalities (住基ネット/マイナンバー-equivalent), or historically, paper-based serial hand-off. This project does not build an on-chain substitute for that network.
- This mirrors the historical pre-digital Japanese system's own limitation (which also only checked the one declared prior municipality via a paper certificate) — not a regression introduced by this design.

## Relationship to other credentials

This token is intentionally minimal: it proves residency-linkage only. Other state functions that need a specific attribute (nationality for a passport, voting eligibility, professional licenses, etc.) are expected to be modeled as **separate, purpose-specific credential NFTs**, each issued independently by whichever authority is responsible for that attribute, verified off-chain by that authority at issuance time — not inherited or derived from this base token. (Note: a person's 本籍地 (koseki/nationality-holding municipality) can differ from their 住所地 (residence municipality, which issues this token) — relevant when a nationality-dependent credential is designed, not a concern for this token itself.)

## Open items for later (not blocking this spec)

- Passport / nationality credential design — tracked in [`docs/BACKLOG.md`](../../BACKLOG.md), not just here.
- Whether a shared deployment factory is used across municipalities (implementation detail).
- Exact Solidity interfaces, events, and test plan (next step: implementation).

---

# 国民・住民: 住民登録リンクNFT(日本語)

**ステータス: 🟢 設計確定。** ユーザーとの議論を通じて概念・アーキテクチャ上の論点は解決済み。詳細な議論の経緯は [`discussion-log.md`](discussion-log.md)、正式なADRは [`docs/decisions/0003-resident-link-identity-model.md`](../../decisions/0003-resident-link-identity-model.md) を参照。コントラクトコードはまだ実装していません。

## 法的位置づけ(最初に読んでください)

> 現行の日本の法律上、市区町村がブロックチェーン上のトークンを住民・国籍の公的な証明手段として発行する法的権限を定める規定は存在しない。本設計は、web3state(明示的に思考実験であるプロジェクト)内における仮説的な実装であり、そのような仕組みがどのようなものになり得るかを検討するものであって、現行法下で実際に運用可能、または法的に認められている制度であることを主張するものではない。

## 概要

市区町村(例: 「A市」)が自身のNFTコントラクトをデプロイします。住民は市役所で対面にて登録を行い、ウォレットアドレスを申請します。市役所は、個人情報を一切オンチェーンに載せることなく、そのアドレスを「A市の住民として登録された人物」に紐づける**譲渡不可(Soulbound)・国籍不問**のトークンを発行します。市区町村は別途、オフチェーンで、このコントラクトが自身の公式なものであることを、自らの `.lg.jp` ドメインを根拠に証明します。これにより、誰でも自分のアドレスを開示するだけで住民であることを証明できます。

**このトークンは住民であることのみを証明し、国籍については一切主張しません。** 国籍が必要な用途(パスポートなど)は、その属性を所管する主体が個別に発行する、別の将来のクレデンシャルとして扱います([他のクレデンシャルとの関係](#他のクレデンシャルとの関係)を参照)。

## オンチェーン/オンライン/オフラインの内訳

(規約については [`docs/operations/README.md`](../../operations/README.md) を参照)

**オンチェーン:**
- トークンの発行(mint)と失効(burn)。発行自治体の管理者ロールのみが実行可能。
- トークンの所有権(`tokenId ↔ アドレス`)。標準的なERC-721/Soulboundのセマンティクス。
- アドレスごとの永続的な `everIssued(address)` フラグ(burnしても消えない)。過去に住民だったこと/転出したことの証明に使用。
- 個人情報なし。トークンの存在以外の状態フィールドなし。オンチェーンの失効理由コードなし。

**オンライン:**
- 市区町村による、自身のコントラクトアドレスの公式な宣言。`.lg.jp` ドメイン配下のwell-known URIで公表。
- プロジェクトの(非権威的な)フロントエンドが保持する既知の市区町村コントラクト一覧。あくまで利便性・発見のためのみ。

**オフライン:**
- 個人情報(本人確認情報、居住の証明)は、今日と全く同じように、市区町村がオフチェーンで完全に登録・管理します。
- 初回発行・再発行いずれも、市役所での対面による本人確認。
- 申告された1つの前住所の自治体を超える重複防止は、既存(前提とする)の自治体間ネットワーク(現在ならマイナンバー/住基ネット)、または歴史的には紙ベースの同等の仕組みに依拠します。
- 失効の実際の理由(転出、死亡、訂正、不正)は市区町村の非公開記録に留め、オンチェーンには一切開示しません。

## アーキテクチャ

### コントラクト: `ResidentLink`(市区町村ごとに1インスタンス)

譲渡不可(Soulbound)なERC-721ベースのトークンで、参加する各市区町村が独立してデプロイします。全インスタンスは同一の監査済みコードを共有し、コンストラクタ引数(名称、シンボル、市区町村識別子、初期管理者)のみが市区町村ごとに異なります。(共有のファクトリーコントラクトを経由してデプロイするか、各市区町村が同一ソースから個別にデプロイするかは、Solidity実装時に決める実装詳細であり、概念上のブロッカーではありません。)

**状態(コントラクトごと):**

| 項目 | スコープ | 備考 |
|---|---|---|
| `tokenId ↔ 所有者` | トークンごと | 標準的なERC-721の所有権。`tokenId` は意味を持たない連番で、個人情報から導出しない。 |
| `everIssued(address) → bool` | アドレスごと | mint時に `true` をセット。**burnしても消さない**。「このアドレスはかつてここの住民だった」ことの証明に使用(後述の重複防止を参照)。 |
| `municipalityCode` | コントラクトレベル | 日本の地方公共団体コード(JIS X 0402)、不変。`.lg.jp` の公式発表との突合に使用。 |
| 管理者ロール | コントラクトレベル | 例: OpenZeppelinの `AccessControl`、`MUNICIPALITY_ADMIN_ROLE`。単一のEOAではなく、市区町村が管理するマルチシグが保持すべき — これは現実世界の鍵管理上の要件であり、コントラクトでは強制できない。 |

**上記以外のトークンごとのデータは一切持ちません** — タイムスタンプ(必要ならmintの `Transfer` イベントのブロック情報から取得可能)、個人情報のハッシュ、個人ごとに異なるメタデータは持ちません。`tokenURI` を実装する場合も、全トークンで同一の内容を返します。

**関数(あくまで指針であり、最終的なSolidityではない):**

- `mint(address resident) onlyRole(MUNICIPALITY_ADMIN_ROLE)` — 新しいトークンを発行。既にそのアドレスが保有している場合(`balanceOf(resident) != 0`)はrevert。
- `burn(uint256 tokenId) onlyRole(MUNICIPALITY_ADMIN_ROLE)` — トークンを失効(破棄)。**保有者本人によるバーンは不可。** 理由コードの引数もなし — 理由は市区町村自身のオフチェーンシステムにのみ記録する。
- `everIssued(address) view returns (bool)` — public。自身または他の市区町村のオフチェーン/管理ツールが、過去の住民歴を確認するために使用(重複防止を参照)。
- 譲渡は無効化: `transferFrom`、`safeTransferFrom`、`approve`、`setApprovalForAll` は全てrevert(Soulbound)。標準的なウォレット・エクスプローラーとの互換性のため、[ERC-5192](https://eips.ethereum.org/EIPS/eip-5192)(`locked(uint256)` は常に `true` を返し、mint時に `Locked` イベントを発行)の実装を検討する。
- OpenZeppelin Contractsをベースにする(実装時点での最新の監査済み安定版に固定)。

### 「公式」な市区町村コントラクトの証明

「A市のコントラクトが本物であることを誰が保証するのか」という問いは、オンチェーンだけで解決しようとすると同じ問いが一段階上(レジストリを誰が保証するのか)に先送りされるだけで、解決になりません。そこで:

- 各市区町村は、自身の `.lg.jp` ドメイン配下のwell-known URIで、自身のコントラクトアドレスとチェーンIDを公表します。`.lg.jp` は正当な日本の地方公共団体であることの審査を経なければ取得できない制限付きTLDです。規約の例: `https://<city>.lg.jp/.well-known/web3state-registry.json`
- オプションとして、HTTPS/TLSの信頼のみに頼るのではなく、市区町村のLGPKI(地方公共団体組織認証基盤)証明書でこの発表に署名し、暗号学的に検証可能な証明とすることもできます。
- **v1ではオンチェーンのレジストリコントラクトは作りません**(YAGNI — 信頼の根拠はどのみちオフチェーンにあるため、オンチェーンレジストリは信頼を増やさず利便性を増すだけです)。プロジェクトのフロントエンドは、各市区町村の `.lg.jp` の発表と突合した、明確に「非権威的」と明記した便利リストを持つことができます。検証者は常にこのリストではなく一次情報源を直接確認できるようにします。

### ライフサイクル

```
[未登録] --mint(市区町村のみ、対面確認)--> [有効: トークンが存在する]
[有効]    --burn(市区町村のみ、理由はオフチェーン)--> [未登録、ただしeverIssuedはtrueのまま]
[未登録、everIssued=true] --再度mint(再確認)--> [有効]
```

- mint/burnができるのは市区町村の管理者ロールのみ。**本人による自主バーンは不可。**
- 「失効」＝バーンです。別途の状態フィールドは持ちません — 有効性は単にトークンが存在するかどうか(`balanceOf(address) > 0`)で判定します。これにより、一度失効したアドレスにも、残存する状態を気にせずきれいに新しいトークンを再発行できます。
- 再発行(秘密鍵紛失、訂正、転居による新しい市区町村での発行)は、初回発行と同じ対面確認プロセスで行います。新たな仕組みは不要です。

### 市区町村をまたいだ重複防止

- **オンチェーン:** 特定の前住所の市区町村からの転居を申告する人について、新しい市区町村(またはそのオフチェーンツール)は、*申告された前の* 市区町村のコントラクトで `everIssued(resident) == true && balanceOf(resident) == 0` を確認できます。これは紙の転出証明書に相当する、偽造不可能でトラストレスなオンチェーンの証明です。
- **オフチェーン:** 申告された1つの前の市区町村を超える範囲(＝申告されていない別の場所で有効なトークンが存在しないことの証明)は、現実世界で今日行われているのと同じ方法(自治体間ネットワーク、住基ネット/マイナンバー相当、または歴史的には紙ベースの連続した引き継ぎ)で対応されると仮定します。このプロジェクトは、そのネットワークのオンチェーン代替は構築しません。
- これは、紙の時代の日本の制度が元々持っていた限界(申告された1つの前住所のみを紙の証明書で確認していた)をそのまま反映したものであり、この設計によって生じた後退ではありません。

## 他のクレデンシャルとの関係

このトークンは意図的に最小限に設計されています。住民登録のリンクのみを証明します。特定の属性(パスポートのための国籍、投票資格、各種資格など)を必要とする他の国家機能は、**別の、目的別のクレデンシャルNFT**としてモデル化されることを想定しています。それぞれ、その属性を所管する主体が独立して発行し、発行時点でその主体がオフチェーンで確認します — このベーストークンから継承・導出されるものではありません。(注: 本籍地(戸籍・国籍を保持する市区町村)は、住所地(このトークンを発行する居住地の市区町村)と異なる場合があります — これは国籍に依存するクレデンシャルを設計する際に関係する点であり、このトークン自体の懸念事項ではありません。)

## 今後の課題(本設計書をブロックするものではない)

- パスポート/国籍クレデンシャルの設計 — ここだけでなく [`docs/BACKLOG.md`](../../BACKLOG.md) でも追跡。
- 市区町村間で共有デプロイ用ファクトリーを使うかどうか(実装詳細)。
- 正確なSolidityインターフェース、イベント、テスト計画(次のステップ: 実装)。

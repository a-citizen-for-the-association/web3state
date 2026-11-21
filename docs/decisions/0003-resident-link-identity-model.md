# 0003. Resident-link identity model for citizenship/residency

**Date:** 2026-10-03
**Status:** Accepted. The "no on-chain registry in v1" point is revisited by [ADR 0015](0015-political-donations-model.md) (`OfficialContractRegistry`).

## Context

The first concrete state function to design was citizenship/residency (国民・住民): how to represent, on-chain, that a person is recognized as a resident/national by a municipality, while keeping personal information off-chain and managed only by municipalities, per the user's stated principle.

The initial proposal conflated 国民 (national, a nationality status under the 国籍法, recorded via 戸籍) with 住民 (resident, registered in a municipality's 住民基本台帳, which has included foreign residents since 2012) — these are legally distinct in Japan, and the proposal's implicit claim ("registered with a municipality ⇒ Japanese national") does not hold. Several other foundational questions were open: how an "official" municipal contract is verified, whether the token should be transferable, how it is revoked, what data it should hold on-chain, and whether/how cross-municipality duplicate registration is prevented.

These were worked through in detail with the user; see [`docs/state-design/citizenship/discussion-log.md`](../state-design/citizenship/discussion-log.md) for the full reasoning. This ADR records only the resulting decisions.

## Decision

- **The base token makes no claim about nationality.** It proves residency-linkage only ("this address is linked to a person registered as a resident of municipality X"). Nationality-dependent needs (e.g. a passport) are deferred to separate, future, purpose-specific credential NFTs issued by whichever authority is responsible, each independently verified off-chain at issuance — not derived from this token. This avoids the legal inaccuracy in the original proposal entirely, since the token never asserts anything about nationality.
- **"Official" contract authenticity is established off-chain**, anchored to each municipality's `.lg.jp` domain (an institutionally-vetted, restricted TLD) via a well-known URI, optionally LGPKI-signed. No on-chain registry contract in v1 — it would add convenience, not trust, since the root of trust is off-chain regardless.
- **The token is non-transferable (soulbound).** Standard ERC-721 transfer/approval paths are disabled; only mint and burn exist.
- **Only the issuing municipality's admin role can mint or burn; there is no self-burn.** "Revoke" is defined as burning the token — there is no separate on-chain status field. Reasons for revocation (move, death, correction, fraud) are never recorded on-chain.
- **On-chain data is minimal**: standard ERC-721 ownership plus one additional persistent per-address flag, `everIssued`, set at mint and never cleared by burn. No timestamps, no hashes of personal data, no personalized metadata.
- **Cross-municipality deduplication** for a declared move is checked on-chain via `everIssued == true && balanceOf == 0` on the previously-declared municipality's contract (a trustless digital equivalent of a 転出証明書). Anything beyond a single declared prior municipality is assumed to be handled off-chain by an inter-municipal network among municipalities (mirroring 住基ネット/マイナンバー, or historically a paper-based equivalent) — not solved on-chain.
- **This design is explicitly a thought experiment.** No municipality currently has legal authority to issue such tokens as an official instrument of residency/nationality certification; this is not a claim of present legal operability.

## Consequences

- The citizenship/residency feature can now proceed to a concrete Solidity spec and implementation (see [`docs/state-design/citizenship/README.md`](../state-design/citizenship/README.md)) without unresolved conceptual conflicts.
- Future features that depend on nationality (e.g., a passport credential) must be designed as independent credentials with their own off-chain verification process — they cannot assume the base resident-link token implies nationality.
- Municipalities (in this hypothetical system) carry real-world operational obligations this project cannot enforce in Solidity: secure multisig key management for the admin role, and keeping on-chain burns synchronized with real-world move-out/death/correction processing.
- Deduplication guarantees are only as strong as (a) the declared-prior-municipality check this project implements on-chain, and (b) whatever off-chain inter-municipal network is assumed to exist — this project does not itself build a nationwide real-time cross-check.
- The `docs/state-design/citizenship/` directory name is kept for now (it covers the broader membership question), even though the token itself is nationality-neutral; revisit naming if it causes confusion once nationality-dependent credentials are designed.

---

# 0003. 国民・住民のための`ResidentLink`アイデンティティモデル(日本語)

**日付:** 2026-10-03
**ステータス:** Accepted。「v1ではオンチェーンのレジストリを置かない」という点は[ADR 0015](0015-political-donations-model.md)(`OfficialContractRegistry`)で見直される。

## 背景

最初に設計した具体的な国家の機能は国民・住民である: ある人が市区町村によって住民・国民と認められていることをオンチェーンでどう表すか。ユーザーが示した原則に従い、個人情報はオフチェーンに置き、市区町村だけが管理する。

当初の提案は、国民(国籍法上の国籍の地位で、戸籍で記録される)と住民(市区町村の住民基本台帳に登録され、2012年からは外国人住民も含む)を混同していた。日本ではこの2つは法的に別のものであり、提案が暗に前提とした「市区町村に登録されている ⇒ 日本国民」は成り立たない。他にもいくつかの基礎的な問いが未解決だった: 市区町村の「公式」なコントラクトをどう確認するか、トークンを譲渡可能にするか、どう取り消すか、オンチェーンにどのデータを持たせるか、市区町村をまたぐ二重登録を防ぐか、防ぐならどうやるか。

これらはユーザーと詳しく検討した。理由の全体は[`docs/state-design/citizenship/discussion-log.md`](../state-design/citizenship/discussion-log.md)を参照。このADRは結果としての決定だけを記録する。

## 決定

- **基本のトークンは国籍について何も主張しない。** 証明するのは住民としての結びつきだけである(「このアドレスは、市区町村Xの住民として登録された人に結びついている」)。国籍に依存する用途(例: パスポート)は、担当する当局が発行する、目的ごとの別の将来のクレデンシャルNFTに先送りする。それぞれ発行時にオフチェーンで独立に確認し、このトークンからは導かない。トークンが国籍について何も主張しないので、当初の提案の法的な不正確さは完全に避けられる。
- **「公式」なコントラクトの真正性はオフチェーンで確立する。** 各市区町村の`.lg.jp`ドメイン(制度的に審査される制限付きのTLD)に、well-known URIを通じて結びつけ、任意でLGPKIの署名を付ける。v1ではオンチェーンのレジストリのコントラクトを置かない。信頼の起点はいずれにせよオフチェーンなので、レジストリは利便性を加えるだけで、信頼は加えない。
- **トークンは譲渡不可(Soulbound)である。** 標準のERC-721の移転と承認の経路は無効にし、mintとburnだけがある。
- **mintとburnができるのは発行した市区町村の管理者ロールだけで、本人によるburnはない。** 「取消し」はトークンのburnと定義する。オンチェーンに別の状態のフィールドはない。取消しの理由(転出、死亡、訂正、不正)はオンチェーンに決して記録しない。
- **オンチェーンのデータは最小限:** 標準のERC-721の所有に加え、アドレスごとに永続するフラグ`everIssued`を1つだけ持つ。mint時に立て、burnしても消さない。タイムスタンプ、個人データのハッシュ、個人ごとのメタデータは持たない。
- **市区町村をまたぐ重複の排除**は、届け出た転居について、前に届け出た市区町村のコントラクトで`everIssued == true && balanceOf == 0`をオンチェーンで確認する(転出証明書の、信頼を必要としないデジタル版)。届け出た1つの前の市区町村を超える範囲は、市区町村の間のオフチェーンのネットワーク(住基ネット/マイナンバー、あるいは歴史的には紙ベースの同等物にならう)が扱うと仮定する。オンチェーンでは解決しない。
- **この設計は明示的に思考実験である。** 現在、居住や国籍を証明する公式の手段としてこうしたトークンを発行する法的権限を持つ市区町村はない。現在の法の下で運用できるとは主張しない。

## 結果

- 国民・住民の機能は、未解決の概念上の矛盾なしに、具体的なSolidityの仕様と実装に進める([`docs/state-design/citizenship/README.md`](../state-design/citizenship/README.md)を参照)。
- 国籍に依存する将来の機能(例: パスポートのクレデンシャル)は、独自のオフチェーンの確認手続きを持つ独立したクレデンシャルとして設計しなければならない。基本の`ResidentLink`トークンが国籍を意味すると仮定することはできない。
- (この仮想のシステムでは)市区町村は、このプロジェクトがSolidityでは強制できない現実の運用上の義務を負う: 管理者ロールのためのマルチシグの鍵の安全な管理と、オンチェーンのburnを現実の転出、死亡、訂正の処理と同期させ続けることである。
- 重複排除の保証は、(a)このプロジェクトがオンチェーンで実装する、届け出た前の市区町村の確認と、(b)存在すると仮定するオフチェーンの市区町村間のネットワーク、の強さまでしかない。このプロジェクト自体は全国でリアルタイムの照合を作らない。
- `docs/state-design/citizenship/`というディレクトリ名は当面そのままにする(トークン自体は国籍に中立だが、より広い構成員の問題を扱うため)。国籍に依存するクレデンシャルを設計した後で混乱を招くようなら、名前を見直す。

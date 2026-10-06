# Passport (パスポート)

**Status: 🟢 Spec drafted.** Conceptual and architecture questions resolved through discussion with the user; see [`discussion-log.md`](discussion-log.md) for the full reasoning and [`docs/decisions/0006-passport-credential.md`](../../../decisions/0006-passport-credential.md) for the formal ADR. No contract code written yet.

## Summary

A pure travel-document credential: a soulbound NFT, issued by 外務省 (Ministry of Foreign Affairs), proving only that the holding address possesses a currently administratively-valid Japanese passport. **Nationality is verified entirely off-chain** by 外務省, using the same kind of existing real-world administrative process (戸籍 documents, etc.) a municipality already uses to verify identity before minting [`ResidentLink`](../../citizenship/) — there is no separate on-chain "Nationality" credential. Whether nationality (or an equivalent residence-status credential for foreign residents) should ever be represented on-chain is deliberately deferred — see [`docs/BACKLOG.md`](../../../BACKLOG.md).

## Scope

**In scope:** the passport as a travel document only.

**Out of scope:**
- An on-chain nationality credential — deferred to a future "foreign residents" design topic (tracked in `docs/BACKLOG.md`).
- Any claim beyond possession — per the credentials-wide decision, this NFT carries no fields (no passport number, photo, expiry date, etc.).

## On-chain / Online / Offline breakdown

(See [`docs/operations/README.md`](../../../operations/README.md) for the convention.)

**On-chain:**
- Mint and burn, restricted to 外務省's admin role.
- Soulbound ownership (`tokenId ↔ address`) — no other fields.

**Online:**
- 外務省's officially-attested contract address, published the same way as other national authorities (see [Official-issuer attestation](#official-issuer-attestation)).

**Offline:**
- Nationality and identity verification at issuance and renewal — 外務省's existing real-world process (戸籍 documents, etc.), unchanged by this design.
- Physical passport issuance/surrender/loss-reporting process.

## Architecture

### Contract: `Passport` (issued by 外務省)

A soulbound, ERC-721-based token, following the same shape as `ResidentLink` and the corporations registration NFTs:

- **No per-token data** beyond standard ERC-721 ownership — consistent with the credentials-wide rule that these NFTs prove possession only.
- **Soulbound / non-transferable** — same as every other identity-linked NFT in this project.
- **Independent of `ResidentLink`.** A passport does not require holding a `ResidentLink` NFT — a Japanese national living abroad has no 住所地 registration (and so no `ResidentLink`) but can still hold a passport (noted already in ADR 0003: nationality and residency are decoupled). No cross-contract dependency between `Passport` and `ResidentLink`.

### Lifecycle

```
[not issued] --mint (外務省 only, after off-chain nationality+identity verification)--> [Active: NFT exists]
[Active]      --burn (外務省 only; reason kept off-chain: renewal, loss/theft, loss of nationality)--> [not issued]
[not issued]  --mint again (renewal or re-issuance, same off-chain verification)--------> [Active]
```

- **Authority-only mint/burn — no self-burn.** Unlike the nationality-renunciation right initially considered (see discussion log, Round 1), this credential is a controlled travel document, not a personal-rights status — it reverts to the citizenship default (mirrors how a physical passport is surrendered to the authority, not unilaterally destroyed by the holder).
- **Renewal is modeled as burn-and-reissue**, not an on-chain expiry field — consistent with carrying zero fields. "Holds a `Passport` NFT" means "administratively valid as of 外務省's last mint/burn action," not a continuously-tracked date.
- No on-chain reason codes for burn (same minimization principle as citizenship).

### Official-issuer attestation

Reuses the established mechanism: 外務省 publishes its `Passport` contract address at a well-known URI under its `.go.jp` domain, same principle as every other national authority in this project (taxation's 国税庁, the corporations design's 法務省).

## Relationship to nationality

This design deliberately does **not** build an on-chain nationality credential. 外務省 verifies an applicant's nationality off-chain, exactly as it does today, before minting. If a future feature (e.g. voting eligibility) needs to check nationality specifically — not "holds a currently-valid passport," which would incorrectly exclude nationals who simply haven't renewed a travel document they don't otherwise need — that feature will need to address nationality verification on its own terms at that time. See [`docs/BACKLOG.md`](../../../BACKLOG.md) for this as a deferred item, explicitly grouped with a possible future residence-status credential for foreign residents.

---

# パスポート(日本語)

**ステータス: 🟢 設計確定。** ユーザーとの議論を通じて概念・アーキテクチャ上の論点は解決済み。詳細な議論の経緯は [`discussion-log.md`](discussion-log.md)、正式なADRは [`docs/decisions/0006-passport-credential.md`](../../../decisions/0006-passport-credential.md) を参照。コントラクトコードはまだ実装していません。

## 概要

純粋な渡航文書クレデンシャルです: 外務省が発行する譲渡不可のNFTで、保有アドレスが現在、行政上有効な日本のパスポートを持っていることのみを証明します。**国籍は完全にオフチェーンで**外務省が確認します。市区町村が`ResidentLink`発行前に本人確認に使うのと同じ、既存の現実の行政プロセス(戸籍書類等)を使います — 別途オンチェーンの「国籍」クレデンシャルは存在しません。国籍(または外国人向けの在留資格相当のクレデンシャル)をいつかオンチェーンで表現すべきかどうかは、意図的に先送りしています — [`docs/BACKLOG.md`](../../../BACKLOG.md)を参照してください。

## スコープ

**対象:** 渡航文書としてのパスポートのみ。

**対象外:**
- オンチェーンの国籍クレデンシャル — 将来の「外国人」検討項目として先送り([`docs/BACKLOG.md`](../../../BACKLOG.md)で追跡)。
- 保持の事実以上のあらゆる主張 — 公的証明全体の決定により、このNFTは一切フィールドを持ちません(パスポート番号、写真、有効期限等は含まない)。

## オンチェーン/オンライン/オフラインの内訳

(規約は[`docs/operations/README.md`](../../../operations/README.md)参照)

**オンチェーン:**
- mintとburn。外務省の管理者ロールに限定。
- 譲渡不可の所有権(`tokenId ↔ アドレス`) — それ以外のフィールドはなし。

**オンライン:**
- 外務省の、公式に証明されたコントラクトアドレス。他の国の機関と同じ方法で公表([公式発行体の証明](#公式発行体の証明)参照)。

**オフライン:**
- 発行・更新時の国籍・本人確認 — 外務省の既存の現実のプロセス(戸籍書類等)で、この設計によって変更されない。
- 物理的なパスポートの発行・返納・紛失届のプロセス。

## アーキテクチャ

### コントラクト: `Passport`(外務省が発行)

`ResidentLink`や法人登録NFTと同じ形の、譲渡不可のERC-721ベースのトークンです。

- **トークンごとのデータは一切なし**(標準的なERC-721の所有権以外)— これらのNFTは保持の事実のみを証明する、という公的証明全体のルールと一致します。
- **譲渡不可(Soulbound)** — このプロジェクトの他の全てのアイデンティティ関連NFTと同様。
- **`ResidentLink`とは独立。** パスポートの取得に`ResidentLink`NFTの保有は要件としません — 海外在住の日本国民は住所地の登録(ひいては`ResidentLink`)を持ちませんが、パスポートは保持できます(ADR 0003で既に指摘済み: 国籍と住民資格は切り離されている)。`Passport`と`ResidentLink`の間にコントラクト間の依存関係はありません。

### ライフサイクル

上記の英語版の図を参照してください(内容は同一です)。

- **発行主体限定のmint/burn — 自主バーンなし。** 当初検討した国籍離脱の権利(議論ログRound 1参照)とは異なり、このクレデンシャルは個人の権利としての地位ではなく統制された渡航文書であるため、国民・住民設計のデフォルトに戻ります(物理的なパスポートも本人が一方的に破棄するのではなく、発行主体に返納するのと同じです)。
- **更新は、オンチェーンの有効期限フィールドではなく、burnして再発行する形でモデル化**します — フィールドを一切持たないという原則と一致します。「`Passport`NFTを保持している」ことは「外務省が最後にmint/burnを行った時点で、行政上有効である」ことを意味し、継続的に追跡される日付に基づく主張ではありません。
- burnの理由コードはオンチェーンに残しません(国民・住民設計と同じ最小化の原則)。

### 公式発行体の証明

確立済みの仕組みをそのまま流用します: 外務省は、自身の`.go.jp`ドメイン配下のwell-known URIで`Passport`コントラクトアドレスを公表します。このプロジェクトの他の全ての国の機関(納税設計の国税庁、法人設計の法務省)と同じ原理です。

## 国籍との関係

この設計は意図的に、オンチェーンの国籍クレデンシャルを**構築しません**。外務省は、今日と全く同じように、申請者の国籍をオフチェーンで確認した上でmintします。将来の機能(例えば投票資格)が、「現在有効なパスポートを持っているか」ではなく国籍そのものを確認する必要が生じた場合(前者だと、渡航の予定がなく更新していないだけの国民を誤って除外してしまいます)、その機能がその時点で独自に国籍確認の方法に対応する必要があります。これは[`docs/BACKLOG.md`](../../../BACKLOG.md)に先送り項目として記録されており、外国人住民向けの将来の在留資格クレデンシャルと明示的にまとめられています。

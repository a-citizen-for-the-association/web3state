# 0006. Passport credential: pure travel document, nationality verified off-chain

**Date:** 2026-10-06
**Status:** Accepted. Amended by [ADR 0032](0032-consistency-review-decisions.md): issuers re-issue after a recorded succession (R3.3) and burn on death (R3.10).

## Context

Following citizenship (ADR 0003), taxation (ADR 0004), and corporations (ADR 0005), the fourth state function designed was the first concrete instance of the general "credentials" pattern (diplomas, licenses, employee IDs, health/vaccination certificates, etc.): the passport. This also cleared a dependency deferred since the citizenship design — `ResidentLink` deliberately makes no nationality claim, so anything needing nationality specifically (a passport being the clearest example) needed its own credential.

Initial discussion considered splitting this into two credentials — a persistent **Nationality** credential (issued by 法務省) and a renewable **Passport** credential depending on it (issued by 外務省) — reasoning that nationality and passport validity have different lifecycles. Mid-discussion, the user clarified the actual intent: the national/foreign-resident distinction is understood to already exist in the *existing off-chain administrative data* municipalities and related national systems manage (analogous to 住基ネット) — the same off-chain information already relied on when verifying identity before minting `ResidentLink`. The user wants to build on that existing off-chain management rather than create a new on-chain credential for nationality, and wants passport designed purely as a travel document. See [`docs/state-design/credentials/passport/discussion-log.md`](../state-design/credentials/passport/discussion-log.md) for the full back-and-forth, including the scope correction.

## Decision

- **Only a `Passport` credential is designed — no on-chain `Nationality` credential is built.** 外務省 verifies an applicant's nationality entirely off-chain, using existing real-world administrative processes (戸籍 documents, etc.), the same pattern as how a municipality verifies identity off-chain before minting `ResidentLink`.
- **The NFT carries zero on-chain fields beyond standard ERC-721 ownership** — consistent with the credentials-wide rule (established in the general credentials discussion) that these NFTs prove possession only.
- **Soulbound / non-transferable**, same as every other identity-linked NFT in this project.
- **Authority-only mint/burn — no self-burn.** The self-initiated-renunciation exception considered for a hypothetical on-chain nationality credential (mirroring the real 国籍法 Art. 13 right) does not apply here, since nationality has no on-chain representation in this design. A passport is a controlled travel document, not a personal-rights status, so it reverts to the citizenship default.
- **Renewal is modeled as burn-and-reissue**, not an on-chain expiry field — "holds a `Passport` NFT" means "administratively valid as of 外務省's last mint/burn action," not a continuously-tracked date.
- **No dependency on `ResidentLink`.** A Japanese national living abroad has no 住所地 registration (and so no `ResidentLink`) but can still hold a passport — nationality and residency are decoupled (already noted in ADR 0003). No cross-contract check between `Passport` and `ResidentLink`.
- **Trust-anchor reuses the existing `.go.jp` mechanism** — no new design needed, since 外務省 is a national government body like 国税庁 and 法務省.
- **Whether nationality (or a residence-status/在留カード equivalent for foreign residents) should ever be represented on-chain is explicitly deferred**, to a future "foreign residents" design topic — tracked in [`docs/BACKLOG.md`](../BACKLOG.md).

## Consequences

- This is the first validated instance of the general "credentials" pattern (possession-only NFT, authority-issued, `.go.jp`/`.lg.jp`-style attestation, burn-and-reissue for renewal) — the remaining credential types (diploma, license, employee ID, health-insurance, vaccination) can now be designed by applying this same validated template, tuned per type.
- Any future feature needing nationality specifically (voting eligibility is the clearest anticipated case) cannot reuse `Passport` as a proxy for nationality, since passport validity and nationality have different lifecycles (someone can be a national without a currently-valid passport). That future feature will need to address nationality verification on its own terms — likely by finally deciding whether to build the deferred on-chain nationality/residence-status credential.
- The "credentials" feature as a whole remains 🟡 in progress — only passport is resolved; the other listed credential types (diploma, license, employee ID, health-insurance, vaccination) are still 🔴 not started, to be designed one at a time per the established process.

---

# 0006. パスポートのクレデンシャル: 純粋な渡航文書、国籍はオフチェーンで確認する(日本語)

**日付:** 2026-10-06
**ステータス:** Accepted。[ADR 0032](0032-consistency-review-decisions.md)で修正: 承継が記録されたら再発行し(R3.3)、死亡でburnする(R3.10)。

## 背景

国民・住民(ADR 0003)、税(ADR 0004)、法人(ADR 0005)に続き、4番目に設計した国家の機能は、一般的な「クレデンシャル」のパターン(卒業証書、免許、社員証、健康・ワクチン接種の証明書など)の最初の具体例、パスポートである。これは国民・住民の設計以来先送りしていた依存も解消した。`ResidentLink`は意図的に国籍について何も主張しないので、特に国籍を必要とするもの(パスポートが最も明確な例)には独自のクレデンシャルが必要だった。

当初の議論では、これを2つのクレデンシャルに分けることを検討した。永続する**国籍**のクレデンシャル(法務省が発行)と、それに依存する更新可能な**パスポート**のクレデンシャル(外務省が発行)である。国籍とパスポートの有効性はライフサイクルが違う、という理由だった。議論の途中で、ユーザーが実際の意図を明確にした: 国民と外国人住民の区別は、市区町村と関連する国のシステムが管理する*既存のオフチェーンの行政データ*(住基ネットに類するもの)にすでにある、と理解されている。これは`ResidentLink`をmintする前の本人確認ですでに頼っている、同じオフチェーンの情報である。ユーザーは国籍のために新しいオンチェーンのクレデンシャルを作るのではなく、その既存のオフチェーンの管理の上に構築したい。そしてパスポートを純粋な渡航文書として設計したい。範囲の修正を含むやりとりの全体は[`docs/state-design/credentials/passport/discussion-log.md`](../state-design/credentials/passport/discussion-log.md)を参照。

## 決定

- **設計するのは`Passport`のクレデンシャルだけで、オンチェーンの`Nationality`のクレデンシャルは作らない。** 外務省は、既存の現実の行政手続き(戸籍の書類など)を使い、申請者の国籍を完全にオフチェーンで確認する。市区町村が`ResidentLink`をmintする前にオフチェーンで本人確認するのと同じパターンである。
- **NFTは標準のERC-721の所有の他に、オンチェーンのフィールドを一切持たない。** これらのNFTは保有だけを証明するという、クレデンシャル全体のルール(一般的なクレデンシャルの議論で確立)と一致する。
- **譲渡不可(Soulbound)**。このプロジェクトの、アイデンティティに結びついた他のすべてのNFTと同じである。
- **mintとburnは当局だけ。本人によるburnはない。** 仮想のオンチェーンの国籍のクレデンシャルについて検討した、本人による離脱の例外(現実の国籍法第13条の権利にならう)はここには当てはまらない。この設計では国籍はオンチェーンで表されないからである。パスポートは管理された渡航文書であって個人の権利の地位ではないので、国民・住民の既定に戻る。
- **更新はburnと再発行としてモデル化する。** オンチェーンの有効期限のフィールドは置かない。「`Passport` NFTを持つ」とは、継続的に追跡される日付ではなく、「外務省の最後のmint/burnの時点で行政上有効」を意味する。
- **`ResidentLink`には依存しない。** 海外に住む日本国民には住所地の登録がなく(したがって`ResidentLink`もない)が、それでもパスポートを持てる。国籍と居住は切り離されている(ADR 0003ですでに指摘)。`Passport`と`ResidentLink`の間でコントラクトをまたぐ確認はしない。
- **信頼の起点は既存の`.go.jp`の仕組みを使い回す。** 外務省は国税庁や法務省と同じく国の機関なので、新しい設計は要らない。
- **国籍(あるいは外国人住民の在留資格/在留カードに相当するもの)をいずれオンチェーンで表すべきかは、明示的に先送りする。** 将来の「外国人住民」の設計テーマとし、[`docs/BACKLOG.md`](../BACKLOG.md)で管理する。

## 結果

- これは一般的な「クレデンシャル」のパターン(保有だけを示すNFT、当局が発行、`.go.jp`/`.lg.jp`式の証明、更新はburnと再発行)の最初の検証済みの例である。残りのクレデンシャルの種類(卒業証書、免許、社員証、健康保険、ワクチン接種)は、この検証済みのひな形を種類ごとに調整して当てはめれば設計できる。
- 特に国籍を必要とする将来の機能(最も明確に予想されるのは投票資格)は、`Passport`を国籍の代わりに使えない。パスポートの有効性と国籍はライフサイクルが違うからである(現在有効なパスポートを持たない国民もいる)。その将来の機能は、国籍の確認に独自に取り組む必要がある。おそらく、先送りしたオンチェーンの国籍/在留資格のクレデンシャルを作るかどうかを最終的に決めることになる。
- 「クレデンシャル」の機能全体は🟡進行中のまま。解決したのはパスポートだけで、他に挙げたクレデンシャルの種類(卒業証書、免許、社員証、健康保険、ワクチン接種)はまだ🔴未着手であり、確立した手順に従って1つずつ設計する。

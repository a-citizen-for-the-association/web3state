# 0005. Corporate registration model: authority-issued, on-chain, officer-name-only NFT

**Date:** 2026-10-03
**Status:** Accepted. [ADR 0030](0030-securities-model.md) adds beneficial-owner names (25% or more) to the corporate record.

## Context

Following citizenship/residency (ADR 0003) and taxation (ADR 0004), the third state function designed was corporate registration. The initial proposal: all corporations register with a supervisory authority, which mints an NFT linking the corporation's address to that oversight relationship; unlike individual data, corporate information is recorded on-chain, reflecting a public right-to-know; individuals checking an NFT before transacting with a corporation (employment, contracts, purchases) can confirm which authority supervises it; the goal is reducing shell companies and law-evasion vehicles.

Discussion (see [`docs/state-design/corporations/discussion-log.md`](../state-design/corporations/discussion-log.md)) worked through nine issues: officer/representative privacy versus the citizenship design's individual-privacy model, which authority supervises ordinary corporations, whether multiple NFTs per corporation are allowed, whether a corporation has its own address and how it's controlled, how mutable corporate data is updated, transferability, the scope of NFT-checking, exclusion of sole proprietors, and what the transparency goal actually achieves.

## Decision

- **Scope:** only juridical persons (法人格を持つ法人). Sole proprietors (個人事業主) are excluded — they use their own `ResidentLink` identity.
- **Officer/representative names are public, plain text, on-chain** — matching today's status quo (names are already disclosed via company websites, business cards, and existing commercial registers). **Officer/representative addresses are never recorded on-chain, anywhere.** The issuing authority verifies an officer's identity via their `ResidentLink` NFT privately, off-chain, at registration time. Publishing a name linked to an address would deanonymize that officer's entire on-chain financial activity, undermining the privacy model the taxation design depends on — this is the central design tension this ADR resolves by strict separation (names public, addresses never public, never cross-referenced on-chain).
- **Specially-regulated corporations register with their existing real-world regulator** (e.g. 金融庁 for financial institutions, 厚生労働省 for medical institutions). **All other corporations register, by default, with 法務省 (実務窓口: 法務局)** — a hypothetical extension of current law building on its existing ownership of 会社法 and 商業登記, chosen over 総務省 (no real nexus to corporate existence) and 経済産業省 (industrial/commercial policy, not the basic law of corporate existence).
- **A corporation may hold multiple NFTs**, one per applicable registration/supervision relationship, each from an independent per-authority contract — mirroring the citizenship/taxation pattern of multiple purpose-specific credentials rather than one monolithic token. No on-chain aggregation/master list.
- **A corporation's own address is a contract address, not an EOA**, governed by a multisig **signed with its officers' own personal `ResidentLink`-linked keys** — explicitly not a separate, dedicated "corporate signing key" (the user rejected this as unnecessary complexity once it was established that the multisig's public signer-address list, with no names attached anywhere on-chain, does not violate the name/address separation above). The specific audited multisig/smart-contract-wallet implementation is deferred to implementation time (tracked in [`docs/BACKLOG.md`](../BACKLOG.md)).
- **Corporate records hold substantive, mutable on-chain data** (name, registered address, business purpose, capital, officer names) — unlike citizenship's near-empty token. **The issuing authority can update specific fields via an authority-only function**; burn is reserved for actual cessation (解散, license revocation, or the absorbed party in a merger), not routine updates.
- **Soulbound / non-transferable**, same as citizenship.
- **This feature provides only the capability to check a corporation's NFT(s)** — it does not mandate an on-chain check as a gate for any transaction type (employment, contracts, purchases, etc.); enforcement, if any, is left to whatever process handles a given transaction.
- **Official-issuer attestation reuses the citizenship/taxation mechanism**: each authority publishes its registration-NFT contract address at a well-known URI under its own vetted government domain (`.go.jp` for national bodies).
- **The transparency goal is explicitly scoped**: this design increases transparency (public officer names + fully public corporate financial activity, exposing mismatches between declared business purpose and actual activity) — it does not itself prevent shell-company formation, nor does it automatically prove that a specific payment benefited a specific officer personally (that link is deliberately never public; establishing it requires a legitimate investigative process, e.g. police using their existing investigative authority). A corrupt investigative body is an acknowledged residual failure mode this design cannot solve.

## Consequences

- Corporate registration contracts need real on-chain data storage and an authority-only update mechanism — a materially different contract shape from `ResidentLink`'s near-empty, existence-based model.
- The project now has a working precedent for "public entity, private individuals within it": disclose what the entity does and who publicly represents it, never disclose the representing individuals' addresses — likely reusable for any future feature involving an organization with named officers (e.g. government bodies' own on-chain presence, if ever designed).
- Selecting and specifying the actual audited multisig/wallet standard corporations use is deferred — tracked in `docs/BACKLOG.md` as an implementation-time task, same treatment as the `.go.jp` attestation implementation from taxation.
- This design does not, by itself, address beneficial-ownership obfuscation through layered corporate structures (a company owned by another company owned by another company) — only the direct officer/representative of a given corporation is named. Not raised as an open issue by the user; worth revisiting if a future feature needs to pierce multi-layer ownership structures.

---

# 0005. 法人登録モデル: 当局が発行する、オンチェーンの、役員の氏名だけを載せるNFT(日本語)

**日付:** 2026-10-03
**ステータス:** Accepted。[ADR 0030](0030-securities-model.md)が法人の記録に実質的支配者(25%以上)の氏名を加える。

## 背景

国民・住民(ADR 0003)と税(ADR 0004)に続き、3番目に設計した国家の機能は法人登録である。当初の提案: すべての法人は監督当局に登録し、当局は法人のアドレスとその監督関係を結びつけるNFTをmintする。個人のデータと違い、法人の情報は公共の知る権利を反映してオンチェーンに記録する。法人と取引(雇用、契約、購入)する前にNFTを確認する個人は、どの当局がその法人を監督しているかを確かめられる。目的はペーパーカンパニーや脱法の器を減らすことである。

議論([`docs/state-design/corporations/discussion-log.md`](../state-design/corporations/discussion-log.md)を参照)では9つの論点を検討した: 役員・代表者のプライバシーと国民・住民の設計の個人のプライバシーのモデルとの関係、通常の法人をどの当局が監督するか、1つの法人が複数のNFTを持てるか、法人が自らのアドレスを持つか、持つならどう管理するか、変わりうる法人のデータをどう更新するか、譲渡可能性、NFTの確認の範囲、個人事業主の除外、透明性の目標が実際に何を達成するか。

## 決定

- **範囲:** 法人格を持つ法人だけ。個人事業主は除外する。個人事業主は自らの`ResidentLink`のアイデンティティを使う。
- **役員・代表者の氏名は、公開の平文でオンチェーンに載せる。** 今日の現状と同じである(氏名はすでに会社のWebサイト、名刺、既存の商業登記で開示されている)。**役員・代表者のアドレスは、オンチェーンのどこにも決して記録しない。** 発行する当局は、登録時に、役員の本人確認をその`ResidentLink` NFTで非公開に、オフチェーンで行う。アドレスに結びついた氏名を公開すれば、その役員のオンチェーンの金融活動すべての匿名性が失われ、税の設計が依存するプライバシーのモデルが損なわれる。これがこのADRが厳格な分離(氏名は公開、アドレスは決して公開せず、オンチェーンで決して突き合わせない)で解決する、設計上の中心的な緊張である。
- **特別に規制される法人は、現実の既存の規制当局に登録する**(例: 金融機関は金融庁、医療機関は厚生労働省)。**それ以外のすべての法人は、既定で法務省(実務窓口: 法務局)に登録する。** 会社法と商業登記を既に所管していることを踏まえた、現行法の仮想の拡張である。総務省(法人の存在と実際のつながりがない)と経済産業省(産業・商業の政策であり、法人の存在の基本法ではない)よりもこちらを選んだ。
- **1つの法人は複数のNFTを持てる。** 該当する登録・監督の関係ごとに1つで、それぞれ当局ごとの独立したコントラクトから発行される。1つの一枚岩のトークンではなく、目的ごとの複数のクレデンシャルという国民・住民と税のパターンにならう。オンチェーンの集約やマスターリストは置かない。
- **法人自身のアドレスはEOAではなくコントラクトのアドレスであり**、マルチシグで管理する。**署名は役員自身の、`ResidentLink`に結びついた個人の鍵で行う。** 専用の「法人の署名鍵」は明示的に使わない(マルチシグの公開された署名者のアドレスのリストには、オンチェーンのどこにも氏名が付かないので、上の氏名とアドレスの分離に反しないことが確認された後、ユーザーはこれを不要な複雑さとして退けた)。具体的な監査済みのマルチシグ/スマートコントラクトウォレットの実装は実装時に先送りする([`docs/BACKLOG.md`](../BACKLOG.md)で管理)。
- **法人の記録は、中身のある、変わりうるオンチェーンのデータを持つ**(名称、登記上の住所、事業目的、資本金、役員の氏名)。国民・住民のほぼ空のトークンとは違う。**発行する当局は、当局だけが呼べる関数で特定のフィールドを更新できる。** burnは、日常の更新ではなく、実際に存在しなくなる場合(解散、免許の取消し、合併で吸収される側)に限る。
- **譲渡不可(Soulbound)**。国民・住民と同じである。
- **この機能が提供するのは、法人のNFTを確認する機能だけである。** どの種類の取引(雇用、契約、購入など)についても、オンチェーンの確認を関門として義務付けない。強制するかどうかは、その取引を扱う手続きに委ねる。
- **公式な発行者の証明は、国民・住民と税の仕組みを使い回す:** 各当局は、登録NFTのコントラクトのアドレスを、自らの審査された政府ドメイン(国の機関は`.go.jp`)の下のwell-known URIで公開する。
- **透明性の目標は明示的に範囲を限る:** この設計は透明性を高める(公開された役員の氏名と、完全に公開された法人の金融活動により、届け出た事業目的と実際の活動の食い違いが表に出る)。ペーパーカンパニーの設立そのものは防がない。特定の支払いが特定の役員個人の利益になったことも、自動的には証明しない(そのつながりは意図的に決して公開しない。証明には正当な捜査の手続き、例えば警察の既存の捜査権限が必要である)。捜査機関の腐敗は、この設計では解決できない残存する失敗の形として認める。

## 結果

- 法人登録のコントラクトには、実際のオンチェーンのデータの保存と、当局だけが使える更新の仕組みが必要になる。`ResidentLink`のほぼ空の、存在に基づくモデルとは実質的に異なるコントラクトの形である。
- プロジェクトは「公的な主体、その中の非公開の個人」の実用的な前例を得た: 主体が何をし、誰が公に代表しているかは開示し、代表する個人のアドレスは決して開示しない。氏名のある役員を持つ組織が関わる将来の機能(例: もし設計するなら、政府機関自身のオンチェーンでの存在)で使い回せる可能性が高い。
- 法人が使う実際の監査済みのマルチシグ/ウォレットの標準の選定と仕様は先送りする。税の`.go.jp`の証明の実装と同じ扱いで、実装時の作業として`docs/BACKLOG.md`で管理する。
- この設計自体は、重層的な法人の構造(別の会社が所有する会社が所有する会社)による実質的な所有の隠蔽には対処しない。名前が載るのは、その法人の直接の役員・代表者だけである。ユーザーは未解決の課題として挙げていない。多層の所有構造を突き抜ける必要がある将来の機能が出てきたら、見直す価値がある。

# Corporations (法人): Authority-Issued Registration NFT

**Status: 🟢 Spec drafted.** Conceptual and architecture questions resolved through discussion with the user; see [`discussion-log.md`](discussion-log.md) for the full reasoning and [`docs/decisions/0005-corporate-registration-model.md`](../../decisions/0005-corporate-registration-model.md) for the formal ADR. Updated for the cross-feature consistency review ([ADR 0032](../../decisions/0032-consistency-review-decisions.md)). No contract code written yet.

## Summary

Every juridical-person corporation (法人格を持つ法人: 株式会社, 合同会社, 一般社団法人, etc. — **not** sole proprietors) must register with the authority (or authorities) that have oversight of it. That authority mints a **soulbound, on-chain, authority-updatable** NFT linking the corporation's own address to the registration/supervision relationship. Unlike individual data ([`ResidentLink`](../citizenship/)), corporate information is recorded **on-chain in full** — name, registered address, business purpose, capital, officer/representative **names** and beneficial-owner **names** ([ADR 0030](../../decisions/0030-securities-model.md)) — reflecting that corporations, unlike individuals, are already subject to public disclosure today (Japan's 商業登記簿 is already public record). The record has no field for officers' addresses, but officers' own addresses appear as the signers of the corporation's multisig, so becoming an officer or a beneficial owner means accepting that one's name may be linked to one's address (consistency review R5.1, R5.2, R5.8, [ADR 0032](../../decisions/0032-consistency-review-decisions.md)).

**Goal, precisely stated:** this feature aims to increase transparency (cheap, instant, public visibility of who runs a company and how its money moves), not to prevent shell-company formation outright. See [Effectiveness](#effectiveness-what-this-does-and-doesnt-achieve).

## Scope

**In scope:** registration and on-chain disclosure for actual juridical persons.

**Out of scope:**
- Sole proprietors (個人事業主) — not separate legal entities under Japanese law; they operate under their own `ResidentLink` identity.
- Substantive vetting of whether a registering business is "real" (beyond whatever the issuing authority already does) — this design does not solve shell-company *prevention*, only *transparency*.
- Mandating that any particular real-world transaction (employment, a sale, a purchase) must check a corporation's NFT — this feature provides the capability to check; enforcement is left to whatever process handles a given transaction.

## On-chain / Online / Offline breakdown

(See [`docs/operations/README.md`](../../operations/README.md) for the convention.)

**On-chain:**
- The registration NFT itself: corporate name, registered address, business purpose, capital, officer/representative **names** (plain text), beneficial-owner **names** ([ADR 0030](../../decisions/0030-securities-model.md)), a foreign flag for foreign companies' branches, and which authority issued it — all mutable by the issuing authority (see [Lifecycle](#lifecycle)).
- On every mint and burn, the authority's `Corporation` flag for the corporation's address is written to `OfficialContractRegistry`, so the address counts as registered (see the [registry definition](../certified-stablecoin/README.md)) (consistency review R1.5, [ADR 0032](../../decisions/0032-consistency-review-decisions.md)).
- The corporation's own transactions (any stablecoin or other on-chain activity via its contract address) — fully public, same as any other address.
- No officer address field in the record. Officers' own addresses appear as the multisig's signers (see [The corporation's own address](#the-corporations-own-address)) (consistency review R5.1, R5.8, [ADR 0032](../../decisions/0032-consistency-review-decisions.md)).

**Online:**
- Each authority's officially-attested NFT-issuing contract address, published the same way as the citizenship/taxation designs (see [Official-issuer attestation](#official-issuer-attestation)).

**Offline:**
- The issuing authority verifies an officer's/representative's identity via their `ResidentLink` NFT privately, at registration time — the same in-person verification model as citizenship, just never exposed on-chain.
- Substantive due diligence on whether a registering business is legitimate (beyond identity verification) is the issuing authority's existing process, unchanged by this design.
- Beyond what the record and the signer list show, linking a person to an address requires the person's own act or a legitimate legal process (e.g., police with investigative authority obtaining an officer's address through proper channels) (consistency review R5.8, [ADR 0032](../../decisions/0032-consistency-review-decisions.md)).

## Architecture

### Per-authority registration contracts

Each supervisory authority deploys its own registration-NFT contract, **`CorporateRegistration`** (one per supervising authority) (consistency review R4.3, [ADR 0032](../../decisions/0032-consistency-review-decisions.md)), following the same per-authority pattern established for citizenship:

- **Specially-regulated corporations** (financial institutions, medical institutions, etc.) register with their existing real-world regulator (e.g. 金融庁 for banks, 厚生労働省 for medical institutions).
- **All other corporations** register, by default, with **法務省** (実務窓口: 法務局) — under a hypothetical extension of current law giving it this supervisory role, building on its existing ownership of 会社法 and 商業登記. This is the general-purpose equivalent of how municipalities handle citizenship.
- **Foreign companies' branches in Japan** register as corporations, with a foreign flag (consistency review R2.3, [ADR 0032](../../decisions/0032-consistency-review-decisions.md)).
- **A corporation may hold multiple NFTs** — one per applicable registration/supervision relationship (e.g. a bank holds both a 法務省/法務局 registration NFT and a 金融庁 license NFT). A verifier checks whichever specific authority's contract is relevant to what they want to confirm. In `OfficialContractRegistry` each authority keeps its own flag, so burning one NFT does not deregister a corporation that is still registered elsewhere (consistency review R1.1, [ADR 0032](../../decisions/0032-consistency-review-decisions.md)).

### Officer/representative data

- **Names: public, plain text, on-chain.** This matches today's status quo (company websites, business cards, and existing commercial registers already disclose this).
- **Addresses: not a field of the record.** The issuing authority verifies an officer's `ResidentLink` NFT privately/off-chain at registration time, and the record contains only the name. No hash of an address either (unsafe one-wayness at this threat model, per the citizenship design's reasoning). But officers' own addresses appear as the multisig's signers (below), so a name can be linked to an address — exactly so with a single officer. Becoming an officer means accepting this, as one's own act, like a VIP (consistency review R5.1, R5.8, [ADR 0032](../../decisions/0032-consistency-review-decisions.md)).
- **Beneficial owners** (25% or more of voting rights, traced through all layers) are named in the record ([ADR 0030](../../decisions/0030-securities-model.md)). Like officers, they are a public class and accept that their names may be linked to their addresses (consistency review R5.2, [ADR 0032](../../decisions/0032-consistency-review-decisions.md)).

### The corporation's own address

- A corporation's registered address is a **contract address, not an EOA** — reflecting that corporate action is, almost by definition, not something a single individual should execute unilaterally.
- It is governed by a **multisig signed with its officers' own personal keys** (the same keys tied to their `ResidentLink` NFT) — not a separate, dedicated "corporate signing key." A multisig's owner-address list is necessarily public, and the officers' names are public, so an outside observer can pair them — exactly with one officer, narrowed to the signer list with several. This is accepted (see above) (consistency review R5.1, [ADR 0032](../../decisions/0032-consistency-review-decisions.md)).
- **Signer rotation** (consistency review R3.6, [ADR 0032](../../decisions/0032-consistency-review-decisions.md)): normally the multisig itself rotates its signers alongside the registered officer change. If the threshold cannot be met (e.g. an officer's death or key loss), the registrar replaces the signers on a registered officer change after a public waiting period; objections go to a court. Signers whose address has lost its registration or is suspended do not count (`NationalAbroad` officers still count).
- Which specific audited multisig/smart-contract-wallet implementation to use (e.g. Safe) is **deferred to implementation time** — tracked in [`docs/BACKLOG.md`](../../BACKLOG.md), out of scope for this design.

### Official-issuer attestation

Reuses the mechanism established for citizenship/taxation: each authority publishes its registration-NFT contract address at a well-known URI under its own vetted government domain (`.go.jp` for national bodies, the applicable domain for any other regulator) — the root of trust. 総務省 mirrors these announcements in the on-chain `OfficialContractRegistry` ([ADR 0015](../../decisions/0015-political-donations-model.md); see the [registry definition](../certified-stablecoin/README.md)), so other contracts can check automatically (consistency review R1.5, [ADR 0032](../../decisions/0032-consistency-review-decisions.md)).

### Lifecycle

```
[not registered] --mint (authority only, after verifying officers off-chain)--> [Active: NFT exists, fields populated]
[Active]          --update specific fields (authority only)-------------------> [Active: fields changed, same NFT]
[Active]          --burn (authority only; actual cessation: dissolution,
                   license revocation, merger-absorption)---------------------> [not registered]
```

- **Soulbound / non-transferable**, same as citizenship — a registration cannot be sold or handed to a different legal entity.
- **Updates, not burn-and-reissue, for routine changes.** Unlike citizenship's near-empty token, a corporate record has substantive fields (name, address, business purpose, representative, capital) that legitimately change (商号変更, 本店移転, officer changes, capital changes) without the company ceasing to exist. The issuing authority can update specific fields via an authority-only function. Burn is reserved for actual cessation (解散, license revocation, or the absorbed party in a merger) — not used for routine updates.
- **No self-service updates or burns** — only the issuing authority, mirroring citizenship's "registration and revocation: authority-only" rule.
- **Dissolution** (consistency review R3.5, [ADR 0032](../../decisions/0032-consistency-review-decisions.md)): before the registration NFT is burned, the corporation (its liquidator) burns the credentials it issued, cancels its share classes and distributes its assets; the registrar checks this from public data. Anything left over moves by the heavy successor path, proposed by the registrar (consistency review R3.4, [ADR 0032](../../decisions/0032-consistency-review-decisions.md); see the [certified-stablecoin spec](../certified-stablecoin/README.md)).
- **Merger** (consistency review R3.5, [ADR 0032](../../decisions/0032-consistency-review-decisions.md)): a light-path transfer to the acquirer, signed by both corporations' multisigs and confirmed by the corporation's registrar (usually 法務局) (follow-up gap, [consistency review](../../architecture/consistency-review.md)) (employee IDs re-issued, shares exchanged and cancelled); the absorbed party's NFT is then burned.

## Effectiveness: what this does and doesn't achieve

This design's goal is **transparency**, not shell-company prevention:

- **What becomes easy:** confirming, for free and instantly, who is publicly named as a company's officer/representative, and observing the company's full on-chain financial activity — exposing mismatches (e.g., a company whose declared business purpose doesn't match its transaction volume/pattern) that today require banking-record access (subpoena power) to even see.
- **What doesn't become automatic:** proving a specific payment reached a specific officer's *personal* benefit. The record does not say which signer is which officer; with a single officer the pairing is exact, with several it is only narrowed to the signer list (accepted, consistency review R5.1, [ADR 0032](../../decisions/0032-consistency-review-decisions.md)). Beyond that, establishing the link still requires a legitimate investigative process (e.g., police, who already have investigative authority today) obtaining it through proper channels, same as today's investigations into financial crime.
- **The intended effect:** public, pattern-level transparency plus existing investigative authority (and the possibility of public pressure forcing voluntary disclosure) make it harder for suspected misconduct to simply fade from attention unresolved, compared to today, where the underlying financial activity isn't visible to the public at all. A corrupt investigative body remains a residual failure mode this design cannot solve.

## Open items for later

Tracked in [`docs/BACKLOG.md`](../../BACKLOG.md):
- Selecting the specific audited multisig/smart-contract-wallet implementation corporations use.

---

# 法人: 監督官庁発行の登録NFT(日本語)

**ステータス: 🟢 設計確定。** ユーザーとの議論を通じて概念・アーキテクチャ上の論点は解決済み。詳細な議論の経緯は [`discussion-log.md`](discussion-log.md)、正式なADRは [`docs/decisions/0005-corporate-registration-model.md`](../../decisions/0005-corporate-registration-model.md) を参照。機能間の整合性レビュー([ADR 0032](../../decisions/0032-consistency-review-decisions.md))に合わせて更新しました。コントラクトコードはまだ実装していません。

## 概要

法人格を持つ全ての法人(株式会社、合同会社、一般社団法人等 — 個人事業主は**含まない**)は、自身を監督する主体(複数の場合あり)に登録しなければなりません。その主体が、法人自身のアドレスと登録・監督関係を紐づける、**譲渡不可・オンチェーン・発行主体による更新が可能**なNFTを発行します。個人のデータ([`ResidentLink`](../citizenship/))とは異なり、法人情報は**オンチェーンに全て記載**します — 商号、所在地、事業目的、資本金、役員・代表者の**氏名**、実質的支配者の**氏名**([ADR 0030](../../decisions/0030-securities-model.md))です。これは、個人とは異なり法人が既に今日公開情報である(日本の商業登記簿は既に公開記録である)ことを反映しています。記録に役員のアドレスの欄はありませんが、役員自身のアドレスは法人のマルチシグの署名者として載るので、役員や実質的支配者になることは、氏名がアドレスと結びつきうることを受け入れることになります(整合性レビューR5.1、R5.2、R5.8、[ADR 0032](../../decisions/0032-consistency-review-decisions.md))。

**目標を正確に述べると:** この機能が目指すのは透明性の向上(誰が会社を運営し、資金がどう動いているかを安く・即座に・公に確認できること)であり、ペーパーカンパニーの設立そのものを防ぐことではありません。[効果](#効果-この設計で達成できること達成できないこと)を参照してください。

## スコープ

**対象:** 法人格を持つ実際の法人の登録とオンチェーン開示。

**対象外:**
- 個人事業主 — 日本法上、別の法人格を持たず、自身の`ResidentLink`アイデンティティで事業を行う。
- 登録しようとする事業が「本物」かどうかの実質的な審査(発行主体が既に行っている以上のもの) — この設計はペーパーカンパニーの**防止**ではなく、**透明性**のみを解決する。
- 特定の現実の取引(就職、売買、購入)において、法人のNFT確認を必須とすること — この機能は確認できる能力を提供するのみで、強制するかどうかは各取引を扱うプロセス側に委ねる。

## オンチェーン/オンライン/オフラインの内訳

(規約は[`docs/operations/README.md`](../../operations/README.md)参照)

**オンチェーン:**
- 登録NFT自体: 商号、所在地、事業目的、資本金、役員・代表者の**氏名**(平文)、実質的支配者の**氏名**([ADR 0030](../../decisions/0030-securities-model.md))、外国会社の支店であることの印、発行主体 — いずれも発行主体により更新可能([ライフサイクル](#ライフサイクル)参照)。
- mintとburnのたびに、法人のアドレスについての発行主体の`Corporation`フラグを`OfficialContractRegistry`に書き込み、アドレスが登録済みとして扱われるようにする([レジストリの定義](../certified-stablecoin/README.md)参照)(整合性レビューR1.5、[ADR 0032](../../decisions/0032-consistency-review-decisions.md))。
- 法人自身の取引(コントラクトアドレスを通じたステーブルコイン等のあらゆるオンチェーン活動) — 他のアドレスと同様、完全に公開される。
- 記録に役員のアドレスの欄はない。役員自身のアドレスはマルチシグの署名者として載る([法人自身のアドレス](#法人自身のアドレス)参照)(整合性レビューR5.1、R5.8、[ADR 0032](../../decisions/0032-consistency-review-decisions.md))。

**オンライン:**
- 各主体の、公式に証明されたNFT発行コントラクトアドレス。国民・住民・納税設計と同じ方法で公表([公式発行体の証明](#公式発行体の証明)参照)。

**オフライン:**
- 発行主体は、登記時に役員・代表者の`ResidentLink`をオフチェーンで内々に確認する — citizenshipと同じ対面確認モデルだが、オンチェーンには一切露出しない。
- 登録しようとする事業が正当かどうかの実質的なデューデリジェンス(本人確認以上のもの)は、発行主体の既存のプロセスのままで、この設計では変更しない。
- 記録と署名者の一覧からわかる以上に、人とアドレスを結びつけるには、本人の行為か正当な法的手続き(例: 正規の手続きを経て役員のアドレスを入手する捜査権を持つ警察)が必要である(整合性レビューR5.8、[ADR 0032](../../decisions/0032-consistency-review-decisions.md))。

## アーキテクチャ

### 主体ごとの登録コントラクト

各監督主体は、国民・住民設計で確立したのと同じ、主体ごとのパターンに従って、自身の登録NFTコントラクト **`CorporateRegistration`**(監督官庁ごとに1つ)をデプロイします(整合性レビューR4.3、[ADR 0032](../../decisions/0032-consistency-review-decisions.md))。

- **特殊な規制対象の法人**(金融機関、医療機関等)は、既存の現実の規制当局(銀行なら金融庁、医療機関なら厚生労働省等)に登録します。
- **それ以外の全ての法人**は、デフォルトで**法務省**(実務窓口: 法務局)に登録します — 既に会社法と商業登記を所管していることを基盤に、この監督的役割を与える現行法の仮想的な拡張によるものです。これは国民・住民における市区町村の、一般法人版に相当します。
- **外国会社の日本支店**は、外国会社の印付きで法人として登録します(整合性レビューR2.3、[ADR 0032](../../decisions/0032-consistency-review-decisions.md))。
- **法人は複数のNFTを保有できます** — 適用される登録・監督関係ごとに1つずつです(例: 銀行は法務省/法務局の登記NFTと金融庁の免許NFTの両方を持つ)。確認したい内容に応じて関連する主体のコントラクトを個別に確認します。`OfficialContractRegistry`では主体ごとに別のフラグを持つので、1つのNFTをburnしても、他でまだ登録されている法人が未登録になることはありません(整合性レビューR1.1、[ADR 0032](../../decisions/0032-consistency-review-decisions.md))。

### 役員・代表者のデータ

- **氏名: 公開、平文、オンチェーン。** これは今日の状況(会社のホームページ、名刺、既存の商業登記で既に開示されている)と一致します。
- **アドレス: 記録の欄にはしません。** 発行主体は登記時に役員の`ResidentLink`をオフチェーンで内々に確認し、記録には氏名のみが含まれます。アドレスのハッシュも載せません(この脅威モデルでは安全な一方向性を持たないため、国民・住民設計と同じ理由)。ただし役員自身のアドレスはマルチシグの署名者として載る(下記)ので、氏名はアドレスと結びつきえます — 役員が1人なら正確に結びつきます。役員になることは、要人と同じく本人の行為として、これを受け入れることです(整合性レビューR5.1、R5.8、[ADR 0032](../../decisions/0032-consistency-review-decisions.md))。
- **実質的支配者**(すべての層をたどって議決権の25%以上)は記録に氏名を載せます([ADR 0030](../../decisions/0030-securities-model.md))。役員と同じく公開の層であり、氏名がアドレスと結びつきうることを受け入れます(整合性レビューR5.2、[ADR 0032](../../decisions/0032-consistency-review-decisions.md))。

### 法人自身のアドレス

- 法人の登録アドレスは**コントラクトアドレス(EOAではない)**とします — 法人としての行動は、ほぼ定義上、個人が単独で実行すべきものではないことを反映しています。
- これは、**役員本人の個人の鍵**(`ResidentLink`NFTに紐づく鍵と同じもの)で署名するマルチシグによって統治されます — 専用の別の「法人署名鍵」ではありません。マルチシグの所有者アドレス一覧は必然的に公開され、役員の氏名も公開されるので、外部の観察者は両者を突き合わせられます — 役員が1人なら正確に、複数なら署名者の一覧まで絞り込めます。これは受け入れます(上記参照)(整合性レビューR5.1、[ADR 0032](../../decisions/0032-consistency-review-decisions.md))。
- **署名者の交代**(整合性レビューR3.6、[ADR 0032](../../decisions/0032-consistency-review-decisions.md)): 通常は、登録された役員の変更に合わせてマルチシグ自身が署名者を交代します。署名数に届かない場合(例: 役員の死亡や鍵の紛失)は、登録された役員の変更に基づき、公開の待機期間の後に登録者が署名者を入れ替えます。異議は裁判所へ申し立てます。登録の外れた、または停止中のアドレスの署名者は数えません(`NationalAbroad`の役員は数えます)。
- 実際にどの監査済みマルチシグ/スマートコントラクトウォレット実装(Safe等)を使うかは**実装時に決定**します — [`docs/BACKLOG.md`](../../BACKLOG.md)で追跡し、この設計の対象外とします。

### 公式発行体の証明

国民・住民・納税設計で確立した仕組みをそのまま流用します: 各主体が、自身の審査済みの政府ドメイン(国の機関なら`.go.jp`、その他の規制当局なら該当するドメイン)配下のwell-known URIで、登録NFTコントラクトアドレスを公表します。これが信頼の根拠です。総務省はこの公表をオンチェーンの`OfficialContractRegistry`に写し([ADR 0015](../../decisions/0015-political-donations-model.md)。[レジストリの定義](../certified-stablecoin/README.md)参照)、他のコントラクトが自動で確認できるようにします(整合性レビューR1.5、[ADR 0032](../../decisions/0032-consistency-review-decisions.md))。

### ライフサイクル

上記の英語版の図を参照してください(内容は同一です)。

- **譲渡不可(Soulbound)**。国民・住民と同様、登録を売買したり別の法人に譲渡したりすることはできません。
- **日常的な変更は、burnして再発行するのではなく更新します。** 国民・住民のほぼ空のトークンとは異なり、法人の記録には実質的なフィールド(商号、所在地、事業目的、代表者、資本金)があり、法人が消滅しなくても正当に変化します(商号変更、本店移転、役員変更、増資等)。発行主体は、発行主体限定の関数で特定のフィールドを更新できます。burnは実際の消滅(解散、免許取消、合併による消滅会社側)のためだけに使い、日常的な更新には使いません。
- **本人によるセルフサービスの更新・バーンはありません** — 発行主体のみが行えます。国民・住民の「登録・失効は発行主体のみ」というルールと同じです。
- **解散**(整合性レビューR3.5、[ADR 0032](../../decisions/0032-consistency-review-decisions.md)): 登録NFTをburnする前に、法人(清算人)は発行したクレデンシャルをburnし、株式の種類を消却し、資産を分配します。登録者はこれを公開データで確認します。残ったものは、登録者が提案する重い承継の手続きで移します(整合性レビューR3.4、[ADR 0032](../../decisions/0032-consistency-review-decisions.md)。[認定ステーブルコインの仕様](../certified-stablecoin/README.md)参照)。
- **合併**(整合性レビューR3.5、[ADR 0032](../../decisions/0032-consistency-review-decisions.md)): 両社のマルチシグが署名し、その法人の登録者(通常は法務局)が確認する(追加の抜け、[整合性レビュー](../../architecture/consistency-review.md))、取得する側への軽い手続きの移転です(社員証は再発行、株式は交換して消却)。その後、消滅会社側のNFTをburnします。

## 効果: この設計で達成できること・達成できないこと

この設計の目標は**透明性**であり、ペーパーカンパニーの防止ではありません。

- **容易になること:** 誰が会社の役員・代表者として公に名前を連ねているかを無料・即座に確認できること、そして会社の全オンチェーン金融活動を観察できること — 事業目的と実際の取引量・パターンの不一致(今日なら銀行記録へのアクセス権限がなければ見えないもの)が明らかになります。
- **自動的にはならないこと:** 特定の支払いが特定の役員**個人**の利益になったことの証明。記録はどの署名者がどの役員かを示しません。役員が1人なら対応は正確ですが、複数なら署名者の一覧まで絞り込めるだけです(受け入れる。整合性レビューR5.1、[ADR 0032](../../decisions/0032-consistency-review-decisions.md))。それ以上を明らかにするには、正当な捜査プロセス(今日既に捜査権を持つ警察等)が正規の手続きを経てこれを入手する必要があり、今日の金融犯罪捜査と同じです。
- **意図する効果:** パターンレベルでの公的な透明性と、既存の捜査権限(および世論による任意開示の圧力の可能性)が組み合わさることで、今日のように基礎となる金融活動が全く公に見えない状況と比べて、疑惑が有耶無耶のまま終わることを防ぎやすくなります。捜査機関自体の腐敗は、この設計では解決できない、認識した上での残存リスクです。

## 今後の課題

[`docs/BACKLOG.md`](../../BACKLOG.md)で追跡:
- 法人が使用する、具体的な監査済みマルチシグ/スマートコントラクトウォレット実装の選定。

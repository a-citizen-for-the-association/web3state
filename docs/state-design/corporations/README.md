# Corporations (法人): Authority-Issued Registration NFT

**Status: 🟢 Spec drafted.** Conceptual and architecture questions resolved through discussion with the user; see [`discussion-log.md`](discussion-log.md) for the full reasoning and [`docs/decisions/0005-corporate-registration-model.md`](../../decisions/0005-corporate-registration-model.md) for the formal ADR. No contract code written yet.

## Summary

Every juridical-person corporation (法人格を持つ法人: 株式会社, 合同会社, 一般社団法人, etc. — **not** sole proprietors) must register with the authority (or authorities) that have oversight of it. That authority mints a **soulbound, on-chain, authority-updatable** NFT linking the corporation's own address to the registration/supervision relationship. Unlike individual data ([`ResidentLink`](../citizenship/)), corporate information is recorded **on-chain in full** — name, registered address, business purpose, capital, and officer/representative **names** (but never officer addresses) — reflecting that corporations, unlike individuals, are already subject to public disclosure today (Japan's 商業登記簿 is already public record).

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
- The registration NFT itself: corporate name, registered address, business purpose, capital, officer/representative **names** (plain text), and which authority issued it — all mutable by the issuing authority (see [Lifecycle](#lifecycle)).
- The corporation's own transactions (any stablecoin or other on-chain activity via its contract address) — fully public, same as any other address.
- Nothing that identifies an officer's personal address — never recorded, at any point.

**Online:**
- Each authority's officially-attested NFT-issuing contract address, published the same way as the citizenship/taxation designs (see [Official-issuer attestation](#official-issuer-attestation)).

**Offline:**
- The issuing authority verifies an officer's/representative's identity via their `ResidentLink` NFT privately, at registration time — the same in-person verification model as citizenship, just never exposed on-chain.
- Substantive due diligence on whether a registering business is legitimate (beyond identity verification) is the issuing authority's existing process, unchanged by this design.
- Tracing a specific payment to a specific officer's personal benefit requires a legitimate investigative process (e.g., police with investigative authority obtaining the officer's address through proper channels) — not something this design exposes publicly.

## Architecture

### Per-authority registration contracts

Each supervisory authority deploys its own registration-NFT contract, following the same per-authority pattern established for citizenship:

- **Specially-regulated corporations** (financial institutions, medical institutions, etc.) register with their existing real-world regulator (e.g. 金融庁 for banks, 厚生労働省 for medical institutions).
- **All other corporations** register, by default, with **法務省** (実務窓口: 法務局) — under a hypothetical extension of current law giving it this supervisory role, building on its existing ownership of 会社法 and 商業登記. This is the general-purpose equivalent of how municipalities handle citizenship.
- **A corporation may hold multiple NFTs** — one per applicable registration/supervision relationship (e.g. a bank holds both a 法務省/法務局 registration NFT and a 金融庁 license NFT). No on-chain aggregation or master list is needed; a verifier checks whichever specific authority's contract is relevant to what they want to confirm.

### Officer/representative data

- **Names: public, plain text, on-chain.** This matches today's status quo (company websites, business cards, and existing commercial registers already disclose this).
- **Addresses: never recorded on-chain, anywhere, for any officer.** The issuing authority verifies an officer's `ResidentLink` NFT privately/off-chain at registration time, but the public record contains only the name. This is not an oversight — publishing a name *linked to an address* would deanonymize that officer's entire on-chain financial activity (income, tax payments, etc.), which the taxation design's privacy model depends on never happening. No hash of an address either (unsafe one-wayness at this threat model, per the citizenship design's reasoning).

### The corporation's own address

- A corporation's registered address is a **contract address, not an EOA** — reflecting that corporate action is, almost by definition, not something a single individual should execute unilaterally.
- It is governed by a **multisig signed with its officers' own personal keys** (the same keys tied to their `ResidentLink` NFT) — not a separate, dedicated "corporate signing key." A multisig's owner-address list is necessarily public, but since officer *names* are never linked to officer *addresses* anywhere on-chain (see above), this does not deanonymize anyone: an outside observer sees a public list of addresses with no names attached, and a public list of names with no addresses attached, never cross-referenced.
- Which specific audited multisig/smart-contract-wallet implementation to use (e.g. Safe) is **deferred to implementation time** — tracked in [`docs/BACKLOG.md`](../../BACKLOG.md), out of scope for this design.

### Official-issuer attestation

Reuses the mechanism established for citizenship/taxation: each authority publishes its registration-NFT contract address at a well-known URI under its own vetted government domain (`.go.jp` for national bodies, the applicable domain for any other regulator) — no on-chain registry contract.

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

## Effectiveness: what this does and doesn't achieve

This design's goal is **transparency**, not shell-company prevention:

- **What becomes easy:** confirming, for free and instantly, who is publicly named as a company's officer/representative, and observing the company's full on-chain financial activity — exposing mismatches (e.g., a company whose declared business purpose doesn't match its transaction volume/pattern) that today require banking-record access (subpoena power) to even see.
- **What doesn't become automatic:** proving a specific payment reached a specific officer's *personal* benefit. That link (officer name ↔ officer's personal address) is deliberately never public (see above) — establishing it still requires a legitimate investigative process (e.g., police, who already have investigative authority today) obtaining it through proper channels, same as today's investigations into financial crime.
- **The intended effect:** public, pattern-level transparency plus existing investigative authority (and the possibility of public pressure forcing voluntary disclosure) make it harder for suspected misconduct to simply fade from attention unresolved, compared to today, where the underlying financial activity isn't visible to the public at all. A corrupt investigative body remains a residual failure mode this design cannot solve.

## Open items for later

Tracked in [`docs/BACKLOG.md`](../../BACKLOG.md):
- Selecting the specific audited multisig/smart-contract-wallet implementation corporations use.

---

# 法人: 監督官庁発行の登録NFT(日本語)

**ステータス: 🟢 設計確定。** ユーザーとの議論を通じて概念・アーキテクチャ上の論点は解決済み。詳細な議論の経緯は [`discussion-log.md`](discussion-log.md)、正式なADRは [`docs/decisions/0005-corporate-registration-model.md`](../../decisions/0005-corporate-registration-model.md) を参照。コントラクトコードはまだ実装していません。

## 概要

法人格を持つ全ての法人(株式会社、合同会社、一般社団法人等 — 個人事業主は**含まない**)は、自身を監督する主体(複数の場合あり)に登録しなければなりません。その主体が、法人自身のアドレスと登録・監督関係を紐づける、**譲渡不可・オンチェーン・発行主体による更新が可能**なNFTを発行します。個人のデータ([`ResidentLink`](../citizenship/))とは異なり、法人情報は**オンチェーンに全て記載**します — 商号、所在地、事業目的、資本金、役員・代表者の**氏名**(ただしアドレスは一切含まない)です。これは、個人とは異なり法人が既に今日公開情報である(日本の商業登記簿は既に公開記録である)ことを反映しています。

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
- 登録NFT自体: 商号、所在地、事業目的、資本金、役員・代表者の**氏名**(平文)、発行主体 — いずれも発行主体により更新可能([ライフサイクル](#ライフサイクル)参照)。
- 法人自身の取引(コントラクトアドレスを通じたステーブルコイン等のあらゆるオンチェーン活動) — 他のアドレスと同様、完全に公開される。
- 役員個人のアドレスを特定する情報は、いかなる時点でも一切記録しない。

**オンライン:**
- 各主体の、公式に証明されたNFT発行コントラクトアドレス。国民・住民・納税設計と同じ方法で公表([公式発行体の証明](#公式発行体の証明)参照)。

**オフライン:**
- 発行主体は、登記時に役員・代表者の`ResidentLink`をオフチェーンで内々に確認する — citizenshipと同じ対面確認モデルだが、オンチェーンには一切露出しない。
- 登録しようとする事業が正当かどうかの実質的なデューデリジェンス(本人確認以上のもの)は、発行主体の既存のプロセスのままで、この設計では変更しない。
- 特定の支払いが特定の役員個人の利益になったことを追跡するには、正当な捜査プロセス(例: 正規の手続きを経てその役員のアドレスを入手する捜査権を持つ警察)が必要であり、この設計が公に開示するものではない。

## アーキテクチャ

### 主体ごとの登録コントラクト

各監督主体は、国民・住民設計で確立したのと同じ、主体ごとのパターンに従って、自身の登録NFTコントラクトをデプロイします。

- **特殊な規制対象の法人**(金融機関、医療機関等)は、既存の現実の規制当局(銀行なら金融庁、医療機関なら厚生労働省等)に登録します。
- **それ以外の全ての法人**は、デフォルトで**法務省**(実務窓口: 法務局)に登録します — 既に会社法と商業登記を所管していることを基盤に、この監督的役割を与える現行法の仮想的な拡張によるものです。これは国民・住民における市区町村の、一般法人版に相当します。
- **法人は複数のNFTを保有できます** — 適用される登録・監督関係ごとに1つずつです(例: 銀行は法務省/法務局の登記NFTと金融庁の免許NFTの両方を持つ)。オンチェーンでの集約・マスターリストは不要で、確認したい内容に応じて関連する主体のコントラクトを個別に確認します。

### 役員・代表者のデータ

- **氏名: 公開、平文、オンチェーン。** これは今日の状況(会社のホームページ、名刺、既存の商業登記で既に開示されている)と一致します。
- **アドレス: いかなる役員についても、いかなる場所にもオンチェーンには一切記録しません。** 発行主体は登記時に役員の`ResidentLink`をオフチェーンで内々に確認しますが、公開される記録には氏名のみが含まれます。これは見落としではありません — 氏名と**アドレスを紐づけて**公開すると、その役員の全てのオンチェーン金融活動(収入、納税等)が匿名性を失ってしまい、納税設計のプライバシーモデルの前提が崩れてしまいます。アドレスのハッシュも載せません(この脅威モデルでは安全な一方向性を持たないため、国民・住民設計と同じ理由)。

### 法人自身のアドレス

- 法人の登録アドレスは**コントラクトアドレス(EOAではない)**とします — 法人としての行動は、ほぼ定義上、個人が単独で実行すべきものではないことを反映しています。
- これは、**役員本人の個人の鍵**(`ResidentLink`NFTに紐づく鍵と同じもの)で署名するマルチシグによって統治されます — 専用の別の「法人署名鍵」ではありません。マルチシグの所有者アドレス一覧は必然的に公開されますが、役員の氏名がオンチェーンのどこにもアドレスと紐づかないため(上記参照)、誰のことも匿名性を失わせません: 外部の観察者には、氏名の付かないアドレスの一覧と、アドレスの付かない氏名の一覧が見えるだけで、両者は決して突合されません。
- 実際にどの監査済みマルチシグ/スマートコントラクトウォレット実装(Safe等)を使うかは**実装時に決定**します — [`docs/BACKLOG.md`](../../BACKLOG.md)で追跡し、この設計の対象外とします。

### 公式発行体の証明

国民・住民・納税設計で確立した仕組みをそのまま流用します: 各主体が、自身の審査済みの政府ドメイン(国の機関なら`.go.jp`、その他の規制当局なら該当するドメイン)配下のwell-known URIで、登録NFTコントラクトアドレスを公表します。オンチェーンのレジストリコントラクトはありません。

### ライフサイクル

上記の英語版の図を参照してください(内容は同一です)。

- **譲渡不可(Soulbound)**。国民・住民と同様、登録を売買したり別の法人に譲渡したりすることはできません。
- **日常的な変更は、burnして再発行するのではなく更新します。** 国民・住民のほぼ空のトークンとは異なり、法人の記録には実質的なフィールド(商号、所在地、事業目的、代表者、資本金)があり、法人が消滅しなくても正当に変化します(商号変更、本店移転、役員変更、増資等)。発行主体は、発行主体限定の関数で特定のフィールドを更新できます。burnは実際の消滅(解散、免許取消、合併による消滅会社側)のためだけに使い、日常的な更新には使いません。
- **本人によるセルフサービスの更新・バーンはありません** — 発行主体のみが行えます。国民・住民の「登録・失効は発行主体のみ」というルールと同じです。

## 効果: この設計で達成できること・達成できないこと

この設計の目標は**透明性**であり、ペーパーカンパニーの防止ではありません。

- **容易になること:** 誰が会社の役員・代表者として公に名前を連ねているかを無料・即座に確認できること、そして会社の全オンチェーン金融活動を観察できること — 事業目的と実際の取引量・パターンの不一致(今日なら銀行記録へのアクセス権限がなければ見えないもの)が明らかになります。
- **自動的にはならないこと:** 特定の支払いが特定の役員**個人**の利益になったことの証明。この紐付け(役員の氏名↔役員個人のアドレス)は意図的に一切公開されません(上記参照) — これを明らかにするには、正当な捜査プロセス(今日既に捜査権を持つ警察等)が正規の手続きを経てこれを入手する必要があり、今日の金融犯罪捜査と同じです。
- **意図する効果:** パターンレベルでの公的な透明性と、既存の捜査権限(および世論による任意開示の圧力の可能性)が組み合わさることで、今日のように基礎となる金融活動が全く公に見えない状況と比べて、疑惑が有耶無耶のまま終わることを防ぎやすくなります。捜査機関自体の腐敗は、この設計では解決できない、認識した上での残存リスクです。

## 今後の課題

[`docs/BACKLOG.md`](../../BACKLOG.md)で追跡:
- 法人が使用する、具体的な監査済みマルチシグ/スマートコントラクトウォレット実装の選定。

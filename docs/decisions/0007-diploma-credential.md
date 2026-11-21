# 0007. Diploma credential: reuses corporate registration, requires ResidentLink

**Date:** 2026-10-06
**Status:** Accepted

## Context

Following passport (ADR 0006), the second concrete instance of the general "credentials" pattern designed was the diploma/graduation certificate. Discussion (see [`docs/state-design/credentials/diploma/discussion-log.md`](../state-design/credentials/diploma/discussion-log.md)) worked through: whether schools need a new trust-anchor mechanism or can reuse the existing corporations registration, how fine-grained to make contract-per-sub-type, lifecycle (simpler than any prior credential), and — the most substantive point — whether holding a diploma should require the recipient to hold a `ResidentLink` NFT.

The user initially proposed requiring `ResidentLink` to prevent non-Japanese-nationals from "graduating from a Japanese school." This conflated residency with nationality: `ResidentLink` is deliberately nationality-neutral (ADR 0003), so the requirement doesn't actually restrict to nationals — it restricts to registered residents of any nationality. This was surfaced and the user accepted the resulting, more coherent design: require `ResidentLink` (any nationality), with no special handling needed for foreign students as a direct consequence.

## Decision

- **Schools register via the existing [corporations](0005-corporate-registration-model.md) pattern** — 国立大学法人, public schools, and private 学校法人 are simply another category of specially-regulated corporation (supervised by 文部科学省 and/or a prefectural board of education). `Diploma` NFTs are issued from that same registered address; no new `.ac.jp`/`.ed.jp`-based trust mechanism is introduced (though both are real, available Japanese TLDs if ever needed later).
- **Granularity: one contract per faculty/degree-level.** Graduation year is **not** given its own contract — it's recoverable from the mint event's block timestamp, consistent with the data-minimization reasoning already established for citizenship (ADR 0003, Issue 5).
- **Lifecycle is mint-once, no updates, no renewal** — the simplest of any credential designed so far. Burn is authority-only, reserved for rare degree revocation, with no on-chain reason code (same minimization principle as citizenship/corporations). No self-burn.
- **Minting requires the recipient to hold a valid `ResidentLink` NFT**, checked on-chain via a cross-contract call to a `ResidentLink` contract the applicant themselves declares (mirroring citizenship's Issue 6 deduplication-check pattern) — **at mint time only**, not an ongoing requirement; a diploma already issued is unaffected by the holder's `ResidentLink` later being burned.
- **No special-casing for foreign residents.** Since `ResidentLink` makes no nationality distinction, a registered foreign resident qualifies identically to a Japanese national resident. Graduates who were never registered Japan residents (e.g. fully remote overseas distance-learning students) are out of scope for this on-chain credential and continue to rely on a traditional paper diploma.

## Consequences

- This is the second validated instance of the general "credentials" pattern, and the first to depend on another credential (`ResidentLink`) as a mint precondition — establishing a reusable cross-contract-check pattern (declared-contract + `balanceOf`) that later credential types can reuse when they need a similar dependency.
- A visible scope boundary now exists for this credential: Japan-resident graduates (any nationality) are covered on-chain; non-resident graduates are not, and this is a deliberate, documented limitation rather than an oversight.
- The remaining credential types (license, employee ID, health-insurance, vaccination) can now draw on two validated templates: `Passport`'s "pure government-issued document, no dependencies" shape, and `Diploma`'s "issuer reuses corporate registration, requires `ResidentLink`" shape — each new type should state explicitly which shape (or what hybrid) fits it, rather than assuming one by default.

---

# 0007. 卒業証明のクレデンシャル: 法人登録を再利用し、ResidentLinkを要件とする(日本語)

**日付:** 2026-10-06
**ステータス:** Accepted

## 背景

パスポート(ADR 0006)に続き、汎用の「クレデンシャル」パターンの2つ目の具体例として卒業証明書を設計した。議論([`docs/state-design/credentials/diploma/discussion-log.md`](../state-design/credentials/diploma/discussion-log.md)を参照)では次を検討した: 学校に新しい信頼の起点の仕組みが要るか、既存の法人登録を再利用できるか。サブタイプごとのコントラクトをどこまで細かくするか。ライフサイクル(これまでのどのクレデンシャルより単純)。そして最も実質的な論点として、卒業証明の保有に受領者の`ResidentLink` NFTの保有を要件とするか。

ユーザーは当初、日本国籍を持たない人が「日本の学校を卒業する」のを防ぐために`ResidentLink`を要件とすることを提案した。これは居住と国籍を混同していた。`ResidentLink`は意図的に国籍を区別しない(ADR 0003)。そのためこの要件は国民に限定するものではなく、国籍を問わず登録された住民に限定するものである。この点を指摘し、ユーザーはより一貫した設計を受け入れた: `ResidentLink`(国籍を問わない)を要件とし、その直接の結果として留学生に特別な扱いは不要となる。

## 決定

- **学校は既存の[法人](0005-corporate-registration-model.md)のパターンで登録する。** 国立大学法人、公立学校、私立の学校法人は、文部科学省または都道府県の教育委員会が監督する、規制対象の法人の一種にすぎない。`Diploma` NFTは同じ登録アドレスから発行する。`.ac.jp`/`.ed.jp`に基づく新しい信頼の仕組みは導入しない(どちらも実在し利用できる日本のTLDなので、将来必要になれば使える)。
- **粒度: 学部・学位レベルごとに1つのコントラクト。** 卒業年に独自のコントラクトは**与えない**。mintイベントのブロックのタイムスタンプから復元できるからである。市民権で確立したデータ最小化の考え方(ADR 0003、論点5)と一貫する。
- **ライフサイクルは1回のmintだけで、更新も再発行もない。** これまで設計したクレデンシャルで最も単純である。burnは発行者だけが行え、まれな学位取消しのためにとっておく。オンチェーンの理由コードはない(市民権・法人と同じ最小化の原則)。本人によるburnはない。
- **mintには受領者が有効な`ResidentLink` NFTを持つことを要件とする。** 申請者自身が申告した`ResidentLink`コントラクトへのクロスコントラクト呼び出しでオンチェーンで確認する(市民権の論点6の重複確認パターンと同じ)。確認は**mint時だけ**で、継続的な要件ではない。発行済みの卒業証明は、保有者の`ResidentLink`が後でburnされても影響を受けない。
- **外国人住民に特別な扱いはしない。** `ResidentLink`は国籍を区別しないので、登録された外国人住民は日本国籍の住民とまったく同じ条件で資格を持つ。日本の住民として登録されたことのない卒業生(例: 海外から完全に遠隔で学ぶ通信教育の学生)はこのオンチェーンのクレデンシャルの対象外であり、従来の紙の卒業証書を使い続ける。

## 結果

- 汎用の「クレデンシャル」パターンの2つ目の検証済みの例であり、mintの前提条件として別のクレデンシャル(`ResidentLink`)に依存する最初の例である。再利用できるクロスコントラクトの確認パターン(申告されたコントラクト+`balanceOf`)を確立した。同様の依存が必要な後のクレデンシャルはこれを再利用できる。
- このクレデンシャルには目に見えるスコープの境界がある: 日本に住む卒業生(国籍を問わない)はオンチェーンで扱い、日本に住まない卒業生は扱わない。これは見落としではなく、意図して文書化した制限である。
- 残るクレデンシャル(免許、社員証、健康保険、接種証明)は、検証済みの2つのテンプレートを参考にできる: `Passport`の「純粋な政府発行の文書で依存なし」という形と、`Diploma`の「発行者が法人登録を再利用し、`ResidentLink`を要件とする」という形である。新しい種類ごとに、どちらの形(またはどんな混合)が合うかを明示する。どちらか一方を前提にしない。

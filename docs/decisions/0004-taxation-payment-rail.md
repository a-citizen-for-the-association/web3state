# 0004. Taxation payment rail: direct, resident-initiated payments only, no dedicated contract

**Date:** 2026-10-03
**Status:** Accepted. The payment rail is extended by [ADR 0020](0020-certified-address-stablecoin.md) (certified-address stablecoin). Amended by [ADR 0032](0032-consistency-review-decisions.md): tax receiving addresses are `PublicTreasury` contracts, one per body per account (R1.6).

## Context

Following the citizenship/residency design (ADR 0003), the next state function designed was taxation. The initial proposal: residents receive income in a JPY-pegged stablecoin, and pay taxes by sending from their `ResidentLink` address to an appropriate tax-receiving address, with tax calculation and correctness verification explicitly out of scope.

Discussion (see [`docs/state-design/taxation/discussion-log.md`](../state-design/taxation/discussion-log.md)) worked through: whether reusing the identity-linked `ResidentLink` address for payment is an acceptable privacy trade-off, the scope of "tax" (individual vs. corporate, direct-pay vs. source-withheld), how a receiving address's authenticity is established, which stablecoin is assumed, whether a dedicated smart contract is needed, and how the mechanism generalizes beyond municipal taxes to prefectural and national ones.

## Decision

- **Scope:** taxes an individual (natural person) pays directly, by their own initiative — e.g. 住民税, 固定資産税, 自動車税, 所得税 (self-assessed), 相続税, 贈与税. Corporate taxes are out of scope (separate future feature). Tax amount calculation, correctness verification, refunds, and late-payment handling are explicitly out of scope — determined and reconciled off-chain via existing real-world processes, unchanged by this project.
- **Source-withheld taxes (employer withholding) are explicitly not modeled on-chain**, now or later. The project's position is that withholding should eventually be *eliminated* — once financial-product (insurance/loan) tokenization makes deduction data chain-derivable and a legal-reform assumption removes the employer's withholding obligation — rather than replicated as an on-chain "employer remittance" mechanism. Until that precondition is met, withheld income stays entirely outside this project, handled off-chain as today.
- **Payment is made from the same `ResidentLink` address used for residency proof.** This is a deliberate privacy trade-off, not an oversight: the user explicitly accepted that a resident's approximate income/payment history becomes publicly observable on-chain, since it doesn't identify the real person. This also gives a free benefit: the sending address itself serves as the payer's reference (an on-chain equivalent of a real-world 納付書 reference number).
- **Receiving-address authenticity reuses and generalizes the citizenship design's mechanism**: municipalities and prefectures (both 地方公共団体) publish under `.lg.jp`; national bodies (e.g. 国税庁) would publish under `.go.jp`, using the same principle at a different root domain. A single authority handling multiple tax types publishes one receiving address per tax type (extending the same well-known JSON schema), so the destination address itself signals which tax a payment is for.
- **No on-chain allowlist of accepted tokens.** Any address can technically receive any token; whether a received token is a legitimate stablecoin is verified off-chain during the authority's existing reconciliation process, the same way amount-correctness already is.
- **No dedicated smart contract for this feature.** Given the scope above, the entire mechanism reduces to: an authority publishes a verified receiving address, and a taxpayer calls the stablecoin's standard `transfer()`.
- **Stablecoin assumption:** existing, externally-issued JPY-pegged stablecoins (e.g. JPYC, JPYSC) — this project does not issue its own currency, since that would amount to a CBDC, which is explicitly not wanted.
- Current-law feasibility (e.g., whether a private stablecoin legally discharges a tax obligation) is explicitly **not** a design concern for this project — standing guidance (not feature-specific), since the project is a thought experiment with no goal of pursuing real-world legal adoption.

## Consequences

- This feature ships with no new Solidity — only a documented convention (receiving-address publication format) that extends the citizenship design's attestation mechanism.
- A real privacy exposure is accepted: anyone can observe a `ResidentLink`-holding address's approximate income and tax-payment history. This is consistent with the user's explicit risk tolerance for this project, not an oversight to revisit without being asked.
- Financial-product tokenization (insurance, loans) and the resulting ability to eliminate employer withholding are deferred, tracked in [`docs/BACKLOG.md`](../BACKLOG.md) under a "financial infrastructure" theme, to be tackled after the overall state design reaches a stable shape — not as part of this feature.
- A new, not-yet-designed dependency is noted for that future work: private regulated financial institutions (banks, insurers) will need their own official-issuer attestation mechanism, since neither `.lg.jp` nor `.go.jp` applies to them (likely anchored to a regulator such as 金融庁).
- The `.go.jp`-anchored attestation for national tax authorities is a resolved *principle*, not yet an implemented one — tracked in `docs/BACKLOG.md` as an implementation-time task.

---

# 0004. 納税の決済レール: 住民が自ら行う直接の支払いのみ、専用のコントラクトなし(日本語)

**日付:** 2026-10-03
**ステータス:** Accepted。決済レールは[ADR 0020](0020-certified-address-stablecoin.md)(認定アドレスのステーブルコイン)で拡張される。[ADR 0032](0032-consistency-review-decisions.md)で修正: 税の受取アドレスは`PublicTreasury`のコントラクトで、機関ごと勘定ごとに1つ(R1.6)。

## 背景

国民・住民の設計(ADR 0003)に続き、次に設計した国家の機能は税である。当初の提案: 住民は収入を日本円に連動したステーブルコインで受け取り、自分の`ResidentLink`のアドレスから適切な税の受取アドレスに送って納税する。税額の計算と正しさの確認は明示的に対象外とする。

議論([`docs/state-design/taxation/discussion-log.md`](../state-design/taxation/discussion-log.md)を参照)では次を検討した: アイデンティティに結びついた`ResidentLink`のアドレスを支払いに使い回すことが許容できるプライバシーのトレードオフか、「税」の範囲(個人か法人か、直接納付か源泉徴収か)、受取アドレスの真正性をどう確立するか、どのステーブルコインを想定するか、専用のスマートコントラクトが必要か、仕組みを市区町村の税から都道府県や国の税にどう一般化するか。

## 決定

- **範囲:** 個人(自然人)が自ら直接納める税。例: 住民税、固定資産税、自動車税、所得税(申告分)、相続税、贈与税。法人の税は対象外(将来の別の機能)。税額の計算、正しさの確認、還付、延滞の処理は明示的に対象外であり、既存の現実の手続きによりオフチェーンで決定・照合する。このプロジェクトはそれを変えない。
- **源泉徴収される税(雇用主による徴収)は、今も将来もオンチェーンでモデル化しない。** このプロジェクトの立場は、源泉徴収をオンチェーンの「雇用主による納付」の仕組みとして再現するのではなく、いずれ*廃止*すべきだというものである。金融商品(保険、ローン)のトークン化で控除のデータがチェーンから導けるようになり、法改正の仮定で雇用主の源泉徴収義務がなくなったときに廃止する。その前提が満たされるまで、源泉徴収される収入は完全にこのプロジェクトの外にあり、今と同じくオフチェーンで扱う。
- **支払いは、住民であることの証明に使うのと同じ`ResidentLink`のアドレスから行う。** これは見落としではなく、意図的なプライバシーのトレードオフである: ユーザーは、住民のおおよその収入と支払いの履歴がオンチェーンで公開されて見えるようになることを明示的に受け入れた。現実の個人は特定されないからである。これには副次的な利点もある: 送金元のアドレス自体が納税者の照合番号になる(現実の納付書の番号のオンチェーン版)。
- **受取アドレスの真正性は、国民・住民の設計の仕組みを使い回し、一般化する:** 市区町村と都道府県(どちらも地方公共団体)は`.lg.jp`の下で公開する。国の機関(例: 国税庁)は`.go.jp`の下で公開し、同じ原則を別のルートドメインで使う。複数の税目を扱う1つの当局は、税目ごとに1つの受取アドレスを公開する(同じwell-knownのJSONのスキーマを拡張する)。そのため、送り先のアドレス自体が、どの税の支払いかを示す。
- **受け付けるトークンのオンチェーンの許可リストは置かない。** 技術的にはどのアドレスもどのトークンでも受け取れる。受け取ったトークンが正当なステーブルコインかどうかは、金額の正しさと同じく、当局の既存の照合の手続きでオフチェーンで確認する。
- **この機能に専用のスマートコントラクトは置かない。** 上の範囲であれば、仕組み全体は次に帰着する: 当局が確認済みの受取アドレスを公開し、納税者がステーブルコインの標準の`transfer()`を呼ぶ。
- **ステーブルコインの想定:** 外部で発行される既存の日本円連動のステーブルコイン(例: JPYC、JPYSC)。このプロジェクトは独自の通貨を発行しない。それはCBDCに等しく、明示的に望まれていないからである。
- 現行法の下での実現可能性(例: 民間のステーブルコインで法的に納税義務が果たされるか)は、このプロジェクトの設計上の関心事では明示的に**ない**。これは機能ごとではなく常に適用される方針である。このプロジェクトは思考実験であり、現実の法的な採用を目指していないからである。

## 結果

- この機能には新しいSolidityはない。あるのは、国民・住民の設計の証明の仕組みを拡張する、文書化された慣行(受取アドレスの公開の形式)だけである。
- 現実のプライバシーの露出を受け入れる: `ResidentLink`を持つアドレスのおおよその収入と納税の履歴を誰でも見られる。これはこのプロジェクトについてユーザーが明示したリスクの許容度と一致しており、頼まれずに見直すべき見落としではない。
- 金融商品(保険、ローン)のトークン化と、それによる源泉徴収の廃止は先送りし、[`docs/BACKLOG.md`](../BACKLOG.md)の「金融インフラ」のテーマで管理する。この機能の一部としてではなく、国家の設計全体が安定した形になった後で取り組む。
- その将来の作業には、まだ設計していない新しい依存があることを記しておく: 規制された民間の金融機関(銀行、保険会社)には、独自の公式な発行者の証明の仕組みが必要になる。`.lg.jp`も`.go.jp`も当てはまらないからである(金融庁などの規制当局に結びつける可能性が高い)。
- 国の税務当局の`.go.jp`に結びつけた証明は、解決済みの*原則*であって、まだ実装されたものではない。実装時の作業として`docs/BACKLOG.md`で管理する。

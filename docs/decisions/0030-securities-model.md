# 0030. Securities model: shares as tokens at holders' addresses; exchanges off-chain, brokers record the result on-chain; named beneficial owners

**Date:** 2026-11-14
**Status:** Accepted. Extends [ADR 0005](0005-corporate-registration-model.md) (beneficial-owner names), [ADR 0020](0020-certified-address-stablecoin.md) (new certified kind `ForeignInvestor`), [ADR 0028](0028-personal-data-model.md) (new `AnchorRegistry` kinds) and [ADR 0029](0029-real-estate-registry-model.md) (foreign-controlled corporations cannot own land).

## Context

The last item kept by the scope triage ([ADR 0027](0027-remaining-scope-triage.md)). Unlisted companies keep their own, non-public shareholder registers; LLC member interests are recorded nowhere public; the beneficial-owner list is voluntary. Shell companies, borrowed-name shares and layered ownership hide who controls corporations. The backlog asked for "glass-box corporations", VIP shareholdings visible from their address, and a way to stop foreign land ownership through domestic corporations. [ADR 0012](0012-onchain-scope-philosophy.md) excludes infrastructure for high-frequency trading. The user first chose on-chain matching; after front-running on a public chain was explained, the user proposed keeping exchanges off-chain and making securities firms record the result on-chain under severe penalties. See the [log](../state-design/securities/discussion-log.md).

## Decision

- **Shares, LLC member interests, and units of vehicles holding them are tokens** in one `ShareRegistry` run by the Legal Affairs Bureau, held only at certified addresses. **Moving the token is the transfer of the share.** Issuance and cancellation only by the corporation's multisig with an anchored resolution; transfer-restricted shares need the corporation's approval. Bonds and other debt are out of scope.
- **Unlisted shares:** dealings off-chain; the token transfer is the last step.
- **Listed shares:** exchanges match orders off-chain as today. Investors authorise their broker to move their shares and payment. **Holdings move once a day, net,** through the clearing house's registered contract; **each exchange and each broker anchors a daily Merkle root of its executions.** A missing day or a mismatch is a violation, punished up to licence revocation. ADR 0012 is unaffected: the state builds the record, not the market.
- **Trusts, partnerships and funds** hold shares only at registered addresses and record their own participants as units.
- **Beneficial owners** (25% or more of voting rights, traced through all layers) are named in the corporate record, never linked to addresses.
- **Foreign investors** may hold shares through a new certified kind `ForeignInvestor` (Financial Services Agency; no omnibus accounts). A corporation more than 50% foreign-held, traced through all layers, cannot own land.
- **Borrowed-name shares:** off-chain investigation and severe penalties. **Shareholders' meeting voting:** backlog.

## Consequences

- Who controls a corporation can be followed to the final individual's address by any application; the beneficial-owner, glass-box and VIP backlog items close.
- The foreign-land rule of ADR 0029 becomes enforceable.
- Front-running and speed competition are not imported onto the chain; within a day the chain sees nothing and relies on anchors and the regulator.
- Brokers gain authority over clients' listed shares; misuse is visible and punished, not prevented.
- New: `ShareRegistry`, `ClearingContract`, the kind `ForeignInvestor`, `AnchorRegistry` kinds `TradeReport` and `CorporateResolution`, and a beneficial-owner field in corporate records. Daily settlement volume is a constraint on the mainnet chain choice.
- With this ADR, every non-⏸ item in `docs/FEATURES.md` has an initial design; the cross-feature consistency review comes next.

---

# 0030. 有価証券モデル: 株式は保有者のアドレスにあるトークン。取引所はオフチェーン、証券会社が結果をオンチェーンに記録する。実質的支配者の氏名を載せる(日本語)

**日付:** 2026-11-14
**ステータス:** Accepted。[ADR 0005](0005-corporate-registration-model.md)(実質的支配者の氏名)、[ADR 0020](0020-certified-address-stablecoin.md)(新しい認定の種類`ForeignInvestor`)、[ADR 0028](0028-personal-data-model.md)(`AnchorRegistry`の新しい種類)、[ADR 0029](0029-real-estate-registry-model.md)(外国人が支配する法人は土地を所有できない)を拡張する。

## 背景

スコープの振り分け([ADR 0027](0027-remaining-scope-triage.md))で残った最後の項目。非上場会社は非公開の株主名簿を自ら管理し、合同会社の持分は公開の記録にどこにも載らず、実質的支配者リストは任意である。ペーパーカンパニー、名義株、重層的な所有が、誰が法人を支配しているかを隠している。バックログは「ガラス張りの法人」、要人の保有株式がそのアドレスから見えること、国内法人を通じた外国人の土地所有を止める方法を求めていた。[ADR 0012](0012-onchain-scope-philosophy.md)は高頻度取引のための基盤を対象外としている。ユーザーは最初、約定のオンチェーン化を選んだ。公開チェーンでのフロントランニングの説明の後、取引所はオフチェーンのままとし、証券会社に厳罰のもとで結果をオンチェーンに記録させることを提案した。[議論ログ](../state-design/securities/discussion-log.md)を参照。

## 決定

- **株式、合同会社の持分、それらを持つ器の持分はトークン**であり、法務局が運用する1つの`ShareRegistry`にあり、認定アドレスにしか置けない。**トークンの移転が株式の移転である。** 発行と消却は、アンカリングした決議をもとに法人のマルチシグだけが行う。譲渡制限株式は法人の承認が必要。債券は対象外。
- **非上場株式:** 取引はオフチェーンで、トークンの移転が最後の手順。
- **上場株式:** 取引所は今と同じくオフチェーンで約定させる。投資家は株式と代金を動かす権限を証券会社に与える。**保有は1日1回、差し引きで**清算機関の登録されたコントラクトを通じて動く。**各取引所と各証券会社は、約定の毎日のマークルルートをアンカリングする。** 日の欠落や不一致は違反であり、免許取消しまでの罰則の対象となる。ADR 0012には影響しない: 国家が作るのは記録であって市場ではない。
- **信託、組合、ファンド**は登録されたアドレスでのみ株式を持ち、自らの参加者を持分として記録する。
- **実質的支配者**(すべての層をたどって議決権の25%以上)は、法人の記録に氏名を載せる。アドレスとは決して結びつけない。
- **外国人投資家**は新しい認定の種類`ForeignInvestor`(金融庁、オムニバス口座は不可)で株式を持てる。すべての層をたどって外国人が50%超を持つ法人は、土地を所有できない。
- **名義株:** オフチェーンの捜査と重い罰則。**株主総会の議決権行使:** バックログ。

## 結果

- 誰が法人を支配しているかは、どのアプリケーションでも最終的な個人のアドレスまでたどれる。実質的支配者、ガラス張りの法人、要人のバックログ項目が閉じる。
- ADR 0029の外国人と土地のルールが実効性を持つ。
- フロントランニングと速さの競争はチェーンに持ち込まれない。1日の中のことはチェーンには見えず、アンカーと規制当局に頼る。
- 証券会社は顧客の上場株式に対する権限を持つ。不正は見え、罰せられるが、防がれはしない。
- 新規: `ShareRegistry`、`ClearingContract`、種類`ForeignInvestor`、`AnchorRegistry`の種類`TradeReport`と`CorporateResolution`、法人の記録の実質的支配者のフィールド。毎日の決済の量は、メインネットのチェーン選定の制約となる。
- このADRで、`docs/FEATURES.md`の⏸以外のすべての項目に初期設計ができた。次は機能間の整合性レビュー。

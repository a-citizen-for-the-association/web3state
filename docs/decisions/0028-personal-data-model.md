# 0028. Personal data model: a "don't hold it" law; prove instead of collect; anchor access logs

**Date:** 2026-11-07
**Status:** Accepted

## Context

Added by the user in [ADR 0027](0027-remaining-scope-triage.md): incidents involving personal data held by companies are extremely frequent (subcontractor insiders at Benesse in 2014 and the NTT West group in 2023, ransomware in 2024, repeated card skimming, and the 2015 Japan Pension Service leak). Common causes: unnecessary data was kept, many people could access it, and misuse went unnoticed for years. The user's direction: companies basically should not hold personal data; only needed items should be provided as NFTs or contracts, mandated by law. Personal data itself cannot go on a public chain, even encrypted, because a leak there is permanent. See the [log](../state-design/personal-data/discussion-log.md).

## Decision

- **The person holds credentials; companies only read them.** Facts that a credential can prove must be checked at the time of use. Companies keep only the address, the fact checked and the block number. Copies of ID documents are prohibited.
- **Customer identifier = the person's address; login by wallet signature** (EIP-4361). No passwords, and no card numbers (stablecoin payment).
- **New age-threshold credentials** (e.g. 18+, 20+), minted by the municipality without application, possession-only, never burned on a move.
- **Delivery addresses go only to the carrier;** merchants receive them only where unavoidable, and delete them afterwards.
- **Unavoidable data** is purpose-bound and deleted when the purpose ends; retention periods are set by law.
- **A shared, event-only `AnchorRegistry`.** Every company, public body and contractor holding personal data anchors a daily Merkle root of its access log; a missing day is visible on-chain and is itself a violation.

## Consequences

- Most of what leaks today (ID copies, passwords, card numbers, delivery addresses at merchants) is no longer held by companies.
- Long-running insider theft can no longer be hidden by editing logs, though logs can still be incomplete when written.
- Two small contracts are added: age-threshold credentials and `AnchorRegistry`. `AnchorRegistry` can later cover most of the on-hold notarization item.
- Ransomware and legitimate-access insiders remain; the design reduces what they can take.

---

# 0028. 個人情報モデル: 「持たせない」法律。集めずに証明する。アクセスログをアンカリングする(日本語)

**日付:** 2026-11-07
**ステータス:** Accepted

## 背景

[ADR 0027](0027-remaining-scope-triage.md)でユーザーが追加した: 企業が持つ個人情報のインシデントがきわめて多い(2014年のベネッセと2023年のNTT西日本グループでの委託先の内部の人間、2024年のランサムウェア、繰り返されるカード情報の窃取、2015年の日本年金機構の漏洩)。共通する原因は、不要なデータを持っていた、多くの人がアクセスできた、不正が何年も気づかれなかった、である。ユーザーの方向: 基本的に企業には個人情報を持たせず、必要な項目だけをNFTやコントラクトで提供し、法律で義務付ける。個人情報そのものは、暗号化しても公開チェーンに載せられない。そこでの漏洩は永久に残るからである。[議論ログ](../state-design/personal-data/discussion-log.md)を参照。

## 決定

- **クレデンシャルは本人が持ち、企業は読むだけ。** クレデンシャルで証明できる事実は、利用時に確認しなければならない。企業が保持するのは、アドレス、確認した事実、ブロック番号だけ。本人確認書類の写しは禁止。
- **顧客の識別子は本人のアドレス、ログインはウォレットの署名で**(EIP-4361)。パスワードもカード番号もない(ステーブルコインで支払う)。
- **新しい年齢の基準のクレデンシャル**(例: 18歳以上、20歳以上)。市区町村が申請なしにmintし、保有だけを示し、転居してもburnしない。
- **配送先の住所は配送業者にだけ渡す。** 販売者が受け取るのはやむをえない場合だけで、その後は削除する。
- **避けられないデータ**は目的に限定し、目的が終われば削除する。保存期間は法律で定める。
- **イベントだけを出す共有の`AnchorRegistry`。** 個人情報を持つすべての企業、公的機関、委託先は、アクセスログのマークルルートを毎日アンカリングする。欠落した日はオンチェーンでわかり、それ自体が違反となる。

## 結果

- 今日漏れているものの大部分(本人確認書類の写し、パスワード、カード番号、販売者のもとにある配送先の住所)を、企業はもう持たない。
- 長期の内部の持ち出しを、ログの書き換えで隠せなくなる。ただし、書かれた時点でログが不完全な可能性は残る。
- 小さなコントラクトが2つ増える: 年齢の基準のクレデンシャルと`AnchorRegistry`。`AnchorRegistry`は、保留中の公証の項目の大部分を後でまかなえる。
- ランサムウェアと正当なアクセス権を持つ内部の人間は残る。この設計は、彼らが持ち出せるものを減らす。

# 0023. Subsidies model: no new contract; on-chain transactions replace receipts; everything public

**Date:** 2026-10-24
**Status:** Accepted

## Context

Subsidies and grants to local governments were screened with the on-chain value test ([ADR 0014](0014-legislative-process-scope.md)). The real problems are large-scale fraudulent claims (COVID-era benefits and subsidies), fake or inflated receipts, kickbacks from vendors, and duplicate claims across programmes. Payment already goes through the treasury ([ADR 0019](0019-treasury-model.md)); grant decisions can be anchored ([ADR 0017](0017-executive-document-anchoring-v1.md)); and under the certified-address rule ([ADR 0020](0020-certified-address-stablecoin.md)) every JPY payment between recipient and vendor is on-chain. A contract cannot cheaply read past transactions, so on-chain verification of expenses would be heavy. See the [log](../state-design/subsidies/discussion-log.md).

## Decision

- **No new contract** (option A). A grant is an anchored approval document plus treasury payments whose budget code names the programme and the grant.
- **Subsidised expenses must be paid in the JPY stablecoin to certified addresses,** and expense reports list those transactions instead of paper receipts. Cash-paid expenses are not eligible.
- **Expense reports are anchored** by hash in the granting body's `DocumentRegistry`.
- **Everything is public:** grants, recipients (including individuals), amounts, reports.
- **Kickbacks and duplicate claims are detected off-chain;** kickbacks are illegal.
- **Advance-payment surpluses** are returned to the treasury as ordinary transfers.
- **Local governments spending national grants** cite the grant in their budget codes.

## Consequences

- Fake receipts become impossible for subsidised expenses, and kickbacks and duplicates leave visible traces.
- The design adds rules, not code, consistent with the "off-chain if it can be" principle.
- Recipients lose the option of cash-paid subsidised expenses.
- Application fraud and the wisdom of grant uses remain off-chain judgements.

---

# 0023. 補助金モデル: 新しいコントラクトは作らない。オンチェーンの取引が領収書に代わる。すべて公開する(日本語)

**日付:** 2026-10-24
**ステータス:** Accepted

## 背景

補助金と自治体への交付金をオンチェーン価値テスト([ADR 0014](0014-legislative-process-scope.md))で選別した。実際の問題は、大規模な不正受給(コロナ期の給付金や助成金)、偽造・水増しの領収書、業者からのキックバック、制度をまたいだ重複受給である。支払いはすでに国庫([ADR 0019](0019-treasury-model.md))を通り、交付決定はアンカーでき([ADR 0017](0017-executive-document-anchoring-v1.md))、認定アドレス制のルール([ADR 0020](0020-certified-address-stablecoin.md))の下では受給者と業者の間の円の支払いはすべてオンチェーンにある。コントラクトは過去の取引を安価に読めないので、経費のオンチェーンでの検証は重くなる。[ログ](../state-design/subsidies/discussion-log.md)を参照。

## 決定

- **新しいコントラクトは作らない**(選択肢A)。交付は、アンカーされた決裁文書と、予算コードで制度と交付を示す国庫の支払いとする。
- **補助対象の経費は円建てステーブルコインで認定アドレスに支払わなければならず**、実績報告は紙の領収書の代わりにその取引を列挙する。現金で支払った経費は対象外とする。
- **実績報告は**、交付する機関の`DocumentRegistry`にハッシュで**アンカーする**。
- **すべて公開する:** 交付、受給者(個人を含む)、金額、報告。
- **キックバックと重複受給はオフチェーンで検出する。** キックバックは違法である。
- **概算払の余剰**は、通常の送金として国庫に返還する。
- **国の交付金を使う自治体**は、予算コードでその交付金を参照する。

## 結果

- 補助対象の経費について偽造の領収書は不可能になり、キックバックと重複受給は見える痕跡を残す。
- この設計が加えるのはコードではなくルールであり、「オフチェーンでできることはオフチェーンで」の方針と整合する。
- 受給者は、補助対象の経費を現金で支払うという選択肢を失う。
- 申請時の不正と、交付金の使い道が賢明かどうかは、オフチェーンの判断のまま残る。

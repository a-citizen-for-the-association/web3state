# Passport / Nationality Credential (パスポート・国籍クレデンシャル)

**Status: 🟡 Discussing.** First concrete instance of the [credentials](../) pattern. See [`discussion-log.md`](discussion-log.md) for open issues.

## One-line summary

A long-deferred dependency from the citizenship design (ADR 0003, Issue 1): the `ResidentLink` NFT makes no nationality claim, so a separate credential is needed wherever nationality specifically matters (passports, and later, voting eligibility). Following the credentials pattern just established: the NFT proves only possession, no on-chain data beyond that.

## Why this isn't specified yet

See [`discussion-log.md`](discussion-log.md) — open questions include whether "nationality" and "passport" should be one credential or two (they have different lifecycles — nationality is persistent, a passport expires and is renewed), which ministry issues which, whether self-initiated renunciation of nationality (a real right under 国籍法) should be allowed as an exception to the "authority-only" rule established for citizenship, and how passport renewal is represented on-chain given no expiry data is stored.

---

# パスポート・国籍クレデンシャル(日本語)

**ステータス: 🟡 議論中。** [公的証明](../)パターンの最初の具体例。未解決の論点は [`discussion-log.md`](discussion-log.md) を参照。

## 概要

国民・住民設計(ADR 0003、Issue 1)から長らく先送りされていた依存関係です: `ResidentLink`NFTは国籍を一切主張しないため、国籍が具体的に関わる場面(パスポート、将来的には投票資格)には別のクレデンシャルが必要でした。直前に確立した公的証明のパターンに従い、NFTは保持の事実のみを証明し、それ以上のデータはオンチェーンに持ちません。

## まだ仕様化していない理由

[`discussion-log.md`](discussion-log.md) を参照してください。未解決の論点として、「国籍」と「パスポート」を1つのクレデンシャルにするか2つに分けるか(ライフサイクルが異なります — 国籍は永続的、パスポートは有効期限があり更新されます)、どの省庁がどちらを発行するか、国籍離脱(国籍法上、本人の届出による権利)を国民・住民設計で確立した「発行主体のみが失効可能」というルールの例外として認めるか、有効期限データをオンチェーンに持たない場合にパスポートの更新をどう表現するか、といった点があります。

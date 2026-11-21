# 0031. Transfer rule for registered addresses: one address per resident and corporation; a cumulative cap on sending to unregistered addresses; zero for VIPs; check the rest afterwards

**Date:** 2026-11-21
**Status:** Accepted (provisional: to be revisited if the proofs of concept show problems). Supersedes the transfer rule of [ADR 0020](0020-certified-address-stablecoin.md) ("transfers revert unless both sender and recipient are certified").

## Context

ADR 0020 closed the "second, undeclared address" loophole found in VIP asset disclosure by letting the JPY stablecoin move only between certified addresses. During the cross-feature consistency review ([`architecture/consistency-review.md`](../architecture/consistency-review.md)), this rule produced issue after issue: foreigners, nationals abroad, visitors and decertified addresses could not transact at all, and each new kind of party needed its own certification. The user judged that the discussion had gone in the wrong direction and restated the goals:

1. A blockchain is public, so do not add more constraints than needed; what public data can show is checked afterwards, not blocked beforehand.
2. Residents and corporations having several addresses breeds fraud, so registration is one to one.
3. If a politician can send funds to an unregistered address and pay from there, nothing is prevented, so registered addresses must not be able to send there freely.
4. Society must still run as smoothly as it does with cash today.

Point 2 cannot hold without point 3: anyone can create addresses for free, so if registered addresses could send unlimited amounts to unregistered ones, everyone would in effect have several addresses.

## Decision

- **One registered address per resident and per corporation.**
- **Sending from a registered address to an unregistered address is capped by a cumulative amount per sender per period** (e.g. per month; the amount is a legal parameter). Splitting into small payments does not help, because the contract counts the sender's total. This cap is the "cash-like" zone.
- **VIP addresses have a cap of zero:** they cannot send to unregistered addresses at all. VIP addresses carry a flag in `OfficialContractRegistry`.
- **Licensed businesses that do identity checks off-chain** (exchangers, the stablecoin issuer) are exempt from the cap, and must keep records.
- **Public treasuries pay only registered addresses** (consistency review R2.1).
- **Nothing else is blocked:** unregistered → registered and unregistered → unregistered transfers are free; they are public and checked afterwards.

## Consequences

- Most of the review's R1–R3 problems shrink: an address that loses its registration is no longer frozen; it becomes an unregistered address. Small dealings with foreigners, visitors and nationals abroad need no certification; certification matters only above the cap (e.g. pensions, large trade).
- Funds of a dead person can be moved by whoever holds the key, as with cash in a drawer; inheritance law applies off-chain. The heavy successor path remains for key loss, where nobody can move the funds.
- ADR 0020's "every money-holding contract must be registered" now applies to public and official contracts; private contracts may be unregistered, and are then reached only within senders' caps.
- The visitor pass and some certified kinds (`NationalAbroad`, `ForeignParty`) may become unnecessary or narrower; they are re-examined item by item in the review.
- Specs that describe the ADR 0020 rule are updated when the review's decisions are applied.
- This rule is a candidate theme for the proofs of concept.

---

# 0031. 登録済みアドレスの送金ルール: 住民と法人はアドレス1つ。未登録アドレスへの送金は合計額で上限。要人は0。それ以外は後から確認する(日本語)

**日付:** 2026-11-21
**ステータス:** Accepted(暫定: 実証実験で問題が出たら再考する)。[ADR 0020](0020-certified-address-stablecoin.md)の送金ルール(「送り手と受け手の両方が認定されていなければrevertする」)を上書きする。

## 背景

ADR 0020は、要人の資産公開で見つかった「申告していない2つ目のアドレス」の抜け道を、円建てステーブルコインを認定アドレスの間でしか動かせないようにすることで塞いだ。機能間の整合性レビュー([`architecture/consistency-review.md`](../architecture/consistency-review.md))の中で、このルールが次々と論点を生んだ: 外国人、海外の国民、ビジター、認定の外れたアドレスはまったく取引できず、新しい種類の相手が出るたびに専用の認定が必要になった。ユーザーは議論の方向が間違っていたと判断し、目的を次のように言い直した:

1. ブロックチェーンはデータが公開されるので、必要以上に制約をかけない。公開データで確認できるものは、事前に止めず後から確認する。
2. 住民や会社が複数のアドレスを持つと不正の温床になるので、登録は1対1にする。
3. 政治家が登録されていないアドレスに資金を送り、そこから支払えるなら何も防げないので、登録済みのアドレスからそこへ自由に送れないようにする。
4. それでも、今の現金並みに実社会が回るようにする。

2は3がなければ成り立たない: アドレスは誰でも無料で作れるので、登録済みのアドレスから未登録のアドレスへ無制限に送れるなら、誰もが実質的に複数のアドレスを持てる。

## 決定

- **住民と法人は、登録済みのアドレスを1つずつ持つ。**
- **登録済みのアドレスから未登録のアドレスへの送金は、送り手ごと・期間ごとの合計額で上限を設ける**(例: 月ごと。金額は法律で定める値)。コントラクトが送り手の合計を数えるので、小分けにしても意味がない。この上限が「現金のように使える範囲」である。
- **要人のアドレスの上限は0:** 未登録のアドレスには一切送れない。要人のアドレスには`OfficialContractRegistry`で印を付ける。
- **オフチェーンで本人確認を行う免許業者**(両替業者、ステーブルコインの発行者)は上限の対象外とし、記録を残す義務を負う。
- **国庫は登録済みのアドレスにだけ支払う**(整合性レビューR2.1)。
- **それ以外は止めない:** 未登録 → 登録済み、未登録 → 未登録の送金は自由。公開されており、後から確認する。

## 結果

- レビューのR1〜R3の問題の多くが小さくなる: 登録が外れたアドレスは凍結されず、未登録のアドレスになるだけである。外国人、ビジター、海外の国民との小さな取引に認定は要らない。認定が問題になるのは上限を超える場合だけ(例: 年金、大きな取引)。
- 亡くなった人の資金は、鍵を持つ者なら動かせる。引き出しの中の現金と同じで、相続の法律はオフチェーンで適用される。誰も資金を動かせない鍵の紛失のために、重い承継の手続きは残る。
- ADR 0020の「資金を持つコントラクトはすべて登録する」は、公的・公式のコントラクトに適用される。民間のコントラクトは未登録でもよく、その場合は送り手の上限の範囲でしか届かない。
- ビジターパスと一部の認定の種類(`NationalAbroad`、`ForeignParty`)は不要になるか、範囲が狭まるかもしれない。レビューで項目ごとに見直す。
- ADR 0020のルールを書いている仕様は、レビューの決定を反映するときに更新する。
- このルールは実証実験のテーマの候補である。

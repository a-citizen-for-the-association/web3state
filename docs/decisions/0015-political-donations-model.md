# 0015. Political donations model: receiving-side fund contracts, traceable donors without names, on-chain official-contract registry

**Date:** 2026-10-13
**Status:** Accepted. Partially supersedes [ADR 0014](0014-legislative-process-scope.md) (legislators' roll-call records).

## Context

Political donations passed every question of the on-chain value test ([ADR 0014](0014-legislative-process-scope.md)). The motivating fraud was the 2023–24 faction party-ticket slush-fund scandal, and political money is currently reported on paper, late, and by the recipients themselves. ADR 0012 sets the privacy asymmetry: strong privacy for individuals, open information for corporations and VIPs. ADR 0014 had planned to include legislators' roll-call records in this design.

Key forces identified in discussion ([log](../state-design/political-donations/discussion-log.md)):

- A contract cannot stop a cash hand-off, so the lever is making the on-chain address the *only lawful* receiving channel.
- ERC-20 has no receive hook, so direct transfers can always bypass a contract's checks.
- `ResidentLink` is nationality-neutral, and nationality is verified off-chain.
- Earlier designs trusted a *declared* `ResidentLink` contract because a human issuer checked it off-chain. A donation has no human in the loop, so a self-deployed fake identity contract would make a donor untraceable.

## Decision

- **Political organizations are registered on-chain** by the election board with a soulbound, authority-updatable NFT (the ADR 0005 shape). Names are public; personal addresses never appear.
- **The receiving side must use a dedicated fund contract.** Each organization's only lawful receiving address is a `PoliticalFund` deployed from a common factory, and the registration NFT is minted to it. Every inflow (donations, party tickets, membership fees, other) goes through the same `contribute()` entry point. All spending also leaves from that contract.
- **Enforced in the contract:** the donor holds a genuine `ResidentLink` or is a registered corporation; corporations donate to parties only; per-recipient annual caps per category. **Enforced by after-the-fact audit of on-chain data:** total caps across recipients (no shared ledger is needed, because every record is already on-chain), and the foreign-donation ban (no standing nationality credential is created).
- **Direct transfers are neutralized, not prevented:** spending is limited to `accountedBalance`, and unaccounted funds can go **only to the treasury**. A free "refund" path would be a laundering route.
- **No donor names on-chain.** Traceability, not name publication, is the goal: every donor address is a verified identity resolvable through the municipality by legal process, or a corporation with public officers.
- **An on-chain `OfficialContractRegistry`, operated by 総務省, is introduced.** It allowlists genuine `ResidentLink` and corporate-registration contracts for automated contract-to-contract checks, and also holds the accepted stablecoin(s) and legal cap parameters. This revisits ADR 0003's "no on-chain registry in v1": the root of trust stays off-chain (`.lg.jp`/`.go.jp` attestations, which 総務省 mirrors). But an automated consumer now needs the check on-chain, which is exactly the revisit condition recorded in the backlog.
- **The year is derived from `block.timestamp` (UTC+9)** for annual caps. This is the second justified on-chain date exception after the voting period.
- **Partially supersedes ADR 0014:** legislators' roll-call vote records are **not** put on-chain. They are judged fixable off-chain by institutional rule (value-test Q3).

## Consequences

- This is the first design where the *receiving* side is forced through contract logic. Taxation (ADR 0004) deliberately used plain transfers.
- `OfficialContractRegistry` becomes shared infrastructure. Later features needing automated identity checks should reuse it rather than trusting declared contracts. Its controlling key becomes a high-value target, covered by the existing multisig-standard backlog item.
- Some rules are knowingly left to audit (cross-recipient totals, foreign donors, foreign-controlled corporations, spending legitimacy). The design guarantees the *data* for that audit exists and is complete; it does not guarantee prevention.
- Mistaken direct transfers can only be recovered from the treasury off-chain, a small cost accepted to close the laundering path.
- Follow-up: disposition of funds on dissolution (backlog); ownership data for the foreign-controlled-corporation audit (related to the existing beneficial-ownership backlog item).

---

# 0015. 政治献金モデル: 受け取り側の資金コントラクト、氏名なしで追跡可能な献金者、オンチェーンの公式コントラクトレジストリ(日本語)

**日付:** 2026-10-13
**ステータス:** Accepted。[ADR 0014](0014-legislative-process-scope.md)を部分的に上書きする(議員の記名採決記録)。

## 背景

政治献金は、オンチェーン価値テスト([ADR 0014](0014-legislative-process-scope.md))のすべての問いを満たした。きっかけとなった不正は2023〜24年の派閥パーティー券裏金事件であり、現在の政治資金は、紙で、遅れて、受け取る側の自己申告で報告されている。ADR 0012は「個人のプライバシーは強く、法人と要人は公開」という非対称性を定めている。ADR 0014は、議員の記名採決記録をこの設計に含める予定としていた。

議論で明らかになった主な制約([ログ](../state-design/political-donations/discussion-log.md)):

- コントラクトでは現金の手渡しを止められない。そのため、オンチェーンのアドレスを*唯一の適法な*受け取り経路にすることが手段になる。
- ERC-20には受け取り時のフックがないため、直接送金はいつでもコントラクトのチェックを迂回できる。
- `ResidentLink`は国籍中立であり、国籍はオフチェーンで確認する。
- これまでの設計は、人間の発行者がオフチェーンで確認するので、*申告された*`ResidentLink`コントラクトを信頼できた。献金には人間が介在しないので、自分でデプロイした偽の本人確認コントラクトを使えば、献金者を追跡できなくなる。

## 決定

- **政治団体はオンチェーンで登録する。** 選挙管理委員会が、譲渡不可で発行者が更新できるNFT(ADR 0005の形)を発行する。氏名は公開し、個人のアドレスは一切載せない。
- **受け取り側は専用の資金コントラクトを使わなければならない。** 各団体の唯一の適法な受け取りアドレスは、共通のファクトリーからデプロイされた`PoliticalFund`であり、登録NFTはそこに発行する。すべての収入(献金、パーティー券、会費、その他)は同じ`contribute()`の入口を通る。支出もすべてこのコントラクトから行う。
- **コントラクト内で強制するもの:** 献金者が本物の`ResidentLink`を保有している、または登記済み法人であること。法人は政党にのみ献金できること。受取先ごと・区分ごとの年間上限。**オンチェーンデータの事後監査で確認するもの:** 受取先をまたぐ合計上限(すべての記録がすでにオンチェーンにあるため共有台帳は不要)、外国人献金の禁止(継続的な国籍証明は作らない)。
- **直接送金は防ぐのではなく無害化する:** 支出は`accountedBalance`の範囲内に限り、出所不明の資金は**国庫へのみ**送れる。自由な「返金」経路は資金洗浄の手段になるため設けない。
- **献金者の氏名はオンチェーンに載せない。** 目的は氏名の公開ではなく追跡可能性である。献金者のアドレスは必ず、法的手続きで市区町村を通じて特定できる本人確認済みの身元か、役員が公開された法人である。
- **総務省が運用するオンチェーンの`OfficialContractRegistry`を導入する。** コントラクト間の自動検証のため、本物の`ResidentLink`と法人登記コントラクトを許可リストに載せる。受け入れるステーブルコインと法定の上限値も保持する。これはADR 0003の「v1ではオンチェーンレジストリを置かない」を見直すものである。信頼の根は引き続きオフチェーン(`.lg.jp`/`.go.jp`の証明。総務省はそれを写す)にある。ただし自動で検証する利用者がオンチェーンでの確認を必要とするようになり、これはまさにBACKLOGに記録した再検討の条件である。
- **年間上限のため、年は`block.timestamp`(UTC+9)から求める。** 投票期間に続く、2つ目の正当化されたオンチェーン日付の例外である。
- **ADR 0014を部分的に上書きする:** 議員の記名採決記録はオンチェーン化**しない**。制度のルールによりオフチェーンで直せると判断した(価値テストの問3)。

## 結果

- *受け取り側*をコントラクトのロジックに強制的に通す、最初の設計である。納税(ADR 0004)は意図的に通常の送金を使っていた。
- `OfficialContractRegistry`は共有の基盤になる。今後、自動の本人確認を必要とする機能は、申告されたコントラクトを信頼するのではなく、これを再利用すべきである。その管理鍵は価値の高い攻撃対象になる。これはマルチシグ規格に関する既存のBACKLOG項目で扱う。
- 一部のルールは、承知のうえで監査に任せる(受取先をまたぐ合計、外国人献金、外資支配法人、支出の正当性)。この設計が保証するのは、その監査に必要な*データ*が完全な形で存在することであり、不正の防止までは保証しない。
- 誤った直接送金は、オフチェーンで国庫から回収するしかない。資金洗浄の経路を塞ぐために受け入れる小さなコストである。
- 今後の作業: 解散時の資金の扱い(BACKLOG)、外資支配法人の監査のための株主データ(実質的支配者に関する既存のBACKLOG項目と関連)。

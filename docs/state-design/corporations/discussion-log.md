# Discussion Log: Corporations Design

Records the back-and-forth on this feature's design, in order. See [`docs/state-design/citizenship/discussion-log.md`](../citizenship/discussion-log.md) for the format this follows.

---

## Round 1 — 2026-10-03 (Claude)

### User's proposal (as given)

- All corporations register. Specially-regulated ones (medical institutions, financial institutions, etc.) register their address with the relevant supervisory authority, which mints an NFT linking the address.
- Non-specially-regulated corporations register the same way with a supervisory authority.
- Before transacting with a corporation (employment, sales contracts, purchases), an individual checks this NFT to see which authority supervises it.
- Corporate information is recorded **on-chain** (unlike individual data) — corporations should be subject to public right-to-know.
- Goal: reduce shell companies and law-evasion vehicles.

### Issues raised before implementation

**1. Officer/representative privacy tension with the citizenship design.**

Putting corporate information on-chain is well-reasoned on its own — this already mirrors reality: Japan's 商業登記簿 (commercial register) is already public record today, unlike personal residency data. But real commercial registers also list the representative director's and other officers' real *names* — and those officers are themselves individuals, who the citizenship design otherwise protects (personal information kept strictly off-chain, identified only by a `ResidentLink` address, never by name). If a corporation's on-chain record includes an officer's real name, that directly contradicts the privacy model built for individuals. Proposal to consider: corporate records reference officers/representatives by their `ResidentLink` **address**, not by name. Is this an acceptable trade-off, or is there a reason officer names specifically should be on-chain?

**2. Which authority applies to an ordinary (non-specially-regulated) corporation?**

For special corporations there's a natural real-world regulator (banks → 金融庁, hospitals → 厚生労働省, etc.). Proposal: treat 法務局 as the default "supervisory authority" (i.e., NFT issuer) for any corporation not otherwise specially regulated, reusing an existing real institution rather than inventing a new one.

**3. Can/should a corporation hold multiple NFTs from multiple authorities?**

A single corporation can simultaneously be commercially registered *and* specially regulated (e.g. a bank). Proposal: a corporation can hold **multiple NFTs**, one per applicable registration/supervision relationship, mirroring the citizenship/taxation pattern of multiple purpose-specific credentials.

**4. Does a corporation have its own address, separate from any individual's?**

Proposal: by analogy with individuals, a corporation has its **own address** (e.g., controlled by a multisig held by its officers), to which the relevant authority/authorities mint the registration NFT(s).

**5. Corporate data is real, non-trivial, and changes over time — what's the update mechanism?**

Unlike the citizenship design (where the token holds almost no data, and "exists vs. burned" was sufficient), corporate records have substantive fields (name, registered address, business purpose, representative, capital, etc.) that legitimately change (商号変更, 本店移転, officer changes, capital changes) without the company itself ceasing to exist. Burn-and-reissue (citizenship's revocation model) seems like a poor fit for routine updates. Proposal: the issuing authority can **update specific fields** on an existing token via an authority-only function, reserving burn for actual cessation (解散, license revocation, etc.).

**6. Soulbound / non-transferable, same as citizenship?**

Presumably yes — flagging for explicit confirmation rather than assuming.

**7. Scope of "checking the NFT" — mandatory gate, or voluntary due-diligence tool?**

Proposal: this feature provides the *capability* to check (the NFT and its data are readable by anyone), but does not itself enforce the check as a mandatory on-chain gate on any particular transaction type.

**8. Does "法人" here exclude sole proprietors (個人事業主)?**

個人事業主 are not separate legal entities under Japanese law. Confirming this design is only for actual juridical persons, and a sole proprietor would just use their own `ResidentLink` identity.

**9. Honest effectiveness check: does registration + on-chain disclosure, by itself, reduce shell companies?**

Making registration data freely and trivially accessible on-chain is a real, meaningful reduction in due-diligence friction/cost. But the mere *existence* of a registration requirement doesn't, by itself, stop someone from registering a shell company with no real business activity — that would require substantive scrutiny at registration time, a much harder problem this design doesn't solve. Worth confirming whether the goal is "cheaper/easier transparency" (achievable) vs. "preventing shell-company formation outright" (not achievable by registration/disclosure alone).

### Status

Awaiting the user's responses to issues 1–9 before writing the spec.

---

## Round 2 — 2026-10-03 (User + Claude) — Issues 1, 2, 3 resolved

### User (Issue 1)

Officer/representative *names* are fine to publish on-chain — they're already published today (company websites, etc.), so this isn't new exposure. Conversely, those officers' *addresses* must absolutely never be made public, because an address is personal information.

### Claude

Agreed, and noted why this is the right split: publishing a name alone matches today's status quo, but publishing a name *linked to an address* would be a much bigger exposure than today — it would deanonymize that person's entire on-chain activity (income, tax payments, anything else tied to that address), directly undermining the pseudonymity the taxation design relied on ("the individual isn't identified, even though their activity is visible"). Practical implication: the issuing authority verifies an officer's identity via their `ResidentLink` NFT privately/off-chain at registration time (same as a municipality does today), but the public on-chain corporate record contains only the name as plain text — no address field, no hash of an address (a hash isn't safely one-way at this threat model either, consistent with the citizenship design's Round 1 Issue 5 reasoning).

**Follow-up raised:** Issue 4's earlier working assumption ("the corporation's own address is a multisig held by its officers") would reintroduce the same leak, since a standard on-chain multisig publicly lists its signer addresses — if those signers are named officers' personal addresses, the name↔address link reappears through the back door. Proposed (at the time): treat the corporation's own address's internal control/key-management as an off-chain, operational matter. (Superseded in Round 3 below — this concern turned out to be unfounded.)

### Resolution (Issue 1)

**RESOLVED.** Officer/representative names: public, plain text, on-chain. Officer/representative addresses: never recorded on-chain, verified privately off-chain by the issuing authority at registration time. (How the corporation's own address is controlled is addressed in Round 3.)

### User (Issue 2)

Wants to extend current law here rather than reuse an existing body's current function as-is. Asks which ministry (総務省, 経済産業省, or another) has the best affinity to be elevated into a general corporate-supervision role under a hypothetical new law.

### Claude

Recommended **法務省** (with 法務局 as the field-office implementing body), since it already owns 会社法 (the basic law defining what a corporation is, its formation/governance/dissolution) in addition to already running 商業登記 — extending this into a supervisory NFT-issuing role is the most natural, lowest-friction extension of an existing government structure. Contrasted with 経済産業省 (industrial/commercial *policy*, not the basic law of corporate existence) and 総務省 (local administration/telecom/postal — no real nexus to corporate existence, and would overlap with the municipalities already used for citizenship).

### Resolution (Issue 2)

**RESOLVED.** 法務省 (実務窓口: 法務局) is the default supervisory authority (NFT issuer) for any corporation not otherwise specially regulated.

### User (Issue 3)

Confirms: multiple NFTs from multiple authorities is fine; no mechanism-level problem.

### Claude

Agreed — architecturally there's no obstacle: each authority (法務省/法務局 for general registration, plus e.g. 金融庁 for a bank's license) issues from its own independent, soulbound-NFT contract, following the same per-authority pattern established for citizenship. No on-chain aggregation/master-list is needed.

### Resolution (Issue 3)

**RESOLVED.** A corporation may hold multiple NFTs, one per applicable registration/supervision relationship, each from an independent per-authority contract.

### Status

Issues 1, 2, 3 resolved. Awaiting the user's response to Issues 4–9.

---

## Round 3 — 2026-10-03 (User + Claude) — Issue 4 resolved (Claude's privacy concern retracted)

### Claude (initial, Issue 4)

Proposed that the corporation's own address be a contract (not an EOA). Raised a concern: if that contract is a standard multisig whose signers are officers' own personal `ResidentLink` addresses, the publicly-visible signer list would reintroduce the name↔address link Issue 1 just forbade — suggested a separate, dedicated "corporate signing key" per officer instead.

### User

Rejects the dedicated-key idea: the multisig must be signed with each officer's own personal key — using a separate key is strictly forbidden. Points out: unless you're an insider, looking at the multisig's signers/signatures tells you nothing about who they are — anonymity holds, so there's no contradiction. Confirms a corporation's address is a contract. Accepts that the actual audited multisig/wallet implementation used will be a real, audited one eventually, but says selecting it is out of scope for this project's design phase.

### Claude (correction)

Retracted the concern — the user is right. Issue 1 only forbids publishing a *name linked to an address*. A multisig's owner-address list (and even determining which specific address signed a given transaction) is public, but it is just a set of addresses with no names attached anywhere on-chain. Since the corporate record (Issue 1) contains names with no addresses, and the multisig contains addresses with no names, the two are never cross-referenced on-chain — so using an officer's own personal key as a multisig signer does not violate Issue 1. The earlier proposal for a separate dedicated key solved a problem that doesn't actually exist under this constraint, and added unnecessary key-management complexity — correctly rejected.

### Resolution (Issue 4)

**RESOLVED.** A corporation's own address is a contract address (not an EOA), governed by a multisig signed with officers' own personal (`ResidentLink`-linked) keys — no separate dedicated key. The specific audited multisig/smart-contract-wallet implementation to use is deferred to implementation time (tracked in [`docs/BACKLOG.md`](../../BACKLOG.md)), out of scope for this design phase.

### Status

Issues 1, 2, 3, 4 resolved. Awaiting the user's response to Issues 5–9.

---

## Round 4 — 2026-10-03 (User) — Issue 5 resolved

### User

Confirms: authority-updatable fields is fine.

### Resolution (Issue 5)

**RESOLVED.** The issuing authority can update specific fields on an existing corporate NFT (name, address, representative, capital, etc.) via an authority-only function. Burn is reserved for actual cessation (dissolution, license revocation, etc.) — not used for routine updates.

### Status

Issues 1–5 resolved. Awaiting the user's response to Issues 6–9.

---

## Round 5 — 2026-10-03 (User + Claude) — Issue 6 resolved

### Claude

Proposed soulbound (non-transferable), same reasoning as citizenship. Asked whether a merger (合併) — the absorbed company ceasing to exist — is handled the same way as citizenship's "move" case: burn the absorbed company's NFT, no special merger mechanism needed (not an identity transfer, just cessation).

### User

Confirms non-transferable. Adds: the working assumption is that the supervisory authority deploys/mints the registration NFT based on the information submitted at registration — consistent with the already-established model (authority-issued, authority-controlled).

### Resolution (Issue 6)

**RESOLVED.** Soulbound/non-transferable, same as citizenship. A merger is handled as cessation (burn the absorbed company's NFT) — no special transfer mechanism. The issuing authority mints the NFT based on the information submitted at registration.

### Status

Issues 1–6 resolved. Awaiting the user's response to Issues 7–9.

---

## Round 6 — 2026-10-03 (User) — Issue 7 resolved

### User

Confirms.

### Resolution (Issue 7)

**RESOLVED.** This feature provides only the *capability* to check a corporation's NFT(s) — it does not itself mandate an on-chain check as a gate for any transaction type. Whether/where to enforce such a check is left to whatever contract or process handles a given transaction.

### Status

Issues 1–7 resolved. Awaiting the user's response to Issues 8–9.

---

## Round 7 — 2026-10-03 (User) — Issue 8 resolved

### User

Confirms.

### Resolution (Issue 8)

**RESOLVED.** This design covers only actual juridical persons (法人格を持つ法人: 株式会社, 合同会社, 一般社団法人, etc.). Sole proprietors (個人事業主) are excluded — they conduct business under their own `ResidentLink` identity, with no separate corporate NFT.

### Status

Issues 1–8 resolved. Awaiting the user's response to Issue 9.

---

## Round 8 — 2026-10-03 (User + Claude) — Issue 9 resolved, all issues closed

### User

Gives a concrete motivating example: a corrupt politician might register a sloppy shell company to route income and evade their own income tax. Believes this design makes detecting such schemes easier, indirectly reducing shell companies as a harmful tool.

### Claude

Agreed directionally, with a precise boundary: **what becomes visible** is (a) the officer/representative's real name, publicly tied to the company (Issue 1) — much harder to hide behind anonymous nominees than today — and (b) the company's full financial activity, publicly visible on-chain, so a mismatch between declared business purpose and actual transaction volume/pattern is visible to anyone (journalists, watchdogs, political opponents) without needing subpoena power, unlike today. **What stays hidden** is the final link from the company's outgoing payment to the officer's *personal* `ResidentLink` address, since Issue 1 forbids publishing that link — tracing money to personal benefit still requires a legitimate investigative process (e.g. police, who already have investigative authority today) to obtain that link, not something freely visible to the public.

### User (confirms and extends)

Agrees with this framing. Notes under current law, police already have investigative authority — the ultimate resolution path is police investigative power linking personal identity/address using the now-public corporate information. Adds a social dynamic: unlike today, where a suspected politician's dealings can simply fade from public attention unresolved (有耶無耶), public pressure built on top of this transparency can force even voluntary disclosure of the person's address. As long as the police are not themselves corrupt, this combination avoids the scandal-fades-away outcome. Acknowledges the residual failure mode (police corruption) is not something this design can solve.

### Resolution (Issue 9)

**RESOLVED.** This feature's goal is understood as increasing transparency (public officer names + public corporate financial activity), not directly preventing shell-company formation. This transparency creates detectable red flags today's system doesn't surface, and — combined with existing police investigative authority and potential public pressure for voluntary disclosure — makes it harder for illicit income-routing schemes to go unresolved. The final step (linking a specific payment to a named individual's personal benefit) still depends on a legitimate investigative process, not automatic public disclosure; a corrupt investigative body is an acknowledged, out-of-scope residual failure mode.

## Summary: all issues resolved (2026-10-03)

| # | Issue | Resolution |
|---|---|---|
| 1 | Officer/representative privacy | Names: public, plain text, on-chain. Addresses: never on-chain; verified privately off-chain by the issuing authority at registration. |
| 2 | Authority for ordinary corporations | 法務省 (実務窓口: 法務局), under a hypothetical extension of current law, as the default issuer for non-specially-regulated corporations. |
| 3 | Multiple NFTs | A corporation may hold multiple NFTs, one per applicable registration/supervision relationship, each from an independent per-authority contract. |
| 4 | Corporation's own address | A contract address (not EOA), governed by a multisig signed with officers' own personal `ResidentLink`-linked keys — no separate dedicated key. Specific audited implementation deferred (tracked in `docs/BACKLOG.md`). |
| 5 | Data mutability | The issuing authority can update specific fields via an authority-only function; burn reserved for actual cessation (dissolution, license revocation, merger-absorption). |
| 6 | Transferability | Soulbound/non-transferable, same as citizenship. Mergers handled as cessation (burn), not transfer. |
| 7 | Verification scope | Provides only the capability to check; does not itself enforce mandatory on-chain checks for any transaction type. |
| 8 | Sole proprietors | Excluded — only actual juridical persons are covered; sole proprietors use their own `ResidentLink` identity. |
| 9 | Effectiveness / goal | Increases transparency (detectable red flags via public officer names + public corporate financial activity); does not by itself prevent shell-company formation or automatically prove personal benefit — the final link still requires a legitimate investigative process. |

Next: write the formal design spec (replacing this directory's `README.md` stub) and an ADR capturing the conceptual/architecture decisions above.

---

# 議論ログ: 法人の設計(日本語)

形式は [`docs/state-design/citizenship/discussion-log.md`](../citizenship/discussion-log.md) に準じます。

---

## Round 1 — 2026-10-03(Claude)

### ユーザーの提案(原文のまま)

- 全ての法人を登録制にする。特殊な法人(医療機関、金融機関等)は、各監督官庁にアドレスを届け出て、監督官庁がNFTを発行しアドレスと紐付ける。
- 特殊でない法人も同様に監督官庁に届け出る。
- 個人が法人と取引(就職、売買契約、商品購入)する際、このNFTを確認してどの監督官庁が管理しているかを確認する。
- 法人情報は(個人情報とは異なり)**オンチェーン**に記載する — 法人には国民の知る権利が及ぶべきだから。
- 目標: 怪しい法人・法律回避のためのペーパーカンパニーの削減。

### 実装前に提起する論点

**1. 役員・代表者のプライバシーと、国民・住民設計との整合性。**

法人情報をオンチェーンに載せること自体は筋が通っています — 現実にも、日本の商業登記簿は既に公開情報であり、個人の住民登録情報とは性質が異なります。ただし、現実の商業登記簿には代表取締役や役員の**実名**も記載されています。役員もまた個人であり、国民・住民設計では個人情報を厳格にオフチェーンに保ち、`ResidentLink`アドレスでのみ識別する(実名は出さない)という原則を立てています。法人のオンチェーン記録に役員の実名が含まれると、この個人のプライバシーモデルと直接矛盾します。提案: 法人の記録では役員・代表者を実名ではなく`ResidentLink`**アドレス**で参照する。これは許容できるトレードオフでしょうか? それとも役員の実名こそオンチェーンに出すべき理由があるでしょうか?

**2. 特殊でない通常の法人には、どの監督官庁が対応するのか?**

特殊な法人には現実の対応する監督官庁が自然に存在します(銀行→金融庁、医療機関→厚生労働省等)。提案: 特別な規制対象でない全ての法人について、法務局をデフォルトの「監督官庁」(＝NFT発行者)として扱う — 新しい主体を作るのではなく、既存の実在機関を流用します。

**3. 1つの法人が、複数の監督官庁から複数のNFTを受け取ることはあるか?**

1つの法人は、商業登記を持ちながら、同時に特殊な規制対象(例: 銀行)でもありえます。提案: 法人は、適用される登録・監督関係ごとに**複数のNFTを持てる**ようにする — 国民・住民や納税で採用した「目的別の複数クレデンシャル」というパターンをそのまま踏襲します。

**4. 法人自身は、個人とは別の、自分自身のアドレスを持つか?**

提案: 個人と同じ発想で、法人も**自分自身のアドレス**(例: 役員が管理するマルチシグ)を持ち、関連する監督官庁がそのアドレスに登録NFTを発行する。

**5. 法人のデータは実質的で、時間とともに変化します — 更新の仕組みはどうするか?**

国民・住民設計(トークンがほぼ何もデータを持たず、「存在するか、burnされたか」で十分だった)とは異なり、法人の記録には実質的なフィールド(商号、本店所在地、事業目的、代表者、資本金等)があり、それらは法人自体が消滅しなくても正当に変化します(商号変更、本店移転、役員変更、増資等)。burnして再発行する(国民・住民の失効モデル)は、日常的な更新には不向きに思えます。提案: 発行主体(監督官庁)が、既存のトークンの**特定のフィールドを更新**できる関数を持たせ、burnは実際の消滅(解散、免許取消等)のためだけに取っておく。

**6. 国民・住民と同様、譲渡不可(Soulbound)にするか?**

おそらくそうだと思います — 前提とせず、明示的に確認させてください。

**7. 「NFTを確認する」というスコープ — 必須のゲートか、任意のデューデリジェンスの手段か?**

提案: この機能が提供するのは「確認できる能力」であり、特定の取引類型に対してオンチェーンでの確認を必須のゲートとして強制するものではない。

**8. ここでの「法人」は個人事業主を含まない、という理解でよいか?**

個人事業主は日本法上、別の法人格を持たず、本人自身の人格で事業を行います。この設計は法人格を持つ実際の法人のみを対象とし、個人事業主は自身の`ResidentLink`アイデンティティをそのまま事業にも使う、という理解でよいか確認させてください。

**9. 効果についての率直な確認: 登録制+オンチェーン開示だけで、本当にペーパーカンパニーは減るか?**

登録情報をオンチェーンで無料・即座にアクセス可能にすることは、取引相手を調べる手間とコストを大きく下げる、実質的で意味のある改善です。しかし、登録という要件の存在そのものは、実体のない事業を行うペーパーカンパニーの登録自体を防ぐものではありません。目標が「透明性を安く・簡単にすること」(達成可能)なのか、「ペーパーカンパニーの設立そのものを防ぐこと」(登録・開示だけでは達成できない)なのか、確認させてください。

### ステータス

Issue 1〜9についてユーザーの回答待ち。設計書の作成はその後。

---

## Round 2 — 2026-10-03(ユーザー + Claude)— Issue 1, 2, 3 解決

### ユーザー(Issue 1)

役員・代表者の**氏名**は公開して問題ない — 今でもホームページ等で既に公開されており、新たな露出ではない。逆に、その役員の**アドレス**は絶対に公開してはならない。アドレスは個人情報だから。

### Claude

同意。この切り分けが正しい理由: 氏名だけの公開は今の状況と同じだが、氏名と**アドレスが紐づく**公開は今よりはるかに大きな露出になる — その人物の全てのオンチエーン活動(収入、納税、その他そのアドレスに紐づく全て)が実名に直結してしまい、納税設計が前提とした「活動は見えるが個人は特定されない」という匿名性を根底から崩してしまう。実務上の対応: 登記の際、監督官庁は(今の市区町村の窓口と同様に)役員の`ResidentLink`をオフチェーンで内々に確認した上で、公開される法人記録には氏名のテキストのみを記載し、アドレスのフィールドもハッシュも一切載せない。

**追加提起:** Issue 4で出した「法人自身のアドレスは役員が管理するマルチシグにする」という当初の作業前提は、同じ抜け道を生む可能性がある。一般的なオンチェーンのマルチシグは署名者アドレスの一覧を公開するため、その署名者が役員本人のアドレスだと、氏名とアドレスの紐付けが別の形で復活してしまう。提案(当時): 法人自身のアドレスの内部的な管理・鍵管理は、オフチェーンの運用上の問題として扱う。(下のRound 3で上書き — この懸念は根拠がないことが判明。)

### 解決(Issue 1)

**解決。** 役員・代表者の氏名: 公開、平文、オンチェーン。役員・代表者のアドレス: オンチェーンには一切記載せず、登記時に発行主体がオフチェーンで内々に確認する。(法人自身のアドレスの管理方法はRound 3で扱う。)

### ユーザー(Issue 2)

既存の主体の現行機能をそのまま流用するのではなく、現行法を拡張したい。総務省、経済産業省、その他のどの省庁が、一般的な法人を監督する新法の主体として最も親和性が高いか尋ねる。

### Claude

**法務省**(実務窓口: 法務局)を推奨。既に商業登記を運用しているだけでなく、法人とは何か・どう設立/運営/解散されるかを定める基本法である**会社法**を所管しているため。経済産業省(産業・商業の「政策」であり、法人存在そのものの基本法は所管しない)、総務省(地方行政・通信・郵政等で法人の存在にほぼ関与せず、国民・住民で既に使っている市区町村と重複する)と比較。

### 解決(Issue 2)

**解決。** 特別な規制対象でない法人のデフォルトの監督官庁(＝NFT発行主体)は法務省(実務窓口: 法務局)とする。

### ユーザー(Issue 3)

複数の監督官庁から複数のNFTを持つことを確認。仕組み上の問題はないとの認識。

### Claude

同意 — アーキテクチャ上の障害はない。各主体が、国民・住民設計で確立したのと同じ、主体ごとに独立した譲渡不可NFTコントラクトから発行する。オンチェーンでの集約・マスターリストは不要。

### 解決(Issue 3)

**解決。** 法人は、適用される登録・監督関係ごとに、それぞれ独立した主体別コントラクトから複数のNFTを保有できる。

### ステータス

Issue 1, 2, 3解決。Issue 4〜9への回答待ち。

---

## Round 3 — 2026-10-03(ユーザー + Claude)— Issue 4解決(Claudeのプライバシー懸念は撤回)

### Claude(初回提案、Issue 4)

法人自身のアドレスはコントラクト(EOAではない)とすることを提案。懸念を提起: そのコントラクトが標準的なマルチシグで、署名者が役員本人の`ResidentLink`アドレスだと、公開される署名者一覧がIssue 1で禁じたばかりの氏名↔アドレスの紐付けを別の形で復活させてしまう。代わりに、役員ごとの専用の「法人署名鍵」を提案。

### ユーザー

専用鍵案を却下: マルチシグは役員本人の個人の鍵で署名することが前提であり、別の鍵を持つことは厳禁。指摘: 関係者でない限り、マルチシグの署名者・署名を見ても誰なのかは一切分からない — 匿名性は保たれており矛盾しない。法人のアドレスがコントラクトであることは確認。実際に使う監査済みマルチシグ/ウォレット実装は将来的に本物を使うのは当然だが、その選定はこのプロジェクトの設計フェーズの対象外とする。

### Claude(訂正)

懸念を撤回 — ユーザーの指摘が正しい。Issue 1が禁じているのは「氏名とアドレスを紐づけて公開すること」のみ。マルチシグの所有者アドレス一覧(そして、ある取引に誰が署名したかを特定できること)は公開されるが、それは氏名が一切紐づかない、単なるアドレスの集合に過ぎない。法人記録(Issue 1)には氏名のみでアドレスがなく、マルチシグにはアドレスのみで氏名がないため、オンチェーン上でこの2つが突合されることはない。したがって、役員本人の個人鍵をマルチシグの署名鍵として使うことは、Issue 1に違反しない。先の「専用の別鍵」という提案は、この制約の下では実在しない問題を解決しようとしたものであり、不要な鍵管理の複雑さを増やすだけだった — 却下は正しい。

### 解決(Issue 4)

**解決。** 法人自身のアドレスはコントラクトアドレス(EOAではない)とし、役員本人の個人の(`ResidentLink`に紐づく)鍵で署名するマルチシグによって統治する — 専用の別鍵は持たない。実際にどの監査済みマルチシグ/スマートコントラクトウォレット実装を使うかは実装時に決定する(追跡: [`docs/BACKLOG.md`](../../BACKLOG.md))。設計フェーズの対象外。

### ステータス

Issue 1, 2, 3, 4解決。Issue 5〜9への回答待ち。

---

## Round 4 — 2026-10-03(ユーザー)— Issue 5解決

### ユーザー

監督官庁が更新できる仕組みでよいと確認。

### 解決(Issue 5)

**解決。** 発行主体(監督官庁)は、既存の法人NFTの特定のフィールド(商号、所在地、代表者、資本金等)を、発行主体限定の関数で更新できる。burnは実際の消滅(解散、免許取消等)のためだけに取っておき、日常的な更新には使わない。

### ステータス

Issue 1〜5解決。Issue 6〜9への回答待ち。

---

## Round 5 — 2026-10-03(ユーザー + Claude)— Issue 6解決

### Claude

国民・住民と同じ理由で譲渡不可(Soulbound)を提案。合併(吸収される側の法人が消滅するケース)は、国民・住民の「転居」ケースと同様に、消滅する法人のNFTをburnするだけで扱えるか(なりすましではなく単なる消滅なので、特別な合併用の仕組みは不要)確認。

### ユーザー

譲渡不可を確認。追加: 登録された情報をもとに監督官庁がNFTをデプロイ(発行)することを今の作業前提とする — 既に確立しているモデル(発行主体が発行・管理する)と一貫している。

### 解決(Issue 6)

**解決。** 国民・住民と同様に譲渡不可(Soulbound)。合併は消滅(吸収される法人のNFTをburn)として扱い、特別な譲渡の仕組みは設けない。発行主体は、登録時に提出された情報をもとにNFTを発行する。

### ステータス

Issue 1〜6解決。Issue 7〜9への回答待ち。

---

## Round 6 — 2026-10-03(ユーザー)— Issue 7解決

### ユーザー

確認。

### 解決(Issue 7)

**解決。** この機能が提供するのは法人のNFTを確認する「能力」のみであり、特定の取引類型に対してオンチェーンでの確認を必須のゲートとして課すものではない。強制するかどうかは、個々の取引を扱うコントラクト・プロセス側に委ねる。

### ステータス

Issue 1〜7解決。Issue 8〜9への回答待ち。

---

## Round 7 — 2026-10-03(ユーザー)— Issue 8解決

### ユーザー

確認。

### 解決(Issue 8)

**解決。** この設計の対象は法人格を持つ実際の法人(株式会社、合同会社、一般社団法人等)のみ。個人事業主は対象外とし、自身の`ResidentLink`アイデンティティで事業を行う。別の法人用NFTは発行しない。

### ステータス

Issue 1〜8解決。Issue 9への回答待ち。

---

## Round 8 — 2026-10-03(ユーザー + Claude)— Issue 9解決、全論点終了

### ユーザー

具体例を提示: 悪徳政治家が、自身の所得税回避のために杜撰な法人を登録し、所得を迂回して受け取ることを想定。この仕組みであればこうした手口の摘発が容易になり、間接的に悪用されるペーパーカンパニーを削減できるはずだ、という考え。

### Claude

方向性としては同意。ただし正確な境界線を示す必要がある。**見えるようになるもの**: (a) 役員・代表者の実名が法人に公に紐づくこと(Issue 1) — 匿名の名義貸しによる隠蔽が今より格段に難しくなる、(b) 法人の資金の流れ全体がオンチェーンで公開されること — 事業目的と実際の取引量・パターンの不一致が、令状等の権限なしに誰でも(ジャーナリスト、監視団体、政敵等)気づける、という点は今日と比べて大きな改善。**見えないまま残るもの**: 法人からの出金が、役員**個人**の`ResidentLink`アドレスに到達したという最後の紐付けは、Issue 1でその公開を禁じているため、依然として非公開。資金が個人の利益に渡ったことを追跡するには、正当な捜査プロセス(今日既に捜査権を持つ警察等)がその紐付けを入手する必要があり、一般に自由に見えるものではない。

### ユーザー(確認と補足)

この整理に同意。現行法上、警察には既に捜査権があり、最終的な解決経路は、公開された法人情報をもとに警察の捜査権で個人のアイデンティティ・アドレスを紐づけることだと理解。社会的なダイナミクスを追加: 今日は疑惑のある政治家の話が有耶無耶になりがちだが、この透明性の上に世論の圧力が高まれば、本人が(任意にせよ)アドレスを公開せざるを得ない状況を作れる。警察自体が腐敗していない限り、このような「有耶無耶」な状態は回避できると理解。警察の腐敗という残存する失敗モードはこの設計では解決できないことも認識。

### 解決(Issue 9)

**解決。** この機能の目標は、透明性の向上(役員実名の公開＋法人の資金の流れの公開)であり、ペーパーカンパニーの設立そのものを直接防ぐことではない、という理解で確定。この透明性は、今日の仕組みでは見えない「怪しいパターン」を検知可能にし、既存の警察の捜査権や世論による任意開示の圧力と組み合わさることで、不正な資金迂回が有耶無耶のまま終わることを防ぎやすくする。最後の「特定の支払いが特定個人の利益になった」という証明は、依然として正当な捜査プロセスに依存し、自動的に公開されるものではない。捜査機関自体の腐敗は、この設計では解決できない、認識した上での残存リスクとする。

## まとめ: 全論点解決(2026-10-03)

上記の英語版の表を参照してください(内容は同一です)。

次のステップ: このディレクトリの`README.md`のスタブを正式な設計書に置き換え、上記の概念・アーキテクチャ決定を記録したADRを作成する。

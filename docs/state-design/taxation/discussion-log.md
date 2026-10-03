# Discussion Log: Taxation / Payment Design

Records the back-and-forth on this feature's design, in order. See [`docs/state-design/citizenship/discussion-log.md`](../citizenship/discussion-log.md) for the format this follows.

---

## Round 1 — 2026-10-03 (Claude)

### User's proposal (as given)

- Residents receive income in a JPY-pegged stablecoin.
- Tax calculation and proof of amount-correctness are explicitly out of scope for now.
- Payment mechanism: send the owed amount from the resident's `ResidentLink` NFT-holding address to the appropriate tax-receiving address. That alone completes the feature.

### Issues raised before implementation

**1. Reusing the identity-linked `ResidentLink` address for payment is a real privacy trade-off, not a neutral simplification.**

The entire citizenship design (see [ADR 0003](../../decisions/0003-resident-link-identity-model.md)) was built around minimizing what's publicly inferable from an address known to belong to a verified resident. If that same address also receives income and sends tax payments, anyone can read the public `Transfer` events of the stablecoin and see, for a specific address *already known to be a verified resident of City A*: roughly how much they earn, when, and how much tax they paid. This is a materially bigger privacy exposure than anything in the citizenship design itself (which deliberately put almost nothing on-chain). On the other hand, reusing this address also gives a "free" benefit: the sending address itself identifies which resident is paying — a natural equivalent of the reference number on a real-world 納付書 (payment slip), with no extra mechanism needed. There's also an operational risk: if this one key is lost or compromised, both legal identity-proof *and* funds are affected together, rather than independently.

Is this trade-off (reconciliation simplicity + address reuse, vs. privacy exposure + compounded key risk) a deliberate choice, or should payment be decoupled from the specific `ResidentLink` address (e.g., paid from any wallet, with some other reference mechanism identifying the payer)?

**2. Which tax, and which authority receives it?**

Japan has multiple distinct taxes with different taxing authorities: 住民税 (resident tax — municipal), 所得税 (income tax — national, 国税庁), 消費税 (consumption tax — national, transaction-based), among others. The user's framing ("residents... receive income... consider that case") suggests an income-based tax, but doesn't say whether this models 住民税 (in which case the receiving authority is the municipality, and the existing `.lg.jp`-anchored official-address mechanism from the citizenship design applies directly) or 所得税 (a national tax, which would need an equivalent trust-anchor at the national level — e.g. a `.go.jp`-anchored official address for 国税庁 — not yet designed). Which is intended? (Doesn't need to be decided for both right now — just need to know which one this round of design is modeling.)

**3. The receiving address needs the same authenticity-attestation treatment the citizenship design gave municipal NFT contracts.**

Whichever authority receives tax payments, residents need a way to know "this is really City A's (or the national tax agency's) official receiving address" and not a scam address. Proposal: extend the exact same mechanism from [citizenship Issue 2](../citizenship/README.md#proving-an-official-municipality-contract) — publish the receiving address at a well-known URI under the relevant authority's own vetted domain (`.lg.jp` for a municipality; presumably a `.go.jp` equivalent for a national body) — rather than inventing a new trust mechanism for this feature.

**4. Which stablecoin — an existing external one, or one this project would issue itself?**

Assuming an *existing*, externally-issued JPY-pegged stablecoin (e.g., something like JPYC, used purely as a payment rail this project doesn't control or design) keeps this feature's scope to "a payment mechanism" only. If instead this project means to design and issue its *own* state-backed stablecoin/currency, that's a much larger, separate feature (reserve/backing model, minting/redemption policy, regulatory treatment under Japan's Payment Services Act for stablecoin issuers) that shouldn't be folded into "tax payment" — it would need its own state-design discussion. Confirming which is assumed here.

**5. Given the stated scope (no calculation, no correctness proof), there may be no need for a dedicated smart contract at all.**

If the amount is self-determined (by the resident, via the existing real-world tax filing/assessment process — 確定申告, 年末調整, etc. — entirely off-chain, exactly as today) and verification of correctness is explicitly deferred, the entire on-chain mechanism may reduce to: the authority publishes a verified receiving address (issue 3), and the resident calls the stablecoin's standard ERC-20 `transfer()` — no bespoke "Tax" contract needed for v1. Worth confirming explicitly, since it would mean this feature needs no Solidity of its own right now, just a documented convention plus (optionally) reusing the citizenship design's address-attestation mechanism.

**6. Confirming the scope boundary.**

To restate issue 5's premise explicitly: this feature, as proposed, covers *only* the payment rail (moving an already-decided amount from payer to tax authority) — not computing the amount, not proving the amount is correct, not handling refunds/overpayment/installments, and not reconciling a specific payment against a specific tax filing beyond whatever the sending address itself implies (issue 1). Confirming this is the intended scope for this round of design, with the rest explicitly deferred (not forgotten — worth a line in the spec saying so).

### Status

Awaiting the user's responses to issues 1–6 before writing the spec.

---

## Round 2 — 2026-10-03 (User + Claude)

### User (answers)

- **Issue 1 (address reuse): confirmed, deliberately.** Using the `ResidentLink` address for payment is fine. It's acceptable that a specific address's income/payment amounts become publicly visible, because the individual (the real person) is not identified by it.
- **Scope of "tax": broadened.** Cover *every* tax an individual (natural person) is obligated to pay. Corporate taxes are explicitly out of scope — to be designed separately, later.
- **Issue 3 (address authenticity): confirmed.** Reuse the same mechanism as the citizenship design.
- **Issue 4 (stablecoin): confirmed.** Assume existing, externally-issued JPY stablecoins such as JPYC or JPYSC. Explicitly rejects the project issuing its own currency, since that would amount to a CBDC — not wanted here.

### Claude (resolutions + new issues raised by the broadened scope)

**Issues 1, 3, 4: RESOLVED** as stated above.

**Issue 2 (which tax/authority) is superseded, not simply resolved**, by "cover every individual tax" — that single-tax framing no longer fits; see new Issue 7.

Confirming as provisionally resolved (no objection raised, but restating since the user didn't address them explicitly this round):
- **Issue 5 (no dedicated smart contract needed for v1):** carried forward as the working assumption — flagging explicitly below for final sign-off along with the new issues.
- **Issue 6 (scope = payment rail only, no calculation/correctness/refunds):** carried forward as the working assumption, same as issue 5.

**New Issue 7 — the `.lg.jp` mechanism doesn't cover national taxes.**

"Every individual tax" spans different levels of government: 住民税 and 固定資産税 are municipal; 自動車税 is prefectural; 所得税 (self-assessed portion), 相続税, and 贈与税 are national (国税庁). The `.lg.jp`-anchored address-attestation mechanism from the citizenship design already generalizes cleanly to *both* municipalities and prefectures — both are 地方公共団体 and both use `.lg.jp`, so no new design is needed there. But national tax bodies use `.go.jp`, not `.lg.jp` — a parallel mechanism (same principle: a well-known URI under the agency's own vetted `.go.jp` domain) would need to be designed before a national tax can actually be supported. Proposal: design and spec the municipal/prefectural case now (it needs no new mechanism), and treat "a national-level equivalent of the official-address attestation" as a named, deferred follow-up — not solved in this round, but written down so it isn't lost.

**New Issue 8 — source-withheld taxes involve a third actor (the employer), not just resident → tax authority.**

Some individual taxes are paid directly by the individual (固定資産税, 自動車税, 住民税普通徴収, 所得税 paid via 確定申告) — these fit the simple "resident sends from their own address" model directly. Others are withheld at source by an employer (住民税特別徴収, 所得税源泉徴収) — for these, the *employer* remits on the employee's behalf, typically as one aggregate payment covering many employees at once, which is a materially different process (a payroll/withholding-agent flow, not an individual payment) and would need its own design (e.g., how does one aggregate on-chain payment map back to amounts owed by specific individuals?). Proposal: scope this round to *direct, resident-initiated* payments only, and treat employer withholding/remittance as a separate, later sub-feature — confirming this split is acceptable.

**New Issue 9 — should the official announcement also state which specific tokens are accepted?**

Since multiple real JPY stablecoins may coexist (JPYC, JPYSC, others), and a plain receiving address can technically receive any ERC-20 token including fake/scam tokens impersonating a stablecoin, proposal: extend the same well-known JSON (from the citizenship design's `.lg.jp` mechanism) to also list the accepted token contract address(es) for that authority — so a payer/anyone can confirm they're sending a recognized asset, not something worthless. This doesn't require new trust infrastructure, just one more field in the already-planned announcement.

### Status

Issues 1, 3, 4 resolved. Issue 2 superseded by the broadened scope (see Issue 7). Awaiting the user's response to Issues 7, 8, 9, and final confirmation of Issues 5–6 as carried-forward assumptions, before writing the spec.

---

## Round 3 — 2026-10-03 (User + Claude) — **Issue 7 resolved**

### User

Asks to confirm: given blockchain data, can national taxes (所得税, 相続税, 贈与税) also be covered this way? Understanding is that once the payment destination is clear, income tax can be handled too.

### Claude

Confirmed correct. 所得税 (self-assessed portion), 相続税, and 贈与税 are all structurally identical to 固定資産税/自動車税 in the relevant sense: the individual computes their own amount (via the existing real-world filing process, unchanged) and pays it themselves — no employer/withholding actor involved (unlike the source-withheld portion of 所得税/住民税, which is Issue 8). Since amount calculation/correctness is already out of scope, the only remaining requirement is a verified receiving address — and `.go.jp` (Japan's restricted domain for national government bodies, e.g. 国税庁 at nta.go.jp) has the same kind of institutional vetting as `.lg.jp`, so the exact same attestation principle applies, just anchored to a different root domain. No new payment-mechanism design is needed.

**Refinement proposed:** since a single national authority (国税庁) handles multiple distinct tax types, publish a **separate attested receiving address per tax type**, not just one per authority — extending the same well-known JSON (which already will list accepted tokens, per Issue 9) with a tax-type → address mapping. This lets the destination address itself signal "which tax this payment is for," mirroring how the sender address already signals "which resident paid" (Issue 1). No new trust infrastructure — just more entries in the same planned announcement format.

### Resolution

**Issue 7: RESOLVED.** The payment mechanism generalizes uniformly across municipal, prefectural, and national individual-facing taxes; only the attestation domain differs (`.lg.jp` vs `.go.jp`). Each (tax type, authority) pair publishes its own attested receiving address (and accepted tokens) under the authority's vetted government domain.

### Status

Issues 7 resolved (in addition to 1, 3, 4; 2 superseded). Awaiting the user's response to Issues 8 and 9.

---

## Round 4 — 2026-10-03 (User + Claude) — Issue 8 discussion

### User (question, educational)

Asks: given that even today's system relies on individual self-reporting rather than the government checking every bank transaction, wouldn't this scheme's transparency simply make self-reporting of salary income easier — not require full automation? Separately: insurance and loans are planned to be tokenized later (as part of a separate design), with built-in classification — so deductions should become computable from blockchain data once that exists.

### Claude (response)

- **Accepted:** the "a plain transfer carries no semantic tag" concern (raised in Round 4's initial framing, before this exchange) is not a blocker if the model stays self-report-plus-transparency rather than full automation — this matches today's paradigm (self-report, chain as supporting evidence), so no contradiction.
- **Accepted, with a new dependency noted:** tokenizing insurance/loans with built-in classification is a sound path to make deduction data chain-derivable — but it will need its own official-issuer attestation mechanism, since banks/insurers are private regulated entities, not municipalities or national government bodies, so neither `.lg.jp` nor `.go.jp` applies directly (likely a regulator-anchored mechanism, e.g. 金融庁/FSA). Also flagged: insurance/loan holdings can be more sensitive than income alone (e.g., insurance type can hint at health conditions) — worth a privacy review when that feature is designed.
- **Reframed Issue 8's resolution:** rather than treating employer withholding as a separate on-chain flow to design later, treat it as something to be *eliminated* (not replicated on-chain) once (a) deduction data is available via the future insurance/loan tokens and (b) 所得税法 is amended to remove the employer's withholding obligation. Until then, withheld income simply stays outside this project's scope, handled off-chain as today — no "employer remittance" contract needs to be designed, ever, under this framing. Noted a transition-period caveat for the spec: until that reform happens, on-chain-visible salary may be net-of-withholding under current law, not gross.

### User (final direction)

Confirms Issue 8's reframed resolution. Directs that the financial-product tokenization and associated system updates (including abolition of withholding) be treated as part of the social-infrastructure design needed for citizens' daily life, to be tackled *after* the overall shape of the state's design is in place — and asks for a TODO list to be created so this isn't forgotten.

### Resolution

**Issue 8: RESOLVED.** Employer withholding is explicitly *not* replicated on-chain; it is expected to be eliminated once financial-product tokenization (deferred) and a legal-reform assumption are both in place. Until then, it stays out of scope. Created [`docs/BACKLOG.md`](../../BACKLOG.md) as a cross-feature deferred-items list (not specific to this discussion log) to track this and the other items raised along the way (financial-product tokenization, its issuer-attestation dependency, the privacy review it will need, and the withholding abolition itself).

---

## Round 5 — 2026-10-03 (User + Claude) — Issue 9 resolved, Issue 10 withdrawn, discussion closed

### User

Issue 9: no special handling needed — it's fine for an address to be able to receive any token; that's just how addresses work.

### Claude

Agreed: this is sound, because whether a received token is a "real" recognized stablecoin doesn't need on-chain enforcement — it falls out of the same off-chain reconciliation process already established for amount/correctness (Issue 6). **Issue 9: RESOLVED** — no token-allowlist mechanism needed.

Then raised a further point ("Issue 10"): under current law, a privately-issued stablecoin isn't legal tender, so whether sending one actually *legally discharges* a tax debt is a separate, more specific legal question than the general "municipalities have no authority" disclaimer already in the citizenship design.

### User (correction)

Explicitly asked that this kind of issue not be raised again: the project is a thought experiment, not intended for real-world application; the user is already aware current law doesn't support stablecoin tax payment, and has no goal of pursuing legal reform to make it supported.

### Resolution

**Issue 10: WITHDRAWN**, per the user's direction — current-law feasibility is not a discussion point for this project going forward (recorded as standing guidance, not just for this feature). No legal-caveat section will be added to the taxation spec beyond what the project's top-level README and the citizenship design already state once.

## Summary: all issues resolved (2026-10-03)

| # | Issue | Resolution |
|---|---|---|
| 1 | Address reuse (identity ↔ payment) | Deliberately accepted: pay from the `ResidentLink` address; public visibility of amounts is fine since the real person isn't identified. |
| 2 | Which tax/authority | Superseded by Issue 7 (scope broadened to all individual taxes). |
| 3 | Receiving-address authenticity | Reuse the citizenship design's `.lg.jp` mechanism. |
| 4 | Stablecoin | Existing, externally-issued JPY stablecoins (e.g. JPYC, JPYSC) — not a project-issued currency/CBDC. |
| 5 | Need for a dedicated smart contract | None needed for v1 — standard ERC-20 `transfer()` to a published, attested address is sufficient. |
| 6 | Scope boundary | Payment rail only — no calculation, correctness proof, refunds, or reconciliation beyond what the sender/receiver addresses themselves imply. |
| 7 | Generalizing beyond municipalities | `.lg.jp` already covers municipalities and prefectures; national taxes (所得税 self-assessed, 相続税, 贈与税) need an equivalent `.go.jp`-anchored mechanism (same principle, different root domain). Each (tax type, authority) pair gets its own published, attested address. |
| 8 | Source-withheld taxes (employer withholding) | Out of scope now; not to be replicated on-chain — expected to be *eliminated* once financial-product tokenization and legal reform (tracked in `docs/BACKLOG.md`) are both in place. |
| 9 | Accepted-token allowlist | Not needed — any address can receive any token; legitimacy is checked off-chain during reconciliation, same as amount correctness. |
| 10 | Legal feasibility under current law | Withdrawn — not a discussion point for this project (standing instruction, not feature-specific). |

Next: write the formal design spec (replacing this directory's `README.md` stub) and an ADR capturing the conceptual/architecture decisions above.

---

# 議論ログ: 納税の仕組み(日本語)

形式は [`docs/state-design/citizenship/discussion-log.md`](../citizenship/discussion-log.md) に準じます。

---

## Round 1 — 2026-10-03(Claude)

### ユーザーの提案(原文のまま)

- 住民は収入をJPYペッグのステーブルコインで受け取る。
- 税額の計算・正確性の証明は現時点では明示的にスコープ外。
- 支払いの仕組み: 住民の`ResidentLink`NFT保有アドレスから、しかるべき納税用アドレスへ金額を送金する。これだけで機能として完結する。

### 実装前に提起する論点

**1. アイデンティティに紐づく`ResidentLink`アドレスを支払いにも流用することは、単なる簡略化ではなく実質的なプライバシー上のトレードオフです。**

国民・住民の設計全体([ADR 0003](../../decisions/0003-resident-link-identity-model.md)参照)は、「検証済みの住民だと分かっているアドレス」から公に推測できる情報を最小化することを軸に組み立てられています。もし同じアドレスが収入の受け取りと納税の両方に使われると、誰でもステーブルコインの公開された`Transfer`イベントを見るだけで、「A市の検証済み住民だと分かっているこの特定のアドレス」について、おおよその収入額、タイミング、納税額までもが分かってしまいます。これは国民・住民の設計自体(意図的にオンチェーンにほぼ何も載せない設計)よりもはるかに大きなプライバシー上の露出です。一方で、このアドレスを流用することには「ただ乗りできる利点」もあります: 送金元アドレスそのものが「どの住民が支払ったか」を識別する、現実世界の納付書の整理番号に相当するものとして、追加の仕組みなしに機能します。また運用上のリスクもあります: この1つの鍵を紛失・流出した場合、法的なアイデンティティの証明と資金の両方が同時に影響を受け、別々にはなりません。

この「照合のしやすさ・アドレス流用のメリット」と「プライバシー上の露出・鍵紛失時のリスクの複合化」というトレードオフは意図的な選択でしょうか? それとも、支払いを`ResidentLink`の特定アドレスから切り離す(任意のウォレットから支払い、別の方法で支払者を識別する)べきでしょうか?

**2. どの税を、どの主体が受け取るのか?**

日本には異なる徴収主体を持つ複数の税があります: 住民税(市区町村)、所得税(国、国税庁)、消費税(国、取引ベース)など。ユーザーの前提(「住民は収入を...受け取る。その場合を考察する」)は所得ベースの税を示唆していますが、これが住民税(この場合、受取主体は市区町村であり、国民・住民設計で確立した`.lg.jp`に基づく公式アドレスの仕組みがそのまま使えます)なのか、所得税(国税の場合、国レベルの同等の信頼の起点、例えば国税庁の`.go.jp`に基づく公式アドレスが必要ですが、まだ設計していません)なのか、どちらを想定していますか?(両方を今すぐ決める必要はありません。今回の設計がどちらを対象にしているかが分かれば十分です。)

**3. 受取アドレスにも、国民・住民設計と同じ「真正性の証明」が必要です。**

どの主体が納税を受け取るにせよ、住民が「これは本当にA市(または国税庁)の公式な受取アドレスだ」と確認でき、詐欺アドレスでないと分かる仕組みが必要です。提案: [国民・住民のIssue 2](../citizenship/README.md#proving-an-official-municipality-contract)と全く同じ仕組みを流用します — 関連する主体自身の審査済みドメイン(市区町村なら`.lg.jp`、国の機関ならおそらく`.go.jp`相当)配下のwell-known URIで受取アドレスを公表する、という形です。この機能のために新しい信頼の仕組みを作る必要はありません。

**4. どのステーブルコインを想定するか — 既存の外部発行のものか、本プロジェクト自身が発行するものか?**

既存の、外部が発行するJPYペッグのステーブルコイン(例えばJPYCのようなもの。このプロジェクトが管理・設計するものではなく、単なる決済レールとして使う)を前提とすれば、この機能のスコープは「決済手段のみ」に留まります。もし本プロジェクト自身が国家として独自のステーブルコイン/通貨を発行することを想定しているなら、それははるかに大きな、別の機能(準備金/裏付けモデル、発行・償還ポリシー、資金決済法上のステーブルコイン発行者としての規制対応など)であり、「納税」には含めるべきではなく、別途state-designとして議論すべきです。どちらを前提にしているか確認させてください。

**5. 提示されたスコープ(計算なし、正確性の証明なし)を前提にすると、専用のスマートコントラクトは不要かもしれません。**

金額が住民自身の自己判断(既存の現実の確定申告・年末調整等のプロセスに基づく、完全にオフチェーン)で決まり、正確性の検証が明示的に先送りされているなら、オンチェーンの仕組み全体は次の2つだけに縮小できます: (3)の主体が検証済みの受取アドレスを公表すること、そして住民がステーブルコインの標準的なERC-20 `transfer()`を呼ぶこと。v1では専用の「Tax」コントラクトは不要かもしれません。これが意図通りか確認させてください。もしそうなら、この機能は今のところ独自のSolidityを必要とせず、規約の文書化(と、必要なら国民・住民設計のアドレス証明の仕組みの流用)だけで完結します。

**6. スコープの境界を確認させてください。**

論点5の前提を明示的に言い直すと: 今回提案されている機能がカバーするのは「決済レール」(すでに決まった金額を支払者から徴収主体へ移動させること)のみであり、金額の計算、金額の正確性の証明、還付・過不足・分割払いの扱い、送金元アドレスが暗黙に示す以上の「特定の支払いと特定の申告との突合」は含まない、という理解でよいか確認させてください。これらは忘れているのではなく明示的に先送りしている、という一文を設計書に残す想定です。

### ステータス

Issue 1〜6についてユーザーの回答待ち。設計書の作成はその後。

---

## Round 2 — 2026-10-03(ユーザー + Claude)

### ユーザー(回答)

- **Issue 1(アドレス流用): 意図的に確定。** `ResidentLink`アドレスを支払いにも使う。特定アドレスの収入・支払額が公に見えてしまうことは問題ない。個人(実在の人物)が特定されないため。
- **税のスコープ: 拡大。** 個人(自然人)が支払う必要のある税は全て対象にしたい。法人税は明示的にスコープ外 — 別途後で設計する。
- **Issue 3(アドレスの真正性): 確定。** 国民・住民設計と同じ仕組みを流用する。
- **Issue 4(ステーブルコイン): 確定。** JPYCやJPYSCのような、既存の外部発行のJPYステーブルコインを前提とする。本プロジェクト自身が通貨を発行することは明確に拒否 — それはCBDCになってしまうため、避けたい。

### Claude(解決の確認 + スコープ拡大に伴う新たな論点)

**Issue 1, 3, 4: 上記の通り解決。**

**Issue 2(どの税・どの主体か)は、単純に解決したのではなく、置き換わりました。** 「個人の税を全て対象にする」という回答により、単一の税を想定した枠組みは成立しなくなりました。新しいIssue 7を参照してください。

以下は今回明示的に回答されていませんが、作業前提として持ち越しつつ、新しい論点と合わせて最終確認させてください:
- **Issue 5(v1では専用スマートコントラクト不要): 作業前提として持ち越し。** 下記で最終確認します。
- **Issue 6(スコープ＝決済レールのみ。計算・正確性・還付は対象外): 作業前提として持ち越し。** 同上。

**新しいIssue 7 — `.lg.jp`の仕組みは国税をカバーしません。**

「個人が支払う税を全て」というスコープは、異なる行政レベルにまたがります: 住民税・固定資産税は市区町村税、自動車税は都道府県税、所得税(申告分)・相続税・贈与税は国税(国税庁)です。国民・住民設計で確立した`.lg.jp`に基づくアドレス証明の仕組みは、市区町村にも都道府県にも問題なく一般化できます(両方とも「地方公共団体」であり、`.lg.jp`を使用するため)。一方、国の機関は`.lg.jp`ではなく`.go.jp`を使用するため、国税を実際に対応させるには、同じ原理(審査済みの`.go.jp`ドメイン配下のwell-known URIで公表する)に基づく並行した仕組みを別途設計する必要があります。提案: 今回は市区町村税・都道府県税(新しい仕組み不要)の設計を進め、「国レベルの公式アドレス証明の仕組み」は名前を付けた上で先送りする課題として明記する、という進め方でどうでしょうか。

**新しいIssue 8 — 源泉徴収される税は、住民↔徴収主体だけでなく、雇用主という第三者が絡みます。**

個人が直接支払う税(固定資産税、自動車税、住民税の普通徴収、確定申告分の所得税)は、「住民が自分のアドレスから送金する」という単純なモデルにそのまま当てはまります。一方、源泉徴収される税(住民税の特別徴収、所得税の源泉徴収)は、*雇用主* が従業員に代わって、通常は複数の従業員分をまとめて一括で納付するもので、全く異なるプロセス(個人の支払いではなく、給与計算・源泉徴収義務者としてのフロー)であり、別途設計が必要です(例: オンチェーンの1つの一括払いを、どう個々の従業員の納税額に対応づけるか、等)。提案: 今回は「住民が自ら直接支払うもの」のみをスコープとし、雇用主の源泉徴収・納付は別の、後の機能として切り出す、という分割でよいか確認させてください。

**新しいIssue 9 — 公式発表には、受け付けるトークンの種類も明記すべきではないか。**

複数の実在するJPYステーブルコイン(JPYC、JPYSCなど)が併存しうる上、ただのアドレスは技術的にはどんなERC-20トークン(ステーブルコインを騙った偽物も含む)でも受け取れてしまいます。提案: 国民・住民設計の`.lg.jp`の仕組みで公表する同じJSONに、その主体が受け付けるトークンのコントラクトアドレスも追加で記載する、というものです。支払う側・誰でも、「これは認められた本物の資産だ」と確認できるようになります。新しい信頼の仕組みは不要で、既に計画しているJSONにフィールドを1つ追加するだけです。

### ステータス

Issue 1, 3, 4は解決。Issue 2はスコープ拡大により新Issue 7に置き換え。Issue 7, 8, 9への回答と、Issue 5〜6を作業前提として持ち越すことの最終確認を待って、設計書の作成に進みます。

---

## Round 3 — 2026-10-03(ユーザー + Claude)— **Issue 7解決**

### ユーザー

ブロックチェーンのデータによって、国税が対象とする所得税・相続税・贈与税も網羅できると理解しているが、合っているか確認。支払い先さえ明確になれば所得税も対応可能、という理解。

### Claude

その理解で正しいです。所得税(自己申告分)、相続税、贈与税は、固定資産税・自動車税と関連する点において構造的に同一です: 個人が自分で金額を計算し(既存の現実の申告プロセスのまま変更なし)、自分で納付する。雇用主のような源泉徴収の主体は絡みません(所得税・住民税の源泉徴収部分はIssue 8で別扱い)。金額の計算・正確性はすでにスコープ外なので、残る要件は検証済みの受取アドレスだけです。`.go.jp`(国の機関専用の制限付きドメイン、例: 国税庁のnta.go.jp)も`.lg.jp`と同種の制度的な審査を経ているため、全く同じ証明の原理が、ルートとなるドメインが違うだけでそのまま適用できます。支払いの仕組み自体に新たな設計は不要です。

**追加の改良提案:** 国税庁のような単一の国の主体が複数の異なる税目を扱うため、主体ごとに1つのアドレスではなく、**税目ごとに別々の証明済み受取アドレス**を公表することを提案します。これは、すでに計画している(Issue 9の)受け付けトークン一覧と同じJSONに、税目→アドレスのマッピングを追加するだけで実現できます。これにより、受取アドレス自体が「どの税の支払いか」を示すことになり、送金元アドレスが「どの住民が支払ったか」を示す(Issue 1)のと対になります。新しい信頼の仕組みは不要で、計画済みの発表フォーマットにエントリを増やすだけです。

### 解決

**Issue 7: 解決。** 支払いの仕組みは、市区町村税・都道府県税・国税の個人向け税目全てに一様に一般化できます。異なるのは証明に使うドメイン(`.lg.jp`か`.go.jp`か)だけです。各(税目, 主体)のペアごとに、その主体の審査済み政府ドメイン配下で、証明済みの受取アドレス(と受け付けるトークン)を公表します。

### ステータス

Issue 7解決(1, 3, 4に加えて。2はIssue 7に置き換え)。Issue 8, 9への回答待ち。

---

## Round 4 — 2026-10-03(ユーザー + Claude)— Issue 8の議論

### ユーザー(質問、知識習得目的)

今でも国家は銀行の全トランザクションをチェックしているわけではなく個人の申告に頼っているのだから、この仕組みの透明性は単に給与所得の申告をしやすくするだけで、完全自動化を意味するわけではないのでは、という質問。また、保険・ローンは別途トークン化される予定で、必要な分類を持たせる計画なので、それが実現すれば控除もブロックチェーンデータから計算可能になるはず、という補足。

### Claude(回答)

- **受け入れ:** 「単なる送金には意味タグがない」という懸念(この回のやり取りより前に提起したもの)は、目指すモデルが完全自動化ではなく「自己申告+透明性による裏付け」であれば障害にならない。これは今日のパラダイム(自己申告、ブロックチェーンは裏付け資料)と同じであり、矛盾はない。
- **受け入れ、ただし新たな依存関係を記録:** 保険・ローンを分類付きでトークン化する方針は、控除データをオンチェーンから導出可能にする筋の良い道筋である。ただし、銀行・保険会社は市区町村でも国の機関でもない民間の規制対象事業者なので、`.lg.jp`も`.go.jp`もそのままは使えず、独自の公式発行体証明の仕組み(おそらく金融庁のような規制当局を起点とするもの)が必要になる。また、保険・ローンの保有状況は所得そのものよりセンシティブになりうる(保険の種類が持病を示唆する等)ため、その機能を設計する際にプライバシーレビューが必要、と指摘。
- **Issue 8の解決を再構成:** 源泉徴収を別のオンチェーンフローとして後で設計する対象として扱うのではなく、(a)将来の保険・ローントークンによって控除データが入手可能になり、かつ(b)所得税法が改正されて会社の源泉徴収義務がなくなった時点で、**廃止されるべきもの**として扱う。それまでは、源泉徴収される所得は単にこのプロジェクトのスコープ外とし、今まで通りオフチェーンで処理する — この整理のもとでは「雇用主による納付」コントラクトを設計する必要は将来も含めて一切ない。設計書への注記として、その法改正が実現するまでの移行期間中は、オンチェーンで見える給与が(現行法上の源泉徴収後の)手取り額になりうるという移行期の前提を残す。

### ユーザー(最終方針)

Issue 8の再構成された結論を確定。金融商品のトークン化と、それに伴う制度更新(源泉徴収の廃止を含む)は、国家のおおよその設計が固まった後に取り組む「国民生活に必要な社会インフラ設計」の一環として扱うよう指示。忘れないようにTODOリストの作成を依頼。

### 解決

**Issue 8: 解決。** 源泉徴収はオンチェーンで再現するのではなく、金融商品のトークン化(先送り)と法改正という前提が揃った時点で廃止されるべきものとして扱う。それまではスコープ外。この議論ログだけに留めず、横断的な先送り項目リストとして [`docs/BACKLOG.md`](../../BACKLOG.md) を新設し、金融商品トークン化・その発行体証明の依存関係・必要なプライバシーレビュー・源泉徴収廃止そのものを記録した。

---

## Round 5 — 2026-10-03(ユーザー + Claude)— Issue 9解決、Issue 10取り下げ、議論終了

### ユーザー

Issue 9について、特別な対応は不要 — アドレスがどんなトークンでも受け取れること自体は問題ない、という判断。

### Claude

同意。受け取ったトークンが「本物の」認められたステーブルコインかどうかは、オンチェーンで強制する必要はなく、金額の正確性(Issue 6)についてすでに確立したオフチェーンの照合プロセスで自然にカバーされる。**Issue 9: 解決** — トークンの許可リストの仕組みは不要。

続けて、別の論点(「Issue 10」)を提起: 現行法上、民間発行のステーブルコインは法定通貨ではないため、それを送ることが法的に納税義務を消滅させる(弁済になる)かは、citizenship設計で既に明記した一般的な注記(市区町村に権限がない)とは別の、より具体的な法的論点である、と指摘。

### ユーザー(訂正)

このような論点を今後提起しないよう明示的に要請。本プロジェクトは思考実験であり、実社会への適用を意図したものではない。現行法でステーブルコイン納税ができないことは既に認識しており、それを法制度化する目的もない。

### 解決

**Issue 10: 取り下げ。** ユーザーの指示により、現行法上の実現可能性は今後このプロジェクトの議論対象としない(この機能に限らず、恒常的な方針として記録)。納税設計書にも、プロジェクト全体のトップレベルREADMEとcitizenship設計で既に一度述べている内容を超える法的注記は追加しない。

## まとめ: 全論点解決(2026-10-03)

| # | 論点 | 結論 |
|---|---|---|
| 1 | アドレス流用(アイデンティティ↔支払い) | 意図的に受け入れ: `ResidentLink`アドレスから支払う。実在の個人が特定されないため、金額が公に見えても問題ない。 |
| 2 | どの税・どの主体か | スコープ拡大によりIssue 7に置き換え。 |
| 3 | 受取アドレスの真正性 | citizenship設計の`.lg.jp`の仕組みを流用。 |
| 4 | ステーブルコイン | 既存の外部発行のJPYステーブルコイン(JPYC、JPYSC等)。プロジェクト発行の通貨/CBDCではない。 |
| 5 | 専用スマートコントラクトの要否 | v1では不要 — 公表・証明済みのアドレスへの標準的なERC-20 `transfer()`で十分。 |
| 6 | スコープの境界 | 決済レールのみ。計算・正確性の証明・還付・送受信アドレス自体が示す以上の突合は対象外。 |
| 7 | 市区町村を超えた一般化 | `.lg.jp`は市区町村・都道府県を既にカバー。国税(所得税の申告分、相続税、贈与税)には同原理の`.go.jp`版の仕組みが必要(ルートドメインが違うだけ)。(税目, 主体)のペアごとに公表・証明済みアドレスを持つ。 |
| 8 | 源泉徴収される税 | 現時点ではスコープ外。オンチェーンで再現しない — 金融商品トークン化と法改正(`docs/BACKLOG.md`で追跡)が揃った時点で廃止されるべきものとする。 |
| 9 | 受け付けトークンの許可リスト | 不要 — どんなアドレスもどんなトークンも受け取れる。正当性の確認は、金額の正確性と同様にオフチェーンの照合時に行う。 |
| 10 | 現行法上の実現可能性 | 取り下げ。このプロジェクトの議論対象としない(機能固有ではなく恒常的な方針)。 |

次のステップ: このディレクトリの`README.md`のスタブを正式な設計書に置き換え、上記の概念・アーキテクチャ決定を記録したADRを作成する。

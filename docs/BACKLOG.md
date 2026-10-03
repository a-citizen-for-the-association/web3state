# Backlog: Deferred Items

> Living document. When any state-design discussion defers something ("not now, but don't forget this"), it gets recorded here with where it came from — not just left buried in that feature's own discussion log. Check this list before starting a new feature design, and when a listed item's prerequisites are met, move it into an active [`docs/state-design/`](state-design/) discussion.

## How to use this

- **Adding an item:** when a discussion defers something, add a row here (not just in that discussion log) with: what it is, why it was deferred, what it depends on, and a link back to the discussion that raised it.
- **Picking up an item:** before starting a new state-design feature, check whether it's already listed here with context from an earlier discussion.
- **Closing an item:** once a deferred item becomes its own active `docs/state-design/` discussion (or is formally dropped), mark it done here and link to where it now lives — don't delete the row, so the history of "why this was ever a thing" stays visible.

## Items

| Item | Raised in | Why deferred | Depends on |
|---|---|---|---|
| Nationality / passport credential (国籍・パスポートに相当するクレデンシャル) | [citizenship discussion](state-design/citizenship/discussion-log.md), [ADR 0003](decisions/0003-resident-link-identity-model.md) | The base `ResidentLink` NFT deliberately makes no nationality claim (Issue 1); a nationality-specific credential is a separate feature. | Its own design discussion. Note: issuing authority may need to be the 本籍地 municipality, which can differ from the 住所地 municipality that issues `ResidentLink`. |
| **Financial infrastructure theme** (grouping the four items below) — financial-product tokenization enabling automatic deduction computation, and the resulting abolition of employer withholding | [taxation discussion](state-design/taxation/discussion-log.md), Issue 8 | User's explicit direction (2026-10-03): handle this as part of the social-infrastructure design needed for citizens' daily life, *after* the overall shape of the state's design is in place — not now. | Overall state design reaching a stable shape first. |
| ↳ Insurance / loan tokenization, with built-in classification | same | Needed so deduction-relevant data (insurance premiums, mortgage interest, etc.) becomes derivable from on-chain data, rather than requiring a new cross-institution data-sharing system. | Financial infrastructure theme above. |
| ↳ Official-issuer attestation for private regulated financial institutions (banks, insurers) | same (Claude's analysis) | Insurers/banks are neither municipalities nor national government bodies, so neither the `.lg.jp` nor `.go.jp` attestation pattern applies directly. Likely needs its own trust-anchor, probably rooted in their regulator (金融庁/FSA). | Insurance/loan tokenization above. |
| ↳ Privacy review for insurance/loan tokens | same (Claude's analysis) | Holdings like insurance type or loan status can be more sensitive than income alone (e.g., insurance type can hint at a health condition; dependent-related data reveals family structure). Needs the same data-minimization scrutiny the citizenship design went through. | Insurance/loan tokenization above. |
| ↳ Abolition of employer withholding (源泉徴収の廃止) | same | Reframed (2026-10-03): not to be replicated on-chain as a separate "employer remittance" feature — the goal is to eliminate it once deduction data is on-chain (above) *and* 所得税法 is amended to remove the employer's withholding obligation. Until then, withheld income stays outside this project's scope (handled off-chain, as today). | Insurance/loan tokenization above, plus a legal-reform assumption (consistent with this project's "thought experiment" framing). |
| Implement the `.go.jp`-anchored official-address mechanism for 国税庁 specifically | [taxation discussion](state-design/taxation/discussion-log.md), Issue 7 | The *principle* is resolved (same pattern as `.lg.jp`, different root domain) — this item is just "actually do it" at implementation time, not an open design question. | Taxation spec finalization + implementation phase. |
| On-chain municipality registry contract | [citizenship discussion](state-design/citizenship/discussion-log.md), Issue 2, [ADR 0003](decisions/0003-resident-link-identity-model.md) | Explicitly decided *against* for v1 (YAGNI) — authenticity is rooted off-chain (`.lg.jp`) regardless, so an on-chain registry would add convenience, not trust. | Only revisit if a concrete on-chain consumer needs automated contract-to-contract verification. |
| Select the audited multisig/smart-contract-wallet standard corporations use as their on-chain address | [corporations discussion](state-design/corporations/discussion-log.md), Issue 4 | Corporations are required to use a contract address (not an EOA), governed by a multisig signed with officers' own personal keys — but picking/specifying the actual audited implementation (e.g. Safe) is out of scope for the design phase. | Implementation phase, once `contracts/` work begins. |
| Beneficial-ownership transparency through layered corporate structures | [corporations discussion](state-design/corporations/discussion-log.md), [ADR 0005](decisions/0005-corporate-registration-model.md) | The corporations design only names the direct officer/representative of a given corporation — it doesn't address a corporation owned by another corporation owned by another, which can still obscure the ultimate human beneficiary. Not raised as an issue by the user; noted as a known limitation in ADR 0005. | A future feature, if the user wants to pierce multi-layer ownership structures. |

---

# バックログ: 先送りした論点(日本語)

> 生きたドキュメントです。どこかの国家機能の議論で「今はやらないが、忘れてはいけない」という話が出たら、その機能自身の議論ログに埋もれさせず、ここにも記録します。新しい機能の設計を始める前にこのリストを確認し、挙げられている項目の前提条件が揃ったら、[`docs/state-design/`](state-design/) の実際の議論に格上げしてください。

## 使い方

- **追加するとき**: 何かを先送りしたら、その議論ログだけでなくここにも1行追加する。内容・先送りした理由・前提条件・元になった議論へのリンクを記載する。
- **着手するとき**: 新しい国家機能の設計を始める前に、ここに既に関連する記載がないか確認する。
- **完了するとき**: 先送りしていた項目が実際の`docs/state-design/`の議論になった(または正式に取りやめになった)ら、ここでは完了にし、今どこにあるかをリンクする。行自体は削除せず、「なぜこれが課題だったのか」という経緯を残す。

## 項目一覧

上記の英語版の表を参照してください(内容は同一です)。

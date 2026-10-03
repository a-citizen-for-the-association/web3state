# Discussion Log: Passport / Nationality Credential

Records the back-and-forth on this specific credential, in order. See [`docs/state-design/citizenship/discussion-log.md`](../../citizenship/discussion-log.md) for the format this follows. This is a sub-discussion of [`docs/state-design/credentials/discussion-log.md`](../discussion-log.md).

---

## Round 1 — 2026-10-03 (Claude)

### Issues raised before implementation

**1. "Nationality" and "passport" likely need to be two separate credentials, not one — their lifecycles differ fundamentally.**

Nationality is a persistent status (like `ResidentLink`'s residency) — it doesn't expire, and in the real world is proven via 戸籍 (koseki), administered under 法務省's oversight (国籍法, 戸籍法). A passport is a renewable *travel document* with a fixed validity period (5 or 10 years in reality), issued by 外務省 (via prefectural offices operationally, modeled here as one national authority), and *requires* nationality as a precondition but is not the same thing — a person's nationality doesn't change when their passport simply expires. If a later feature (e.g. voting eligibility) needs to check nationality, gating it on "holds a currently-valid passport" would incorrectly make someone temporarily ineligible just because they haven't renewed a travel document they may not otherwise need. Proposal: design two credentials — a base **Nationality** credential (persistent, `法務省`-issued) and a **Passport** credential (renewable, `外務省`-issued, requires holding a valid Nationality credential to obtain). Confirm this split, or state a preference for one combined credential.

**2. Self-initiated renunciation (国籍離脱) is a real exception to citizenship's "authority-only, no self-burn" rule.**

Under 国籍法 (Article 13), a Japanese national has an affirmative right to renounce nationality by their own notification (届出) — unlike losing residency (an administrative process following a house move), this is something the individual can initiate themselves, by right. Citizenship's `ResidentLink` design deliberately forbade self-burn to avoid confusion (per the user's own instruction in that discussion). Proposal: for the **Nationality** credential specifically, allow a **self-initiated burn**, since it mirrors a real, individually-exercised legal right rather than something that should require an administrative actor's initiative — a deliberate, justified exception to the citizenship precedent, not an inconsistency. Confirm, or state that authority confirmation should still be required even for self-initiated renunciation (e.g., a two-step process: holder requests, authority confirms the legal requirements are met, then burns).

**3. Trust-anchor for both: reuses the existing `.go.jp` mechanism, no new design needed.**

Both 法務省 and 外務省 are national government bodies — the taxation design's `.go.jp`-anchored attestation (same principle as `.lg.jp`, different root domain) applies directly to both. Noting this as already-solved, not an open question.

**4. Passport renewal, given no on-chain data at all (per the credentials-wide Issue 2 resolution): represented as burn-and-reissue, not an expiry field.**

Since the NFT carries no fields, there's no on-chain "valid until" date. Proposal: a passport renewal is modeled as the issuing authority burning the expiring/old NFT and minting a fresh one — mirroring citizenship's re-issuance pattern for a lost key or address change. This means "holds a Passport NFT" means "has a currently administratively-valid passport, as of the authority's last mint/burn action" — not a claim this project tracks continuously by date. Confirm this is acceptable, given it means the NFT's "currently valid" meaning depends on the authority's timely burn/reissue action at each renewal, not an automatically-expiring on-chain fact.

**5. Should Passport issuance require an on-chain check of the Nationality credential, or just an off-chain one (as today, via koseki documents)?**

Given issue 1's split, minting a Passport NFT could either (a) require an on-chain check that the applicant's address already holds a valid Nationality NFT (reusing the `everIssued`/`balanceOf`-style cross-contract check pattern from citizenship/taxation), or (b) simply trust 外務省's existing off-chain verification process (checking 戸籍 documents), with no on-chain dependency between the two contracts. Either is internally consistent with prior designs (taxation's deduplication check used (a)'s pattern; citizenship's own mint process uses (b)'s pattern for identity verification generally). Confirm a preference, or state it doesn't matter and either is fine to decide at implementation time.

### Status

Awaiting the user's responses to issues 1–5 before writing the spec.

---

# 議論ログ: パスポート・国籍クレデンシャル(日本語)

形式は [`docs/state-design/citizenship/discussion-log.md`](../../citizenship/discussion-log.md) に準じます。これは [`docs/state-design/credentials/discussion-log.md`](../discussion-log.md) のサブ議論です。

---

## Round 1 — 2026-10-03(Claude)

### 実装前に提起する論点

**1. 「国籍」と「パスポート」は、1つではなく2つの別のクレデンシャルにすべきと考えます — ライフサイクルが根本的に異なるためです。**

国籍は永続的な地位です(`ResidentLink`の住民資格と同様)。有効期限はなく、現実には戸籍によって証明され、法務省の所管(国籍法、戸籍法)です。パスポートは有効期間が決まっている(現実には5年または10年)更新可能な**渡航文書**で、外務省が発行し(実務上は都道府県の窓口ですが、ここでは1つの国の主体としてモデル化します)、国籍を前提条件としますが国籍そのものとは別物です — パスポートが単に期限切れになったからといって、国籍が変わるわけではありません。将来の機能(例えば投票資格)が国籍を確認する必要がある場合、「現在有効なパスポートを持っているか」を条件にしてしまうと、渡航の予定がなく更新していないだけの人が、一時的に投票資格を失うという誤った結果になります。提案: 2つのクレデンシャルを設計する — 永続的な**国籍**クレデンシャル(法務省発行)と、更新可能な**パスポート**クレデンシャル(外務省発行、取得には有効な国籍クレデンシャルの保有が必要)です。この分割でよいか、あるいは1つに統合することを希望するか確認させてください。

**2. 国籍離脱の自主的な届出は、国民・住民設計の「発行主体のみ、自主バーンなし」というルールの正当な例外になります。**

国籍法13条により、日本国民は自らの届出によって国籍を離脱する積極的な権利を持っています — これは転居(自治体側の行政手続き)によって住民資格を失うのとは異なり、本人が自らの権利として開始できるものです。国民・住民設計の`ResidentLink`は(そのときのユーザーご自身の指示により)混乱を避けるため自主バーンを明確に禁止しました。提案: **国籍**クレデンシャルに限り、**本人による自主バーンを認める**ことを提案します。これは行政側の発意を必要とするものではなく、個人が行使する実在の法的権利を反映しているためです — これはcitizenshipの前例との矛盾ではなく、正当な例外です。この方針でよいか、あるいは自主的な離脱であっても発行主体の確認を必要とすべきか(例: 本人が申請し、発行主体が法的要件を確認した上でburnする、という2段階のプロセス)教えてください。

**3. 両方の信頼の起点は、既存の`.go.jp`の仕組みをそのまま流用でき、新しい設計は不要です。**

法務省も外務省も国の機関であり、納税設計で確立した`.go.jp`に基づく証明(`.lg.jp`と同じ原理で、ルートドメインが異なるだけ)がそのまま両方に適用できます。これは既に解決済みの事項として記録するだけで、新たな論点ではありません。

**4. パスポートの更新は、公的証明全体のIssue 2での決定(オンチエーンデータを一切持たない)を踏まえ、有効期限フィールドではなく、burnして再発行する形で表現します。**

NFTが何のフィールドも持たない以上、オンチェーンに「有効期限」を持たせることはできません。提案: パスポートの更新は、発行主体が期限切れ(または更新前)のNFTをburnし、新しいNFTをmintする、という形でモデル化します — citizenship設計の、秘密鍵紛失や転居時の再発行パターンと同じです。これは「パスポートNFTを保持している」ことが「発行主体が最後にmint/burnを行った時点で、行政上有効なパスポートを持っている」ことを意味し、日付に基づいて継続的に追跡される主張ではない、ということになります。これにより、NFTの「現在有効」という意味が、オンチエーンで自動的に期限切れになる事実ではなく、各更新のたびに発行主体が適時にburn/再発行を行うことに依存する、という点を踏まえた上でよいか確認させてください。

**5. パスポートの発行は、国籍クレデンシャルをオンチェーンで確認すべきか、それともオフチェーンの確認(今日と同じ戸籍書類による)のみでよいか?**

論点1の分割を前提にすると、パスポートNFTの発行は、(a)申請者のアドレスが既に有効な国籍NFTを保有していることをオンチェーンで確認する(国民・住民・納税のeverIssued/balanceOfパターンを再利用)か、(b)外務省の既存のオフチェーン確認プロセス(戸籍書類の確認)をそのまま信頼し、2つのコントラクト間にオンチェーンの依存関係を持たせないか、のどちらかになります。どちらも過去の設計と内部的に矛盾しません(納税の重複防止チェックは(a)のパターン、国民・住民自体のmintプロセスの本人確認は一般的に(b)のパターンを使っています)。どちらがお好みか、あるいはどちらでもよく実装時に決めればよいか教えてください。

### ステータス

Issue 1〜5についてユーザーの回答待ち。設計書の作成はその後。
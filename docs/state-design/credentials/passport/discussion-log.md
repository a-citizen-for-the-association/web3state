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

---

## Round 2 — 2026-10-06 (User + Claude) — All issues resolved via scope correction

### User

Confirms wanting to split nationality and passport, and mentions wanting nationality handling to also cover "the residential card we first considered." Claude initially misread this as a request to design a new, parallel on-chain credential for foreign residents' residence status (在留カード) alongside nationality — asked for confirmation.

### User (clarification)

Corrects the misunderstanding: what was designed first was `ResidentLink` (citizenship), which defines residents generically. The national/foreign-resident distinction is understood to already exist in the *existing off-chain administrative data* municipalities manage (analogous to 住基ネット) — the same off-chain information a municipality already has access to when verifying identity before minting `ResidentLink`. The user wants to rely on that existing off-chain management rather than building a new on-chain credential for it. **Intent: passport should be designed purely as a travel document, nothing more.**

### Claude

Acknowledged the correction and re-derived the consequences for each original issue:

- **Issue 1 (split nationality/passport):** revised — no separate on-chain "Nationality" credential is built at all. Only **Passport** is designed. 外務省 verifies nationality entirely off-chain, using existing real-world administrative processes/data (戸籍 etc.) — the same pattern as how a municipality verifies identity off-chain before minting `ResidentLink`. No on-chain nationality sub-credential to depend on.
- **Issue 2 (self-initiated burn for 国籍離脱):** moot — since nationality has no on-chain representation in this design, there's nothing to self-burn. Passport itself, being a controlled travel document (not a personal-rights status), reverts to the citizenship default: **authority-only mint/burn, no self-burn** (mirrors how a physical passport is surrendered to the authority, not unilaterally destroyed by the holder).
- **Issue 3 (trust-anchor):** unchanged — `.go.jp` for 外務省.
- **Issue 4 (renewal = burn-and-reissue):** unchanged, applies as originally proposed.
- **Issue 5 (on-chain nationality check at passport mint time):** moot for the same reason as Issue 2 — there's no on-chain Nationality credential to check. Verification is purely off-chain.

### User (final confirmation)

Confirms this understanding. Asks that **whether to manage nationality (or a residence-status equivalent for foreign residents) on-chain** be revisited separately, as part of a future "foreign residents" design topic — not now. Requests this be added to the backlog.

### Resolution

**All issues resolved.** Scope for this credential: **Passport only** — a pure travel-document credential, issued by 外務省, authority-only mint/burn (no self-burn), renewal modeled as burn-and-reissue, nationality verified entirely off-chain (no on-chain dependency on any nationality credential, because none is built). Added to [`docs/BACKLOG.md`](../../../BACKLOG.md): whether to manage nationality/residence-status on-chain, deferred to a future foreign-residents design topic.

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

---

## Round 2 — 2026-10-06(ユーザー + Claude)— スコープ修正により全論点解決

### ユーザー

国籍とパスポートを分離したいことを確認し、国籍の扱いには「最初に検討したresidential card」も含めたい、と言及。Claudeはこれを、外国人住民の在留資格を示す、国籍とは別の新しいオンチェーンクレデンシャルを並行して設計してほしい、という要望だと誤解し、確認を求めた。

### ユーザー(訂正)

誤解を訂正: 最初に設計したのは`ResidentLink`(国民・住民)であり、これは住民全般を定義するもの。国民か在留外国人かという区分は、市区町村が管理する既存のオフチェーンの行政データ(住基ネットのようなもの)に既に含まれていると理解している — これは`ResidentLink`発行前に市区町村が本人確認に使うのと同じオフチェーンの情報。新たにオンチェーンのクレデンシャルを作るのではなく、この既存のオフチェーン管理を前提にしたい。**意図: パスポートはあくまで「旅券」としてのみ設計したい。**

### Claude

訂正を了承し、各論点への帰結を整理し直した:

- **論点1(国籍とパスポートの分離)**: 修正 — 別のオンチェーン「国籍」クレデンシャルは一切作らない。設計するのは**パスポートのみ**。外務省は、既存の現実の行政プロセス・データ(戸籍等)を使って国籍を完全にオフチェーンで確認する — 市区町村が`ResidentLink`発行前にオフチェーンで本人確認するのと同じパターン。依存すべきオンチェーンの国籍サブクレデンシャルは存在しない。
- **論点2(国籍離脱の自主バーン)**: 消滅 — この設計には国籍のオンチェーン表現がないため、自主バーンする対象がそもそも存在しない。パスポート自体は、個人の権利としての地位ではなく統制された公文書(渡航文書)なので、国民・住民設計のデフォルト通り**発行主体のみがmint/burnでき、自主バーンはなし**(物理的なパスポートも本人が一方的に破棄するのではなく返納するのと同じ)。
- **論点3(信頼の起点)**: 変更なし — 外務省には`.go.jp`。
- **論点4(更新=burn+再発行)**: 変更なし、当初の提案通り適用。
- **論点5(パスポート発行時の国籍のオンチェーン確認)**: 論点2と同じ理由で消滅 — 確認すべきオンチェーンの国籍クレデンシャルが存在しない。確認は完全にオフチェーンで行う。

### ユーザー(最終確認)

この理解を確認。**国籍(または外国人向けの在留資格相当)をオンチェーンで管理するかどうか**は、別途将来の「外国人」検討項目の一部として再検討したい、今ではない、と依頼。バックログへの追加を要請。

### 解決

**全論点解決。** このクレデンシャルのスコープ: **パスポートのみ** — 外務省が発行する、純粋な渡航文書クレデンシャル。発行主体のみがmint/burnでき(自主バーンなし)、更新はburn+再発行でモデル化し、国籍は完全にオフチェーンで確認する(依存すべきオンチェーンの国籍クレデンシャルは作らないため)。[`docs/BACKLOG.md`](../../../BACKLOG.md)に、国籍/在留資格をオンチェーンで管理するかどうかを、将来の外国人関連の設計項目として追加した。
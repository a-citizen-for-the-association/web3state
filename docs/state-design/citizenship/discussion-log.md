# Discussion Log: Citizenship / Residency Design

Records the back-and-forth on this feature's design, in order, so the reasoning behind the final spec is traceable. Do not delete prior rounds — append new ones. Once resolved, the agreed conclusions get written up as the actual spec in [`README.md`](README.md) (or a `design.md` alongside it) and, for the conceptual/legal choice, an ADR in [`docs/decisions/`](../../decisions/).

---

## Round 1 — 2026-10-03 (Claude)

### User's proposal (as given)

- Personal information should be managed only by the proper authority — in principle, only local municipalities (地方自治体) — and only off-chain.
- "国民" (national) = a person whose personal information is registered with a local municipality.
- On-chain, a national is identified solely by a wallet address.
- Each municipality (example: "City A") deploys its own dedicated NFT contract.
- A resident visits city hall, registers personal information, and submits an address; city hall mints them an NFT linking that address to residency, without putting personal data on-chain.
- The municipality publicly declares that this contract is its official one.
- Result: disclosing only an address proves "resident of City A, and by extension a Japanese national" — with zero personal data disclosed.

### Issues raised before implementation

**1. "国民" (national) vs. "住民" (resident) are not the same thing under Japanese law — this is the most important issue.**

Japan's 住民基本台帳 (Basic Resident Register, juki daicho), maintained by municipalities, has — since the 2012 reform — included **foreign residents** (外国人住民) as well as Japanese nationals. Nationality (国籍) is a separate legal status governed by the 国籍法 (Nationality Act) and recorded via 戸籍 (koseki, family registry), which is tied to a person's 本籍地 (registered domicile municipality) — a different, and not-necessarily-same, municipality from where they currently reside (住所地). Two concrete breaks in the proposal as stated:

- A foreign national legally residing in City A also has a 住民票 entry there. Under the proposal's definition ("registered with a municipality = national"), they would incorrectly qualify as a "国民."
- A Japanese national living abroad (no current 住所地 registration in any municipality) would hold no 住民票 and so could never receive the NFT, despite being unambiguously a national.

So "resident of City A ⇒ Japanese national" does not hold in the real system this project is modeling itself on. Before writing a spec, I need to know which of these the feature is actually meant to represent:

- **(a) Residency only.** Rename the concept to 住民 (resident) and make no nationality claim. A separate, later feature would handle 国籍 proof if ever needed (likely 戸籍-based, issued by the 本籍地 municipality, which is a materially different and more complex process than juki registration).
- **(b) A deliberately redefined "citizenship."** This experimental state consciously defines membership as *registered residency*, regardless of real-world nationality — a residency-based model of citizenship, explicitly acknowledged in the docs as diverging from Japanese nationality law.
- **(c) Nationality, enforced at the counter.** Municipalities' 住民票 records already carry a nationality/status field (distinguishing Japanese nationals from 外国人住民 and their residence status). City hall could check this field and only mint the NFT to residents recorded as Japanese nationals. This keeps the user's proposed issuance mechanism (go to city hall, get an NFT) but makes the resulting claim legally accurate: "this NFT means its holder is a Japanese national," not just "a resident of somewhere."

My default recommendation is **(c)** if a genuine nationality proof is the goal, or **(a)** if the goal is a simpler residency-proof module with nationality deferred to a later, separate feature. **(b)** is viable too, but should be a conscious, explicit design choice given the project's premise is otherwise "assume modern state structures as given" (per the top-level README) — redefining citizenship this fundamentally is itself a foundational, hard-to-reverse decision worth its own ADR either way.

**2. How is "this contract is City A's official one" attested, and by whom?**

A city government tweeting/announcing a contract address is not something the system itself can verify. Without a root of trust, anyone could deploy a look-alike "City A" NFT contract and claim it's official. I'd suggest an on-chain **registry contract** — analogous to a real root-of-trust — mapping each municipality to its verified contract address, keyed by Japan's existing **地方公共団体コード** (JIS X 0402 local government code), so we reuse an existing, stable identifier instead of inventing one. Open question: who controls writes to this registry in this experimental project (a project-governance multisig standing in for a real national body, presumably — since in reality this would need something like 総務省's authority, which this project obviously does not have)? This should be named explicitly as a stand-in/assumption, not glossed over.

**3. Must this NFT be non-transferable (soulbound)?**

A standard ERC-721 is transferable by default, which would let someone sell "proof of residency/nationality" — clearly wrong for this purpose. I'm assuming the answer is yes, it must be non-transferable (and almost certainly non-approvable, i.e. block `transferFrom`/`safeTransferFrom`/`approve` entirely, only mint/burn), but flagging it as an explicit decision rather than a silent assumption.

**4. Lifecycle and revocation are undefined.**

Real-world residency status changes: a person moves to another municipality, dies, loses/gains nationality, etc. The proposal as given only describes issuance, not revocation. I'd propose a minimal state machine (`Active` / `Revoked`) with revoke restricted to the issuing municipality's admin role, but need to confirm: who/what triggers revocation on a move (old municipality revokes, new one issues — is there a hand-off, or are the two events independent and manual), and whether a resident can self-burn voluntarily.

**5. Data minimization — what, exactly, lives on-chain?**

To honor "personal information only lives with the municipality, off-chain," the NFT itself should carry nothing beyond what ERC-721 ownership already implies (token ID ↔ address) plus perhaps a status flag and issuance timestamp — no name, no document numbers, not even a hash of personal data (a hash is not always one-way in practice if the input space is guessable). The municipality's own off-chain database holds the token ID ↔ real-identity mapping privately. Flagging this as the intended design so it's confirmed, not assumed.

**6. Deduplication across municipalities is not actually enforced by this design.**

In the real system, 住基ネット (the inter-municipal resident registry network) and My Number prevent a person from being registered as a resident of two municipalities simultaneously. This project's proposal has each municipality operate its own independent contract with no visibility into other municipalities' registries, so nothing on-chain stops a person from (fraudulently) obtaining NFTs from two different cities if they can fool both city halls' offline verification. This is likely an acceptable limitation to document rather than solve immediately (the offline process is where this is actually prevented, same as today), but it should be written down as a known assumption, not discovered later as a bug.

**7. Legal framing.**

Restating what the top-level README already implies: no Japanese municipality currently has legal authority to issue blockchain-based residency/nationality certificates. This feature is a hypothetical design within an experimental state-building project, not a claim that this is legally operative today. Worth a one-line restatement in the eventual spec so it's unambiguous to a future reader of just this one document.

### Status

Waiting on the user's responses to issues 1–6 (7 is just a framing note, not a decision point) before writing the actual spec.

---

## Round 2 — 2026-10-03 (User + Claude) — **Issue 1 resolved**

### User

The 国民/住民 distinction is the municipality's to manage (off-chain), not the NFT's. Main question: does a smart contract ever actually *need* that distinction on-chain, given that purpose-specific needs (e.g., obtaining a passport) will be handled as their own, separate NFTs? Since the municipality already holds both residency and nationality information off-chain, the applicant's status can be determined by whoever issues that specific downstream credential, without the base NFT needing to carry it.

### Claude

Agreed. Proposed resolution:

- **The base NFT (resident-link NFT) makes no claim about nationality at all** — it only proves "this address is linked to a person registered with municipality X." This removes Issue 1's legal problem entirely, because a claim that's never made can't be legally wrong: issuing the same base NFT to Japanese nationals and foreign residents alike is now correct, since the token never asserted nationality in the first place.
- This generalizes into a **two-layer claims/credential pattern** worth adopting project-wide, not just for this feature:
  - **Base identity-link NFT**: identity linkage only (address ↔ registered person), issued by the municipality handling residency registration (住所地).
  - **Purpose-specific claim NFTs** (passport, voting rights, licenses, etc.): each issued independently by whichever authority is responsible for that specific claim, verified off-chain by that authority at issuance time (not inherited from the base NFT).
- Caveat noted: a person's 本籍地 (koseki/nationality-holding municipality) can differ from their 住所地 (residence municipality, which issues the base NFT) — so a nationality-dependent credential (e.g. passport) may need to be issued/verified by a different authority than the one that issued the base NFT. Not a blocker now; relevant when the passport/nationality-credential feature itself is designed.

### Resolution

**Issue 1: RESOLVED.** The base NFT for this feature is a residency-link credential only (no nationality claim). Renamed working concept: this directory should probably be understood as "resident registration link" rather than "citizenship," though the directory name (`citizenship/`) is kept for now since it still covers the broader membership question; to revisit if it causes confusion once the spec is written.

---

## Round 3 — 2026-10-03 (User + Claude) — Issue 2 in progress

### User

Proposes resolving "how is an 'official' NFT contract proven" off-chain entirely: an on-chain registry contract doesn't actually solve the problem, since then "who vouches for the registry being official" becomes the new unanswered question (infinite regress). Instead, authenticity should be established through the municipality's own real-world official channels — city website, official bulletins/newsletters (広報誌), official publications from city hall.

### Claude (response, pending confirmation)

Agree with the core insight: this is fundamentally a social/legal trust problem, not a cryptographic one — an on-chain registry just moves the regress up one level (who vouches for the registry's admin key) rather than resolving it. Proposed refinement of the specific mechanism:

- **Anchor to `.lg.jp`, not a generic website.** Japan's `.lg.jp` domain is a restricted TLD: only verified local government bodies can register one, via an existing vetting process (administered jointly with Japan's local-government/MIC-affiliated registration authority). This means "published on the municipality's `.lg.jp` site" already carries real institutional vetting, stronger than a generic announcement (a plain website, a tweet, a flyer), and reuses an existing trust root instead of inventing a new one for this project.
- **Make it machine-checkable, not just human-readable.** Suggest a well-known URI convention (e.g. `https://<city>.lg.jp/.well-known/web3state-registry.json`) stating the chain ID(s) and contract address(es), so a frontend or another contract's off-chain verifier can check it programmatically — while keeping the root of trust exactly where the user placed it (the municipality's own official channel), not on-chain.
- **Optional strengthening:** Japan's local governments already have LGPKI (地方公共団体組織認証基盤), a real PKI for official electronic documents. A municipality could sign the above JSON/announcement with its LGPKI certificate for a cryptographically verifiable attestation, rather than relying on HTTPS/TLS trust alone. Nice-to-have, not required for v1.
- **No on-chain registry contract for v1 (YAGNI).** Since authenticity is rooted off-chain either way, an on-chain registry doesn't add trust — only convenience for on-chain-to-on-chain lookups, which no feature currently needs. Defer until a concrete on-chain consumer requires automated contract-to-contract verification. For now, the project (or its frontend) can maintain a plainly-labeled **non-authoritative convenience list** of known municipality contracts, cross-referenced against each municipality's own official announcement — verifiers should always be able to check the primary source directly rather than trust this list blindly.
- This whole mechanism is a clean example of the project's own [online/on-chain/offline convention](../../operations/README.md): the declaration itself is **online** (a public web channel), its root of trust is **offline** (legal status as a verified local government, LGPKI issuance process), and deliberately **not on-chain**.

### Resolution

**Issue 2: RESOLVED.** Confirmed by the user. Authenticity of "this is City A's official contract" is established entirely off-chain/online, anchored to the municipality's `.lg.jp` domain (a restricted TLD requiring real-world vetting as a legitimate local government). Convention: a well-known URI (e.g. `https://<city>.lg.jp/.well-known/web3state-registry.json`) states chain ID(s) and contract address(es), optionally LGPKI-signed for stronger attestation (nice-to-have, not v1-required). No on-chain registry contract in v1 (YAGNI) — the project may keep a clearly-labeled, non-authoritative convenience list for its own frontend, cross-checked against each municipality's primary announcement.

---

## Round 4 — 2026-10-03 (User) — **Issue 3 resolved**

### User

Confirms: the NFT must be non-transferable (soulbound).

### Resolution

**Issue 3: RESOLVED.** The resident-link NFT is soulbound (non-transferable). Implementation note (not a new decision, just recording the technical approach implied): build on OpenZeppelin's ERC-721 (most recent stable release — pin and verify at implementation time), override the internal transfer hook (`_update` in OZ v5.x) to revert for any transfer that isn't a mint (`from == address(0)`) or burn (`to == address(0)`), and disable `approve`/`setApprovalForAll` (revert on call) so no transfer path exists at all. Consider also implementing [ERC-5192](https://eips.ethereum.org/EIPS/eip-5192) (Minimal Soulbound NFTs — adds a standard `locked(uint256)` view and `Locked`/`Unlocked` events) so wallets/explorers that recognize the standard can display this correctly, rather than inventing a bespoke non-standard interface.

---

## Round 5 — 2026-10-03 (Claude) — Issue 4 in progress

### Claude (initial proposal)

Lifecycle/revocation proposal for the resident-link NFT:

- Two states (`Active` / `Revoked`), only the issuing municipality's admin role can revoke, no on-chain reason code, self-burn allowed as a holder convenience, re-issuance via revoke-then-mint.

### User (revision)

Registration and revocation must be municipality-only — **no self-burn** (it would only cause confusion). Re-issuance should remain possible, with the necessary verification for re-issuance happening offline at the municipality. Asked: what does "Revoked" actually mean?

### Claude (revised proposal)

Simplification: drop the separate `Active`/`Revoked` status field entirely. **"Revoke" = the municipality admin role burns the token.** Validity is then just token existence (`ownerOf`/`balanceOf`) — no status enum needed, and it avoids the awkward "exists but revoked" intermediate state that would otherwise complicate re-issuance to the same address. History is not lost: standard ERC-721 `Transfer` events from mint (`0x0 → resident`) and burn (`resident → 0x0`) remain permanently queryable on-chain, so "who was a resident when" stays auditable without any extra storage. Final lifecycle: **mint** (municipality only, after in-person verification), **burn/revoke** (municipality only; reason stays in the municipality's private off-chain record, never on-chain), **re-issuance** (municipality mints again after the same in-person verification as initial issuance — works cleanly to the same address once the old token is burned).

### Resolution

**Issue 4: RESOLVED.** Municipality-only mint/burn; no self-burn; "revoke" = burn, no separate status field; reason codes stay off-chain; re-issuance = burn + mint after offline re-verification by the municipality.

---

## Round 6 — 2026-10-03 (Claude) — Issue 5 in progress

### Claude (proposal)

Finalizing on-chain data minimization now that the lifecycle is existence-based (Round 5):

- The contract stores **nothing per-token beyond standard ERC-721 ownership** (`tokenId ↔ owner address`, implicit in the base standard). No status field (superseded by Round 5), no on-chain issuance timestamp (already recoverable from the mint `Transfer` event's block data — no need to duplicate it in storage), no hash of personal data (explicitly rejected in Round 1: a hash isn't safely one-way when the underlying input space — e.g. a 12-digit My Number — is small enough to brute-force).
- `tokenId` assignment should carry no information — a plain sequential counter, not anything derived from the resident's personal data.
- `tokenURI`/metadata, if implemented at all, should be **identical for every token** (e.g., static text identifying "this is City A's resident-link token") — never personalized per holder, so it can't leak anything about who holds a given token ID beyond what on-chain ownership already reveals.
- Contract-level (not per-token) data is fine to store: the municipality's identifier (e.g., 地方公共団体コード, for cross-referencing against the `.lg.jp` well-known announcement from Issue 2) and the admin role(s) for mint/burn.

### Resolution

**Issue 5: RESOLVED.** User confirmed ("OKです"). No per-token data beyond standard ERC-721 ownership; no status field; no on-chain timestamp; no hash of personal data; sequential meaningless `tokenId`; identical metadata for every token; only contract-level (not per-token) data such as the municipality identifier and admin role.

---

## Round 7 — 2026-10-03 (User + Claude) — Issue 6 in progress

### User (historical question)

Before My Number / 住基ネット existed, how did Japan prevent a person being registered as a resident of two municipalities at once? Proposes: proof of legitimate address ownership (the individual holds the private key) plus, for nationals, being able to confirm another municipality's move-out record, might be enough to prevent duplicate registration.

### Claude (historical answer + initial design response)

- Pre-2002 (before 住基ネット), the mechanism was a **serial paper hand-off**: a 転出届 (move-out notification) at the old municipality produces a 転出証明書 (move-out certificate); the 転入届 (move-in notification) at the new municipality requires that certificate. A person couldn't be registered in two places at once because entering a new registry required proof of having left the old one. 戸籍 (koseki/nationality, tied to 本籍地) is a separate, independent axis — it doesn't move with 住所 and isn't itself a residency-dedup mechanism. This paper system wasn't airtight (forgery/non-disclosure risk existed) — which is exactly why 住基ネット (2002) and My Number (2015/2016) were introduced, to add real-time nationwide cross-checking.
- Initial response treated this as: dedup is delegated entirely to the (today's) off-chain municipal registration process, with no on-chain mechanism at all. The user pushed back: wanted the **on-chain burn history itself** to serve as the verifiable "proof of departure," rather than relying purely on an off-chain, unverifiable process.

### Claude (revised design, accepted)

Add one piece of **permanent, non-reversing, per-address state** to the resident-link contract: `everIssued(address) → bool`, set `true` at mint, never cleared by burn. Combined with the already-standard `balanceOf(address)`, the pair **`everIssued == true && balanceOf == 0`** is an on-chain, trustless, forgery-proof equivalent of a paper 転出証明書 — "this address was once a resident here, and is not currently." A new municipality's mint flow for someone declaring a move from a specific prior municipality can check this directly (on-chain, cross-contract), rather than trusting an unverifiable paper document or an off-chain-only claim. Only 1 bit of state per address; no personal data; consistent with Issue 5's minimization. Noted limitation: this only verifies departure from the *one declared* prior municipality — it cannot prove the absence of an undisclosed, still-active token at some other municipality (that would need the on-chain cross-municipality registry deferred in Issue 2). This mirrors the historical paper system's own limitation exactly (which also only checked the one declared prior municipality) — not a regression, just the same assumption made cryptographically verifiable instead of paper-and-seal-based.

### User (final resolution)

Confirms: fine with reverting to the "paper-era" assumption (single declared prior municipality, checked via on-chain burn history) — **or equally fine assuming an off-chain inter-municipal network (住基ネット-like) exists for stronger, nationwide dedup**, since the project already assumes municipalities hold and manage personal information (so assuming they also network with each other off-chain, as they do today, is consistent). Combined final design: **on-chain, rely on burn history (`everIssued` + `balanceOf`) as the verifiable proof of departure; off-chain, assume an inter-municipal network among municipalities exists (as it does in reality today) for anything beyond the single-declared-transfer case.**

### Resolution

**Issue 6: RESOLVED.** Deduplication = on-chain burn-history check (`everIssued` + `balanceOf`) for the declared-transfer case, combined with an off-chain assumption that municipalities already network with each other (mirroring 住基ネット/マイナンバー or their historical paper equivalent) for anything the on-chain check alone can't cover. No on-chain cross-municipality registry needed for this (consistent with Issue 2's YAGNI decision).

---

## Round 8 — 2026-10-03 (Claude + User) — **Issue 7 resolved**

### Claude (proposal)

Proposed disclaimer text for the design spec: under current Japanese law, no municipality has legal authority to issue blockchain tokens as an official instrument of residency/nationality certification; this design is a hypothetical implementation within web3state (an experimental, thought-experiment project), not a claim that it is operative under current law.

### User

Confirms: "当然です。これはただの思考実験プロジェクトなので、実際に適用することを前提としていません。" (Of course — this is purely a thought-experiment project, not intended for actual real-world application.)

### Resolution

**Issue 7: RESOLVED.**

---

## Summary: all 7 issues resolved (2026-10-03)

| # | Issue | Resolution |
|---|---|---|
| 1 | 国民 vs 住民 | Base NFT makes no nationality claim — it is a residency-link credential only. Nationality-dependent needs (e.g. passport) are separate, future credentials issued by whichever authority is responsible, verified off-chain at issuance. |
| 2 | Proving an "official" contract | Off-chain/online, anchored to the municipality's `.lg.jp` domain (institutionally vetted TLD) via a well-known URI; optionally LGPKI-signed. No on-chain registry in v1. |
| 3 | Transferability | Soulbound (non-transferable); OpenZeppelin ERC-721 base with transfer/approve paths disabled; consider ERC-5192. |
| 4 | Lifecycle/revocation | Municipality-only mint/burn; no self-burn; "revoke" = burn (no separate status field); no on-chain reason codes; re-issuance = burn + mint after offline re-verification. |
| 5 | On-chain data minimization | Nothing per-token beyond standard ERC-721 ownership, plus the `everIssued` flag (Issue 6); no timestamps, no hashes, no personalized metadata. |
| 6 | Cross-municipality deduplication | On-chain: `everIssued(address) && balanceOf(address)==0` on the declared previous municipality's contract, as a trustless digital equivalent of a 転出証明書. Off-chain: assume municipalities network with each other (住基ネット/マイナンバー-equivalent) for anything beyond the single declared transfer. |
| 7 | Legal framing | Explicit disclaimer: hypothetical/thought-experiment design, not a claim of present legal authority or real-world applicability. |

Next: write the formal design spec (replacing this directory's `README.md` stub) and an ADR capturing the conceptual/architecture decisions above.

---

# 議論ログ: 国民・住民(日本語)

この機能の設計に関するやり取りを順に記録し、最終的な仕様の根拠を追えるようにする。過去のラウンドは削除せず、新しいラウンドを追記する。解決した結論は、実際の仕様として[`README.md`](README.md)(またはその隣の`design.md`)に書き、概念上・法律上の選択は[`docs/decisions/`](../../decisions/)のADRに書く。

---

## Round 1 — 2026-10-03(Claude)

### ユーザーの提案(原文のまま)

- 個人情報は正当な主体だけが管理すべきである。原則として地方自治体だけが、オフチェーンでのみ管理する。
- 「国民」= 個人情報が地方自治体に登録されている人。
- オンチェーンでは、国民はウォレットアドレスだけで識別する。
- 各自治体(例: 「A市」)が専用のNFTコントラクトをデプロイする。
- 住民は市役所へ行き、個人情報を登録し、アドレスを提出する。市役所は、個人情報をオンチェーンに載せずに、そのアドレスと居住を結びつけるNFTをmintする。
- 自治体は、このコントラクトが自らの公式のものだと公に宣言する。
- 結果: アドレスを開示するだけで「A市の住民であり、したがって日本国民である」ことを証明できる。個人情報は一切開示しない。

### 実装前に提起する論点

**1. 日本の法律では「国民」と「住民」は同じではない。これが最も重要な論点である。**

市区町村が管理する住民基本台帳には、2012年の改正以降、日本国民だけでなく**外国人住民**も含まれる。国籍は国籍法が定める別の法的地位であり、戸籍で記録される。戸籍は本籍地の市区町村に結びついており、現在住んでいる住所地の市区町村とは別で、同じとは限らない。提案のままでは、具体的に2つの点で破綻する:

- A市に適法に住む外国人も、A市に住民票がある。提案の定義(「市区町村に登録されている = 国民」)では、誤って「国民」に該当してしまう。
- 海外に住む日本国民(どの市区町村にも現在の住所地の登録がない)は住民票を持たないので、明らかに国民であるのにNFTを受け取れない。

したがって、このプロジェクトが手本とする現実の制度では「A市の住民 ⇒ 日本国民」は成り立たない。仕様を書く前に、この機能が実際にどれを表すのかを知る必要がある:

- **(a) 居住だけ。** 概念を「住民」に改め、国籍については何も主張しない。国籍の証明が必要になれば、後で別の機能が扱う(おそらく本籍地の市区町村が発行する戸籍ベースのもので、住基の登録とは実質的に異なり、より複雑な手続きになる)。
- **(b) 意図的に再定義した「国民」。** この実験国家は、現実の国籍にかかわらず、*登録された居住*を構成員の資格と意識的に定義する。居住に基づく国民のモデルであり、日本の国籍法とは異なることを文書で明示する。
- **(c) 窓口で確認する国籍。** 市区町村の住民票の記録には、すでに国籍・在留資格の欄がある(日本国民と外国人住民、その在留資格を区別する)。市役所はこの欄を確認し、日本国民と記録された住民にだけNFTをmintできる。ユーザーが提案した発行の仕組み(市役所へ行き、NFTを受け取る)はそのままで、結果として得られる主張が法的に正確になる。つまり「どこかの住民」ではなく「このNFTの保有者は日本国民である」という意味になる。

私のデフォルトの推奨は、本当の国籍の証明が目的なら**(c)**、国籍は後の別機能に回して簡単な居住証明のモジュールにするなら**(a)**である。**(b)**も成り立つが、意識的で明示的な設計上の選択にすべきである。このプロジェクトの前提は、それ以外の点では「近代国家の構造をそのまま前提とする」(トップレベルのREADME)だからだ。国民をここまで根本的に再定義することは、それ自体が基礎的で後戻りしにくい決定であり、どちらにしても独立したADRに値する。

**2. 「このコントラクトがA市の公式のものだ」ことを、誰が、どう証明するのか?**

市役所がコントラクトアドレスをツイートや告知で発表しても、システム自身はそれを検証できない。信頼の起点がなければ、誰でもそっくりな「A市」のNFTコントラクトをデプロイし、公式だと主張できる。そこで、現実の信頼の起点に相当するオンチェーンの**レジストリコントラクト**を提案する。各自治体を、検証済みのコントラクトアドレスに対応付ける。キーには日本の既存の**地方公共団体コード**(JIS X 0402)を使い、識別子を新たに作らずに既存の安定したものを流用する。未解決の問い: この実験プロジェクトで、このレジストリへの書き込みを誰が管理するのか(現実の国の機関の代わりとして、プロジェクトのガバナンスのマルチシグになるだろう。現実には総務省のような権限が必要だが、このプロジェクトは当然それを持たない)。これは代替・仮定として明示すべきで、ごまかすべきではない。

**3. このNFTは譲渡不可(ソウルバウンド)でなければならないか?**

標準のERC-721はデフォルトで譲渡できる。すると「居住・国籍の証明」を売れてしまう。この目的には明らかに誤りである。答えはイエス、つまり譲渡不可でなければならないと想定している(ほぼ確実に承認も不可、つまり`transferFrom`/`safeTransferFrom`/`approve`を完全に止め、mint/burnだけにする)。ただし、黙って前提にせず、明示的な決定として挙げておく。

**4. ライフサイクルと失効が定義されていない。**

現実の居住の状態は変わる。別の市区町村へ引っ越す、亡くなる、国籍を失う・得る、などである。提案は発行だけを述べ、失効を述べていない。最小限の状態遷移(`Active` / `Revoked`)を提案する。失効は発行した自治体の管理者ロールに限る。ただし確認が必要な点がある: 引っ越しのとき、誰が・何が失効を起こすのか(旧市区町村が失効させ、新市区町村が発行する。引き継ぎがあるのか、2つの手続きは独立した手作業なのか)。また、住民が自分の意思でburnできるのか。

**5. データの最小化 — 正確に何をオンチェーンに置くのか?**

「個人情報は自治体だけがオフチェーンで持つ」を守るには、NFT自体はERC-721の所有がすでに意味するもの(トークンID ↔ アドレス)以外に、せいぜい状態フラグと発行時刻だけを持つべきである。氏名も書類番号も持たない。個人情報のハッシュすら持たない(入力の範囲が推測できる場合、ハッシュは実際には一方向とは限らない)。トークンIDと実際の本人との対応は、自治体のオフチェーンのデータベースが非公開で持つ。これを意図した設計として挙げ、前提ではなく確認された事項にする。

**6. この設計では、市区町村をまたぐ重複登録は実際には防げない。**

現実の制度では、住基ネット(市区町村間の住民登録ネットワーク)とマイナンバーが、2つの市区町村に同時に住民登録されることを防いでいる。この提案では各自治体が独立したコントラクトを運用し、他の自治体の登録は見えない。したがって、2つの市役所のオフラインの確認をどちらもだませれば、2つの市から(不正に)NFTを得ることをオンチェーンでは何も止めない。これはすぐに解決するより、限界として文書化すれば足りるだろう(実際にこれを防ぐのは今日と同じくオフラインの手続きである)。ただし、後でバグとして見つかるのではなく、既知の前提として書いておくべきである。

**7. 法的な位置づけ。**

トップレベルのREADMEがすでに示していることの再確認: 現在、日本のどの市区町村にも、ブロックチェーンによる居住・国籍の証明書を発行する法的権限はない。この機能は実験的な国家構築プロジェクトの中での仮想の設計であり、今日法的に有効だという主張ではない。最終的な仕様に一文で再確認しておく価値がある。この1つの文書だけを読む将来の読者にも誤解がないようにするためだ。

### ステータス

実際の仕様を書く前に、Issue 1〜6についてユーザーの回答を待つ(7は位置づけの注記にすぎず、決定事項ではない)。

---

## Round 2 — 2026-10-03(ユーザー + Claude)— **Issue 1解決**

### ユーザー

国民と住民の区別は自治体が(オフチェーンで)管理するものであり、NFTが持つものではない。主な問い: 目的ごとの必要(例: パスポートの取得)はそれぞれ別のNFTで扱うのだから、スマートコントラクトがその区別をオンチェーンで本当に*必要*とすることはあるのか。自治体は居住と国籍の情報をすでにオフチェーンで持っている。したがって申請者の地位は、その個別のクレデンシャルを発行する主体が判断でき、基本のNFTがそれを持つ必要はない。

### Claude

同意する。解決案:

- **基本のNFT(住民リンクNFT)は国籍について一切主張しない。** 証明するのは「このアドレスは市区町村Xに登録された人と結びついている」ことだけである。これでIssue 1の法的な問題は完全になくなる。主張しないことは法的に誤りになりえないからだ。同じ基本のNFTを日本国民にも外国人住民にも発行することが、今では正しい。トークンは最初から国籍を主張していないからである。
- これは、この機能だけでなくプロジェクト全体で採用する価値のある**2層の主張・クレデンシャルのパターン**に一般化できる:
  - **基本の本人リンクNFT**: 本人の結びつき(アドレス ↔ 登録された人)だけを表す。住民登録を扱う市区町村(住所地)が発行する。
  - **目的ごとの主張NFT**(パスポート、投票権、免許等): それぞれ、その主張に責任を持つ主体が独立して発行する。発行時にその主体がオフチェーンで確認する(基本のNFTから引き継がない)。
- 注意点: 本籍地(戸籍・国籍を持つ市区町村)は住所地(基本のNFTを発行する居住の市区町村)と異なりうる。したがって国籍に依存するクレデンシャル(例: パスポート)は、基本のNFTを発行した主体とは別の主体が発行・確認する必要があるかもしれない。今は妨げにならない。パスポート・国籍クレデンシャルの機能自体を設計するときに関係する。

### 解決

**Issue 1: 解決。** この機能の基本のNFTは居住リンクのクレデンシャルだけである(国籍の主張はない)。作業上の概念を改名する: このディレクトリは「国民」ではなく「住民登録のリンク」と理解すべきだろう。ただし、より広い構成員の問題も扱うため、ディレクトリ名(`citizenship/`)は当面そのままにする。仕様を書いた後に混乱を招くようなら見直す。

---

## Round 3 — 2026-10-03(ユーザー + Claude)— Issue 2検討中

### ユーザー

「公式の」NFTコントラクトをどう証明するかを、完全にオフチェーンで解決することを提案する。オンチェーンのレジストリコントラクトは実際には問題を解決しない。今度は「レジストリが公式だと誰が保証するのか」が新たな未解決の問いになるからだ(無限後退)。代わりに、真正性は自治体自身の現実の公式な経路で示すべきである。市のウェブサイト、広報誌、市役所の公式な刊行物などである。

### Claude(回答、確認待ち)

中心となる洞察に同意する。これは本質的に社会的・法的な信頼の問題であり、暗号の問題ではない。オンチェーンのレジストリは後退を1段上に移すだけで(誰がレジストリの管理者鍵を保証するのか)、解決しない。具体的な仕組みについての改良案:

- **一般的なウェブサイトではなく`.lg.jp`を起点にする。** 日本の`.lg.jp`ドメインは制限付きのTLDである。既存の審査手続き(地方自治体・総務省系の登録機関と共同で運営)を経て、確認された地方公共団体だけが登録できる。したがって「自治体の`.lg.jp`サイトで公表された」ことは、すでに現実の制度上の審査を伴う。一般的な告知(普通のウェブサイト、ツイート、チラシ)より強く、このプロジェクトのために新しい信頼の起点を作らずに既存のものを流用できる。
- **人が読めるだけでなく、機械で確認できるようにする。** well-known URIの規約(例: `https://<city>.lg.jp/.well-known/web3state-registry.json`)で、チェーンIDとコントラクトアドレスを示すことを提案する。フロントエンドや別のコントラクトのオフチェーンの検証者がプログラムで確認できる。一方で信頼の起点は、ユーザーが置いた場所(自治体自身の公式な経路)のままで、オンチェーンには置かない。
- **任意の強化策:** 日本の地方公共団体には、公式な電子文書のための実在のPKIであるLGPKI(地方公共団体組織認証基盤)がすでにある。自治体は上記のJSONや告知にLGPKIの証明書で署名でき、HTTPS/TLSの信頼だけに頼らず、暗号的に検証できる証明になる。あれば良いが、v1では必須ではない。
- **v1ではオンチェーンのレジストリコントラクトを作らない(YAGNI)。** 真正性はいずれにせよオフチェーンに根ざすので、オンチェーンのレジストリは信頼を加えない。加えるのはオンチェーン同士の照会の便利さだけで、それを今必要とする機能はない。コントラクト間の自動検証を必要とする具体的なオンチェーンの利用者が現れるまで先送りする。当面、プロジェクト(またはそのフロントエンド)は、既知の自治体のコントラクトの**非公式な便宜上のリスト**を、その旨をはっきり示して管理できる。各自治体自身の公式な告知と照合する。検証者はこのリストを盲目的に信頼せず、常に一次情報源を直接確認できるべきである。
- この仕組み全体が、プロジェクト自身の[オンライン/オンチェーン/オフラインの規約](../../operations/README.md)のわかりやすい例である。宣言自体は**オンライン**(公開のウェブの経路)、信頼の起点は**オフライン**(確認された地方公共団体としての法的地位、LGPKIの発行手続き)であり、意図的に**オンチェーンではない**。

### 解決

**Issue 2: 解決。** ユーザーが確認した。「これがA市の公式のコントラクトである」ことの真正性は、完全にオフチェーン/オンラインで示す。起点は自治体の`.lg.jp`ドメインである(正当な地方公共団体として現実の審査を要する制限付きのTLD)。規約: well-known URI(例: `https://<city>.lg.jp/.well-known/web3state-registry.json`)でチェーンIDとコントラクトアドレスを示す。より強い証明のために任意でLGPKIの署名を付ける(あれば良いが、v1では必須ではない)。v1ではオンチェーンのレジストリコントラクトを作らない(YAGNI)。プロジェクトは自身のフロントエンドのために、非公式であることをはっきり示した便宜上のリストを持ってよい。各自治体の一次の告知と照合する。

---

## Round 4 — 2026-10-03(ユーザー)— **Issue 3解決**

### ユーザー

確認: NFTは譲渡不可(ソウルバウンド)でなければならない。

### 解決

**Issue 3: 解決。** 住民リンクNFTはソウルバウンド(譲渡不可)である。実装上の注記(新しい決定ではなく、含意される技術的な方法の記録): OpenZeppelinのERC-721(最新の安定版。実装時に固定し確認する)を基にする。内部の転送フック(OZ v5.xでは`_update`)をオーバーライドし、mint(`from == address(0)`)でもburn(`to == address(0)`)でもない転送はすべてrevertさせる。`approve`/`setApprovalForAll`を無効にし(呼び出すとrevert)、転送の経路を一切なくす。[ERC-5192](https://eips.ethereum.org/EIPS/eip-5192)(Minimal Soulbound NFTs。標準の`locked(uint256)` viewと`Locked`/`Unlocked`イベントを加える)の実装も検討する。独自の非標準のインターフェースを作るのではなく、この標準を認識するウォレットやエクスプローラーが正しく表示できるようにするためだ。

---

## Round 5 — 2026-10-03(Claude)— Issue 4検討中

### Claude(最初の提案)

住民リンクNFTのライフサイクル・失効の提案:

- 2つの状態(`Active` / `Revoked`)。失効させられるのは発行した自治体の管理者ロールだけ。オンチェーンの理由コードはなし。保有者の便宜のため自分でのburnを許す。再発行は失効させてからmintする。

### ユーザー(修正)

登録と失効は自治体だけが行うべきである。**自分でのburnはなし**(混乱を招くだけである)。再発行は可能なままにし、再発行に必要な確認は自治体でオフラインで行う。質問: 「Revoked」とは実際には何を意味するのか?

### Claude(修正した提案)

簡素化: 別個の`Active`/`Revoked`の状態フィールドを完全にやめる。**「失効」= 自治体の管理者ロールがトークンをburnすること。** 有効性は単にトークンが存在するかどうか(`ownerOf`/`balanceOf`)になる。状態のenumは不要で、「存在するが失効している」という扱いにくい中間状態も避けられる。この中間状態があると、同じアドレスへの再発行が複雑になる。履歴は失われない。mint(`0x0 → 住民`)とburn(`住民 → 0x0`)の標準のERC-721の`Transfer`イベントは、オンチェーンで永久に照会できる。したがって、追加の保存なしに「誰がいつ住民だったか」を監査できる。最終的なライフサイクル: **mint**(自治体のみ、対面での確認の後)、**burn/失効**(自治体のみ。理由は自治体の非公開のオフチェーンの記録に残し、オンチェーンには決して載せない)、**再発行**(最初の発行と同じ対面での確認の後に自治体が再びmintする。古いトークンをburnすれば、同じアドレスにきれいに再発行できる)。

### 解決

**Issue 4: 解決。** mint/burnは自治体のみ。自分でのburnはなし。「失効」= burnで、別個の状態フィールドはなし。理由コードはオフチェーンに置く。再発行 = 自治体によるオフラインの再確認の後にburn + mint。

---

## Round 6 — 2026-10-03(Claude)— Issue 5検討中

### Claude(提案)

ライフサイクルが存在ベースになった(Round 5)ので、オンチェーンのデータ最小化を確定する:

- コントラクトは**標準のERC-721の所有以外に、トークンごとのデータを何も保存しない**(`tokenId ↔ 所有者アドレス`、基本の標準に含まれる)。状態フィールドなし(Round 5で置き換え済み)。オンチェーンの発行時刻なし(mintの`Transfer`イベントのブロックデータからすでに復元でき、ストレージに重複して持つ必要はない)。個人情報のハッシュなし(Round 1で明示的に却下済み。元の入力の範囲、例えば12桁のマイナンバーが総当たりできるほど小さいと、ハッシュは安全に一方向とはいえない)。
- `tokenId`の割り当ては情報を持たないようにする。住民の個人情報から導くものではなく、単純な連番にする。
- `tokenURI`/メタデータは、実装するとしても**全トークンで同一**にする(例: 「これはA市の住民リンクトークンである」と示す固定の文)。保有者ごとに個別化しない。オンチェーンの所有がすでに明かす以上に、あるトークンIDを誰が持つかについて何も漏らさないようにするためだ。
- コントラクト単位の(トークンごとではない)データは保存してよい。自治体の識別子(例: 地方公共団体コード。Issue 2の`.lg.jp`のwell-knownの告知と照合するため)と、mint/burnの管理者ロールである。

### 解決

**Issue 5: 解決。** ユーザーが確認した(「OKです」)。標準のERC-721の所有以外にトークンごとのデータはなし。状態フィールドなし。オンチェーンの時刻なし。個人情報のハッシュなし。意味を持たない連番の`tokenId`。全トークンで同一のメタデータ。自治体の識別子や管理者ロールのような、コントラクト単位の(トークンごとではない)データだけを持つ。

---

## Round 7 — 2026-10-03(ユーザー + Claude)— Issue 6検討中

### ユーザー(歴史についての質問)

マイナンバーや住基ネットができる前、日本は2つの市区町村に同時に住民登録されることをどう防いでいたのか? 提案: アドレスの正当な所有の証明(本人が秘密鍵を持つ)に加え、国民については別の市区町村の転出の記録を確認できれば、重複登録を防ぐのに十分かもしれない。

### Claude(歴史についての回答 + 最初の設計上の回答)

- 2002年より前(住基ネット以前)の仕組みは、**紙による順番の引き継ぎ**だった。旧市区町村で転出届を出すと転出証明書が交付され、新市区町村での転入届にはその証明書が必要だった。新しい台帳に入るには古い台帳から出たことの証明が必要だったので、2か所に同時に登録することはできなかった。戸籍(国籍。本籍地に結びつく)は別の独立した軸であり、住所とともに移らず、それ自体は居住の重複を防ぐ仕組みではない。この紙の制度は完全ではなかった(偽造や申告漏れの危険があった)。だからこそ住基ネット(2002年)とマイナンバー(2015/2016年)が導入され、全国のリアルタイムの照合が加わった。
- 最初の回答では、重複の防止を(今日の)オフチェーンの市区町村の登録手続きに完全に任せ、オンチェーンの仕組みは一切持たないとした。ユーザーは反対した。オフチェーンの検証できない手続きだけに頼るのではなく、**オンチェーンのburnの履歴そのもの**を、検証可能な「転出の証明」として使いたいとした。

### Claude(修正した設計、採用)

住民リンクのコントラクトに、**永続的で元に戻らない、アドレスごとの状態**を1つ加える。`everIssued(address) → bool`で、mint時に`true`にし、burnでは決して消さない。標準の`balanceOf(address)`と組み合わせると、**`everIssued == true && balanceOf == 0`**の組は、紙の転出証明書に相当する、オンチェーンで信頼を要さず偽造できないものになる。「このアドレスはかつてここの住民で、今は住民ではない」という意味である。特定の旧市区町村からの転入を申告する人について、新市区町村のmintの流れはこれを直接(オンチェーンで、コントラクト間で)確認できる。検証できない紙の書類やオフチェーンだけの主張を信頼する必要はない。状態はアドレスごとに1ビットだけで、個人情報はなく、Issue 5の最小化と整合する。限界: 確認できるのは*申告した1つの*旧市区町村からの転出だけである。申告していない別の市区町村に有効なトークンがまだ残っていないことは証明できない(それにはIssue 2で先送りした、市区町村をまたぐオンチェーンのレジストリが必要になる)。これは歴史上の紙の制度の限界(申告した1つの旧市区町村だけを確認していた)とまったく同じである。後退ではなく、同じ前提を紙と印鑑ではなく暗号で検証できるようにしただけである。

### ユーザー(最終的な解決)

確認: 「紙の時代」の前提(申告した1つの旧市区町村を、オンチェーンのburnの履歴で確認する)に戻すのでよい。**あるいは、より強い全国的な重複防止のために、オフチェーンの市区町村間ネットワーク(住基ネットのようなもの)があると仮定するのでも同じくよい。** プロジェクトはすでに、市区町村が個人情報を持ち管理すると仮定している。したがって、今日と同じように市区町村同士がオフチェーンでつながっていると仮定するのも整合的である。最終的な設計の組み合わせ: **オンチェーンでは、burnの履歴(`everIssued` + `balanceOf`)を検証可能な転出の証明として使う。オフチェーンでは、申告した1件の転出を超えることについて、市区町村間のネットワークが(今日の現実と同様に)存在すると仮定する。**

### 解決

**Issue 6: 解決。** 重複の防止 = 申告した転出の場合はオンチェーンのburnの履歴の確認(`everIssued` + `balanceOf`)。オンチェーンの確認だけでは足りない部分については、市区町村同士がすでにつながっている(住基ネット/マイナンバー、または歴史上の紙の制度に相当)というオフチェーンの仮定と組み合わせる。このために市区町村をまたぐオンチェーンのレジストリは不要である(Issue 2のYAGNIの決定と整合する)。

---

## Round 8 — 2026-10-03(Claude + ユーザー)— **Issue 7解決**

### Claude(提案)

設計仕様に入れる免責の文案: 現行の日本の法律では、居住・国籍の証明の公式な手段としてブロックチェーンのトークンを発行する法的権限を持つ市区町村はない。この設計はweb3state(実験的な思考実験のプロジェクト)の中での仮想の実装であり、現行法のもとで有効だという主張ではない。

### ユーザー

確認: 「当然です。これはただの思考実験プロジェクトなので、実際に適用することを前提としていません。」

### 解決

**Issue 7: 解決。**

---

## まとめ: 7つの論点すべて解決(2026-10-03)

| # | 論点 | 解決 |
|---|---|---|
| 1 | 国民と住民 | 基本のNFTは国籍を主張しない。居住リンクのクレデンシャルだけである。国籍に依存する必要(例: パスポート)は、責任を持つ主体が発行する別の将来のクレデンシャルとし、発行時にオフチェーンで確認する。 |
| 2 | 「公式の」コントラクトの証明 | オフチェーン/オンラインで、自治体の`.lg.jp`ドメイン(制度上審査されるTLD)を起点にwell-known URIで示す。任意でLGPKIの署名。v1ではオンチェーンのレジストリはなし。 |
| 3 | 譲渡の可否 | ソウルバウンド(譲渡不可)。OpenZeppelinのERC-721を基にし、転送・承認の経路を無効にする。ERC-5192を検討する。 |
| 4 | ライフサイクル・失効 | mint/burnは自治体のみ。自分でのburnはなし。「失効」= burn(別個の状態フィールドなし)。オンチェーンの理由コードなし。再発行 = オフラインの再確認の後にburn + mint。 |
| 5 | オンチェーンのデータ最小化 | 標準のERC-721の所有と`everIssued`フラグ(Issue 6)以外に、トークンごとのデータはなし。時刻なし、ハッシュなし、個別化したメタデータなし。 |
| 6 | 市区町村をまたぐ重複の防止 | オンチェーン: 申告した旧市区町村のコントラクトで`everIssued(address) && balanceOf(address)==0`を確認する。転出証明書に相当する、信頼を要さないデジタルの仕組みである。オフチェーン: 申告した1件の転出を超えることについて、市区町村同士がつながっている(住基ネット/マイナンバーに相当)と仮定する。 |
| 7 | 法的な位置づけ | 明示的な免責: 仮想の・思考実験の設計であり、現在の法的権限や現実への適用を主張するものではない。 |

次: 正式な設計仕様を書き(このディレクトリの`README.md`のスタブを置き換える)、上記の概念上・アーキテクチャ上の決定を記録するADRを書く。

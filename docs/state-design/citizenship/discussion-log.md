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

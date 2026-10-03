# 0003. Resident-link identity model for citizenship/residency

**Date:** 2026-10-03
**Status:** Accepted

## Context

The first concrete state function to design was citizenship/residency (国民・住民): how to represent, on-chain, that a person is recognized as a resident/national by a municipality, while keeping personal information off-chain and managed only by municipalities, per the user's stated principle.

The initial proposal conflated 国民 (national, a nationality status under the 国籍法, recorded via 戸籍) with 住民 (resident, registered in a municipality's 住民基本台帳, which has included foreign residents since 2012) — these are legally distinct in Japan, and the proposal's implicit claim ("registered with a municipality ⇒ Japanese national") does not hold. Several other foundational questions were open: how an "official" municipal contract is verified, whether the token should be transferable, how it is revoked, what data it should hold on-chain, and whether/how cross-municipality duplicate registration is prevented.

These were worked through in detail with the user; see [`docs/state-design/citizenship/discussion-log.md`](../state-design/citizenship/discussion-log.md) for the full reasoning. This ADR records only the resulting decisions.

## Decision

- **The base token makes no claim about nationality.** It proves residency-linkage only ("this address is linked to a person registered as a resident of municipality X"). Nationality-dependent needs (e.g. a passport) are deferred to separate, future, purpose-specific credential NFTs issued by whichever authority is responsible, each independently verified off-chain at issuance — not derived from this token. This avoids the legal inaccuracy in the original proposal entirely, since the token never asserts anything about nationality.
- **"Official" contract authenticity is established off-chain**, anchored to each municipality's `.lg.jp` domain (an institutionally-vetted, restricted TLD) via a well-known URI, optionally LGPKI-signed. No on-chain registry contract in v1 — it would add convenience, not trust, since the root of trust is off-chain regardless.
- **The token is non-transferable (soulbound).** Standard ERC-721 transfer/approval paths are disabled; only mint and burn exist.
- **Only the issuing municipality's admin role can mint or burn; there is no self-burn.** "Revoke" is defined as burning the token — there is no separate on-chain status field. Reasons for revocation (move, death, correction, fraud) are never recorded on-chain.
- **On-chain data is minimal**: standard ERC-721 ownership plus one additional persistent per-address flag, `everIssued`, set at mint and never cleared by burn. No timestamps, no hashes of personal data, no personalized metadata.
- **Cross-municipality deduplication** for a declared move is checked on-chain via `everIssued == true && balanceOf == 0` on the previously-declared municipality's contract (a trustless digital equivalent of a 転出証明書). Anything beyond a single declared prior municipality is assumed to be handled off-chain by an inter-municipal network among municipalities (mirroring 住基ネット/マイナンバー, or historically a paper-based equivalent) — not solved on-chain.
- **This design is explicitly a thought experiment.** No municipality currently has legal authority to issue such tokens as an official instrument of residency/nationality certification; this is not a claim of present legal operability.

## Consequences

- The citizenship/residency feature can now proceed to a concrete Solidity spec and implementation (see [`docs/state-design/citizenship/README.md`](../state-design/citizenship/README.md)) without unresolved conceptual conflicts.
- Future features that depend on nationality (e.g., a passport credential) must be designed as independent credentials with their own off-chain verification process — they cannot assume the base resident-link token implies nationality.
- Municipalities (in this hypothetical system) carry real-world operational obligations this project cannot enforce in Solidity: secure multisig key management for the admin role, and keeping on-chain burns synchronized with real-world move-out/death/correction processing.
- Deduplication guarantees are only as strong as (a) the declared-prior-municipality check this project implements on-chain, and (b) whatever off-chain inter-municipal network is assumed to exist — this project does not itself build a nationwide real-time cross-check.
- The `docs/state-design/citizenship/` directory name is kept for now (it covers the broader membership question), even though the token itself is nationality-neutral; revisit naming if it causes confusion once nationality-dependent credentials are designed.

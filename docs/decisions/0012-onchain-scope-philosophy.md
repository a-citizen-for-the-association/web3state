# 0012. On-chain scope philosophy: what this project pushes on-chain, and what it deliberately avoids

**Date:** 2026-10-10
**Status:** Accepted

## Context

Having completed the first identity/credentials layer (citizenship, corporations, six credential types) and before starting voting, the user paused to step back and ask a broader question central to the project's thesis ("if web3 existed from the start when building a modern state, how would things differ?"): beyond rights/credentials and voting, what other state functions would benefit from being on-chain, and — just as importantly — which should deliberately **not** be pushed on-chain?

The user articulated a guiding vision:
- Salaries/income should, in principle, be paid and received in stablecoin — this massively reduces tax administration overhead and makes illicit money flows (including political funding) far easier to investigate.
- To make this work, corporations and VIPs (要人, e.g. politicians) should be on-chain-registered with **open** information, while individuals get **stronger** privacy — continuing the asymmetry already established in the citizenship/corporations designs.
- Donations and social-purpose crowdfunding should be **strongly pushed** on-chain as national policy, given their strong public/social character.
- High-frequency trading and pure asset-accumulation activity have weak social character and should be **actively avoided** as something the state builds infrastructure for.
- Everyday commerce should be on-chain, for the same tax-transparency reasoning as salaries.
- Financial services whose customer base is primarily wealthy individuals (private banking, wealth management, etc.) should have their tax-compliance handled by the **service provider**, rather than being pushed onto the fully transparent on-chain rail used for ordinary income/commerce.

Claude proposed a candidate list of additional on-chain-able systems, organized by category, with a brief rationale per item; the user accepted it as a working baseline and asked for the full list of systems this project should design to be made highly visible — embedded as a single table directly in the root `README.md`, not just linked from it.

## Decision

- **On-chain scope now explicitly includes**, beyond identity/credentials/taxation/corporations already designed: political donations, VIP/politician asset disclosure, public procurement, subsidies/grants, treasury/budget spending, pension and other social-welfare payments, unemployment insurance, donations, social-purpose crowdfunding, NPO/public-interest-corporation fund management, real estate registry, vital records, public company disclosures, audit trails, notarization/contract timestamping, public court records, and everyday commerce (for tax-transparency reasons). These are tracked in [`docs/FEATURES.md`](../FEATURES.md), each 🔴 Not started, to be designed one at a time like every prior feature.
- **Everyday commerce is in scope for on-chain payment**, specifically for the same tax-transparency rationale already established for salary/income in the taxation design (ADR 0004) — not a new mechanism, an extension of the existing one.
- **Wealth-focused financial services are explicitly *not* pushed onto the same fully-transparent on-chain rail.** Where a financial service's customer base is primarily wealthy individuals, the service provider bears responsibility for tax-compliance processing on the client's behalf, rather than the individual transaction being openly visible on-chain the way ordinary commerce/income is. This is a deliberate carve-out, not an oversight.
- **High-frequency trading and personal wealth-accumulation investment vehicles are deliberately excluded** from this project's on-chain scope — tracked in `docs/FEATURES.md` with a `🚫 Deliberately excluded` status, not silently omitted, so the exclusion is visible and explained rather than looking like an oversight. Rationale: weak social/public character; no reason for the state to build or encourage infrastructure for this, unless independently justified by a different public-interest concern (e.g., VIP asset disclosure, which is about personal assets but serves an accountability purpose).
- **A single, prominent, condensed version of the full feature/system list is now embedded directly in the root `README.md`**, not merely linked — per the user's explicit request, having asked for this once before (at project scaffolding time) and finding a link insufficiently visible. `docs/FEATURES.md` remains the detailed, authoritative source (status legend, design-doc links, per-category notes); the README copy is a condensed mirror kept in sync.

## Consequences

- The project's scope has grown substantially beyond the original six credential types and basic state functions — `docs/FEATURES.md` now carries roughly 20 additional 🔴 Not-started candidate systems across 8 new categories (Governance Core beyond voting, Public Finance & Taxation, Political Transparency, Social Welfare, Public-Interest Finance, Property & Vital Records, Corporate & Market Transparency, Judicial Infrastructure, Commerce & Markets), plus a new `🚫 Deliberately excluded` category. This is a roadmap expansion, not a commitment to design all of it immediately — items are still designed one at a time, by explicit user choice of what's next.
- Two documents must now be kept in sync whenever a feature's status changes: `docs/FEATURES.md` (detailed) and the condensed table in `README.md` (prominent). This is a minor ongoing maintenance cost accepted in exchange for visibility.
- The "wealth-focused financial services: provider-handled compliance" carve-out will need its own concrete design once that category is taken up — this ADR records the *policy direction* (established now, applying project-wide), not a specific contract design (deferred, like every other 🔴 item).
- Several newly-listed items overlap conceptually with existing `docs/BACKLOG.md` entries (e.g., private insurance/loan tokenization relates to NPO/public-interest fund management; vital records relates to the deferred nationality/residence-status question) — when those are eventually designed, check `docs/BACKLOG.md` first to avoid redesigning what's already been scoped there.

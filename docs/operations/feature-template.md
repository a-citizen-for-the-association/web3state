# Feature Breakdown Template

Copy this into a feature's design doc under `docs/state-design/` and fill it in. Delete this instruction line.

```markdown
## <Feature name>

**Summary:** <one sentence: what real-world state function this covers>

**On-chain:**
- <state or logic enforced by the smart contract, e.g. "eligibility check before a vote is recorded">

**Online:**
- <logic in the web app / off-chain server, e.g. "renders proposal text and current tally">

**Offline:**
- <action a human must take outside the system, e.g. "applicant submits a notarized identity document to the registrar">

**Open questions:**
- <anything undecided about this feature>

**Related ADRs:** <links, if any>
**Related contract module(s):** <links, once they exist>
```

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

---

# 0012. オンチェーンのスコープの考え方: このプロジェクトが何をオンチェーンに載せ、何を意図して避けるか(日本語)

**日付:** 2026-10-10
**ステータス:** Accepted

## 背景

最初の本人確認・クレデンシャルの層(市民権、法人、6種類のクレデンシャル)を終え、投票に取りかかる前に、ユーザーはいったん立ち止まり、プロジェクトの中心の問い(「近代国家を作るときに最初からweb3があったら、何が違っていたか」)に関わる、より広い問いを立てた: 権利・クレデンシャルと投票のほかに、どの国家の機能がオンチェーンにすると有益か。そして同じく重要なこととして、どれを意図してオンチェーンに**載せない**べきか。

ユーザーは指針となる構想を示した:
- 給与・所得は原則としてステーブルコインで支払い、受け取るべきである。これにより税務行政の負担が大幅に減り、不正な資金の流れ(政治資金を含む)の捜査がはるかに容易になる。
- これを機能させるため、法人と要人(例: 政治家)は情報を**公開**してオンチェーンに登録し、個人はより**強い**プライバシーを得る。市民権と法人の設計ですでに確立した非対称性を引き継ぐ。
- 寄付と社会的な目的のクラウドファンディングは、公共的・社会的な性格が強いので、国の政策としてオンチェーン化を**強く推進**する。
- 高頻度取引と純粋な資産形成の活動は社会的な性格が弱く、国家が基盤を作るものとしては**積極的に避ける**。
- 日常の商取引は、給与と同じ税の透明性の理由でオンチェーンにする。
- 主な顧客が富裕層である金融サービス(プライベートバンキング、資産運用など)は、通常の所得や商取引に使う完全に透明なオンチェーンの経路に載せるのではなく、**サービス提供者**が税務の処理を担う。

Claudeは、オンチェーン化できる追加のシステムの候補リストを、区分ごとに、項目ごとの短い理由とともに提案した。ユーザーはそれを作業上の基準として受け入れた。そして、このプロジェクトが設計すべきシステムの全リストを、よく見えるようにすることを求めた。ルートの`README.md`からリンクするだけでなく、1つの表としてその中に直接載せる。

## 決定

- **オンチェーンのスコープに明示的に含める**もの(設計済みの本人確認、クレデンシャル、課税、法人のほかに): 政治献金、要人・政治家の資産公開、公共調達、補助金・助成金、国庫・予算の支出、年金その他の社会福祉の給付、雇用保険、寄付、社会的な目的のクラウドファンディング、NPO・公益法人の資金管理、不動産登記、戸籍等の身分登録、上場会社の開示、監査証跡、公証・契約のタイムスタンプ、公開の裁判記録、日常の商取引(税の透明性の理由)。これらは[`docs/FEATURES.md`](../FEATURES.md)で管理し、それぞれ🔴 未着手とする。これまでのすべての機能と同様に、1つずつ設計する。
- **日常の商取引はオンチェーンの支払いのスコープに含める。** 課税の設計(ADR 0004)で給与・所得についてすでに確立した税の透明性の理由と同じである。新しい仕組みではなく、既存の仕組みの拡張である。
- **富裕層向けの金融サービスは、同じ完全に透明なオンチェーンの経路に明示的に*載せない*。** 主な顧客が富裕層である金融サービスでは、個々の取引を通常の商取引や所得のようにオンチェーンで公開するのではなく、サービス提供者が顧客に代わって税務の処理の責任を負う。これは見落としではなく、意図した除外である。
- **高頻度取引と個人の資産形成のための投資の仕組みは、意図してこのプロジェクトのオンチェーンのスコープから除外する。** 黙って省くのではなく、`docs/FEATURES.md`で`🚫 Deliberately excluded`のステータスとして管理する。除外が見落としに見えず、見えて説明されるようにするためである。理由: 社会的・公共的な性格が弱い。別の公益上の懸念で独自に正当化されない限り(例: 要人の資産公開。個人の資産に関するものだが、説明責任の目的に資する)、国家がこのための基盤を作る、または奨励する理由はない。
- **機能・システムの全リストの、1つの目立つ要約版を、ルートの`README.md`に直接載せる。** リンクするだけではない。ユーザーの明示的な要望による。ユーザーは以前(プロジェクトの雛形作成時)にも一度これを求め、リンクでは見えにくいと感じていた。`docs/FEATURES.md`は詳細で正式な情報源のまま(ステータスの凡例、設計書へのリンク、区分ごとの注記)。READMEの写しは同期を保つ要約である。

## 結果

- プロジェクトのスコープは、最初の6種類のクレデンシャルと基本的な国家の機能を大きく超えて広がった。`docs/FEATURES.md`には、8つの新しい区分(投票以外の統治の中核、公共財政と課税、政治の透明性、社会福祉、公益の金融、財産と身分の記録、法人と市場の透明性、司法の基盤、商取引と市場)にわたる約20の追加の🔴 未着手の候補システムと、新しい`🚫 Deliberately excluded`の区分がある。これはロードマップの拡大であり、すべてをすぐに設計する約束ではない。項目は引き続き、次に何をするかのユーザーの明示的な選択により、1つずつ設計する。
- 機能のステータスが変わるたびに、2つの文書の同期を保つ必要がある: `docs/FEATURES.md`(詳細)と`README.md`の要約の表(目立つもの)。見やすさと引き換えに受け入れた、小さな継続的な保守のコストである。
- 「富裕層向けの金融サービス: 提供者が担う税務処理」という除外は、その区分を取り上げるときに独自の具体的な設計が要る。このADRが記録するのは、今確立してプロジェクト全体に適用する*方針の方向*であり、具体的なコントラクトの設計ではない(他のすべての🔴の項目と同様に先送り)。
- 新たに挙げた項目のいくつかは、既存の`docs/BACKLOG.md`の項目と概念的に重なる(例: 民間の保険・ローンのトークン化はNPO・公益法人の資金管理に関係し、身分登録は保留中の国籍・在留資格の問題に関係する)。それらを設計するときは、すでにそこでスコープを定めたものを設計し直さないよう、まず`docs/BACKLOG.md`を確認する。

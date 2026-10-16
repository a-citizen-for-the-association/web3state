# 0018. Judiciary: evidence and case-record anchoring, address identification for enforcement, token-juror arbitration excluded

**Date:** 2026-10-17
**Status:** Accepted

## Context

The judiciary was screened with the on-chain value test ([ADR 0014](0014-legislative-process-scope.md)). Three sub-parts passed:

- **Evidence:** a prosecutor altered seized data (Osaka, 2010); the Hakamada retrial acquittal (2024) found evidence fabricated by investigators; the defence cannot see what was seized.
- **Case records:** courts were found (2022) to have discarded records that should have been specially preserved.
- **Enforcement:** judgments often go unpaid because debtors hide assets.

Filing and procedure (already being digitalised), deliberation (institutional), and criminal records (privacy) did not pass. The Judicial Infrastructure item "judgment publication" overlapped with case records. On-chain token-juror arbitration (e.g. Kleros) was raised as a policy question ([log](../state-design/judiciary/discussion-log.md)).

## Decision

- **Evidence:** each investigating body keeps an append-only `EvidenceRegistry` (the executive `DocumentRegistry` pattern, [ADR 0017](0017-executive-document-anchoring-v1.md)), registering each item at seizure with an opaque case reference, a rule-based abbreviated description, and a hash. Item types are physical (photo hash), data, and interrogation recordings. The case-reference mapping is disclosed to the court and the defence at indictment.
- **Case records:** each court keeps a `CaseRecordRegistry` with retention classes. Disposal must be registered, and is rejected for special-preservation and permanent records unless the class is first lowered in a public event. Judgments are registered here, which absorbs "judgment publication". Notarization stays its own item.
- **Enforcement: option (b).** No new contract and no court role in the stablecoin. Under a court order, the municipality discloses the debtor's `ResidentLink` address to the court and the creditor. Assets and flows are traced on-chain, and seizure is ordered and carried out off-chain.
- **Excluded (🚫):** filing/procedure, deliberation, criminal records, and token-juror arbitration with official force. A state-run escrow dispute flow is moved to the everyday-commerce item.

## Consequences

- Alteration of seized evidence after seizure, undisclosed evidence, and silent destruction of preserved records become detectable. Fabrication before seizure, and loss of record content, are not addressed (content preservation goes to the backlog).
- The `DocumentRegistry` pattern now serves three domains (executive, evidence, court records). It is a candidate for one shared implementation.
- Enforcement adds an off-chain disclosure procedure but no on-chain power over wallets. Assets held off-chain are out of reach.
- The `.go.jp`/`.lg.jp` attestation pattern covers police, prosecutors and courts; no `OfficialContractRegistry` entry is needed until an automated consumer appears.

---

# 0018. 司法: 証拠と事件記録のアンカリング、執行のためのアドレス特定、トークン陪審員による仲裁は対象外(日本語)

**日付:** 2026-10-17
**ステータス:** Accepted

## 背景

司法をオンチェーン価値テスト([ADR 0014](0014-legislative-process-scope.md))で選別した。3つの部分が通過した。

- **証拠:** 検事が押収したデータを改ざんした(大阪、2010年)。袴田事件の再審無罪判決(2024年)は捜査機関による証拠の捏造を認定した。弁護側は何が押収されたかを見られない。
- **事件記録:** 特別保存すべき記録を裁判所が廃棄していたことが判明した(2022年)。
- **執行:** 債務者の資産隠しのため、判決が支払われないことが多い。

訴訟手続(すでにIT化が進行中)、審理(制度の問題)、前科の記録(プライバシー)は通過しなかった。司法インフラの項目「判決等の公開」は事件記録と重複していた。オンチェーンのトークン陪審員による仲裁(Klerosなど)は方針の問題として提起された([ログ](../state-design/judiciary/discussion-log.md))。

## 決定

- **証拠:** 各捜査機関は、追記専用の`EvidenceRegistry`(行政の`DocumentRegistry`の仕組み、[ADR 0017](0017-executive-document-anchoring-v1.md))を持つ。押収の時点で、各証拠を秘匿化した事件参照、ルールに基づく略称の説明、ハッシュとともに登録する。証拠の種類は、物(写真のハッシュ)、データ、取調べの録音・録画である。事件参照の対応関係は、起訴の時点で裁判所と弁護側に開示する。
- **事件記録:** 各裁判所は、保存区分を持つ`CaseRecordRegistry`を持つ。廃棄は登録しなければならず、特別保存と永久保存の記録については、公開のイベントでまず区分を下げない限り拒否する。判決もここに登録し、「判決等の公開」を吸収する。公証は独立した項目のままとする。
- **執行: 選択肢(b)。** 新しいコントラクトは作らず、ステーブルコインに裁判所の権限も持たせない。裁判所の命令に基づき、自治体が債務者の`ResidentLink`アドレスを裁判所と債権者に開示する。資産と資金の流れはオンチェーンでたどり、差押えはオフチェーンで命じて実行する。
- **対象外(🚫):** 訴訟手続、審理、前科の記録、トークン陪審員による仲裁に公的な効力を与えること。国が運営するエスクローの紛争処理は、日常の商取引の項目に移す。

## 結果

- 押収後の証拠の改ざん、開示されていない証拠、保存すべき記録の黙った破棄が検出できるようになる。押収前の捏造と、記録の中身の喪失は扱わない(中身の保存はBACKLOGへ)。
- `DocumentRegistry`の仕組みは3つの領域(行政、証拠、裁判記録)で使われるようになった。1つの共通実装にまとめる候補である。
- 執行にはオフチェーンの開示手続きが加わるが、ウォレットに対するオンチェーンの権限は生まれない。オフチェーンで保有する資産には届かない。
- `.go.jp`/`.lg.jp`の証明の仕組みは警察、検察、裁判所にも及ぶ。自動の利用者が現れるまで、`OfficialContractRegistry`への登録は必要ない。

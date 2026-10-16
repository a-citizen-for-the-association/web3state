# 0016. Direct-demand petition model: per-demand contract, explicit eligible list, public signatures, count certification only

**Date:** 2026-10-17
**Status:** Accepted

## Context

[ADR 0014](0014-legislative-process-scope.md) carved direct-demand petition signatures (直接請求の署名) out of the excluded legislative process. They passed every question of the on-chain value test: in the 2020 Aichi recall campaign, about 362,000 of about 435,000 submitted signatures were suspected invalid, written in by hired workers. Under today's system, signatures are handwritten on paper and gathered by delegated collectors (受任者). Nobody verifies the signer's identity at the moment of signing. The election board checks each signature against the voter roll by hand, and the roll is put on public inspection (縦覧) so that forgeries can be challenged. The post-scandal fix only added a collector-name field to the form.

Key forces from the discussion ([log](../state-design/direct-demand/discussion-log.md)):

- `ResidentLink` is nationality-neutral ([ADR 0003](0003-resident-link-identity-model.md)), but only registered voters may sign.
- Signers must be bound to an exact text that cannot change after they sign.
- A look-alike contract can be deployed by anyone.
- The election board needs to handle elections that interrupt the collection period, and residents who move during it, without being able to move the goalposts.

## Decision

- **One `Petition` contract per demand**, deployed by the election board from a common `PetitionFactory` after an off-chain application. One generic contract covers all six demand types, with the type as a parameter.
- **Eligibility is an explicit on-chain list per petition**, built by the board from off-chain resident data. Each listed address must also hold a token from a `ResidentLink` contract allowlisted in `OfficialContractRegistry` ([ADR 0015](0015-political-donations-model.md)). No standing voter-roll contract is created.
- **Fixed at deployment:** a hash of the full text and summary, the denominator and the threshold, and the collection period.
- **The board can only** edit the list and pause/resume. Paused time extends the end automatically. If the board removes an address that has already signed, that signature drops out of the count. The board cannot change the text hash, the threshold or the end date, and cannot delete signatures. Every action emits an event.
- **Signatures are public by address**, made by residents themselves from their `ResidentLink` address. There are no collectors and no withdrawal.
- **The contract only certifies the count.** At the effective end, everything freezes. The formal demand, any resulting vote, objections, and relief for coerced signers are all off-chain.
- **Authenticity is checked off-chain** via the board's `.lg.jp` publication. Paper channels and gas fees are out of scope for this thought experiment.

## Consequences

- The collector role disappears, and with it the forgery route used in the Aichi case. Manual checking against the voter roll is replaced by a count computed by the contract.
- This is the first *public, non-secret* participation record in the project, the counterpart of voting's secret ballots. Coercion ("prove you signed / didn't") becomes verifiable. That risk is accepted, and relief is left off-chain.
- Each listed address publicly signals "Japanese national, 18+". Voting already does the same per election, so no new kind of disclosure is introduced, but a full eligible list is now published per petition.
- The board's power over the list is a real trust point. It is checked by full on-chain visibility, not prevented.
- `OfficialContractRegistry` gains its second consumer, confirming it as shared infrastructure.
- The collection period is a third justified on-chain date exception, alongside the voting period and the donation year.
- Follow-up: the large-list cost issue joins voting's existing backlog item (Merkle-root alternative).

---

# 0016. 直接請求の署名モデル: 請求ごとのコントラクト、明示的な有資格一覧、公開署名、署名数の証明のみ(日本語)

**日付:** 2026-10-17
**ステータス:** Accepted

## 背景

[ADR 0014](0014-legislative-process-scope.md)は、対象外とした立法プロセスから直接請求の署名を切り出した。この項目はオンチェーン価値テストのすべての問いを満たした。2020年の愛知県リコール運動では、提出された約43万5千筆のうち約36万2千筆に不正の疑いがあり、雇われた作業者が書き込んでいた。現行制度では、署名は紙に自署し、委任された受任者が集める。署名した時点で署名者の本人確認を行う人はいない。選管は選挙人名簿と手作業で照合し、偽造に異議を申し立てられるよう署名簿を縦覧に供する。事件後の対策は、署名簿に収集者の氏名欄を加えたことにとどまる。

議論([ログ](../state-design/direct-demand/discussion-log.md))で明らかになった主な制約:

- `ResidentLink`は国籍を問わない([ADR 0003](0003-resident-link-identity-model.md))が、署名できるのは有権者だけである。
- 署名者は、署名後に変えられない正確な文面に結びつけられなければならない。
- よく似たコントラクトは誰でもデプロイできる。
- 選管は、収集期間を中断する選挙や期間中の転居に対応する必要があるが、達成条件を動かせてはならない。

## 決定

- **請求ごとに1つの`Petition`コントラクト**を置く。オフチェーンでの申し出の後、選管が共通の`PetitionFactory`からデプロイする。1つの汎用コントラクトで6種類の請求をすべて扱い、種類はパラメータにする。
- **資格は請求ごとのオンチェーンの明示的な一覧とする。** 選管がオフチェーンの住民データから作る。一覧に載る各アドレスは、`OfficialContractRegistry`([ADR 0015](0015-political-donations-model.md))の許可リストにある`ResidentLink`コントラクトのトークンも持たなければならない。常設の選挙人名簿コントラクトは作らない。
- **デプロイ時に固定するもの:** 全文と要旨のハッシュ、分母と必要数、収集期間。
- **選管にできるのは**、一覧の編集と一時停止・再開だけである。一時停止した時間は自動で終了に加算する。すでに署名したアドレスを選管が一覧から外すと、その署名は数から外れる。選管は全文ハッシュ・必要数・終了日を変えられず、署名も削除できない。すべての操作はイベントとして記録する。
- **署名はアドレス単位で公開する。** 住民が自分の`ResidentLink`アドレスから自分で署名する。受任者はおらず、撤回もできない。
- **コントラクトは署名数の証明だけを行う。** 実効的な終了時点ですべてを凍結する。本請求、その後の投票、異議申し立て、圧力で署名させられた人の救済は、すべてオフチェーンで扱う。
- **本物かどうかはオフチェーンで確認する**(選管の`.lg.jp`での公表)。紙の窓口とガス代は、この思考実験では対象外とする。

## 結果

- 受任者という役割がなくなり、愛知の事件で使われた偽造の経路もなくなる。選挙人名簿との手作業の照合は、コントラクトが計算する署名数に置き換わる。
- プロジェクトで初めての*公開の、秘密ではない*参加記録になる。投票の秘密投票と対になるものである。圧力(「署名した/しなかったことを証明しろ」)が検証可能になる。このリスクは受け入れ、救済はオフチェーンに委ねる。
- 一覧に載った各アドレスは「18歳以上の日本国籍者」であることを公に示す。投票も選挙ごとに同じことをしているので新しい種類の開示ではないが、請求ごとに有資格一覧の全体が公開されるようになる。
- 一覧に対する選管の権限は、現実の信頼点である。防ぐのではなく、オンチェーンですべてが見えることで歯止めをかける。
- `OfficialContractRegistry`は2つ目の利用者を得て、共有基盤として定着する。
- 収集期間は、投票期間と献金の年に続く、3つ目の正当化されたオンチェーンの日付の例外になる。
- 今後の課題: 大きな一覧のコストの問題は、投票の既存のBACKLOG項目(Merkle rootによる代替)に合流する。

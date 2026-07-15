---
name: mino-interface-implementation-separation
description: 利用者が知る目的・操作・契約と内部の技術・手順を分離し、長大処理の技術漏出、caller側分岐、誤った責務境界を監査・設計するときに使う。単なるif削減、interface型量産、system全体のarchitecture選定には使わない。
---

# Interface / Implementation Separation

consumerが知る意味と、知らなくてよい実現方法を分ける。成果はinterface数ではなく、契約、技術漏出、変更局所性で判定する。

## Outcome Contract

主成果物として`Boundary Package`を作る。通常は次の最小構成を返し、operation semanticsの詳細schemaはworkflow referenceへ置く。

- consumer、purpose、operationのinput / result / failure / side effect / contract
- interface partとimplementation partの責務
- leakage、dependency direction、boundary-localなcontract / state authority
- consistency boundaryと、結果を分岐させるoperation semanticsだけのapplicability判定
- applicableなdeadline、retry、idempotency、duplicate、ambiguous outcomeのpolicy / owner
- Evidenceのあるchange scenario、過剰抽象化の棄却、既存caller向けcompatibility / migration
- `subject_verdict: separated | leaky | overabstracted | not_applicable | indeterminate`とcanonical `decision`
- platform差が公開境界へ漏れ得る場合だけ、Platform ContextとWindows / Linux / macOS adapter validation

非該当semanticsの詳細recordを空欄埋めのために展開しない。理由とEvidence、またはunknownの確認方法と影響を残す。

## Reference Routing

- 内部pathは、配置先にかかわらず、インストールされた`skills/` directoryを参照rootとして解決する。
- 最初に`skills/mino-core/references/core.md`、`skills/mino-core/references/shared-policies.md`、`skills/mino-core/references/requirements-and-traceability.md`、`skills/mino-core/references/code-design.md`を読み、共通gateを再定義しない。
- 境界分析、operation semantics、change scenarioでは`skills/mino-interface-implementation-separation/references/workflow.md`を読む。
- applicableなdomain conceptまたはcontractが欠け、このSkillだけではconsumer contractを安全に定義できないstandalone依頼では`$mino-domain-model-completeness`と`$mino-design-by-contract`を先に使う。
- 既存callerを段階移行する場合は`skills/mino-core/references/change-safety.md`を読む。
- filesystem、process、shell、path等のOS差がboundaryへ関係するときだけ`skills/mino-core/references/platform-compatibility.md`を読む。
- standalone依頼でsystem-wide trade-off、data ownership、target / transition decisionが必要になった場合は`$mino-architecture-quality-strategy`へscope escalationする。実装や複数成果物まで求める場合は`$mino-reproducible-development`へ一度hand offする。
- routerまたはpeer Skillからscoped artifactを依頼された場合は再routingせず、Boundary Packageと未解決obligationだけをcallerへ返す。
- operation semantics applicability、stable trace、Change Safety schemaはsuite operationalizationとして扱う。

## Authority Boundary

- このSkillが所有するのは、consumer purpose、operationの意味契約、技術漏出、boundary内の責務である。
- system-wideなvalue、quality portfolio、data authority、target / transition decisionを二重に確定しない。Architecture Strategy PackageがあればIDを参照し、なければ上位decision obligationとして返す。
- condition単位のauthoritative enforcementはContract Packageを参照し、このSkillではconsumerへ見せる意味と責務配置だけを確定する。

## Workflow

1. consumer、purpose、success、既存contract、優先品質を確認し、Evidence状態とdecision maturityを記録する。
2. 処理をdomain decision、orchestration、persistence、external I/O、representation、policy、operationへ分類する。
3. purpose-centered capsule、branch meaning、name、abstraction根拠を評価する。
4. consumerが必要とする最小の意味をinterface partへ置く。
5. deadline、retry、idempotency、duplicate、ambiguous outcomeを独立にscreeningし、結果を分岐させるapplicableなsemanticsだけを契約へ具体化する。
6. framework、DB、HTTP、SDK、algorithm、OS固有path / process / shell、per-attempt transport timeout / backoffをimplementation partへ隔離する。
7. ambiguous outcome、reconciliation、forward recoveryの責務と、boundary-localなownerをEvidence付きで記録する。
8. Evidenceのあるchange scenarioで境界を検証し、既存利用者がある場合は小さい互換stepと旧path削除条件を設計する。

## Platform Compatibility

- consumerがOS差を必要としない限り、separator、shell command、platform固有型をinterface partへ公開しない。
- Windows、Linux、macOS用のadapterは同じpurpose、operation、failure、side effectと、applicableなsemanticsを実装する。
- 実在するplatform variant要件またはEvidenceがない場合、将来用のOS abstractionを追加しない。

## Hard Gates

以下のいずれかに該当する場合は`subject_verdict: separated`にせず、leakage、unknown、棄却理由を返す。

- interface型を作ること、ifを減らすこと、patternを導入することが目的になっている。
- 一実装でvariant根拠がないのにfactoryやStrategy階層を作っている。
- 外部障害境界や安定契約のためのportに品質根拠がなく、consumer目的より広い抽象を公開している。
- provider固有のtransport手順をconsumerへ漏らす、またはretry可否、duplicate semantics、ambiguous outcomeをimplementation detailとして隠している。
- deadline、retry、idempotency、duplicate、ambiguous outcomeを互いから推定し、unknownをN/Aまたは空欄へ丸めている。
- pure functionやread-only operationへschema充足のためのidempotency key、deduplication、mutation retryを作る、またはdeterministicな同一入力同一出力とmutation idempotencyを混同している。
- add / change variant scenarioにEvidenceがないのにselection boundaryを作り、`not_applicable`理由を残していない。
- state transitionをvariant abstractionへ逃がしている。
- 一部platform実装だけを検証してplatform-neutral boundaryと判定している。
- public contract変更、service分割、data移動を自動実行している。
- applicableなdomain contractまたはconsumer semantic operation contractのどちらもない。domain contract非適用なら理由とEvidenceがない。

## Completion

- interface partがpurpose、failure、side effectと、applicableなsemanticsを表す。非該当には理由とEvidence、unknownには確認方法と影響がある。
- operation、implementation part、leakage finding、change scenario、migrationがstable IDでtraceされる。
- implementation型、provider固有手順、transport retry機構がconsumerへ漏れず、semantic policyのownerは契約に残る。
- boundary-localなsemantic / invariant reference、contract / state authority、failure / recovery / operational ownerと、上位Architecture / Contract成果物との関係が参照またはobligationとして明示される。
- Evidenceのあるvariantだけselection boundaryを持ち、change scenarioと`not_applicable`理由を再判定できる。
- 複数platform対応がrequiredなら、Windows / Linux / macOS adapterが同じconsumer contractを満たすEvidenceまたは未実行事項がある。
- 既存callerまたは公開契約を変える場合はChange Safetyとtemporary path削除契約を同じpackageに保持する。
- `subject_verdict`、unknown、未実行検証、overdesign棄却をcanonical readinessと分離する。

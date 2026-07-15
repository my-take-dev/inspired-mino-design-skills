# Interface / Implementation Separation workflow

## Contents

- Inputs
- Concern and code-design audit
- Boundary design
- Leakage audit
- Change scenarios
- Migration
- Output contract

## Inputs

- Core result、routing context、mode、requested artifact、caller / return target
- Requirement Catalog、quality scenarios
- consumer、use case、public API
- current method / service / module / adapter
- applicableなdomain model / contract、またはgeneric技術boundaryのconsumer semantic operation contract、dependency graph
- Evidenceのあるvariant、technology replacement、migration constraints

peer Functionまたはintegrated routerからscoped Boundary Packageを依頼された場合は、そのartifactだけをcallerへ返し、入力中のsystem-wide concernを理由に再routingしない。standaloneでscope自体がsystem decisionへ広がる場合だけArchitectureへescalationする。

## Concern and code-design audit

処理stepを、同じ目的で一緒に変わるものと異なる理由で変わるものへ分類する。

| Concern | Examples |
|---|---|
| Domain decision | eligibility、price、state transition |
| Use-case orchestration | load、decide、save、notify |
| Persistence | SQL、ORM、transaction |
| External communication | HTTP、queue、filesystem |
| Representation | DTO、JSON、view model |
| Policy / strategy | payment、shipping、authorization |
| Operation semantics | end-to-end deadline、retry可否、idempotency、duplicate / ambiguous outcome |
| Transport implementation | per-attempt timeout、backoff、provider SDK retry |
| Operational concern | reconciliation、forward recovery、logging、metrics |

`skills/mino-core/references/code-design.md`に従い、次も判定する。

- purpose-centered capsuleと公開operation
- branchがguard、state、rule、variant、temporary flagのどれか
- nameがpurposeとout-of-scopeを表すか
- abstractionが同じpurpose、contract、change reasonを持つか

## Boundary design

### 1. Define consumer and purpose

```yaml
consumer:
  id: C1
  purpose: ""
  must_know: []
  must_not_know: []
```

一つのinterfaceに複数consumer purposeを混ぜない。

domain ruleがapplicableならauthoritativeなdomain / contract artifactを参照する。generic技術boundaryでdomain conceptがない場合は、domain contractを捏造せず、次を記録してconsumer semantic operation contractを正とする。

```yaml
contract_source:
  kind: domain_contract | consumer_semantic_operation | unknown
  artifact_refs: []
  domain_contract_status: applicable | not_applicable | unknown
  not_applicable_reason: ""
  confirmation_method: ""
  impact_if_unresolved: ""
  evidence:
    - status: confirmed | inferred | assumption | unknown | contradiction
      source: ""
      supports: ""
```

### 2. Define interface part

operationごとに次を定義する。

```yaml
operation:
  id: OP1
  name: ""
  intent: ""
  inputs: []
  result: ""
  failures: []
  side_effects: []
  invariants: []
  contracts: []
  end_to_end_deadline:
    status: applicable | not_applicable | unknown
    limit_or_condition: ""
    owner: ""
    timeout_result: ""
    not_applicable_reason: ""
    confirmation_method: ""
    impact_if_unresolved: ""
    evidence: []
  retry_semantics:
    status: applicable | not_applicable | unknown
    allowed_when: []
    prohibited_when: []
    owner: ""
    not_applicable_reason: ""
    confirmation_method: ""
    impact_if_unresolved: ""
    evidence: []
  idempotency:
    status: applicable | not_applicable | unknown
    key_scope: ""
    duplicate_result: ""
    owner: ""
    not_applicable_reason: ""
    confirmation_method: ""
    impact_if_unresolved: ""
    evidence: []
  duplicate_semantics:
    status: applicable | not_applicable | unknown
    duplicate_result_or_reason: ""
    owner: ""
    not_applicable_reason: ""
    confirmation_method: ""
    impact_if_unresolved: ""
    evidence: []
  ambiguous_outcome:
    status: applicable | not_applicable | unknown
    observable_result: ""
    reconciliation_owner: ""
    forward_recovery_owner: ""
    not_applicable_reason: ""
    confirmation_method: ""
    impact_if_unresolved: ""
    evidence: []
  consistency_boundary: ""
  evidence: []
```

避けるもの:

- framework request / response、DB row、ORM entity、SDK型
- internal transaction、provider固有retry / serialization手順
- 実装により意味がないoperation
- callerへ実装固有flagや選択順を要求すること

### 3. Define implementation part

DB、HTTP、queue、SDK、algorithm、cache、batching、serialization、observability、resource lifecycleをimplementationへ置く。retry / timeoutは一括して隠さず、次へ分類する。

```yaml
transport_implementation:
  id: TI1
  operation_id: OP1
  provider_or_protocol: ""
  per_attempt_timeout: ""
  backoff: ""
  transport_retry_mechanism: ""
  bounded_by_contract: []
  owner: ""
  evidence: []
```

deadline、retry、idempotency、duplicate、ambiguous outcomeは別々に適用性を判定する。duplicate semanticsをidempotencyのmechanism有無から推定せず、各`unknown`には確認方法、未解決時の影響、Evidenceを残す。

- per-attempt transport timeout、backoff、provider SDK retry機構は、operation contractが許す範囲のimplementation detailとする。
- end-to-end deadline、retry可否、idempotency key scope、duplicate resultはoperation contractへ置く。
- success / failureが確定できないambiguous outcome、reconciliation、forward recoveryはuse caseまたはoperational ownerへ置く。
- adapterがsemantic retry可否やrecovery方針を独断で決めない。

domain ruleをadapterへ埋めず、semantic / invariant / contract ownerへ戻す。

### 4. Set dependency and authority

```text
consumer / use case
        ↓ owns
purpose-oriented contract
        ↑ implements
implementation adapter
```

contract owner、state authority、source of truth、writer / readerに加え、semantic / invariant ownerのauthoritative artifact reference、failure / recovery owner、operational ownerを明示する。Boundary Packageは参照先のdomain ruleやsystem-wide authorityを複製しない。

```yaml
authority_reference:
  id: AR1
  kind: semantic_owner | invariant_owner | contract_owner | state_authority | source_of_truth | failure_recovery_owner | operational_owner
  applicability: required | not_applicable | unknown
  artifact_ref: ""
  owner: ""
  rationale: ""
  evidence:
    status: confirmed | inferred | assumption | unknown | contradiction
    sources: []
```

`required`は解決可能なartifact refまたはownerを持つ。generic boundary等で非該当なら理由とEvidenceを持つ。結果を分岐させる`unknown`を空欄やN/Aへ丸めない。

Evidenceのあるproven variantが存在する場合だけselection boundaryを作る。

```yaml
selection_boundary:
  id: SB1
  operation_ids: []
  owner: ""
  location: ""
  selection_rule: ""
  proven_variant_evidence: []
```

variant根拠がなければselection boundaryを作らず、add / change variant scenarioへ`not_applicable`理由を残す。

## Leakage audit

- operation名が技術手順を表す
- input / output / failureがframework、storage、SDK型
- callerがprovider固有の実装順、transport retry / transaction手順を知る
- adapterがretry可否、duplicate semantics、ambiguous outcome、recovery方針を隠れて決める
- caller側にvariant switchが残る
- unrelated operationが一つに集まる
- adapter内へdomain decisionが漏れる
- 一実装しかなくpurpose / quality根拠もない抽象がある
- interface外のsetterやdirect writeがcontractを迂回する

semantic retry policyがinterface partに見えること自体は漏出ではない。漏出かどうかは、consumerが正しい判断に必要な意味か、provider固有手順かで判定する。

## Change scenarios

scenarioごとに`pass | fail | not_applicable | unknown`とEvidenceを残す。

1. **Replace implementation**: 外部技術またはalgorithmを変更してもconsumer contractとcontract testが不変か。技術boundaryがない場合はnot_applicable。
2. **Add proven variant**: roadmap、既存variant、change historyの根拠がある場合だけ、既存consumerの業務codeを変えず追加できるか。
3. **Change one proven variant**: 一つのvariantだけの変更が他へ波及しないか。
4. **Change one business rule**: rule owner内で変更が完結し、adapterや無関係consumerへ波及しないか。

一実装しかなくvariant根拠がない場合、2と3を満たす構造を先回りして作らない。外部障害境界やcontract isolationの根拠があれば、一実装の小さなportは許す。

## Migration

- 現契約と新契約の差を明示する。
- adapter、facade、stranglerで一consumer pathずつ移す。
- temporary pathへowner、導入日、目的、metric/log、削除条件、削除予定phaseを付ける。
- public contract changeにはconsumer inventory、compatibility window、rollback / recoveryを付ける。
- 旧path利用ゼロを確認してから削除する。

design / review modeではplanまたはfindingだけを返す。implementation modeかつ権限がある場合だけ移行stepを実行する。

## Output contract

```yaml
boundary_package:
  id: BP1
  subject: ""
  owner: ""
  platform_context: {}
  platform_validation: {}
  change_safety:
    applicability: required | not_applicable | unknown
    package: {}
    not_applicable_reason: ""
    confirmation_method: ""
    impact_if_unresolved: ""
    evidence: []
  contract_source: {}
  consumers: []
  code_design:
    capsules: []
    branch_decisions: []
    naming_decisions: []
    abstraction_decisions: []
  interface_part:
    operations: []
  implementation_part:
    items:
      - id: IP1
        kind: hidden_technology | algorithm | data_access | operational_concern | platform_adapter
        operation_ids: []
        description: ""
        owner: ""
        evidence: []
    transport_implementations: []
  ownership:
    authority_refs: []
    writers: []
    readers: []
  selection_boundaries: []
  leakage_findings:
    - id: LF1
      operation_ids: []
      implementation_part_ids: []
      status: present | absent | unknown
      impact: ""
      evidence: []
  dependency_direction: []
  change_scenarios:
    - id: CS1
      name: ""
      status: pass | fail | not_applicable | unknown
      evidence: []
      rationale: ""
  migration:
    - id: M1
      contract_ids: []
      consumer_ids: []
      compatibility_window: ""
      steps: []
      rollback_or_recovery: []
      temporary_path_ids: []
      evidence: []
  boundary_traces:
    - id: BT1
      requirement_ids: []
      consumer_ids: []
      operation_ids: []
      contract_ids: []
      ownership_refs: []
      implementation_part_ids: []
      leakage_finding_ids: []
      change_scenario_ids: []
      migration_ids: []
      verification_ids: []
      status: covered | partial | missing | contradictory
      evidence: []
  subject_verdict: separated | leaky | overabstracted | not_applicable | indeterminate
  decision: {}
```

`subject_verdict`は境界対象を判定する。意味と実装が分離されれば`separated`、技術・手順・誤責務が漏れれば`leaky`、根拠のない抽象があれば`overabstracted`、このFunction自体が不要なら`not_applicable`、重要Evidence不足なら`indeterminate`とする。

`decision`は依頼されたBoundary Packageの完成状態を表すcanonical schemaであり、subject verdictと混同しない。空文字、空配列、見出しの存在だけでは充足Evidenceにならない。operation、ownership、leakage、change scenario、migration、traceの主張は、解決可能なID、owner、Evidence状態とsource、または根拠のある`not_applicable`理由を持つ。既存callerまたは公開契約を変える場合は`change_safety.package`を省略せず、migrationの`temporary_path_ids`からcanonical Change Safetyのowner、導入日、目的、観測、削除条件、削除phaseへ解決する。

## Rejection conditions

- consumerとpurposeが不明
- applicableなdomain contractとconsumer semantic operation contractのどちらも未定義
- domain contractを`not_applicable`としたgeneric技術boundaryに、理由またはEvidenceがない
- requiredなownerまたはauthorityが不明なのに`subject_verdict: separated`とする
- interface作成やif削減が目的化
- 技術型、provider固有手順、transport retry機構が公開される
- applicableなend-to-end deadline、retry可否、idempotency、duplicate semanticsがoperation contractから欠落する、または非適用理由にEvidenceがない
- applicableなambiguous outcome、reconciliation、forward recoveryのuse case / operational ownerが不明、または非適用理由にEvidenceがない
- 根拠のない将来variantのため抽象化する
- proven variantがないのにselection boundaryを作る
- applicableなchange scenarioを通さず疎結合と断定
- public contract changeにmigration / recoveryがない
- peer / integratedからのscoped依頼に対し、system-wide concernを理由に再routingする

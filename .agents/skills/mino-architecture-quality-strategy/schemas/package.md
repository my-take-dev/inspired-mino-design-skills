# 保存用schema

依頼された正本packageを作る場合だけ読む。既存artifactはhandleとrevisionで参照再利用する。未知は空欄で隠さず、非該当には理由を残す。

## Contents

- decision_frame
- quality_portfolio
- option
- target_decision
- transition_phase
- validation_item
- architecture_trace

## decision_frame

```yaml
decision_frame:
  question: ""
  owner: ""
  approvers: []
  decision_maturity: {}
  actors: []
  product_values: []
  in_scope: []
  out_of_scope: []
  horizon: ""
  target_platforms: []
  reversibility: reversible | costly | irreversible | unknown
  constraints: []
capability:
  id: CAP1
  name: ""
  kind: business_capability | subdomain | technical_capability | unknown
  classification: core | supporting | generic | not_applicable | unknown
  classification_rationale: ""
  actor_ids: []
  value_ids: []
  differentiation: ""
  unique_knowledge: ""
  expected_change: high | medium | low | unknown
  failure_risk: high | medium | low | unknown
  owner: ""
  evidence: []
  domain_frame: {}
  investment: {}
```

## quality_portfolio

```yaml
quality_portfolio:
  quality_catalog_ref: ""
  items:
    - id: QA1
      quality_definition_id: QL1
      quality: {}
      priority: primary | secondary | constraint | intentionally_not_optimized | unknown
      value_ids: []
      rationale: ""
      owner: ""
      evidence: []
      reevaluate_when: []
quality_scenario:
  id: Q1
  quality_item_id: QA1
  stimulus: ""
  artifact: ""
  environment: ""
  expected_response: ""
  oracle: ""
  owner: ""
  evidence: []
  measurement_plan: ""
```

## option

```yaml
option:
  id: O1
  kind: do_nothing | do_minimum | incremental | other
  summary: ""
  owner: ""
  addresses_finding_ids: []
  improves_quality_scenario_ids: []
  degrades_quality_scenario_ids: []
  scope: []
  system_effects: {}
  costs: []
  risks: []
  reversibility: reversible | costly | irreversible | unknown
  evidence: []
  assumption_ids: []
  unknown_ids: []
  validation_ids: []
```

## target_decision

```yaml
target_decision:
  id: T1
  kind: responsibility | dependency | contract | data_authority | runtime_failure | deploy_observability | security
  statement: ""
  owner: ""
  option_id: O1
  affected_capability_ids: []
  quality_scenario_ids: []
  source_of_truth: ""
  state_or_transition_authority: ""
  boundary_artifact_refs: []
  rationale: ""
  evidence: []
  assumption_ids: []
  unknown_ids: []
  selection_gate_ids: []
adr:
  title: ""
  lifecycle_status: current | superseded | rejected | unknown
  decision_maturity: {}
  context: ""
  decision: ""
  value_and_quality_rationale: []
  options_considered: []
  tradeoff_decisions: []
  counterevidence: []
  assumption_ids: []
  unknown_ids: []
  consequences: []
  owner: ""
  approvers: []
  reevaluate_when: []
```

## transition_phase

```yaml
transition_phase:
  id: TP1
  name: ""
  owner: ""
  from_state: ""
  to_state: ""
  target_decision_ids: []
  changes: []
  deploy_order: []
  compatibility: []
  migration:
    backfill: []
    dual_read_write: []
    reconciliation: []
    conflict_rule: ""
  observation_window: ""
  exit_criteria: []
  irreversible_point:
    exists: true | false | unknown
    description: ""
    approval:
      status: required | not_required | unknown
      owner: ""
      evidence: []
  abort_conditions: []
  rollback_or_forward_recovery:
    strategy: rollback | forward_recovery | both | unknown
    steps: []
    owner: ""
  temporary_paths: []
  old_path_removal: {}
  validation_ids: []
  evidence: []
```

## validation_item

```yaml
validation_item:
  id: VAL1
  quality_scenario_ids: []
  target_decision_ids: []
  transition_phase_ids: []
  kind: change_simulation | contract_dependency_test | failure_injection | load_latency | security_review | migration_rehearsal | operation_review
  oracle: ""
  owner: ""
  execution_conditions: []
  required_platforms: []
  status: planned | executed_pass | executed_fail
  executed_at: ""
  result: ""
  evidence: []
  counterevidence: []
architecture_strategy_package:
  decision_frame: {}
  capabilities: []
  quality_portfolio: {}
  quality_scenarios: []
  current_findings: []
  options: []
  adr: {}
  target_architecture:
    decisions: []
  transition_architecture:
    phases: []
  validation:
    items: []
  architecture_traces: []
  selection_gates: []
  platform_context: {}
  platform_validation: {}
  subject_verdict: coherent | conditional | incomplete | indeterminate
  decision: {}
```

## architecture_trace

```yaml
architecture_trace:
  id: AT1
  value_ids: []
  quality_scenario_ids: []
  current_finding_ids: []
  option_id: O1
  target_decision_ids: []
  transition_phase_ids: []
  validation_ids: []
  status: covered | partial | missing | contradictory
  evidence: []
  gaps: []
```

actorはid/purpose/evidence、product valueはid/statement/actor_ids/success_signals/owner/evidenceを持つ。

domain_frameはdomain_vision_status、not_applicable_reason、target_customer、critical_problem、unique_value、success_signals、value_preservation_or_risk_statement。investmentはpriority(now/next/later/do-not-fix/unknown)、level、build_buy_reuse、rationale、reevaluate_whenを適用範囲で保持する。

quality_catalog_refとquality_definition_idは入力または今回作ったContext Packetのquality_lens.definitionsへ解決する。quality snapshotを保持する場合は参照元と一致させる。catalogを作る場合だけ`skills/mino-core/schemas/core.md`のquality_definitionを使う。

current_findingsはid、quality_scenario_ids、levels(local/system/journey/organization/future_change)、observed_symptom、violated_quality_or_target、wrong_responsibility_or_authority、structural_cause、product_or_delivery_impact、owner、evidenceを持つ。

deploy_orderはorder、artifact(producer/consumer/schema/runtime/operation)、change、preconditionsを持つ。temporary_pathsは実在TMP IDで参照できる。old_path_removalはartifacts、owner、deadline、usage_metric、removal_conditionを持つ。

decisionには`skills/mino-core/schemas/decision.md`、platform_context / platform_validationには`skills/mino-core/schemas/platform.md`を使う。

既存挙動変更・移行が該当する場合だけ`skills/mino-core/schemas/change-safety.md`を使う。

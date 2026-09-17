# 保存用schema

依頼された正本packageを作る場合だけ読む。既存artifactはhandleとrevisionで参照再利用する。未知は空欄で隠さず、非該当には理由を残す。

## Contents

- scope
- model_element
- access_path
- destruction_probe
- contract_obligation
- completeness_package

## scope

```yaml
scope:
  actors: []
  use_cases: []
  requirements: []
  contexts: []
  in_scope: []
  out_of_scope: []
discovery_readiness:
  status: verified_input | discovery_required | blocked
  evidence:
    status: confirmed | inferred | assumption | unknown | contradiction
    sources: []
  reason: ""
```

## model_element

```yaml
model_element:
  id: ME1
  dimension: term_context | concept | constraint | state | transition | behavior | relationship | failure | time | writer | reader | authority
  name: ""
  meaning_or_rule: ""
  target_status: present | missing | conflicting | unknown
  concept_kind: value_object | entity | aggregate | policy | domain_service | event | not_applicable | unknown
  evidence:
    status: confirmed | inferred | assumption | unknown | contradiction
    sources: []
dimension_applicability_profile:
  id: DAP1
  requirement_ids: []
  dimensions: []
  disposition: not_applicable
  rationale: ""
  evidence:
    status: confirmed | inferred | assumption | unknown | contradiction
    sources: []
requirement_model_matrix:
  - requirement_id: R1
    dimension_links:
      - dimension: concept
        element_ids: [ME1]
        evidence:
          status: confirmed | inferred | assumption | unknown | contradiction
          sources: []
    not_applicable_profile_ids: []
```

## access_path

```yaml
access_path:
  id: AP1
  matrix_element_id: ME1
  kind: writer | reader
  actor_or_component: ""
  entry_point: ""
  operation_or_interpretation: ""
  model_element_ids: []
  validation_or_translation_route: ""
  bypass_or_misinterpretation_risk: ""
  representation: ""
  platform: windows | linux | macos | common | not_applicable | unknown
  evidence:
    status: confirmed | inferred | assumption | unknown | contradiction
    sources: []
ownership:
  id: OW1
  matrix_element_id: ME1
  authority_type: semantic_owner | invariant_owner | state_authority | source_of_truth
  subject_element_ids: []
  owner: ""
  target_status: unique | conflicting | unknown | transitional
  transition_controls:
    status: required | not_applicable | unknown
    transition_period: ""
    conflict_rule: ""
    reconciliation: ""
    removal_condition: ""
    owner: ""
    confirmation_method: ""
    impact_if_unresolved: ""
    evidence: []
  evidence:
    status: confirmed | inferred | assumption | unknown | contradiction
    sources: []
```

## destruction_probe

```yaml
destruction_probe:
  id: DP1
  requirement_ids: []
  writer_access_path_id: AP1
  entry_point: ""
  destructive_input_or_sequence: ""
  propagation: []
  business_impact: []
  expected_invariant: ""
  observed_result:
    status: prevented | constructed | partially_observed | not_executed | unknown
    evidence: []
  defense_assessment:
    status: present | absent | unknown
    mechanisms: []
    evidence: []
  gap:
    kind: none | missing_concept | missing_constraint | invalid_state | missing_transition | missing_behavior | missing_relationship | missing_failure | missing_time | missing_writer | missing_reader | leakage | authority_conflict | unknown
    element_ids: []
  obligations:
    applicability: required | not_applicable | unknown
    rationale: ""
    confirmation_method: ""
    impact_if_unresolved: ""
    contract_obligation_ids: []
    test_obligation_ids: []
```

## contract_obligation

```yaml
contract_obligation:
  id: CO1
  requirement_ids: []
  model_element_ids: []
  required_contract_kind: precondition | postcondition | invariant | environment_condition | failure_guarantee | prohibited_transition | retry | duplicate | idempotency
  statement: ""
  evidence:
    status: confirmed | inferred | assumption | unknown | contradiction
    sources: []
test_obligation:
  id: TO1
  requirement_ids: []
  model_element_ids: []
  contract_obligation_ids: []
  scenario: ""
  required_oracle: ""
  evidence:
    status: confirmed | inferred | assumption | unknown | contradiction
    sources: []
```

## completeness_package

```yaml
completeness_package:
  scope: {}
  discovery_readiness: {}
  domain_discovery:
    applicability: required | not_applicable | unknown
    package: {}
    not_applicable_reason: ""
    confirmation_method: ""
    impact_if_unresolved: ""
    evidence: []
  audit_rubric:
    dimensions: []
  model_elements: []
  dimension_applicability_profiles: []
  requirement_model_matrix: []
  access_paths: []
  ownership: []
  destruction_probes: []
  gaps:
    - id: G1
      requirement_ids: []
      element_ids: []
      kind: missing_concept | missing_constraint | invalid_state | missing_transition | missing_behavior | missing_relationship | missing_failure | missing_time | missing_writer | missing_reader | leakage | authority_conflict | unknown
      evidence: []
      impact: ""
      severity: blocker | major | minor | unknown
      contract_obligation_ids: []
      test_obligation_ids: []
  contract_obligations: []
  test_obligations: []
  existing_downstream_links: []
  coverage:
    audit_screen_denominator: 0
    audit_screen_resolved_numerator: 0
    applicable_model_denominator: 0
    present_model_numerator: 0
    unresolved_cells: []
    missing_element_ids: []
  platform_context: {}
  platform_validation: {}
  subject_verdict: complete | incomplete | indeterminate
  decision: {}
```

concept_kindはconceptだけに用い、他観点はnot_applicable。requirement_model_matrixは各要件の12観点をlinkまたはN/A profileで一度ずつ解決する。profileは同じ理由・Evidenceの場合だけ共有する。probeのobserved_resultとdefenseは独立判定し、必要な契約とtestのobligationを両方保持する。

decisionには`skills/mino-core/schemas/decision.md`、platform_context / platform_validationには`skills/mino-core/schemas/platform.md`を使う。

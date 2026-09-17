# 保存用schema

依頼された正本packageを作る場合だけ読む。既存artifactはhandleとrevisionで参照再利用する。未知は空欄で隠さず、非該当には理由を残す。

## Contents

- operation
- contract_item
- idempotency_assessment
- contract_test
- contract_package

## operation

```yaml
operation:
  id: OP1
  name: ""
  caller: ""
  boundary: ""
  contract_owner: ""
  initial_state: ""
  inputs: []
  expected_result: ""
  side_effects: []
  failures: []
  evidence:
    status: confirmed | inferred | assumption | unknown | contradiction
    sources: []
```

## contract_item

```yaml
contract_item:
  id: CI1
  operation_id: OP1
  requirement_ids: [R1]
  domain_obligation_ids: []
  kind: precondition | postcondition | invariant | environment_condition | failure_guarantee | prohibited_transition | retry | duplicate | idempotency
  statement: ""
  applicability:
    status: required | not_applicable | unknown
    rationale: ""
    confirmation_method: ""
    impact_if_unresolved: ""
  contract_level: value_object | aggregate | use_case | api | repository | workflow | not_applicable | unknown
  authority_type: semantic_owner | invariant_owner | contract_owner | state_authority | source_of_truth | transition_owner | failure_recovery_owner | operational_owner | not_applicable | unknown
  authoritative_owner: ""
  defensive_validations:
    status: present | not_applicable | unknown
    rationale: ""
    entries:
      - location: ""
        purpose: early_feedback | malformed_input | defense_in_depth
  evidence:
    status: confirmed | inferred | assumption | unknown | contradiction
    sources: []
```

## idempotency_assessment

```yaml
idempotency_assessment:
  operation_id: OP1
  applicability: required | not_applicable | unknown
  rationale: ""
  confirmation_method: ""
  impact_if_unresolved: ""
  evidence:
    status: confirmed | inferred | assumption | unknown | contradiction
    sources: []
  contract_item_ids: []
  mechanism:
    key_scope: ""
    key_lifetime: ""
    duplicate_result: ""
    fingerprint_rule: ""
    retry_rule: ""
```

## contract_test

```yaml
contract_test:
  id: T1
  operation_id: OP1
  requirement_ids: [R1]
  verifies: [CI1]
  given: ""
  when: ""
  then: []
  oracle: ""
  environment_conditions: []
  implementation_status: planned | implemented
  execution_status: not_run | passed | failed
  evidence: []
```

## contract_package

```yaml
contract_package:
  subject: ""
  platform_context: {}
  platform_validation: {}
  change_safety: {}
  requirements: []
  operations: []
  contract_items: []
  idempotency_assessments: []
  public_contract_changes: []
  tests: []
  traceability:
    - requirement_id: R1
      domain_obligation_ids: []
      operation_ids: []
      contract_item_ids: []
      test_ids: []
      status: covered | partial | missing | contradictory
  coverage:
    requirement: {denominator: 0, numerator: 0, uncovered_ids: []}
    contract: {denominator: 0, numerator: 0, incomplete_item_ids: []}
    test: {denominator: 0, numerator: 0, uncovered_item_ids: []}
    execution: {denominator: 0, numerator: 0, unverified_item_ids: []}
    unknown_item_ids: []
  subject_verdict: sufficient | insufficient | indeterminate
  decision: {}
```

change_safetyはapplicability、package、not_applicable_reason、confirmation_method、impact_if_unresolved、evidenceを持つ。公開変更recordはid、contract_item_ids、applicability、approval(status/owner/evidence)、compatibility_window、migration_steps、rollback_or_recovery、confirmation_method、impact_if_unresolved、evidenceを持つ。

decisionには`skills/mino-core/schemas/decision.md`、platform_context / platform_validationには`skills/mino-core/schemas/platform.md`を使う。

既存挙動変更・移行が該当する場合だけ`skills/mino-core/schemas/change-safety.md`を使う。

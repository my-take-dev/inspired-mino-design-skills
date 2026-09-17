# 保存用schema

依頼された正本packageを作る場合だけ読む。既存artifactはhandleとrevisionで参照再利用する。未知は空欄で隠さず、非該当には理由を残す。

## Contents

- consumer
- transport_implementation
- boundary_package

## consumer

```yaml
consumer:
  id: C1
  purpose: ""
  must_know: []
  must_not_know: []
contract_source:
  kind: domain_contract | consumer_semantic_operation | unknown
  artifact_refs: []
  domain_contract_status: applicable | not_applicable | unknown
  not_applicable_reason: ""
  confirmation_method: ""
  impact_if_unresolved: ""
  evidence: []
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
  end_to_end_deadline: {}
  retry_semantics: {}
  idempotency: {}
  duplicate_semantics: {}
  ambiguous_outcome: {}
  consistency_boundary: ""
  evidence: []
```

## transport_implementation

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
selection_boundary:
  id: SB1
  operation_ids: []
  owner: ""
  location: ""
  selection_rule: ""
  proven_variant_evidence: []
```

## boundary_package

```yaml
boundary_package:
  id: BP1
  subject: ""
  owner: ""
  platform_context: {}
  platform_validation: {}
  change_safety: {}
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
    items: []
    transport_implementations: []
  ownership:
    authority_refs: []
    writers: []
    readers: []
  selection_boundaries: []
  leakage_findings: []
  dependency_direction: []
  change_scenarios: []
  migration: []
  boundary_traces: []
  subject_verdict: separated | leaky | overabstracted | not_applicable | indeterminate
  decision: {}
```

operationの5 semanticsはstatus(applicable/not_applicable/unknown)とevidenceを持つ。applicableには本文の意味field、N/Aにはnot_applicable_reason、unknownにはconfirmation_methodとimpact_if_unresolvedだけを加える。

change_safetyはapplicability(required/not_applicable/unknown)、package、not_applicable_reason、confirmation_method、impact_if_unresolved、evidenceを持つ。

itemsはid、kind(hidden_technology/algorithm/data_access/operational_concern/platform_adapter)、operation_ids、description、owner、evidenceを持つ。leakage_findingsはid、operation_ids、implementation_part_ids、status(present/absent/unknown)、impact、evidence。change_scenariosはid、name、status、evidence、rationale。

migrationはid、contract_ids、consumer_ids、compatibility_window、steps、rollback_or_recovery、temporary_path_ids、evidence。boundary_tracesはid、requirement_ids、consumer_ids、operation_ids、contract_ids、ownership_refs、implementation_part_ids、leakage_finding_ids、change_scenario_ids、migration_ids、verification_ids、status(covered/partial/missing/contradictory)、evidenceを持つ。

decisionには`skills/mino-core/schemas/decision.md`、platform_context / platform_validationには`skills/mino-core/schemas/platform.md`を使う。

既存挙動変更・移行が該当する場合だけ`skills/mino-core/schemas/change-safety.md`を使う。

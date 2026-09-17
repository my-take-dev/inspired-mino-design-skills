# 保存用schema

依頼された正本packageを作る場合だけ読む。既存artifactはhandleとrevisionで参照再利用する。未知は空欄で隠さず、非該当には理由を残す。

## Contents

- requirement
- trace
- rejection_criterion

## requirement

```yaml
requirement:
  id: R1
  actor: ""
  context: ""
  trigger: ""
  expected_result: ""
  prohibited_results: []
  quality_constraint_ids: []
  evidence:
    status: confirmed | inferred | assumption | unknown | contradiction
    sources: []
  acceptance: []
```

## trace

```yaml
trace:
  purpose_id: P1
  goal_id: G1
  requirement_id: R1
  model_elements: []
  contract_ids: []
  boundary_operations: []
  implementation_changes: []
  verification_ids: []
  evidence: []
  connections:
    - from_kind: purpose | goal | requirement | model | contract | boundary | change
      from_id: ""
      to_kind: goal | requirement | model | contract | boundary | change | verification
      to_id: ""
      rationale: ""
      validation_ids: []
      evidence: []
  not_applicable:
    - target_kind: model | contract | boundary | change | verification
      target_id_or_scope: ""
      reason: ""
      evidence: []
  status: covered | partial | missing | contradictory
```

## rejection_criterion

```yaml
rejection_criterion:
  id: RC1
  requirement_ids: []
  condition: ""
  evidence_required: []
  gate: core | architecture | completeness | contract | boundary | verification
```

quality_constraint_idsはContext Packetの実在品質IDへ解決する。local IDはartifact handleとrevisionで区別する。未知・未充足をcoverageの分母から外さない。

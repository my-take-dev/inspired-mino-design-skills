# 保存用schema

依頼された正本packageを作る場合だけ読む。既存artifactはhandleとrevisionで参照再利用する。未知は空欄で隠さず、非該当には理由を残す。

## Contents

- problem_frame
- reasoning_trace
- context_packet
- unknown
- ai_restatement
- selection_gate
- quality_definition
- core_result

## problem_frame

```yaml
problem_frame:
  actor: ""
  context: ""
  desired_state: ""
  observed_barrier: ""
  impact: ""
causal_chain:
  applicability: required | not_applicable | unknown
  reason: ""
  symptom: ""
  violated_goal_or_quality: ""
  violated_rule_or_invariant: ""
  incorrect_owner_or_source: ""
  structural_cause: ""
  unmet_capability: ""
  demand_evidence: []
  success_condition_ids: []
```

## reasoning_trace

```yaml
reasoning_trace:
  id: RT1
  concrete_evidence: []
  actor_or_owner: ""
  purpose_or_loss: ""
  violated_rule_or_quality: ""
  decision_or_obligation: ""
  falsifier_or_counterexample: ""
  validation: []
  stop_reason: decision_useful | authority_boundary | insufficient_evidence
```

## context_packet

```yaml
context_packet:
  actors: []
  problem: ""
  purposes: []
  success_conditions: []
  context:
    time_or_state: []
    business_background: []
    technical_background: []
  terminology:
    - term: ""
      meaning: ""
      alternative_meanings: []
      evidence: []
  rules:
    - id: R1
      statement: ""
      kind: precondition | postcondition | invariant | policy | prohibition
      owner: ""
      evidence_status: confirmed | inferred | assumption | unknown | contradiction
  quality_lens:
    definitions: []
    primary_ids: []
    secondary_ids: []
    constraint_ids: []
    intentionally_not_optimized_ids: []
    tradeoff_decisions: []
  change_boundary:
    must_preserve: []
    may_change: []
    must_not_change: []
    out_of_scope: []
  evidence:
    confirmed: []
    inferred: []
    assumptions: []
    unknowns: []
    contradictions: []
```

## unknown

```yaml
unknown:
  id: U1
  subject: ""
  confirmation_method: ""
  impact_if_unresolved: ""
  owner: ""
  evidence: []
```

## ai_restatement

```yaml
ai_restatement:
  statement: ""
  comparison_basis: []
  proposed_status: matched | mismatched | blocked
  differences: []
  reviewed_by:
    kind: user | human_owner | independent_evaluator | unresolved
    identity: ""
    review_status: accepted | rejected | unresolved
    evidence: []
```

## selection_gate

```yaml
selection_gate:
  id: SG1
  subject: ""
  candidate_ids: []
  decision_condition: ""
  evidence_required: []
  evidence_acquisition: []
  owner: ""
  status: pending | satisfied | rejected
  evidence: []
```

## quality_definition

```yaml
quality_definition:
  id: QL1
  quality:
    reference_model: ""
    level: characteristic | subcharacteristic | project_defined | unknown
    characteristic: ""
    subcharacteristic: ""
    standard_term: ""
    display_name_ja: ""
    source_terms_ja: []
  evidence: []
```

## core_result

```yaml
core_result:
  decision_maturity: {}
  problem_readiness: ready | conditional | blocked
  problem_frame: {}
  interpretations: []
  premises: []
  causal_chain: {}
  candidate_means: []
  abstraction_ladder: {}
  context_packet: {}
  selection_gates: []
  platform_context: {}
  platform_validation: {}
  traceability_seed: []
  reasoning_traces: []
  ai_restatement: {}
  blockers: []
```

premiseはstatement、evidence、falsification、impact_if_false、evidence_status、assessmentを持つ。abstraction_ladderはconcrete_start、levels、stop_reasonを持つ。

quality_lens.tradeoff_decisionsはid、statement、affected_quality_ids、decision_maturity、evidenceを持つ。品質の階層と意味は`skills/mino-core/references/quality.md`に従う。

decisionは`skills/mino-core/schemas/decision.md`、platformは`skills/mino-core/schemas/platform.md`を使う。

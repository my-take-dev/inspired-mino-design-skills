# 保存用schema

依頼された正本packageを作る場合だけ読む。既存artifactはhandleとrevisionで参照再利用する。未知は空欄で隠さず、非該当には理由を残す。

## Contents

- decision_frame
- meaning_or_premise
- problem_readiness
- problem_framing_package

## decision_frame

```yaml
decision_frame:
  question: ""
  owner: ""
  decide: []
  not_decide: []
  reversibility: reversible | costly | irreversible | unknown
  deadline_or_window: ""
  target_platforms: []
```

## meaning_or_premise

```yaml
meaning_or_premise:
  id: MP1
  statement_or_term: ""
  first_interpretation: ""
  alternatives: []
  discriminating_evidence: []
  evidence_status: confirmed | inferred | assumption | unknown | contradiction
  falsification: ""
  impact_if_false: ""
```

## problem_readiness

```yaml
problem_readiness:
  subject_verdict: ready | conditional | blocked
  reasons: []
  evidence_needed: []
  safe_assumptions: []
  selection_gate_ids: []
  next_artifacts:
    - artifact: architecture | completeness | contract | boundary | integrated_change
      obligations: []
```

## problem_framing_package

```yaml
problem_framing_package:
  decision_frame: {}
  problem_frame: {}
  evidence:
    confirmed: []
    inferred: []
    assumptions: []
    unknowns: []
    contradictions: []
  meanings_and_premises: []
  causal_chain: {}
  candidate_means: []
  reasoning_traces: []
  context_packet: {}
  selection_gates: []
  success_conditions: []
  rejection_criteria: []
  ai_restatement: {}
  problem_readiness: {}
  platform_context: {}
  platform_validation: {}
  decision: {}
```

problem_frame、causal_chain、context_packet、selection_gates、ai_restatementは`skills/mino-core/schemas/core.md`を読む。未使用collectionは空、未知は確認方法付きrecordにする。

decisionには`skills/mino-core/schemas/decision.md`、platform_context / platform_validationには`skills/mino-core/schemas/platform.md`を使う。

# 保存用schema

依頼された正本packageを作る場合だけ読む。既存artifactはhandleとrevisionで参照再利用する。未知は空欄で隠さず、非該当には理由を残す。

## Contents

- priority_assessment
- change_step
- change_safety

## priority_assessment

```yaml
priority_assessment:
  factors:
    - kind: business_criticality | expected_change | debt_impact | failure_risk | remediation_cost
      rating: high | medium | low | unknown
      impact: ""
      rationale: ""
      evidence: []
  comparison_rationale: ""
  owner:
    status: identified | unknown
    value: ""
    resolution_or_reason: ""
    evidence: []
```

## change_step

```yaml
change_step:
  id: S1
  single_goal: ""
  affected_contracts: []
  files: []
  preconditions: []
  validation: []
  abort_conditions: []
  rollback_or_recovery: []
  completion_condition: ""
temporary_path:
  id: TMP1
  artifact: "flag | adapter | dual-write | copy | old-path"
  owner: ""
  introduced_at: ""
  purpose: ""
  metric_or_log: ""
  removal_condition: ""
  removal_phase: ""
```

## change_safety

```yaml
change_safety:
  target_state: {}
  priority: now | next | later | do-not-fix | unknown
  priority_assessment: {}
  behavior_baseline: []
  intent_hypotheses: []
  strategy: ""
  first_vertical_slice: ""
  steps: []
  temporary_paths: []
  independent_review: []
```

priorityを再決定しない場合は既存priority_assessmentを参照し理由を残す。temporary_pathのIDは他packageから参照できる。導入予定と実際の導入日を区別する。

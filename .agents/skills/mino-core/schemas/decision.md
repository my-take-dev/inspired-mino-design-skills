# Canonical decision schema

## Contents

- When to read
- Decision record

## When to read

保存・引継ぎartifactを作るときに読む。各statusの意味とgate適用先は`skills/mino-core/references/shared-policies.md`に従う。現在artifact、対象の良否、次phase、releaseの判断を混ぜない。

## Decision record

```yaml
decision:
  status: pass | revise | blocked | awaiting_approval
  artifact_readiness: ready | incomplete | blocked
  engineering_status: not_started | planned | changed | verified | failed
  release_status: not_applicable | not_ready | awaiting_approval | approved
  decision_maturity:
    status: proposed | approved | frozen | unknown | contradiction
    owner: ""
    scope: []
    evidence_status: confirmed | inferred | assumption | unknown | contradiction
    approval_evidence: []
    baseline_version: ""
    change_control: ""
  next_phase:
    name: ""
    status: allowed | blocked | awaiting_approval | not_applicable
    reasons: []
    human_approvals_required: []
  evidence: []
  assumptions: []
  unknowns:
    - id: U1
      subject: ""
      confirmation_method: ""
      impact_if_unresolved: ""
      owner: ""
      evidence: []
  contradictions: []
  failed_gates: []
  unexecuted_validation:
    - id: UV1
      reason: ""
      required_runner: ""
      planned_commands: []
      owner: ""
      evidence: []
  platform_validation: {}
  residual_risks: []
  human_approvals_required: []
```

platform_validationは`skills/mino-core/schemas/platform.md`のrecordまたは同一artifactへの解決可能な参照を使う。未知や未実行を空文字・成功で埋めず、確認方法・runner・ownerを残す。

# 保存用schema

依頼された正本packageを作る場合だけ読む。既存artifactはhandleとrevisionで参照再利用する。未知は空欄で隠さず、非該当には理由を残す。

## Contents

- function_plan
- decision_frame
- implementation_spec

## function_plan

```yaml
function_plan:
  - function: architecture | discovery | completeness | contract | boundary | change_safety
    run_if: ""
    required_artifact: ""
    status: planned | completed | failed | blocked | not_applicable
    not_applicable_reason: ""
```

## decision_frame

```yaml
decision_frame:
  mode: design | implementation | review | reproduction-test
  requested_outcome: ""
  decision_owner: ""
  routing_origin: integrated
  mutation_authorized: false
  in_scope: []
  out_of_scope: []
  reversibility: reversible | costly | irreversible | unknown
  public_contract_change_allowed: false
  destructive_change_allowed: false
  deadline_or_window: ""
  host_platform: windows | linux | macos | unknown
  target_platforms: []
  decision_maturity: {}
```

## implementation_spec

```yaml
implementation_spec:
  decision_frame: {}
  function_plan: []
  platform_context: {}
  platform_validation: {}
  problem_frame: {}
  problem_readiness: {}
  selection_gates: []
  premises: []
  causal_chain: {}
  context_packet: {}
  reasoning_traces: []
  requirements: []
  rejection_criteria: []
  architecture_strategy_package: {}
  domain_discovery_package: {}
  completeness_package: {}
  contract_package: {}
  boundary_package: {}
  change_safety_package: {}
  allowed_dependencies: []
  prohibited_structures: []
  change_boundary: {}
  verification_plan: []
  traceability: []
  human_approvals_required: []
  function_artifact_refs: []
reproducible_development_result:
  mode: ""
  function_plan: []
  mode_artifact:
    kind: implementation_spec | verified_change | review_result | reproduction_report
    artifact: {}
  platform_context: {}
  core_result: {}
  requirement_catalog: []
  rejection_criteria: []
  architecture_strategy_package: {}
  domain_discovery_package: {}
  completeness_package: {}
  contract_package: {}
  boundary_package: {}
  change_safety_package: {}
  implementation_summary: []
  validation:
    executed: []
    passed: []
    failed: []
    unexecuted: []
    platform_validation: {}
  traceability: []
  findings: []
  function_artifact_refs: []
  decision: {}
  next_action: ""
```

mode_artifact.kindはdesign=implementation_spec、implementation=verified_change、review=review_result、reproduction-test=reproduction_reportとし、artifactへ内容または解決可能な参照を置く。

専門packageのfieldは該当するFunctionだけ必須とする。非該当はfunction_planへ理由を記録し、そのpackage fieldを省略できる。該当するpackageは上記fieldかfunction_artifact_refsから解決できるようにし、専門schema・ID・coverage・未知を保持する。空packageを実行済みにしない。

verified_changeはspec参照、対象revision、変更一覧、契約/trace、実行Evidence、独立確認、未実行、残存riskを持つ。review_resultはscope/revision、参照要求、Evidence付きfinding、再現条件、影響、修正方針、subject verdict、未確認領域を持つ。reproduction_reportはrun一覧、除外理由、metric、問題signature、設定/digest/隔離、未実行を持つ。

findingsはgate、severity(blocker/major/minor)、evidence、violated_requirements、violated_contracts、impact、required_actionを保持する。同じartifactを内外のenvelopeへ重複保存せず参照できる。

decisionには`skills/mino-core/schemas/decision.md`、platform_context / platform_validationには`skills/mino-core/schemas/platform.md`を使う。

既存挙動変更・移行が該当する場合だけ`skills/mino-core/schemas/change-safety.md`を使う。

新規の共通recordは`skills/mino-core/schemas/core.md`、要件とtraceは`skills/mino-core/schemas/requirements.md`を使う。各専門packageは選択したSkillのschemaを使い、参照再利用する。

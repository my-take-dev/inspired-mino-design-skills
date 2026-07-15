# Architecture Quality Strategy workflow

## Contents

- Decision, value, and investment frame
- Quality portfolio and scenarios
- Current architecture and debt
- Options and authority
- ADR and transition
- Validation and output
- Architecture trace

Architectureはsystem-wideのvalue、quality portfolio、responsibility / data authority、target / transition decisionを所有する。peer Functionまたはintegrated routerからscoped artifactを依頼された場合は、依頼範囲だけをcallerへ返し、consumer operation boundary等の依頼外Functionへ再routingしない。必要なBoundary PackageはIDで参照し、consumer operation contractを重複定義しない。

## Decision, value, and investment frame

```yaml
decision_frame:
  question: ""
  owner: ""
  approvers: []
  decision_maturity: {}
  actors:
    - id: A1
      purpose: ""
      evidence: []
  product_values:
    - id: V1
      statement: ""
      actor_ids: []
      success_signals: []
      owner: ""
      evidence:
        - status: confirmed | inferred | assumption | unknown | contradiction
          source: ""
          supports: ""
  in_scope: []
  out_of_scope: []
  horizon: ""
  target_platforms: []
  reversibility: reversible | costly | irreversible | unknown
  constraints: []
```

named architectureやtechnologyを`candidate_means`へ退避する。

capabilityの対象種別を先に判定する。`core | supporting | generic`はbusiness capabilityまたはsubdomainの投資分類であり、技術要素の重要度labelとして使わない。

```yaml
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
  evidence:
    - status: confirmed | inferred | assumption | unknown | contradiction
      source: ""
      supports: ""
  domain_frame:
    domain_vision_status: applicable | not_applicable | unknown
    not_applicable_reason: ""
    target_customer: ""
    critical_problem: ""
    unique_value: ""
    success_signals: []
    value_preservation_or_risk_statement: ""
  investment:
    priority: now | next | later | do-not-fix | unknown
    level: high | medium | low | unknown
    build_buy_reuse: build | buy | reuse | not_applicable | unknown
    rationale: ""
    reevaluate_when: []
```

- `kind: business_capability | subdomain`だけを`core | supporting | generic`へ仮分類する。`core`では`domain_vision_status: applicable`とし、顧客価値、differentiation、独自知識、expected change、failure riskをEvidenceにする。`supporting | generic`では架空の`unique_value`を作らず、`not_applicable_reason`と、security、legal、accounting、operation等の`value_preservation_or_risk_statement`をEvidence付きで残す。
- `kind: technical_capability`は原則`classification: not_applicable`とし、`classification_rationale`とEvidenceを残す。logging、deployment、cache等は、core domain分類ではなくquality scenario、failure risk、operation、costで評価する。
- kindまたはclassificationをEvidenceから判定できない場合は`unknown`を保持し、Selection Gate、確認方法、未解決時の影響へ接続する。

| Classification | Design investment |
|---|---|
| core + high change | deep model、明確なboundary、強いcontract、手厚いtest |
| supporting + high risk | security、accounting、legal等の必要品質へ投資 |
| generic | buy / reuse / simple implementationを比較 |
| low change + low risk | do-not-fix / do-minimumを許す |

架空のROIを作らない。`build | buy | reuse`と再評価triggerを残す。classification、change / risk、quality priority、investment、reversibilityをEvidenceから確定できない場合は`unknown`を使い、canonical decisionのunknown recordとselection gateへ接続する。

## Quality portfolio and scenarios

```yaml
quality_portfolio:
  items:
    - id: QA1
      quality:
        reference_model: ""
        level: characteristic | subcharacteristic | project_defined | unknown
        characteristic: ""
        subcharacteristic: ""
        standard_term: ""
        display_name_ja: ""
        source_terms_ja: []
      priority: primary | secondary | constraint | intentionally_not_optimized | unknown
      value_ids: []
      rationale: ""
      owner: ""
      evidence: []
      reevaluate_when: []
```

全品質を同時に最大化せず、主に最適化する品質を絞る。`quality`は`skills/mino-core/references/core.md`のQuality vocabularyを使い、characteristic、subcharacteristic、standard term、source term、suite / project内表示名を別fieldへ置く。`modifiability`と`maintainability`、`functional_correctness`と`functional_suitability`のように粒度が異なる語を同じfieldの値として並べない。

```yaml
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

未計測の数値を作らず、`unknown`とmeasurement planを記録する。

## Current architecture and debt

module、service、data、contract、runtime、deploy、owner、operationをinventory化する。findingを次のlevelで評価する。

- `local`: class、function、package
- `system`: module、service、data flow、failure propagation
- `journey`: actorのend-to-end outcome
- `organization`: ownership、coordination、deploy、on-call
- `future_change`: roadmap上の代表変更

findingはID、owner、Evidence状態を持ち、debtを次の因果で記述する。

```text
observed symptom
→ violated quality / target state
→ wrong responsibility or authority
→ structural cause
→ product / delivery impact
```

```yaml
current_finding:
  id: F1
  quality_scenario_ids: []
  levels: [local, system, journey, organization, future_change]
  observed_symptom: ""
  violated_quality_or_target: ""
  wrong_responsibility_or_authority: ""
  structural_cause: ""
  product_or_delivery_impact: ""
  owner: ""
  evidence:
    - status: confirmed | inferred | assumption | unknown | contradiction
      source: ""
      supports: ""
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
  priority: now | next | later | do-not-fix | unknown
```

portfolio対象が未選択なら、business criticality、expected change、debt impact、failure risk、remediation costで`now | next | later | do-not-fix`の候補を比較する。5 factorを一度ずつ記録し、`debt_impact.impact`相当の影響説明とEvidenceを残す。High / Medium / Lowは比較のためのordinalであり、根拠のない数値換算を行わない。静的metricは兆候でありEvidenceの代わりにしない。`owner.status: identified`では`value`を必須にする。ownerが入力から確定できない場合は補完せず、`priority: unknown`、解決方法または未確定理由、Evidenceを残し、最終順位ではなく人間選択待ちの候補として扱う。

## Options and authority

最低限、`do nothing / do minimum / incremental`を含む現実的なoptionを、次の意味契約で比較する。

| Field | Content |
|---|---|
| improves / degrades | 対象quality scenario |
| scope | module、data、consumer、operation |
| system effects | journey、organization、failure、future change |
| cost | build、migration、operation、learning |
| risk | failure、security、compatibility |
| reversibility | reversible / costly / irreversible |
| evidence | code、history、measurement、experiment |
| validation | test、pilot、metric、review |

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
  system_effects:
    local: []
    system: []
    journey: []
    organization: []
    future_change: []
  costs: []
  risks: []
  reversibility: reversible | costly | irreversible | unknown
  evidence: []
  assumption_ids: []
  unknown_ids: []
  validation_ids: []
```

targetで次を一意にする。

- semantic / capability owner
- public contract owner
- source of truth
- state / transition authority
- failure and recovery owner
- operational owner

writerとreaderは複数存在できる。targetの複数writerは明示的なcoordination contractが必要である。migration中のdual writerは期限、conflict rule、reconciliation、removal conditionを持つ。

人間判断待ちのconditional designでは、target authorityを勝手に選ばず、optionごとの候補と選択gate、Evidence取得方法を示す。この場合はADRを`proposed`、subject verdictを`conditional`とし、選択済みtargetとして扱わない。

選択gateは`skills/mino-core/references/core.md`の`selection_gate`契約を使い、Architectureでは`candidate_ids`へoption IDまたはtarget decision候補IDを置く。gateの`status: pending`中は、priority、quality priority、target authority、reversibility、cutover / recovery方針を確定値へ丸めない。

Architectureはsystem decisionを次の契約で所有する。consumer operationの詳細はBoundary PackageのIDを参照し、重複定義しない。

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
```

## ADR and transition

```yaml
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

AIが作成したADRは`decision_maturity.status: proposed`とする。権限を持つownerのEvidenceなしに価値、trade-off、不可逆判断を`approved | frozen`へ進めない。`lifecycle_status`は現行・廃止状態であり、承認状態の代用にしない。
`assumption_ids`と`unknown_ids`はCoreのpremiseまたはcanonical unknown recordへ解決し、free textをID代わりにしない。

### Target

- responsibility and context boundary
- interface contract and dependency direction
- state / data authority
- runtime / failure boundary
- deploy、observability、security boundary

### Transition

各phaseは一つ以上のtarget decisionへ接続し、次の意味契約を持つ。

```yaml
transition_phase:
  id: TP1
  name: ""
  owner: ""
  from_state: ""
  to_state: ""
  target_decision_ids: []
  changes: []
  deploy_order:
    - order: 1
      artifact: producer | consumer | schema | runtime | operation
      change: ""
      preconditions: []
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
  temporary_paths:
    - artifact: "flag | adapter | dual-write | copy | old-path"
      owner: ""
      introduced_at: ""
      purpose: ""
      metric_or_log: ""
      removal_condition: ""
      removal_phase: ""
  old_path_removal:
    artifacts: []
    owner: ""
    deadline: ""
    usage_metric: ""
    removal_condition: ""
  validation_ids: []
  evidence: []
```

temporary pathはowner、導入日、目的、metric/log、削除条件、削除予定phaseを持つ。rollbackで既に成功した外部副作用を戻せない場合は、新規writeを止めてforward recoveryする。
`irreversible_point.exists`、approval、recovery strategyが未確認なら`unknown`を保持し、確認方法と未解決時の影響をcanonical decisionへ接続する。unknownのまま不可逆stepを選択または実行しない。

## Validation and output

品質scenarioを可能な範囲で実行またはsimulationする。

- representative change impact
- contract / architecture dependency test
- failure injection、retry、partial failure
- load / latency、authorization、threat review
- migration dry-run、readback、rollback rehearsal
- runbookとoperational owner review

各validationは次の契約を持つ。

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
```

`planned`は成功Evidenceではなく、`executed_pass`と別にする。ただしdesign modeでoracle、owner、実行条件、必要platformが揃えばartifactはreadyにでき、canonical decisionは`engineering_status: planned`と後続phaseを示す。未実行をpassedとせず、結果と反例をbenchmarkへ還元する。

## Architecture trace

sectionの並存だけで完了にせず、valueからvalidationまでをIDで接続する。

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

各IDは実在するartifactへ解決し、optionとtarget decisionは対応するquality scenarioを改善または意図的に劣化させる理由を持つ。`partial | missing | contradictory`は隠さずcanonical decisionへ反映する。

```yaml
architecture_strategy_package:
  decision_frame: {}
  platform_context: {}
  platform_validation: {}
  capabilities: []
  quality_portfolio: {}
  quality_scenarios: []
  current_findings: []
  options: []
  selection_gates: []
  adr: {}
  target_architecture:
    decisions: []
  transition_architecture:
    phases: []
  validation:
    items: []
  architecture_traces: []
  subject_verdict: coherent | conditional | incomplete | indeterminate
  decision: {}
```

`subject_verdict`は設計対象を判定する。選択済みtargetとtransitionが全traceを満たせば`coherent`、選択肢・選択gate・Evidence取得方法まで揃い人間判断を待つなら`conditional`、Evidence付き欠陥を特定できれば`incomplete`、重要Evidence不足で判定不能なら`indeterminate`とする。

`capabilities`、`options`、`target_architecture.decisions`、`transition_architecture.phases`、`validation.items`は、このworkflow内のID、owner、Evidence付き意味契約で出す。簡略メモや調査資料側のschemaをruntime output contractの正にしない。

`decision`は依頼されたArchitecture Strategy Packageの完成状態を表すcanonical schemaであり、subject verdictと混同しない。上のschemaの空文字、空配列、見出しの存在だけではgateの充足Evidenceにならない。各主張はID、owner、Evidence状態とsource、または根拠のある`not_applicable`理由を持つ。

## Rejection conditions

- named styleまたはtechnologyが目的化
- valueまたはquality scenarioがない
- core capabilityにEvidenceのあるdomain visionがない、またはsupporting / genericのdomain vision非適用にvalue-preservation / risk statement、理由、Evidenceがない
- technical capabilityへ`core | supporting | generic`を付ける、またはkind不明をbusiness capabilityへ丸める
- quality characteristicとsubcharacteristicを同じfieldへ混在させる、またはstandard term、source term、display nameの対応を暗黙にする
- localだけを見てsystem / journey / operationを評価しない
- current findingのpriorityに5 factor、debt impactの影響説明、Evidence、比較理由、人間ownerがない、または根拠のない数値scoreを使う
- 選択済みtargetのsource of truthまたはauthorityが不明、またはconditional designに候補・選択gate・Evidence取得方法がない
- targetだけでtransitionのdeploy order、exit criteria、irreversible point、abort、rollback / forward recovery、old path removalがない
- irreversible decisionにEvidenceとapprovalがない
- unknownのpriority、quality priority、reversibility、irreversible point、approval、recovery strategyを確定済みとして扱う
- 全品質を上げると主張しtrade-offを隠す
- validation planだけを実行結果として扱う
- value → quality scenario → current finding → option → target decision → transition phase → validationのtraceが解決しない
- peer / integratedからのscoped依頼に対し、依頼外Functionへ再routingする

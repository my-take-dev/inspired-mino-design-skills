# Reproducible Development integrated workflow

## Contents

- Modes and routing
- Phase 0: Decision frame
- Phase 1: Core gate
- Platform context and portability gate
- Phase 2: Requirements and rejection criteria
- Phase 3: Architecture strategy
- Phase 4: Domain discovery and completeness
- Phase 5: Contract
- Phase 6: Boundary and code design
- Phase 7: Implementation Spec
- Phase 8: Implementation
- Phase 9: Independent verification
- Phase 10: Human acceptance
- Phase 11: Reproduction test
- Final output and stop conditions

## Modes and routing

| Mode | Outcome | Workspace mutation |
|---|---|---|
| design | Implementation Specと未解決gate | prohibited |
| implementation | Verified Changeと実行結果 | authorized scope only |
| review | Findings and Decision | prohibited |
| reproduction-test | 複数runのReproduction Report | live workspace prohibited |

依頼からmodeを判断できない場合は最も狭いread-only modeを選び、仮定を明示する。

routerは`routing_context.origin: integrated`、`requested_by: router`、`requested_artifact`、`return_to: router`をFunctionへ渡す。Functionは固有成果物を返し、routerまたはpeerへ再routingしない。

| Condition | Required module | Order |
|---|---|---|
| problem、meaning、change boundaryが曖昧 | Shared Core | first |
| 複数module、data authority、system quality、migration | Architecture | Core後 |
| 用語、context、暗黙conceptの発見 | Domain discovery | completeness前 |
| concept、state、transition、failureの欠落 | Completeness | contract前 |
| pre / post / invariant、failure guarantee | Contract | model後 |
| 技術漏出、long script、variant、implementation交換 | Boundary | contract後 |
| existing behavior、legacy、migration | Change safety | implementation前 |

単一成果物は対応Functionだけへhand offし、routerを継続しない。private mechanical changeではこのworkflowを起動しない。

```yaml
function_plan:
  - function: architecture | discovery | completeness | contract | boundary | change_safety
    run_if: ""
    required_artifact: ""
    status: planned | completed | failed | blocked | not_applicable
    not_applicable_reason: ""
```

`run_if`が成立するFunctionだけを呼ぶ。`not_applicable`はscopeとEvidenceに基づく理由を持たせ、phase見出しが存在するという理由で全Functionを実行しない。Functionを呼ぶときは`$<skill-name>`とrouting contextを使い、固有SKILL.mdのOutcome、gate、Completionを迂回しない。

最終成果物には`function_plan`を残す。Function成果物を読みやすく要約してもよいが、次の意味契約を文章へ圧縮して消してはならない。

- applicable / not applicableと、その`run_if`または非該当理由
- requirement、condition、testの安定IDと相互参照
- Evidence状態、authority種別、authoritative owner、defensive validation
- coverageの分母、分子、未coverage ID、根拠付きN/A
- subject verdictと、成果物自体のreadinessを分けた判定

これらを本文へ展開しない場合は、同じ最終成果物内のlosslessなFunction packageを参照する。まだ作成していないIDや、成果物外の一時的な会話を参照して完了扱いにしない。

## Phase 0: Decision frame

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
  host_platform: windows | linux | unknown
  target_platforms: []
  decision_maturity:
    status: proposed | approved | frozen | unknown | contradiction
    owner: ""
    scope: []
    evidence_status: confirmed | inferred | assumption | unknown | contradiction
    approval_evidence: []
    baseline_version: ""
    change_control: ""
```

公開契約、data meaning、security、money、safety、irreversible operationへ影響する未決事項を仮定で越えない。design / reviewでは選択肢、選択gate、Evidence取得方法へ隔離できるが、選択・実装・不可逆操作はblockerのままにする。

## Phase 1: Core gate

`skills/mino-core/references/core.md`に従い、次を作る。

- Problem Frame
- alternative interpretation、premise、falsification、causal chain
- technical gravity signalsとcandidate means
- Context Packetとquality lens
- AI restatementのstatement、comparison basis、proposed status、differences、review主体
- concrete Evidence → purpose / loss → rule / quality → decision → validationのreasoning trace

`problem_readiness: blocked`なら専門Functionや実装へ進まない。`conditional`ならdesign / reviewで選択肢とobligationを具体化できるが、未決事項に依存する選択とimplementationへ進まない。

### Platform context and portability gate

filesystem、process、shell、toolchain、test実行、またはWindows / Linux対応がscopeにある場合は、`skills/mino-core/references/platform-compatibility.md`を読む。

- runtime Evidenceからhost platform、shell、filesystem、toolchainを記録する。
- target platformと、platformごとの実行可能なvalidation commandを決める。
- 共通のrequirement、contract、test oracleと、platform固有implementationを分離する。
- 両OS対応がrequiredで一方を実行できない場合は、必要runnerとcommandを未実行検証へ残す。

## Phase 2: Requirements and rejection criteria

`skills/mino-core/references/requirements-and-traceability.md`に従う。

1. 各要求をactor、context、trigger、expected / prohibited result、quality constraint、Evidence付きで正規化する。
2. 現行挙動を`must-preserve | intentional-change | unknown`へ分類する。
3. purpose → goal → requirementのseed traceを作る。
4. 実装前のrejection criteriaをEvidence付きで記録する。権限を持つownerがbaselineとして承認した場合だけdecision maturityを`approved | frozen`とし、AI生成直後は`proposed`とする。

最低限の拒否条件:

- approved problemと異なるactor / purposeを実装する
- requirement、model、contract、testのcoverageが欠ける
- invalid state、禁止transition、未定義failureを残す
- implementation detailをpublic boundaryへ漏らす
- primary quality scenarioまたはconstraintを破る
- 無承認のcontract / data meaning変更やscope外変更を行う
- important unknown / contradictionを隠す

## Phase 3: Architecture strategy

`run_if`: 複数module / service / team、data authority、system quality、migration、低可逆性のいずれかがscopeにある。

次のいずれかがある場合だけArchitecture Functionを使う。

- 複数module / service / team
- source of truth、writer、public API / event / schema変更
- 性能、信頼性、security、modifiabilityのtrade-off
- target / transition、migration、recovery
- 可逆性が低い判断

成果:

- value / capability kind / domain vision / investment frame
- characteristic / subcharacteristic、standard / source / display termを分けたquality portfolioとscenario
- current evidence、option、trade-off、ADR
- target authorityとtransition writer
- migration、compatibility、recovery、validation

局所変更なら`not_applicable`と理由を記録する。

## Phase 4: Domain discovery and completeness

`run_if`: 用語・context・model boundaryの発見、またはconcept / state / transition / failure / writer / readerの完全性判定が必要である。

用語、context、model boundaryが未確定なら`skills/mino-core/references/domain-discovery.md`を使う。

- stable IDを持つterm ledger、ambiguous meaning参照、example / counterexample
- bounded context、upstream / downstream、最小交換fact、stable term / context IDを参照するtranslation
- relationshipごとのfailure owner、retry、duplicate、ambiguous outcomeの適用判定
- invisible concept、out-of-scope、current symbol mapping

`skills/mino-core/references/domain-discovery.md`のcanonical field名を保持する。termは`id`、`name`、`context_id`、`actors`、`purpose`、`meaning`、`examples`、`counterexamples`、`rules`、`related_meaning_term_ids`、`evidence`を省略しない。translationのsource / target context IDとterm ID、relationshipのupstream / downstream context IDを結合値、表の暗黙列、改名fieldへ圧縮しない。全参照IDを検査し、relationshipのfailure ownerとretry / duplicate / ambiguous outcomeの適用判定、理由またはpolicy、owner、Evidenceを省略しない。unknown recordでは`confirmation_method`と`impact_if_unresolved`も保持する。

完全性判定がapplicableな場合だけCompleteness Functionで、requirementごとにsuite-defined audit dimensionsのapplicabilityをscreeningし、結果を分岐させる観点を詳細化する。このdimension集合を公開資料の完全性定義として帰属させない。

- concept、value constraint
- state、allowed / prohibited transition
- behavior、relationship、failure、time
- semantic / invariant owner、source of truth、writer、reader、state authority
- alternate writerとdestruction probe

blocker gapがある間はcontractを確定しない。design / reviewではgapに依存しないcontract itemと、未決のcontract / test obligationを分けて返せる。
Completeness Functionはcontract / testの必要条件をobligationとして返し、未作成のcontract / test IDを生成しない。routerが後続成果物の実在IDと統合する。

## Phase 5: Contract

`run_if`: 観測可能なoperation保証、pre / post / invariant、failure guarantee、retry / duplicate semanticsを成果物として定義する必要がある。

公開operationごとにEvidence状態とdecision maturityを記録し、次を定義する。

- precondition、postcondition、invariant
- environment condition、failure guarantee
- idempotency key / fingerprint / duplicate result
- retry、ordering、concurrency、不可逆点
- authoritative owner
- Given-When-Then test ID、oracle、実装 / 実行status

requirementからcontractとtestへtraceできなければ実装へ進まない。

## Phase 6: Boundary and code design

`run_if`: consumerへ技術・手順・variant選択が漏れる、purpose boundaryが誤る、またはEvidence付きのimplementation交換 / change scenarioがある。

`skills/mino-core/references/code-design.md`とBoundary Functionを使う。

- consumer、purpose、must know / must not know
- operationのmeaning、failure、side effect、および個別にapplicableと判定したdeadline、retry、idempotency、duplicate、ambiguous outcome、consistency
- implementation technology、algorithm、operation concern
- capsule、branch classification、purpose-driven name、abstraction根拠
- dependency direction、contract owner、state authority
- Evidenceのあるchange scenario

根拠のないvariantのためfactoryやStrategyを作らない。漏出を発見した場合、designは改善案、reviewはfinding、implementationだけ実変更へ反映する。

## Phase 7: Implementation Spec

```yaml
implementation_spec:
  method_provenance: {}
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
```

各項目がEvidenceまたは明示的assumptionを持ち、全requirementがverificationまでtraceされることを確認する。

applicableなFunction成果物は各`*_package`へ、Function workflowで定義したcanonical schemaのまま埋め込む。Completenessのsuite-defined applicability rubric、Contractのcondition単位authority / defensive validation / test oracle、Boundaryのstable trace ID、Architectureのtarget / transition / validation、Change Safetyのtemporary pathを要約listへ圧縮しない。canonical packageが欠けるSpecは、内容が妥当でもschema未完成として`decision.status: revise`、`artifact_readiness: incomplete`にする。

domain discoveryがapplicableな場合も同様に、`domain_discovery_package`へcanonical field単位のterm、ambiguous term、context、translation、relationship、failure semanticsと`reference_integrity.status: pass`を保持する。意味が読めてもtermのactor / purpose / rule / Evidence、ID field、unknown failure recordの確認方法または影響を省略したSpecはschema未完成として扱う。

## Phase 8: Implementation

`mode != implementation`ならこのphaseを`not_applicable`とし、repositoryを変更しない。

`mode == implementation`でも`mutation_authorized != true`ならblockedにする。

既存挙動、legacy、migrationを変更する場合は`skills/mino-core/references/change-safety.md`に従う。

1. Characterization testまたは観測baselineを作る。
2. in-place、purpose split / copy-delete、stranglerから最小riskのstrategyを選ぶ。
3. 最初のvertical sliceを決める。
4. 一step一目的、可逆、即時検証可能な単位で変更する。
5. Rename / Moveはsymbol-aware toolを優先する。
6. temporary pathへowner、導入日、目的、metric/log、削除条件、削除予定phaseを付ける。
7. 関係ないcleanup、将来用abstraction、無承認のpublic changeを行わない。

実装者が作ったtestだけで自己正当化せず、`approved | frozen`なcontract baselineと独立verificationを使う。

## Phase 9: Independent verification

生成担当の説明と独立して、`approved | frozen`なartifact baselineと実行結果から判定する。

### Mode-specific checks

- design: schema、coverage、矛盾、実行可能なverification planを監査する。testを実行済みとしない。
- review: read-only test / analysisを実行できる範囲で行い、findingを返す。修正しない。
- implementation: test、formatter、lint、type / static analysis、build、integrationを実行する。
- reproduction-test: fresh contextと隔離artifactで複数runし、code差でなくmetricを比較する。

WindowsとLinuxの両対応がrequiredなら、同じrequirement IDとoracleで各platformのtest / build / analysisを実行し、結果を混ぜずに記録する。一方の成功を他方のruntime Evidenceとして代用しない。

### Required checks

- requirement → model → contract → boundary → change → test traceability
- invalid construction、boundary value、prohibited transition
- failure state、retry、duplicate、partial failure、rollback / recovery
- model / interface leakage、dependency direction
- representative business / implementation change
- migration rehearsal / readback where applicable
- rejection criteriaの全項目

利用できる場合はfresh subagent / contextを検証者に使い、solverへ期待解や既知findingを渡さない。独立検証手段がなければ`unexecuted_validation`へ残し、release passを宣言しない。

design modeでは、oracle、owner、実行条件が揃った未実行planをartifact readinessのEvidenceにできるが、`passed`へ入れない。`engineering_status: planned`とし、実行を`next_phase`へ置く。

```yaml
finding:
  gate: core | requirements | architecture | completeness | contract | boundary | implementation | verification | acceptance
  severity: blocker | major | minor
  evidence: []
  violated_requirements: []
  violated_contracts: []
  impact: ""
  required_action: ""
```

## Phase 10: Human acceptance

engineering outcomeとreleaseを分ける。

- AI / toolはtechnical gateの候補判定を行う。
- 権限を持つ人間は元のproblem、actor value、trade-off、operation、support、security / legal / safety、migration、releaseを判定する。
- 依頼がdesign / reviewだけならrelease statusは`not_applicable`にできる。
- engineering verification済みでhuman-owned判断だけが残る場合は`awaiting_approval`にする。
- canonical `decision.status`は現在のmodeだけを判定し、後続implementationのblockerを`next_phase`へ記録する。
- 後続implementation / operationだけの承認をcurrent modeの`awaiting_approval`理由にせず、`next_phase.human_approvals_required`へ置く。

## Phase 11: Reproduction test

`skills/mino-core/references/benchmark.md`に従う。

1. raw task、Evidence、allowed assumption、prohibited changeを、権限を持つevaluation ownerがversioned baselineとして`frozen`にし、model実行中のAIに変更させない。
2. 最低3つのfresh contextへSkillとraw artifactだけを渡す。
3. run artifactを相互に見せない。
4. evaluatorがproblem signature、coverage、failure safety、leakage、false positive、authorityを採点する。
5. 一runでもcommon hard gateを破ればsuite releaseをfailにする。

fresh contextまたは隔離を利用できない場合は未実行とし、再現性を推測でpassにしない。

## Final output and stop conditions

```yaml
reproducible_development_result:
  mode: ""
  method_provenance:
    source_derived_principles: []
    suite_operationalization: []
    repository_policy: []
  function_plan: []
  mode_artifact:
    kind: implementation_spec | verified_change | review_result | reproduction_report
    artifact: {}
  platform_context: {}
  core_result:
    problem_frame: {}
    selection_gates: []
    premises: []
    causal_chain: {}
    context_packet: {}
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
    reasoning_traces: []
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
    unexecuted:
      - id: UV1
        reason: ""
        required_runner: ""
        planned_commands: []
        owner: ""
        evidence: []
    platform_validation:
      required_platforms: []
      executed:
        - platform: windows | linux
          evidence_layer: structural_validator | native_filesystem | application_runtime
          process_platform: windows | linux | unknown
          artifact_filesystem: native_ntfs | linux_filesystem | wsl_linux_via_unc | other | unknown
          requirement_ids: []
          contract_ids: []
          verification_ids: []
          oracle_refs: []
          trace_not_applicable:
            - target_kind: requirement | contract | verification | oracle
              target_id_or_scope: ""
              reason: ""
              evidence: []
          commands: []
          result: pass | fail
          evidence: []
      unexecuted:
        - platform: windows | linux
          evidence_layer: structural_validator | native_filesystem | application_runtime
          process_platform: windows | linux | unknown
          artifact_filesystem: native_ntfs | linux_filesystem | wsl_linux_via_unc | other | unknown
          requirement_ids: []
          contract_ids: []
          verification_ids: []
          oracle_refs: []
          trace_not_applicable:
            - target_kind: requirement | contract | verification | oracle
              target_id_or_scope: ""
              reason: ""
              evidence: []
          reason: ""
          required_runner: ""
          planned_commands: []
          owner: ""
          evidence: []
      parity_result: pass | fail | incomplete | not_applicable
  traceability: []
  findings: []
  function_artifact_refs: []
  decision: {}
  next_action: ""
```

`decision`はcanonical schemaを使う。

`mode_artifact`は現在modeの主成果物であり、次の対応を必須にする。

| Mode | kind | Required content |
|---|---|---|
| design | implementation_spec | Phase 7のschema、未解決gate、verification plan |
| implementation | verified_change | `approved | frozen`なSpec参照、変更、実行結果、独立verification、残存risk |
| review | review_result | Evidence付きfinding、要件影響、subject verdict、canonical decision |
| reproduction-test | reproduction_report | case / run ID、isolation、run別metric、variance、aggregate result |

`mode_artifact.artifact`を見出し名だけのopaque objectにしない。表のRequired contentを同じ成果物内へ展開し、stable ID、Evidence、verification status、unknown、未実行事項、canonical decisionを保持する。`function_plan`は全Functionの実行結果を`completed | failed | blocked | not_applicable`まで更新し、`change_safety`がapplicableならcanonical packageを`change_safety_package`へ格納する。

Problem Frame、Evidence付きpremise / unknown、AI restatement、Requirement Catalog、rejection criteria、mode artifact、canonical decisionは省略不可とする。人間向けに短く表現してもfieldの意味を保持する。

`mode_artifact`を`ready`にする前に、applicableな各Functionについて、`function_plan`、固有package、stable ID、Evidence、authority、coverage、subject verdictが同じartifact内で解決することを確認する。routerによる要約でFunctionのhard gateを落とした場合は、専門内容が妥当でも統合成果物をpassにしない。

停止条件:

- Core / requirement normalization failure
- implementationまたは選択済みdesignを妨げるblocker model gap、contract owner / state authority conflict。review findingまたはconditional designとして安全に隔離できる場合はcurrent artifactをblockedにしない
- mode外のmutationまたはpublic change権限不足
- risky changeにmigration / recoveryがない
- 重要validationが実行不能で同等Evidenceもない
- required platformの検証が失敗、または未実行なのにWindows / Linux parityをverifiedとしている
- 現在modeの成果物を`approved | frozen`へ進めるhuman-owned判断が必要で未承認。後続phaseだけの判断は`next_phase`へ置く

停止時も、完了artifact、failed gate、必要な次のEvidenceを返す。

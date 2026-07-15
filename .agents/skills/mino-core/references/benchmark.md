# Reproducibility benchmark

Skill suiteの品質はprompt量やcode一致ではなく、同じ入力に対して同じproblem signatureと要件gateを満たすかで評価する。

## Contents

- Evaluation protocol
- Versioned case bundles
- Metrics
- Representative tasks
- Negative cases
- Run report
- Release gate

## Evaluation protocol

1. taskごとに`mode`、`required_platforms`、`raw_request`、`confirmed_evidence`、`known_unknowns`、`allowed_assumptions`、`prohibited_changes`だけをsolver inputとし、権限を持つevaluation ownerがversioned baselineとして`frozen`にする。solver自身にbaselineを承認・変更させない。
2. runnerは選択した一つの`yaml` fenceのbodyだけをexact payloadとして抽出し、case見出し、case ID、Markdown wrapper、oracle metadataを渡さない。
3. solver workspaceから`skills/mino-core/evaluations/`全体を除外し、期待解、既知finding、期待routing、期待statusを読めないことを記録する。
4. 明示Invocationは利用者が書いた`$<skill-name>`を`raw_request`内にそのまま保持する。runnerがskill名を注入して明示Invocationを捏造しない。implicit routing caseの`raw_request`にはskill名を含めない。
5. evaluatorはrun完了後だけoracleを読み、このbenchmarkとevaluation ownerが`frozen`にしたversioned gateで採点する。solverとevaluatorのcontextを分離する。
6. counted runごとにrun ID、runner、model、完全なmodel setting、runtime suite artifact SHA-256、exact solver input SHA-256、solver output SHA-256、workspace exclusion、oracle visibilityを記録する。digestまたは設定が欠けるrunをrelease母数へ数えない。
7. release判定では、同じsuite artifact、model、settingのfresh contextで最低3 runを行う。
8. runごとに隔離workspaceまたはread-only artifactを使い、前runの生成物を次runから見えなくする。
9. fresh contextまたは隔離を利用できない場合は`unexecuted_validation`へ記録し、release passを宣言しない。
10. code diffではなく下記metricを採点し、一つでもcommon hard gateを破ったrunがあればsuite versionを合格にしない。
11. failureをCore、routing、Function、shared viewpoint、platform / technology adapter、verificationのどこに起因するか分類する。

`suite_artifact_sha256`はsolverに見せるruntime suiteから`skills/mino-core/evaluations/`を除いたregular fileを対象にする。logical pathをU+002F slash区切りのUTF-8 byte順でsortし、各fileを`logical pathのUTF-8 bytes + NUL + byte lengthのASCII decimal + NUL + file bytes`として連結したstreamをSHA-256へ渡す。symlink、順序未定義のarchive、platform固有path表現をdigest入力にしない。`solver_input_sha256`はfence bodyのexact bytes、`solver_output_sha256`はrunnerが保存したraw responseのexact bytesを対象にする。

## Versioned case bundles

再実行可能な評価では、`skills/mino-core/evaluations/cases/0.8.0.md`のsolver input、`skills/mino-core/evaluations/oracles/0.8.0.md`のevaluator-only oracle、`skills/mino-core/evaluations/0.8.0.md`の実行記録を分離する。

- solverへ渡せるtop-level fieldはEvaluation protocol 1のallowlistだけとする。別名field、期待値、routing metadataを追加しない。
- case ID、selection種別、期待routing、期待statusはevaluator-only oracleのrunner metadataへ置く。ただし利用者自身の明示Invocationはraw requestの一部であり、削除またはrunner注入しない。
- oracle、既知finding、期待routing、期待statusをsolverのcontextまたはworkspaceへ含めない。
- evaluatorはrun完了後だけoracleを読み、必須要素、禁止要素、status層、Evidence integrityを採点する。
- case / oracleを更新した場合はversionを上げ、旧caseと結果を上書きしない。
- exact input / output artifactを保存できない場合もdigestを残す。digestを計算できない場合はprovenance不足として`not_executed`扱いにし、release runへ数えない。

production、外部決済、実data、deployをbenchmarkから変更しない。必要な実装variantは使い捨てworkspaceだけに作る。

## Metrics

| Metric | Pass condition |
|---|---|
| same problem solved | 全runのactor、problem、success conditionが同じproblem signatureになる |
| core evidence | 全runにpremise / unknownのEvidence状態とAI restatementが残る |
| method provenance | source-derived principle、suite operationalization、repository policyを誤帰属せず、suite固有schemaを本人の直接手法として扱わない |
| restatement review integrity | restatement、comparison basis、proposed status、review主体を分け、高impact判断をAIの自己matchだけで通さない |
| decision consistency | current mode、next phase、releaseの同じgateが全runで同じstatus層へ置かれる |
| requirement coverage | 全requirementがmodel、contract、boundary、testへtraceされる |
| contract coverage | 必要なpre / post / invariant / failure / retry項目が欠けない |
| invalid state prevention | public writerから禁止状態を生成できない |
| model completeness | concept、state、transition、failure、writer / readerの対象gapがなく、非該当にはEvidence付き理由がある |
| interface boundary integrity | public boundaryへframework、storage、手順が漏れない |
| quality strategy | primary品質、constraint、trade-offが目的へ接続される |
| change locality | 代表変更が無関係なmoduleへ波及しない |
| failure safety | partial failure、retry、rollback / recoveryを必要範囲で検証する |
| evidence integrity | assumption、unknown、contradictionをconfirmedとして扱わない |
| causal trace integrity | concrete Evidence、purpose / loss、rule / quality、decision、validationが往復接続される |
| schema integrity | applicable項目にEvidenceがあり、非該当とcoverage除外に理由がある |
| routing return integrity | Functionがrequested artifactを返し、peer / router間で再routingしない |
| overdesign avoidance | 不要なabstractionやarchitecture変更を強制しない |
| human authority | 価値、trade-off、不可逆判断、releaseをAIが確定しない |
| platform parity | requiredなWindows / Linuxで同じrequirement、contract、test oracleを使い、結果と未実行事項をplatform別に記録する |

## Representative tasks

### B1. Quantity and money constraints

quantityは1以上かつ販売上限以下、moneyはcurrencyを失わない。invalid construction、境界値、total整合性を設計・検証する。

### B2. Reservation state machine

`pending → confirmed → consumed / cancelled`、consumed後cancel禁止、expiration、duplicate confirmを扱う。

### B3. Replaceable payment boundary

consumerは`authorize payment`だけを知り、provider SDK型、retry、HTTP detailを公開しない。provider追加予定のEvidenceがない場合、factoryやStrategy階層は作らない。

### B4. Long transaction and partial failure

DB read、domain decision、external API、save、notificationが一methodへ混在し、external success / internal failureがある。model、contract、boundary、recoveryを分離する。

### B5. Data authority migration

old schemaからnew schemaへ段階移行する。source of truth、dual read / write、backfill、reconciliation、cutover、rollback / forward recoveryを扱う。

### B6. Product-specific quality trade-off

latency、security、modifiabilityが競合する。全品質最大化を主張せず、portfolio、owner、trade-offごとのdecision maturityを残す。

### B7. Ambiguous language and context

同じ`商品`が注文、在庫、配送で異なるruleとlifecycleを持つ。term ledger、context、最小交換事実、translationを作る。

### B8. Legacy purpose split

複数actorと副作用が混在する巨大classを、公開契約を保って段階分割する。behavior classification、characterization、最初のvertical slice、temporary path removalを扱う。

### B9. Windows and Linux portability

file走査、child process、test scriptを持つtoolをWindowsとLinuxへ配置する。論理`skills/` pathを維持し、case sensitivity、separator、CRLF / LF、permission、exit statusの差をimplementationへ隔離して、同じcontractとtest oracleで検証する。

## Negative cases

### N1. Mechanical rename

公開契約へ影響しないprivate symbol rename。full workflowを起動せず、symbol-aware renameとtestへ限定する。

### N2. One concrete implementation

現実的なvariant根拠がない一つの具体実装。外部障害境界など別の品質根拠もなければinterfaceやstrategyを強制しない。

### N3. Intentionally simple code

変更頻度もriskも低い小module。DDD patternやservice分割を追加しない。

### N4. Contradictory requirements

二つのauthoritative specificationが競合する。勝手に一方を選ばずblockedにする。

### N5. Irreversible change without permission

schema dropまたはdata deletionに、許可、backup、recoveryがない。設計案は提示できても実行しない。

### N6. Read-only review

review依頼にfindingと判定だけを返し、repositoryを修正しない。

### N7. Unsupported portability claim

Linuxでのみtest済みの変更をWindows / Linux対応済みと宣言しない。Windowsの必要runner、command、未実行理由を残し、parityを`incomplete`にする。

## Run report

```yaml
benchmark_run:
  suite_version: ""
  task_id: B1
  run_id: ""
  mode: design | implementation | review | reproduction-test
  provenance:
    runner: ""
    model: ""
    model_settings: {}
    suite_artifact_sha256: ""
    solver_input_sha256: ""
    solver_output_sha256: ""
  isolation:
    kind: fresh_context | isolated_workspace | read_only_artifact
    excluded_paths: [skills/mino-core/evaluations/]
    previous_run_artifacts_visible: false
    evaluator_oracle_visible: false
  platform:
    host: windows | linux | unknown
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
  problem_signature:
    actor: ""
    problem: ""
    success_conditions: []
  function_results:
    architecture: not_executed | pass | fail | not_applicable
    discovery: not_executed | pass | fail | not_applicable
    completeness: not_executed | pass | fail | not_applicable
    contract: not_executed | pass | fail | not_applicable
    boundary: not_executed | pass | fail | not_applicable
    change_safety: not_executed | pass | fail | not_applicable
  metrics:
    core_evidence: not_executed | pass | fail
    method_provenance: not_executed | pass | fail
    restatement_review_integrity: not_executed | pass | fail
    decision_consistency: not_executed | pass | fail
    requirement_coverage:
      status: not_executed | pass | fail
      denominator: 0
      numerator: 0
      uncovered_ids: []
    contract_coverage:
      status: not_executed | pass | fail
      denominator: 0
      numerator: 0
      uncovered_ids: []
    invalid_state_prevention: not_executed | pass | fail
    model_completeness: not_executed | pass | fail
    interface_boundary_integrity: not_executed | pass | fail
    quality_strategy: not_executed | pass | fail
    change_locality: not_executed | pass | fail
    failure_safety: not_executed | pass | fail
    evidence_integrity: not_executed | pass | fail
    causal_trace_integrity: not_executed | pass | fail
    schema_integrity: not_executed | pass | fail
    routing_return_integrity: not_executed | pass | fail
    overdesign_avoidance: not_executed | pass | fail
    human_authority_preserved: not_executed | pass | fail
    platform_parity: not_executed | pass | fail
  benchmark_result: not_executed | pass | fail
  failed_gates: []
  unexecuted_validation:
    - id: UV1
      reason: ""
      required_runner: ""
      planned_commands: []
      owner: ""
      evidence: []
  residual_risks:
    - id: RR1
      condition: ""
      impact: ""
      mitigation_or_acceptance: ""
      owner: ""
      evidence: []
  observations: []
```

全statusは未採点時に`not_executed`から開始する。positive / negative polarityのboolean既定値でpassを推測しない。複数run後、problem signatureの一致率、各metricの分散、counted / excluded run IDと除外理由をaggregate reportへまとめる。`same_problem_solved`は単一runで判定しない。

## Release gate

- B1〜B9の全runでcommon hard gate違反がない。
- source-derived principle、suite operationalization、repository policyの誤帰属がなく、高impactなAI restatementを独立reviewなしでconfirmed matchとして扱わない。
- N1〜N7で不要なFunction、過剰設計、書換え、権限越境、未検証の両OS対応宣言がない。
- 前versionでpassしたtaskに回帰がない。
- Windowsでは`skills/mino-core/scripts/validate-suite.ps1`、Linuxでは`skills/mino-core/scripts/validate-suite.sh`がpassする。
- validator契約変更時は`skills/mino-core/scripts/test-validator-fixtures.ps1`と`skills/mino-core/scripts/test-validator-fixtures.sh`で、共通negative fixtureが期待messageとexit 1を返し、positive controlがexit 0になる。
- 両OS対応をreleaseする場合は、WindowsとLinuxでrequiredなruntime validationがpassし、同じcontract oracleへtraceできる。
- failureの原因componentと修正対象を特定できる。
- 結果を`skills/mino-core/evaluations/`へ、suite versionをfile名にして保存する。task、run数、metric、未実行事項、残存riskだけを残し、solverへ期待解を漏らす詳細は保存しない。

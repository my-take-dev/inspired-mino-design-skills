# Reproducibility benchmark

Skill suiteの品質はprompt量やcode一致ではなく、同じ入力に対して同じproblem signatureと要件gateを満たすかで評価する。

## Contents

- Evaluation protocol
- Baseline comparison
- Versioned case bundles
- Package checks and isolation
- Metrics
- Representative tasks
- Negative cases
- Run report
- Release gate

## Evaluation protocol

1. taskごとに`mode`、`required_platforms`、`raw_request`、`confirmed_evidence`、`known_unknowns`、`allowed_assumptions`、`prohibited_changes`だけをsolver inputとし、権限を持つevaluation ownerがversioned baselineとして`frozen`にする。solver自身にbaselineを承認・変更させない。
2. runnerは選択した一つの`yaml` fenceのbodyだけをexact payloadとして抽出し、case見出し、case ID、Markdown wrapper、oracle metadataを渡さない。
3. solver workspaceから`maintenance/evaluations/`全体を除外し、期待解、既知finding、期待routing、期待statusを読めないことを記録する。
4. 明示Invocationは利用者が書いた`$<skill-name>`を`raw_request`内にそのまま保持する。runnerがskill名を注入して明示Invocationを捏造しない。implicit routing caseの`raw_request`にはskill名を含めない。
5. evaluatorはrun完了後だけoracleを読み、このbenchmarkとevaluation ownerが`frozen`にしたversioned gateで採点する。solverとevaluatorのcontextを分離する。
6. counted runごとにrun ID、runner、model、完全なmodel setting、runtime suite artifact SHA-256、exact solver input SHA-256、solver output SHA-256、workspace exclusion、oracle visibilityを記録する。digestまたは設定が欠けるrunをrelease母数へ数えない。
7. release判定では、同じsuite artifact、model、settingのfresh contextで最低3 runを行う。
8. runごとに隔離workspaceまたはread-only artifactを使い、前runの生成物を次runから見えなくする。
9. fresh contextまたは隔離を利用できない場合は`unexecuted_validation`へ記録し、release passを宣言しない。
10. code diffではなく下記metricを採点し、一つでもcommon hard gateを破ったrunがあればsuite versionを合格にしない。
11. failureをCore、routing、Function、shared viewpoint、platform / technology adapter、verificationのどこに起因するか分類する。

`suite_artifact_sha256`はsolverに見せるruntime suiteから`maintenance/evaluations/`を除いたregular fileを対象にする。logical pathをU+002F slash区切りのUTF-8 byte順でsortし、各fileを`logical pathのUTF-8 bytes + NUL + byte lengthのASCII decimal + NUL + file bytes`として連結したstreamをSHA-256へ渡す。symlink、順序未定義のarchive、platform固有path表現をdigest入力にしない。`solver_input_sha256`はfence bodyのexact bytes、`solver_output_sha256`はrunnerが保存したraw responseのexact bytesを対象にする。

## Baseline comparison

非劣化比較ではbaseline commitとcandidate runtime digestを固定し、旧重要caseと現行caseの対応、保持した意味gate、意図的な変更、未対応を先に記録する。r6の対応表は`maintenance/evaluations/0.12.0-r6.md`に置く。

- paired runは両runtimeへ同じfence bodyのraw bytesを渡す。入力はstrict UTF-8・BOMなし・LF・final newlineを先に検査し、改行正規化したhashをexact bytesと呼ばない。旧caseに採点hintがある場合はinstruction_followingとして別集計し、hintを除いた新入力とはbyte同一を主張しない。
- 同じ実効model / 全setting、tool権限、artifact保存条件、required platform、共通の意味oracleを使う。未観測の設定を一致したと推測しない。継承指定だけの試用は、その制約を明示したtargeted smokeにとどめる。
- solverには一つの入力と当該runtimeだけを渡す。case ID・期待route・oracle・比較指摘・他run出力を渡さない。fresh context、workspace分離とOSによるアクセス遮断を区別する。
- 専門入口の高impact照合、分類別投資、部分失敗と復旧、正本packageの引継ぎを優先する。baseline再利用と品質比較だけのnegative caseも含め、過剰確認・過剰packageを回帰として扱う。
- 共通の意味gateで各出力と保存artifactを採点する。版固有のfield名・schema適合は別に検査し、991 fieldの字句存在やCI成功を意味の同等性へ置き換えない。既知の差を除外するときはownerの判断と理由を残す。
- 各側最低3回の反復、必要case・platform、frozen入力・oracle、実効設定のEvidenceが揃うまで非劣化・behavioral releaseを主張しない。速度・費用は同じ品質gateを満たすrunの実測で比較し、PR中間版との文書量差や途中版の試用を代用しない。

## Versioned case bundles

再実行可能な評価では、`maintenance/evaluations/cases/0.12.0-r6.md`のsolver input、`maintenance/evaluations/oracles/0.12.0-r6.md`のevaluator-only oracle、`maintenance/evaluations/0.12.0-r6.md`の実行記録を分離する。suite versionは0.12.0を維持し、評価入力の改訂はsuite contractのevaluation_revisionで識別する。旧`maintenance/evaluations/cases/0.12.0.md`と旧oracleと0.12.0-r2 / r3 / r4 / r5のcase / oracleは変更せず保管する。runにはsuite versionに加えてevaluation revisionとruntime digestを記録し、同じversion文字列だけで結果を再利用しない。

- solverへ渡せるtop-level fieldはEvaluation protocol 1のallowlistだけとする。別名field、期待値、routing metadataを追加しない。
- case ID、selection種別、期待routing、期待statusはevaluator-only oracleのrunner metadataへ置く。ただし利用者自身の明示Invocationはraw requestの一部であり、削除またはrunner注入しない。
- oracle、既知finding、期待routing、期待statusをsolverのcontextまたはworkspaceへ含めない。
- evaluatorはrun完了後だけoracleを読み、必須要素、禁止要素、status層、Evidence integrityを採点する。
- case / oracleを更新した場合はversionを上げ、旧caseと結果を上書きしない。
- exact input / output artifactを保存できない場合もdigestを残す。digestを計算できない場合はprovenance不足として`not_executed`扱いにし、release runへ数えない。

旧versionの原本caseと結果は保守者の版管理で保持する。本配布に含まれない旧caseの回帰は未実行として扱い、旧結果を新versionのpassへ転記しない。今回の62caseは全7責務と代表B1〜B9・negative N1〜N7の観点を含むが、旧caseの完全な置換や全release行列の実行済み宣言ではない。

evaluator-onlyのevaluation_typeでjudgment（自力で判断するcase）とinstruction_following（明示指示への追従）を別集計する。solverのprohibited_changesには実際の操作・変更範囲だけを置き、採点上の禁止事項、期待status、期待Skillを転記しない。構造検査はjudgmentの制約と採点項目の完全一致を検出するだけであり、言い換えたhintや意味上の漏洩はevaluatorが別途点検する。過去の38caseは採点上の禁止事項を入力へ含むため、独立した判断能力のEvidenceに流用しない。

実装・tool操作caseにはrunnerが対象code、承認済み契約、実toolを使い捨てworkspaceで提供する。自然言語の「実行できる」という記述だけでは実行環境にならない。未提供ならcapability不足として除外し、想像したtool成功を採点しない。

production、外部決済、実data、deployをbenchmarkから変更しない。必要な実装variantは使い捨てworkspaceだけに作る。

## Package checks and isolation

全7Skillの構造検査は`maintenance/scripts/validate_suite.py`、fixture検査は`maintenance/scripts/test_validator_fixtures.py`を使う。Python 3.10+標準libraryが必要で、Skillの文章を利用するだけならPython不要。Windowsは同梱PowerShell launcher、Linux/macOSは同梱Bash launcherから同じengineを実行する。native launcherの実測Evidenceは別に記録する。

`maintenance/scripts/suite-files.txt`は実行用Skillだけの配布file inventory、`maintenance/suite-contract.json`は責務・enum・mode対応の機械検査用正本である。旧版だけのfileを残さず、無関係Skillは検査しない。構造validatorは保守directoryから実行用skills rootを指定する。solverへは実行用skillsだけを渡し、maintenanceと評価oracleを渡さない。

ケースのexact payload hash、期待primary route、採点条件は`maintenance/evaluations/oracles/0.12.0-r6.json`を正本とする。`maintenance/scripts/render_evaluation_oracle.py`で保守rootを解決し、対応Markdownを生成してからvalidatorで一致を確認する。いずれもevaluator-only。solverへ渡すruntime copyからevaluations全体と前run成果物を除外する。子contextに親の期待結果をforkして独立性を主張しない。

実行方針の追加caseでは、特定名を知らなくても共通手順を使い、API対応を対象runtimeごとに確認する。確認済みsupported項目を別環境の制約で削除しない。

追加の構造fixtureはtest runnerが使い捨てdirectoryへ生成する。invalid UTF-8、旧file混在、参照、metadata、case改変、missing engine等は構造/実行可能性の検査であり、モデルが正しい判断を返す実験ではない。fixtureのpass数をbehavioral runへ加算しない。

## Metrics

| Metric | Pass condition |
|---|---|
| same problem solved | 全runのactor、problem、success conditionが同じproblem signatureになる |
| core evidence | 全runにpremise / unknownのEvidence状態とAI restatementが残る |
| authoring boundary | 作成時の帰属・履歴をruntimeへ混入させず、業務上のEvidenceと未知は保持する |
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
| platform parity | requiredなWindows / Linux / macOSで同じrequirement、contract、test oracleを使い、結果と未実行事項をplatform別に記録する |

実行方針の追加caseでは、権限内のfollow-through、read-only維持、具体例と反例の照合、委譲の実在、検証範囲、API互換性、pending / staleの扱い、資料の出自をoracleで判定する。結果は既存のobservationsとfailed gatesへ記録する。costや時間は計測Evidenceがある場合だけ併記し、品質gate未達を低costで相殺しない。

## Representative tasks

### B1. Quantity and money constraints

quantityは1以上かつ販売上限以下、moneyはcurrencyを失わない。invalid construction、境界値、total整合性を設計・検証する。

### B2. Reservation state machine

`pending → confirmed → consumed / cancelled`、consumed後cancel禁止、expiration、duplicate confirmを扱う。

### B3. Replaceable payment boundary

consumerは`authorize payment`だけを知り、provider SDK型とHTTP detailを公開しない。意味上のretry可否は公開contractへ、transport retry機構はimplementationへ分ける。provider追加予定のEvidenceがない場合、factoryやStrategy階層は作らない。

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

### B9. Cross-platform portability

file走査、child process、test scriptを持つtoolをWindows、Linux、macOSへ配置する。論理`skills/` pathを維持し、case sensitivity、separator、CRLF / LF、permission、exit statusの差をimplementationへ隔離して、同じcontractとtest oracleで検証する。

## Negative cases

### N1. Mechanical rename

公開契約へ影響しないprivate symbol rename。full workflowを起動せず、symbol-aware renameとtestへ限定する。

### N2. One concrete implementation

現実的なvariant根拠がない一つの具体実装。外部障害境界など別の品質根拠もなければinterfaceやstrategyを強制しない。

### N3. Intentionally simple code

変更頻度もriskも低い小module。DDD patternやservice分割を追加しない。

### N4. Contradictory requirements

二つのauthoritative specificationが競合する。勝手に一方を選ばず、依存する選択・実装をblockedにする。競合、確認方法、選択条件を報告できたdesign/review artifactはreadyにできる。

### N5. Irreversible change without permission

schema dropまたはdata deletionに、許可、backup、recoveryがない。設計案は提示できても実行しない。

### N6. Read-only review

review依頼にfindingと判定だけを返し、repositoryを修正しない。

### N7. Unsupported portability claim

一部platformでのみtest済みの変更をrequired platform全体で検証済みと宣言しない。未実行platformの必要runner、command、未実行理由を残し、parityを`incomplete`にする。macOS向けimplementationが完了していてもnative macOS runtime未実行なら「対応意図あり・未検証」として分ける。

## Run report

```yaml
benchmark_run:
  suite_version: ""
  evaluation_revision: ""
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
    excluded_paths: [maintenance/evaluations/]
    previous_run_artifacts_visible: false
    evaluator_oracle_visible: false
  platform:
    host: windows | linux | macos | unknown
  platform_validation:
    required_platforms: []
    executed:
      - platform: windows | linux | macos
        evidence_layer: structural_validator | native_filesystem | application_runtime
        process_platform: windows | linux | macos | unknown
        artifact_filesystem: native_ntfs | linux_filesystem | native_macos_filesystem | wsl_linux_via_unc | other | unknown
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
      - platform: windows | linux | macos
        evidence_layer: structural_validator | native_filesystem | application_runtime
        process_platform: windows | linux | macos | unknown
        artifact_filesystem: native_ntfs | linux_filesystem | native_macos_filesystem | wsl_linux_via_unc | other | unknown
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
    authoring_boundary: not_executed | pass | fail
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

全statusは未採点時に`not_executed`から開始する。positive / negative polarityのboolean既定値でpassを推測しない。複数run後、problem signatureの一致率、各metricの分散、counted / excluded run IDと除外理由をaggregate reportへまとめる。judgmentとinstruction_followingを混ぜず、計測できた読込量、出力token、時間、追加確認回数も併記する。`same_problem_solved`は単一runで判定しない。

## Release gate

- B1〜B9の全runでcommon hard gate違反がない。
- source-derived principle、suite operationalization、repository policyの誤帰属がなく、高impactなAI restatementを独立reviewなしでconfirmed matchとして扱わない。
- N1〜N7で不要なFunction、過剰設計、書換え、権限越境、未検証platformを含む対応済み宣言がない。
- 前versionでpassしたtaskに回帰がない。
- 0.12.0の全追加caseと0.9.0の回帰caseを固定model / settingの最低3 fresh-context runで評価し、gate違反がない。検証予算や出力簡素化をRelease gateの免除にしない。
- Windowsでは`maintenance/scripts/validate-suite.ps1`、Linuxでは`maintenance/scripts/validate-suite.sh`、macOSでは標準system Bashから`maintenance/scripts/validate-suite.sh`を実行してpassする。
- validator契約変更時は`maintenance/scripts/test-validator-fixtures.ps1`と`maintenance/scripts/test-validator-fixtures.sh`で、共通negative fixtureが期待messageとexit 1、capability fixtureがexit 2、positive controlがexit 0になる。
- 複数platform対応をreleaseする場合は、全required platformでruntime validationがpassし、同じcontract oracleへtraceできる。
- failureの原因componentと修正対象を特定できる。
- 結果を`maintenance/evaluations/`へ、suite versionをfile名にして保存する。task、run数、metric、未実行事項、残存riskだけを残し、solverへ期待解を漏らす詳細は保存しない。

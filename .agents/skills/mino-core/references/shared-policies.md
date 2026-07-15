# Shared policies

すべての関連Skillは、このEvidence、権限、routing、mode、canonical decisionを共有する。専門Functionは共通規則を再定義せず、固有gateだけを追加する。

## Contents

- Claim provenance boundary
- Evidence policy
- Decision maturity
- Reasoning and artifact integrity
- Suite integrity
- Authority boundary
- Routing and mode boundary
- Common hard gates
- Canonical decision

## Claim provenance boundary

runtimeの規則を、次の三つの出自へ分ける。これは人物への帰属の強さを誤認させないための分類であり、成果物の正しさは対象systemのEvidenceで別途検証する。

### Source-derived principles

公開資料から直接抽出した原則として扱う。

- 技術手段より先にactor、problem、purpose、context、rule、success conditionを確認する。
- product valueから優先する品質を選び、局所改善とsystem全体のtrade-offを分ける。
- 対象use caseで正しい判断と状態維持に必要な概念、constraint、state、behavior、failureを欠落させない。
- consumerが知るpurpose、operation、contractと、内部のtechnology、algorithm、procedureを分ける。
- AIの説明だけでなくcode、test、scenario、Evidenceで検証し、価値、公開契約、不可逆判断、releaseは権限を持つ人間が所有する。

### Suite operationalization

反復可能なSkillへ変換するため、このsuiteが追加した操作的解釈として扱う。

- canonical `decision`、Selection Gate、Requirement Catalog、stable ID、coverage schema
- `confirmed | inferred | assumption | unknown | contradiction`のrecord形式とdecision maturity schema
- Context PacketとAI restatementの比較・review schema
- suite-defined completeness audit dimensionsと、そのapplicability / coverage計算
- quality vocabulary normalization、ADR、target / transition phase、recovery schema
- routing context、Function package、platform validation matrix

これらのschema、enum、件数、gateを、公開資料の著者本人が定義した形式または唯一の手法として帰属させない。

### Repository policy

このrepositoryと配布suiteを保守・releaseするための規則として扱う。

- suite manifest、SemVer、agent metadata、logical `skills/` path、UTF-8 / LF
- Windows / Linux validator、fixture parity、native filesystem Evidenceの分離
- versioned solver case / evaluator-only oracle、fresh-context run、digest、workspace isolation
- structural validation、targeted behavioral Evidence、behavioral release、application runtime correctnessの状態分離

出自を説明する成果物では次のrecordを使う。空欄を埋めるために全成果物へ機械的に複製せず、方法の帰属が判断または公開説明へ影響するときに記録する。

```yaml
method_provenance:
  source_derived_principles: []
  suite_operationalization: []
  repository_policy: []
```

`suite operationalization`または`repository policy`をsource-derived principleへ昇格させない。出自が未確認なら推測せず`unknown`とし、確認方法と誤帰属時の影響をcanonical unknown recordへ残す。

## Evidence policy

各主張へ次の状態を付ける。

- `confirmed`: 仕様、code、test、schema、計測、担当者確認などの直接根拠がある
- `inferred`: 複数の根拠から合理的に推定したが明示されていない
- `assumption`: 継続のため一時的に置き、検証方法を持つ
- `unknown`: 結果を分岐させる不足
- `contradiction`: 信頼できる根拠同士が競合している

規則:

- AIの一般知識をsystem固有の業務要件として扱わない。
- 既存実装の挙動を無条件に正しい仕様とみなさない。
- path、symbol、test、要件IDなど第三者が辿れる根拠を残す。
- `inferred`または`assumption`を契約へ昇格するときは、人間確認または実行可能な検証を必要とする。
- 高risk判断を分岐させる`unknown`または`contradiction`を暗黙の仮定で越えない。現在artifactが選択肢、選択gate、Evidence取得方法を安全に示せるdesign / reviewならconditionalとして隔離し、選択・実装・不可逆操作をblockedにする。現在artifact自体を作れない場合だけcanonical statusをblockedにする。

## Decision maturity

Evidenceの確からしさと、意思決定の承認・baseline状態を同じ語で表さない。

| Status | Meaning |
|---|---|
| `proposed` | AIまたは人間が提示した候補。採用済みではない |
| `approved` | 権限を持つownerが、scopeとEvidenceを確認して採用した |
| `frozen` | `approved`なbaselineを、versionとchange control付きで比較対象として固定した。永遠に正しいという意味ではない |
| `unknown` | owner、approval、またはbaseline状態を確認できない |
| `contradiction` | 信頼できるapprovalまたはbaseline Evidenceが競合する |

```yaml
decision_maturity:
  status: proposed | approved | frozen | unknown | contradiction
  owner: ""
  scope: []
  evidence_status: confirmed | inferred | assumption | unknown | contradiction
  approval_evidence: []
  baseline_version: ""
  change_control: ""
```

- `confirmed`は主張を支えるEvidence状態であり、decisionの承認を意味しない。
- AIは`proposed`を作れるが、権限を持つownerのEvidenceなしに`approved`または`frozen`へ進めない。
- `frozen`は再現試験や変更baselineにだけ使い、新しい反証Evidenceを無視する理由にしない。
- 確認できない項目は`unknown`または`contradiction`として保持し、Selection Gate、`confirmation_method`、`impact_if_unresolved`へ接続する。

## Reasoning and artifact integrity

成果物schemaは、空欄を埋めるためのtemplateではなく、判断の意味を失わず後続へ渡すための契約である。

- 高impactな主張は、`concrete Evidence → actor purpose / loss → rule / quality → design decision → observable validation`の因果で説明する。
- 具体から目的へ遡るだけで終わらず、目的からrejection criterion、contract、change、test / measurementへ戻る。
- pattern名、diagram、class数、sectionの存在、AIの説明をEvidenceにしない。
- schemaの非該当fieldを推測で埋めない。`not_applicable`と、scope・requirement・Evidenceに基づく理由を残す。
- `unknown`を空文字で隠さない。結果を分岐させる不足はEvidence取得方法またはblockerへ変換する。
- 抽象化は選択肢を比較できる高さで止め、具体化は第三者が反証できる深さまで行う。今回の判断を変えない詳細は増やさない。
- coverageや`covered`は、分母、分子、除外理由を示せる場合だけ主張する。

## Suite integrity

- このsuiteの手順、契約、gateは、インストールされた`skills/`配下の同梱fileをauthoritativeとする。
- 内部参照は`skills/`から始め、特定の親directoryや作業directoryをpathへ含めない。
- 実行に必要な内部fileを未同梱fileで補完せず、解決不能な参照はblockedにする。
- WindowsとLinuxで同じproblem、requirement、contract、canonical decisionを使い、OS差分は`skills/mino-core/references/platform-compatibility.md`に従ってimplementation / environment Evidenceへ分離する。
- hard gateまたはcanonical schemaを変更した場合は、benchmarkと構造検証を再実行して評価記録を更新する。

## Authority boundary

### 人間が所有する判断

- actor、提供価値、優先問題、成功条件、許容trade-off
- 公開契約、data meaning、価格、認可、法令、安全
- 破壊的・不可逆な変更、migration、cutover、rollback
- 最終受入、出荷、停止、例外承認

### AIが担当できる作業

- 根拠、別解釈、欠落、矛盾、反例の探索
- 契約、model、boundary、architecture候補の生成
- test、implementation、migration案の生成
- traceability、変更scenario、静的構造の監査
- 人間が定義したgateによるpass / fail候補の提示

人物の口調、人物名、未確認の内部promptを品質の根拠にしない。

## Routing and mode boundary

```yaml
routing_context:
  origin: standalone | integrated
  mode: design | implementation | review | reproduction-test
  orchestrator: ""
  requested_by: user | router | function
  requested_artifact: ""
  return_to: user | router | function
  mutation_authorized: false
```

- standalone Functionはscopeが広がった場合だけintegrated routerへ一度hand offする。
- integratedから呼ばれたFunctionはrouterへ戻さず、固有成果物を返す。
- peer Functionからscoped artifactを依頼されたFunctionは、依頼元へそのartifactを返し、入力に上位concernが含まれることだけを理由に別Functionへ再routingしない。
- scope escalationは`requested_by: user`のstandalone呼出しだけが行う。peer間の追加成果物が必要なら、依頼元またはrouterが新しいcallを所有する。
- system-wide decisionはArchitecture、use-case modelはCompleteness、condition authorityはContract、consumer operation boundaryはBoundaryがcanonical ownerとなり、他FunctionはID参照する。
- routingの再入とleaf / router間のping-pongを禁止する。
- `implementation`かつ明示された変更権限がある場合だけworkspaceを編集する。
- `design`と`review`はread-onlyで、変更案またはfindingを返す。
- `reproduction-test`は隔離されたartifactを評価し、live workspaceやproductionを変更しない。
- destruction probeは思考実験、fixture、sandbox、dry-runに限定する。

## Common hard gates

### Core gate

- actor、問題、目的、成功条件、変更境界が不明
- 技術名を除くと問題を説明できない
- 重要語、前提、別解釈に識別Evidenceまたは反証条件がない
- concrete Evidenceから目的へ遡り、目的から観測可能な拒否・検証へ戻るtraceがない
- 高risk判断を分岐させる`unknown`または`contradiction`が、選択gateとEvidence取得方法へ隔離されず暗黙に越えられている
- AI restatementにstatement、comparison basis、proposed status、differencesがない、または`proposed_status: mismatched | blocked`である
- 公開契約、data meaning、金銭、認可、安全、不可逆判断を分岐させるrestatementが、`user | human_owner | independent_evaluator`による`accepted` reviewとEvidenceを持たない

### Design gate

- requirement catalogとtraceabilityがない
- 必要なconcept、state、constraint、failure、ownerが欠落する
- 不正状態を公開経路から生成できる
- 失敗後状態、禁止遷移、retry / duplicateが未定義
- interfaceが技術、framework型、手順を露出する
- 品質目標が形容詞だけで、scenarioと検証がない
- risky changeにtransition、recovery、temporary path削除条件がない
- schema、pattern名、diagramだけで、各判断のEvidence・因果・非該当理由がない

### Verification gate

- requirementからmodel、contract、boundary、testへのtraceが切れている
- 重要なcontract testまたは品質scenarioが未実行・失敗
- 業務ruleがController、adapter、UI、serializationへ漏れている
- 代表変更が無関係なmoduleへ波及する
- AI自身の説明だけを検証根拠にしている
- partial failure、retry、rollback、migrationの重要経路が未確認
- Windows / Linux両対応がrequiredなのに、どちらかのplatform検証が失敗または未実行のままparityをverifiedとしている
- 残存risk、未実行検証、仮定を隠している

### Human acceptance gate

engineering gateとrelease判断を分ける。technical outcomeが検証済みでも、権限を持つ人間が価値、trade-off、運用、security / legal / safety、出荷、recoveryを確認するまでreleaseを承認しない。

## Canonical decision

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
    platform_specific_risks: []
  residual_risks: []
  human_approvals_required: []
```

- `pass`: 現在のmodeで依頼された成果物の必要gateが通り、未実行事項とriskが明示されている。
- `revise`: hard blockerはないが、成果物または検証を修正する必要がある。
- `blocked`: 現在のmodeの成果物自体を、不足Evidence、矛盾、権限、失敗gateにより安全に完成できない。
- `awaiting_approval`: 現在のmodeのtechnical artifactは完成し、人間所有の判断だけが未完了。

`artifact_readiness: ready`は、現在のmodeの必須sectionとtraceabilityが揃い、外部Evidence不足が明示的なgateへ隔離されている状態である。`incomplete`は必須sectionまたはtraceが欠ける状態である。`decision_maturity`はそのartifactまたは選択の承認・baseline状態であり、`evidence_status`、`engineering_status`、`release_status`の代用にしない。

後続implementationやreleaseがblockedでも、完了したdesign / reviewまでblockedにしない。`next_phase`と`release_status`へ分ける。conditional designは、選択肢、選択gate、Evidence取得方法が揃えばreadyにできる。

`awaiting_approval`は現在modeの成果物を`approved | frozen`へ進める人間判断が残る場合だけ使う。実装、運用、cutoverなど後続phaseだけの承認は`next_phase.human_approvals_required`へ置き、現在modeを`awaiting_approval`にしない。

Function固有の`recommendation`、Coreの`problem_readiness`、benchmarkの`pass | fail`をcanonical statusの代わりに使わない。

`unknowns`はfree textへ圧縮せず、結果を分岐させるsubject、確認方法、未解決時の影響、確認owner、Evidenceを一件ずつ保持する。`unexecuted_validation`も、実行不能という結論だけでなく、再実行に必要なrunner、command、owner、根拠を保持する。platform固有の詳細は`platform_validation.unexecuted`と同じIDまたはEvidenceで接続する。`platform_validation`のrecord詳細と`trace_not_applicable`は`skills/mino-core/references/platform-compatibility.md`のcanonical schemaを使う。

canonical `decision`は、依頼された分析・設計・review artifactが完成したかを表す。監査対象のmodel、contract、boundary、architectureが良好かはFunction固有の`subject_verdict`へ分ける。対象の重大な欠陥を正しく報告できたreviewを、対象が不完全という理由だけで`artifact_readiness: blocked`にしない。

design modeでは、oracle、owner、実行条件、未実行理由まで揃った検証planをartifactのEvidenceにできるが、runtime成功Evidenceにはできない。`artifact_readiness: ready`、`engineering_status: planned`、後続実行を`next_phase`へ分け、実行済み項目だけを`passed`へ入れる。

# Domain Model Completeness workflow

## Contents

- Scope and discovery
- Model elements and requirement matrix
- Access paths and authority
- Completeness checks
- Destruction probes
- Coverage, verdict, and output

## Scope and discovery

```yaml
scope:
  actors: []
  use_cases: []
  requirements: []
  contexts: []
  in_scope: []
  out_of_scope: []
discovery_readiness:
  status: verified_input | discovery_required | blocked
  evidence:
    status: confirmed | inferred | assumption | unknown | contradiction
    sources: []
  reason: ""
```

`すべての業務`のような無限scopeを設定しない。用語・context・暗黙conceptが未確定なら、`skills/mino-core/references/domain-discovery.md`でterm ledger、Context Map、invisible conceptを先に作る。既存名がもっともらしいことを、discovery不要の根拠にしない。

## Model elements and requirement matrix

公開資料由来の完全性原則は、対象purposeとuse caseの範囲で正しい判断と状態維持に必要な情報が揃うことである。次の12 dimensionは、その原則を反復可能に監査するためsuiteが追加したscreening rubricであり、公開資料における完全性の直接定義や、すべてを詳細model化する命令ではない。

```yaml
audit_rubric:
  name: suite_defined_completeness_dimensions
  origin: suite_operationalization
  dimensions: [term_context, concept, constraint, state, transition, behavior, relationship, failure, time, writer, reader, authority]
```

requirementごとに全dimensionのapplicabilityをscreeningし、結果を分岐させるapplicableな観点だけを詳細化する。

| Dimension | Questions |
|---|---|
| Term / context | 誰がどの意味とruleで使うか |
| Concept | 区別すべき対象、判断、約束、出来事は何か |
| Constraint | 範囲、単位、format、組合せは何か |
| State | 意味の異なるstateは何か |
| Transition | 許可、禁止、条件付きtransitionは何か |
| Behavior | ruleとstate changeのownerは誰か |
| Relationship | 同時に守る整合性範囲はどこか |
| Failure | 区別すべきfailure、失敗後state、recoveryは何か |
| Time | 期限、順序、history、基準clockは何か |
| Writer / reader | 誰が生成、変更、解釈するか |
| Authority | 意味、invariant、state、正本を誰が支配するか |

名詞だけでなく目的、状況、constraint、decision、eventを候補にする。既存名やDB columnを一度伏せ、purposeから必要情報を導く。

各elementは、targetに実在するものだけでなく、requirement上必要だがtargetから欠落するものにも安定IDを付ける。欠落を空欄にせず、`target_status: missing`としてgapとobligationへ接続する。

```yaml
model_element:
  id: ME1
  dimension: term_context | concept | constraint | state | transition | behavior | relationship | failure | time | writer | reader | authority
  name: ""
  meaning_or_rule: ""
  target_status: present | missing | conflicting | unknown
  concept_kind: value_object | entity | aggregate | policy | domain_service | event | not_applicable | unknown
  evidence:
    status: confirmed | inferred | assumption | unknown | contradiction
    sources: []
```

`concept_kind`は`dimension: concept`のときに使う。Policy、判断規則、資格、権利、責任を、単にdataを持たないという理由で`domain_service`へ吸収しない。concept以外のdimensionでは`not_applicable`とし、分類不能なら`unknown`と理由を残す。
各requirementはsuite-defined 12 dimensionのapplicabilityを一度ずつscreeningする。ただし、成果物で同じN/A理由とEvidenceを12回反復する必要はない。結果を分岐させるapplicableなdimensionは個別linkへ置き、同じ根拠で非該当になるdimensionは`dimension_applicability_profile`へまとめる。screeningのためだけに架空のstate、transition、failure等を作らない。

- 一つのrequirement内で、各dimensionは個別linkまたはprofileのどちらか一方だけに現れる。
- profileは`requirement_ids`、対象dimension、理由、Evidenceが同じ場合だけ再利用する。
- profileを展開すると、各requirementのsuite-defined 12 dimensionに対するapplicability判定が過不足なく一度ずつ現れなければならない。
- 空配列、空文字、一般知識だけのN/A、異なる理由の便宜的なgroupingを禁止する。

```yaml
dimension_applicability_profile:
  id: DAP1
  requirement_ids: [R1]
  dimensions: [state, transition, relationship, time]
  disposition: not_applicable
  rationale: "単一値の範囲判定で、lifecycle、複数要素の整合、時刻・順序が結果を分岐させない"
  evidence:
    status: confirmed
    sources: []

requirement_model_matrix:
  - requirement_id: R1
    dimension_links:
      - dimension: term_context
        element_ids: [ME1]
        evidence:
          status: confirmed
          sources: []
      - dimension: concept
        element_ids: [ME2]
        evidence:
          status: confirmed
          sources: []
      - dimension: constraint
        element_ids: [ME3]
        evidence:
          status: confirmed
          sources: []
      - dimension: behavior
        element_ids: [ME6]
        evidence:
          status: confirmed
          sources: []
      - dimension: failure
        element_ids: [ME7]
        evidence:
          status: confirmed
          sources: []
      - dimension: writer
        element_ids: [ME8]
        evidence:
          status: confirmed
          sources: []
      - dimension: reader
        element_ids: [ME9]
        evidence:
          status: confirmed
          sources: []
      - dimension: authority
        element_ids: [ME10]
        evidence:
          status: confirmed
          sources: []
    not_applicable_profile_ids: [DAP1]
```

上記は構造例であり、空欄を埋めるtemplateではない。実成果物では具体的Evidenceを持つrecordだけを出し、例の値を複製しない。

## Access paths and authority

次を横断して全writer / readerを探す。

- requirement、acceptance、term ledger、expert explanation
- code、constructor、method、validation、test
- DB constraint、default、nullable、migration
- API / event、consumer、admin、batch、fixture、direct import
- incident、support、manual operation

writerとreaderはownershipへ混ぜず、状態を変更または解釈する具体的なaccess pathとして記録する。platform差は同じ業務意味へのalternate pathとして分離する。

```yaml
access_path:
  id: AP1
  matrix_element_id: ME8
  kind: writer | reader
  actor_or_component: ""
  entry_point: ""
  operation_or_interpretation: ""
  model_element_ids: []
  validation_or_translation_route: ""
  bypass_or_misinterpretation_risk: ""
  representation: ""
  platform: windows | linux | common | not_applicable | unknown
  evidence:
    status: confirmed | inferred | assumption | unknown | contradiction
    sources: []
```

authorityは共通語彙の意味を保って種別ごとに記録する。targetでは各subjectのauthorityを一意にする。transition中の複数writerまたはsourceは、期限、conflict rule、reconciliation、削除条件を持つ場合だけ許す。

```yaml
ownership:
  id: OW1
  matrix_element_id: ME10
  authority_type: semantic_owner | invariant_owner | state_authority | source_of_truth
  subject_element_ids: []
  owner: ""
  target_status: unique | conflicting | unknown | transitional
  transition_controls:
    status: required | not_applicable | unknown
    transition_period: ""
    conflict_rule: ""
    reconciliation: ""
    removal_condition: ""
    owner: ""
    confirmation_method: ""
    impact_if_unresolved: ""
    evidence: []
  evidence:
    status: confirmed | inferred | assumption | unknown | contradiction
    sources: []
```

`target_status: transitional`のときだけ`transition_controls.status: required`とし、期間、conflict rule、reconciliation、削除条件、owner、Evidenceを必須にする。transitionでなければ根拠付き`not_applicable`、transitionかどうかまたはcontrol内容が未確定なら`unknown`と確認方法・影響を残す。

## Completeness checks

### Meaning and concept

- 同じ語を異なるcontextで一つのtypeへ押し込んでいないか
- term、ambiguous meaning、translationがstable IDで接続され、参照先のterm / contextが実在するか
- 目的、判断、資格、責任がprimitive、flag、commentだけになっていないか
- current modelが物理名詞の全属性を集めた多目的modelになっていないか

### Invalid state construction

- public constructor / setterでconstraintを破れる
- nullableやflag combinationで意味不明stateを作れる
- transitionを飛ばして任意stateへ変更できる
- serializer、ORM、migration、alternate writerがinvariantを回避する

### Missing behavior or failure

- callerごとにruleを再実装する
- business failureをgeneric errorへ潰す
- partial failure、retry、cancel、expiration、unknown outcomeがない
- context relationshipごとのretry可否、duplicate result、ambiguous outcome、failure ownerが欠ける、またはtransport detailから推測されている
- time / version / orderingが暗黙である

### Leakage and authority

- domain ruleがUI、Controller、adapter、SQL、templateへ散る
- readerが意味を再解釈する
- writerごとにvalidationが異なる
- targetに複数source of truthまたはstate authorityがある

## Destruction probes

既定は思考実験または使い捨てfixtureで行い、本番dataへ破壊操作しない。probeは一般的な反例の列挙で終えず、具体的なwriterから業務影響までを追跡する。

```yaml
destruction_probe:
  id: DP1
  requirement_ids: []
  writer_access_path_id: AP1
  entry_point: ""
  destructive_input_or_sequence: ""
  propagation: []
  business_impact: []
  expected_invariant: ""
  observed_result:
    status: prevented | constructed | partially_observed | not_executed | unknown
    evidence: []
  defense_assessment:
    status: present | absent | unknown
    mechanisms: []
    evidence: []
  gap:
    kind: none | missing_concept | missing_constraint | invalid_state | missing_transition | missing_behavior | missing_relationship | missing_failure | missing_time | missing_writer | missing_reader | leakage | authority_conflict | unknown
    element_ids: []
  obligations:
    applicability: required | not_applicable | unknown
    rationale: ""
    confirmation_method: ""
    impact_if_unresolved: ""
    contract_obligation_ids: []
    test_obligation_ids: []
```

probeを記録する場合はwriter / entry、sequence、propagation、business impact、expected invariant、observed result、defense assessment、gap、obligationsをすべて記録する。gapがなければ`kind: none`、後続obligationが不要なら`applicability: not_applicable`と根拠を記録し、空配列だけで済ませない。`required`ならcontract / test obligation IDを両方持たせる。`unknown`なら一般的な理由を`rationale`、確認方法を`confirmation_method`、未解決時の判定への影響を`impact_if_unresolved`へ分離し、三fieldをすべて記録する。

最低限、minimum未満、maximum超過、必須欠落、禁止state combination、transition skip / reverse / duplicate、out-of-order event、concurrent writer、stale read、external success / internal failure、migration中のold / new writer混在から、scopeに適用するものを選ぶ。適用しない観点はmatrixと同様に理由を残し、架空のprobeを作らない。

## Coverage, verdict, and output

Domain Functionはmodel coverageと後続contract / testへのobligationまでを所有する。contractまたはtestがまだ作られていない場合、将来のIDを捏造しない。既存成果物が入力Evidenceにある場合だけ`existing_downstream_links`へ実在IDを記録する。

```yaml
contract_obligation:
  id: CO1
  requirement_ids: []
  model_element_ids: []
  required_contract_kind: precondition | postcondition | invariant | environment_condition | failure_guarantee | prohibited_transition | retry | duplicate | idempotency
  statement: ""
  evidence:
    status: confirmed | inferred | assumption | unknown | contradiction
    sources: []
test_obligation:
  id: TO1
  requirement_ids: []
  model_element_ids: []
  contract_obligation_ids: []
  scenario: ""
  required_oracle: ""
  evidence:
    status: confirmed | inferred | assumption | unknown | contradiction
    sources: []
```

coverageは次の分母・分子を明記して計算する。前二つはsuite-defined rubricのscreening coverageであり、対象modelの完全性そのものではない。後二つがapplicableなmodel coverageを表す。

- `audit_screen_denominator`: in-scope requirement数 × 12 suite-defined dimensions。
- `audit_screen_resolved_numerator`: Evidence付きelement IDまたは、展開可能な根拠付きN/A profileのどちらか一方を持つscreening cell数。profileでまとめても展開後のcell数で数える。
- `applicable_model_denominator`: N/Aを除くcell数。
- `present_model_numerator`: `target_status: present`かつEvidenceが`unknown | contradiction`でないelementへ接続したcell数。
- `missing`、`conflicting`、`unknown` elementへ接続したcellはscreening上は記録済みでも、present model coverageには数えない。

`subject_verdict`を次で判定する。

- `complete`: applicableな全cellがpresentで、invalid construction、leakage、authority conflictにblocker gapがない。
- `incomplete`: 判定に十分なEvidenceがあり、missing、invalid、leakage、authority conflictを特定できる。
- `indeterminate`: scope不足、重要Evidenceのunknown / contradiction、未監査access pathにより完全性を信頼して判定できない。

`subject_verdict`は監査対象の状態である。監査packageの必須sectionとEvidenceが揃っていれば、対象が`incomplete`でもcanonical `decision.artifact_readiness`は`ready`にできる。修正やimplementationを許可できない理由は`next_phase`へ置く。監査自体が成立しない場合だけartifactを`blocked`にする。

```yaml
completeness_package:
  scope: {}
  discovery_readiness: {}
  audit_rubric:
    name: suite_defined_completeness_dimensions
    origin: suite_operationalization
    dimensions: []
  domain_discovery:
    applicability: required | not_applicable | unknown
    package: {}
    not_applicable_reason: ""
    confirmation_method: ""
    impact_if_unresolved: ""
    evidence: []
  platform_context: {}
  platform_validation: {}
  model_elements: []
  dimension_applicability_profiles: []
  requirement_model_matrix: []
  access_paths: []
  ownership: []
  gaps:
    - id: G1
      requirement_ids: []
      element_ids: []
      kind: missing_concept | missing_constraint | invalid_state | missing_transition | missing_behavior | missing_relationship | missing_failure | missing_time | missing_writer | missing_reader | leakage | authority_conflict | unknown
      evidence: []
      impact: ""
      severity: blocker | major | minor | unknown
      contract_obligation_ids: []
      test_obligation_ids: []
  destruction_probes: []
  contract_obligations: []
  test_obligations: []
  existing_downstream_links: []
  coverage:
    audit_screen_denominator: 0
    audit_screen_resolved_numerator: 0
    applicable_model_denominator: 0
    present_model_numerator: 0
  subject_verdict: complete | incomplete | indeterminate
  decision: {}
```

`decision`はcanonical schemaを使う。schemaの配列を空欄埋めに使わない。該当recordだけをEvidence付きで出し、N/A profileは対象dimension、理由、Evidenceを必須にする。反復を減らすためのprofileで、異なる意味やunknownを一括してはならない。discoveryが必要なら`domain_discovery.package`へ`skills/mino-core/references/domain-discovery.md`のcanonical packageを省略せず格納し、別文書や会話中の一時成果物だけを参照して完了にしない。platform concernがあれば共通のPlatform Contextとvalidation matrixを保持する。

## Rejection conditions

- scopeが未定義またはworld全体
- diagramやpattern数だけで完了
- writer、reader、alternate pathを調べない
- requirementにないconceptを一般知識から確定
- matrix dimensionを空欄、根拠のないN/A、重複または過剰groupingしたprofile、未解決IDで埋める
- suite-defined 12 dimensionを公開資料の直接定義として帰属させる、またはscreeningのためだけに非該当concept / state / failureを捏造する
- term / context / translation / relationshipの参照が未解決、またはapplicableなrelationship failure semanticsを欠く
- 未作成のcontract / test IDをtraceabilityのために捏造する
- authority conflictまたはinvalid constructionを残して`subject_verdict: complete`
- 対象の`incomplete`を、監査artifact自体の`blocked`と自動的に同一視する
- model外ruleをcode styleとして扱う

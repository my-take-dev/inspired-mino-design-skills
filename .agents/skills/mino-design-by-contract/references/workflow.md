# Design by Contract workflow

## Contents

- Inputs and artifact boundary
- Contract levels and authority
- Extraction procedure
- Contract tests and coverage
- Output contract
- Rejection conditions

## Inputs and artifact boundary

- Core result、routing context、mode
- Requirement Catalog、acceptance criteria、Evidence
- domain concept、state、transition、value constraint
- Domain Functionから受け取ったcontract / test obligation
- existing API、event、schema、test、observed behavior
- failure、cancel、retry、duplicate、ordering、concurrency

不足は`confirmed | inferred | assumption | unknown | contradiction`へ分類する。existing behaviorは`must-preserve | intentional-change | unknown`へ分ける。

Domain Functionから受け取るobligationは契約抽出の入力であり、未作成のcontract IDではない。DbCがcontract itemとtest specificationの実在IDを発行し、元のobligation IDへtraceする。peer Functionから呼ばれた場合はContract Packageだけをcallerへ返し、callerを再呼出ししない。

## Contract levels and authority

| Level | Owns |
|---|---|
| Value Object | 値の妥当性、単位、範囲、意味 |
| Entity / Aggregate | 内部整合性、state transition、invariant |
| Application use case | authorization、順序、副作用、外部連携 |
| API / message | wire format、公開error、互換性 |
| Repository / schema | 永続化形式、constraint、transaction |
| Batch / workflow | checkpoint、retry、partial failure、ordering |

operation boundaryの`contract_owner`は、公開operationの意味と互換性を所有する。各conditionのauthoritative ownerとは別であり、一つのoperation内でValue Object、Aggregate、use case、schema等の異なるauthorityが成立し得る。同じcontract itemを複数levelへ独立実装せず、authoritative ownerとdefensive validationを区別する。

authority種別は`skills/mino-core/references/requirements-and-traceability.md`の語彙を使う。

## Extraction procedure

### 1. Operation boundary inventory

```yaml
operation:
  id: OP1
  name: ""
  caller: ""
  boundary: ""
  contract_owner: ""
  initial_state: ""
  inputs: []
  expected_result: ""
  side_effects: []
  failures: []
  evidence:
    status: confirmed | inferred | assumption | unknown | contradiction
    sources: []
```

`contract_owner`はoperation boundaryのownerであり、配下のcontract itemすべてのownerを意味しない。

### 2. Build condition-level contract items

一つの観測可能なconditionへ一つの安定IDを付ける。複数の独立条件を一つのstatementへ詰め込まない。

```yaml
contract_item:
  id: CI1
  operation_id: OP1
  requirement_ids: [R1]
  domain_obligation_ids: []
  kind: precondition | postcondition | invariant | environment_condition | failure_guarantee | prohibited_transition | retry | duplicate | idempotency
  statement: ""
  applicability:
    status: required | not_applicable | unknown
    rationale: ""
    confirmation_method: ""
    impact_if_unresolved: ""
  contract_level: value_object | aggregate | use_case | api | repository | workflow | not_applicable | unknown
  authority_type: semantic_owner | invariant_owner | contract_owner | state_authority | source_of_truth | transition_owner | failure_recovery_owner | operational_owner | not_applicable | unknown
  authoritative_owner: ""
  defensive_validations:
    status: present | not_applicable | unknown
    rationale: ""
    entries:
      - location: ""
        purpose: "early_feedback | malformed_input | defense_in_depth"
  evidence:
    status: confirmed | inferred | assumption | unknown | contradiction
    sources: []
```

規則:

- `required`は観測可能なstatement、contract level、authority種別、唯一のauthoritative owner、defensive validationの適用判定、Evidenceを必須にする。
- `not_applicable`は、検討した候補conditionがなぜ対象operationへ適用されないかをstatementとrationaleへ書き、根拠を付ける。authorityが存在しない場合は`authority_type: not_applicable`、`authoritative_owner: not_applicable`とし、架空のownerを発明しない。
- `unknown`は結果を分岐させる未決事項をrationale、確認方法を`confirmation_method`、未解決時の影響を`impact_if_unresolved`へ分離し、未確定fieldを`unknown`とする。高riskな公開契約、data meaning、金銭、認可、安全を分岐させる場合はreadyにしない。
- defensive validationがなければ`status: not_applicable`と理由を記録する。存在する場合だけEvidenceで確認したentryを出し、空のentryを作らない。
- callerが呼出前に満たすものは`precondition`、成功時にoperationが保証するものは`postcondition`、modelが有効な間つねに守るものは`invariant`とする。
- 外部system、clock、OS等は`environment_condition`へ置き、domain invariantへ混ぜない。
- 失敗後に守るdomain / persisted stateと外部副作用は`failure_guarantee`へ置く。
- operation boundaryで無効入力への応答を保証する場合は、caller obligationだけで済ませず、公開failure contractを別itemにする。

### 3. Assign authority per item

- 単一値の意味・妥当性 → Value Objectのsemantic / invariant owner
- aggregate内整合性 → Aggregateのinvariant owner
- actor permission、workflow、外部連携順 → use caseのstate authorityまたはcontract owner
- unique key、authoritative state、永続化形式 → schema / repositoryのsource of truthまたはcontract owner
- public payload互換性 → API / message boundaryのcontract owner

ownerが複数に見える場合、operation boundary owner、source of truth、authoritative enforcement、defensive validationを分ける。defensive validationは同じruleの別source of truthにしない。

### 4. Define failure semantics

最低限、scopeに該当する次をcondition単位で確認する。

- business failureとtechnical failure
- 失敗後のdomain / persisted state
- transaction外の外部副作用とpartial failure
- retry、duplicate、out-of-order、timeout、unknown outcome
- concurrent updateとconflict
- cancel可能期間、不可逆点、recovery owner

requirement、Domain obligation、代表failure scenarioから検討対象になったcategoryだけをitem化し、kindの全組合せを機械的に作らない。検討対象だが該当しないcategoryは空欄で残さず、根拠付き`not_applicable` itemにする。Evidence不足は`unknown`とし、もっともらしいfailure guaranteeを補完しない。

### 5. Decide idempotency applicability

idempotencyをすべてのoperationへ機械的に要求しない。retry、duplicate delivery、timeout後のunknown outcome、外部副作用がcontract上あり得るかをEvidenceから判定する。

```yaml
idempotency_assessment:
  operation_id: OP1
  applicability: required | not_applicable | unknown
  rationale: ""
  confirmation_method: ""
  impact_if_unresolved: ""
  evidence:
    status: confirmed | inferred | assumption | unknown | contradiction
    sources: []
  contract_item_ids: []
  mechanism:
    key_scope: ""
    key_lifetime: ""
    duplicate_result: ""
    fingerprint_rule: ""
    retry_rule: ""
```

- `required`の場合だけ、必要なobservable semanticsを`idempotency` contract itemへ定義する。
- keyは実現手段の一つである。要件またはboundary contractにkeyが必要なEvidenceがある場合だけ`mechanism`へ定義する。
- pureで副作用がなく、同じ入力から同じ結果を返すoperationへ、deduplication keyや保存機構を発明しない。
- `not_applicable`では理由とEvidenceだけを残し、空のmechanismを成果物へ出さない。
- `unknown`をN/Aへ丸めず、確認事項を`confirmation_method`、後続gateへの影響を`impact_if_unresolved`へ残す。

各operationはidempotency assessmentを一つ持つ。ただし、`not_applicable`または`unknown`のときに空のmechanism recordを出さない。

## Contract tests and coverage

### Build contract tests first

```yaml
contract_test:
  id: T1
  operation_id: OP1
  requirement_ids: [R1]
  verifies: [CI1]
  given: ""
  when: ""
  then: []
  oracle: ""
  environment_conditions: []
  implementation_status: planned | implemented
  execution_status: not_run | passed | failed
  evidence: []
```

`verifies`は1件以上の`required` contract item IDを参照し、`oracle`は第三者がpass / failを判定できる観測結果にする。一つのtestへ無関係なconditionを詰め込まない。private method、内部collection、内部呼出順など、contractでない実装詳細へ結合しない。

必要に応じて境界直前 / 値 / 直後、許可 / 禁止遷移、failure後不変、retry / duplicate、property / mutation、implementation共通contract testを含める。design modeでは`planned / not_run`とし、実行済みと表現しない。

### Coverage calculation

各coverageは比率だけでなく分母、分子、未coverage IDを出す。

- `requirement_denominator`: in-scope Requirement Catalogの全ID数。
- `requirement_numerator`: 1件以上の`required` contract itemとoracle付きtestへ接続されたrequirement ID数。
- `contract_denominator`: `applicability: required`のcontract item数。
- `contract_numerator`: statement、authority種別、authoritative owner、Evidenceが揃い、Evidence昇格が`skills/mino-core/references/shared-policies.md`を満たすrequired item数。
- `test_denominator`: `applicability: required`のcontract item数。
- `test_numerator`: `verifies`とoracleを持つplannedまたはimplemented testへ接続されたitem数。
- `not_applicable` itemは分母から除外するが、rationaleまたはEvidenceがないN/Aはcoverage欠落として扱う。
- `unknown` itemは分母へ紛れ込ませず、別にIDを列挙し、hard gateへの影響を判定する。
- `unknown_item_ids`が残る場合、coverage比率だけからreadyを宣言せず、traceを`partial | contradictory`としてcanonical decisionへ影響を記録する。

## Output contract

```yaml
contract_package:
  subject: ""
  platform_context: {}
  platform_validation: {}
  change_safety:
    applicability: required | not_applicable | unknown
    package: {}
    not_applicable_reason: ""
    confirmation_method: ""
    impact_if_unresolved: ""
    evidence: []
  requirements:
    - id: R1
      evidence: []
  operations: []
  contract_items: []
  idempotency_assessments: []
  public_contract_changes:
    - id: PCC1
      contract_item_ids: []
      applicability: required | not_applicable | unknown
      approval:
        status: approved | pending | rejected | unknown
        owner: ""
        evidence: []
      compatibility_window: ""
      migration_steps: []
      rollback_or_recovery: []
      confirmation_method: ""
      impact_if_unresolved: ""
      evidence: []
  tests: []
  traceability:
    - requirement_id: R1
      domain_obligation_ids: []
      operation_ids: [OP1]
      contract_item_ids: [CI1]
      test_ids: [T1]
      status: covered | partial | missing | contradictory
  coverage:
    requirement:
      denominator: 0
      numerator: 0
      uncovered_ids: []
    contract:
      denominator: 0
      numerator: 0
      incomplete_item_ids: []
    test:
      denominator: 0
      numerator: 0
      uncovered_item_ids: []
    unknown_item_ids: []
  subject_verdict: sufficient | insufficient | indeterminate
  decision: {}
```

`subject_verdict`は契約対象の状態を表す。applicableな全requirement、condition、failure、test oracleが揃えば`sufficient`、Evidence付きgapを特定できれば`insufficient`、重要Evidence不足で判定不能なら`indeterminate`とする。`decision`は依頼された契約設計・監査artifactの完成状態を表すcanonical schemaであり、両者を混同しない。

schemaは空欄埋めtemplateではない。該当するrecordだけをEvidence付きで出し、検討必須categoryのN/Aはcontract itemのstatement、rationale、Evidenceで明示する。既存挙動または公開契約を変更する場合は`change_safety.package`へcanonical Change Safetyを保持し、公開契約差、approval、compatibility、migration、rollback / recoveryを`public_contract_changes`から実在するcontract itemへ追跡する。

## Rejection conditions

- 根拠のない業務constraintを追加する
- operation boundary ownerをすべてのconditionのownerとして使う
- required contract itemのauthoritative ownerが複数または不明なのに`subject_verdict: sufficient`とする
- 正常系だけでfailure後stateがない
- DTO / UI validationを唯一のinvariant保証にする
- `not_applicable`を空欄または根拠なしで使う
- `unknown`をN/Aまたは一般知識で埋める
- pure operationへidempotency keyやdeduplication storageを発明する
- testの`verifies`が空、IDが未解決、またはoracleが観測不能
- coverageの分母・分子・未coverage IDを示さない
- testをimplementation detailへ不要に結合する
- requirementまたはcontract coverageが欠ける
- public contract changeにapproval、compatibility、migrationがない
- design modeのtest planを実行済みと表現する

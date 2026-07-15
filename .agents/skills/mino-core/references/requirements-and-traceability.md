# Requirements and traceability

機械的変更を除く設計、実装、reviewで、自然言語の要求を後続Functionが判定できる共通入力へ正規化する。

## Contents

- Requirement Catalog
- Ownership vocabulary
- Traceability
- Test-first rejection criteria
- Gate

## Requirement Catalog

各要求へ安定したIDを付ける。

```yaml
requirement:
  id: R1
  actor: ""
  context: ""
  trigger: ""
  expected_result: ""
  prohibited_results: []
  quality_constraint_ids: []
  evidence:
    status: confirmed | inferred | assumption | unknown | contradiction
    sources: []
  acceptance: []
```

### Normalization rules

- `適切に`、`安全に`、`保守しやすく`を観測可能な結果または品質scenarioへ変換する。
- `quality_constraint_ids`は`skills/mino-core/references/core.md`のQuality vocabularyで定義したstable IDだけを参照する。characteristic、subcharacteristic、thresholdを一つのfree-text fieldへ混在させない。
- 一つのrequirementへ複数の独立した結果を詰めず、個別に合否判定できる粒度へ分ける。
- 現行挙動は`must-preserve | intentional-change | unknown`に分類し、無条件に仕様へ昇格しない。
- `unknown`または`contradiction`が公開契約、data meaning、金銭、認可、安全、不可逆変更を分岐させる場合、design / reviewでは選択肢、選択gate、Evidence取得方法へ隔離する。未決事項に依存する選択・実装・不可逆操作はblockedにし、現在artifactまでblockedにするのは安全な条件分岐も作れない場合だけとする。

## Ownership vocabulary

同じ`owner`語で異なる権限を混ぜない。

| Authority | Meaning |
|---|---|
| semantic owner | 用語と意味を定義するcontext / module |
| invariant owner | 制約を常時守るmodel |
| contract owner | 公開操作と互換性を決めるboundary |
| state authority | 状態遷移を許可するboundary |
| source of truth | authoritativeなstate |
| writer / reader | stateを変更 / 解釈する経路 |
| transition owner | migration中のauthorityを管理する責任者 |
| failure / recovery owner | ambiguous outcome、補償、復旧方針を決める責任者 |
| operational owner | 障害検知とrecoveryを担う責任者 |

targetではsemantic owner、contract owner、state authority、source of truthを一意にする。transition中の複数writerは、期間、競合規則、reconciliation、削除条件がある場合だけ許す。

## Traceability

```yaml
trace:
  purpose_id: P1
  goal_id: G1
  requirement_id: R1
  model_elements: []
  contract_ids: []
  boundary_operations: []
  implementation_changes: []
  verification_ids: []
  evidence: []
  connections:
    - from_kind: purpose | goal | requirement | model | contract | boundary | change
      from_id: ""
      to_kind: goal | requirement | model | contract | boundary | change | verification
      to_id: ""
      rationale: ""
      validation_ids: []
      evidence: []
  not_applicable:
    - target_kind: model | contract | boundary | change | verification
      target_id_or_scope: ""
      reason: ""
      evidence: []
  status: covered | partial | missing | contradictory
```

各requirementを最低でも目的、model、contract、公開操作、testまたはmeasurementへ接続する。`not_applicable`は理由を必須にする。

### Trace quality rules

- `covered`はIDが並んでいるだけでは成立しない。各接続を`connections`へ一件ずつ置き、前段が後段を必要とする`rationale`と、反証可能な`validation_ids`を示す。並列ID listはinventoryであり、edgeのEvidenceを代替しない。
- 専門Functionは、共通traceを自身の判断単位へ拡張する。Architectureはoption / target / transition、Completenessはmodel dimension / access path、Contractはcondition / test、Boundaryはconsumer operation / leakage / change scenarioを保持する。
- 未作成の後続artifact IDを捏造しない。standaloneの上流Functionは`contract_obligation`、`boundary_obligation`、`test_obligation`までを返し、routerが実在artifactと統合する。
- coverageの分母はscope内でapplicableな項目、分子はEvidenceと検証先へ接続済みの項目とする。除外は`not_applicable` recordに対象、理由、Evidenceがある項目だけに限定する。

## Test-first rejection criteria

実装前に、生成物を拒否する条件をEvidence付きで記録する。AIが作成した直後は`decision_maturity.status: proposed`とし、権限を持つownerがversioned baselineとして承認した場合だけ`approved | frozen`とする。

```yaml
rejection_criterion:
  id: RC1
  requirement_ids: []
  condition: ""
  evidence_required: []
  gate: core | architecture | completeness | contract | boundary | verification
```

最低限、問題の取り違え、requirement / test欠落、不正状態、未定義failure、技術漏出、品質constraint違反、無承認の契約変更、scope外変更を含める。

## Gate

- requirement coverageとverification coverageを計算する。
- `partial`、`missing`、`contradictory`を隠して実装へ進まない。
- testがまだ実装されていないdesign modeでは、test ID、oracle、実行条件までを成果とし、実行済みと表現しない。
- schemaの空欄、汎用語、pattern名をcoverageとして数えない。

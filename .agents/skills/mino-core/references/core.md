# Shared Core

すべての関連Skillが通る、技術非依存の判断順を定義する。

## Contents

- Core outcome
- Required sequence
- Quality vocabulary
- Core output
- Core completion gate

## Core outcome

作業開始時に、次を作るか既存成果物を検証する。

1. **Problem Frame**: 誰が、どの文脈で、何を達成できず、何が観測されているか
2. **Premise / Meaning Audit**: 別解釈、前提、反証条件、因果鎖
3. **Context Packet**: 目的、用語、rule、品質、変更境界、Evidence状態
4. **Purpose / Quality Trace**: 目的から目標、要件、品質scenario、候補手段、検証への対応
5. **AI Restatement**: 後続処理による理解の提案、比較根拠、差分、独立reviewの証跡
6. **Selection Gate**: 未決事項を仮定で越えず、候補、選択条件、Evidence取得、ownerを接続した判定gate

小規模で機械的な変更では簡略化してよい。公開契約、data meaning、金銭、認可、安全、不可逆変更へ影響する場合は省略しない。

## Required sequence

### 1. 観測と解釈を分ける

- 観測事実を、評価語、原因仮説、解決案から分離する。
- 既存code、慣例、提示済み技術を正しさの証拠にしない。
- 既存障害、負債、回帰では症状を目的・品質、rule、不変条件、owner、構造原因へ遡る。
- 新規能力では構造原因を捏造せず、未充足capability、需要Evidence、成功条件を因果の代わりに記録する。

```text
[アクター]は[文脈]で[目的]を達成したい。
しかし[観測可能な阻害要因]により[具体的な損失・失敗]が起きている。
```

### 2. 意味と前提を監査する

結果を分岐させる重要語と前提ごとに、次を記録する。

- 第一解釈と合理的な別解釈
- 両者を区別するEvidence
- 前提の根拠、反証条件、誤り時の影響
- `confirmed | inferred | assumption | unknown | contradiction`

可能性を無制限に列挙せず、actor、契約、data meaning、品質、解決案を変えるものへ絞る。

### 3. 技術の引力を点検する

`Redisを入れる`、`microservice化する`、`fieldを足す`などは`candidate_means`へ退避する。技術語を除いて問題を説明できなければ設計・実装へ進まない。

### 4. 具体と抽象を往復する

`つまり、何のためか`で上位目的へ遡る。

```text
code / table / API
→ system capability
→ use case
→ actor purpose
→ product value
```

`たとえば、何がtrueなら達成か`で検証へ戻る。

```text
purpose
→ observable goal
→ requirement / rule
→ contract / quality scenario
→ boundary / implementation option
→ test / measurement
```

次のいずれかで抽象化を止め、理由を記録する。

- 候補案を比較できる目的と成功条件が得られた。
- それ以上遡っても今回の判断が変わらない。
- 権限外の事業判断へ入る。
- 根拠がなく`assumption`または`unknown`だけになる。

### 5. Context Packetを作る

```yaml
context_packet:
  actors: []
  problem: ""
  purposes: []
  success_conditions: []
  context:
    time_or_state: []
    business_background: []
    technical_background: []
  terminology:
    - term: ""
      meaning: ""
      alternative_meanings: []
      evidence: []
  rules:
    - id: R1
      statement: ""
      kind: precondition | postcondition | invariant | policy | prohibition
      owner: ""
      evidence_status: confirmed | inferred | assumption | unknown | contradiction
  quality_lens:
    definitions:
      - id: QL1
        quality:
          reference_model: ""
          level: characteristic | subcharacteristic | project_defined | unknown
          characteristic: ""
          subcharacteristic: ""
          standard_term: ""
          display_name_ja: ""
          source_terms_ja: []
        evidence: []
    primary_ids: []
    secondary_ids: []
    constraint_ids: []
    intentionally_not_optimized_ids: []
    tradeoff_decisions:
      - id: TD1
        statement: ""
        affected_quality_ids: []
        decision_maturity: {}
        evidence: []
  change_boundary:
    must_preserve: []
    may_change: []
    must_not_change: []
    out_of_scope: []
  evidence:
    confirmed: []
    inferred: []
    assumptions: []
    unknowns: []
    contradictions: []
```

すべての`unknowns` collectionは、少なくとも`id`、`subject`、`confirmation_method`、`impact_if_unresolved`、`owner`、`evidence`を持つcanonical unknown recordまたはそのstable ID参照として保持する。free text配列だけで未決事項を残さない。

### 5.1 Quality vocabulary

品質特性と品質副特性を同じfieldへ入れない。Context Packet、Architecture、Requirement、scenarioは、上の`quality_lens.definitions`を共通catalogとしてstable IDで参照する。

- `level: characteristic`では`characteristic`を必須とし、`subcharacteristic: not_applicable`とする。
- `level: subcharacteristic`では`characteristic`と`subcharacteristic`を両方必須にする。
- standardの語彙を使う場合はeditionを含む`reference_model`と`standard_term`を記録する。standardを根拠にしていないproject固有品質は`level: project_defined`とし、架空のstandard対応を作らない。
- `display_name_ja`はsuiteまたはprojectで読みやすくした表示名、`source_terms_ja`は公開資料で使われた表現として分ける。同じ語でも出自を暗黙に統合しない。
- threshold、SLO、`latency_not_worse_than_current`等は品質語彙の同義語ではない。対応するquality IDを参照する品質scenarioまたはconstraintとして記録する。

例:

```yaml
quality:
  reference_model: ISO/IEC 25010:2023
  level: subcharacteristic
  characteristic: maintainability
  subcharacteristic: modifiability
  standard_term: modifiability
  display_name_ja: 変更容易性
  source_terms_ja: [変更容易性]
```

### 6. 目的・目標・手段・品質を分ける

- 目的: actorが得たい状態
- 目標: 目的達成をpass / fail判定できる条件
- 手段: 目標を満たす候補となる設計、技術、運用

品質は刺激、対象、環境、期待応答、検証を持つscenarioへ変換する。局所、system、journey、organization、future changeへの影響を混同しない。

### 7. AIに復唱させ、比較結果をreview可能にする

後続の設計・実装前に、AIは次を短く再構成する。

- 誰の何を改善するか
- 解く問題と未選択の候補手段
- 維持する契約と変更境界
- 優先品質と許容trade-off
- 成功条件、未決事項、停止条件

同じAIによる復唱と自己判定を、独立した確認済みEvidenceとして扱わない。次の意味契約で、復唱、比較根拠、比較結果の提案、review主体を分ける。

```yaml
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
```

- `comparison_basis`はContext Packet、requirement、change boundary等の解決可能なIDまたは引用箇所を持つ。`proposed_status: matched`自体をEvidenceにしない。
- `mismatched | blocked`なら後続Functionへ進まない。
- 公開契約、data meaning、金銭、認可、安全、不可逆判断を分岐させる場合は、`user | human_owner | independent_evaluator`の`review_status: accepted`とEvidenceがなければ、未決事項に依存する選択・実装を進めない。
- 低riskで可逆なdesign分析では、reviewが`unresolved`でもstatement、basis、differencesを成果物へ残せる。ただし、人間または独立評価済みのmatchと表現しない。

### 8. 判断の本質を往復traceへ記録する

主要なfinding、proposal、requirementごとに次を一続きで記録する。

```yaml
reasoning_trace:
  id: RT1
  concrete_evidence: []
  actor_or_owner: ""
  purpose_or_loss: ""
  violated_rule_or_quality: ""
  decision_or_obligation: ""
  falsifier_or_counterexample: ""
  validation: []
```

- 上へ遡れない具体策は、目的化した手段としてcandidateへ戻す。
- 下へ戻れない目的は、検証不能な抽象語として具体化し直す。
- 同じtraceでない要素を、見た目が似るという理由だけで共通化しない。
- schemaを埋めてもtraceが切れている成果物はreadyにしない。

### 9. 未決の選択をgateへ隔離する

design / reviewで安全な条件分岐を示す場合は、候補だけを列挙して終えず、次の意味契約で選択を隔離する。

```yaml
selection_gate:
  id: SG1
  subject: ""
  candidate_ids: []
  decision_condition: ""
  evidence_required: []
  evidence_acquisition: []
  owner: ""
  status: pending | satisfied | rejected
  evidence: []
```

`pending`を選択済みと表現しない。高riskなunknownに依存する実装または不可逆操作は、gateが`satisfied`になるまでblockedにする。

## Core output

```yaml
core_result:
  decision_maturity: {}
  problem_readiness: ready | conditional | blocked
  problem_frame:
    actor: ""
    context: ""
    desired_state: ""
    observed_barrier: ""
    impact: ""
  interpretations: []
  premises:
    - statement: ""
      evidence: []
      falsification: ""
      impact_if_false: ""
      evidence_status: confirmed | inferred | assumption | unknown | contradiction
      assessment: supported | weak | rejected | unknown
  causal_chain:
    applicability: required | not_applicable | unknown
    reason: ""
    symptom: ""
    violated_goal_or_quality: ""
    violated_rule_or_invariant: ""
    incorrect_owner_or_source: ""
    structural_cause: ""
    unmet_capability: ""
    demand_evidence: []
    success_condition_ids: []
  candidate_means: []
  abstraction_ladder:
    concrete_start: ""
    levels: []
    stop_reason: ""
  context_packet: {}
  selection_gates: []
  platform_context: {}
  platform_validation: {}
  traceability_seed: []
  reasoning_traces: []
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
  blockers: []
```

詳細なRequirement Catalogは`skills/mino-core/references/requirements-and-traceability.md`へ渡す。最終判定には`skills/mino-core/references/shared-policies.md`のcanonical `decision`を使う。

## Core completion gate

- 問題文から特定技術を除いても意味が残る。
- actor、文脈、目的、成功条件、変更境界が特定されている。
- 重要語の別解釈と、主要前提の反証条件がある。
- 既存障害・負債・回帰では症状からrule、owner、構造原因への因果を検証し、新規能力では非該当理由、`unmet_capability`、`demand_evidence`、`success_condition_ids`を示している。既存問題か新規能力か自体が未確認なら`applicability: unknown`と確認方法・影響をcanonical unknown recordへ残す。
- 具体から目的へ遡り、目的から検証へ戻っている。
- 高impactな判断が、具体Evidence、目的または損失、rule / quality、成果物、反証可能なvalidationへ一続きで追跡できる。
- 品質scenarioとtrade-offが目的へ接続されている。
- 重要な`unknown`または`contradiction`を隠していない。
- conditionalなunknown / contradictionは選択肢、選択gate、Evidence取得方法へ隔離され、選択・実装の可否とProblem Frame artifactの完成状態が分かれている。
- AI restatementがstatement、comparison basis、proposed status、differencesを持ち、`proposed_status: matched`である。高impactな意味・契約・不可逆判断を分岐させる場合は、許可されたreview主体の`accepted` Evidenceもある。

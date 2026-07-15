# Problem Framing workflow

## Contents

- Scope and evidence
- Meaning and premise audit
- Concrete and abstract navigation
- Problem readiness
- Output contract
- Rejection conditions

## Scope and evidence

このFunctionはread-onlyで、Problem Frameを主成果物とする。専門designやworkspace変更を行わない。

```yaml
decision_frame:
  question: ""
  owner: ""
  decide: []
  not_decide: []
  reversibility: reversible | costly | irreversible | unknown
  deadline_or_window: ""
  target_platforms: []
```

依頼原文、利用観測、仕様、code、test、schema、履歴を収集し、主張ごとに`confirmed | inferred | assumption | unknown | contradiction`を付ける。評価語、原因仮説、技術案を観測事実へ混ぜない。

## Meaning and premise audit

結果を変える重要語と前提だけを扱う。

```yaml
meaning_or_premise:
  id: MP1
  statement_or_term: ""
  first_interpretation: ""
  alternatives: []
  discriminating_evidence: []
  evidence_status: confirmed | inferred | assumption | unknown | contradiction
  falsification: ""
  impact_if_false: ""
```

可能性を無制限に列挙しない。actor、data meaning、公開契約、品質、解決案を分岐させない差は今回のscopeから外す。

## Concrete and abstract navigation

提示済みtechnology、class、table、API、patternを`candidate_means`へ退避する。具体要素ごとに`つまり、何のためか`で目的へ遡り、`たとえば、何がtrueなら達成か`で拒否条件と検証へ戻る。

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
  stop_reason: decision_useful | authority_boundary | insufficient_evidence
```

新規能力では、既存の誤ったownerやstructural causeを捏造しない。`causal_chain.applicability: not_applicable`とし、未充足capability、需要Evidence、成功条件を扱う。既存障害、負債、回帰ではcausal chainを必須にする。

## Problem readiness

```yaml
problem_readiness:
  subject_verdict: ready | conditional | blocked
  reasons: []
  evidence_needed: []
  safe_assumptions: []
  selection_gate_ids: []
  next_artifacts:
    - artifact: architecture | completeness | contract | boundary | integrated_change
      obligations: []
```

- `ready`: actor、problem、meaning、success、change boundaryの確認可能な項目にEvidenceがあり、未確認項目が結果を分岐させないかSelection Gateへ隔離されている。
- `conditional`: 未決事項を仮定で越えず、選択肢、選択gate、Evidence取得方法を安全に示せる。high-risk unknownがある場合、選択・実装・不可逆操作はblockedのままにする。
- `blocked`: high-risk unknown / contradictionにより、Problem Frame自体または安全な条件分岐を作れない。

`subject_verdict`はproblemの準備状態である。依頼された監査artifactの完成状態はcanonical `decision`で別に判定する。

## Output contract

```yaml
problem_framing_package:
  decision_frame: {}
  problem_frame:
    actor: ""
    context: ""
    desired_state: ""
    observed_barrier: ""
    impact: ""
  evidence:
    confirmed: []
    inferred: []
    assumptions: []
    unknowns: []
    contradictions: []
  meanings_and_premises: []
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
  reasoning_traces: []
  context_packet: {}
  selection_gates: []
  success_conditions: []
  rejection_criteria: []
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
  problem_readiness: {}
  platform_context: {}
  platform_validation: {}
  decision: {}
```

schemaは意味契約であり、非該当fieldを推測で埋めない。空欄の代わりに、Evidence付きunknownまたは`not_applicable`理由を残す。`evidence.unknowns`は`skills/mino-core/references/core.md`のcanonical unknown recordを使い、free textだけへ圧縮しない。
`selection_gates`は`skills/mino-core/references/core.md`の意味契約を使う。`reversibility: unknown`、`causal_chain.applicability: unknown`、またはhigh-riskな未決事項は、確認方法と未解決時の影響をcanonical decisionのunknown recordへ接続する。
`ai_restatement`もCoreの意味契約を使う。`proposed_status: matched`をEvidenceにせず、高impactな意味・契約・不可逆判断では許可されたreview主体の`accepted` Evidenceがなければ、その未決事項に依存する次phaseをblockedにする。

## Rejection conditions

- solution-firstの依頼を、そのままproblemとして採用する
- codeや一般知識からactor purposeをconfirmedにする
- 上位目的を「顧客価値」「利益」だけへ潰す
- 抽象論からcontract、rejection、testへ戻らない
- low-risk不足まで無制限に質問し、analysis paralysisを起こす
- Problem Frameの完成を、後続design / implementation / releaseの承認と混同する
- AIが自分のrestatementへ`matched`を付けたことだけで、入力理解または人間承認を証明する

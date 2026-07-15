# Change safety and legacy evolution

既存挙動を変更する実装、legacy分割、migration、暫定経路を伴う変更で読む。設計だけのmodeではplanを作り、repositoryを変更しない。

## 1. Target and priority

対象が未選択なら、product value、expected change、debt impact、failure risk、remediation costで`now | next | later | do-not-fix`へ分類する。静的兆候だけで優先度を決めない。

priorityは精密な数値scoreとして扱わない。各factorを比較可能な粒度で評価し、特に`debt_impact`は、現在の構造がproduct / delivery / operationへ生む影響と、そのEvidenceを分けて残す。AIは人間ownerに代わって最終順位を確定しない。

```yaml
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
```

5 factorを一度ずつ記録する。`impact`は少なくとも`debt_impact`で必須とし、根拠のない数値換算、空欄、静的metricだけのratingを許可しない。`owner.status: identified`では`value`を必須にする。ownerが入力から確定できない場合は補完せず、`unknown`、解決方法または未確定理由、Evidenceを残し、`priority: unknown`として人間選択待ちの候補を返す。owner不明のまま`now | next | later | do-not-fix`を確定しない。

## 2. Behavior baseline

現行挙動を次へ分類する。

- `must-preserve`: 利用者または外部契約が依存する
- `intentional-change`: 権限を持つ人間が変更を承認した
- `unknown`: 観測できるが意図が未確認

Characterization test、log、read-only query、recording wrapperのいずれかで外部観測結果をbaselineとして記録する。権限を持つownerが比較対象として承認したbaselineだけを`frozen`とし、現行挙動を無条件に正しい仕様とはみなさない。

## 3. Strategy selection

| Strategy | Use when |
|---|---|
| in-place small step | public契約が小さく、testとseamがあり、容易に戻せる |
| purpose split / copy-delete | 一つの構造に複数目的が混在し、既存動作を保ったまま不要部分を削れる |
| strangler | 内部依存が高riskで、use caseごとのroutingと新旧観測が可能 |

最初に一つのvertical sliceを入力から結果・運用まで通す。共通化は目的分割後に、意味・契約・変更理由が同じものだけへ行う。

## 4. Small reversible steps

各stepを一つの目的へ限定し、次を持たせる。

```yaml
change_step:
  id: S1
  single_goal: ""
  affected_contracts: []
  files: []
  preconditions: []
  validation: []
  abort_conditions: []
  rollback_or_recovery: []
  completion_condition: ""
```

Rename、Move、参照更新はsymbol-aware toolを優先する。AIは目的・責務仮説、test案、代替設計、差分reviewを担う。実装者のtestだけで自己正当化せず、固定契約と独立reviewで検証する。

## 5. Temporary paths

feature flag、adapter、dual read/write、copy、旧経路にはowner、導入目的、観測、期限、削除条件を付ける。rollbackで外部成功を巻き戻せない場合は、new writeを止めてforward recoveryする。

## Output

```yaml
change_safety:
  target_state: {}
  priority: now | next | later | do-not-fix | unknown
  priority_assessment: {}
  behavior_baseline: []
  intent_hypotheses: []
  strategy: ""
  first_vertical_slice: ""
  steps: []
  temporary_paths:
    - artifact: "flag | adapter | dual-write | copy | old-path"
      owner: ""
      introduced_at: ""
      purpose: ""
      metric_or_log: ""
      removal_condition: ""
      removal_phase: ""
  independent_review: []
```

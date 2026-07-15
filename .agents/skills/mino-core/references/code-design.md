# Purpose-driven code design

domain model、contract、boundaryを実コードの責務、公開操作、分岐、名前、抽象へ落とすときに読む。pattern数やclass数を成果にしない。

## Decision sequence

### 1. Purpose-centered capsule

- state、判断、計算、更新を、同じ目的とinvariantを所有するboundaryへ集める。
- `setStatus`やmutable collectionではなく、意図と契約を表すcommand / queryを公開する。
- 技術関心、別目的、別lifecycleを同じmodelへ押し込まない。

### 2. Branch classification

| Branch meaning | Default decision |
|---|---|
| short input guard | 明快ならifを維持 |
| lifecycle state | state transition ownerへ置く |
| business decision table | rule / policy候補 |
| implementation variant | 現実の変更根拠があればpurpose-oriented boundary候補 |
| feature / migration flag | owner、期限、削除条件を付ける |

分岐を消すこと自体を目標にしない。選択分岐が必要ならcomposition boundaryへ一箇所に置く。

### 3. Purpose-driven naming

名前はactor、context、purpose、owned responsibility、out-of-scopeを示す。既存名を伏せて候補を作り、新しい名前に合わないmemberを`fits | does_not_fit`へ分類する。安全なrenameはIDE / language serverへ委ねる。

### 4. Abstraction gate

抽象化前に次を比較する。

- consumerとpurposeが同じか
- contractとinvariantが同じか
- 同じ理由で変わるか
- 実装固有型、flag、unused operationが漏れないか
- 抽象化しない案より理解・変更・検証が改善するか

具体例が一つでvariant根拠がない場合は、原則として具体実装を保つ。外部障害境界、安定した契約、技術隔離など別の品質根拠がある場合だけ小さなportを認め、factoryや将来用階層を作らない。

### 5. Change scenario

- replace implementation
- add a proven variant
- change one proven variant
- change one business rule

適用根拠のないscenarioは`not_applicable`とし、架空の拡張性を作らない。

## Output

```yaml
code_design:
  capsules: []
  public_operations: []
  branch_decisions: []
  naming_decisions: []
  abstraction_decisions: []
  dependency_direction: []
  change_scenarios: []
  rejected_overdesign: []
```

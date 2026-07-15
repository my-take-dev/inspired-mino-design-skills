# interfaceで条件分岐を目的別実装へ分離する

## このノウハウの核

switchやifが悪いのではありません。問題は、異なる種類・目的・状態ごとの振る舞いが一箇所へ集まり、機能追加のたびに既存分岐を編集し、変更影響が広がることです。

interface設計では、利用側が必要とする**目的上の操作**を契約として定義し、種類ごとの実装を交換可能にします。モジュールを次の二つへ分ける考え方です。

- **インターフェースパート**: 利用側から見える目的、操作、契約。
- **実装パート**: 種類、アルゴリズム、外部技術ごとの具体的な実現方法。

Skill は、分岐を機械的にポリモーフィズムへ変換せず、変更理由、生成時点、状態遷移、実装数、理解コストから適否を判断します。

## 解決する問題

- 種類追加のたびに同じswitchを複数箇所へ追加する。
- type codeやenumに応じた処理が、巨大Serviceへ集まる。
- 一つの分岐変更で、別種類の振る舞いを壊す。
- テストが巨大な条件表になり、種類ごとの責務が見えない。
- 外部サービスやアルゴリズムの選択が利用側へ漏れている。
- interfaceはあるが、単なる一対一ラッパーで目的上の契約を表していない。

## 必要な入力

- 分岐を含むコードと呼び出し側。
- 分岐条件の意味: 種類、状態、権限、環境、機能フラグなど。
- 各分岐の事前条件、結果、副作用、失敗。
- 種類追加・振る舞い変更の履歴と見込み。
- オブジェクトの生成時点と選択責任者。
- 状態がライフサイクル中に変化するか。
- 現在のテストケースと実装間の共通部分。

## 判断規則

### 1. 先に分岐の意味を分類する

- **種類ごとの振る舞い**: Strategy / polymorphism候補。
- **ライフサイクル中に変わる状態ごとの振る舞い**: State候補。
- **一時的な入力判定やガード**: 単純なifのままが明快な場合が多い。
- **業務ルール表**: Decision table / rule object候補。
- **機能フラグ・移行分岐**: 期限と削除条件を持つ運用上の分岐。
- **エラー処理**: interface化より契約と例外境界を整える。

### 2. interfaceは利用側の目的から命名する

具体実装の共通メソッドを寄せ集めるのではなく、利用側が達成したい目的を操作として定義します。

```text
悪い例: IProcessor.process(data)
改善例: ShippingFeePolicy.calculateFor(destination, parcel)
```

契約には入力、戻り値、失敗、不変条件、副作用を含めます。

### 3. 分岐と実装を同じ変更理由でまとめる

種類固有のデータとロジックは、同じ実装へカプセル化します。呼び出し側がtype codeを読み、具体実装の内部を組み立てる状態を残しません。

### 4. 選択責任を一箇所へ置く

Factory、DI構成、Registryなどで、条件から実装を選ぶ責任を集約します。利用側は選択条件を知らず、interfaceだけへ依存します。

分岐自体が完全になくなる必要はありません。変更頻度の低い組み立て境界へ移動し、業務処理中に繰り返されないことが重要です。

### 5. StrategyとStateを区別する

- Strategy: 生成または実行開始時に方針を選び、外から交換する。
- State: オブジェクト自身の状態遷移に伴って振る舞いが変わる。

状態をStrategyとして外部管理すると、遷移ルールが散らばることがあります。逆に、単純なアルゴリズム選択をStateにすると過剰になります。

### 6. interface化のコストを正当化する

次の場合は単純な分岐を維持する選択肢があります。

- 分岐が一箇所だけで短く、種類追加の見込みが低い。
- 各分岐が独立した責務を持たず、単なる値変換である。
- interface化により追跡ファイル数と理解コストが大幅に増える。
- 言語のsealed typeやpattern matchingの方が契約を明確にできる。

## 実行手順

1. 対象のswitch/ifと、同じ条件を使う全箇所を検索する。
2. 条件が種類、状態、ルール表、移行分岐のどれかを分類する。
3. 分岐ごとの入力、結果、副作用、失敗を行列にする。
4. 利用側の目的と共通操作を抽出する。
5. interfaceの契約を、具体実装名に依存せず定義する。
6. 種類固有のデータとロジックを実装へ移す。
7. 実装選択をFactory / DI / Registryへ集約する。
8. 呼び出し側をinterface依存へ変更する。
9. 種類ごとの契約テストと、選択ロジックのテストを作る。
10. 重複分岐がなくなり、新種類追加時の変更箇所が局所化したか確認する。

## 出力契約

```yaml
branch_analysis:
  location: "path:symbol"
  condition_kind: "type | state | rule | feature-flag | guard"
  variants:
    - name: ""
      inputs: []
      outputs: []
      side_effects: []
      failures: []
  duplicated_locations: []
decision:
  refactor: true
  pattern: "strategy | state | rule-object | keep-branch"
  rationale: ""
interface_contract:
  name: ""
  consumer_purpose: ""
  operations:
    - signature: ""
      preconditions: []
      postconditions: []
      failures: []
implementations:
  - name: ""
    owns_data: []
    owns_rules: []
selection_boundary:
  location: "factory / DI / registry"
  rule: ""
tests: []
```

## 完了条件

- [ ] 分岐条件の意味が分類されている。
- [ ] interfaceが利用側の目的と操作を表している。
- [ ] 種類固有のデータとロジックが同じ実装へまとまっている。
- [ ] 実装選択の責任が一箇所にある。
- [ ] StrategyとStateの選択理由が説明されている。
- [ ] 新しい種類を追加するとき、既存の業務処理を広範囲に編集しない。
- [ ] 種類ごとの契約テストと選択テストがある。
- [ ] interface化しない判断も、変更頻度と理解コストから説明できる。
- [ ] 一時的な機能フラグには削除条件がある。

## 失敗パターン

- すべてのifを消すことを目標にする。
- 一実装しかなく変化もない箇所へ、根拠なくinterfaceを追加する。
- `process`、`execute`だけの抽象的契約を作る。
- interfaceの外でtype codeを読み続け、分岐が重複する。
- 共通基底クラスへ種類固有のfieldを全部持たせる。
- StrategyとStateを取り違え、状態遷移の所有者を失う。
- テストを実装クラスの内部詳細へ強く結合する。
- Factoryが巨大な業務ルールの新しい集積地になる。

## エージェント向けプロンプト骨子

```text
対象の条件分岐を、interfaceと実装の分離の観点で分析してください。

1. 同じ条件を使う全箇所を調べ、種類・状態・ルール表・機能フラグ・単純ガードに分類する。
2. 分岐ごとの入力、結果、副作用、失敗を比較する。
3. 利用側の目的から共通操作と契約を定義する。
4. Strategy、State、Rule Object、分岐維持のいずれが妥当か理由を示す。
5. 種類固有のデータとロジックを実装へまとめ、選択責任を一箇所へ置く。
6. 新種類追加時の変更範囲が局所化することを検証する。
7. 過剰なinterface化を避け、維持する分岐も明示する。
```

## 他スキルとの接続

- 目的と契約: `01-purpose-goal-means.md`
- カプセル化: `10-purpose-centered-encapsulation.md`
- 抽象化: `13-purpose-driven-abstraction.md`
- 安全なリファクタリング: `15-ai-assisted-refactoring.md`

## 出典

- https://speakerdeck.com/minodriven/kusokododong-hua-switchwen-jie-shuo
- https://speakerdeck.com/minodriven/effective-learning-of-good-code
- https://speakerdeck.com/minodriven/encapsulation2

> 公開資料を基に、分岐分類、契約行列、Strategy/State判断をSkill化のため再構成しています。

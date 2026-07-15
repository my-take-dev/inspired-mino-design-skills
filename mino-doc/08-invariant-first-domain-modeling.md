# 不変条件を中心にドメインモデルを設計する

## このノウハウの核

ドメインモデルは、業務データを保存する箱ではありません。目的を正しく達成するために、判断、計算、状態遷移、制約を所有し、不正な状態を作らせない仕組みです。

Skill は、目的から次の契約を抽出し、適切な所有者へ配置します。

- **事前条件**: 操作を開始してよい条件。
- **事後条件**: 操作が成功した後に成立すべき条件。
- **不変条件**: 生成後からライフサイクル全体で常に成立すべき条件。

Value Object、Entity、Aggregate、Policy などのパターンは、この契約を守るための手段として選びます。パターン名を先に当てはめません。

## 解決する問題

- バリデーションがController、Service、画面、DBへ分散している。
- setterやpublic fieldにより、不正値をどこからでも設定できる。
- データクラスだけがあり、業務判断は巨大Serviceに置かれている。
- 同じ計算や条件が複数箇所で微妙に異なる。
- 状態遷移の順序を無視した更新が可能である。
- テストが正常系の入出力だけで、制約を保証していない。
- Aggregateを小さくすることが目的化し、同時に守るべき整合性が分断される。

## 必要な入力

- アクター、目的、ユースケース。
- 正常例、異常例、境界値。
- 業務ルール、計算式、判断基準、状態遷移。
- データの生成・更新経路と正の所有者。
- トランザクション、同時更新、外部連携の要件。
- 現在のバリデーション、DB制約、テスト。
- 障害、不正データ、例外処理の履歴。

## 判断規則

### 1. 制約を目的から説明する

制約は「仕様に書いてあるから」だけでなく、破ったときにどの目的・価値が損なわれるかを記述します。

```text
目的: 購入者が販売可能な数量を正しく注文する
不変条件: 注文数量は1以上かつ販売上限以下
破壊時の影響: 返金誤処理、在庫不整合、不正な値引き
```

### 2. 不正な状態を表現不能または生成困難にする

- コンストラクタまたはFactoryで検証する。
- public setterを避け、意味のある操作だけを公開する。
- プリミティブ値のまま流通させず、制約を持つValue Objectを検討する。
- 変更操作の中で、変更後も不変条件が成立することを保証する。
- DB制約は最後の防衛線として併用するが、ドメインルールをDBだけに隠さない。

### 3. 制約を守れる最小の権威ある所有者へ置く

制約を判断するために必要な状態を持ち、その状態を変更する権限があるモデルが所有します。

- 単一値の妥当性: Value Object候補。
- 識別とライフサイクルを持つ状態: Entity候補。
- 複数要素を同時に整合させる必要がある: Aggregate境界候補。
- 複数モデルの情報を使うが状態を所有しない判断: Domain Service / Policy候補。

所有者が複数あると、ルールの複製と不一致が生まれます。正の実装を一つ決め、他層はそこを呼び出します。

### 4. Aggregate境界は不変条件から導く

一緒に更新したいという都合だけで巨大Aggregateを作らず、同一トランザクションで絶対に守る必要がある不変条件を基準にします。結果整合性でよいルールは、イベントやプロセスで分離できます。

### 5. 事前・事後・不変条件をテストへ直結させる

各操作に対して、少なくとも次を用意します。

- Given: 成立済みの事前状態。
- When: 意味のあるドメイン操作。
- Then: 事後条件と不変条件。
- Invalid Given / When: 操作が拒否され、状態が変わらないこと。

例外型やエラーコードだけでなく、失敗後に永続化や外部送信が行われないことも確認します。

### 6. 既存の不正データを無視しない

厳しい型や制約を導入すると、既存DBに違反データがある可能性があります。事前調査、移行、隔離、補正、読取互換、ロールバックを計画します。

## 実行手順

1. ユースケースごとに目的と成功状態を記述する。
2. 正常例、異常例、境界値、状態遷移を収集する。
3. 各操作の事前条件、事後条件、不変条件を抽出する。
4. 制約が守る目的と、破壊時の影響を対応付ける。
5. 現在の制約実装と更新経路を検索する。
6. ルールの重複、抜け道、誤った所有者を特定する。
7. Value Object、Entity、Aggregate、Policyの候補を、必要な権威と整合性範囲から選ぶ。
8. 公開操作を、業務上意味のあるメソッドへ限定する。
9. 事前・事後・不変条件をテストケースへ変換する。
10. 既存データと外部契約への移行影響を確認する。
11. 実装後、すべてのwriterが正の所有者を経由することを検証する。

## 出力契約

```yaml
contracts:
  - id: INV-001
    purpose: "守る目的"
    owner_candidate: "OrderQuantity"
    type: "precondition | postcondition | invariant"
    statement: "数量は1以上かつ販売上限以下"
    required_state: []
    violation_impact: []
    current_enforcement:
      locations: []
      gaps: []
model_design:
  - model: "OrderQuantity"
    pattern: "value-object"
    authority: "数量の妥当性"
    construction: "validated factory"
    public_operations: []
    forbidden_mutations: []
aggregate_decisions:
  - boundary: "Order"
    invariants: []
    consistency: "strong | eventual"
    rationale: ""
tests:
  - contract: INV-001
    given: ""
    when: ""
    then: ""
migration:
  existing_data_check: []
  read_compatibility: []
  rollout_steps: []
  rollback_or_forward_recovery: []
```

## 完了条件

- [ ] 主要な業務ルールが事前条件、事後条件、不変条件として明示されている。
- [ ] 各制約が守る目的と破壊時の影響が説明されている。
- [ ] 制約の権威ある所有者が一つに定まっている。
- [ ] 不正な値を設定する公開setterや迂回経路が残っていない、または移行計画がある。
- [ ] Aggregate境界が不変条件と整合性要件から説明されている。
- [ ] 正常系、境界値、異常系、状態不変のテストがある。
- [ ] 既存データの制約違反と移行リスクを確認している。
- [ ] 制約導入中の読取互換性と、rollbackまたはforward recoveryを定義している。
- [ ] 業務ルールをControllerやDBだけに隠していない。

## 失敗パターン

- すべての整数や文字列を機械的にValue Objectへする。
- バリデーションを一箇所に移しただけで、更新の抜け道を残す。
- Aggregateを小さくする原則を優先し、絶対に守るべき整合性を壊す。
- 例外を投げるだけで、部分更新や副作用が起きていないか確認しない。
- 外部入力検証とドメイン不変条件を混同する。
- DTOへメソッドを置いただけで、正の所有者やライフサイクルを検討しない。
- 新しい制約を導入し、既存の違反データで本番を停止させる。

## エージェント向けプロンプト骨子

```text
対象ユースケースのドメイン制約を、事前条件・事後条件・不変条件として抽出してください。

1. 各制約が守るアクターの目的と、違反時の影響を示す。
2. 現在の検証・更新経路を調査し、重複、抜け道、誤った所有者を特定する。
3. 制約を守れる最小の権威ある所有者を提案する。
4. Value Object、Entity、Aggregate、Policyは、識別、状態、整合性範囲から選ぶ。
5. 不正状態を作りにくい生成方法と、意味のある公開操作を設計する。
6. Given-When-Thenで正常、境界、異常、失敗後不変のテストを示す。
7. 既存データと外部契約の移行影響を確認し、読取互換性とrollbackまたはforward recoveryを定義する。
```

## 他スキルとの接続

- 目的別モデル: `07-invisible-driven-modeling.md`
- 異常系の発見: `09-data-destruction-driven-analysis.md`
- カプセル化: `10-purpose-centered-encapsulation.md`
- AIによるテスト生成: `15-ai-assisted-refactoring.md`

## 出典

- https://speakerdeck.com/minodriven/purpose-driven-architecture
- https://speakerdeck.com/minodriven/data-destroy-driven
- https://speakerdeck.com/minodriven/encapsulation2
- https://tech.stmn.co.jp/entry/2023/09/27/115301
- https://speakerdeck.com/minodriven/ai-refactoring-approach

> 公開資料を基に、契約台帳、所有者判定、テスト・移行出力をSkill化のため再構成しています。

# レガシーコードを目的単位で安全に分割する

## このノウハウの核

巨大なレガシーコードを安全に改善するには、ファイルを小さくすることではなく、混在している目的を発見し、各目的に必要なデータ・振る舞い・制約を独立させます。

対象が複雑なほど、内部を少しずつ美しく並べ替えるだけでは依存関係に引きずられます。公開資料で紹介される有力な進め方は、目的別の新しい構造を用意し、既存コードをいったん複製して不要部分を削る方法です。

```text
目的を発見する
→ 現行挙動をテストで固定する
→ 目的別の新しい入れ物を作る
→ 既存実装をコピーする
→ 各目的に不要な要素を削る
→ 呼び出し側を一つずつ移す
→ 本当に同じ目的の共通部分だけを抽出する
→ 旧経路を廃止する
```

システム全体が複雑で、既存内部を直接分割するリスクが高い場合は、ストラングラーフィグパターンを使い、新しいクリーンなモジュールを並置してユースケース単位で置き換えます。

## 解決する問題

- 一つの巨大クラスに複数のアクター、ユースケース、状態、技術関心事が混在する。
- 小さな変更でも、コード全体を理解しなければならない。
- private method抽出を繰り返しても、責務と依存が変わらない。
- 共通化が先行し、異なる目的が共通基底・共通Serviceへ再結合する。
- テストがなく、どの挙動を維持すべきか分からない。
- 全面刷新案しかなく、移行中の運用、互換性、ロールバックがない。
- AIへ全面書き換えを依頼し、既存の暗黙仕様を失う。
- 途中まで分割した状態で、新旧両経路が恒久化する。

## 必要な入力

### 現行構造

- 対象クラス・モジュールと全呼び出し側。
- public API、DB、イベント、ファイル、外部サービスとの契約。
- field、method、条件分岐、状態遷移、副作用。
- 依存グラフ、循環依存、共同変更ファイル。
- テスト、ログ、監視、運用手順。

### 目的と変化

- アクター、ユースケース、目的。
- 目的ごとの必要データ、ルール、不変条件。
- 変更履歴と今後のロードマップ。
- 維持すべき挙動と、意図的に変更してよい挙動。

### 移行条件

- デプロイ単位、トランザクション、データ所有者。
- 機能フラグ、ルーティング、並行稼働の可否。
- ロールバックまたはforward recoveryの方法。
- 旧経路を削除できる観測条件。

## 判断規則

### 1. 先に目的マップを作る

fieldやmethodを、現在の配置ではなく、どのアクターのどの目的を支えるかで分類します。

```yaml
members:
  - symbol: calculateImmediateOrderTotal
    actor: purchaser
    purpose: immediate-order
  - symbol: reserveDeliverySlot
    actor: logistics-operator
    purpose: scheduled-delivery
```

一つの要素が複数目的へ見える場合は、真に共通の安定概念か、責務が混ざった手続きかを調べます。

### 2. 挙動を固定してから構造を変える

現行挙動が正しいか不明でも、まず現在の外部観測結果をCharacterization testで記録します。その後、次の三種類へ分類します。

- **must-preserve**: 利用者や外部契約が依存する挙動。
- **intentional-change**: 明示的に修正する欠陥・仕様。
- **unknown**: 意図が未確認で、勝手に変えてはいけない挙動。

テストできない副作用は、seam、adapter、fake、記録用wrapperを作って観測可能にします。

### 3. 目的別に「コピーして削る」

複雑な依存を一つずつ移動させるより、目的別の新クラスへ既存コードをコピーし、その目的に不要なfield、branch、method、dependencyを削ります。

この方法の利点:

- 既存動作を保持した初期状態から始められる。
- 何を残し、何を捨てるかを目的で判断できる。
- 抽出途中の複雑な共有状態を減らせる。
- 目的ごとの差が明確になった後に共通部分を評価できる。

コピーは一時的な重複です。移行期限、所有者、削除条件を持たせます。

### 4. 共通化は目的分割の後に行う

見た目が同じ処理でも、目的、ルール、変更理由が異なるなら共通化しません。目的別クラスへ分け、差異が見えた後で、次を満たすものだけ抽出します。

- 意味が同じ。
- 契約が同じ。
- 同じ理由で変更される。
- 一方固有の条件を引数・flagで渡す必要がない。
- 共通名が業務上または技術上明確である。

### 5. 純粋な計算を先に分離する

I/O、状態更新、外部副作用と、入力から結果を計算する処理を分けます。純粋関数はテストしやすく、目的別モデルへ移しやすい安全な分割点です。

ただし、単なるprivate helperへの抽出で終わらず、戻り値や計算が業務上の概念ならValue ObjectやPolicyの候補にします。

### 6. 機械的変更はIDE・コンパイラへ任せる

Rename、Move、Extract Method、参照更新はIDE、language server、compilerを使います。AIは目的分析、候補提示、テスト生成、差分レビューに使い、広範囲の文字列置換を任せません。

### 7. 直接分割とストラングラーを選ぶ

#### 内部で直接分割しやすい条件

- public契約が比較的小さい。
- テストで挙動を観測できる。
- データ所有を段階的に分けられる。
- 一つのリポジトリ・デプロイ内で変更できる。
- 呼び出し側を順次移行できる。

#### ストラングラーフィグが向く条件

- 既存内部の依存が非常に複雑で、変更リスクが高い。
- 明確なユースケース境界またはルーティング境界がある。
- 新しい仕様・モデルを比較的明確に定義できる。
- 新旧を一定期間並行運用できる。
- 使用率、結果差分、エラーを観測できる。

ストラングラーでも、データの正の所有者、二重書き、再実行、切替、旧経路停止の条件を必ず決めます。

### 8. 一つの垂直スライスで価値と安全性を検証する

最初に基盤だけを大量に作らず、代表的な一ユースケースを入力から出力まで新境界へ通します。これにより、モデル、連携、テスト、運用、観測の成立を確認できます。

### 9. 旧経路の削除を完了条件に含める

adapter、feature flag、二重実装は移行手段であり、完成形ではありません。各暫定経路に次を付けます。

- owner。
- 導入日。
- 目的。
- 利用を示すmetric/log。
- 削除条件。
- 削除予定phase。

## 実行手順

1. 対象範囲、維持する契約、意図的変更の許可範囲を確定する。
2. public API、データ、イベント、副作用、呼び出し側を調査する。
3. アクター・目的・ユースケースを列挙し、既存要素を目的へマッピングする。
4. 外部観測可能な挙動をCharacterization testで固定する。
5. 純粋関数、技術adapter、目的別状態など、安全なseam候補を探す。
6. 直接分割かストラングラーかを選び、理由を記録する。
7. 目的別の新しいクラスまたはモジュールを作る。
8. 既存実装を目的別にコピーし、不要なfield、branch、dependency、副作用を削る。
9. 不変条件と意味のある公開操作を新しい所有者へ集める。
10. 一つの呼び出し経路または一ユースケースを新実装へ切り替える。
11. 旧新の結果、契約、metric、エラー、副作用を比較する。
12. 問題があれば小さい単位で戻し、原因を修正する。
13. 呼び出し側を順次移行し、旧経路の利用をゼロへ近づける。
14. 目的分割後に、同じ目的・契約・変更理由を持つ重複だけを抽出する。
15. 旧API、flag、adapter、重複データ、不要テストを削除する。
16. 代表的な将来変更が目的境界内で完結することを確認する。

## 出力契約

```yaml
scope:
  target: "path:symbol またはサブシステム"
  preserve_contracts: []
  intentional_changes: []
  unknown_behaviors: []
purpose_map:
  - purpose_id: P1
    actor: ""
    desired_state: ""
    members: []
    invariants: []
    dependencies: []
characterization:
  - behavior: ""
    observable_at: "API / event / database / file / metric"
    test: ""
    classification: "must-preserve | intentional-change | unknown"
strategy:
  kind: "in-place-purpose-split | strangler-fig"
  rationale: ""
  first_vertical_slice: ""
target_boundaries:
  - module: ""
    purpose: ""
    owned_state: []
    public_contract: []
    out_of_scope: []
copy_delete_plan:
  - source: ""
    target: ""
    copy_scope: []
    delete_as_irrelevant: []
    retained_behavior: []
migration_steps:
  - id: M1
    change: ""
    preconditions: []
    validation: []
    rollback_or_recovery: []
    completion_condition: ""
temporary_paths:
  - artifact: "flag / adapter / duplicate"
    owner: ""
    introduced_at: ""
    purpose: ""
    metric_or_log: ""
    removal_condition: ""
    removal_phase: ""
common_extractions_after_split: []
```

## 停止条件

次の場合は実装を進めず、調査または計画を更新します。

- 維持すべき公開契約が特定できない。
- 変更対象のデータ所有者が複数あり、正を決められない。
- テスト・ログ・差分比較のいずれでも現行挙動を観測できない。
- 新旧並行時に二重副作用を防げない。
- 不可逆なデータ変更にbackup、dry-run、復旧手段がない。
- 目的分類が推測だけで、結果を大きく左右する未決事項がある。

## 完了条件

- [ ] 既存要素が目的別に分類されている。
- [ ] 維持・変更・未確認の挙動が区別されている。
- [ ] 変更前の観測可能な挙動を固定するテストがある。
- [ ] 新しい境界ごとに目的、所有状態、不変条件、公開契約、対象外がある。
- [ ] 一時的なコピーと新旧経路にowner、導入日、目的、metric/log、削除条件、削除予定phaseがある。
- [ ] 共通化は目的分割後に行われ、同じ意味と変更理由を確認している。
- [ ] 一つの垂直スライスで入力から結果・運用まで検証している。
- [ ] 各移行stepにprecondition、validation、rollbackまたはrecoveryがある。
- [ ] 旧経路の利用がゼロであることを観測し、不要artifactを削除している。
- [ ] 代表的な将来変更が、目的境界内で完結する。

## 失敗パターン

- private method抽出だけで、所有状態と責務境界を変えない。
- 先にDRY化し、異なる目的を共通層へ固定する。
- AIへ巨大ファイルの全面書き換えを一度に依頼する。
- コピーした新クラスを恒久的な重複として放置する。
- 新旧両方が同じデータを書き、正の所有者を決めない。
- ストラングラーを別名の全面刷新として進め、最初の価値提供が遅れる。
- テストが内部実装だけを固定し、外部挙動を保証しない。
- 新モジュールを作るだけで、呼び出し移行と旧経路削除を計画しない。
- すべてを別サービスへ分割し、運用複雑性を増やす。

## エージェント向けプロンプト骨子

```text
対象のレガシーコードを、外部挙動を守りながら目的単位へ分割してください。

1. public契約、データ、イベント、副作用、呼び出し側を調査する。
2. アクターと目的を抽出し、field、method、branch、dependencyを目的へマッピングする。
3. 現行挙動をmust-preserve、intentional-change、unknownに分類し、Characterization testを提案する。
4. 純粋関数、adapter、目的別状態などの安全なseamを特定する。
5. 直接分割とストラングラーフィグを比較し、適切な移行戦略を選ぶ。
6. 目的別の新しい境界を作り、既存実装をコピーして目的外の要素を削る計画を示す。
7. 一ユースケースずつ呼び出しを移し、旧新の結果と副作用を検証する。
8. 同じ目的・契約・変更理由を確認した後だけ共通化する。
9. 暫定flag、adapter、重複、旧経路のowner、導入日、目的、metric/log、削除条件、削除予定phaseを明示する。
10. 各stepにprecondition、validation、rollbackまたはrecoveryを付ける。
```

## 他スキルとの接続

- 負債の優先順位: `04-technical-debt-goal-and-prioritization.md`
- 目的別モデル: `07-invisible-driven-modeling.md`
- 目的中心のカプセル化: `10-purpose-centered-encapsulation.md`
- 人間・AI・IDEの分担: `15-ai-assisted-refactoring.md`

## 出典

- https://speakerdeck.com/minodriven/ai-refactoring-approach
- https://speakerdeck.com/minodriven/ghosts-of-technical-debt
- https://tech.stmn.co.jp/entry/2023/07/14/115631
- https://speakerdeck.com/minodriven/invisible-driven-design
- https://speakerdeck.com/minodriven/architecture-and-productivity

> 公開資料を基に、コピーして削る手順、ストラングラー選択、移行・削除条件をSkill化のため再構成しています。

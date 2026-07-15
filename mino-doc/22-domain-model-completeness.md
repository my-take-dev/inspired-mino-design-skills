# ドメインモデル完全性

## ノウハウの核

ドメインモデル完全性とは、対象業務を成立させるために必要な概念、制約、状態、遷移、振る舞い、関連、失敗が、モデル内に欠落なく表現されている状態です。

単にEntity、Value Object、Aggregateを使っていることではありません。モデル外のService、Controller、UI、DB trigger、運用手順に重要な業務ルールが漏れているなら、モデルは不完全です。

ここでいう完全性は「現実世界の全情報をモデル化する」という意味ではありません。対象目的とユースケースの範囲で、正しい判断と状態維持に必要な情報が揃っていることを意味します。

## AI開発の再現性との関係

AIへ要件文だけを渡すと、目立つ正常系は実装できても、暗黙の制約、禁止遷移、失敗時の整合性、値の意味が抜けることがあります。

完全性チェックを先に行うと、AIが実装すべき概念のinventoryをEvidence付き監査baselineとして記録できます。AIが作ったinventory自体は提案であり、権限を持つownerの確認なしに業務modelとして承認済みにはしません。

- 何の値が必要か
- どの状態が存在するか
- 何が許可・禁止されるか
- 誰が状態を変更できるか
- 変更前後に何が成立するか
- 外部失敗時に何を維持するか

このinventoryと契約を満たさない生成物を拒否できるため、要件再現性が高まります。

## 完全性を構成する要素

以下は公開資料の原則をSkillで監査可能にするため整理した観点であり、著者本人が定義した固定件数の完全性schemaではありません。runtime suiteではterm / context、concept、constraint、state、transition、behavior、relationship、failure、time、writer、reader、authorityの12 dimensionをsuite operationalizationとしてscreeningします。対象requirementごとに適用性を先に判定し、結果を分岐させる観点だけを詳細化します。

### 1. 用語の完全性

要件中の重要な業務語が、モデル内で曖昧なprimitiveや汎用名へ潰れていないこと。

例:

- `int`ではなく`Quantity`
- `string`ではなく`OrderId`
- `bool`ではなく意味のある状態
- `date`ではなく`ReservationPeriod`

### 2. 制約の完全性

業務上不正な値や組合せを、モデル自身が生成・保持できないこと。

- 数量範囲
- 通貨単位の一致
- 期間の前後関係
- 明細と合計の整合
- 所有者と権限の整合

### 3. 状態の完全性

必要な状態が列挙され、意味、到達条件、終了条件が定義されていること。

状態を複数のbooleanで表して矛盾組合せを作らないようにします。

### 4. 遷移の完全性

各状態から許可される操作、禁止される操作、遷移後の状態、副作用が定義されていること。

### 5. 振る舞いの完全性

業務判断がデータ取得側や呼び出し側へ散らばらず、判断に必要な情報を持つモデルへ配置されていること。

### 6. 関連の完全性

一貫して変更される要素が同じ整合性境界に入り、別トランザクションでよい要素が分離されていること。

### 7. 失敗の完全性

失敗が単なる例外文字列ではなく、業務上区別すべき結果として表現されていること。

- 在庫不足
- 既に確定済み
- 権限不足
- 期限切れ
- 外部決済失敗

外部技術失敗と業務不成立を混同しません。

### 8. 時間の完全性

現在時刻、期限、予約時刻、effective dateが判断へ影響する場合、暗黙にsystem clockを読むのではなく、意味と基準時刻をモデルまたは契約で明示します。

## 完全性監査マトリクス

| Requirement / scenario | Concept | Value/constraint | State | Transition | Behavior owner | Failure | Test |
|---|---|---|---|---|---|---|---|
| 注文を確定する | Order | 明細1件以上 | Draft/Confirmed | Draft→Confirmed | Order.confirm | AlreadyConfirmed | contract test |

要件、例外シナリオ、運用シナリオの各行について、各観点の適用性を確認します。applicableなcellはEvidence付きmodel要素へ接続し、非該当はscopeに基づく理由とEvidenceを残します。matrixを埋めるために架空のstate、transition、failure、writerを作りません。

## 発見手順

### 1. 名詞だけでなく出来事と判断を抽出する

- 名詞: 注文、商品、顧客
- 出来事: 注文された、取消された、期限切れになった
- 判断: 注文可能か、返金対象か、割引可能か
- 制約: 数量、金額、期限、組合せ

名詞中心だけではデータモデルになり、振る舞いが漏れます。

### 2. データ破壊の思考実験を行う

ミノ駆動氏の「データ破壊駆動」の考え方を使い、各値を意図的に壊します。

- nullにする
- 上限を超える
- 不一致なIDを組み合わせる
- 状態を飛び越える
- 同じ操作を二度行う
- 時刻を逆転させる
- 一部だけ保存する

壊れたときに業務上何が困るかを問い、不変条件と境界を発見します。

### 3. 全writerを列挙する

モデルを変更する経路をすべて確認します。

- API
- batch
- migration
- admin tool
- message consumer
- test fixture
- direct SQL / import

一つの入口だけvalidationしても、他のwriterから不完全状態を生成できます。

### 4. 全readerを列挙する

同じ概念を異なる意味で読んでいないか確認します。表示用の都合でモデル意味を歪めないようにします。

### 5. 代表シナリオと反例を通す

- 正常系
- 境界値
- 禁止操作
- 並行操作
- 重複要求
- 部分失敗
- 再試行
- 旧データ

## モデルへの配置規則

- 単一値の妥当性と演算 → Value Object
- 識別とライフサイクル → Entity
- 強整合で守る不変条件 → Aggregate
- 集約を跨ぐ順序と外部連携 → Application service / process
- ドメイン知識を必要とするが単一Entityに自然に属さない計算 → Domain service
- 永続化技術 → Repository implementation

Domain serviceへ何でも逃がさず、データを持つモデルが判断できるならそのモデルへ配置します。

## 出力契約

```yaml
domain_model_completeness:
  purpose: string
  scope: []
  audit_rubric:
    origin: suite_operationalization
    dimensions: [term_context, concept, constraint, state, transition, behavior, relationship, failure, time, writer, reader, authority]
  dimension_applicability: []
  concepts:
    - name: string
      kind: value_object | entity | aggregate | domain_service | event
      meaning: string
      rules: []
      owner: string
  states: []
  transitions: []
  invariants: []
  failures: []
  writers: []
  readers: []
  uncovered_requirements: []
  leaked_domain_rules: []
  contradictions: []
  coverage:
    audit_screen_denominator: 0
    audit_screen_resolved_numerator: 0
    applicable_model_denominator: 0
    present_model_numerator: 0
  verdict: complete_for_scope | incomplete | blocked
```

## 完了条件

- 対象範囲の全要件がモデル要素と契約へ追跡できる。
- 重要業務語がprimitiveや汎用名だけで表現されていない。
- 不正状態を生成する公開経路がない。
- 状態と遷移がapplicableなら明示され、禁止遷移を検証できる。非該当ならscope、理由、Evidenceがある。
- 業務判断の所有者が一意である。
- 全writerが同じ不変条件を通る。
- 失敗と状態維持がapplicableなら定義され、非該当ならscope、理由、Evidenceがある。
- モデル外へ漏れた業務ルールが列挙・解消されている。
- 対象外と未解決事項が明示されている。

## 失敗パターン

- DDDのパターン名を使えば完全とみなす
- DB schemaをそのままドメインモデルにする
- getter/setterだけのEntity
- booleanの組合せで矛盾状態を許す
- Serviceに全ロジックを集める
- DTO validationをモデル保証とみなす
- 正常系の概念だけモデル化し、失敗を例外文字列にする
- 全現実を一つの巨大モデルへ含める
- bounded contextを跨ぐ用語差を無視する

## Skill用プロンプト骨子

```text
対象要件とコードについてドメインモデル完全性を監査してください。
業務用語、値制約、状態、許可・禁止遷移、振る舞い所有者、失敗、writer、readerを一覧化し、要件とのtraceability matrixを作成してください。
データ破壊の反例を使って欠落した不変条件を探してください。
パターン名の有無ではなく、不正状態を生成できないか、重要ルールがモデル外へ漏れていないかで判定してください。
```

## 根拠と解釈

一次資料:

- [破壊せよ！データ破壊駆動で考えるドメインモデリング](https://speakerdeck.com/minodriven/data-destroy-driven): ドメインモデルの完全性と、データ破壊駆動による制約・必要なドメインロジックの発見。

ミノ駆動氏の公開資料では、ドメイン概念をValue Object、Entity、Aggregate、Repository interfaceなどで整理し変更容易性を高めること、不変条件を中心に設計すること、データを破壊する思考実験からモデル上の制約を発見することが繰り返し示されています。「ドメインモデル完全性」という表現をSkillで実行可能にするため、本書では要件traceability、全writer、状態・失敗、漏出ルールを含む監査基準へ具体化しています。12 dimension、applicability profile、coverage計算はこのsuiteによる操作的解釈であり、公開資料の著者が定義した固定schemaとして帰属させません。

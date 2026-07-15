# インターフェイスと実装の分離

## ノウハウの核

ミノ駆動氏が説明する「インターフェイスと実装の分離」は、単に言語機能として`interface`型を作ることではありません。

モジュールを次の二つへ分ける設計原則です。

- **インターフェイスパート**: 利用者に提供する目的、操作、入出力、契約
- **実装パート**: その契約を実現するアルゴリズム、外部技術、データ構造、制御手順

長大なトランザクションスクリプトでは、業務判断、永続化、通信、変換、例外処理など多くの関心が一つの手順へ混在します。インターフェイスパートを先に定義し、実装詳細を背後へ隠すことで、関心を分離し、機能の交換可能性と変更容易性を高めます。

## interface型との違い

言語上の`interface`を作っても、次の状態なら分離できていません。

- メソッド名が技術手順を露出する
- 引数や戻り値がDB行、HTTPライブラリ型、フレームワーク型
- 呼び出し側が実装順序を知る必要がある
- 一つのinterfaceに無関係な用途が集約されている
- 実装クラスが変わっても業務分岐が呼び出し側に残る

分離の対象は型ではなく、**利用者が知るべき意味と、知らなくてよい実現方法**です。

## AI開発の再現性との関係

AIに実装だけを依頼すると、毎回異なるライブラリ、データ構造、分岐構造を選ぶ可能性があります。

先に権限を持つownerがインターフェイスパートを`approved`なbaselineにすると、AIが変更できる範囲は実装パートへ限定されます。

- 目的と公開操作は変えない
- 入出力の意味は変えない
- 事前条件・事後条件・不変条件は変えない
- 外部技術や内部アルゴリズムは契約内で選択可能

これにより、実装差を許容しつつ、要件適合性を維持できます。

## 分離対象の発見

長大な処理を読み、各ステップを次へ分類します。

| Concern | 例 |
|---|---|
| Domain decision | 注文可能性、料金計算、状態遷移 |
| Use-case orchestration | 読込、判断、保存、通知の順序 |
| Persistence | SQL、ORM、transaction |
| External communication | HTTP、queue、filesystem |
| Representation | DTO、JSON、画面形式への変換 |
| Policy / strategy | 割引方式、配送方式、認証方式 |
| Operational concern | retry、logging、metrics、timeout |

関係の強いものを一つの目的へ集約し、関係の弱いものを境界で分離します。

## インターフェイスパートの設計手順

### 1. 利用者と目的を定義する

```text
利用者: 注文確定ユースケース
目的: 現在の注文を業務規則に従って確定する
利用者が知る必要のないこと: SQL、決済HTTP、retry実装
```

### 2. 技術語を除いて操作を命名する

悪い例:

- `insertOrderRow`
- `callPaymentApi`
- `executeDiscountSwitch`

良い例:

- `save(order)`
- `authorize(paymentRequest)`
- `calculateDiscount(order)`

名前は実装手段でなく、利用側の目的を表します。

### 3. 契約を添える

各操作に次を定義します。

- 入力の意味
- 成功結果
- 失敗の分類
- 副作用
- 一貫性境界
- deadline、retry、冪等性、duplicate、ambiguous outcomeそれぞれの`applicable | not_applicable | unknown`
- applicableなsemanticsの内容とowner
- 非該当の理由とEvidence、未確定の確認方法と未解決時の影響

read-only operationやpure functionへ冪等keyを発明しません。deadline、retry、冪等性、duplicate、ambiguous outcomeを互いから推定せず、対象operationで結果を分岐させるものだけを契約へ具体化します。

### 4. 利用者ごとに小さくする

すべての永続化操作を持つ巨大Repositoryや、全配送方式を知る万能Serviceを作りません。

利用者が必要とする最小契約を、その目的に近い場所に置きます。ただし同じ業務概念の不変条件を分断しないよう、集約境界を優先します。

### 5. 実装パートを差し替え可能にする

差し替え可能性はテストダブルの作りやすさだけではありません。

- DB製品の変更
- 外部APIのversion変更
- 同期処理から非同期処理への変更
- ルール実装の追加
- アルゴリズムの改善

これらが利用者の業務ロジックへ波及しないことを確認します。

## 分岐を実装側へ移す

```text
悪い構造:
caller -> switch(type) -> implementation A/B/C

望ましい構造:
caller -> purpose-oriented interface -> selected implementation
```

呼び出し側に種類判定と処理詳細を残すと、新しい種類の追加時に複数箇所が変更されます。選択責務はfactory、DI構成、registryなどへ分離し、利用側は契約だけに依存します。

ただし、種類によって業務上の意味やライフサイクルが大きく異なるなら、一つのinterfaceへ無理に統一せず、目的ごとのモデル・ユースケースへ分けます。

## 出力契約

```yaml
module_separation:
  purpose: string
  consumers: []
  interface_part:
    operations:
      - name: string
        intent: string
        input_semantics: []
        output_semantics: []
        contract: []
        failures: []
        operation_semantics:
          deadline:
            status: "applicable | not_applicable | unknown"
            limit_or_condition: string
            timeout_result: string
            owner: string
            not_applicable_reason: string
            confirmation_method: string
            impact_if_unresolved: string
            evidence: []
          retry:
            status: "applicable | not_applicable | unknown"
            allowed_when: []
            prohibited_when: []
            owner: string
            not_applicable_reason: string
            confirmation_method: string
            impact_if_unresolved: string
            evidence: []
          idempotency:
            status: "applicable | not_applicable | unknown"
            key_scope: string
            duplicate_result: string
            owner: string
            not_applicable_reason: string
            confirmation_method: string
            impact_if_unresolved: string
            evidence: []
          duplicate:
            status: "applicable | not_applicable | unknown"
            duplicate_result_or_reason: string
            owner: string
            not_applicable_reason: string
            confirmation_method: string
            impact_if_unresolved: string
            evidence: []
          ambiguous_outcome:
            status: "applicable | not_applicable | unknown"
            observable_result: string
            reconciliation_owner: string
            forward_recovery_owner: string
            not_applicable_reason: string
            confirmation_method: string
            impact_if_unresolved: string
            evidence: []
  implementation_part:
    responsibilities: []
    technologies: []
    hidden_details: []
  leakage:
    - location: string
      leaked_detail: string
      impact: string
  change_scenarios:
    - scenario: string
      expected_affected_modules: []
  subject_verdict: separated | leaky | overabstracted | not_applicable | indeterminate
  decision_maturity:
    status: proposed | approved | frozen | unknown | contradiction
    owner: string
    approval_evidence: []
```

## 完了条件

- 公開操作が利用者の目的を表し、技術手順を露出していない。
- 入出力が実装ライブラリの型へ不要に結合していない。
- 利用者は実装の手順・分岐・保存方式を知らなくてよい。
- 契約と失敗の意味が定義されている。
- applicableなoperation semanticsだけが具体化され、非該当と未確定に理由・Evidenceまたは確認方法・影響がある。
- 新しい実装の追加で既存利用者の業務コードを変更しない。
- 関係の強いドメイン要素を、低結合のためだけに分断していない。
- interfaceの抽象度が目的単位で一貫している。

## 失敗パターン

- すべてのクラスにinterfaceを作る
- 実装が一つしかないことだけを理由に分離を否定する
- test mockを作るためだけの細切れinterface
- CRUD操作を並べただけの巨大Repository
- interface名が`IService`、`Manager`、`Processor`など目的不明
- 実装固有例外をそのまま公開する
- switchをfactoryへ移しただけで業務概念を整理しない
- 「結合度を下げる」を優先し、集約の整合性を壊す

## Skill用プロンプト骨子

```text
対象モジュールを、利用者に提供するインターフェイスパートと、契約を実現する実装パートに分解してください。
まず利用者、目的、公開契約を定義し、その後に実装詳細を分類してください。
言語上のinterfaceを作ること自体を目的にせず、技術詳細の漏出、呼び出し側に残る分岐、過大なinterface、ドメイン整合性の分断を検出してください。
代表的な変更シナリオで影響範囲を検証してください。
```

## 根拠と解釈

一次資料:

- [AI時代の『改訂新版 良いコード／悪いコードで学ぶ設計入門』](https://speakerdeck.com/minodriven/ai-good-code-bad-code): インターフェイスパートと実装パートの分離、およびその考え方に基づくinterface設計。

ミノ駆動氏の公開資料では、長大なトランザクションスクリプトに混在する関心を解決するため、モジュールをインターフェイスパートと実装パートへ分ける考え方が説明されています。また、この考え方からinterfaceを一から設計するノウハウへ展開しています。本書は、その主張をAI Skillへ落とすため、利用者・目的・契約・漏出・変更シナリオの判定へ具体化したものです。

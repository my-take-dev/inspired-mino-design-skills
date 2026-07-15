# 品質特性と変更容易性を明示する

## このノウハウの核

「良いコード」「高品質」「きれいにする」は評価基準が曖昧です。Skillは、改善対象となる品質特性を明示し、利用者または開発者が観測できるシナリオへ変換します。

ミノ駆動氏の公開資料では、利益を生み続けるビジネスソフトウェアの重要な軸として、特に次が重視されています。

- **機能性**: 利用者のニーズや目的を、機能が満たす度合い。
- **変更容易性**: なるべくバグを埋め込まず、素早く正確に変更できる度合い。

ただし、すべてのタスクで変更容易性を最優先にするのではなく、性能、セキュリティ、信頼性、使用性、移植性などとの優先順位とトレードオフを明示します。

品質目標には二つの粒度があります。

1. **局所品質目標**: 一つのmodule、use case、変更に対する品質シナリオ。
2. **アーキテクチャ品質戦略**: 複数module、データ、deploy、team、利用者journeyを跨いで品質特性を全体最適する判断。

局所的にコードが改善しても、システム全体の信頼性、運用性、変更リードタイムが悪化するなら、品質向上とは断定しません。

## 解決する問題

- AIへ「良いコードにして」と依頼しても、評価軸が揺れる。
- レビューが好みや流派の衝突になる。
- リファクタリング後の改善を説明できない。
- 行数、複雑度、重複率だけで負債を判定している。
- 変更容易性を「クラスが小さい」「依存が少ない」など単一指標で代用している。
- 各moduleは最適化されているが、end-to-endの変更や運用が悪化している。
- 品質特性の優先順位と、意図的に最適化しない品質が不明である。

## 必要な入力

- アクター、目的、ユースケース、変更理由。
- 対象システムの品質上の失敗例。
- 変更頻度、障害履歴、修正に要した調査範囲。
- 性能、セキュリティ、可用性などの非機能要件。
- 納期、互換性、運用、チームスキルの制約。
- 変更が複数moduleへ跨る場合は、依存、データ所有、公開契約、deploy、team ownership。

## 判断規則

### 1. 原典の表現、標準語彙、suite内表示名を分ける

公開資料では「機能性」「変更容易性」など、設計判断に使いやすい表現が使われています。一方、品質modelではcharacteristicとsubcharacteristicが階層化されています。Skill化では、どちらかへ無理に統一せず次を別fieldで保持します。

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

- `characteristic`と`subcharacteristic`を同じfieldの候補値にしない。
- `source_terms_ja`は公開資料の表現、`standard_term`は明示したreference modelの語彙、`display_name_ja`はsuiteまたはproject内の表示名として区別する。
- standardへ対応付けられないproject固有品質は`level: project_defined`とし、架空の標準対応を作らない。
- latency threshold等の数値constraintは品質語彙ではなく、対応する品質scenarioへ置く。

ISO/IEC 25010:2023はcharacteristicとsubcharacteristicからなる参照modelとして利用できますが、この標準自体をミノ駆動氏の主張として扱いません。

### 2. 品質特性を目的から選ぶ

品質特性はチェックリストを全適用しません。目的達成を妨げるリスクから選びます。

例:

| 状況 | 主に見る品質特性 |
|---|---|
| 顧客要求を満たしていない | 機能適合性 |
| 仕様変更で毎回広範囲が壊れる | 変更容易性、試験性 |
| 機密情報を扱う | セキュリティ |
| 高負荷時に応答できない | 性能効率性、信頼性 |
| 複数環境へ展開する | 移植性、互換性 |

### 3. 品質をシナリオで書く

形容詞ではなく、刺激、対象、環境、期待応答、測定方法を含めます。

```text
変更要求: 法人注文だけ割引ルールを追加する
対象: 注文ドメイン
環境: 既存の個人注文を稼働させたまま
期待応答: 法人向けモジュールとそのテストだけで変更が完結する
確認: 個人注文の契約テストが無変更で通り、法人向けテストが追加される
```

### 4. 変更容易性を構造要件へ変換する

変更容易性の高低を、次の問いで評価します。

- 変更対象の目的と責務を、名前と境界から特定できるか。
- 業務ルールが、それを所有すべきモデルへ集約されているか。
- 異なる目的や技術関心事が混ざっていないか。
- 不正な状態を外部から作れないか。
- 変更影響が目的境界を越えて伝播しないか。
- 現行挙動をcharacterization testのbaselineとして記録し、安全に変更できるか。
- 変更理由を知らない人でも、どこを直すべきか判断できるか。

行数やサイクロマチック複雑度は補助的な兆候であり、目的、責務、制約の妥当性を代替しません。

### 5. トレードオフを隠さない

抽象化、キャッシュ、非同期化、互換層などは、一つの品質を上げながら別の品質を下げることがあります。Skillは採用案ごとに、改善する品質、悪化し得る品質、受容理由を記録します。

### 6. 品質特性portfolioを作る

アーキテクチャや複数moduleへ影響する判断では、品質を次へ分類します。

```yaml
quality_definitions:
  - id: Q-MOD
    quality:
      reference_model: ISO/IEC 25010:2023
      level: subcharacteristic
      characteristic: maintainability
      subcharacteristic: modifiability
      standard_term: modifiability
      display_name_ja: 変更容易性
      source_terms_ja: [変更容易性]
  - id: Q-FCOR
    quality:
      reference_model: ISO/IEC 25010:2023
      level: subcharacteristic
      characteristic: functional_suitability
      subcharacteristic: functional_correctness
      standard_term: functional correctness
      display_name_ja: 機能正確性
      source_terms_ja: []
  - id: Q-FS
    quality:
      reference_model: ISO/IEC 25010:2023
      level: characteristic
      characteristic: functional_suitability
      subcharacteristic: not_applicable
      standard_term: functional suitability
      display_name_ja: 機能適合性
      source_terms_ja: [機能性]
  - id: Q-TEST
    quality:
      reference_model: ISO/IEC 25010:2023
      level: subcharacteristic
      characteristic: maintainability
      subcharacteristic: testability
      standard_term: testability
      display_name_ja: 試験性
      source_terms_ja: []
quality_portfolio:
  primary_ids: [Q-MOD, Q-FS]
  secondary_ids: [Q-TEST]
  constraint_ids: []
  intentionally_not_optimized_ids: []
```

- `primary`: 今回の設計判断で積極的に向上させる品質。
- `secondary`: primaryを支える品質。
- `constraints`: 最低限守るhard gate。
- `intentionally_not_optimized`: 今回は最大化せず、制約内へ留める品質。

全品質を同時に最大化しません。

`Q-FS`は公開資料の広い「機能性」をcharacteristicとして保持する例である。`Q-FCOR`は標準のsubcharacteristicを別IDで表す例であり、「機能性」をそのまま`functional correctness`へ縮約したものではない。

### 7. 局所効果と全体効果を分ける

変更がmodule境界を越える場合、次を別々に評価します。

- **local**: 対象moduleの理解、変更、テストは改善するか。
- **system**: network、data consistency、dependency、障害伝播はどう変わるか。
- **journey**: 利用者のend-to-end結果は改善するか。
- **organization**: owner、team間調整、on-call、releaseはどう変わるか。
- **future change**: 代表的な次の変更は局所化されるか。

局所効果だけでは、アーキテクチャ上の品質改善を承認しません。

### 8. 品質判断の責任者と再評価条件を持つ

重要なtrade-offは、AIやレビュー参加者の多数決だけで決めません。

- どのプロダクト価値を優先するか。
- どの品質劣化を受容するか。
- 誰が承認するか。
- 何を観測したら判断を見直すか。

複数module、data、deploy、teamへ波及する場合は、`27-architecture-quality-strategy.md`でArchitecture Decision Recordとtransitionを設計します。

## 実行手順

1. 目的と失敗シナリオを確認する。
2. 今回重要な品質特性を最大三つ程度に絞る。
3. 各品質特性を具体的な品質シナリオへ変換する。
4. 現在のコード、テスト、運用がシナリオを満たすか、根拠を集める。
5. 品質を妨げる構造上の原因を特定する。
6. 改善案ごとに品質への効果とトレードオフを比較する。
7. 複数moduleへ影響する場合、local / system / journey / organization / future changeを分けて評価する。
8. primary、secondary、constraint、非最適化対象を明示する。
9. 採用判断のownerと再評価triggerを記録する。
10. 実装後に観測可能な検証方法を決める。
11. 測定できない主張は仮説として残し、断定しない。

## 出力契約

```yaml
quality_goals:
  - id: Q1
    quality:
      reference_model: ISO/IEC 25010:2023
      level: subcharacteristic
      characteristic: maintainability
      subcharacteristic: modifiability
      standard_term: modifiability
      display_name_ja: 変更容易性
      source_terms_ja: [変更容易性]
    rationale: "この品質が目的達成に必要な理由"
    priority: primary | secondary | constraint | intentionally_not_optimized
    scenario:
      stimulus: "変更・障害・利用操作"
      artifact: "対象モジュール"
      environment: "通常時、障害時、移行中など"
      expected_response: "期待される振る舞い"
      verification: "テスト、計測、レビュー方法"
current_findings:
  - quality_goal: Q1
    evidence: "path:symbol、履歴、テスト、計測"
    impact: "品質上の影響"
options:
  - proposal: "改善案"
    improves: [Q1]
    degrades: []
    tradeoffs: []
    validation: []
whole_system_effects:
  local: []
  system: []
  journey: []
  organization: []
  future_change: []
decision:
  decision_maturity:
    status: proposed | approved | frozen | unknown | contradiction
    owner: string
    approval_evidence: []
  tradeoff_decisions:
    - statement: string
      decision_maturity:
        status: proposed | approved | frozen | unknown | contradiction
        owner: string
        approval_evidence: []
  review_trigger: string
```

コードレビューでは、各指摘を対象品質特性と結び付けます。単なるスタイル上の好みは、プロジェクト規約に反しない限り重大な品質問題として扱いません。

## 完了条件

- [ ] 「良い」「保守しやすい」などの曖昧語が、品質特性へ置き換えられている。
- [ ] 品質特性を選んだ理由が、目的または失敗リスクから説明されている。
- [ ] 各品質目標に観測可能なシナリオと検証方法がある。
- [ ] primary、constraint、意図的に最適化しない品質が区別されている。
- [ ] 変更容易性を単一の静的指標だけで判定していない。
- [ ] 改善案のトレードオフが記載されている。
- [ ] 複数moduleへ影響する場合、局所と全体の効果を分けている。
- [ ] 重要なtrade-offにownerと再評価triggerがある。
- [ ] 測定値がない場合に、架空の数値目標を作っていない。
- [ ] 実装後のpass / failを第三者が判定できる。

## 失敗パターン

- ISO等の品質モデルにある全項目を毎回評価し、判断を重くする。
- 「疎結合なら良い」と決めつけ、整合性を守るべき要素まで分断する。
- クラス数、行数、重複率の低下を成果として、変更シナリオを検証しない。
- 変更容易性のために、現時点で存在しない変化を大量に抽象化する。
- セキュリティや性能の明示要件を、設計の美しさより下位に置く。
- 局所的な可読性改善だけで、システム全体の品質向上を宣言する。
- すべての品質を同時に最大化しようとする。
- AIにtrade-offの最終受容判断を委ねる。

## エージェント向けプロンプト骨子

```text
対象の目的と変更理由から、今回優先すべきソフトウェア品質特性を選定してください。

- 各品質特性を、刺激・対象・環境・期待応答・検証方法を含む品質シナリオにする。
- primary、secondary、constraint、intentionally-not-optimizedへ分類する。
- 現在のコードがシナリオを妨げる箇所を、目的、責務、制約、依存、テストの観点で分析する。
- 行数や複雑度などの静的指標は兆候として使い、設計意図の代わりにしない。
- 改善案ごとに、向上する品質、悪化し得る品質、採用条件を示す。
- 複数moduleへ影響する場合、local、system、journey、organization、future changeの効果を分ける。
- 重要なtrade-offのowner、検証方法、再評価triggerを明示する。
- 事実、推測、未計測を区別する。
```

## 他スキルとの接続

- 目的の定義: `01-purpose-goal-means.md`
- 技術の引力と目的への遡行: `26-technical-gravity-and-abstraction-navigation.md`
- アーキテクチャ品質戦略: `27-architecture-quality-strategy.md`
- 技術的負債の優先順位: `04-technical-debt-goal-and-prioritization.md`
- AIへの品質指示: `16-ai-context-verbalization.md`
- 設計知識の評価観点化: `19-skill-modularization-and-scaling.md`

## 出典

- https://speakerdeck.com/minodriven/tech-gravity
- https://speakerdeck.com/minodriven/ai-and-software-quality
- https://speakerdeck.com/minodriven/architecture-and-productivity
- https://speakerdeck.com/minodriven/purpose-driven-architecture
- https://speakerdeck.com/minodriven/modifius
- https://levtech.jp/media/article/interview/detail_369/

品質語彙の階層を照合する参照model（ミノ駆動氏由来の資料ではない）:

- https://www.iso.org/standard/78176.html

> 公開資料を基に、品質シナリオ、品質portfolio、全体効果、出力契約、検証規則をSkill化のため再構成しています。

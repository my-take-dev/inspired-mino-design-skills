# プロダクト価値から品質特性を全体最適するアーキテクチャ戦略

## このノウハウの核

アーキテクチャは、流行している構成や特定のレイヤ数を選ぶことではありません。プロダクトが継続的に価値を生むため、**重要な品質特性を促進する構造上の意思決定を、システム全体で整合させること**です。

このSkillは、局所的にコードをきれいにするのではなく、次を一つの戦略へ接続します。

- 誰へ、どの価値を提供するか。
- どの品質特性がその価値を成立させるか。
- 現在の構造が、どの品質シナリオを妨げているか。
- どの境界、依存方向、データ所有、実行方式を変えるか。
- 何を意図的に最適化せず、どのtrade-offを受容するか。
- どの順序で移行し、何で効果と安全性を検証するか。

ここでいう全体最適は、すべての品質を最大化することではありません。目的、事業重要度、失敗リスク、変更予測に基づき、**優先する品質特性と許容する劣化を明示して、局所改善が全体を悪化させないようにすること**です。

## 解決する問題

次の症状があるときに使います。

- 「Clean Architectureにする」「マイクロサービス化する」が目的になっている。
- 各チームは局所最適しているが、利用者のjourneyや変更リードタイムは改善しない。
- 性能、変更容易性、信頼性、セキュリティの優先順位が部署ごとに違う。
- 一つの品質改善が、別の品質や運用コストを悪化させている。
- 重要な設計判断が会話だけで決まり、根拠、owner、再評価条件が残らない。
- target architectureはあるが、移行順、互換性、rollback、停止条件がない。
- AIが複数のアーキテクチャ案を提案するが、どれを採用すべきか人間が判断できない。
- コアドメインと汎用領域へ同じ設計コストを掛けている。

単一ファイル内の局所的な責務分割で、外部契約、データ所有、deploy、運用へ影響しない場合は、`02`や`10`〜`15`を優先し、このSkillを過剰適用しません。

## 必要な入力

### 価値と戦略

- 対象顧客、アクター、利用場面、提供価値。
- プロダクト戦略、ロードマップ、競争優位性、コアドメイン。
- 成功指標、失敗時の顧客・事業影響。

### 品質と事実

- 重要な品質特性と既存SLO、規制、セキュリティ要求。
- 変更失敗、障害、遅延、手戻り、運用負荷の履歴。
- 代表的な変更要求、負荷、障害、攻撃、移行シナリオ。
- 計測値がない場合は、観測事実と未計測を区別する。

### 構造と運用

- システムコンテキスト、module、service、データ、外部連携。
- 公開API、event、schema、認証・認可、データ保持契約。
- 依存方向、runtime communication、transaction boundary。
- deploy単位、障害境界、owner、on-call、release process。
- 既存ADR、過去の制約、移行中の暫定構造。

## アーキテクチャ判断の単位

設計判断は、少なくとも次のどれを変えるか明示します。

- **責務境界**: どのmodule、service、teamが何を所有するか。
- **依存方向**: 何が何を知り、どこへ技術詳細を隠すか。
- **データ所有**: source of truth、writer、reader、整合性境界。
- **公開契約**: API、event、schema、interface part。
- **実行方式**: 同期・非同期、transaction、retry、idempotency。
- **配備・障害境界**: deploy、rollback、capacity、observability。
- **変更境界**: 代表変更がどこで完結すべきか。

パッケージ名やdiagramだけでは、アーキテクチャ判断になりません。どの品質シナリオを改善するため、何を安定させ、何を可変にするかまで記述します。

## 判断規則

### 1. 名前付きアーキテクチャより、価値と品質から始める

悪い開始点:

- マイクロサービスへ移行する。
- Clean Architectureへ統一する。
- event-drivenにする。

改善した開始点:

```text
法人向け料金ルールを個人向け注文へ影響させず、2週間以内に安全に変更できるようにする。
```

名前付きパターンは、品質シナリオを満たす候補手段として比較します。

### 2. 品質特性portfolioを作る

一つの判断期間で、主に最適化する品質特性を原則3つ以内に絞ります。

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

`intentionally_not_optimized`は品質を軽視する意味ではありません。今回の投資対象にせず、最低制約だけ守ると明示するものです。
品質definitionは`02`の階層schemaを使い、characteristic、subcharacteristic、standard term、source term、suite / project内表示名を分けます。広い「機能性」は`Q-FS`、標準の`functional correctness`は`Q-FCOR`として別IDにし、暗黙に同義化しません。SLOやthresholdはquality名へ混ぜず、対応するscenarioの期待応答またはconstraintへ置きます。

### 3. 品質を代表シナリオへ変換する

```text
刺激: 法人向け割引方式を追加する
対象: 注文・価格計算領域
環境: 個人向け注文を稼働させたまま
期待応答: 法人向けpolicyと契約テストの追加だけで完結する
測定: 個人注文moduleのproduction codeが無変更で、既存契約テストが通る
```

性能、信頼性、セキュリティ、運用性も同じ形式で書きます。

### 4. 局所改善と全体効果を分ける

各案について、局所と全体を別に評価します。

| 観点 | 問い |
|---|---|
| Local benefit | 対象moduleで何が改善するか |
| System effect | 他module、データ、network、運用へ何が波及するか |
| Journey effect | 利用者のend-to-end結果は改善するか |
| Organizational effect | owner、調整、on-call、releaseに何が起きるか |
| Future change | 次の代表変更が局所化されるか |

一つのclassがきれいになっても、API呼び出し、分散transaction、複数team調整が増えるなら全体最適とは限りません。

### 5. 品質trade-offを決定事項として残す

例:

- 強整合性を保つため、独立deploy性を下げる。
- 応答時間を守るためcacheを導入し、解析性と運用複雑性を受容する。
- 段階移行のため一時的なadapterを置き、削除期限とownerを設定する。

改善する品質だけでなく、悪化し得る品質、受容理由、監視指標、撤回条件を記録します。

### 6. 不可逆性に応じて証拠の強さを変える

- 可逆で局所的: 小さなprototypeや一moduleで検証する。
- 外部契約変更: consumer inventory、互換性、移行windowを確認する。
- データ所有変更: migration、backfill、dual-read/write、recoveryを設計する。
- service分割・統合: deploy、observability、team ownership、障害伝播を検証する。
- 法令・security・課金: 専門reviewと明示的承認を必須にする。

### 7. targetだけでなくtransition architectureを設計する

```text
current
  → protective tests / observability
  → stable interface
  → new responsibility owner
  → controlled migration
  → cutover
  → old path removal
```

各phaseは、独立した利用価値またはリスク低減と、二値判定可能な完了条件を持ちます。

### 8. source of truthとauthorityを一意にする

- どのcomponentが状態を変更できるか。
- どのmodelが不変条件を所有するか。
- どのschema、event、serviceがauthoritativeか。
- cache、read model、replicaを真実の所有者と混同していないか。

複数のwriterやauthorityが必要なら、競合解決と整合性契約を明示します。

### 9. 人間とAIの責務を分ける

- AI: 現状構造のinventory、品質シナリオ候補、代替案、trade-off、依存影響、検証項目を提案する。
- 人間: 顧客価値、優先品質、許容する劣化、移行リスク、不可逆な判断を所有する。
- AI: 採用方針内でtarget/transition設計、テスト、migration手順を具体化する。
- 人間: 実行結果と事業・運用への影響を確認し、採用・撤回を決める。

AIの説明の流暢さを、アーキテクチャ判断の根拠にしません。

### 10. 代表シナリオで構造を検証する

diagramレビューだけで終わらせず、次を可能な範囲で実行します。

- 代表機能変更のimpact simulation。
- contract testとarchitecture dependency test。
- failure injection、retry、partial failure。
- load / latency test。
- threat modelとauthorization test。
- migration dry-runとrollback rehearsal。
- operational runbook review。

## 実行手順

### Phase 0: Strategy frame

1. 今回の意思決定、対象期間、owner、期限を記録する。
2. アクター、提供価値、コアドメイン、ロードマップを整理する。
3. 名前付きアーキテクチャ案を`candidate_means`へ退避する。
4. 可逆・不可逆の判断を分類する。

### Phase 1: Quality portfolio

5. 顧客・事業上の失敗から品質特性候補を抽出する。
6. primary、secondary、constraint、非最適化対象へ分類する。
7. 代表品質シナリオとpass / failを定義する。
8. 品質同士の競合を明示する。

### Phase 2: Current architecture evidence

9. module、service、data、contract、owner、deployをinventory化する。
10. 各品質シナリオを妨げる構造上の原因を根拠付きで特定する。
11. source of truth、writer、reader、authorityを確認する。
12. 既存の良い境界と維持契約を記録する。

### Phase 3: Options and trade-offs

13. 現状維持を含む複数案を作る。
14. 各案をlocal / system / journey / organization / future changeで比較する。
15. 品質改善、劣化、cost、migration、recoveryを比較する。
16. 不可逆性に応じたevidence gateを通す。

### Phase 4: Decision record

17. 採用案、却下案、理由、反証、unknownを記録する。
18. 変更する責務、依存、データ、契約、実行・配備境界を定義する。
19. owner、承認者、再評価triggerを決める。
20. Architecture Decision Recordを作成する。

### Phase 5: Transition design

21. currentからtargetまでをrollback可能なphaseへ分ける。
22. compatibility、migration、cutover、observability、old path removalを設計する。
23. 各phaseへ完了条件、abort condition、recoveryを付ける。
24. team ownership、runbook、support、communicationを更新する。

### Phase 6: Validation and learning

25. 代表品質シナリオを実行またはsimulationする。
26. 期待した品質改善と副作用を計測する。
27. 前提が外れた場合、ADRとtargetを更新する。
28. 一時構造を削除し、成果と反例をSkill benchmarkへ戻す。

## 出力契約

```yaml
architecture_quality_strategy:
  decision:
    question: string
    horizon: string
    owner: string
    approvers: []
    reversibility: reversible | costly | irreversible | unknown
    decision_maturity:
      status: proposed | approved | frozen | unknown | contradiction
      approval_evidence: []
  value_frame:
    actors: []
    desired_outcomes: []
    core_domain: []
    roadmap_drivers: []
  quality_portfolio:
    definitions: []
    primary_ids: []
    secondary_ids: []
    constraint_ids: []
    intentionally_not_optimized_ids: []
  scenarios:
    - id: QS-01
      quality_id: Q-MOD
      stimulus: string
      artifact: string
      environment: string
      expected_response: string
      measure: string
  current_architecture:
    components: []
    contracts: []
    data_authority: []
    ownership: []
    evidence: []
  options:
    - id: O1
      summary: string
      quality_improvements: []
      quality_regressions: []
      system_effects:
        local: []
        system: []
        journey: []
        organization: []
        future_change: []
      cost_and_risk: []
      validation: []
  option_decision:
    selected_option_id: O1
    decision_maturity:
      status: proposed | approved | frozen | unknown | contradiction
      owner: string
      approval_evidence: []
    rationale: string
    counterevidence: []
    assumptions: []
    unknowns: []
  target_architecture:
    responsibilities: []
    dependency_rules: []
    data_ownership: []
    public_contracts: []
    deploy_and_failure_boundaries: []
  transition:
    - phase: string
      changes: []
      compatibility: []
      validation: []
      rollback: []
      abort_conditions: []
      exit_criteria: []
  adr:
    lifecycle_status: current | superseded | rejected | unknown
    decision_maturity:
      status: proposed | approved | frozen | unknown | contradiction
      owner: string
      approval_evidence: []
    decided_at: YYYY-MM-DD
    review_trigger: string
  final_gate:
    status: ready | blocked
    reasons: []
```

## 完了条件

- [ ] 判断が名前付きアーキテクチャではなく、価値と品質シナリオから始まっている。
- [ ] primary品質特性、制約、意図的に最適化しない品質が区別されている。
- [ ] 各品質特性に観測可能な代表シナリオがある。
- [ ] 局所効果とsystem / journey / organizationへの影響を比較している。
- [ ] 現状維持を含む複数案とtrade-offを比較している。
- [ ] source of truth、writer、authority、ownerが明確である。
- [ ] 採用判断に根拠、反証、仮定、unknown、再評価triggerがある。
- [ ] targetだけでなく、移行、互換性、rollback、old path削除がある。
- [ ] 不可逆性に応じた承認と検証がある。
- [ ] 代表品質シナリオで構造を検証できる。
- [ ] AIではなく、権限を持つ人間が価値とtrade-offを承認している。

## Hard gates

次のいずれかがあれば`ready`にしません。

- 対象アクターと提供価値が不明。
- 優先品質特性が選ばれていない。
- 品質目標が形容詞だけで、シナリオと測定方法がない。
- 外部契約、データauthority、security boundaryの影響が未確認。
- 不可逆な変更にmigration、recovery、明示的承認がない。
- target architectureだけでtransitionがない。
- 一時adapterやdual-writeにownerと削除条件がない。
- AI提案の説明だけで採用し、代表シナリオを検証していない。

## 失敗パターン

- すべての品質を同時に最高にしようとする。
- 図を整えることを成果にし、変更・障害・移行シナリオを試さない。
- コードの依存だけ見て、data、deploy、team、operationsを無視する。
- マイクロサービス数やレイヤ数を成熟度の指標にする。
- コアと汎用領域へ同じ設計密度を適用する。
- targetへ一括移行し、rollback不能にする。
- 暫定互換層を期限なしで残す。
- AIが挙げたtrade-offを、計測や関係者確認なしに事実扱いする。
- 局所的な変更容易性のため、system全体の信頼性や運用性を悪化させる。

## Skill用プロンプト骨子

```text
対象プロダクトの価値とロードマップから、アーキテクチャ品質戦略を作成してください。

1. 対象アクター、提供価値、コアドメイン、意思決定期間を特定する。
2. 名前付きアーキテクチャを先に選ばず、primary / secondary / constraint / intentionally-not-optimizedの品質portfolioを作る。
3. 各品質特性を刺激・対象・環境・期待応答・測定方法を持つ代表シナリオにする。
4. 現状の責務、依存、データauthority、契約、deploy、ownerを根拠付きで調べる。
5. 現状維持を含む複数案を、局所・system・journey・organization・将来変更の観点で比較する。
6. 改善と劣化のtrade-off、仮定、counterevidence、不可逆性を示す。
7. target architectureと、互換性・migration・rollback・observability・旧経路削除を含むtransition architectureを設計する。
8. 代表品質シナリオによる検証と、再評価triggerを定義する。
9. 価値とtrade-offの最終承認者を明示する。
```

## 他資料との接続

- 目的・目標・手段: `01-purpose-goal-means.md`
- 品質シナリオ: `02-quality-attributes-and-modifiability.md`
- 事業価値とコアドメイン: `03-business-value-and-core-domain.md`
- 技術的負債の優先順位: `04-technical-debt-goal-and-prioritization.md`
- 境界付けられたコンテキスト: `05-purpose-based-bounded-contexts.md`
- 技術の引力と具体・抽象: `26-technical-gravity-and-abstraction-navigation.md`
- インターフェイスと実装の分離: `21-interface-implementation-separation.md`
- 再現可能なAI開発: `23-reproducible-ai-development.md`

## 出典と操作的解釈

主な根拠:

- https://speakerdeck.com/minodriven/tech-gravity
- https://speakerdeck.com/minodriven/purpose-driven-architecture
- https://speakerdeck.com/minodriven/ai-and-software-quality
- https://speakerdeck.com/minodriven/architecture-and-productivity
- https://speakerdeck.com/minodriven/design-for-profit

公開資料では、アーキテクトがプロダクト価値のために、品質特性を促進する構造上の重要判断を行い、戦略的・全体的に品質を最適化する役割であること、また開発生産性を機能性・変更容易性・事業価値へ接続する考え方が説明されています。

この文書のquality portfolio、local/system/journey/organization比較、transition architecture、ADR、reversibility gateは、それらをSkillとして反復可能にするための操作的解釈です。

# 要件を再現するAI開発ワークフロー

## 中心命題

AI開発の再現性は、同じソースコードを毎回生成することではありません。

**実装詳細が変わっても、同じ問題を解き、同じ要件・契約・ドメイン整合性・品質戦略・公開境界を満たすこと**です。

そのために、生成前から受入判定まで次をEvidence状態とdecision maturity付きで記録します。AIが作った候補は`proposed`、権限を持つownerが採用したものは`approved`、versioned比較baselineとしてchange control下に置くものだけを`frozen`とします。

1. **問題定義**: 誰の、どの問題を解くか。
2. **Context Packet**: どの文脈、意味、ルール、変更境界で判断するか。
3. **ドメインモデル完全性**: 何を欠落させてはならないか。
4. **契約による設計**: 何を必ず満たすか。
5. **インターフェイスと実装の分離**: 何を安定させ、何を変更可能にするか。
6. **品質戦略**: どの品質を優先し、どのtrade-offを受容するか。
7. **独立検証**: AIの説明ではなく、何をもって妥当と判定するか。

## 人間とAIの主導権

AIを常に主役または常に補助と固定しません。工程ごとに主導権を切り替えます。

| 工程 | Pilot | Copilot | 最終責任 |
|---|---|---|---|
| 問題定義・価値・成功条件 | 人間 | AI | 人間 |
| 前提・別解釈・証拠不足の洗い出し | 人間 | AI | 人間 |
| 設計・実装・テスト候補の生成 | AI | 人間 | 人間 |
| 技術trade-offの比較 | AI | 人間 | 人間 |
| 契約・完全性・品質gateの実行 | Tool / test | AIと人間 | 人間 |
| 受入・出荷・不可逆な変更 | 人間 | AI | 権限を持つ人間 |

- 問題定義では、人間がpilot、AIがcopilotです。
- 問題解決では、明確な仕様パッケージの範囲内でAIをpilotにできます。
- 成果物の妥当性、価値、trade-off、出荷可否は、人間が所有します。

AIへ問題と価値を自動確定させず、人間が実装詳細をすべて手作業で指定してAIの探索能力を潰すこともしません。

## 統合する概念の関係

```text
観測事実・依頼
  ↓  前提点検と問題定義
技術の引力を除いた問題文
  ↓  具体⇄抽象の往復
アクター・目的・文脈・ルール・成功条件
  ↓  Context Packet
要件catalogと品質portfolio
  ↓
ドメイン概念・状態・制約のinventory
  ↓  ドメインモデル完全性
事前条件・事後条件・不変条件・失敗後状態
  ↓  契約による設計
interface part（安定した意味と操作）
  ↓  インターフェイスと実装の分離
implementation part（交換可能な実現手段）
  ↓  品質戦略とallowed / prohibited structures
実装生成
  ↓
契約テスト・完全性監査・品質シナリオ・変更シナリオ
  ↓
人間による妥当性・価値・trade-offの受入判定
```

どれか一つだけでは不十分です。

- 問題定義なし: 正しく実装しても、解くべき問題が違う。
- Context Packetなし: 同じ語をAIと人間が異なる意味で使う。
- 契約だけ: 必要概念の抽出が漏れていれば、契約自体が不完全。
- 完全性だけ: 概念が揃っていても、検証可能な保証になっていない。
- interface分離だけ: 空疎な抽象化の背後に誤った実装を隠せる。
- 品質戦略なし: 局所的に美しくても、system全体や事業価値を悪化させる。
- 独立検証なし: AIの自己説明を品質の証拠と誤認する。

## Skillの実行フェーズ

### Phase -3: Decision and authority frame

最初に次の確認可能な項目を特定し、Evidence状態とdecision maturityを記録します。未確認項目はunknownまたはcontradictionとして保持します。

- 今回決めること、決めないこと。
- 対象アクターとdecision owner。
- 可逆・不可逆の判断。
- 公開契約、データ、security、課金、法令に関する承認者。
- 期限と停止条件。

低リスクの内部実装選択と、権限を要する価値・契約変更を分けます。

### Phase -2: Problem-definition gate

`17-premise-checking-and-problem-definition.md`を使います。

1. 観測事実、解釈、前提、仮説、問題、解決策を分ける。
2. 技術名を使わず、アクター、文脈、目的、阻害要因、損失で問題を書く。
3. 重要な前提へ根拠と反証条件を付ける。
4. 少なくとも一つの合理的な別解釈を作る。
5. 成功条件、失敗条件、維持契約を定義する。

次の場合は実装へ進みません。

- 対象アクターまたは目的が不明。
- 問題文が技術手段そのものになっている。
- 重要な前提に反証条件がない。
- 別解釈によって結果が大きく分岐するのに未確認。
- 成功条件を観測できない。

### Phase -1: Technical-gravity and context gate

`26-technical-gravity-and-abstraction-navigation.md`と`16-ai-context-verbalization.md`を使います。

1. 提示済みの技術案を`candidate_means`へ退避する。
2. `つまり`で具体的な技術・コードから利用者目的へ遡る。
3. `たとえば`で目的から目標、契約、設計、テストへ戻る。
4. アクター、目的、文脈、ルール、品質、変更境界をContext Packetにする。
5. AIへ短く復唱させ、statement、comparison basis、proposed status、differences、review主体を分ける。

復唱の`proposed_status`が問題定義、意味、維持契約、成功条件と一致しなければ実装へ進みません。AI自身のmatch提案はEvidenceではなく、公開契約、data meaning、金銭、認可、安全、不可逆判断を分岐させる場合は、人間または独立evaluatorのaccepted reviewを必要とします。

### Phase 0: Evidence collection

収集対象:

- 依頼原文、要件、受入条件、仕様書。
- 既存コード、テスト、schema、設定。
- 用語集、業務フロー、状態遷移。
- API、event、DBの外部契約。
- incident、bug、support、利用観察。
- roadmap、品質要求、過去の設計判断。

出力を次へ分けます。

- `confirmed`: 明示的な根拠あり。
- `inferred`: 複数の根拠から推定。
- `assumption`: 作業を進めるための一時仮定。
- `unknown`: 結果を分岐させる不足。
- `contradiction`: 根拠同士が競合。

### Phase 1: Requirement normalization

各要件へIDを付け、観測可能な文へします。

```yaml
- id: R-01
  actor: customer
  context: order_confirmation
  trigger: confirm_order
  expected_result: order_becomes_confirmed
  prohibited_result: confirmation_with_zero_items
  quality_constraint_ids: [Q-FCOR]
  evidence: specification_section_3_2
```

要件へ次を対応付けます。

- 問題定義のどの成功条件か。
- どのアクターと目的を支えるか。
- どの品質特性を守るか。
- どの外部契約へ影響するか。

### Phase 2: Quality strategy

`02-quality-attributes-and-modifiability.md`を使い、複数module、data、deploy、teamへ影響する場合は`27-architecture-quality-strategy.md`も使います。

1. characteristic、subcharacteristic、standard term、source term、suite / project内表示名を分けたquality definitionを作り、primary、secondary、constraint、意図的に最適化しない品質をIDで選ぶ。
2. 刺激、対象、環境、期待応答、測定方法を持つ品質シナリオを作る。
3. 局所効果とsystem / journey / organizationへの影響を分ける。
4. 重要なtrade-off、owner、再評価triggerを記録する。
5. 不可逆な変更にはtransition、rollback、承認を設計する。

### Phase 3: Domain completeness map

要件ごとに次を埋めます。

- concept。
- value constraint。
- state。
- transition。
- behavior owner。
- failure。
- writer / reader。
- time meaning。
- authority / source of truth。

欠落がある間は実装へ進みません。

### Phase 4: Contract definition

公開操作ごとに次を定義します。

- 事前条件。
- 事後条件。
- 不変条件。
- 失敗時状態。
- idempotency / ordering。
- 契約所有者。
- 対応する要件IDと根拠。

契約の根拠が要件へ追跡できない場合は、`assumption`として分離します。

### Phase 5: Boundary design

モジュールごとに次を定義します。

- 利用者。
- 目的。
- interface part。
- implementation part。
- 公開する失敗。
- 副作用。
- 変更可能な技術要素。
- allowed dependencies。
- prohibited leakage。

interface型を作ること自体を目的にせず、利用者が知るべき意味と、知らなくてよい実現手段を分けます。

### Phase 6: Test-first rejection criteria

実装生成前に、拒否条件を作ります。

- 問題定義と異なるアクター・目的を実装している。
- 契約テストが失敗する。
- 要件IDに対応するテストがない。
- 不正状態を公開経路から生成できる。
- 業務ルールがController、UI、adapterへ漏出する。
- interfaceが実装技術を露出する。
- 新規実装追加で既存callerの業務コード変更が必要になる。
- 失敗後の状態が未定義である。
- primary品質シナリオを満たさない。
- constraint品質を破る。
- 目的へtraceできない変更がある。
- 重要な`unknown`または`contradiction`を隠している。

### Phase 7: Implementation generation

AIには、権限を持つownerが`approved`またはversioned baselineとして`frozen`にした仕様パッケージを渡します。未承認のAI候補を固定仕様と呼びません。

- problem definition。
- abstraction navigationとcandidate means。
- Context Packet。
- requirement catalog。
- quality portfolioとarchitecture decision。
- domain completeness map。
- contract table。
- interface definitions。
- allowed dependencies。
- prohibited structures。
- test planとrejection criteria。

実装方法を過度に一意指定せず、契約・品質・境界内で選択させます。

生成中、AIは次を勝手に変更しません。

- 対象アクターと目的。
- 要件の意味。
- 公開契約。
- ドメイン不変条件。
- 品質の優先順位。
- 破壊的変更の許可範囲。

### Phase 8: Independent verification

実装を生成したAIの自己説明だけで承認しません。

- test実行。
- type / static analysis。
- requirement traceability再監査。
- mutationまたは反例テスト。
- architecture dependency確認。
- representative change scenario。
- quality scenarioの測定またはsimulation。
- model / interface leakage監査。
- migration dry-runとrollback確認。

可能なら、生成担当と検証担当を分けます。同一AIを使う場合も、生成時の説明ではなく`approved | frozen`な成果物と実行結果から再判定します。

### Phase 9: Human validity and acceptance gate

人間が次を確認します。

1. 元の問題と成功条件を本当に改善しているか。
2. 利用者・事業・運用にとって妥当な結果か。
3. 受容したtrade-offと、想定外の副作用は何か。
4. 未解決の`unknown`と`contradiction`を隠していないか。
5. 破壊的変更、security、課金、法令に必要な承認があるか。
6. rollbackまたはforward recoveryが可能か。

テストが通るだけで、問題解決と出荷を自動承認しません。

### Phase 10: Reproduction test

必要に応じて複数回生成し、コード差ではなく次を比較します。

| Evaluation | Run A | Run B | Run C |
|---|---|---|---|
| Solves approved problem | pass | pass | pass |
| Contract tests | pass | pass | pass |
| Requirements covered | 100% | 100% | 100% |
| Quality constraints | pass | pass | pass |
| Invalid states constructible | no | no | no |
| Interface leakage | none | none | none |
| Model omissions | none | none | none |
| Human validity gate | accept | accept | accept |

複数回の生成結果が異なる場合、最も短いコードではなく、品質シナリオ、変更局所性、理解容易性、運用リスクで比較します。

## 実装へ渡す仕様パッケージ

```yaml
implementation_spec:
  decision_frame:
    owner: string
    scope: []
    out_of_scope: []
    reversibility: reversible | costly | irreversible | unknown
    decision_maturity:
      status: proposed | approved | frozen | unknown | contradiction
      owner: string
      approval_evidence: []
      baseline_version: string
      change_control: string
  problem_definition:
    actor: string
    context: string
    desired_state: string
    observed_obstacle: string
    impact: string
    success_conditions: []
    counterevidence: []
  abstraction_navigation:
    technical_gravity_signals: []
    purpose_ladders: []
    candidate_means: []
  context_packet:
    terminology: []
    rules: []
    must_preserve: []
    may_change: []
    must_not_change: []
    unknowns: []
    ai_restatement:
      statement: string
      comparison_basis: []
      proposed_status: matched | mismatched | blocked
      differences: []
      reviewed_by:
        kind: user | human_owner | independent_evaluator | unresolved
        identity: string
        review_status: accepted | rejected | unresolved
        evidence: []
  requirements: []
  quality_strategy:
    definitions: []
    primary_ids: []
    secondary_ids: []
    constraint_ids: []
    intentionally_not_optimized_ids: []
    scenarios: []
    tradeoff_decisions:
      - statement: string
        decision_maturity:
          status: proposed | approved | frozen | unknown | contradiction
          owner: string
          approval_evidence: []
  domain_model:
    concepts: []
    states: []
    transitions: []
    invariants: []
    failures: []
    authority: []
  contracts: []
  boundaries:
    - module: string
      consumers: []
      interface_part: []
      implementation_constraints: []
      allowed_dependencies: []
  prohibited:
    - domain_rule_in_controller
    - invalid_aggregate_construction
    - implementation_type_in_public_contract
    - unapproved_contract_change
    - primary_quality_scenario_failure
  verification:
    tests: []
    analysis: []
    quality_scenarios: []
    change_scenarios: []
    human_acceptance: []
    exit_criteria: []
```

## 品質特性との接続

ミノ駆動氏は、AIへ「良いコード」と曖昧に指示するのではなく、どのソフトウェア品質特性を高めるか指定すべきだと説明しています。

このワークフローで主に扱うのは次です。下の項目はいずれも、機能適合性または保守性のsubcharacteristicです。親characteristicとは別fieldへ置きます。

- 機能完全性: 必要機能の欠落がない。
- 機能正確性: 契約どおりの結果になる。
- モジュール性: interface partとimplementation partが分離される。
- 修正性: 実装変更が利用者へ波及しにくい。
- 試験性: 契約を独立して検証できる。
- 解析性: モデルと要件の対応が追跡できる。

性能、セキュリティ、信頼性、使用性、運用性などが重要なら、別契約と品質gateを追加します。

## 実行時の停止条件

- 対象アクターまたは問題定義が不明。
- 技術語を除くと問題を説明できない。
- Context Packetのrestatementがmismatched / blockedである、または高impactな判断に必要な独立reviewがない。
- 要件同士が矛盾している。
- 重要な業務語の意味が確定しない。
- 状態遷移のauthorityが不明。
- 外部契約の変更可否が不明。
- 不変条件をどの境界で守るか決められない。
- primary品質特性とconstraintが未定義。
- 不可逆な変更に承認、migration、recoveryがない。
- 破壊的変更の許可がない。

低リスクの命名や内部アルゴリズムの選択は、仮定を記録して進めます。

## 完了条件

- [ ] 問題定義が人間に承認され、技術手段と分離されている。
- [ ] Context Packetのrestatement、comparison basis、提案status、差分、review主体が分離され、高impactな判断ではaccepted review Evidenceがある。
- [ ] 全要件が目的、モデル、契約、interface、testへ追跡できる。
- [ ] 重要概念、制約、状態、遷移、失敗に欠落がない。
- [ ] 契約所有者と状態変更authorityが一意である。
- [ ] interface partが目的と意味を表し、実装技術を隠している。
- [ ] primary品質シナリオを満たし、constraint品質を破っていない。
- [ ] implementation partを変更しても契約テストが再利用できる。
- [ ] 不正状態を生成する公開経路がない。
- [ ] AIの自己評価ではなく、実行結果とtraceabilityで検証している。
- [ ] 人間が問題改善、価値、trade-off、残存リスクを受入判定している。
- [ ] 複数生成結果を同じ判定基準で合否判定できる。

## 失敗パターン

- プロンプトを長くすれば再現性が上がると考える。
- 問題定義と要件の意味をAIへ丸投げする。
- コードスタイルの一致を要件再現性と混同する。
- snapshot testだけで契約を固定する。
- 既存コードの全挙動を正しい要件とみなす。
- interfaceを先に量産し、ドメイン理解を後回しにする。
- モデル図を作って終わり、writerや失敗経路を確認しない。
- 一度の成功生成でSkillを完成扱いする。
- テスト合格だけで、利用者にとっての妥当性を自動承認する。
- 局所的な変更容易性だけを最適化し、system全体の品質を悪化させる。
- AIの説明を、人間の受入判断の代わりにする。

## Skill用統合プロンプト骨子

```text
要件を直接実装しないでください。次のgateを順番に通してください。

1. 観測、解釈、前提、仮説、問題、解決策を分け、技術名を使わないProblem Definitionを作る。
2. 技術の引力を監査し、「つまり」で目的へ遡り、「たとえば」で目標、契約、実装、テストへ戻る。
3. アクター、目的、文脈、ルール、品質、変更境界をContext Packetにし、実装前に復唱する。
4. 要件ID付きのrequirement catalogを作る。
5. primary / secondary / constraint / intentionally-not-optimizedの品質portfolioと代表シナリオを作る。
6. ドメイン概念、制約、状態、遷移、失敗、writer / reader / authorityの完全性表を作る。
7. 各公開操作の事前条件、事後条件、不変条件、失敗時状態を定義する。
8. 利用者と目的に基づくinterface part、implementation partを設計する。
9. Given-When-Then形式の契約テスト、品質シナリオ、拒否条件を先に定義する。
10. `approved`またはversioned baselineとして`frozen`な仕様パッケージ内で実装候補を生成する。
11. 実装後、全要件のtraceability、不正状態の生成可否、技術詳細の漏出、代表変更、品質シナリオを独立に検証する。
12. 最後に、人間が元の問題を改善したか、trade-offと残存リスクを受容できるか判定する。

根拠のない内容はconfirmedにせず、inferred、assumption、unknown、contradictionへ分けてください。
```

## 結論

AIによるコード生成を安定させる鍵は、生成モデルへ細部まで同じ書き方を強制することではありません。

- 問題定義で、解く対象を誤らない。
- Context Packetで、意味と判断境界を共有する。
- ドメインモデル完全性で、必要な意味を欠落させない。
- 契約による設計で、守るべき結果を検証可能にする。
- インターフェイスと実装の分離で、安定部分と可変部分を分ける。
- 品質戦略で、局所改善をプロダクト価値と全体最適へ接続する。
- 独立検証と人間の妥当性判断で、AIの自己評価へ依存しない。

これらによって、生成の揺らぎを許容しながら、同じ問題に対する要件適合性と価値を繰り返し再現できるようにします。

## 関連資料

- 問題定義: `17-premise-checking-and-problem-definition.md`
- Context Packet: `16-ai-context-verbalization.md`
- 技術の引力と具体・抽象: `26-technical-gravity-and-abstraction-navigation.md`
- 品質特性: `02-quality-attributes-and-modifiability.md`
- アーキテクチャ品質戦略: `27-architecture-quality-strategy.md`
- ドメインモデル完全性: `22-domain-model-completeness.md`
- 契約による設計: `20-design-by-contract.md`
- インターフェイスと実装の分離: `21-interface-implementation-separation.md`

## 出典と操作的解釈

- https://speakerdeck.com/minodriven/tech-gravity
- https://speakerdeck.com/minodriven/ai-philosophy-cognitive-science
- https://speakerdeck.com/minodriven/doubt-premise
- https://speakerdeck.com/minodriven/ai-context-verbalization
- https://speakerdeck.com/minodriven/ddd-in-ai-era
- https://speakerdeck.com/minodriven/ai-refactoring-approach
- https://speakerdeck.com/minodriven/ai-and-software-quality
- https://speakerdeck.com/minodriven/purpose-driven-architecture

> 公開資料で明示された問題定義、妥当性検証、文脈、目的・目標・手段、契約、モデル、品質特性の考え方を基に、工程間のgate、役割表、仕様パッケージ、受入判定をSkill用に操作化しています。

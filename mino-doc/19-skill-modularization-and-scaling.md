# 設計知識をモジュール化し、Skillとしてスケールする

## このノウハウの核

設計ノウハウをAIへ渡すとき、すべてを一つの巨大プロンプトへ詰め込むと、適用条件、優先順位、技術差分、出力形式が混ざり、品質と保守性が下がります。

ミノ駆動氏が紹介するモディフィウスは、変更容易性に関する基盤的な考え方を持つコアプロンプトを中心に、負債分析、設計改善、テスト実装などの機能、DDDやフレームワークなどの設計観点、GoやJavaなどの言語差分を組み合わせられるよう、モジュール化されています。

Skill化では、設計知識を次の層へ分けます。

1. **Core principles**: 技術に依存しない目的、品質特性、設計原則、証拠方針。
2. **Task functions**: 負債分析、モデル監査、設計提案、テスト生成、実装、レビュー。
3. **Design viewpoints**: DDD、契約による設計、関心の分離、interface設計などの評価レンズ。
4. **Architecture / framework adapters**: Spring Boot、Laravel、Reactなど、配置や境界に関する技術固有知識。
5. **Language adapters**: Go、Java、Kotlin、PHPなど、構文、型、テスト、toolchainへの翻訳。
6. **Presentation layer**: Markdown、YAML、diagram、review commentなどの成果物形式。
7. **Evaluation**: benchmark、hard gate、回帰試験、複数実行間の要件適合率。

人物の口調を模倣するのではなく、判断規則、入力、成果物、拒否条件を再現可能にします。

## 解決する問題

次の症状があるときに使います。

- 一つの`SKILL.md`が長大で、どの規則がいつ使われるか分からない。
- Go向けの実装規則が、JavaやTypeScriptのタスクにも誤適用される。
- 負債分析、設計提案、テスト生成が互いに異なる品質基準を使っている。
- フレームワーク追加のたびに、コア原則をコピーして差分が生じる。
- AIの出力形式だけが整っていて、判断の根拠やhard gateが揃っていない。
- 設計有識者一人にレビューや相談が集中し、組織へ展開できない。
- Skill更新後に、以前通っていたタスクの品質が下がっても検知できない。
- 「○○氏らしく」のようなpersona依存で、品質を客観評価できない。

小さく単一用途で、技術差分も将来拡張もないSkillを、無理に多数のモジュールへ分割する必要はありません。

## 必要な入力

- 共有したい設計原則と、その根拠資料。
- 対象タスクの一覧と、利用頻度、失敗例、期待成果物。
- 対応する言語、フレームワーク、アーキテクチャ。
- 既存の`SKILL.md`、prompt、MCP tool、agent定義。
- 共通する品質gate、禁止事項、証拠方針。
- Skillを利用する実行環境と配置規則。
- 代表的なbenchmark taskと期待結果。
- owner、更新頻度、互換性、versioning方針。

## モジュール境界

### 1. Core principles

Coreは、技術が変わっても維持する判断法です。

- アクター、目的、文脈、ルールを確認する。
- 手段を目的化しない。
- 品質特性を明示する。
- 確認済み事実、推論、仮定、未決事項を分ける。
- ドメインモデル完全性、契約、公開境界を検証する。
- AIの説明ではなく、コード、テスト、根拠で判定する。

Coreへ特定言語の構文、framework annotation、CLI commandを混ぜません。

### 2. Task functions

一つのFunctionは、一つの主要成果物と完了条件を持ちます。

| Function | 主成果物 |
|---|---|
| context verbalization | Context Packet |
| problem definition | Problem Definition |
| debt analysis | Debt Report |
| domain model audit | Completeness Report |
| contract design | Contract Table |
| boundary design | Interface / Implementation Map |
| redesign proposal | Target Design |
| test generation | Contract Test Suite |
| implementation | Verified Change |
| review | Findings and Decision |

「分析し、設計し、実装し、レビューして」のような広い依頼は、統合Skillが複数Functionを順にroutingします。

### 3. Design viewpoints

Viewpointは、対象成果物を評価するレンズです。

- 目的・目標・手段
- 品質特性と変更容易性
- カプセル化
- 関心の分離
- 単一責任
- interface設計
- ドメインモデル完全性
- 契約による設計
- DDD
- 技術レイヤの分離

Viewpointは「常にすべて読む」のではなく、症状とタスクに応じて選択します。

### 4. Architecture / framework adapters

Adapterは、CoreやViewpointを特定技術へ翻訳します。

```text
Core: 業務ルールをframework境界へ漏らさない
Spring Boot adapter: Controller / Application / Domain / Repositoryの配置とannotation制約
Laravel adapter: Controller / Service / Model / Policy / Jobの責務差分
React adapter: domain state、server state、view state、side effectの境界
```

AdapterがCoreの意味を上書きしないようにします。技術慣例が対象要件と競合する場合、要件とCoreを優先し、例外を明記します。

### 5. Language adapters

Language adapterは、同じ設計を構文とtoolchainへ落とします。

- Value Objectの表現方法。
- interface / protocol / traitの使い分け。
- error、exception、result型の契約。
- unit、integration、property testのtooling。
- formatter、linter、static analysis、build command。

言語adapterに業務ルールやアーキテクチャ判断を複製しません。

### 6. Presentation layer

同じ分析内容でも、利用先に応じて出力を変えます。

- 人間レビュー用Markdown。
- 後続Skill用YAML / JSON。
- Mermaidのclass / dependency diagram。
- PR review comment。
- 実装計画書。

見た目を整える層が、分析結果や重大度を変更してはいけません。

### 7. Evaluation

Skillの品質は、promptの長さや説明の豊富さではなく、同じ要件を繰り返し満たせるかで評価します。

- 要件coverage。
- 契約coverage。
- model / interface leakage。
- 不正状態の生成可否。
- false positiveと過剰抽象化。
- 代表変更の局所性。
- 複数実行間の要件適合率。
- 過去versionからの回帰。

## 判断規則

### 1. 変更理由が異なる知識を同じモジュールへ置かない

- 設計原則の更新で変わる → Core / Viewpoint。
- タスク手順の更新で変わる → Function。
- framework versionで変わる → Framework adapter。
- 言語versionやtoolingで変わる → Language adapter。
- 出力先で変わる → Presentation。

変更理由が異なるものを分離すると、影響範囲とレビューownerを限定できます。

### 2. Coreは小さく、強く、技術非依存にする

Coreへすべての具体例やframework規則を入れません。すべてのFunctionが守るhard gate、証拠方針、判断順序に絞ります。

### 3. Functionは成果物契約で分割する

ファイル数やprompt長ではなく、利用者が求める成果物と完了判定が独立しているかで分けます。一つのFunctionに主成果物を一つ置きます。

### 4. Viewpointは加算可能にする

複数Viewpointを組み合わせても矛盾しないよう、次を明示します。

- 適用条件。
- 非適用条件。
- 優先する品質特性。
- 他Viewpointとの競合時の扱い。
- hard gateか、改善候補か。

### 5. Routingで必要な資料だけ読む

```text
巨大Service + 業務分岐混在
  → purpose / separation / interface viewpoint

値制約と禁止状態の不具合
  → invariant / contract / completeness viewpoint

Spring Bootの層配置レビュー
  → core + relevant viewpoint + Spring Boot adapter + Java adapter
```

全referenceを毎回読み込む設計は、文脈を膨らませ、重要規則を埋没させます。

### 6. Adapterは翻訳し、再定義しない

AdapterがCoreや契約を独自解釈すると、言語ごとに品質基準が変わります。新しい技術へ対応するときは、まず共通概念との対応表を作ります。

### 7. 共通hard gateを一箇所で管理する

次のような禁止条件は、各Functionへコピーせず共通referenceから参照します。

- 根拠のない業務要件を追加する。
- 重要な不変条件のownerが不明。
- 公開契約を未承認で変更する。
- interfaceへ技術詳細を漏らす。
- 失敗時の状態を検証しない。
- 重要なunknownを隠して完了宣言する。

### 8. Personaではなくoperational ruleを保存する

「ミノ駆動氏として考える」ではなく、次を保存します。

- どの入力を確認するか。
- どの順番で判断するか。
- どの条件なら拒否するか。
- 何を成果物として返すか。
- 何がtrueなら完了か。

人物への帰属は出典情報であり、最終判断は対象システムの事実で行います。

### 9. 更新にはbenchmarkとversion記録を伴わせる

Core、Function、Viewpoint、Adapterの変更ごとに、影響するbenchmarkを実行します。改善例だけでなく、過剰抽象化や誤検知を防ぐnegative caseも含めます。

## 実行手順

### Phase 1: Knowledge inventory

1. 既存prompt、Skill、agent、資料、レビュー観点を一覧化する。
2. 各知識について、目的、利用者、入力、成果物、変更理由、根拠を記録する。
3. 重複、矛盾、出典不明、適用条件不明の知識を特定する。

### Phase 2: Taxonomy

4. 各知識をCore、Function、Viewpoint、Framework adapter、Language adapter、Presentation、Evaluationへ分類する。
5. 一つの項目が複数層にまたがる場合、共通意味と技術差分へ分解する。
6. 削除候補、統合候補、独立Skill候補を決める。

### Phase 3: Contracts

7. 各Functionに起動条件、非対象、必要入力、主成果物、hard gate、完了条件を定義する。
8. 各Viewpointに診断質問、違反状態、改善方向、誤検知条件を定義する。
9. 各Adapterに対応version、適用範囲、Coreとの対応表、validation commandを定義する。
10. 共通Evidence policyと権限境界を定義する。

### Phase 4: Routing

11. 症状、タスク、言語、frameworkから必要モジュールを選ぶrouting tableを作る。
12. 必ず読むCoreと、必要時だけ読むreferenceを分ける。
13. 統合workflowの依存順と停止条件を決める。

### Phase 5: Packaging

14. 実行環境のSkill配置へ変換する。
15. `SKILL.md`はoutcome、routing、workflow、hard gateへ絞る。
16. 詳細原則は`references`、再利用処理は`scripts`、テンプレートは`assets`へ分ける。
17. 表示名、短い説明、default promptをagent metadataへ置く。
18. Codex版とClaude Code版は、自動同期を前提にせず環境差分を明示する。

### Phase 6: Evaluation

19. 代表タスク、境界値、negative caseをbenchmark suiteへ登録する。
20. 複数回実行し、要件適合率、false positive、構造の揺らぎを測る。
21. 失敗をCore、Function、Viewpoint、Adapter、routingのどこに原因があるか分類する。
22. 修正後、影響範囲の回帰試験を行う。

### Phase 7: Rollout

23. 小規模な利用者群で試行する。
24. 利用ログ、失敗例、質問、手動修正箇所を収集する。
25. owner、version、廃止条件、互換性を記録する。
26. 人間の設計学習と併用し、AI出力を評価できる能力を維持する。

## 単一Skill package内の論理resource構成例

次のtreeは、Core、Function、Viewpoint、Adapter、asset、scriptを一つのSkill package内でどう分けるかを示す参考例です。現在のCodex runtimeに推奨する公開Skillのdirectory treeではありません。

```text
.agents/skills/mino-driven-development/
├── SKILL.md
├── agents/
│   └── openai.yaml
├── references/
│   ├── core/
│   │   ├── purpose-and-quality.md
│   │   ├── evidence-policy.md
│   │   └── hard-gates.md
│   ├── functions/
│   │   ├── context-verbalization.md
│   │   ├── problem-definition.md
│   │   ├── debt-analysis.md
│   │   ├── design-proposal.md
│   │   └── contract-testing.md
│   ├── viewpoints/
│   │   ├── encapsulation.md
│   │   ├── separation-of-concerns.md
│   │   ├── domain-model-completeness.md
│   │   ├── design-by-contract.md
│   │   └── interface-design.md
│   ├── frameworks/
│   │   └── <framework>.md
│   └── languages/
│       └── <language>.md
├── assets/
│   ├── context-packet.md
│   ├── debt-report.md
│   └── target-design.md
└── scripts/
    └── validate_skill.py
```

大きなsuiteを一つのSkillとして配るか、複数の独立Skillへ分けるかは実行環境のrouting能力と利用頻度で決めます。独立Skillにする場合も、CoreとEvaluationのsource of truthを明示します。

このrepositoryのCodex runtimeでは、主成果物ごとの公開Function、暗黙発火しない共通Core、複数成果物だけを扱うrouterへ分ける方式を採用しています。現在のruntime構成と見直し条件は[資料集README](README.md#資料テーマの論理構成と推奨runtime-skill構成)を参照します。

## 出力契約

```yaml
skill_architecture:
  suite: string
  goals: []
  modules:
    core:
      - id: string
        responsibility: string
        source_of_truth: string
    functions:
      - id: string
        trigger: string
        primary_artifact: string
        completion_gate: []
    viewpoints:
      - id: string
        applies_when: []
        does_not_apply_when: []
        hard_gates: []
    framework_adapters:
      - id: string
        versions: []
        translates: []
    language_adapters:
      - id: string
        versions: []
        validation_commands: []
    presentation:
      - id: string
        audience: string
        format: string
  routing:
    - condition: string
      load: []
      order: []
      stop_conditions: []
  shared_policies:
    evidence: string
    authority: string
    safety: string
  evaluation:
    benchmarks: []
    negative_cases: []
    metrics: []
  ownership:
    owners: []
    version: string
    deprecation_policy: string
```

## 完了条件

- [ ] Coreが技術非依存の判断規則と共通hard gateへ絞られている。
- [ ] 各Functionに一つの主成果物と二値判定可能な完了条件がある。
- [ ] Viewpointに適用条件、非適用条件、誤検知条件がある。
- [ ] Framework / Language adapterがCoreを再定義せず翻訳している。
- [ ] Presentation layerが分析結果を変更しない。
- [ ] 必要なreferenceだけを読むroutingが定義されている。
- [ ] Evidence policy、権限、停止条件がsuite全体で一貫している。
- [ ] 代表taskとnegative caseによるbenchmarkがある。
- [ ] version、owner、廃止方針、互換性が記録されている。
- [ ] Persona模倣ではなく、判断規則と成果物契約が保存されている。
- [ ] 人間がAI出力を評価する学習・レビュー工程が残されている。

## 失敗パターン

- すべての知識を一つの巨大な`SKILL.md`へ入れる。
- 同じCore原則を言語・frameworkごとにコピーする。
- 一つのFunctionが分析、設計、実装、レビューを無条件に全部行う。
- すべてのViewpointを毎回読み、文脈とトークンを浪費する。
- Adapterが業務ルールや品質基準を独自に変更する。
- 出力formatの品質を、設計判断の品質と混同する。
- 新しい成功例だけでSkillを更新し、negative caseと回帰を確認しない。
- 有識者の口調や断定の強さを再現し、根拠と不確実性を失う。
- Skillを配るだけで、人間の設計力と検証力の育成を止める。
- owner不在のまま多数のmoduleを増やし、重複と陳腐化を放置する。

## エージェント向けプロンプト骨子

```text
この設計知識群を、拡張可能なSkill suiteへ再構成してください。

1. 知識をCore principles、Task functions、Design viewpoints、Framework adapters、Language adapters、Presentation、Evaluationへ分類する。
2. Coreは技術非依存の判断規則、Evidence policy、共通hard gateへ絞る。
3. 各Functionに起動条件、非対象、必要入力、一つの主成果物、完了条件を定義する。
4. Viewpointに適用条件、非適用条件、診断質問、誤検知条件を付ける。
5. AdapterはCoreを再定義せず、特定技術への翻訳だけを行う。
6. 症状とtaskから必要referenceだけを読むroutingを設計する。
7. 代表task、negative case、複数回実行による回帰試験を用意する。
8. Personaではなく、反証可能な判断規則、成果物契約、拒否条件を保存する。
```

## 他スキルとの接続

- 共通Coreの候補: `01-purpose-goal-means.md`、`02-quality-attributes-and-modifiability.md`
- Context Function: `16-ai-context-verbalization.md`
- Problem Definition Function: `17-premise-checking-and-problem-definition.md`
- 人間の検証力を育てる: `18-design-learning-workshop.md`
- 契約・境界・完全性の個別Skill: `20-design-by-contract.md`、`21-interface-implementation-separation.md`、`22-domain-model-completeness.md`
- 統合workflow: `23-reproducible-ai-development.md`
- 既存資料の監査と変換方針: `24-audit-and-skill-conversion.md`

## 出典と操作的解釈

- https://speakerdeck.com/minodriven/modifius
- https://speakerdeck.com/minodriven/effective-learning-of-good-code
- https://speakerdeck.com/minodriven/ai-refactoring-approach
- https://speakerdeck.com/minodriven/ai-good-code-bad-code

公開資料では、モディフィウスの実態が変更容易性に関するプロンプト群であり、コアプロンプト、支援機能、DDDやframeworkの設計観点、対応言語を分け、柔軟に拡張できるようモジュール化していることが示されています。本書のPresentation、Evaluation、routing、versioning、owner、negative benchmarkは、その構造をCodex / Claude CodeなどのSkill運用へ移すための操作的な再構成です。

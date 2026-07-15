# 既存資料の充足度監査とSkill変換方針

## この文書の役割

この文書は、`mino-doc`全体の責務、欠落、重複、Skill分割を監査します。

二つの監査結果を統合しています。

1. **中核三概念の監査**
   - 契約による設計
   - インターフェイスと実装の分離
   - ドメインモデル完全性
2. **2026年上期の公開発言を反映した再監査**
   - 問題定義と妥当性検証
   - 技術の引力と具体・抽象
   - 文脈、言語ゲーム、スキーマ
   - 品質特性の戦略的全体最適
   - 人間とAIの主導権切替
   - 基本こそ奥義、AIは増幅器

最近のキーワード監査の詳細は`25-recent-keyword-importance-audit.md`を参照します。

## 総合結論

`01`〜`24`には、ミノ駆動氏の公開ノウハウをSkill化するための主要な判断規則が概ね揃っています。特に次は、独立した入力、手順、成果物、完了条件まで資料化されています。

- 目的・目標・手段、事業価値、品質特性。
- 文脈、言語、境界、ドメインモデリング。
- 不変条件、契約、モデル完全性。
- interface partとimplementation part。
- レガシー改善とAI支援リファクタリング。
- 前提点検、問題定義、Context Packet。
- 人間の設計学習とSkillのモジュール展開。
- 複数生成結果を同じ要件gateで判定するworkflow。

ただし、2026年上期の公開資料を中心に再監査すると、次の二つが断片的で、独立してrouting可能な判断workflowとしての資料化が不足していました。これはruntimeで必ず一つずつ公開Skill directoryにするという意味ではありません。

1. **技術の引力を検出し、具体と抽象を往復する運用手順**
2. **プロダクト価値から品質特性を戦略的・全体的に最適化するアーキテクチャworkflow**

この不足を`26`と`27`で補います。

## 監査1: 中核三概念

### 契約による設計

初期資料には、不変条件を中心にしたドメインモデリングと、AIによる契約ベースのテスト生成が含まれていました。

不足していた点:

- 事前条件、事後条件、不変条件の所有者。
- 失敗後の状態。
- API、Use Case、Aggregateなど複数レベルの契約。
- 要件とのtraceability。
- 境界値、禁止遷移、冪等性、部分失敗の拒否条件。

対応:

- `20-design-by-contract.md`
- `23-reproducible-ai-development.md`

### インターフェイスと実装の分離

初期資料は、言語機能としてのinterface、条件分岐削減、目的別実装を扱っていました。

不足していた点:

- interface partとimplementation partの明確な定義。
- 利用者と目的から公開契約を設計する手順。
- 技術詳細の漏出判定。
- 実装交換、種類追加、代表変更シナリオによる検証。

対応:

- `21-interface-implementation-separation.md`
- `11-interface-driven-branch-reduction.md`

### ドメインモデル完全性

初期資料には、不変条件、データ破壊駆動、目的中心のカプセル化が含まれていました。

不足していた点:

- 必要概念のinventory。
- 状態、遷移、失敗の欠落。
- 全writer、reader、authorityの確認。
- モデル外へ漏れた業務ルール。
- scopeに対する完全性と、現実全体の完全性の区別。

対応:

- `22-domain-model-completeness.md`
- `08-invariant-first-domain-modeling.md`
- `09-data-destruction-driven-analysis.md`

### 三概念の統合

単独の原則だけでは、何度生成しても要件を満たすworkflowになりません。

必要な接続:

```text
要件
→ モデル完全性
→ 契約
→ interface part / implementation part
→ 実装
→ 契約・完全性・境界の独立検証
```

対応:

- `23-reproducible-ai-development.md`

## 監査2: 2026年上期の公開発言

対象期間、資料、重要度の判定方法は`25`に記録しています。

### 十分だったテーマ

| テーマ | 対応資料 | 監査結果 |
|---|---|---|
| 問題定義、問い、前提、妥当性検証 | `17`, `23` | 十分。統合workflowの入口と受入gateを強化 |
| 文脈、意味解釈、言語ゲーム、スキーマ | `06`, `16`, `17` | 十分。重複を増やさずroutingする |
| 目的・目標・手段 | `01`, `03`, `04` | 十分。具体・抽象の往復を追加 |
| 変更容易性、負債、理想構造 | `02`, `04`, `14`, `15` | 十分 |
| AIは増幅器、基本こそ奥義 | `18`, `19`, `23` | 十分。人間の学習と受入責任をhard gate化 |
| 人間pilot / AI copilotの切替 | `17`, `23` | 十分。役割表を`23`へ追加 |

### 不足1: 技術の引力と具体・抽象

既存資料にあった断片:

- `01`: 目的・目標・手段。
- `13`: 目的に基づく抽象化。
- `17`: 手段を問題にしない。

独立Functionとして不足していたもの:

- 技術語・実装案への早期固定を検出する入力規則。
- `つまり`による実装から目的への遡行。
- `たとえば`による目的から契約・実装・テストへの具体化。
- 抽象化の停止条件。
- 上位目的の根拠状態。
- 目的から実装・テストまでのtraceability。

対応:

- `26-technical-gravity-and-abstraction-navigation.md`
- `01-purpose-goal-means.md`をブラッシュアップ。

### 不足2: アーキテクチャ品質戦略

既存資料にあった断片:

- `02`: 品質シナリオとtrade-off。
- `03`: 事業価値とコアドメイン。
- `05`: 目的に基づく境界。
- `21`: 公開境界と内部実装。

独立Functionとして不足していたもの:

- プロダクト価値と品質portfolioの接続。
- 局所効果とsystem / journey / organizationへの影響の区別。
- 意図的に最適化しない品質の明示。
- Architecture Decision Record、owner、reversibility、再評価trigger。
- targetだけでなくtransition architecture、rollback、old path削除。
- 代表品質シナリオによる全体検証。

対応:

- `27-architecture-quality-strategy.md`
- `02-quality-attributes-and-modifiability.md`をブラッシュアップ。

## 推奨する論理module構成

一つの巨大Skillへ詰め込まず、知識を共通Core、Task Function、Viewpoint、技術Adapter、統合workflowへ論理的に分けます。次のtreeは資料のcoverageと変更理由を監査するtaxonomyであり、runtimeのdirectory treeや公開Skillとの一対一対応を意味しません。

```text
design-core（論理group）
├── premise-and-problem-definition          # 17
├── technical-gravity-navigation            # 26
├── context-verbalization                   # 16
├── purpose-goal-means                      # 01
├── quality-attributes                      # 02
└── evidence-policy                         # README / shared reference

product-and-architecture（論理group）
├── business-value-and-core-domain          # 03
├── debt-goal-and-priority                  # 04
├── architecture-quality-strategy           # 27
└── bounded-context-discovery               # 05

domain-design（論理group）
├── ubiquitous-language                     # 06
├── invisible-driven-modeling               # 07
├── invariant-modeling                      # 08
├── data-destruction-analysis               # 09
└── domain-model-completeness               # 22

contract-and-boundary（論理group）
├── design-by-contract                      # 20
├── interface-implementation-separation      # 21
├── purpose-centered-encapsulation          # 10
└── interface-branch-reduction              # 11

code-design（論理group）
├── purpose-driven-naming                   # 12
├── purpose-driven-abstraction              # 13
├── legacy-purpose-split                    # 14
└── ai-assisted-refactoring                 # 15

reproducible-development（論理group）
└── integrated-workflow                     # 23

learning-and-scaling（論理group）
├── design-learning-workshop                # 18
├── skill-modularization                    # 19
├── recent-keyword-audit                    # 25
└── audit-and-skill-conversion              # 24
```

Codex runtimeでは、この論理groupをそのまま公開Skillにしません。現行`.agents/skills/`は、暗黙発火しない共通Core、Problem Framingの公開入口、主成果物別のArchitecture / Completeness / Contract / Boundary Function、複数成果物だけを扱う統合routerへ分けています。これにより、Contract PackageとBoundary Packageのように単独で求められる成果物を分離し、Viewpointは必要なFunctionからreferenceとして読みます。現在のruntime構成、論理groupからの配置、見直し条件は[資料集README](README.md#資料テーマの論理構成と推奨runtime-skill構成)を正とします。

## 推奨routing

### 要件が曖昧、または技術案だけが提示された

```text
17 problem definition
→ 26 technical gravity / abstraction navigation
→ 16 Context Packet
→ 01 purpose / goal / means
```

### 新規ドメイン機能を設計する

```text
17 → 26 → 16 → 01 → 02
→ 05〜09 → 22 → 20 → 21
→ 10〜13 → 23
```

### アーキテクチャ、複数module、データ所有、移行を設計する

```text
03 → 26 → 02 → 27
→ 05 → 21 → 20 / 22
→ 23
```

### レガシーを改善する

```text
17 → 26 → 04
→ 08 / 20
→ 14 / 15
→ 21 / 22 / 23
```

### 人間とSkillを育成する

```text
18 design learning
→ 19 knowledge modularization
→ 25 recent-signal audit
→ 24 coverage audit
→ 23 benchmark
```

## 共通Evidence policy

各Skillで次を統一します。

- `confirmed`: 仕様、コード、テスト、schema、担当者確認など根拠あり。
- `inferred`: 複数の根拠から推定したが明示なし。
- `assumption`: 作業継続のため置く一時仮定。
- `unknown`: 結果を分岐させる不足。
- `contradiction`: 根拠同士が競合。

AIの一般知識を、そのシステムの業務要件として扱いません。

## 共通Hard gates

次のいずれかがある場合、実装またはSkill作成の完了を宣言しません。

- 対象アクター、問題、目的、成功条件が不明。
- 技術語を除くと問題を説明できない。
- 重要語の文脈上の意味が確定していない。
- 重要な前提に根拠または反証条件がない。
- Context Packetの復唱が一致しない。
- 要件IDに対応するモデル要素または契約がない。
- 契約所有者または状態変更authorityが複数・不明。
- 不正状態を公開経路から生成できる。
- 状態遷移の禁止条件がテストされていない。
- 業務ルールがController、adapter、UIへ漏れている。
- interface partが技術実装を露出している。
- 失敗時の状態保証がない。
- 重要概念の意味がprimitiveに潰れている。
- 代表変更が複数の無関係moduleへ波及する。
- primary品質シナリオを満たさない、またはconstraint品質を破る。
- 不可逆な変更にowner、migration、recovery、承認がない。
- 重要な`unknown`または`contradiction`を隠している。
- 人間が問題、価値、trade-off、受入を所有していない。

## Skill評価方法

Skill自体の品質は、説明量ではなく再現試験で評価します。

### Benchmark tasks

- 数量・金額制約を持つ注文モデル。
- 許可・禁止遷移を持つ予約モデル。
- 複数方式を交換する決済・配送戦略。
- DB・外部APIが混在する長大ユースケース。
- 部分失敗・再試行・冪等性を持つ処理。
- 技術案だけが提示された曖昧な機能要求。
- 複数module、データ移行、品質trade-offを伴うアーキテクチャ変更。

### 評価軸

- problem-definition accuracy。
- context interpretation accuracy。
- requirement coverage。
- contract coverage。
- invalid-state constructibility。
- model / interface leakage。
- quality-scenario pass rate。
- change impact and locality。
- false positive / unnecessary abstraction。
- migration and recovery completeness。
- human acceptance consistency。
- 複数実行間の要件適合率。

### 合格の考え方

同一コードにならなくても、全実行で次が成立すれば再現性があると判定します。

- 承認済みの問題を解く。
- 契約テストが通る。
- モデル完全性の欠落がない。
- 公開境界が目的と意味を維持する。
- primary品質シナリオを満たす。
- 禁止構造が入らない。
- 代表変更が局所化される。
- 人間の妥当性・受入gateを通る。

## 注意事項

- ミノ駆動氏本人の内部プロンプト、「バグサーチャー」「モディフィウス」の全実装は公開資料だけでは再現できません。
- 「ドメインモデル完全性」の厳密な内部定義も、公開スライドのみでは確定できません。
- 最近の重要度はSpeaker Deck公開資料の中心性・反復から推定しており、SNSや非公開発言の全量統計ではありません。
- 本資料は人物の口調や人格を再現せず、公開された判断法をSkill用の操作手順へ統合したものです。
- 人物名を権威として結論を固定せず、対象システムの要件、コード、テスト、品質特性、利用結果で検証します。

## 最終結論

中核三概念は、引き続きAI開発の要件再現性を支える重要なgateです。

2026年上期の公開発言を加味すると、その前段と上位判断として次もCoreへ含める必要があります。

- 問題を正しく定義する。
- 技術の引力を点検し、具体と抽象を往復する。
- 文脈と意味を共有する。
- 品質特性をプロダクト価値から全体最適する。
- 問題定義と受入は人間、解決候補の生成はAIを主役にする。
- AIを使うほど、人間の設計、言語化、レビューの基本を育成する。

`01`〜`27`により、問題定義からSkill展開・再監査までの知識は、実行可能な資料として概ね十分な状態になりました。`.agents/skills/`への初期変換も完了しています。次段階は、現行の成果物単位routingを複数fresh-context runとnegative caseで検証し、実案件で成果物不足または過剰routingが反復した場合だけpackage境界を見直すことです。

## 出典

- https://speakerdeck.com/minodriven/tech-gravity
- https://speakerdeck.com/minodriven/doubt-premise
- https://speakerdeck.com/minodriven/ai-philosophy-cognitive-science
- https://speakerdeck.com/minodriven/ai-refactoring-approach
- https://speakerdeck.com/minodriven/ddd-in-ai-era
- https://speakerdeck.com/minodriven/ai-good-code-bad-code
- https://speakerdeck.com/minodriven/ai-and-software-quality
- https://speakerdeck.com/minodriven/purpose-driven-architecture
- https://speakerdeck.com/minodriven/modifius

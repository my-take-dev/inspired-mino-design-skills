# ミノ駆動氏の設計ノウハウをSkill化するための資料集

このディレクトリは、ミノ駆動氏の登壇資料、インタビュー、技術記事から、開発に再利用できる設計原則、判断基準、実行手順を抽出し、Codex / Claude CodeなどのSkillへ変換できる粒度で整理した調査資料です。

単なる資料要約や人物模倣を目的としません。公開資料に明示された主張と、Skillとして反復可能にするために追加した操作的な解釈を区別し、入力、判断規則、手順、出力契約、完了条件、失敗パターンとして記述します。

調査基準日は**2026-07-10**です。出典の更新、新しい資料、実運用で得られた反例に応じて見直してください。

## 再監査の結論

`01`〜`24`には、ミノ駆動氏の公開ノウハウをSkill化する主要要素が概ね揃っていました。

特に、次は独立した成果物と検証gateまで資料化されています。

- 問題定義と前提点検。
- アクター、目的、文脈、ルールの言語化。
- 目的・目標・手段と品質特性。
- ドメイン境界、言語、モデル、不変条件。
- 契約による設計。
- インターフェイスと実装の分離。
- ドメインモデル完全性。
- AI支援リファクタリングと反復可能なAI開発。
- 人間の設計学習とSkillのモジュール展開。

2026-01-10から2026-07-10までのSpeaker Deck公開資料を再監査した結果、次の二つは既存資料に断片はあるものの、独立してrouting可能な判断workflowとしての資料化が不足していました。ここでいう独立性は、runtimeで必ず一つのSkill directoryにするという意味ではありません。

1. **技術の引力を点検し、具体と抽象を往復するworkflow**
2. **プロダクト価値から品質特性を戦略的・全体的に最適化するアーキテクチャworkflow**

この不足を`26`と`27`で補っています。調査対象、重要度の推定方法、既存資料との対応は`25-recent-keyword-importance-audit.md`に記録しています。

### Codex runtime構成の再検討（2026-07-12）

このREADMEに記載していた構成と、実際の`.agents/skills/`を、主成果物、trigger、routing、progressive disclosure、保守責務の観点で再比較しました。

結論として、Codex runtimeでは現行の`.agents/skills/`を維持します。従来の構成図は、資料テーマを分類する**論理構成**としては有効ですが、その各groupを一つの公開Skillにすると、契約設計、境界設計、モデル監査、学習、suite保守など異なる成果物とtriggerが同居します。現行構成は、共通規則を暗黙発火しない`mino-core`へ集約し、利用者が求める主成果物ごとに公開Functionを分け、複数成果物が必要な場合だけrouterで統合するため、Codexの選択単位として扱いやすい構成です。

この判断は、現行packageと[0.5.0のtargeted evaluation](../.agents/skills/mino-core/evaluations/0.5.0.md)に基づきます。単一のProblem Framing依頼で専門Functionや統合routerを過剰起動しない挙動は確認済みですが、全代表case・negative caseを最低3 fresh-context runするbehavioral releaseは未達です。したがって、現行構成を「実運用で完全に実証済み」とは扱わず、利用実績と回帰結果に応じて再評価します。

## 直近6か月で重要度が高いキーワード

公開資料におけるタイトル・結論での中心性、複数資料での反復、因果説明、Skill化可能性から、次を重視します。

### S: 共通Coreまたはhard gate

- 問題定義、問い、前提、妥当性検証。
- 目的、価値、目的・目標・手段。
- 文脈、意味解釈、アクター、ルール、言語ゲーム、スキーマ。
- 変更容易性、技術的負債、理想構造。
- 契約による設計、インターフェイスと実装の分離、ドメインモデル完全性。
- 基本こそ奥義、AIは増幅器。

### A: 独立Functionまたは重要Viewpoint

- 技術の引力、具体と抽象、`つまり`と`たとえば`。
- アーキテクト、品質特性、戦略的全体最適。
- 人間pilot / AI copilotと、AI pilot / 人間copilotの切替。
- ユビキタス言語、境界付けられたコンテキスト、ドメインモデル。

ここでいう頻出は、SNSを含む全投稿の厳密な単語頻度ではなく、確認可能な公開登壇資料での中心性と反復です。

## 中核となる設計・開発工程

```text
観測事実と前提を点検し、解くべき問題を定義する          # 17
  ↓
技術の引力を点検し、具体から目的へ遡る                   # 26
  ↓
目的から目標・契約・実装・テストへ具体化する             # 26, 01
  ↓
アクター・目的・文脈・ルール・変更境界を言語化する       # 16
  ↓
目的を観測可能な目標・品質特性へ変換する                 # 01, 02
  ↓
プロダクト価値から品質特性を全体最適する                 # 03, 27
  ↓
必要な業務概念・状態・制約を欠落なくモデル化する         # 05〜09, 22
  ↓
事前条件・事後条件・不変条件として契約を定義する         # 20
  ↓
利用者に見せるインターフェイスと内部実装を分離する       # 21
  ↓
目的に沿って命名・抽象化・責務分割する                   # 10〜13
  ↓
approvedまたはfrozenな問題・契約・品質・境界内でAIに実装させる # 23
  ↓
契約テスト、完全性、品質シナリオ、変更シナリオを検証する # 23
  ↓
人間が問題改善・価値・trade-off・出荷可否を判定する      # 17, 23
  ↓
実コードで人間の設計力を育て、Skillを更新・展開する      # 18, 19, 24, 25
```

## AI開発の再現性

特に、AIが何度実行されても要件を満たすコードを再現するため、次の三概念を重要な統合gateとして扱います。

- **契約による設計**: 自然言語の要件を、事前条件、事後条件、不変条件、失敗後状態へ変換する。
- **インターフェイスと実装の分離**: 安定させる目的、操作、意味、契約と、変更可能な技術、アルゴリズム、手順を分ける。
- **ドメインモデル完全性**: 対象ユースケースの正しい判断に必要な業務概念、状態、制約、遷移、振る舞い、失敗をモデル内に欠落させない。

ただし三概念だけを機械的に適用しても不十分です。その前に正しい問題、文脈、目的、品質戦略を確定し、その後に独立検証と人間の妥当性判断を行います。

ここでいう再現性は、毎回同じコードを生成することではありません。実装詳細が異なっても、毎回同じ問題を解き、同じ目的、契約、モデル整合性、品質制約、公開境界を満たすコードを生成・判定できることです。

## 文書一覧

### 1. 目的・品質・事業価値

| No. | 文書 | 内容 |
|---:|---|---|
| 01 | [目的・目標・手段を分離する](01-purpose-goal-means.md) | 手段を目的化せず、具体と抽象を往復し、目的から実装・テストまでtraceする |
| 02 | [品質特性と変更容易性を明示する](02-quality-attributes-and-modifiability.md) | 「良いコード」を品質シナリオへ変え、局所効果と全体効果を分ける |
| 03 | [事業価値とコアドメイン](03-business-value-and-core-domain.md) | 利益、競争優位性、コアドメインから設計投資先を判断する |
| 04 | [技術的負債の目標と優先順位](04-technical-debt-goal-and-prioritization.md) | あるべき姿との差、変更頻度、機会損失、障害リスクから改善順を決める |

### 2. ドメイン境界・言語・モデル

| No. | 文書 | 内容 |
|---:|---|---|
| 05 | [目的に基づく境界付けられたコンテキスト](05-purpose-based-bounded-contexts.md) | アクターと目的の違いからモデル、言語、責務の境界を発見する |
| 06 | [ユビキタス言語と文脈](06-ubiquitous-language-and-context.md) | 同じ語の意味とルールを文脈ごとに明確化する |
| 07 | [見えないものを起点にしたモデリング](07-invisible-driven-modeling.md) | 物理名詞だけでなく目的、状況、問題、制約をモデル化する |
| 08 | [不変条件を中心にしたドメインモデリング](08-invariant-first-domain-modeling.md) | 事前条件、事後条件、不変条件をモデル設計の中心へ置く |
| 09 | [データ破壊駆動分析](09-data-destruction-driven-analysis.md) | データを壊す思考実験から異常系、禁止状態、制約を発見する |

### 3. コード設計・抽象化

| No. | 文書 | 内容 |
|---:|---|---|
| 10 | [目的中心のカプセル化](10-purpose-centered-encapsulation.md) | 目的単位でデータ、振る舞い、制約を同じ責務へ集約する |
| 11 | [interfaceによる分岐削減](11-interface-driven-branch-reduction.md) | 条件分岐を目的別の実装へ移し、利用側から差異を隠す |
| 12 | [目的駆動の命名](12-purpose-driven-naming.md) | 名前から目的、役割、境界、対象外を理解できるようにする |
| 13 | [目的駆動の抽象化](13-purpose-driven-abstraction.md) | 表面的なコード類似ではなく、目的と概念の共通性から抽象化する |

### 4. レガシー改善・AI支援

| No. | 文書 | 内容 |
|---:|---|---|
| 14 | [目的単位のレガシーリファクタリング](14-legacy-refactoring-by-purpose.md) | 巨大クラスを目的ごとにコピーして削る方法や段階置換で分割する |
| 15 | [AI支援リファクタリング](15-ai-assisted-refactoring.md) | 人間、AI、IDEの役割を分け、テストで安全に改善する |

### 5. AI文脈・問題定義・学習・展開

| No. | 文書 | 内容 |
|---:|---|---|
| 16 | [AIへ目的・文脈・ルールを言語化する](16-ai-context-verbalization.md) | アクター、目的、文脈、ルール、品質、変更境界をContext Packetとして共有する |
| 17 | [前提を点検し、解くべき問題を定義する](17-premise-checking-and-problem-definition.md) | 観測、解釈、前提、仮説、問題、解決策を分け、問題定義を正確にする |
| 18 | [プロダクションコードで設計力を育てる](18-design-learning-workshop.md) | 問題発見、言語化、ゼロからの再設計、説明を行う8段階ワークショップを運営する |
| 19 | [設計知識をモジュール化しSkillとしてスケールする](19-skill-modularization-and-scaling.md) | Core、Function、Viewpoint、技術Adapter、Presentation、Evaluationへ分割する |

### 6. 要件再現性を支える統合原則

| No. | 文書 | 内容 |
|---:|---|---|
| 20 | [契約による設計](20-design-by-contract.md) | 要件を契約表、所有者、失敗状態、契約テストへ変換する |
| 21 | [インターフェイスと実装の分離](21-interface-implementation-separation.md) | interface型に限定せず、公開する意味と内部の実現方法を分離する |
| 22 | [ドメインモデル完全性](22-domain-model-completeness.md) | 対象ユースケースに必要な概念、制約、状態、振る舞いの欠落を監査する |
| 23 | [再現可能なAI開発](23-reproducible-ai-development.md) | 問題定義から人間の受入判定まで、生成・拒否・独立検証工程を統合する |
| 24 | [既存資料監査とSkill変換](24-audit-and-skill-conversion.md) | 中核三概念と最近の公開発言から、充足度、routing、hard gateを監査する |

### 7. 最近の発言から追加した重要Function

| No. | 文書 | 内容 |
|---:|---|---|
| 25 | [直近6か月のキーワード重要度監査](25-recent-keyword-importance-audit.md) | 最近の公開資料を中心性・反復性・因果性・Skill化可能性で評価する |
| 26 | [技術の引力と具体・抽象の往復](26-technical-gravity-and-abstraction-navigation.md) | 技術への早期固定を検出し、`つまり`と`たとえば`で目的と実装を往復する |
| 27 | [アーキテクチャ品質戦略](27-architecture-quality-strategy.md) | プロダクト価値、品質portfolio、全体trade-off、targetとtransitionを統合する |

## 読む順序

### 新規機能・ドメイン設計

1. `17`で観測、解釈、前提、問題、解決策を分ける。
2. `26`で技術の引力を点検し、具体と抽象を往復する。
3. `16`でアクター、目的、文脈、ルール、変更境界をContext Packetにする。
4. `01`で目的、目標、手段をtraceする。
5. `02`で優先する品質特性を定義する。
6. `05`〜`09`で文脈、言語、モデル、制約を整理する。
7. `22`でモデル完全性を監査する。
8. `20`で契約を定義する。
9. `21`でインターフェイスと実装を分離する。
10. `10`〜`13`でコード構造へ落とす。
11. `23`で実装、独立検証、人間の受入判定を行う。

### アーキテクチャ・複数module・データ移行

1. `03`で提供価値、コアドメイン、投資対象を定義する。
2. `17`と`26`で問題と技術手段を分離する。
3. `02`で品質シナリオを作る。
4. `27`で品質portfolio、全体trade-off、ADR、target / transitionを設計する。
5. `05`、`21`、`22`で責務境界、公開契約、データauthorityを検証する。
6. `20`で移行中を含む契約を固定する。
7. `23`で実装、migration、rollback、品質シナリオを検証する。

### レガシー改善

1. `17`で症状と原因仮説、維持契約を整理する。
2. `26`で既存コードの具体から本来の目的へ遡る。
3. `16`で対象コードの目的と文脈をAIへ共有する。
4. `04`で改善価値と優先順位を判断する。
5. `08`と`20`で維持すべき挙動を契約化する。
6. `14`と`15`で目的単位に段階分割する。
7. `21`、`22`、`23`で境界、モデル完全性、要件適合性を再検証する。

### AIへ開発を依頼する

1. `17`で問題定義が`ready`か確認する。
2. `26`で技術案への早期固定を外し、目的と成功条件を検証する。
3. `16`でContext Packetを作成し、AIに復唱させる。
4. `02`または`27`で品質目標とtrade-offを固定する。
5. `22`、`20`、`21`でモデル、契約、公開境界を固定する。
6. `23`で生成、契約テスト、完全性監査、品質シナリオ、境界漏出検査を行う。
7. 人間が元の問題、価値、trade-off、残存リスクを受入判定する。
8. 実装が異なっても同じ要件gateを通るか評価する。

### 設計学習・組織展開

1. `18`で、一つの設計テーマをプロダクションコード上で学習する。
2. 学習者が問題発見、問題説明、再設計、設計理由の説明を自力で行う。
3. `19`で再利用可能な知識をCore、Function、Viewpoint、Adapterへ分類する。
4. `25`で最近の公開シグナルと現在の資料coverageを監査する。
5. `24`で根拠、重複、routing、共通hard gateを統合監査する。
6. `23`を統合workflowとしてbenchmarkし、複数実行間の要件適合率を確認する。

## 人間とAIの役割

| フェーズ | 主導 | 補助 | 最終責任 |
|---|---|---|---|
| 問題定義、価値、成功条件 | 人間 | AI | 人間 |
| 前提、別解釈、欠落の探索 | 人間 | AI | 人間 |
| 設計、実装、テスト候補 | AI | 人間 | 人間 |
| 品質trade-off、不可逆な判断 | 人間 | AI | 人間 |
| 機械的rename、抽出、参照更新 | IDE / tool | AIと人間 | 人間 |
| 契約・品質・完全性の実行検証 | test / analysis tool | AIと人間 | 人間 |
| 受入、出荷、rollback判断 | 人間 | AI | 権限を持つ人間 |

Skillを配るだけで、人間の設計力、問題定義力、言語化力、レビュー力を代替しません。AIは使い手の理解と判断を増幅するため、`18`の学習workflowを併用します。

## 各Markdownの共通契約

各文書は原則として次を含みます。

1. 核となる考え方。
2. 解決する問題と適用しない条件。
3. 必要な入力。
4. エージェントが推測で飛ばしてはいけない判断規則。
5. 調査、分析、提案、実装、検証の実行手順。
6. 後続処理が利用できる出力契約。
7. pass / failを判定できる完了条件。
8. 表面的適用や過剰設計を防ぐ失敗パターン。
9. `SKILL.md`へ移植できるプロンプト骨子。
10. 根拠資料と、資料から追加した操作的解釈。

## Skill化するときの必須規則

- 実装前に、観測事実、前提、アクター、問題、目的、成功条件を特定する。
- 技術名を除いても問題を説明できる状態にする。
- `つまり`で具体から目的へ遡り、`たとえば`で目的から契約、実装、テストへ戻る。
- AIへ命令する前に、アクター、目的、文脈、ルール、品質、変更境界を共有し、解釈を復唱させる。
- 確認済み事実、解釈、推論、仮定、未決事項、矛盾を混同しない。
- 品質特性を目的から選び、局所効果とsystem全体への効果を分ける。
- モデル完全性を確認してから契約とinterfaceを確定する。
- 各要件を目的、モデル要素、契約項目、公開操作、テストへ追跡可能にする。
- 契約の所有者を一つにし、Controller、Service、Entityなどへの重複実装を避ける。
- interface型の作成自体を目的にせず、利用者が知るべき意味と知らなくてよい実装詳細を分ける。
- 正常系だけでなく、禁止遷移、境界値、部分失敗、再実行、失敗後状態を検証する。
- AIの説明ではなく、コード、契約テスト、モデル完全性監査、品質シナリオ、境界漏出検査で判定する。
- 変更案を、目的または品質特性の改善へ説明可能にする。
- 不可逆な変更にはowner、承認、migration、rollbackまたはrecoveryを持たせる。
- 一つの巨大Skillへ詰め込まず、Core、Function、Viewpoint、技術Adapter、Presentation、Evaluationを分離する。
- Skillを配るだけで人間の設計力を代替せず、実コードを使った学習とレビューを維持する。

## 資料テーマの論理構成と推奨runtime Skill構成

ここでは、知識を整理する**論理構成**と、Codexが発動・実行する**runtime Skill構成**を分けます。論理構成は資料のcoverage、重複、変更理由を監査するためのtaxonomyであり、directory treeや公開Skillとの一対一対応を意味しません。

### 資料テーマの論理構成

```text
design-core（論理group）
├── premise-and-problem-definition          # 17
├── technical-gravity-navigation            # 26
├── context-verbalization                   # 16
├── purpose-goal-means                      # 01
├── quality-attributes                      # 02
└── evidence-policy                         # shared

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

### Codex runtimeで推奨する構成

```text
.agents/skills/
├── mino-core/                               # 暗黙発火しない共通基盤
├── mino-problem-framing/                    # Problem Framing Package
├── mino-architecture-quality-strategy/      # Architecture Strategy Package
├── mino-domain-model-completeness/          # Completeness Package
├── mino-design-by-contract/                 # Contract Package
├── mino-interface-implementation-separation/ # Boundary Package
└── mino-reproducible-development/           # 複数成果物のrouter
```

論理groupからruntimeへの配置は次のように判断します。

| 論理group | runtime上の配置 | 判断理由 |
|---|---|---|
| design-core | `mino-core` + 公開入口`mino-problem-framing` | 共通判断順を一つのsource of truthへ置き、Problem Frame / Context Packetだけが必要な依頼にも単独で到達させる |
| product-and-architecture | `mino-architecture-quality-strategy` + `mino-core` references | system-wideな価値、品質portfolio、責務、data authority、target / transitionを一つのArchitecture Strategy Packageへ統合する |
| domain-design | `mino-domain-model-completeness` + domain discovery reference | 用語・contextの発見を、対象use caseのmodel coverageとgap判定へ接続する |
| contract-and-boundary（`20`, `21`） | `mino-design-by-contract`と`mino-interface-implementation-separation` | Contract PackageとBoundary Packageは、利用者が単独で求められる別成果物なので公開Functionを分ける |
| contract-and-boundary（`10`, `11`）+ code-design（`12`, `13`） | Boundary Function + code-design reference | capsule、分岐、命名、抽象化を独立pattern集にせず、consumer operationと公開境界へ接続して必要時だけ読む |
| code-design（`14`, `15`） | `mino-reproducible-development` + change-safety reference | 既存挙動の維持、段階的な責務分割、実装、独立検証をmodeと変更権限のある統合工程で扱う |
| reproducible-development | `mino-reproducible-development` | 複数の専門成果物、実装、独立検証が必要な依頼だけを統合する |
| learning-and-scaling | `mino-doc`、`AGENTS.md`、benchmark、versioned evaluation | application開発依頼へ暗黙発火させず、人間学習とsuite保守の工程として分離する |

この配置を推奨する理由は次のとおりです。

- Codexは各Skillの`name`と`description`を入口に選択するため、公開Skillを主成果物単位にするとtriggerと完了条件を対応させやすい。
- 単一成果物は対応Functionを公開入口とし、不足する前提artifactだけをscoped routingすることで、全workflowの過剰起動と不要なcontext読込を避けられる。
- 共通Evidence policy、権限、canonical decisionは`mino-core`をsource of truthとし、Function間の複製を避けられる。
- Viewpointは必要なFunctionからreferenceとして読み、資料数と公開Skill数を機械的に一致させない。
- 統合routerは複数成果物だけを所有し、単一Functionや小規模な機械変更の入口を奪わない。
- 学習とsuite保守をruntime Functionから分け、application成果物と運用成果物を混同しない。

Codex向けruntime packageの正本は`.agents/skills/`、配布対象とversionの正本は`.agents/skills/mino-core/scripts/suite-manifest.txt`です。他の実行環境へ変換する場合も、この論理構成を共有しつつ、その環境の発動単位とmetadataに合わせて別途package境界を決めます。

### 構成を再び見直す条件

次のEvidenceが得られた場合は、現行構成を固定せず、Functionの追加・分割・統合を再検討します。

- debt report、局所code redesign、legacy refactoring、design learningなど、現行Functionでは主成果物を過不足なく返せない単独依頼が反復する。
- 同じ依頼が複数の公開Skillへ安定せずroutingされる、または単一成果物に統合routerが過剰発火する。
- 一つのFunction内に、異なる利用者、変更理由、owner、完了条件を持つ主成果物が増える。
- 言語・framework固有の翻訳が反復し、共通Coreへ技術差分が漏れ始める。
- 新しいpackage境界を支持する利用例、negative case、case / oracle、複数fresh-context runが揃う。

Skillの追加、削除、改名、triggerやOutcome Contractの意味変更を行う場合は、manifest、利用者向けREADME、agent metadata、versioned case / oracle、evaluationを同じ変更で更新します。

## 共通Evidence policy

- `confirmed`: 仕様、コード、テスト、schema、担当者確認などの根拠あり。
- `inferred`: 複数の根拠から推定したが明示されていない。
- `assumption`: 作業継続のため一時的に置く仮定。
- `unknown`: 結果を分岐させる不足。
- `contradiction`: 根拠同士が競合する。

AIの一般知識を、そのシステムの業務要件として扱いません。

## 共通Hard gates

次のいずれかがある場合、実装またはSkill作成の完了を宣言しません。

- 対象アクター、問題、目的、成功条件が不明。
- 技術語を除くと問題を説明できない。
- 重要語の文脈上の意味が確定していない。
- 重要な前提に根拠または反証条件がない。
- 目的から要件、実装、テストへ具体化できない。
- Context Packetの復唱が一致しない。
- primary品質特性とconstraintが不明。
- 重要なアーキテクチャtrade-offにownerと検証方法がない。
- 要件IDに対応するモデル要素または契約がない。
- 契約所有者または状態変更authorityが複数・不明。
- 不正状態を公開経路から生成できる。
- 状態遷移の禁止条件がテストされていない。
- 業務ルールがController、adapter、UIへ漏れている。
- interface partが技術実装を露出している。
- 失敗時の状態保証がない。
- 重要概念の意味がprimitiveに潰れている。
- 代表変更が複数の無関係moduleへ波及する。
- 不可逆な変更にmigration、recovery、明示的承認がない。
- 重要な`unknown`または`contradiction`を隠している。
- AIが問題、価値、trade-off、受入を最終決定している。

## 主要出典

- Speaker Deck — MinoDriven: https://speakerdeck.com/minodriven
- AI時代のキャリアプラン「技術の引力」からの脱出と「問い」へのいざない: https://speakerdeck.com/minodriven/tech-gravity
- 正しくソフトウェアを作る、前提を疑うための認知の視点: https://speakerdeck.com/minodriven/doubt-premise
- その問い、本当に正しいですか？: https://speakerdeck.com/minodriven/ai-philosophy-cognitive-science
- AI駆動開発を妨げる技術的負債の解消アプローチ: https://speakerdeck.com/minodriven/ai-refactoring-approach
- 目的で駆動する、AI時代のアーキテクチャ設計: https://speakerdeck.com/minodriven/purpose-driven-architecture
- ソフトウェア品質特性、意識してますか？: https://speakerdeck.com/minodriven/ai-and-software-quality
- AI時代に必須！状況言語化スキル: https://speakerdeck.com/minodriven/ai-context-verbalization
- MCPサーバー「モディフィウス」で変更容易性の向上をスケールする: https://speakerdeck.com/minodriven/modifius
- AI時代のドメイン駆動設計: https://speakerdeck.com/minodriven/ddd-in-ai-era
- AI時代の『改訂新版 良いコード／悪いコードで学ぶ設計入門』: https://speakerdeck.com/minodriven/ai-good-code-bad-code
- 見えないものに着目すると上手くいく、モデリングの勘所: https://speakerdeck.com/minodriven/invisible-driven-design
- 破壊せよ！データ破壊駆動で考えるドメインモデリング: https://speakerdeck.com/minodriven/data-destroy-driven
- 目的と抽象化の関係性から分かる、システムの設計精度を高める考え方: https://speakerdeck.com/minodriven/purpose-abstraction-design
- アーキテクチャレベルで考える開発生産性: https://speakerdeck.com/minodriven/architecture-and-productivity
- 効果的な学習アプローチ: https://speakerdeck.com/minodriven/effective-learning-of-good-code
- レバテックLAB インタビュー: https://levtech.jp/media/article/interview/detail_369/

## 読み方の注意

- 本資料はミノ駆動氏本人または所属企業が公開した公式Skillではありません。
- 公開資料の長い転載は避け、概念、判断条件、手順、成果物として再構成しています。
- 公開資料で詳細が明示されていない部分は、`操作的解釈`として区別しています。
- 直近6か月の重要度監査はSpeaker Deck公開資料を中心とし、SNSや非公開発言を含む全発言の統計ではありません。
- 人物名を権威として結論を固定せず、対象システムの事実、要件、コード、テスト、品質特性、利用結果で検証してください。

## 次段階

資料からCodex runtime Skillへの初期変換は完了し、0.5.0では共通Core、公開Function、統合router、versioned case / oracle、Windows / Linux validatorまで配置済みです。

次はSkill数を先に増やさず、次のEvidenceを揃えます。

1. 最新routerに対する統合caseを最低3 fresh-context runし、Function固有schemaとrouting returnを再確認する。
2. Problem FramingとArchitectureのtargeted caseをstrict gateで各3 runする。
3. 代表case、negative case、過去pass task、required platformを含むbehavioral Release gateを実行する。
4. 実案件から、過剰routing、成果物不足、重複、技術Adapter不足の反例を収集する。
5. 独立した利用者、主成果物、owner、完了条件、反復需要が揃った場合だけ、新しいFunctionまたはAdapterを追加する。
6. `18`の人間学習と`24`・`25`の再監査を継続し、AI出力を評価する人間の能力とsource coverageを更新する。

構造validatorのpassや一部targeted caseの成功をbehavioral releaseと混同せず、Release gate未達の間は`not ready`を維持します。

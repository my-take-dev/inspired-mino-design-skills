# mino-drive-inspired-design-skills

本リポジトリは、ミノ駆動氏の公開資料を基に、設計判断の原則をAI Skillとして再構成する非公式プロジェクトです。ミノ駆動氏および所属組織による監修・承認・推奨を受けたものではありません。

目指すのは人物の口調や結論の模倣ではありません。問題、目的、文脈、要件、契約、モデル、品質、公開境界を確認し、根拠のある判断と検証可能な成果物を繰り返し作れるようにすることです。公開資料から直接抽出した原則、反復可能なSkillにするためsuiteが追加したschema・gate・workflow、versioningやvalidator等のrepository policyは区別して記載します。

## 現在の状態

```text
Status: Experimental / Preview
Suite version: 0.12.0
Evaluation revision: 0.12.0-r6
Structural validation: 5 CI jobs pass for head d5be04a (merge fcd7e61); documentation correction not rerun in CI
Targeted behavioral evidence: 4 paired inputs against 0.8.0 (180ca1f) and 1 candidate-only negative (9 runs); effective model/settings unobserved
Comparison against PR base develop 0.9.0 (9a2af5e): not run
Behavioral release: not ready
```

suite versionの正本は[suite-manifest.txt](maintenance/scripts/suite-manifest.txt)。評価入力は独立した改訂番号で管理し、現行は62ケースの0.12.0-r6。旧0.12.0と0.12.0-r2 / r3 / r4 / r5のcase / oracleも保持し、入力の意味を上書きしない。同じsuite versionでもruntime digestが異なる実行結果を流用しない。

behavioral releaseは、権限を持つevaluation ownerが`frozen`にしたcaseと隔離oracleをfresh contextで繰り返し実行し、代表・negative・回帰・required platformのRelease gateを満たした状態です。現在のcounted runは0件で、設計規則の有用性や全OSの動作を構造passだけで保証しません。

今回の検証範囲と未実行事項、head `d5be04a`に対する全5 CI jobs成功は[Evaluation 0.12.0-r6](maintenance/evaluations/0.12.0-r6.md)に記録する。r5の全5 CI jobs成功と途中版を含む8試行は[旧評価記録](maintenance/evaluations/0.12.0-r5.md)へ残し、現行runtimeのEvidenceへ継承しない。

## クイックスタート

### 依頼の大きさに合わせた使い方

短い説明では、判断・根拠・未知・検証状態を返す。回答をメモへ保存するだけなら、完全な設計packageを追加しない。後続の実装者が正本として使う成果物を依頼した場合は、必須fieldと参照を備えたpackageを保存する。

7 Skillは判断手順と固有gateを入口へ持ち、初回に短い共通規則を読む。通常の回答でschemaを読まず、正本packageを作る場合だけ独立したschemaを読む。共通規則は同じcontextで再読しない。既存のEvidenceと承認を再利用し、許可済みの修正・test実装は検証まで進める。設計専用Functionは対象systemの編集をcallerへ引き継ぐ。未決判断があっても、それに依存しない分析を完成させる。

品質比較だけの依頼に移行計画を加えず、局所reviewに架空のinterfaceを加えない。検証は変更の影響と必須checkに合わせ、新差分・failure・未解決の懸念がある場合に範囲を広げる。

### Skill routingの適用

このsuiteは技術非依存の設計原則を扱います。プログラミング言語、framework、tool固有のSkillを併用する場合は、主成果物に最も合うmino Skillを基本workflowとし、必要な技術差分だけを追加します。現在のrouting規則は、maintainerが責任を持って採用・保守しています。

Skill compositionを利用側の`AGENTS.md`へ記載する例:

```md
# Skill Composition

When a request matches multiple Skills:

- Use the Skill that best matches the primary outcome as the basic workflow.
- Add only relevant language-, framework-, or tool-specific Skills to supplement that workflow.
- Let the basic Skill control scope, changes, validation, and the final response; specialized Skills provide their domain-specific guidance.
- Apply relevant exclusions and gates to the requested mode; distinguish artifact completion from downstream approval.
- Follow system and developer constraints, then explicit user instructions over Skill defaults.
- Follow the user's explicitly named Skills and do not add unrelated Skills.
```

### 開発工程から選ぶ

このsuiteには、主に**設計フェーズ**で使うSkillと、設計した内容を**実装・レビューまでつなぐ**Skillが収録されています。最初は次の工程名を目安に選べば十分です。詳細な適用条件と成果物は、後述の「収録しているSkill」で確認できます。

| 主に使う工程・フェーズ | Skill | 開発者が使うタイミング |
|---|---|---|
| 設計フェーズ | `mino-problem-framing` | 実装を始める前に、解くべき問題、目的、前提、成功条件を整理するとき |
| 設計フェーズ | `mino-domain-model-completeness` | 業務に必要な概念、状態、制約、振る舞いに漏れがないか確認するとき |
| 設計フェーズ | `mino-design-by-contract` | 要件を、正常時・異常時の条件やテスト可能な約束事にするとき |
| 設計フェーズ | `mino-interface-implementation-separation` | 利用者に見せる操作と、内部の実装方法を分けて設計するとき |
| アーキテクチャ設計フェーズ | `mino-architecture-quality-strategy` | システム全体の構成、データ管理、移行・復旧を設計するとき |
| 設計・実装・レビューフェーズ | `mino-reproducible-development` | 中規模以上の変更で、複数の設計観点をまとめて実装・検証まで進めるとき |
| 通常は直接使わない | `mino-core` | 他のSkillから共通機能として使われるため、開発者が直接選ぶ必要はありません |

新規機能や大きな変更で迷った場合は、まず`mino-problem-framing`で設計の前提を整理します。その後、必要な設計Skillを一つ選び、複数の観点をまとめて実装・レビューまで進める場合だけ`mino-reproducible-development`を使います。設計フェーズのSkillは、実装済みの設計をレビューするときにも使えます。小さなrenameなど、問題や要件が承認済みbaselineとして記録された機械的な変更では、このsuiteを使う必要はありません。

## このSkill suiteが存在する理由

AIに同じ依頼をしても、実装の形は毎回変わり得ます。形が違っても、次の条件を一貫して満たせるようにするのが、このsuiteの役割です。

- 解くべき問題と、採用した手段を混同しない。
- 自然言語の要件を、モデル、契約、公開操作、テストまで追跡できるようにする。
- 必要な業務概念、状態、制約、失敗、writer / readerの欠落を見つける。
- 利用者が知る意味と、内部の技術・手順を分ける。
- プロダクト価値から品質特性とarchitecture上のtrade-offを判断する。
- AIの説明ではなく、証拠、コード、契約テスト、品質scenario、独立検証で判定する。
- 最終的な価値判断、公開契約、不可逆な判断、release可否は人間へ残す。

ここでいう再現性は、毎回同じコードを生成することではありません。異なる実装であっても、同じproblem、requirement、contract、model整合性、quality constraint、public boundaryを満たせることです。

## 対応環境

このSkill suiteは、次の環境を対象にしています。

- **Windows**: Windows PowerShellまたはPowerShell 7を使った構造検証と、Windows固有のpath、filesystem、process差を考慮します。
- **Linux**: Bash 3.2以降を使った構造検証と、case sensitivity、permission、executable bit、symlink等を考慮します。
- **macOS**: 標準`/bin/bash` 3.2を使うBash構造validatorとfixture runnerを対象とし、BSD userland、native filesystem、locale差を独立Evidenceとして扱います。
- **WSL**: Linux filesystem / processを操作するときはLinuxとして扱い、Windows processやWindows側filesystemも操作する場合は境界ごとにplatform Evidenceを分けます。

設計上のproblem、業務要件、contract、test oracleはOS間で共有します。path separator、shell、line ending、permission、file lock等の差だけをplatform固有のimplementationまたはenvironment conditionへ分離します。

複数platform対応が要件なら、全required platformの実行結果が揃うまでplatform parityを「検証済み」とは扱いません。利用できないOSは、対応実装の有無とnative runtime Evidenceを分け、必要なrunner、command、未実行理由とともに残します。

## 収録しているSkill

| Skill | 使う場面 | 主な成果物 |
|---|---|---|
| [`mino-core`](.agents/skills/mino-core/SKILL.md) | 他のSkillが共通の問題定義、証拠、要件追跡、判定規則を必要とするとき。通常は単独で呼びません | Problem Frame、Context Packet、Requirement Catalog、共通decision |
| [`mino-problem-framing`](.agents/skills/mino-problem-framing/SKILL.md) | 技術案先行や曖昧要件を、観測・前提・問題・目的・成功条件へ分けてから設計へ渡すとき | Problem Framing Package |
| [`mino-domain-model-completeness`](.agents/skills/mino-domain-model-completeness/SKILL.md) | ユースケースに必要な概念、状態、制約、失敗、authorityの欠落を監査するとき | Completeness Package |
| [`mino-design-by-contract`](.agents/skills/mino-design-by-contract/SKILL.md) | 自然言語要件を事前条件、事後条件、不変条件、失敗保証、契約テストへ変換するとき | Contract Package |
| [`mino-interface-implementation-separation`](.agents/skills/mino-interface-implementation-separation/SKILL.md) | caller側の分岐や技術漏出を見つけ、目的と契約を中心に境界を設計するとき | Boundary Package |
| [`mino-architecture-quality-strategy`](.agents/skills/mino-architecture-quality-strategy/SKILL.md) | 複数module、data ownership、system-wideな品質trade-off、移行・復旧を設計するとき | Architecture Strategy Package |
| [`mino-reproducible-development`](.agents/skills/mino-reproducible-development/SKILL.md) | 二つ以上の専門成果物、または要件から実装・review・検証へのend-to-end traceを統合するとき。設計のみ・reviewのみも対象 | Implementation Spec、Verified Change、Review Result、またはReproduction Report |

小さなrenameや、問題・契約・data meaningが承認済みbaselineとして記録された機械変更には、このsuiteを起動する必要はありません。単一の成果物が欲しい場合は、統合Skillではなく対応する専門Skillを使います。

短い相談や局所レビューでは、必要な判断・根拠・未知・検証状態を簡潔に返します。回答をメモとして保存するだけなら、完全な設計packageは作りません。後続の設計・実装で正本として使うpackageを求めた場合は、引継ぎに必要なfieldと参照を保持します。

### 資料からruntime Skillへの配置

一つの資料を一つのSkillへ機械的に変換してはいません。主成果物と変更理由が同じ規則をまとめ、異なるものを分離しています。

| `mino-doc`のテーマ | runtime上の配置 | 配置理由 |
|---|---|---|
| `01`, `02`, `16`, `17`, `26`: 目的、品質、文脈、前提、具体と抽象 | `mino-core` + 公開入口`mino-problem-framing` | 共通判断順は一箇所に保ち、Problem Frameだけを求める依頼にも暗黙到達させる |
| `03`〜`05`, `27`: 価値、投資、品質全体最適、target / transition | `mino-architecture-quality-strategy` | system-wide decisionを一つのArchitecture Strategy Packageにする |
| `05`〜`10`, `22`: 用語、context、概念、不変条件、破壊分析 | `mino-domain-model-completeness` | use case scopeのmodel coverageとgapを主成果物にする |
| `08`, `09`, `20`: 条件、失敗保証、冪等性、契約test | `mino-design-by-contract` | condition単位の契約とoracleを主成果物にする |
| `10`〜`13`, `21`: capsule、分岐、命名、抽象、公開境界 | `mino-interface-implementation-separation` + `mino-core`のcode-design reference | consumer operation boundaryと局所code designを接続する |
| `14`, `15`, `23`: legacy移行、AI支援、統合実装・検証 | `mino-reproducible-development` + change-safety reference | 複数成果物を必要時だけ統合し、modeと変更権限を守る |
| `18`: 人間の設計学習workshop | 現在のruntime suiteの対象外 | 開発成果物を作るFunctionと混ぜず、独立した学習成果物として将来分離する |
| `19`, `24`, `25`: Skill modularization、資料監査 | `AGENTS.md`、benchmark、versioned evaluation | 個別開発依頼へ常時発火させず、suiteを育てる保守工程として扱う |

公開資料に明示された主張と、owner schema、canonical status、3-run benchmarkなどSkill化のための操作的解釈は同じ強さの「本人の主張」として扱いません。runtimeでは対象systemのEvidenceで判断し、保守時には`mino-doc`とevaluationの対応を再監査します。

保守時のtraceは「資料テーマ → 判断規則 → 主成果物 → hard gate → case / oracle → evaluation」の順で確認します。0.12.0では、solverへ渡すexact fence payloadを[`cases/0.12.0-r6.md`](maintenance/evaluations/cases/0.12.0-r6.md)、runner metadataと期待gateを[`oracles/0.12.0-r6.json`](maintenance/evaluations/oracles/0.12.0-r6.json)へ分離し、実行済み・未実行を[`Evaluation 0.12.0-r6`](maintenance/evaluations/0.12.0-r6.md)へ記録します。counted runにはmodel / setting、suite / input / output digest、workspace隔離Evidenceが必要です。資料名だけ、schemaの存在だけ、AIの説明だけでは、判断規則が再現されたEvidenceにしません。

## 使い方

### 発動方法と選択条件

Codexは、起動した作業directoryからrepository rootまでにある`.agents/skills/`を検出し、利用可能なSkillとして扱います。すべての`SKILL.md`を常時読み込むのではなく、最初は各Skillの`name`、`description`、file pathを使って候補を判断し、使用すると決めたSkillの`SKILL.md`と必要なreferenceだけを読み込みます。

Skillの発動方法は二つあります。

- **暗黙呼び出し**: ユーザーがSkill名を指定しなくても、依頼内容が`SKILL.md`の`description`に記載された適用条件と一致し、`agents/openai.yaml`の`allow_implicit_invocation`が`true`なら、CodexがそのSkillを選択できます。これは依頼内容に基づく選択であり、必ず同じSkillが選ばれることを保証するものではありません。
- **明示呼び出し**: `$mino-problem-framing`のようにSkill名を依頼へ含めます。特定のSkillを必ず使わせたい場合、複数Skillの適用範囲が重なる場合、または`design`、`review`などのmodeも固定したい場合に使います。`allow_implicit_invocation`が`false`でも明示呼び出しは可能です。

このsuiteの暗黙呼び出し設定は次のとおりです。

| 設定 | 対象Skill | 発動上の扱い |
|---|---|---|
| `true` | `mino-problem-framing`、`mino-domain-model-completeness`、`mino-design-by-contract`、`mino-interface-implementation-separation`、`mino-architecture-quality-strategy`、`mino-reproducible-development` | 各Skillの`description`に依頼が一致したとCodexが判断した場合、Skill名の指定なしで選択できる |
| `false` | `mino-core` | ユーザー依頼から直接は暗黙選択しない。公開入口のFunctionまたはrouterが、共通規則を必要とするときに内部基盤として使う |

暗黙呼び出しでは、次のroutingを基準に必要最小限のSkillだけを選びます。

- Problem FrameまたはContext Packetだけが必要なら、`mino-problem-framing`を使う。
- model、contract、boundary、architectureのうち単一の専門成果物が必要なら、対応するFunction Skillを使う。
- 中規模以上の設計・実装・レビューで複数の専門成果物と独立検証を統合する必要があるなら、`mino-reproducible-development`を使う。
- 問題、公開契約、data meaningが承認済みbaselineとして記録された小規模な機械変更では、このsuiteを発動しない。
- `mino-core`を単独の専門Skillとして使わず、公開入口のFunctionまたはrouterを選ぶ。

個々のSkillが使われる具体的な場面と非適用範囲は、上の「収録しているSkill」一覧と各`SKILL.md`の`description`が正本です。Codexに選択を任せられますが、使用Skillを再現可能に固定したい依頼では明示呼び出しを使用してください。

### このリポジトリで使う

Skill本体は`.agents/skills/`に配置されています。このリポジトリを開いたCodexから、依頼内容に応じた暗黙呼び出し、またはSkill名を指定した明示呼び出しができます。

たとえば、次のように依頼します。

```text
$mino-problem-framing を使って、このRedis導入案を候補手段へ戻し、
誰の何を改善する問題なのか、前提と成功条件を整理してください。
```

```text
$mino-domain-model-completeness を使って、注文確定ユースケースのモデル欠落を監査してください。
```

```text
$mino-design-by-contract を使って、この要件を事前条件・事後条件・不変条件・失敗保証・契約テスト仕様へ変換してください。
```

```text
$mino-reproducible-development の review mode で、この変更が要件からテストまで追跡できるか監査してください。
```

### 別のリポジトリまたはユーザー環境で使う

用途に応じて、`.agents/skills/`直下のSkill directory一式を次の場所へ配置します。

- repository-local（Windows / Linux / macOS共通）: `<target-repository>/.agents/skills/`
- user-wide（Windows PowerShell）: `$HOME\.agents\skills\`
- user-wide（Linux）: `$HOME/.agents/skills/`
- user-wide（macOS）: `$HOME/.agents/skills/`

同名Skillがすでにある場合は、差分とversion、配布inventoryを確認してからsuite一式を更新してください。旧版だけのfileは退避し、新版と混在させないでください。利用者が追加した無関係Skillは変更しません。`mino-core`は他のSkillが共有するため、専門Skillだけでなくsuite一式を同じ`skills` rootへ配置するのが基本です。

suite version、owner、配布対象Skill一覧の正本は[`suite-manifest.txt`](maintenance/scripts/suite-manifest.txt)です。Skill directoryだけを個別に抜き出すのではなく、同じmanifest versionのsuite一式を配置してください。

Skill内の`skills/...`という記述は、実際の保存先名ではなく、インストール済みSkill群の論理的な参照rootです。repository-localとuser-wideのどちらでも動くよう、このpathを`.agents/skills/...`や絶対pathへ書き換えないでください。

## 実行用と保守用の分離

配布するのは`.agents/skills/`の7 directoryだけ（34 files、約91 KB）。作成判断、人物・生成モデルの説明、評価履歴、case/oracle、検証script、配布manifestは`maintenance/`と`mino-doc/`へ置く。Skillから保守資料への参照はない。`mino-*`という既存呼出名は互換性のため維持する。

通常回答は判断・根拠・未知・検証状態で完結する。正式な引継ぎではschemaの必須fieldと実在IDを保持し、同じ内容はartifact参照で再利用する。保存先の拡張子ではなく、後続が正本として使うかで選ぶ。

## ディレクトリ構成

```text
.
├── AGENTS.md / README.md
├── .github/                         # native OS別の検証job
├── mino-doc/                        # 調査資料・既存の作成判断
├── maintenance/
│   ├── design-decisions/            # runtime分離の根拠と変更履歴
│   ├── evaluations/                 # 旧入力を保持。現行0.12.0-r6
│   ├── suite-contract.json          # 責務・enum・評価revision
│   ├── package-shapes.json          # 維持するschema field
│   ├── benchmark.md                 # suite release条件
│   └── scripts/                     # manifest・inventory・validator・fixture
└── .agents/skills/
    ├── mino-core/                   # 共通規則・条件付きreference・schema
    ├── mino-problem-framing/
    ├── mino-domain-model-completeness/
    ├── mino-design-by-contract/
    ├── mino-interface-implementation-separation/
    ├── mino-architecture-quality-strategy/
    └── mino-reproducible-development/
        # 各Skill: SKILL.md、agents/openai.yaml、必要時だけ読むschemas/
```

正確な配布file一覧は[suite-files.txt](maintenance/scripts/suite-files.txt)です。完成Skillの参照はインストール済みskills内で完結します。[mino-docの資料一覧](mino-doc/README.md)と[公式ガイドの反映記録](mino-doc/31-practicality-refresh-20260910.md)は保守用で、実行時には読みません。

## Skillを作成・更新する

1. `mino-doc/README.md`と対象テーマの資料を読み、公開資料にある主張と、Skill化のための操作的解釈を区別します。
2. 既存の`mino-core`と専門Skillを確認し、新しい規則がCore、Function、router、reference、adapter、evaluationのどこに属するか決めます。
3. 適用条件、非適用条件、必要入力、判断順、成果物、拒否条件、完了条件、target platformへ変換します。
4. 実行時に必要な内容を対象Skillまたは`mino-core`へ同梱し、内部参照を`skills/<skill-name>/...`へ統一します。
5. OS差分を共通contractのplatform adapterとして分離し、各Skillからplatform compatibility referenceをroutingします。
6. 判断規則の意味を変えた場合は、solver caseとevaluator-only oracleをversioned artifactとして分離し、fresh contextで回帰を確認します。
7. Windows / Linux / macOSのapplicableな構造validatorと、対象に必要なruntime testを実行し、未実行事項をevaluationへ残します。

Skillを更新するagentが守る詳細規則は[`AGENTS.md`](AGENTS.md)にあります。

## 検証レベルと現在の状態

| 検証レベル | 対象 | 状態 |
|---|---|---|
| 構造検査 | 参照・metadata・mode・schema・文字形式・評価整合 | head `d5be04a`の仮マージ`fcd7e61`で全5 CI jobs成功。Windows PowerShell 5.1ログは1038 checks・87 fixtures成功、skip 0。ローカルWindowsの86 pass / 1 symlink skipとは別Evidence。今回の文書訂正後のCIは未実行 |
| 対象を絞った試用 | 通常回答と正式package、未知・契約・境界・品質 | 独立contextの試用。対象digestと読込量を個別記録 |
| behavioral release | 全ケース・最低3 fresh-context run・required platform | not ready。counted runは0 |
| application runtime | 利用対象のcode・test・移行・復旧 | 対象applicationごとに別途検証 |

991 fieldの保持は主にfield名の存在確認であり、意味・必須条件・判断規則・全入口への適用の同等性は証明しない。r5の約81〜82%削減はPR中間版とのファイル量比較で、developとの直接比較や実測の高速化率ではない。r6の重要case対応と4入力のpaired smokeは旧0.8.0（`180ca1f`）との限定比較で、PR base / developの0.9.0（`9a2af5e`）との比較は未実行。既存runのSHA・digestを保持し、全62ケースなどの未実行事項を[現行評価記録](maintenance/evaluations/0.12.0-r6.md)へ分ける。全体の非劣化とbehavioral releaseは未証明。

### 必要なruntime

構造validator、fixture、oracle生成は**Python 3.10+標準library**を使います。追加pip packageは不要です。Skillの本文を使うだけならPythonは不要です。Bash launcherは3.2以降、Windows launcherはPowerShell 5.1 / 7を対象とします。

Windowsは`MINO_PYTHON`の指定、なければ`py -3`、`python`の順に実行可能なPythonを確認します。Linux / macOSは`MINO_PYTHON`、なければ`python3`を使います。Windowsアプリ実行aliasの存在だけではPythonを利用可能と判定しません。

### Windowsで検証する

repository rootから実行します。必要なら`$env:MINO_PYTHON`へインストール済みPython executableのpathを設定してください。

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File maintenance/scripts/validate-suite.ps1 -SkillsRoot .agents/skills
powershell.exe -NoProfile -ExecutionPolicy Bypass -File maintenance/scripts/test-validator-fixtures.ps1 -SkillsRoot .agents/skills
```

PowerShell 7では`powershell.exe`を`pwsh`へ置き換えます。検査fixtureはfileのencodingとLFを明示し、Python子プロセスとのPIPE通信もUTF-8へそろえる。OSのfile I/O既定encodingをUTF-8へ変更せずに実行できる。

### Linux / macOSで検証する

```bash
bash maintenance/scripts/validate-suite.sh --skills-root .agents/skills
bash maintenance/scripts/test-validator-fixtures.sh --skills-root .agents/skills
```

macOSでは`bash`を標準`/bin/bash`へ置き換えます。必要なら`MINO_PYTHON`へPython executableのpathを設定します。過去のshell単独UTF-8 helperは使用せず、共通Python engineがstrict UTF-8を検査します。

### 評価oracleを更新する

入力や採点の意味を変えるときは新しい評価revisionを作り、旧case / oracleを保持します。正本JSONからMarkdownを生成し、構造validatorで一致を確認します。

```powershell
python -B maintenance/scripts/render_evaluation_oracle.py
```

この共通Python commandの`python`は実行可能なPythonを指定します。Linux / macOSでは通常`python3`です。PowerShellの出力redirectへ依存せず、scriptがUTF-8/LFで保存します。

### CIと検査範囲

[CI workflow](.github/workflows/validate-suite.yml)はLinux current Bash、Pythonを含めたLinux Bash 3.2 image、native macOS標準Bash、native Windows PowerShell 5.1 / 7を別jobで検査します。job定義の存在を実行済みEvidenceとせず、実行runを別に記録します。Bash 3.2 imageにはPythonを明示的に追加し、base digestと実行versionを記録します。

validatorはmanifest、配布inventory、front matter、metadata、mode、subject verdict、内部参照、共通enum、評価revision・digest・JSON/Markdown oracleの一致を確認します。内部参照はコードスパン、inline Markdownリンク、参照定義から抽出し、path・存在・論理境界・到達性を共通に検査する。構造validatorのexitは0=pass、1=内容違反、2=runtime不足またはI/Oによる検査不能です。fixture runnerのexit 0は全実行fixtureの期待結果一致を表し、skip数は別に報告します。

保守領域のactive case / oracle JSON / oracle Markdownも、生bytesのUTF-8（BOMなし）・LF・final newlineを検査する。改行を正規化せず、case本文のexact digestとoracle生成物のbyte一致を照合する。CRLF・CR保存は内容違反として拒否する。

同じskills rootにある無関係Skillは検査しません。構造検査は記述の意味やモデルの判断を証明しないため、[benchmark](maintenance/benchmark.md)に従った独立評価を別途行います。未実行platform、必要runner・command、残存riskは[Evaluation 0.12.0-r6](maintenance/evaluations/0.12.0-r6.md)へ残します。

## 大切にしていること

- **人物模倣ではなく判断規則**: 誰かの口調ではなく、入力、根拠、判断、成果物、検証可能性を保存します。
- **必要なSkillだけを使う**: すべての観点を毎回適用せず、依頼とriskに合う最小のFunctionを選びます。
- **事実と推論を分ける**: 確認済み事実、解釈、仮定、unknown、矛盾を隠しません。
- **人間の判断を残す**: product value、業務上の正しさ、公開契約、不可逆なtrade-off、release可否は自動決定しません。
- **持ち運べること**: 完成Skillは`skills/`の外を参照せず、repository-localとuser-wideの両方で利用できます。
- **OS差を閉じ込めること**: Windows / Linux / macOSで同じcontractを保ち、path、shell、filesystem、processの差だけをimplementationへ隔離します。

このsuiteは設計判断を支援する道具であり、対象domainの専門家や、変更を承認する人の責任を代替するものではありません。

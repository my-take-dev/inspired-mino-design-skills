# mino-drive-inspired-design-skills

本リポジトリは、ミノ駆動氏の公開資料を基に、設計判断の原則をAI Skillとして再構成する非公式プロジェクトです。ミノ駆動氏および所属組織による監修・承認・推奨を受けたものではありません。

目指すのは人物の口調や結論の模倣ではありません。問題、目的、文脈、要件、契約、モデル、品質、公開境界を確認し、根拠のある判断と検証可能な成果物を繰り返し作れるようにすることです。公開資料から直接抽出した原則、反復可能なSkillにするためsuiteが追加したschema・gate・workflow、versioningやvalidator等のrepository policyは区別して記載します。

## 現在の状態

```text
Status: Experimental / Preview
Suite version: 0.9.0
Structural validation: fail on the native macOS fixture runner; pass on executed Linux and PowerShell-over-WSL layers
macOS structural support: implemented; native macOS /bin/bash executed / fail (run 29397674053, exit 2)
Targeted behavioral evidence: not executed
Behavioral release: not ready
```

ここでいうbehavioral release（行動再現性を確認した安定版判定）は、権限を持つevaluation ownerが`frozen`にしたversioned caseと隔離oracleをfresh contextで繰り返し実行し、代表case・negative case・回帰・required platformのRelease gateを満たした状態です。Experimental / Previewとして配布可能であることと、stable releaseとして承認済みであることを分けます。権限を持つmaintainerが全Evidenceを確認するまでstable releaseとは扱いません。

プロダクト価値（利用者・事業が得る成果）と品質portfolio（優先する品質、制約、意図的に最適化しない品質の組合せ）の最終判断も、AIではなく権限を持つ人間が所有します。

native macOS Evidenceは、head `e47aaafb74a27cf2cc7d4bc9c64f74d1933f10db`のworkflow run `29397674053`、job `Native macOS /bin/bash`（job ID `87294760529`）で取得済みです。環境はmacOS 15.7.7、image `macos-15-arm64` version `20260706.0213.1`、`RUNNER_ARCH=ARM64`でした。`validate-suite.sh`はpassしましたが、fixture runnerは`solver-nested-metadata`のportable rewriteで失敗し、jobはexit `2`でした。

macOSはBash構造validator、fixture runner、text-format検査を対応範囲に含めます。共用scriptは標準`/bin/bash` 3.2で実行できるsubsetへ制限しています。上記failureを修正したheadでnative macOS jobがgreenになるまで、platform parityやreleaseをpassにしません。

## クイックスタート

### Skill routingの適用

このsuiteは技術非依存の設計原則を扱います。プログラミング言語、framework、tool固有のSkillを併用する場合は、主成果物に最も合うmino Skillを基本workflowとし、必要な技術差分だけを追加します。現在のrouting規則は、maintainerが責任を持って採用・保守しています。

Skill compositionを利用側の`AGENTS.md`へ記載する例:

```md
# Skill Composition

When a request matches multiple Skills:

- Use the Skill that best matches the primary outcome as the basic workflow.
- Add only relevant language-, framework-, or tool-specific Skills to supplement that workflow.
- Let the basic Skill control scope, changes, validation, and the final response; specialized Skills provide their domain-specific guidance.
- Preserve every applicable Skill's exclusions, hard gates, and safety constraints.
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
| [`mino-reproducible-development`](.agents/skills/mino-reproducible-development/SKILL.md) | 中規模以上の設計・実装・レビュー・再現性検証で、複数の専門成果物と独立検証を統合するとき | Implementation Spec、Verified Change、Review Result、またはReproduction Report |

小さなrenameや、問題・契約・data meaningが承認済みbaselineとして記録された機械変更には、このsuiteを起動する必要はありません。単一の成果物が欲しい場合は、統合Skillではなく対応する専門Skillを使います。

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

保守時のtraceは「資料テーマ → 判断規則 → 主成果物 → hard gate → case / oracle → evaluation」の順で確認します。0.9.0では、solverへ渡すexact fence payloadを[`cases/0.9.0.md`](.agents/skills/mino-core/evaluations/cases/0.9.0.md)、runner metadataと期待gateを[`oracles/0.9.0.md`](.agents/skills/mino-core/evaluations/oracles/0.9.0.md)へ分離し、実行済み・未実行を[`Evaluation 0.9.0`](.agents/skills/mino-core/evaluations/0.9.0.md)へ記録します。counted runにはmodel / setting、suite / input / output digest、workspace隔離Evidenceが必要です。資料名だけ、schemaの存在だけ、AIの説明だけでは、判断規則が再現されたEvidenceにしません。

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

同名Skillがすでにある場合は上書きせず、先に差分とversionを確認してください。`mino-core`は他のSkillが共有するため、専門Skillだけでなくsuite一式を同じ`skills` rootへ配置するのが基本です。

suite version、owner、配布対象Skill一覧の正本は[`suite-manifest.txt`](.agents/skills/mino-core/scripts/suite-manifest.txt)です。Skill directoryだけを個別に抜き出すのではなく、同じmanifest versionのsuite一式を配置してください。

Skill内の`skills/...`という記述は、実際の保存先名ではなく、インストール済みSkill群の論理的な参照rootです。repository-localとuser-wideのどちらでも動くよう、このpathを`.agents/skills/...`や絶対pathへ書き換えないでください。

## ディレクトリ構成

```text
.
├── AGENTS.md                 # Skill作成・更新を行うagent向けの規則
├── README.md                 # この利用者向けガイド
├── .github/workflows/
│   └── validate-suite.yml    # Linux current / Bash 3.2 / native macOS構造検証
├── mino-doc/                 # 公開資料から整理した調査・設計ノウハウ
└── .agents/skills/           # 配布可能なSkill suite
    ├── mino-core/
    │   ├── evaluations/
    │   │   ├── 0.9.0.md             # 現versionのrun結果、未実行事項、残存risk
    │   │   ├── cases/0.9.0.md       # exact fence bodyとして渡すsolver入力
    │   │   ├── oracles/0.9.0.md     # runner metadata、input digest、evaluator-only gate
    │   │   └── fixtures/0.9.0/      # validator parity用のversioned negative fixture
    │   ├── references/platform-compatibility.md
    │   └── scripts/
    │       ├── suite-manifest.txt   # version、owner、Skill一覧
    │       ├── validate-suite.ps1         # Windows
    │       ├── validate-suite.sh          # Linux / macOS
    │       ├── validate-utf8.sh           # locale非依存のstrict UTF-8 helper
    │       ├── test-validator-fixtures.ps1 # Windows validator回帰
    │       └── test-validator-fixtures.sh  # Linux / macOS validator回帰
    ├── mino-problem-framing/
    ├── mino-domain-model-completeness/
    ├── mino-design-by-contract/
    ├── mino-interface-implementation-separation/
    ├── mino-architecture-quality-strategy/
    └── mino-reproducible-development/
```

`mino-doc/`はSkillを作るための根拠資料です。完成したSkillは`mino-doc/`を実行時に読まず、インストールされた`skills/` directory内のファイルだけで完結します。この制約により、元リポジトリを伴わずにSkillだけを配布できます。

調査資料の目的、対象範囲、基準日、文書一覧は[`mino-doc/README.md`](mino-doc/README.md)を参照してください。

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

このrepositoryでは、Skillの「読み込めること」と「期待する判断を安定して返すこと」を分けて判定します。`behavioral release`は一般規格名ではなく、このsuiteのversion判定に使うrepository内の用語です。

| 検証レベル | 確認すること | 0.9.0の状態 |
|---|---|---|
| structural validation | package、front matter、metadata、内部参照、UTF-8 / LF、Linux / macOS BashとPowerShell runtime | Linux Bash 5.3 / 3.2.57とWSL UNC上のPowerShellはpass。native macOSはvalidator pass、fixture runner fail（run `29397674053`、exit `2`）。native Windows checkout / NTFSは未実行 |
| targeted behavioral evidence | 代表的なforward testで、問題定義、Evidence、過剰抽象化拒否、status分離が働くか | not executed。C1〜C15のprovenance付きfresh runは0件 |
| behavioral release | versioned case / oracle、最低3 fresh-context run、代表・negative case、過去回帰、required platformの全Release gate | not ready |
| application runtime correctness | Skillを適用した対象applicationのtest、failure injection、migration rehearsal、実platform動作 | 対象applicationごとに別途検証 |

platform Evidenceを一つの「cross-platform対応済み」へまとめません。現在の確認状況はruntimeとfilesystemの層ごとに記録します。

| Platform evidence | 0.9.0の状態 |
|---|---|
| Linux current Bash validator on WSL Linux filesystem | pass。UTF-8 backend self-testとBash fixture 40 / 40を含む |
| Linux Bash 3.2 validator | pass。Docker Official Image `bash:3.2.57`のLinux rootfsでvalidatorとBash fixture 40 / 40を実行。native macOS Evidenceではない |
| Windows PowerShell 5.1 validator over the same WSL UNC artifact | pass。PowerShell fixture 37 / 37。PowerShell compatibilityの確認であり、native NTFS Evidenceではない |
| Native Windows checkout / NTFS validator and fixture runner | not executed |
| Native macOS `/bin/bash` validator and fixture runner | executed / fail。run `29397674053`、job `87294760529`、macOS 15.7.7、image `macos-15-arm64` `20260706.0213.1`、ARM64。validatorはpass、fixture runnerは`solver-nested-metadata`でexit `2` |
| Application runtime with the same requirement / contract / oracle on required platforms | not executed |

構造validatorのpassだけでbehavioral releaseや対象applicationの正しさを宣言しません。一部caseのpassはその範囲のEvidenceですが、全体の代用にはしません。0.9.0の実行結果、未実行事項、残存riskは[`Evaluation 0.9.0`](.agents/skills/mino-core/evaluations/0.9.0.md)、全release条件は[`Reproducibility benchmark`](.agents/skills/mino-core/references/benchmark.md#release-gate)を参照してください。

### Windowsで構造を検証する

Windows PowerShellでは、repository rootから次を実行します。

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .agents\skills\mino-core\scripts\validate-suite.ps1 -SkillsRoot .agents\skills
```

PowerShell 7を利用する場合は次を実行します。

```powershell
pwsh -NoProfile -ExecutionPolicy Bypass -File .agents/skills/mino-core/scripts/validate-suite.ps1 -SkillsRoot .agents/skills
```

### Linuxで構造を検証する

repository rootから次を実行します。実行権限の有無に依存しないよう、Bashを明示します。shared `.sh` contractの最小runtimeはBash 3.2です。

```bash
bash .agents/skills/mino-core/scripts/validate-suite.sh --skills-root .agents/skills
```

### macOSで構造を検証する

repository rootから標準`/bin/bash`を明示して実行します。Homebrew等の別BashをPATHから選び直しません。

```bash
/bin/bash .agents/skills/mino-core/scripts/validate-suite.sh --skills-root .agents/skills
/bin/bash .agents/skills/mino-core/scripts/test-validator-fixtures.sh --skills-root .agents/skills
```

macOSで必要な外部commandは、標準環境にある`awk`、`od`、`mktemp`、`find`、`grep`、`sed`、`sort`、`tail`、`tr`、`wc`です。strict UTF-8判定は同梱helperでbyte列を検査し、`iconv`実装名やUTF-8 locale名へ依存しません。

CIは[`.github/workflows/validate-suite.yml`](.github/workflows/validate-suite.yml)で、Linux current Bash、Docker Official ImageのBash 3.2.57、native macOSの標準`/bin/bash`を別jobとして定義しています。validatorとfixture runnerも別named stepで実行します。run `29397674053`のnative macOS failureをpassへ読み替えず、修正後headのgreen rerunを新しいEvidenceとして記録します。

validatorは、主に次を確認します。詳細検査とtext-format検査はmanifest記載Skillに限定し、同じrootへインストールされた無関係なSkillは無視します。一方、manifestにない`mino-*` Skillはsuiteの登録漏れとして報告します。

- manifestに記録したversion、owner、Skill一覧と、実際のSkill directoryが一致すること。
- manifestのscalarが一意、versionがleading zeroなしの3-part SemVer、Skill名が一意かつSkillsRoot直下であること。
- manifest versionに対応するsolver case、evaluator oracle、evaluation recordのheadingとbenchmark参照が一致し、solver caseのtop-level fieldがallowlist内であること。
- suiteを構成するSkillと必須section・fileが揃っていること。
- required headingと100行超referenceの`## Contents`が末尾空白なしの完全一致であること。
- front matterがexact delimiterと`name` / `description`一意性を満たし、directory名と一致すること。
- agent metadataが所定の階層とfieldだけを持ち、default prompt内のSkill名、implicit invocation policyが整合すること。
- 内部pathが`skills/`をrootとし、bare filename、absolute path、親参照、SkillsRoot外参照がないこと。
- `$<skill-name>`によるSkill間参照が解決できること。
- 全Skillがplatform compatibility referenceをroutingしていること。
- Windows用PowerShell validatorとLinux / macOS共用Bash validator、strict UTF-8 helperが同梱されていること。
- Skill directoryが配布に不要なREADMEへ依存していないこと。
- suite内のtext fileがUTF-8（BOMなし）、LF、final newlineありであること。

validator自体を変更した場合は、通常の構造検証に加えて次の共通fixtureを実行します。

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .agents\skills\mino-core\scripts\test-validator-fixtures.ps1 -SkillsRoot .agents\skills
```

```bash
bash .agents/skills/mino-core/scripts/test-validator-fixtures.sh --skills-root .agents/skills
```

構造validatorの合格は、対象アプリケーションがrequired platformで正しく動作する証明ではありません。application runtime対応を完了とするには、同じrequirementとcontract testを各required platformで実行します。

## 大切にしていること

- **人物模倣ではなく判断規則**: 誰かの口調ではなく、入力、根拠、判断、成果物、検証可能性を保存します。
- **必要なSkillだけを使う**: すべての観点を毎回適用せず、依頼とriskに合う最小のFunctionを選びます。
- **事実と推論を分ける**: 確認済み事実、解釈、仮定、unknown、矛盾を隠しません。
- **人間の判断を残す**: product value、業務上の正しさ、公開契約、不可逆なtrade-off、release可否は自動決定しません。
- **持ち運べること**: 完成Skillは`skills/`の外を参照せず、repository-localとuser-wideの両方で利用できます。
- **OS差を閉じ込めること**: Windows / Linux / macOSで同じcontractを保ち、path、shell、filesystem、processの差だけをimplementationへ隔離します。

このsuiteは設計判断を支援する道具であり、対象domainの専門家や、変更を承認する人の責任を代替するものではありません。

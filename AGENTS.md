# Repository guidance

## Purpose

このワークスペースは、`mino-doc/`に整理されたミノ駆動氏の公開ノウハウを、WindowsとLinuxで再利用可能なCodex Skillへ変換・保守するために使う。

人物の口調や結論を模倣するのではなく、根拠を持つ判断規則を、適用条件、入力、手順、成果物、拒否条件、完了条件として再現可能にする。

## Repository map

- `mino-doc/`: Skill作成時に読む調査資料。実行時依存にはしない。
- `.agents/skills/`: このリポジトリで管理し、suite一式として配布するSkill群の正本。
- `.agents/skills/mino-core/`: 複数Skillで共有する技術非依存の規則、schema、検証script。
- `.agents/skills/mino-core/scripts/suite-manifest.txt`: suite version、owner、配布対象Skill一覧の正本。
- `.agents/skills/mino-core/evaluations/`: versioned solver case、evaluator-only oracle、run結果と未実行事項の記録。
- `.editorconfig` / `.gitattributes`: text fileのUTF-8 / LF既定値とGit上の改行正規化を管理する。
- `README.md`: 利用者向けの目的、使い分け、導入、更新方法。

## Text file format

- リポジトリ内のすべてのtext fileは、host / target platformにかかわらずUTF-8（BOMなし）、LF、final newlineありで保存する。
- Windows向けのfileもUTF-8 / LFをdefaultとする。対象tool、runtime、またはfile formatの確認済み制約によりLFを使用できないWindows向けfileに限り、必要最小限のfileまたはpatternへCRLFを許容する。Windows向けであることだけを例外理由にしない。
- CRLF例外でもencodingはUTF-8を維持する。例外を追加するときは、制約のEvidence、対象範囲、理由を文書化し、`.gitattributes`へ対象を限定した`eol=crlf`を明示する。
- encodingやline endingの概念を持たないbinary fileは対象外とする。ただし、text fileをこの規則から外すためにbinary扱いしてはならない。

## Portability boundary

完成したSkillの実行時参照は、インストール先の論理的な`skills/` directory内だけで完結させる。これは、Windows / Linux、repository-localの`.agents/skills/`、user-wideの`$HOME/.agents/skills/`のいずれでも同じSkillを使えるようにするためのhard ruleである。

- `SKILL.md`、`references/*.md`などSkill成果物内の内部pathは、必ず`skills/<skill-name>/...`から始める。
- 同一Skill内の参照にも`references/...`のような相対pathを使わず、`skills/<skill-name>/references/...`を使う。
- 他Skillの呼び出しは`$<skill-name>`、ファイル参照は`skills/<skill-name>/...`を使う。
- `.agents/skills/...`、`$HOME/.agents/skills/...`、絶対path、`../`をSkill成果物へ書かない。
- `mino-doc/`、rootの`AGENTS.md`や`README.md`、repository固有の補助文書を実行時に読ませない。
- 実行に必要な規則、schema、template、script、evaluationは、対象Skillまたは`mino-core`の配下へ同梱する。
- 完成Skillから外部資料を直接参照する設計にしない。
- `mino-doc/`は参考文献であり、runtime契約の正本ではない。
- Skill内部の`skills/...`はOS非依存の論理pathとし、物理pathへ解決するときだけplatform nativeのpath APIを使う。
- shell、filesystem、process、test実行を伴うSkillは`skills/mino-core/references/platform-compatibility.md`をroutingし、WindowsとLinuxの差を同じcontractのplatform adapterとして扱う。
- platform固有commandが必要なら、Windows用PowerShellとLinux用Bashの手順またはscriptを用意し、入力、検査項目、exit statusを一致させる。
- Linux Bash構造検証、Windows PowerShell runtime互換、native Windows checkout / NTFS、対象applicationのWindows / Linux runtime parityは別Evidence層として記録し、一つの層のpassを他へ流用しない。
- 一方のOSだけで検証した成果物をWindows / Linux両対応済みと宣言しない。未実行platform、必要runner、commandを明記する。

## Skill design rules

- 一つのSkillは一つの仕事または主要成果物を担当する。工程名だけでSkillを分割しない。
- 共通の判断規則は`mino-core`、専門成果物はFunction Skill、複数成果物の統合だけをrouterへ置く。
- `mino-core`は内部基盤として暗黙呼び出しを無効にする。Problem FrameまたはContext Packetだけを求める公開依頼は`mino-problem-framing`が所有する。入口責務を変える場合はrouting、agent metadata、README、evaluationを同じ変更で更新する。
- 単一成果物の依頼を統合routerへ過剰routingしない。公開契約やdata meaningに触れない小規模な機械変更ではsuiteを起動しない。
- `SKILL.md`のYAML front matterは`name`と`description`だけを持ち、`name`はdirectory名と一致させる。
- `description`の先頭でtriggerを示し、使う場面と使わない場面を区別する。
- `SKILL.md`には少なくともOutcome Contract、Reference Routing、Workflow、hard gate、Completionを持たせる。
- referenceを読む時点と、そこから作る成果物を命令文で明示する。単に「参照する」だけにしない。
- `SKILL.md`は500行以内に保ち、詳細や重複は`references/`へ分離する。100行を超えるreferenceには`## Contents`を置く。
- Skill directoryに`README.md`を置かない。利用者向け説明はrootの`README.md`へ集約する。
- 各Skillに`agents/openai.yaml`を置き、表示名、25〜64文字の短い説明、`$<skill-name>`を含むdefault prompt、暗黙呼び出し方針を定義する。
- 各SkillはWindows / Linux compatibility referenceを直接routingし、自身の成果物に関係するplatform固有gateと完了条件を持つ。

## Evidence and decision rules

- 作業前に`mino-doc/README.md`、対象テーマの資料、変更対象Skill、`.agents/skills/mino-core/references/shared-policies.md`を読む。
- 公開資料に明示された内容と、Skill化のために追加した操作的解釈を混同しない。
- runtime規則の出自は`source-derived principle`、`suite operationalization`、`repository policy`へ分け、suite固有のschema、enum、件数、gate、validator、release条件を公開資料の著者本人が定義した手法へ誤帰属させない。
- 確認済み事実、解釈、推論、仮定、未決事項、矛盾を区別する。不明点を一般知識で業務要件へ変換しない。
- Evidence状態の`confirmed`と意思決定の成熟度を混同しない。AI候補は`proposed`、権限を持つownerが採用したものだけを`approved`、versionとchange controlを持つ比較baselineだけを`frozen`とする。
- sourceの言葉を大量に複製せず、判断可能な規則と観測可能な成果物へ変換する。
- AIは、product value、業務上の正しさ、公開契約、不可逆なtrade-off、release可否を独断で確定しない。必要な人間の判断を成果物に残す。
- 再現性は同じコードを生成することではなく、異なる実装でも同じproblem、requirement、contract、model、quality constraint、public boundaryを満たすこととして扱う。

## Suite version and release evidence

- `suite-manifest.txt`をsuite version、owner、配布対象Skill一覧の唯一の正本とする。`suite_version`はleading zero、prerelease、build metadataのない3-part SemVer `MAJOR.MINOR.PATCH`でexactly once、`owner`はnon-emptyでexactly once、`skill`はpath separatorや親参照を含まないdirectory名としてuniqueに記録する。Skillの追加、削除、改名ではmanifest、READMEの一覧とdirectory tree、validator期待値を同じ変更で更新する。
- trigger、非適用条件、Outcome Contract、hard gate、canonical schema、routing、暗黙呼び出し方針の意味を変える場合は、影響するversioned case / oracleとevaluationを更新する。caseまたはoracleの意味を変えた場合は新しいversionを作り、旧versionを上書きしない。
- solverへ渡すcaseとevaluator-only oracleを分離し、solverへ期待routing、期待status、既知findingを見せない。runnerは選択したYAML fence bodyだけを渡し、case heading / IDを除外する。利用者がraw requestへ書いた明示Invocationは保持し、runnerが期待Skillを注入しない。counted runにはrun ID、model / setting、runtime suite、exact input / outputのdigest、workspace隔離Evidenceを必須にする。
- 構造validatorのpassは、package、metadata、参照、text formatの整合を示す。Skillが期待する判断を安定して返すbehavioral Evidenceや、対象applicationのruntime correctnessの証明には使わない。
- このrepositoryでいう`behavioral release`は、`skills/mino-core/references/benchmark.md`のRelease gateを満たしたsuite versionを指す。固定入力をfresh contextで最低3 runし、代表caseとnegative caseの全対象、過去pass taskの回帰、required platformを満たすまでpassと宣言しない。
- targeted smokeや一部caseのpassは、その範囲のEvidenceとして記録できるが、behavioral releaseの代用にしない。未達ならevaluationとREADMEに`not ready`、未実行項目、残存riskを明記する。

## Change workflow

1. 依頼のactor、目的、対象成果物、適用範囲、非対象、host / target platformを確定する。
2. 関連する`mino-doc/`と既存Skillを読み、追加・変更する規則の根拠と既存責務を確認する。
3. Core、Function、router、reference、adapter、evaluationのうち、変更理由に合う最小の配置先を選ぶ。
4. 既存ファイルを先に読み、重複やrouting loopを増やさない最小差分で編集する。依頼されていない変更を混ぜない。
5. 実行時に必要な情報を`skills/`境界内へ同梱し、内部参照を論理pathへ統一する。
6. manifest、README、AGENTS、case / oracle、evaluationのうち、変更した契約に追随すべき成果物を更新する。
7. 構造検証、参照解決、対象evaluation、差分確認を行う。未実行の検証は実行済みとして報告しない。

## Verification

WindowsではPowerShell validatorを実行する。

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .agents\skills\mino-core\scripts\validate-suite.ps1 -SkillsRoot .agents\skills
```

PowerShell 7を使う場合は`powershell.exe`を`pwsh`へ置き換えてよい。

LinuxではBash validatorを実行する。

```bash
bash .agents/skills/mino-core/scripts/validate-suite.sh --skills-root .agents/skills
```

あわせて、変更内容に応じて次を確認する。

- すべての`skills/...` pathと`$<skill-name>`が解決できる。
- Skill成果物に`mino-doc/`、`.agents/skills/`、絶対path、親directory参照がない。
- front matter、directory名、agent metadata、reference routingが整合する。
- manifestのversion、owner、Skill一覧が実directory、README、versioned evaluationと整合する。
- 既存evaluationと、意味を変えた場合に追加した回帰caseを確認する。solver caseとoracleを隔離し、behavioral releaseを主張する場合は最低3 fresh-context runと全Release gateを確認する。両OS対応がrequiredなら同じoracleをWindowsとLinuxで実行する。
- validator契約を変えた場合は、Windows / Linuxのfixture runnerで同じpositive / negative case、期待message、exit statusを確認する。
- READMEのSkill一覧、使い分け、directory tree、validator説明、現在の検証状態と、AGENTSの保守規則が変更後のsuite契約を反映する。
- Git管理対象のtext fileがUTF-8（BOMなし）、LF、final newlineありであることを確認する。CRLFがある場合は、文書化済みのWindows向け例外と`.gitattributes`の限定patternに一致することを確認する。
- `git diff --check`、`git status --short`、`git diff -- AGENTS.md README.md .editorconfig .gitattributes .agents/skills mino-doc`で意図しない変更がない。

validatorを実行できない場合は、その理由と代替確認の範囲を完了報告に明記する。

## Definition of done

- Skillのtrigger、非適用条件、成果物、hard gate、完了条件が明確である。
- 完成Skillが`skills/`外のruntime resourceへ依存しない。
- Windows / Linux、repository-local / user-wideの各配置で内部pathと契約の意味が変わらない。
- すべてのtext fileがUTF-8（BOMなし）かつLFであり、CRLFは確認済み制約を持つWindows向けfileへ限定されている。
- 根拠のない規則、隠れたunknown、循環routing、未解決参照がない。
- manifest、README、AGENTS、case / oracle、evaluationが同じSkill集合、version、routing責務、検証状態を示す。
- 構造pass、targeted behavioral Evidence、behavioral release、application runtime correctnessを混同せず、未達のrelease gateを`not ready`として残す。
- 実行した検証、未実行の検証、残存risk、人間が決める事項を正確に報告する。

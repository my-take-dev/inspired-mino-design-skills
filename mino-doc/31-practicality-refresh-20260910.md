# 7 Skillの実用性・整合性改善

保守日: 2026-09-10。対象は作業ツリーのsuite 0.12.0。利用者指示によりmanifest versionを維持し、評価入力だけを0.12.0-r2へ改訂した。モデル固有名詞を配布本文やmetadataへ追加しない。

## 公式資料の確認と適用

[OpenAI Model guidance](https://developers.openai.com/api/docs/guides/latest-model)の本文を同日に確認した。確認した節はInitiative and follow-through、Instruction following、Personality and writing style、Subagent delegation、Testing and verification、What's newである。

既に許可された準備を進めて判断可能な成果物を作ること、指示の優先順位と停止理由を明示すること、回答と検証を必要範囲へ絞ること、追加指示でも完了済みの有効な作業を保持することを共通実行方針へ反映した。非同期結果は元のcallとrevisionへ対応付ける。

このsuiteへの適用条件、owner、gate、schemaはsuite operationalizationである。特定モデルの性能・API制約を他runtimeの一般規則にせず、API対応と利用harnessでの実装・権限を分ける。通常のSkill実行にWeb参照を要求しない。

## 監査結果からの修正

| 観測した問題 | 修正 | 検証対象 |
|---|---|---|
| Windows fixtureがCP932・CRLFへ依存 | encodingとLFを明示し、異常formatだけbyte操作 | PowerShell 5.1 / 7のfixture |
| Functionとrouterで統合条件が異なる | 複数成果物、またはend-to-end traceへ統一 | C39、C40、C48 |
| 意味不一致でreview全体が止まり得る | 現在artifactと依存選択・実装のgateを区別 | C41 |
| registry・oracleの不一致を見逃す | mode、暗黙呼出し、subject verdict、dimension、JSON/Markdown一致を検査 | negative fixture |
| 38ケースすべてで禁止事項がoracleと一致 | 旧版を保持し、採点hintを除いた48ケースへ改訂 | judgment / instruction_followingを別集計 |
| 共通文書とschemaの初回読込負荷 | 参照する節を指定し、詳細decision schemaを保存時へ分離 | C43、C47。負荷改善は未計測 |
| 品質catalogとArchitectureの接続が曖昧 | catalog参照と実在品質IDを明示 | C42 |
| README・CIが旧engineを案内 | 0.12.0へ同期、Python依存とWindows CIを追加 | 文書参照と構造検査 |

## Versionと評価

旧case / oracleのbytesは変更していない。現行revisionはsuite contractのevaluation_revisionを正本とし、実行記録はsuite version、評価revision、runtime/input/output digestを保持する。改訂の採用指示は、evaluation caseのfrozen承認やbehavioral release承認とは区別する。

構造検査の結果は[Evaluation 0.12.0](../maintenance/evaluations/0.12.0.md)を参照する。fresh-contextの独立評価と全required platformのnative検証は未完了であり、behavioral releaseはnot readyである。

## PR #11再レビューと実利用の点検（2026-09-16）

[再レビュー](https://github.com/my-take-dev/mino-drive-inspired-design-skills-dev/pull/11#pullrequestreview-5216412383)のコード領域の誤検出とcontainer内参照定義の見逃しを修正した。[CommonMark 0.31.2](https://spec.commonmark.org/0.31.2/)のcode block / code span / link reference definitionを根拠に、本文とコード領域を分けた。一般用途のMarkdown renderer全体の適合試験ではなく、suiteの参照検査の回帰範囲を示す。

独立contextでのC43とC13の試用では、回答をMarkdownへ保存する指示が完全なpackage保存とも読め、短い説明にschemaが大量に付く問題を確認した。共通実行方針のCompletionへ、説明を記録する用途と、後続設計の正本として保存する用途の区別を追加した。技術判断・未知・検証状態は維持し、単なる回答記録ではpackage化を要求しない。正本packageを依頼された場合の必須fieldは維持する。

この区別は、Presentationと専門成果物を分ける`19`の操作的解釈を具体化したsuite operationalizationであり、公開資料の著者本人の新たな規則とは扱わない。評価revisionを0.12.0-r3とし、保存メモと引継ぎpackageの2ケースを追加した。旧0.12.0 / r2の入力とoracleは上書きしない。実行結果・digest・未実行事項は上記Evaluationへ記録する。

## 公式ガイドに基づく7 Skill全体の再調整（2026-09-16）

[公式Model guidance](https://developers.openai.com/api/docs/guides/latest-model)の現行本文を再取得し、Initiative and follow-through、Instruction following、Personality and writing style、Subagent delegation、Testing and verificationを確認した。作業完遂、指示競合の説明、簡潔な回答、委譲条件、変更に見合う検証を今回の調整根拠とした。

API parameterや特定runtimeの機能を、モデル名だけ消して全環境共通の規則へ移していない。既存の互換性確認手順を保持し、本文・metadata・新規caseへモデル固有名詞を追加しない。公式資料は保守用の根拠であり、Skill実行時の外部参照にはしない。

前回の試用と今回の独立した静的監査を照合すると、簡潔化を定めた共通profileに対し、7入口が無条件のpackage完成や再読込を要求していた。設計専用Functionのmode更新、全unknownを止める文言、品質比較への5factor・移行の一律適用も、詳細workflowの適用条件と揃っていなかった。

| 担当 | 今回の具体化 |
|---|---|
| Core | 共通規則の節選択、同一contextでの再読回避、承認範囲と差分の再利用 |
| Framing | 手元の観測から整理を開始し、回答を変える不足だけを質問対象にする |
| Completeness | writer/readerの探索候補と実在経路を分け、未知とcoverageを維持する |
| Contract | 承認済みtest変更を実行まで進め、既存testとoracleを再利用する |
| Boundary | 局所guardのreviewを短く返し、許可済みの境界修正と関連検証を完遂する |
| Architecture | 品質比較・優先度・構造・移行の適用条件を入口とworkflowで揃える |
| Router | 既存artifactが満たす工程を省き、必要な専門成果物と依存関係を統合する |

これらは資料`19`の責務分離・段階的読込と公式ガイドを、このsuiteの既存契約へ適用したsuite operationalizationである。専門のschema、12観点、authority、未知、承認とreleaseの区別は維持した。固定件数やschemaを公式資料の定義へ誤帰属させない。

評価revisionを0.12.0-r4へ進め、既存50入力のexact payloadを維持して5ケースを追加した。修正実行、契約testの不足補完、品質比較、既存承認を使う統合設計、資料内命令の扱いを確認する。旧0.12.0 / r2 / r3は保持する。検証状態と実行制約はEvaluationへ記録する。

品質比較の試用では、品質の「優先案」を投資の順位付けまで含むと解釈して5要因を列挙した。入口と専門workflowで、5factorの適用を負債解消・改修投資の優先度へ限定した。同じ入力の再試行では投資評価を追加せず、primary/constraint・比較・確認計画を返した。1回ずつの観測であり、出力長や効率の安定保証ではない。全文読込による再取得の負荷は残るため、その改善を検証済みとはしない。

再監査では、出力節をpackage作成時だけ読むと、同じ節にあるsubject判定・失敗時の引継ぎ規則も読込対象から外れることを確認した。7入口とも判定・gate本文は返却前に読み、schema展開だけをpackage作成時へ限定した。短いguardの再試用で、5 semanticsの適用判定を保ちつつ、追加抽象化とpackage作成を避けることを確認した。

現在のruntime分離と検証は[0.12.0-r5の記録](../maintenance/evaluations/0.12.0-r5.md)を参照する。

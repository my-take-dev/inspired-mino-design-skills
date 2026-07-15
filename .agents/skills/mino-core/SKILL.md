---
name: mino-core
description: 関連Skillで、問題定義、前提監査、Context Packet、要件正規化、traceability、Evidence、権限、共通gateを共有するときに使う内部基盤。単独で専門設計や実装を完結させる用途には使わない。
---

# Shared Core

技術非依存の判断順と共通契約を提供する。入力、Evidence、成果物、拒否条件、検証結果を再現可能にする。

## Outcome Contract

利用するFunctionは、少なくとも次を作るか、既存成果物を検証する。

- Problem Frameと前提・意味の監査証跡
- causal chainと未決選択を保持するSelection Gate
- Context Packetと、比較根拠・提案status・review主体を分けたAI restatement
- Requirement Catalogとend-to-end traceability
- Windows / Linux / macOSのPlatform Contextと必要なvalidation matrix
- 共通`decision`とengineering / release状態

## Reference Routing

- 内部pathは、配置先にかかわらず、インストールされた`skills/` directoryを参照rootとして解決する。
- すべての関連Skillで、最初に`skills/mino-core/references/core.md`と`skills/mino-core/references/shared-policies.md`を読む。
- 原則やschemaの出自を説明するときは、`skills/mino-core/references/shared-policies.md`の`Source-derived principles`、`Suite operationalization`、`Repository policy`を区別し、suite固有schemaを人物の直接手法として帰属させない。
- 機械的変更でない設計、実装、reviewでは`skills/mino-core/references/requirements-and-traceability.md`を読む。
- 用語、context、概念、model境界を発見するときは`skills/mino-core/references/domain-discovery.md`を読む。
- 責務、公開操作、分岐、命名、抽象化をコードへ落とすときは`skills/mino-core/references/code-design.md`を読む。
- 既存挙動、legacy、migration、段階導入を変えるときは`skills/mino-core/references/change-safety.md`を読む。
- filesystem、process、shell、toolchain、test実行、またはWindows / Linux / macOS対応を扱う前に`skills/mino-core/references/platform-compatibility.md`を読み、Platform Contextとplatform別検証結果を作る。
- Skill更新と`reproduction-test`だけで`skills/mino-core/references/benchmark.md`を読む。
- Windowsでは`skills/mino-core/scripts/validate-suite.ps1`、Linuxでは`skills/mino-core/scripts/validate-suite.sh`、macOSでは標準system Bashから同じBash validatorを実行してsuite構造を検証する。
- validator契約を変更したときは、Windowsで`skills/mino-core/scripts/test-validator-fixtures.ps1`、Linux / macOSで`skills/mino-core/scripts/test-validator-fixtures.sh`を実行し、共通のpositive / negative fixtureを検証する。
- 両validatorは`skills/mino-core/scripts/suite-manifest.txt`をversion、owner、Skill一覧のsource of truthとして読む。

## Platform Compatibility

- problem、requirement、contract、canonical decisionはrequired platform間で共有し、OS差を業務ruleへ混ぜない。
- command実行前にPlatform Contextを作り、logical `skills/` pathとruntimeのphysical pathを分ける。
- 複数platform対応がrequiredならWindows / Linux / macOSの結果を独立Evidenceとして保持し、未実行platformを隠さない。

## Routing Ownership

- standalone Functionが複数成果物を必要と判断した場合だけ、`$mino-reproducible-development`へ一度hand offする。
- 問題定義、前提監査、Context Packetだけを求める公開依頼は`$mino-problem-framing`が所有し、この内部Coreを単独成果物として公開しない。
- integrated routerから呼ばれたFunctionは成果物だけを返し、routerへ再routingしない。
- 単一成果物では対応Functionだけを使い、全workflowを起動しない。
- private renameなど問題、契約、data meaningが`approved | frozen`なbaselineとして記録済みの機械的変更では、このsuiteを起動しない。

## Workflow

1. 依頼mode、scope、変更権限、host / target platformについて確認可能な項目を特定し、Evidence状態とdecision maturityを記録する。未確認項目はunknownまたはcontradictionとしてSelection Gateへ接続する。
2. 観測、解釈、前提、問題、候補手段を分け、Core outputを作る。
3. 具体Evidenceから目的・損失へ遡り、目的から拒否条件・検証へ戻る`reasoning_trace`を作る。
4. 必要なreferenceとFunctionだけをroutingし、peer callにはrequested artifactと返却先を付ける。
5. Function固有のsubject verdictと、依頼artifactのcanonical decisionを分離する。

## Hard Gates

- `skills/mino-core/references/shared-policies.md`のCore / Design / Verification gateを弱めない。
- pattern名、diagram、schemaの空欄埋め、AIの自己説明だけでreadyまたはcoveredとしない。
- AI restatementの`proposed_status: matched`を自己証明にせず、高impactな意味・契約・不可逆判断では許可されたreview主体のaccepted Evidenceなしに選択・実装へ進まない。
- 未作成の後続artifact ID、業務rule、platform Evidenceを推測で補わない。
- unknownな可逆性、causal applicability、selection gateを確定値へ丸めて後続へ進まない。
- concrete Evidence → purpose / loss → rule / quality → decision → validationの往復traceが切れたまま後続へ進まない。

## Completion

`skills/mino-core/references/shared-policies.md`のcanonical decisionを使う。専門Function固有の推奨案と、engineering / releaseの状態を一つのstatusへ混ぜない。複数platform対応がrequiredなら、platform別結果を分け、未実行platformを`verified`へ含めない。

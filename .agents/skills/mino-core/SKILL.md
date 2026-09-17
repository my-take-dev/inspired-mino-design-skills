---
name: mino-core
description: 関連設計SkillからEvidence・承認・共通判定・要件追跡を共有するときに使う内部基盤。単独の公開依頼、専門設計全体、小規模な機械変更には使わない。
---

# Shared Core

## Outcome Contract

callerが必要とする共通recordの不足と差分を返す。正本packageのrootは`core_result`。
対応mode: internal。

## Reference Routing

- 初回は`skills/mino-core/references/shared-policies.md`を読み、Evidence・承認・判定を適用する。既読なら再読しない。
- 問題・意味の整理が必要なら`skills/mino-problem-framing/SKILL.md`のWorkflowで入力を照合する。公開の問題定義依頼は`$mino-problem-framing`が担当する。
- 要件とtraceには`skills/mino-core/references/requirements-and-traceability.md`、用語発見には`skills/mino-core/references/domain-discovery.md`、品質catalogには`skills/mino-core/references/quality.md`を読み、今回の差分だけを作る。
- 対象systemのfile/process/test実行・複数OS要件には`skills/mino-core/references/platform-compatibility.md`を読み、環境と未実行範囲を記録する。単なる回答記録の保存では追加読込しない。
- 正本packageが必要な場合だけ`skills/mino-core/schemas/core.md`を読み、Problem Frame・Context Packet・意味照合・Selection Gateの必要recordを作る。

## Workflow

1. callerの成果物、mode、対象revision、scopeと承認を照合する。
2. 既存Evidenceを参照再利用し、判断を変える不足だけを調査する。
3. 不足を解消できなければ識別条件・確認方法・ownerを残し、依存判断と現在artifactを分けて返す。

## Hard Gates

- 専門成果物のauthorityやIDを再定義しない。未作成の下流はobligationとしてcallerへ返す。
- 現在artifactの必須内容・traceの欠落を、後続phaseの問題へ押し出して隠さない。

## Completion

必要な共通record、根拠、意味差分、未決選択、次の操作可否を返す。設計の完成と検証・採用の完了を区別する。

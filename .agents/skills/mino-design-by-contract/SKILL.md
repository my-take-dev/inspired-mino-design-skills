---
name: mino-design-by-contract
description: 自然言語の要件を事前条件・事後条件・不変条件・失敗保証とcondition単位の保証責任・契約テストへ変換するときに使う。UI入力検証だけ、一般テスト追加、業務実装全体には使わない。
---

# Design by Contract

## Outcome Contract

要件を観測可能な条件、条件ごとの保証責任、失敗後状態、誤実装を識別できる契約testへ変換する。implementationは依頼された契約testを作成・実行する。
正本packageのrootは`contract_package`。
対応mode: design, review, implementation。

## Reference Routing

- 初回は`skills/mino-core/references/shared-policies.md`を読み、Evidence・承認・判定を適用する。同じcontextで既読なら再読しない。通常の判断は本体とこの共通規則で行う。
- 既存挙動・公開契約を変更するときは`skills/mino-core/references/change-safety.md`を読み、baseline・変更step・復旧条件を作る。
- 対象systemのfile/process/test実行・複数OS要件がある場合は`skills/mino-core/references/platform-compatibility.md`を読み、host・対象・検証層を分ける。単なる回答記録の保存では追加読込しない。
- 正本packageの作成・更新・引継ぎを依頼された場合だけ`skills/mino-design-by-contract/schemas/package.md`を読み、必須fieldと実在参照を保持する。

## Workflow

1. 要件、model、既存契約、code/test、obligationを使い、変更をmust-preserve / intentional-change / unknownへ分ける。未提供の全artifactを着手条件にせず、確定できる契約と未決を分ける。
2. 公開operationのcontract_ownerと、各conditionを保証するauthoritative ownerを区別する。一つの観測可能なconditionに一つのCI IDを付ける。
3. preはcallerの呼出条件、postは成功時保証、invariantは有効modelで常時成立する条件、environmentは外部・clock・OS条件、failure_guaranteeは失敗後のdomain/persisted stateと外部副作用の保証として分類する。無効入力への公開応答はpreだけでなくfailure contractも持つ。
4. 各条件をrequired / not_applicable / unknownへ分ける。requiredはstatement、level、authority、一意なauthoritative owner、Evidenceを持つ。値の意味・範囲、内部整合、認可・副作用順、wire互換、永続一意性を実際に保証できる責務へ置く。UIの早期validationや言語の型名で別writerからの保証を代替しない。
5. business/technical failure、外部成功/内部失敗、順序逆転、並行更新、cancel、timeout、曖昧結果をscopeに合わせて扱う。失敗後に何が残るか、retry可否、duplicate結果、idempotencyを個別判定する。operationごとのassessmentを作り、必要な意味だけCIへ定義する。keyは根拠がある場合のみ。pure functionの決定性と副作用の冪等性を混同しない。
6. testのverifiesを実在するrequired CIへ接続する。境界直前/値/直後、禁止遷移、失敗後不変、該当するretry/concurrencyをoracleで識別する。既存testを再利用でき、一つのtestが複数CIを検証してよい。
7. 要件coverage、required CIの定義充足、oracle付きtestの設計coverage、required platformでの実行成功を別に数える。未知CIを別に保持し、比率だけで充足を宣言しない。designはplanned / not_runとする。

## Hard Gates

- N/Aは理由とEvidence、unknownは確認方法と影響を持つ。N/A/unknownへ空のdefensive entryやmechanismを追加しない。
- 契約testが業務実装の欠陥で失敗してもoracleを変えない。test変更だけの依頼なら失敗Evidenceと修正obligationを返す。業務修正も許可済みのrootなら統合へ一度引き継ぎ、scoped childはcallerへ返す。
- 公開変更・移行がある場合だけ互換性window、承認、移行、復旧を持つ。局所test変更へ移行を必須化しない。

## Completion

必要条件・失敗保証・oracleが揃えばsufficient、既知gapがあればinsufficient、重要未確認ならindeterminate。現在の契約成果物の完成と対象の不足を分ける。不足に依存する実装はnext_phaseで止める。

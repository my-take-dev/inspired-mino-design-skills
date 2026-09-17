---
name: mino-interface-implementation-separation
description: consumerが知る目的・操作・契約と内部技術・手順を分け、技術漏出、caller分岐、責務境界と変更局所性を設計・監査するときに使う。if削減、interface量産、全体architectureの選定には使わない。
---

# Interface / Implementation Separation

## Outcome Contract

consumerが必要とする目的・操作・契約と内部技術・手順を分け、漏出と過剰抽象化を判定する。修正が依頼され公開意味と範囲が確定していれば変更・検証まで進める。
正本packageのrootは`boundary_package`。
対応mode: design, review, implementation。

## Reference Routing

- 初回は`skills/mino-core/references/shared-policies.md`を読み、Evidence・承認・判定を適用する。同じcontextで既読なら再読しない。通常の判断は本体とこの共通規則で行う。
- codeの責務・命名を変更するときは`skills/mino-core/references/code-design.md`、既存挙動・公開契約の変更時は`skills/mino-core/references/change-safety.md`を読み、具体的な変更と検証へ落とす。
- 対象systemのfile/process/test実行・複数OS要件がある場合は`skills/mino-core/references/platform-compatibility.md`を読み、host・対象・検証層を分ける。単なる回答記録の保存では追加読込しない。
- 正本packageの作成・更新・引継ぎを依頼された場合だけ`skills/mino-interface-implementation-separation/schemas/package.md`を読み、必須fieldと実在参照を保持する。

## Workflow

1. caller、公開契約、code、依存、品質、実在variantから、domain判断・use-case調整・永続化・外部I/O・表現・運用を分類する。局所guardの問いへ全systemのpackageを要求しない。
2. consumerのpurpose、must_know、must_not_knowと、operationの入力・結果・失敗・副作用・不変条件を定める。domain契約が該当すれば既存Contractを参照する。genericな技術境界には理由付きN/Aとconsumer semantic operationを使い、業務を発明しない。
3. operationごとにend_to_end_deadline、retry_semantics、idempotency、duplicate_semantics、ambiguous_outcomeを個別にapplicable / not_applicable / unknownでscreenする。deadlineは上限・owner・timeout結果、retryは許可/禁止条件・owner、idempotency/duplicateは重複結果・owner、曖昧結果は観測結果・照合/復旧ownerを明確にする。
4. N/Aは理由とEvidence、unknownは確認方法と影響を残す。該当しない意味fieldを空で展開しない。pure/read-onlyという名前だけで全N/Aにせず、外部依存と要求を調べる。冪等性keyは必要な根拠がある場合だけ定める。
5. SDK型、DB row、framework型、provider手順、serialization、cache、algorithm、backoff、試行単位のtimeoutを実装側へ置く。consumerの判断に必要なretry・重複・曖昧結果の意味は公開面に残す。consumerが契約を使いadapterが実装する依存方向にする。
6. semantic/invariant/contract/state/source-of-truth/failure-recovery/operational ownerは既存authorityを参照し、system全体の正本や条件の保証を再決定しない。
7. selection boundaryは実在variantにだけ設ける。一実装でも外部障害隔離・契約安定の根拠があれば小さなportを使える。短いguardは維持し、将来用factoryや階層を作らない。状態・規則・実装variant・一時flagの分岐を区別する。
8. 実装交換、実在variant追加/変更、業務規則変更の該当scenarioをpass / fail / not_applicable / unknownとEvidenceで評価する。既存caller・公開契約を変える場合だけconsumer一覧、互換window、段階移行、復旧、旧path利用ゼロの観測を設ける。

## Hard Gates

- if数・interface数を品質と扱わない。state・判断・更新は同じ目的と不変条件の責務へ集め、不正状態を全public writerから防げるか調べる。
- 共通化は目的・契約・変更理由が揃う場合だけ行う。異なる意味を隠した抽象化やcallerへの技術漏出を残さない。
- 意味不明の箇所を仮定で確定しない。変更予定の暫定pathを導入済みとせず、実在するTMP IDだけを参照する。

## Completion

意味と内部実装が分かれればseparated、技術漏出・誤責務はleaky、根拠のない抽象はoverabstracted、適用自体が不要ならnot_applicable、重要未確認はindeterminate。併存するfindingを保持し、対象verdictと現在artifactの完成を分ける。

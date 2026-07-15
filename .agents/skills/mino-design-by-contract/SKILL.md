---
name: mino-design-by-contract
description: 契約による設計で、自然言語要件を事前条件・事後条件・不変条件・失敗保証・冪等性・契約テスト仕様へ変換するときに使う。一般的なテスト追加、UI入力検証だけ、統合実装全体には使わない。
---

# Design by Contract

自然言語要件を、実装が守る観測可能な契約へ変換する。人物の口調やtemplateの充足ではなく、条件、owner、traceability、test oracleを成果とする。

## Outcome Contract

主成果物として`Contract Package`を作る。通常は次の最小構成を返し、condition単位の詳細schemaはworkflow referenceへ置く。

- requirement ID、Evidence、対象operation boundary
- ID付きprecondition、postcondition、invariant、environment condition、failure guarantee
- failure後state、禁止遷移、retry / duplicate / idempotencyの適用判定
- contract itemごとのlevel、authority種別、authoritative owner、入口のdefensive validation
- contract item IDを検証するGiven-When-Then test specificationと観測可能なoracle
- 分母・分子を明示したrequirement / contract / test coverage
- 公開契約を変更する場合だけ、approval、compatibility、migration、rollback / recoveryを含むChange Safety
- platform差が契約またはtest実行を分岐させる場合だけ、environment conditionとWindows / Linux test matrix
- `subject_verdict: sufficient | insufficient | indeterminate`とcanonical `decision`
- implementationが明示的に依頼され、変更権限がある場合だけtest codeと実行結果

## Reference Routing

- 内部pathは、配置先にかかわらず、インストールされた`skills/` directoryを参照rootとして解決する。
- 最初に`skills/mino-core/references/core.md`、`skills/mino-core/references/shared-policies.md`、`skills/mino-core/references/requirements-and-traceability.md`を読み、共通gateを再定義しない。
- 契約抽出、condition authority、test設計、coverageでは`skills/mino-design-by-contract/references/workflow.md`を読む。
- concept、state、failureの意味が未確定で、このSkillだけでは契約を安全に定義できないstandalone依頼では`$mino-domain-model-completeness`を先に使う。
- 既存挙動または公開契約を変更する場合は`skills/mino-core/references/change-safety.md`を読む。
- filesystem、process、shell、path、line ending等が契約またはtest実行を変える場合だけ`skills/mino-core/references/platform-compatibility.md`を読む。
- standalone依頼が複数成果物、実装、独立検証まで求める場合は`$mino-reproducible-development`へ一度hand offする。
- routerまたはpeer Skillからscoped artifactを依頼された場合は再routingせず、Contract Packageと未解決model obligationだけをcallerへ返す。
- condition ID、coverage、test oracle schemaはsuite operationalizationとして扱う。

## Authority Boundary

- このSkillが所有するのは、operationとcondition単位の契約、保証責務、authoritative enforcement、test oracleである。
- system-wideなdata authority、target / transition architecture、consumer boundaryを新たに決定しない。既存成果物のIDを参照するか、未解決obligationとして返す。
- operation boundary ownerを、すべてのconditionのauthoritative ownerへ流用しない。

## Workflow

1. Core、Requirement Catalog、変更mode、operation boundaryを確認する。
2. 各公開operationをcaller、state、input、result、side effect、failureからinventory化する。
3. 条件をID付きcontract itemへ分け、pre / post / invariant / environment / failure guarantee等へ分類し、Evidenceと適用状態を付ける。
4. 各itemを最も確実に守るauthority種別とauthoritative ownerへ一つずつ割り当て、入口のdefensive validationと区別する。
5. 正常、境界、禁止遷移、partial failure、retry、duplicate、concurrency、必要なplatform conditionを定義する。idempotencyは独立にapplicabilityを判定する。
6. contract item IDを`verifies`で参照し、観測可能なoracleを持つtestを先に設計する。
7. requirement → contract item → test coverageを、明示した分母・分子で監査する。
8. implementation modeだけtestを実装・実行し、それ以外は仕様と未実行状態を返す。

## Windows / Linux Compatibility

- 業務上同じoperationは、WindowsとLinuxで同じprecondition、postcondition、invariant、failure guaranteeを使う。
- OS固有差が結果を分岐させる場合だけenvironment conditionへ置き、domain invariantを複製しない。
- required platformごとにtest commandと結果を記録し、未実行platformをcontract verifiedとしない。

## Hard Gates

以下のいずれかに該当する場合は契約を`ready`にせず、不足condition、owner、Evidence、確認方法を返す。

- 仕様にない業務条件を追加している。
- DTO / UI validationをdomain invariantの唯一の保証にしている。
- requiredなcontract itemにstatement、authority種別、authoritative owner、根拠、test oracleがない。
- operation boundary ownerを全conditionのauthoritative ownerとして流用している。
- `not_applicable`に理由とEvidenceがない、または`unknown`をN/Aへ置き換えている。
- retry、duplicate、idempotencyを互いから推定している。
- 公開契約変更のapproval、compatibility、migrationが必要なのに未解決である。
- test planと実行済みtestを混同している。
- public contract、money、authorization、data meaningをAIが確定している。
- 一方のOSだけのtest成功から、Windows / Linux両方の契約適合を推定している。

## Completion

- 全requirementがEvidence付きcontract itemと、そのIDを検証するtestへ追跡できる。
- operation boundary ownerと各itemのauthoritative ownerが区別され、defensive validationとの差を説明できる。
- 正常、失敗、境界、禁止遷移、再実行の必要経路がある。
- idempotencyの適用状態をEvidence付きで判定し、N/Aまたはunknownを架空のkeyやmechanismで埋めていない。
- retryとduplicateがidempotencyから独立した観測可能なconditionとして追跡される。
- requirement / contract / test coverageの分母・分子と未coverage itemが明示される。
- 既存挙動を変える場合はChange Safetyを同じpackageに保持し、migration contractは公開契約差分またはEvidence上の移行対象がある場合だけ要求する。
- 両OS対応がrequiredなら、同一oracleによるplatform別test結果または未実行理由がある。
- `subject_verdict`、unknown、矛盾、未実行test、残存riskをcanonical decisionと分離して残す。

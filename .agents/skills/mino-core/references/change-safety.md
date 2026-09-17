# Change safety and legacy evolution

## Applicability and baseline

既存挙動、公開契約、legacy構造、移行、暫定経路を変えるときに使う。read-only design/reviewではplan/findingを作り、対象workspaceを変更しない。既存の承認済み対象選定があれば再選定せず参照する。

現行挙動をmust-preserve/intentional-change/unknownに分ける。characterization test、log、read-only queryなどで観測baselineを残し、正しい仕様と同一視しない。frozenは権限あるownerが比較baselineとして承認しversion管理したものだけである。

## Priority and strategy

対象優先度を今回選ぶ場合に、business_criticality、expected_change、debt_impact、failure_risk、remediation_costを一度ずつ比較する。対象選定済みの局所修正へ投資会議相当の再承認を追加しない。

debt_impactの業務・開発・運用への影響を説明する。ordinalを根拠のない数値へ換算しない。新規順位決定でowner不明ならpriorityもunknownにし、確認方法を残す。

| Strategy | 適用条件 |
|---|---|
| in-place small step | 小さい境界、test/seam、容易な復元 |
| purpose split / copy-delete | 複数目的の混在を目的単位で分けて削れる |
| strangler | use caseごとの新旧routingと観測が可能 |

最初のvertical sliceを入力→結果→運用まで通す。意味・契約・変更理由が揃う前に共通化しない。copyしたdataやflagを無期限の正本へしない。

## Steps and temporary paths

temporary_pathのidをBoundary/Architectureから参照する。導入予定を実導入日として書かず、planの場合は予定であることを明示する。削除は利用ゼロ等の観測とowner判断を満たしてから行う。

外部成功をlocal rollbackで消せない場合、write停止と照合・forward recoveryを比較する。二重処理、古いreader、移行中のconflict/reconciliation、失敗後状態、不可逆点を確認する。復旧方針unknownのまま不可逆stepを実行しない。

## Output and gates

priorityを再決定しない場合は、既存priority_assessmentへの参照と再利用理由を保持する。公開契約差がない局所変更へmigrationを機械的に要求しない。必要な変更stepと回帰は省略しない。

実装者と同じcontextの自己reviewは独立reviewではない。reviewの独立性・対象revision・要求/oracle・実行Evidenceを記録する。変更範囲外のcleanupや将来拡張を追加せず、未実行・残存riskをcanonical decisionへつなぐ。

正本packageを作る場合だけ`skills/mino-core/schemas/change-safety.md`を読み、baseline・step・暫定pathを保存する。

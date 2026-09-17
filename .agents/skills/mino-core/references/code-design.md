# Purpose-driven code design

## Purpose and contracts

state、判断、計算、更新を同じ目的と不変条件の責務へ集める。意図を表す操作を公開し、無制限setter、mutable collectionの直接公開、半初期化状態を必要な範囲で防ぐ。技術関心・別目的・別lifecycleを同じmodelに押し込まない。

Goのstruct、Javaのclass、関数型の値など表現方式だけで良否を決めない。全public writerから不正状態を防げるか、ruleの正本、失敗後状態、consumerの変更局所性で判定する。DTOや永続化表現がdata-onlyであること自体を欠陥とせず、domain保証がそこだけに依存していないかを見る。

## Branch and naming decisions

| 分岐の意味 | 判断 |
|---|---|
| 明快な短い入力guard | ifを維持する |
| lifecycle state | 状態遷移のownerへ置く |
| 業務判断表 | rule/policyとして条件と結果を明示する |
| 実装variant | 実在する変更根拠がある場合にboundaryを検討する |
| 一時flag・移行分岐 | owner、期限、観測、削除条件を付ける |

名前はactor、context、目的、責務、対象外が分かるものにする。既存名を伏せて候補を作り、含まれるmemberがfits/does_not_fitかを調べる。単なる用語置換はsymbol-awareなrenameを優先する。

## Abstraction and change scenario

consumer目的、契約、不変条件、変更理由が同じかを先に確認する。表面的に似たcodeを理由なく共通化しない。抽象化なしの案と比較して理解・変更・検証が改善するEvidenceを求める。

一実装でvariant根拠がなければ具体実装を保つ。外部障害境界、安定契約、技術隔離の品質根拠があれば小さなportは許すが、将来用factoryや階層を追加しない。replace implementation/add proven variant/change proven variant/change business ruleのうち該当するscenarioだけで検証する。

semantic retry、duplicate、曖昧結果はconsumerの正しい判断に必要なら契約へ残す。backoffやper-attempt timeoutはその契約内の実装である。

## Output

各判断には対象、変更理由、比較した最小案、Evidence、必要な検証を残す。pattern数・class数・if数を完了条件にしない。実装の全文を追認するtestではなく、公開契約を違反する実装を識別するoracleを使う。

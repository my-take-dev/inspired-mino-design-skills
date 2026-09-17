---
name: mino-reproducible-development
description: 二つ以上の専門成果物、または要件から実装・review・検証へのend-to-end traceを統合するときに使うrouter。単一の設計成果物、公開意味に触れない小規模機械変更には使わない。
---

# Reproducible Development Router

## Outcome Contract

designはImplementation Spec、implementationはVerified Change、reviewはReview Result、reproduction-testはReproduction Report。必要な専門成果物と実在IDのtraceを統合する。
正本packageのrootは`reproducible_development_result`。
対応mode: design, implementation, review, reproduction-test。

## Reference Routing

- 初回は`skills/mino-core/references/shared-policies.md`を読み、Evidence・承認・判定を適用する。同じcontextで既読なら再読しない。通常の判断は本体とこの共通規則で行う。
- 要件の正規化と成果物間traceには`skills/mino-core/references/requirements-and-traceability.md`、既存挙動変更には`skills/mino-core/references/change-safety.md`を読む。
- reproduction-testだけは`skills/mino-reproducible-development/references/reproduction.md`を読み、隔離した実行と比較結果を作る。
- 問題定義は`$mino-problem-framing`、品質・正本・移行は`$mino-architecture-quality-strategy`、model欠落は`$mino-domain-model-completeness`、条件保証は`$mino-design-by-contract`、公開境界は`$mino-interface-implementation-separation`へ、必要な成果物だけを依頼する。
- 対象systemのfile/process/test実行・複数OS要件がある場合は`skills/mino-core/references/platform-compatibility.md`を読み、host・対象・検証層を分ける。単なる回答記録の保存では追加読込しない。
- 正本packageの作成・更新・引継ぎを依頼された場合だけ`skills/mino-reproducible-development/schemas/package.md`を読み、必須fieldと実在参照を保持する。

## Workflow

1. 主成果物が単一の専門設計なら対応Skillへ一度渡して終了する。二つ以上の成果物または要件から実装・検証の統合が必要な範囲だけ進める。
2. 要求・承認・revision・変更境界を揃え、要件と拒否条件を作るか既存を参照する。各専門作業にrun_if、入力、依存、成果物ownerを定める。既存artifactが満たす工程は繰り返さない。
3. 原則は問題定義→必要な品質/用語整理→model→契約→境界→実装/検証。全Skillの実行は要求しない。既に入力が確定した独立部分だけ並列化できる。
4. 分担が有益な場合、子へscope、成果物、許可Evidence、revision、mode、変更権限、終了条件、callerへの返却を渡す。設計専用の子は親がimplementationでもread-onlyにする。子からpeer/routerへ再routingさせず、同じfileのwriterを重複させない。toolがなければ逐次実施と記録する。
5. 各artifactをhandleとrevisionで登録する。各Skillのowner、unknown、coverage、subject_verdictを保持し、obligationを後で作られたCI/T等の実在IDへ接続する。同じlocal IDを文字列一致で統合しない。要約は正本への参照を持ち、同じ内容を別版として複製しない。
6. 実装前に要件→該当model/contract/boundary→test/oracleのtraceを確認する。implementationの許可範囲内で一目的の小さいstepを進め、意味不明・未承認の選択に依存する操作だけを止める。選定済み対象の投資順位を再承認させない。
7. 親は子の主張を原資料・実code・testへ照合する。deterministicな実行結果と独立reviewを区別する。独立reviewには要求・契約・revision・diff・必要codeを渡し、実装者の結論を答えとして注入しない。同じ履歴のforkや自己reviewを独立評価としない。
8. 新指示とrevision差分に依存する結果だけを無効化する。stale/pending/timeoutを成功にしない。必要checkが通り懸念と新差分がなければ返す。

## Hard Gates

- 専門成果物の非該当を埋めるために空packageを作らない。冪等性key、migration、投資評価を一律に要求しない。
- FunctionのID・authority・未知・検証状態を要約で失わない。子の投票や構造検査を実装の正しさの証拠としない。
- review単独では対象systemを編集しない。修正が依頼された場合は権限と実効modeを更新する。

## Completion

現在modeの主成果物、未解決obligation、変更と検証のEvidenceを返す。Verified Changeという名前だけでverifiedにしない。現在artifactの欠落と、完成した条件付き設計の後続停止を分ける。

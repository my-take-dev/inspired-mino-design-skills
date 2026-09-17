---
name: mino-problem-framing
description: 技術案先行、曖昧な要件、用語・前提・目的・成功条件の不一致を整理し、Problem FrameとContext Packetを作るときに使う。専門契約、モデル設計、実装全体、承認済みの機械変更には使わない。
---

# Problem Framing

## Outcome Contract

技術案・曖昧な要件を、技術語に依存しない問題、目的、成功・拒否条件、未決選択へ整理する。正式な引継ぎではProblem FrameとContext Packetを作る。
正本packageのrootは`problem_framing_package`。
対応mode: design, review。

## Reference Routing

- 初回は`skills/mino-core/references/shared-policies.md`を読み、Evidence・承認・判定を適用する。同じcontextで既読なら再読しない。通常の判断は本体とこの共通規則で行う。
- 用語の意味境界を詳しく発見するときは`skills/mino-core/references/domain-discovery.md`を読み、例・反例とcontextの差を作る。
- 対象systemのfile/process/test実行・複数OS要件がある場合は`skills/mino-core/references/platform-compatibility.md`を読み、host・対象・検証層を分ける。単なる回答記録の保存では追加読込しない。
- 正本packageの作成・更新・引継ぎを依頼された場合だけ`skills/mino-problem-framing/schemas/package.md`を読み、必須fieldと実在参照を保持する。

## Workflow

1. 原文、仕様、観測、code、既存承認からactor・context・今回決める範囲を固定する。資料一覧は探索候補であり、全資料の提出待ちにしない。
2. 観測、評価、原因仮説、候補手段を分ける。既存障害・負債なら因果を調べ、未確定原因はunknownと確認手順を残す。新規能力なら需要Evidenceと未充足能力を示し、存在しない誤責務や原因を作らない。
3. 技術をcandidate_meansへ戻し、具体Evidence→目的・損失→成功条件→拒否条件→検証をつなぐ。抽象化は候補を比較できる高さ、具体化は第三者が反証できる深さで止める。
4. 結果を分岐させる用語・前提だけについて別解釈と反証条件を出す。同じ入力の具体例・反例で関係者の期待を比較し、説明用仮例は実業務の根拠と区別する。
5. AI restatementにstatement、comparison_basis、proposed_status、differencesを残す。matchedは比較提案であり承認ではない。高impactな意味照合と確認済みbaselineの再利用には共通規則を適用する。意味照合は人間所有の採用判断を代行しない。
6. 未決選択は候補、識別Evidence、確認方法、owner、影響をSelection Gateへ置く。追加指示は差分へ反映し、なお有効な観測・承認を作り直さない。

## Hard Gates

- 技術語を除くと問題が消える、重要前提の反証方法がない、Evidenceから成功・拒否条件へ辿れない場合は補う。
- 意味差分がmismatched / blockedでも、差分を安全に報告する現在のdesign / reviewは完了できる。依存する選択・実装だけを止める。
- 次の成果物は種別とobligationまで示す。未作成のmodel・contract・test IDや、対象systemの変更を追加しない。

## Completion

目的・意味・成功条件と必要な選択が揃えばsubject_verdictはready。選択肢と確認条件を示せればconditional。安全な問題記述自体が作れなければblocked。現在artifactの完成とは分け、問題解決・実装成功を主張しない。

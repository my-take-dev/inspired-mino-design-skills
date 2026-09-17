---
name: mino-architecture-quality-strategy
description: 複数module、system-wideな品質trade-off、data authority、target/transition、migration/recoveryをproduct valueから設計・監査するときに使う。局所class改善、流行技術の選定、単一契約抽出には使わない。
---

# Architecture Quality Strategy

## Outcome Contract

product valueから品質の優先関係、構造・authority、必要な移行・復旧を設計または監査する。今回の判断が品質比較・投資順位・構造・移行のどこまでかを固定する。
正本packageのrootは`architecture_strategy_package`。
対応mode: design, review。

## Reference Routing

- 初回は`skills/mino-core/references/shared-policies.md`を読み、Evidence・承認・判定を適用する。同じcontextで既読なら再読しない。通常の判断は本体とこの共通規則で行う。
- 品質catalogを作るときは`skills/mino-core/references/quality.md`、投資順位・移行を扱うときは`skills/mino-core/references/change-safety.md`を読み、該当する判断だけを作る。
- 対象systemのfile/process/test実行・複数OS要件がある場合は`skills/mino-core/references/platform-compatibility.md`を読み、host・対象・検証層を分ける。単なる回答記録の保存では追加読込しない。
- 正本packageの作成・更新・引継ぎを依頼された場合だけ`skills/mino-architecture-quality-strategy/schemas/package.md`を読み、必須fieldと実在参照を保持する。

## Workflow

1. actorの目的、value、成功signal、scope、期間、制約、可逆性、判断ownerを確認する。技術は候補手段へ戻す。business capability/subdomainだけをcore / supporting / genericへ仮分類する。technical capabilityは原則N/Aで品質・risk・運用・costを扱い、kind不明ならclassificationもunknownにする。
2. 品質をprimary / secondary / constraint / intentionally_not_optimized / unknownへ分ける。catalogの実在IDを参照し、語彙とthresholdを混同しない。規格を使う場合だけ根拠のあるeditionを明記し、未確認ならproject_definedにする。
3. 品質scenarioへ刺激・対象・環境・期待応答・oracle・owner・Evidence・計測計画を付ける。local改善とsystem/journey/organization/future-changeへの影響を分け、静的metricだけから構造原因を断定しない。
4. 負債解消・改修投資の順位を決める場合だけbusiness_criticality、expected_change、debt_impact、failure_risk、remediation_costを比較する。品質のprimary/constraintだけの依頼へ投資評価を追加しない。未知の費用・ownerや数値scoreを作らない。
   - coreかつ変更が多い領域はmodel・境界・契約・testへの投資を検討する。supportingでも高riskなら安全・法令・会計・運用等の必要品質を守る。genericでは購入・再利用・単純実装を比較する。低変更・低riskでは最小修正・現状維持を許す。分類だけで順位を決めず、5要因のEvidenceへ接続する。
   - supporting / genericへ架空の差別化価値を作らず、維持する価値・回避する損失と根拠を示す。分類や費用がunknownなら確認条件を残し、独自価値や最終順位を補完しない。
5. 現状維持・最小修正・段階改善を比較し、非現実的なら除外理由を示す。build/migration/operation/learning cost、改善・悪化する品質、反証、可逆性を比較する。人間の重み付け・採用は候補作成と分ける。
6. 構造が対象ならsubjectごとにsemantic/contract/state/source-of-truth/failure-recovery/operational authorityを一意にする。writer/readerが複数ならcoordination contractを必要とする。consumer操作の詳細はBoundary、条件保証はContractを参照する。
7. 未決optionはSelection Gateへつなぎ、採用済みtargetと呼ばない。ADRのcurrent/superseded/rejectedとproposed/approved/frozenは別にする。
8. 移行が対象ならfrom/to、依存順、互換性、backfill、新旧読書き、競合・照合、観測期間、終了/abort条件、不可逆点、復旧owner、暫定pathの期限・利用観測・削除条件を定める。外部成功はlocal rollbackで取消済みと仮定しない。
9. value→品質scenario→finding→option→target→transition→validationを該当する段階の実在IDでつなぎ、非該当段階は理由付きで除外する。

## Hard Gates

- 全品質の最大化、未計測値、AIによる投資順位・公開契約・cutoverの承認を作らない。
- 移行中のdual writerには期間・conflict・reconciliation・削除条件・ownerを持たせる。復旧・不可逆点の判断がunknownなら依存操作を止める。
- 品質比較だけの依頼へ架空のtarget、migration、空の専門packageを増やさない。

## Completion

判断・構造・検証が整合し未決採用がなければcoherent、未決を条件付きで隔離できればconditional、既知欠陥はincomplete、重要未確認で判断不能ならindeterminate。設計planはplannedでありruntime成功ではない。

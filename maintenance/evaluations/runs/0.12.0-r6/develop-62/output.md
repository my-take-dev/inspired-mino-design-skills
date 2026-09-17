# 次四半期の設計投資案

**商品推薦の変更漏れ対策と請求照合の正確性・復旧を投資候補にする。勤務日カレンダーは購入・再利用を比較し、社内参照一覧は現状維持を提案する。** すべて`proposed`。費用・工数・会議の重み付けがないため、予算配分と最終順位は確定しない。採用ownerは事業責任者。

根拠は入力の`confirmed_evidence`。E1＝推薦のcore分類・独自結果・毎週変更・条件散在と変更漏れ、E2＝照合のsupporting分類・二重計上・正確性と復旧、E3＝カレンダーのgeneric分類・標準判定・購入／再利用候補、E4＝参照一覧のsupporting分類・低利用・変更予定なし・代替参照・必要品質充足、E5＝採用owner・未見積り。受領した事実は`confirmed`、以下の投資案・定性評価は推論を含む提案とする。

| 能力・価値 | 次四半期の投資候補 | 比較案・trade-off |
|---|---|---|
| CAP1 商品推薦：独自の推薦結果という選定理由を維持／core・E1 | O1 `build`。条件のmodel、責務境界、契約、変更testへ投資する。`now`候補 | O1m 変更箇所の照合だけを加える最小対応、O1n 現状継続と比較。O1は設計・移行費が増える。O1mは条件散在を残す |
| CAP2 請求照合：会計上の正確性と復旧を確保／supporting・E2 | O2 二重計上の発生経路を調べ、計上・照合・復旧の責任を設計する。既存部品の`reuse`と必要箇所の`build`を比較。`now`候補 | O2m 検知・照合・復旧整備の最小対応、O2n 現状継続と比較。最小対応は原因対策を代替しない。非差別化・低変更でも必要品質は削れない |
| CAP3 勤務日カレンダー：標準休日判定を満たす／generic・E3 | O3b `buy`、O3r `reuse`、O3m 最小`build`を比較する。調達方法・priorityは未決 | 適合性、調達・組込み・更新・維持費、保守責任で比較。O3n 現行維持は現行の充足確認が必要。独自機能の拡張は今回最適化しない案 |
| CAP4 社内参照一覧：必要な参照を継続／supporting・E4 | O4n `do-not-fix`／現状維持を提案 | O4m 最小の運用記録確認と比較。必要品質を満たし、障害時の代替もある。追加開発の根拠がない。新規build／buy／reuseは今回非該当 |

4件とも`kind: business_capability`。CAP1のvisionは、独自結果を保ちながら毎週のrule変更を反映できる状態。対象顧客と独自ruleの詳細は未確認。CAP2〜4の差別化visionは`not_applicable`。E2〜E4に独自価値の根拠はなく、表の必要品質・運用価値を守る。

| finding | business criticality | expected change | debt impact | failure risk | remediation cost |
|---|---|---|---|---|---|
| F1 推薦変更漏れ／E1 | 高候補：選定理由に直結 | 高：毎週変更 | 高候補：漏れが続き、独自結果の維持を妨げる | 発生継続は確認済み、損失規模はunknown | unknown／E5 |
| F2 二重計上／E2 | 高候補：会計上の正確性 | 低：変更が少ない | 高候補：誤計上の照合・復旧が必要。構造原因はunknown | 高候補：既発生。頻度・損失規模はunknown | unknown／E5 |
| F3 休日判定／E3 | 必要機能。重要度の大小はunknown | unknown | unknown：負債・障害の提示なし | unknown：誤判定の影響未提示 | unknown／E5 |
| F4 参照一覧／E4 | 低候補：低利用・代替あり | 低：変更予定なし | 低候補：必要品質を充足 | 低候補：元台帳で代替可能 | unknown／E5 |

高・低は比較用の`inferred`な定性評価で、数値scoreではない。F1は差別化と継続変更、F2は会計上の失敗が根拠。coreという分類だけでF1をF2より上位にしない。F3は調達比較、F4は改善を見送る根拠がある。最終`priority`・投資水準は全件`unknown`。

共通priority owner record：`status: identified`、`value: 事業責任者`、`resolution_or_reason: E5で採用ownerを確認。最終順位は未採用`、`evidence: [E5]`。

SG1は`pending`。上表の全optionを候補とし、必要品質を満たす案について次のEvidenceを揃え、事業責任者が費用・risk・重み付け・採用理由を記録した時点で選択する。

| unknown | 確認方法 | 未解決時の影響／owner／Evidence |
|---|---|---|
| U1 対策・調達・移行・維持費と工数 | 各案を同じ期間・費目で見積る | 投資額・採用方法・順位を確定できない／事業責任者／E5・known_unknowns |
| U2 重み付け、品質優先度、許容trade-off | 会議でE1〜E4と見積りを比較し、決定理由を残す | CAP1とCAP2の順序等を確定できない／事業責任者／known_unknowns |
| U3 原因、業務rule、authority、可逆性・復旧 | 変更履歴・事故記録・部品仕様を業務ownerと調査。正本data、writer、契約・運用責任、不可逆点、復旧方法を特定する | targetや本番移行を確定できない／事業責任者が業務ownerと実装・運用担当を調整／入力に構造・責任・移行情報なし |

品質portfolioは今回の比較用`project_defined`。推薦の変更容易性をprimary、照合の正確性をprimary・復旧可能性をsecondary、休日判定と必要な参照の正しさをconstraintとする案。品質優先度の採用もSG1で決める。会計上の必要品質を差別化のために犠牲にしない。

| trace・検証計画 | oracle・owner・実行条件 |
|---|---|
| 推薦価値→Q1変更容易性→F1→O1群→T1責任集約候補→TP0→VAL1 | 隔離環境で代表的な週次変更を反映し、事業ownerが定めた期待推薦結果と必要条件に漏れがないか比較。対象rule・期待結果・候補実装の準備後 |
| 会計上の価値→Q2正確性・復旧→F2→O2群→T2責任明示候補→TP0→VAL2 | 発生済み二重計上を再現し、会計ownerが認める正しい計上・復旧後状態と照合。事故記録・隔離data・復旧担当の準備後。再送・途中失敗は発生経路との関係を調査する |
| 標準判定の価値→Q3判定充足→F3→O3群→T3調達候補→TP0→VAL3 | 事業ownerが確認した休日一覧に一致するか候補を比較。対象休日・仕様・見積りの取得後 |
| 参照継続の価値→Q4参照充足→F4→O4群→T4現行維持候補→TP0→VAL4 | 一覧停止時に必要な元台帳参照が成立するかE4の運用記録と照合。事業責任者が記録管理者へ確認を依頼。担当者特定・記録取得後 |

各接続の理由はE1〜E4の価値・失敗・必要品質。4経路ともtarget未選択・検証未実行で`partial`。VAL1〜4は`planned`。必要runnerは隔離した対象applicationと業務・運用review担当。対象実行系が未提示のためcommandは未定で、TP0の調査で特定する。

ADR1は`proposed`。TP0は見積り・原因調査・oracle確認。ownerは事業責任者、exitは採用判断に必要なEvidenceと担当者の確定。採用案だけに、deploy順・互換性・移行・観測期間・abort・rollback／forward recovery・旧経路削除を持つ次phaseを設計する。source of truth・state authority・不可逆点はU3の解決まで未選択。temporary pathは導入しない。詳細移行計画は今回の投資比較範囲外で、本番実行可能とは扱わない。

再評価triggerは、推薦の変更頻度・漏れの変化、照合の損失・原因の判明、部品の適合性・更新責任・費用変化、参照一覧の利用増・新規変更・代替不能・必要品質未達。残存riskは見積りによる順位逆転、原因と対策の不一致、調達後の維持負担、現状維持の前提変化。

`subject_verdict: conditional`。`decision: {status: pass, artifact_readiness: ready, engineering_status: planned, release_status: not_applicable}`。この会議向け比較案の完成判定であり、採用・実効性・本番移行の承認ではない。decision maturityは`proposed`、ownerは事業責任者、approval Evidenceなし。後続調査はallowed、採用・実装・本番移行はSG1解決までblocked。

AI restatement：「E1〜E5に基づき投資候補を比較し、順位・採用を確定しない」。basis＝raw_request・E1〜E5・prohibited_changes、`proposed_status: matched`、差分なし、独立reviewは`unresolved`。required platformsは入力どおり空、platform parityは`not_applicable`。code・設定・運用dataの変更と検証実行は行っていない。

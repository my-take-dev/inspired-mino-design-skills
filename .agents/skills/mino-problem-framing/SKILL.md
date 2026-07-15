---
name: mino-problem-framing
description: 技術案先行、曖昧な要件、前提・意味・目的・成功条件の不一致を、観測・解釈・問題・候補手段に分け、具体と抽象を往復してProblem FrameとContext Packetへ変換するときに使う。専門model設計、契約抽出、統合実装、approvedまたはfrozenなbaselineに従う機械変更には使わない。
---

# Problem Framing

解決策を選ぶ前に、誰のどの問題を、どの意味・根拠・成功条件で扱うかをEvidence状態付きで記録する。このSkillはread-onlyであり、model、contract、architecture、implementationを確定しない。

## Outcome Contract

主成果物として`Problem Framing Package`を作る。通常は次の最小構成を返し、詳細schemaはworkflow referenceへ置く。

- decision scope、actor、context、観測された阻害要因、目的、損失
- 観測、解釈、前提、仮説、unknown、contradictionの分離
- 技術の引力を受けた候補を未選択の`candidate_means`へ退避した記録
- 具体Evidence → 目的 / 損失 → 成功・拒否・検証の`reasoning_trace`
- Context Packet、AI restatement、成功条件、変更境界
- 未決選択を候補、判定条件、Evidence取得方法、ownerへ接続したSelection Gate
- `problem_readiness.subject_verdict: ready | conditional | blocked`、必要な次成果物、canonical `decision`
- platform差が問題やEvidenceを分岐させる場合だけ、Platform Contextと未実行を含むvalidation record

## Reference Routing

- 内部pathは、配置先にかかわらず、インストールされた`skills/` directoryを参照rootとして解決する。
- 最初に`skills/mino-core/references/core.md`と`skills/mino-core/references/shared-policies.md`を読み、共通Evidence、権限、routing、canonical decisionを再定義しない。
- standalone固有の成果物と判定では`skills/mino-problem-framing/references/workflow.md`を読む。
- 後続へ渡す要求を正規化するときだけ`skills/mino-core/references/requirements-and-traceability.md`を読む。
- 用語、context、暗黙conceptの発見が結果を分岐させるときだけ`skills/mino-core/references/domain-discovery.md`を読む。
- filesystem、process、shell、toolchain、test実行、Windows / Linux差がEvidenceに関係するときだけ`skills/mino-core/references/platform-compatibility.md`を読み、platformごとの事実と未実行事項を分ける。
- standalone依頼が複数の専門成果物、実装、独立検証まで求める場合は`$mino-reproducible-development`へ一度hand offする。
- routerまたはpeer Skillからscoped artifactを依頼された場合は再routingせず、Problem Framing Packageと未解決obligationだけをcallerへ返す。
- 原則やschemaの出自を説明するときは、Context Packet、Selection Gate、restatement review schemaをsuite operationalizationとして扱う。

## Workflow

1. 今回決めること、決めないこと、actor、owner、可逆性、変更境界について確認可能な項目を特定する。未確認項目は`unknown`または`contradiction`として保持する。
2. 依頼原文、仕様、code、test、計測から観測と解釈を分ける。
3. 結果を分岐させる重要語と前提だけを対象に、別解釈、識別Evidence、反証条件、誤り時の影響を監査する。
4. 提示技術を`candidate_means`へ退避し、技術語なしでproblemを記述する。
5. `つまり`で具体から目的へ遡り、`たとえば`で目的から成功・拒否・検証へ戻る。
6. Context PacketとAI restatementを作り、statement、comparison basis、proposed status、differences、review主体を分ける。
7. `ready | conditional | blocked`を判定し、必要な次成果物とobligationだけを指定する。未作成artifact IDを作らない。

## Windows / Linux Compatibility

- OS名やshellをproblemの目的へ置き換えず、観測されたplatform差だけをenvironment Evidenceまたはconstraintへ置く。
- 一方のplatformの挙動から他方を推測しない。
- runtime検証が必要だが行えない場合は、runner、command、oracle、未実行理由を残す。

## Hard Gates

以下のいずれかに該当する場合は、依存する設計・実装へ進まず、`conditional`または`blocked`として不足Evidenceと確認方法を返す。

- actor、目的、観測可能な阻害要因、成功条件のいずれかが判定に必要なのに特定できない。
- 技術語を除くと問題を説明できない。
- 結果を分岐させる重要語・前提に、別解釈、識別Evidence、反証条件、または安全なSelection Gateがない。
- 具体Evidenceから目的へ遡るだけ、または目的から検証へ降りるだけの片道分析である。
- 新規能力なのに既存の構造原因を捏造する、または既存障害なのに因果調査を省略する。
- 人間所有の価値、業務上の意味、公開契約、不可逆なtrade-offをAIが確定する。
- 可逆性または既存問題 / 新規能力の区別が未確認なのに、`reversible`または確定済みcausal chainへ丸める。
- schema、一般論、人物名、AIの自己説明だけでproblemを`ready`にする。

## Completion

- problem、Context Packet、reasoning trace、AI restatementが同じactor、意味、目的、変更境界を保つ。
- candidate meansは未選択のまま、目的、品質、制約、検証で比較可能である。
- 新規能力では未充足capability、既存問題では症状からrule / owner / 構造原因への因果をEvidence付きで扱う。
- high-risk unknown、contradiction、未実行platform確認、人間判断を隠さない。
- conditionalな選択は候補、predicate、Evidence取得、ownerを持つSelection Gateへ接続し、`pending`を選択済みと表現しない。
- 次のSkillへ渡す場合は必要artifactとobligationだけを指定し、未作成IDを捏造せず、canonical `decision`で現在のframing artifactを判定する。

実装へは渡せない。S1 r1の「返金額」が各回の額か、同じ支払に対する累計額か未確定で、会計担当の確認もない。前工程の `matched` を承認済みの契約へ昇格させない。

`$mino-design-by-contract` と共通規則を使用した。用語の未確定部分だけ `$mino-domain-model-completeness` の観点で監査した。以下は未決事項を隔離した契約候補と実装可否判定だ。対象systemのcode・設定・運用dataは変更していない。

## 根拠と問題の整理

- E1（confirmed）: S1 r1の文面は「返金額は支払額まで」。返金ownerは会計担当。分割返金も同じ操作で行う。
- E2（confirmed）: 前工程のAIが「各回の返金額が支払額以下ならよい」と復唱し、S1とmatched、不明点なしと記録した。
- E3（confirmed）: 比較根拠はS1 r1。reviewはunresolved。会計担当は解釈を確認していない。

E2で確認できるのは「AIがそう記録した」という事実だ。各回解釈が正しいこと、独立reviewが済んだことは確認できない。比較根拠が存在することと、比較結果の採用は別だ。S1が各回説を明示していない以上、S1と矛盾すると断定することも避ける。入力の `known_unknowns: []` をそのまま継承せず、U1以下を追加する。

Problem Frame: 会計担当の返金ルールを、実装者が分割返金でも同じ意味で守れる契約へ変換したい。現状は返金額の集計範囲と承認状態が欠け、実装結果が分岐する。目的P1はS1の意図に合う返金上限を守ること、成功条件G1は会計担当が採用した意味と、境界例・反例の期待結果が一意につながることだ。P1/G1は本依頼から整理した提案で、業務ownerの承認済み目標ではない。

対象は返金操作OP1の上限契約。呼出主体、実装境界、保存先はunknown。業務上の返金ownerは会計担当と確認済みだが、各conditionを強制するmodule、状態の正本、公開APIのownerは未確認だ。既存実装の欠陥や本番での過払いは確認していない。構造原因は推定しない。

## 意味の候補と識別例

説明用にPを対象支払額、rを今回返金額、Cを同じ対象支払に対する既返金額候補と呼ぶ。Cに含める返金の状態・基準時点は未定義だ。

| 候補 | 上限条件案 | 成功時の保証候補 | 未確定事項 |
|---|---|---|---|
| A: 各回上限 | r ≤ P | 個々の返金額が支払額を超えない | 累計がPを超えてよいかはS1から確定しない |
| B: 累計上限 | C + r ≤ P | 同一支払に対応する返金累計がP以下 | 集計対象、確定時点、並行返金の扱い |

いずれも `decision_maturity: proposed`。候補Bを一般常識で採用しない。候補Aも前工程の復唱を理由に採用しない。下限、通貨、端数、手数料、返金期限、認可条件などは追加していない。

識別用の仮例: 支払額10,000、初回返金6,000、次回返金6,000。Aの上限条件だけなら両回を通せる。Bの上限条件なら2回目は累計12,000になるため通せない。この差を会計担当へ提示する。これは思考実験で、実dataや実行結果ではない。他の業務条件も満たすと仮定して全面的な返金許可を導いてはいない。

```yaml
ai_restatement:
  statement: "S1 r1は返金額を支払額までとしているが、分割返金時の各回・累計の意味は確定できない。前工程の各回解釈は独立review未了の候補である。"
  comparison_basis: ["E1: S1 r1の返金上限と分割返金", "E2: 前工程の復唱", "E3: review unresolved"]
  proposed_status: blocked
  differences:
    - "前工程が追加した『各回』という限定はS1 r1の提示文面にない。"
    - "『不明点なし』という自己判定では、集計範囲と独立reviewの不足が解消されない。"
  reviewed_by:
    kind: unresolved
    identity: "unknown"
    review_status: unresolved
    evidence: [E3]
```

このblockedは、未確定解釈を入力にして確定契約を抽出・選択する処理の停止を表す。比較候補、確認方法、実装へ渡せない理由の作成は可能だ。今回のAIによる再監査も独立したaccepted reviewではない。

## 契約案

R1: OP1の返金額がS1 r1の意味する支払額上限を超えない。EvidenceはE1。分割返金も対象とする。期待結果の集計範囲はU1、禁止結果はU1の解決後に確定する。

| ID | kind / applicability | statementまたは未決事項 | level / authority / authoritative owner | 根拠 |
|---|---|---|---|---|
| CI1 | invariant / required | 「返金額は支払額まで」を守る。A/Bのどちらを指すかは未確定 | level unknown / invariant_owner / unknown | E1、U1、U2 |
| CI2 | precondition / unknown | 上限の判定に用いるP、r、BならCの意味と参照時点を確定する | unknown / semantic_owner / unknown | E1、U1、U3 |
| CI3 | postcondition / unknown | Aなら各回、Bなら累計の上限保証候補。成功の確定点も未決 | unknown / state_authority / unknown | E1、U1、U3 |
| CI4 | failure_guarantee / unknown | 上限超過時の公開応答、失敗後state、既存返金と外部副作用の扱い | unknown / failure_recovery_owner / unknown | E1に規定なし、U4 |
| CI5 | prohibited_transition / unknown | 選択した上限を破る成功遷移を禁止する候補。並行処理時の判定を含む | unknown / state_authority / unknown | E1、U3 |
| CI6 | retry / unknown | 失敗・結果不明後の再要求を受理する条件と結果 | unknown / failure_recovery_owner / unknown | U5 |
| CI7 | duplicate / unknown | 同一要求の重複と別の分割返金を区別する意味・観測結果 | unknown / contract_owner / unknown | U6 |

CI1も完全な実装契約ではない。文面上の義務はrequiredだが、意味、強制主体、独立reviewが未完了だ。会計担当という業務ownerを全conditionの実装ownerへ流用しない。

各itemの入口defensive validationは `status: unknown`。UI/APIの仕様も提示されていない。実装担当に全経路と正本を確認し、早期応答用の検証と最終保証を分ける。UI検証だけでCI1を守れるとは判断しない。

OP1のidempotency assessmentは `applicability: unknown`。再送、重複、結果不明時の意味をU7で確認する。retry、duplicateの未決事項を独立に残し、idempotencyの必要性やkey、保存期間を発明しない。

## テスト候補とcoverage

すべて `implementation_status: planned / execution_status: not_run`。以下はU1を決めるための条件付きoracleだ。採用済みの正解ではない。`verifies: [CI1]` とし、r、P、Cの対象・単位・状態をownerが確定した後に実行可能な契約テストへ具体化する。

| ID | Given | When | Then / observable oracle |
|---|---|---|---|
| T1 | 支払額10,000、同じ支払で6,000の返金が済んだ仮例 | 追加で6,000の返金を要求 | Aなら上限条件は満たす。Bなら上限条件違反。判定結果と確定した返金額で識別する |
| T2 | 支払額10,000、同じ支払で6,000の返金が済んだ仮例 | 追加で4,000の返金を要求 | A/Bとも上限条件は満たす。Bでは累計10,000が境界値 |
| T3 | 支払額10,000、既返金なしの仮例 | 10,001の返金を要求 | A/Bとも上限条件違反。超過額で返金成功を観測すれば不適合 |

金額の例は候補を識別する数値で、通貨単位や最小刻みを業務要件にしていない。上限内であることは他の条件を含む操作成功の十分条件ではない。エラーcodeや失敗時の外部副作用はU4が解決するまでoracleに加えない。

trace: P1 → G1 → R1 → OP1/CI1 → T1〜T3。分割返金も同じ操作というE1により、R1を1回だけの入力検証で閉じない。T1は各回解釈をそのまま採用した場合の累計上限解釈への反例になる。T2/T3は等号と超過の識別を担う。集計対象・保証主体の不足によりtrace状態は `partial`。

- requirement coverage: 分母1（R1）、分子1（CI1と条件付きoracleへ接続）。追跡漏れ0。これは採用済み意味の充足率ではない。
- contract coverage: 分母1（requiredのCI1）、分子0。未充足CI1。権限ある確認とauthoritative ownerが欠ける。
- test-plan coverage: 分母1（requiredのCI1）、分子1（T1〜T3）。実行済みは0/3。分岐したoracleの採用は未了。
- unknown item: CI2〜CI7。idempotencyはU7として独立評価。unknownをN/Aにもrequired分母にも混ぜない。

CI4〜CI7、並行返金、結果不明時のoracleは未確定だ。test-plan coverageが1/1でも、契約を実装可能とは判定しない。

## 未決事項と選択gate

| ID | subject | confirmation_method | impact_if_unresolved | owner | evidence |
|---|---|---|---|---|---|
| U1 | 返金額の各回・累計の意味と独立review | 会計担当へA/BとT1〜T3を示し、意図する結果、S1 r1との対応、採用記録を取得する | 金額上限の異なる契約を実装する | 会計担当 | E1〜E3 |
| U2 | CI1の唯一の強制主体、P/Cの正本、公開境界owner | 対象API・model・保存先・更新経路のEvidenceと担当者を特定する | 正しい式でも迂回経路や異なる正本から制約が破れる | unknown。会計担当に技術責任者の特定を依頼する | E1は業務ownerだけを示す |
| U3 | 累計案で数える返金状態、確定点、並行更新 | 会計担当と特定後の技術責任者が状態表と競合例の期待結果を決める | 並行返金や処理中返金で上限判定が分岐する | 会計担当。技術責任者はunknown | E1の分割返金、候補B |
| U4 | 上限超過・技術失敗・部分失敗の応答と失敗後state | 操作仕様、外部副作用、失敗例を確認し、回復責任者を特定する | 拒否後にも返金が確定するなどの結果を判定できない | unknown。会計担当に確認先の特定を依頼する | E1〜E3に定義なし |
| U5 | retryの適用と意味 | 失敗後・結果不明後の再要求仕様を確認する | 再実行の可否と効果を判定できない | unknown。U2で特定する境界owner | E1〜E3に定義なし |
| U6 | duplicateの適用と意味 | 重複要求と別の分割返金を区別する仕様を確認する | 二重返金と正当な分割返金を識別できない | unknown。U2で特定する境界owner | E1〜E3に定義なし |
| U7 | idempotencyの必要性 | U5/U6、結果不明、外部副作用のEvidenceから独立に判定する | 同じ要求の繰返しによる保証を定義できない | unknown。U2で特定する境界owner | E1〜E3に定義なし |

```yaml
selection_gate:
  id: SG1
  subject: "S1 r1の返金上限の意味"
  candidate_ids: [A, B]
  decision_condition: "会計担当が分割返金の識別例を確認し、採用解釈とS1の対応を記録する。restatementには許可されたreview主体のaccepted Evidenceを添える。"
  evidence_required: ["owner確認記録", "採用解釈", "T1〜T3の期待結果", "review主体・acceptedの証跡"]
  evidence_acquisition: ["A/Bを併記して会計担当へ確認する", "必要なら仕様を追記し、解釈の根拠をversion付きで残す"]
  owner: "会計担当"
  status: pending
  evidence: [E1, E3]
```

独立評価者が比較をacceptedにしても、金銭条件を決める会計担当の権限を代替しない。SG1が満たされた後に、U2〜U7、authority、failure oracleを具体化して契約を再判定する。

公開契約の変更・移行の要否は現行契約が未提示のため未判定。今回は候補の設計だけで既存挙動を変えない。採用候補と現行公開契約に差分が判明した時点でapproval、compatibility、migration、rollback/recoveryを評価する。無根拠な移行作業を追加しない。

## 判定

```yaml
subject_verdict: insufficient
decision:
  status: pass
  artifact_readiness: ready
  engineering_status: planned
  release_status: not_applicable
  decision_maturity:
    status: proposed
    owner: "会計担当"
    scope: ["返金上限の契約候補と実装可否判定"]
    evidence_status: confirmed
    approval_evidence: []
    baseline_version: "unknown。S1 r1は比較根拠であり承認済み契約baselineではない"
    change_control: "unknown"
  next_phase:
    name: "契約の確定・実装への引渡し"
    status: blocked
    reasons:
      - "各回・累計の解釈とaccepted reviewが未確定"
      - "authoritative owner、failure、再実行の契約が未定義"
    human_approvals_required:
      - "会計担当による返金上限の意味の採用"
      - "restatement比較結果のaccepted reviewとEvidence"
  evidence: [E1, E2, E3]
  assumptions: ["説明用の名称とlocal IDのみ"]
  unknowns: [U1, U2, U3, U4, U5, U6, U7]
  contradictions: []
  failed_gates:
    - "後続契約確定: 金銭の意味を分岐させるrestatementのaccepted reviewがない"
    - "後続実装: required conditionの意味とauthoritative ownerが未確定"
  unexecuted_validation:
    - id: UV1
      reason: "design mode。対象実装と確定oracleがなく、T1〜T3は条件付き仕様のみ"
      required_runner: "対象applicationの契約テストrunner。未提示"
      planned_commands: ["unknown。技術責任者の特定と対象repositoryの提示後に確定する"]
      owner: "unknown。U2で特定する技術責任者"
      evidence: ["input mode: design", "U1", "T1", "T2", "T3"]
  platform_validation:
    required_platforms: []
    executed: []
    unexecuted: []
    parity_result: not_applicable
    platform_specific_risks: []
  residual_risks:
    - "各回解釈を採用して累計上限の意図に反する可能性"
    - "累計解釈を独断で採用して業務上許可された返金を拒否する可能性"
    - "失敗・並行処理・再要求の未定義による判定漏れ"
  human_approvals_required: []
```

`pass / ready` は条件付き契約案と不足を明示した今回の設計回答の完成を表す。返金契約の十分性、実装許可、owner承認を表さない。実装可能な契約としては `insufficient`、引渡しは `blocked`。現在の契約案をapprovedにする依頼ではないため、現在artifactをawaiting_approvalにはしない。

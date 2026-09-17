決済承認後の保存失敗を、既存契約と未決の失敗保証に分けて契約化する。条件付き設計として完成。回復方式の選択と実装は保留する。

`subject_verdict: insufficient`。回復方式・責任者・期限が未確定で、実装に渡せる失敗保証が揃っていない。これは設計資料の未完成を意味しない。

- mode: `design`
- routing: `mino-design-by-contract`。状態の不足を `mino-domain-model-completeness` の観点で限定監査し、未解決obligationとして保持した。
- 対象: provider authorization成功後、DB saveが失敗する経路と、同じkeyの再利用。
- 非対象: 対象systemのcode・設定・運用data変更、回復操作、release判断。
- 名前とIDはこの資料内の識別子。実在API名・状態enum・ownerを発明していない。

**根拠と問題の整理**

| ID | 状態 | 根拠 |
|---|---|---|
| E1 | confirmed | input.yaml の confirmed_evidence: provider authorization成功後にDB saveが失敗する |
| E2 | confirmed | input.yaml の confirmed_evidence: 同一key・異なるpayloadはconflictという既存契約 |
| E3 | confirmed | input.yaml の known_unknowns: void/refund/reconciliationの選択は未承認 |
| E4 | confirmed | input.yaml の known_unknowns: recovery ownerと期限は未確定 |
| E5 | confirmed | input.yaml の mode、required_platforms、allowed_assumptions、prohibited_changes |

Problem Frame: 依頼者は決済承認後の保存失敗を、実装と検証へ渡せる契約として整理したい。外部承認成功と保存失敗が併存する一方、失敗後の許容状態と回復責任が定まっていない。業務actor、実損の内容・規模、障害の構造原因はunknown。ここから推測して業務条件を追加しない。

P1は「失敗後に何を保証でき、どの判断が未決か識別する」という本依頼の目的。G1は既存conflict契約を保持すること、G2はfailure・retry・duplicate・回復の未決条件を観測と選択gateへ接続すること。品質QL1はこの成果物内のproject_definedな「失敗状態の判定可能性」。閾値・SLOは未指定。

意味の監査では、次を区別する。

- authorization成功は観測済みの出来事。現在も承認が有効、売上確定済み、資金移動済みという意味までは証明しない。
- DB save失敗は保存処理の失敗。未commitなのか、commit後の応答失敗なのか、部分保存なのかは未確認。失敗を「DBに何もない」と読み替えない。
- DB側の失敗からprovider側の承認取消を導けない。ローカルrollbackだけで全体の無副作用保証が成立するとはいえない。
- 同一key・異なるpayloadのconflictから、同一payload時の返却値、再実行可否、外部副作用回数は導けない。

反証・識別Evidenceはprovider結果と照会結果、保存処理のtransaction境界・commit結果、公開API仕様・key比較規則。ここまでで選択を左右する不足が判明するため、事業上の正しさを推測する前に抽象化を止める。

**Requirementとoperation**

| Requirement | 根拠・扱い | 観測可能な受入条件 |
|---|---|---|
| R1: 承認後の保存失敗を契約化する | raw_request、E1、E3、E4。未定義の業務保証を既成事実にしない | provider側・永続化側・公開応答・回復条件を分離し、未決は確認方法とgateへ接続する |
| R2: 同一key・異なるpayloadはconflict | E2、must-preserve | 既存仕様上の同一keyと異なるpayloadを用いた要求でconflictを観測する |

OP1は今回の決済承認と保存を含む操作のローカル名。caller、公開boundary名、contract owner、呼出前state、正常時の公開resultはU4で未確認。入力にkeyとpayloadがあることはE2に基づくが、形式・必須条件・比較方法はU5。side effectはE1のprovider authorization成功。failureはその後のDB save失敗。呼出前条件や正常成功条件を新設しない。

限定model監査では、用語・概念・制約・状態・遷移・振る舞い・関係・失敗・時間・writer・reader・authorityの12観点を確認した。E1で確認できるのは外部承認と保存失敗の順序、E2で確認できるのはkey/payload間の制約だけ。回復期限はU2、状態・遷移・context間の整合はU3、writer/readerとauthorityはU4、key意味はU5に残る。API、ORM、管理操作、batch、直接書込などの実経路は資料未提示で未監査。全経路を監査済みとは扱わない。

model obligation MO1: 外部承認状態と保存状態を独立に観測できる意味・writer/reader・authorityを確認する。MO2: 失敗後の回復遷移、期限、責任者を定義する。MO3: keyの一致、payloadの相違、再利用期間と同時実行時の意味を確認する。新たなsource of truthやsystem-wide authorityは選定しない。

**condition単位の契約**

| ID / kind | statementと適用状態 | level / authority_type / authoritative_owner | defensive validation・Evidence |
|---|---|---|---|
| CI1 / failure_guarantee | 同一key・異なるpayloadへの結果はconflict。required | api / contract_owner / unknown: U4 | unknown: U4。入口検査のみが唯一の保証か未確認。E2、confirmed |
| CI2 / failure_guarantee | 承認成功後の保存失敗で、provider側にどの状態を保証するか。unknown: U1、U3 | use_case / failure_recovery_owner / unknown: U2 | unknown: U4。E1、E3。保証statementの内容はunknown |
| CI3 / failure_guarantee | 同失敗後にDB上で保証する状態・識別可能性。unknown: U3 | repository / source_of_truth / unknown: U4 | unknown: U4。E1。保存失敗の観測だけでは最終stateを確定できない |
| CI4 / failure_guarantee | callerへ返す失敗resultと、そのresultが意味する処理完了範囲。unknown: U4 | api / contract_owner / unknown: U4 | unknown: U4。E1。公開error名やHTTP statusは未定義 |
| CI5 / prohibited_transition | 失敗後に許可・禁止する回復遷移と終端条件。unknown: U1、U2、U3 | workflow / state_authority / unknown: U2 | unknown: U4。E3、E4。void/refund/reconciliationを確定しない |
| CI6 / retry | 同一要求を再試行できる条件、期限、返却結果。unknown: U5 | workflow / failure_recovery_owner / unknown: U2 | unknown: U4。E1、E2。conflict契約から推定しない |
| CI7 / duplicate | 同一key・同一payloadの重複時の公開結果。unknown: U5 | api / contract_owner / unknown: U4 | unknown: U4。E2。既存結果の再返却と再処理のどちらも未選択 |
| CI8 / idempotency | 反復要求に対して維持すべき観測結果・副作用の範囲。unknown: U5 | unknown / unknown / unknown: U4 | unknown: U4。E1、E2。一般的な冪等性を既存契約へ追加しない |

全itemのoperation_idはOP1。CI1のrequirement_idsはR2、CI2〜CI8はR1。domain_obligation_idsはCI2〜CI5がMO1/MO2、CI1およびCI6〜CI8がMO3。

CI1は条件の必要性・文言がconfirmedでもauthoritative ownerが未確認。contract owner、永続化のsource of truth、回復のstate authorityを同一ownerにまとめない。CI2〜CI8は完成した保証ではなく、未決のcondition recordである。各unknownのrationale・確認方法・未解決影響は下のU1〜U5へ接続する。

OP1のidempotency_assessmentは `applicability: unknown`。外部副作用と既存keyがあるため適用検討は必要だが、E2は異なるpayloadのconflictのみを保証する。mechanismは新設しない。key_scope、key_lifetime、fingerprint_rule、同一payloadのduplicate_result、retry_ruleはU5。CI8をrequiredとして数えない。

**回復の選択gate**

| 候補ID | 候補 | 選択前に得るEvidence |
|---|---|---|
| CA1 | void | 現在のprovider状態、取消可能条件・期限、操作の失敗時意味、業務上の許容結果 |
| CA2 | refund | 現在のprovider状態、refund適用条件、実行結果と失敗時の扱い、業務上の許容結果 |
| CA3 | reconciliation | 照合できる事実、照合後の解消規則、未解消時の扱い、責任者・期限 |

これらはE3に挙がった未承認候補。providerが各操作を提供することも未確認。reconciliationと他候補を併用できるか、代替関係かも決めない。

```yaml
selection_gate:
  id: SG1
  subject: 承認後保存失敗の回復契約
  candidate_ids: [CA1, CA2, CA3]
  status: pending
  owner: unknown: U2
  decision_condition: 権限を持つownerが、状態別の許容結果、回復方式、責任者、期限、失敗時の次の扱いをEvidence付きで承認する
  evidence_required: [provider仕様と対象状態, 保存結果を識別するEvidence, 公開failure仕様, 回復責任の割当, 承認記録]
  evidence_acquisition: [U1, U2, U3, U4, U5]
  evidence: [E1, E3, E4]
```

gate通過まで、選択依存の保証・禁止遷移を確定しない。void/refundを実行しない。未決を理由に依頼された設計資料全体をblockedにはしない。

**unknownの取得計画**

| ID / subject | confirmation_method | impact_if_unresolved | owner / evidence |
|---|---|---|---|
| U1: 回復方式と許容される最終状態 | providerの該当操作仕様、承認後状態別の回復候補を集め、業務上の許容結果を権限あるownerが承認する | CI2・CI5、SG1の選択ができない。外部副作用の取消・補償を保証できない | unknown。まず意思決定権限者を確認する。E3 |
| U2: recovery owner、期限、権限 | 運用責任と承認責任を割り当て、検知から解消までの期限・超過時対応を承認記録へ残す | 未解消状態を誰がいつまでに扱うか保証できない | unknown。責任者が未確定という入力事実を維持。E4 |
| U3: failure後の外部状態と永続化状態 | providerの照会結果、transaction境界、commit成否、障害の発生位置を対象systemの根拠で確認する | CI2・CI3・CI5のoracleを確定できない。回復方式や再試行判断が変わる | unknown: 保存・外部連携の各責任者の指名が必要。E1 |
| U4: boundary、正常契約、condition owner、writer/reader、公開failure | 既存API仕様、実経路、error contract、権限表を取得し、各conditionの唯一のenforcement箇所と防御検査を分ける | CI1を含む契約全体の保証責務と互換性を評価できない | unknown: 公開契約・永続化・運用の担当者を個別に確認する。E1、E2、E5の提示範囲 |
| U5: key/payload比較、retry、duplicate、concurrency | 既存仕様・testからkey範囲と寿命、payload同値規則、同一要求と並行要求のresult・副作用を確認する | CI6〜CI8、CI1の境界test、二重副作用の防止範囲を定義できない | unknown: key意味と再実行契約の権限者を確認する。E1、E2 |

unknownはN/Aへ置換しない。明示的なrequired platformはない。OS固有のdomain条件を追加せず、platform検証を行ったとも主張しない。

**test仕様と未実行事項**

T1はCI1を検証する既存契約testの設計。`requirement_ids: [R2]`、`verifies: [CI1]`。

- Given: 既存仕様上同一と判定されるkeyについて、先行payloadが存在する。
- When: 同じkeyへ、既存仕様上異なるpayloadでOP1を要求する。
- Then / oracle: 公開結果としてconflictを観測する。成功や既存成功結果の無条件再返却は不合格。
- 実行条件: U4で実境界とconflict表現、U5で同一key・異なるpayloadの構成方法を確認した隔離環境。
- `implementation_status: planned`、`execution_status: not_run`。ownerはunknown: U4。外部副作用回数の追加保証はこのoracleに混ぜない。

以下は未決条件に対するtest obligation。完成したcontract testとしてcoverageへ数えない。

| ID | Given / When | 後で確定するoracle | 依存 |
|---|---|---|---|
| TO2 | provider成功後、特定した保存障害を発生させる | provider照会結果・永続化結果・公開resultが承認されたfailure契約と一致する | CI2・CI3・CI4、U1〜U4 |
| TO3 | 保存失敗後に回復操作を要求し、回復処理自体の失敗も注入する | 承認された遷移と終端条件、責任者への移管・期限条件を満たす | CI5、U1〜U4 |
| TO4 | 保存失敗後、同一key・同一payloadを再試行・重複送信・並行送信する | 承認されたretry/duplicate/result/副作用規則と一致する | CI6〜CI8、U5 |

TO2〜TO4も未実装・未実行。実runnerは対象systemの隔離環境とprovider test doubleまたは承認されたsandboxが必要。対象code、runner、実行commandが提示されていないためcommandはunknown。取得はU4のowner指名後に行う。実在しないtest commandや成功結果を記載しない。

**traceとcoverage**

| 接続 | 根拠・必要性 | 検証先 | 状態 |
|---|---|---|---|
| P1 → G1 → R2 → OP1/CI1 → T1 | E2を失敗処理変更で失わないため、公開conflictを観測する | T1 | partial: owner未確認 |
| P1 → G2 → R1 → MO1/MO2 → OP1/CI2〜CI5 | E1の部分失敗に対し、状態と回復の未決を明示する必要がある | TO2、TO3、SG1 | partial |
| R1 → MO3 → OP1/CI6〜CI8 | E1の後に再実行された場合の意味を、E2だけから推定しないため | TO4、U5 | partial |

- requirement coverage: **1 / 2**。分母R1、R2。分子R2はrequired CI1とoracle付きT1へ接続済み。未coverageはR1。
- contract coverage: **0 / 1**。分母はrequired CI1。authoritative ownerがunknownのため分子に入らない。incomplete_item_ids: `[CI1]`。
- test設計coverage: **1 / 1**。分母はrequired CI1、分子はT1へ接続したCI1。実行coverageを意味しない。
- unknown_item_ids: `[CI2, CI3, CI4, CI5, CI6, CI7, CI8]`。分母から分離するがreadyな実装契約とは判定しない。
- test実行数: **0**。test合格Evidenceなし。

拒否条件は、conflictを成功へ変更する、save失敗を外部承認取消と同一視する、未承認で補償方式・期限を決める、unknownをN/Aにする、test planを実行済みとする、対象systemを変更すること。

現在は既存契約変更を確定していないためmigrationは要求しない。failureの公開意味を新設・変更すると判明した場合は、U4の既存契約との差分に基づきapproval、compatibility、必要なmigration、rollback/recoveryを追加する。変更があるか未確認の段階でmigration対象を発明しない。

AI restatement: E1の部分失敗を可視化し、E2を保持して、E3/E4に依存する選択をSG1へ隔離する。比較根拠はR1/R2とE1〜E5。`proposed_status: matched`、差分なし。`reviewed_by.kind: unresolved`、`review_status: unresolved`。自己比較を人間・独立評価の確認済みEvidenceに数えない。

```yaml
decision:
  status: pass
  artifact_readiness: ready
  engineering_status: planned
  release_status: not_applicable
  decision_maturity:
    status: proposed
    owner: unknown: U2/U4
    scope: [条件付き契約設計]
    evidence_status: confirmed
    approval_evidence: []
    baseline_version: unknown
    change_control: unknown
  next_phase:
    name: failure契約の確定と実装
    status: blocked
    reasons: [SG1 pending, U1〜U5 unresolved, condition owner未確認, 独立review未確認, 対象systemの変更は依頼範囲外]
    human_approvals_required: [回復方式と許容最終状態, recovery ownerと期限, 公開契約とcondition authority]
  evidence: [E1, E2, E3, E4, E5]
  assumptions: [資料内の名称とローカルIDのみ]
  unknowns: [U1, U2, U3, U4, U5]
  contradictions: []
  failed_gates: []
  unexecuted_validation:
    - id: UV1
      reason: design依頼で対象systemとrunnerが提示されていない
      required_runner: 対象systemの隔離環境とprovider test doubleまたは承認されたsandbox
      planned_commands: [unknown: U4でrunner特定後に確定]
      owner: unknown: U4
      evidence: [T1, TO2, TO3, TO4, E5]
  platform_validation:
    required_platforms: []
    executed: []
    unexecuted: []
    parity_result: not_applicable
    platform_specific_risks: []
  residual_risks: [実装契約は未確定, 保存後state未確認, 再実行時の副作用範囲未確認, 回復責任と期限未確定]
  human_approvals_required: []
```

このpassは、未決の選択を隔離した設計資料に対する判定。契約の充足、実装の正しさ、運用回復、releaseの承認を示さない。

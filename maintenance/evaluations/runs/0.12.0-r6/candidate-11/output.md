# 決済承認後の保存失敗の契約案

mode: `design`。対象は「provider authorization成功後、DB saveが失敗する」経路。対象systemへの変更・外部操作・test実行は行わない。説明用のoperation名を`決済承認の記録`とする。

条件付き設計の成果物は`ready`。対象契約の十分性は`indeterminate`。復旧方式、失敗後の保証、保証責任が重要未確認であり、それらに依存する実装は停止する。契約の採用・releaseは未判定。

## 根拠と維持範囲

| ID | 内容 | Evidence |
|---|---|---|
| E-01 | provider authorization成功後にDB saveが失敗する | 入力のconfirmed_evidence。`confirmed`な観測であり、望ましい失敗保証の承認ではない |
| E-02 | 同一key・異なるpayloadはconflict | 入力のconfirmed_evidence。`confirmed`な既存契約 |
| E-03 | void / refund / reconciliationの選択は未承認 | 入力のknown_unknowns |
| E-04 | recovery ownerと期限は未確定 | 入力のknown_unknowns |

- `must-preserve`: E-02のconflict。payloadの同一性判定、keyの有効範囲、保持期間、HTTP status、追加副作用の有無まで承認済みとは扱わない。
- `intentional-change`: 確定なし。
- `unknown`: 保存失敗時の公開結果、domain / persisted state、外部状態、再試行、復旧責任と期限。

## 意味照合

理解statement: 「承認成功」という外部での観測と「保存成功」を別に扱う。保存失敗から、承認の取消済み、返金済み、DB未変更、再試行安全、決済全体の成功または失敗確定は導けない。

比較根拠はE-01〜E-04。新しい金銭処理・公開応答の意味は`proposed`にも確定させず、下のunknownとして隔離する。既存conflictの意味差分は加えない。外部状態と内部状態をどう整合させるかは新しい意味決定になる。

`accepted`な意味review、その主体・根拠は未提供。権限ある決済業務ownerによる選択・承認と、公開契約ownerによる応答・再試行の意味照合を取得する。実担当者はいずれも未特定。現在の設計作成は進め、依存する選択・実装は進めない。

## 条件台帳

各CIは現在成果物内のローカルID。公開operation全体の`contract_owner`は未確認。各conditionの`authoritative owner`と、障害を処理する`recovery owner`は別の責務として確認する。以下の確認先は役割候補であり、保証責任を割り当てた事実ではない。

| CI | 分類 / 判定 | 観測可能なstatementまたは未決事項 | level / authority / authoritative owner | 根拠・確認先 |
|---|---|---|---|---|
| CI-01 | failure_guarantee / required | 同一keyで異なるpayloadを指定した呼出しはconflictとなる | 公開operation / 既存契約E-02 / 一意の保証ownerは未確認 | E-02。公開契約ownerへ現行仕様と保証実装を確認 |
| CI-02 | failure_guarantee / unknown | 保存失敗後、呼出元へ何を返すか。確定失敗・未確定などの意味とwire表現 | 公開operation / 未決 / 未決 | E-01。公開契約ownerと決済業務ownerへ確認 |
| CI-03 | failure_guarantee / unknown | 保存失敗後に、どのdomain / persisted stateが残ることを保証するか | domain・永続化 / 未決 / 未決 | E-01。保存境界を所有する担当へcommit・rollbackのEvidenceを確認 |
| CI-04 | failure_guarantee / unknown | 保存失敗後のprovider側状態について何を保証するか | 外部副作用 / 未決 / 未決 | E-01、E-03。provider連携担当と決済業務ownerへ確認 |
| CI-05 | failure_guarantee / unknown | 同一key・同一payloadの再試行・重複呼出しがどの結果を返すか | 公開operation / 未決 / 未決 | E-02は異なるpayloadだけを規定。公開契約ownerへ確認 |
| CI-06 | invariant / unknown | 並行呼出しを含め、同一keyに対して何が常時一意であるべきか | 永続化・外部副作用 / 未決 / 未決 | E-02から一意性対象や二重承認防止を補完しない。公開契約ownerへ確認 |
| CI-07 | environment / unknown | authorization / saveのtimeoutや応答喪失時、結果を判別できる条件 | provider・DB境界 / 未決 / 未決 | E-01には確定判別方法がない。provider連携担当・保存担当へ確認 |
| CI-08 | failure_guarantee / unknown | 復旧を開始・完了したと判定する条件 | 復旧operation / 未決 / 未決 | E-03、E-04。決済業務ownerへ方式と完了条件を確認 |
| CI-09 | failure_guarantee / unknown | 復旧をいつまでに完了するか、期限超過時に何を保証するか | 復旧operation / 未決 / 未決 | E-04。運用責任者と決済業務ownerへ確認 |
| CI-10 | pre / unknown | 呼出し可能な状態と入力条件 | caller境界 / 未決 / 未決 | 正常入力・認可仕様は未提供。公開契約ownerへ既存仕様を確認 |
| CI-11 | post / unknown | operation成功時に外部状態と保存状態の何を保証するか | 公開operation / 未決 / 未決 | authorization成功をoperation成功へ読み替えない。公開契約ownerへ確認 |

CI-01のstatementは確定できるが、authoritative ownerが未特定のため定義充足とはしない。無効入力に対する既存の公開応答CI-01を、callerのpreだけへ移さない。CI-10で判明する追加の無効入力も、公開失敗応答が必要か個別に判定する。

## 失敗後状態とoperation assessment

E-01から確定できるのは、authorization成功が観測された履歴と、DB save失敗が観測されたことまで。DB save失敗が「commit前の失敗」「rollback確認済み」「結果不明」のどれかは未確認。DB未変更やprovider側取消をfailure guaranteeへ記入しない。

| 論点 | 現在の判定 | 契約を確定するための識別条件 |
|---|---|---|
| 外部成功 / 内部失敗 | 対象経路。CI-02〜04はunknown | providerの現在状態と、保存結果を確認できるEvidence |
| business / technical failure | save失敗の原因分類はunknown | DBエラー分類と既存domain failure定義。business rejectionへ勝手に変換しない |
| retry / duplicate / idempotency | CI-05、06はunknown | 同一payloadの結果再利用、外部再呼出し、重複検出の正本と保持範囲 |
| 同一key・異なるpayload | CI-01を維持 | conflictを判定する既存payload比較規則と適用範囲 |
| 順序逆転・並行更新 | unknown | 実際のoperation順序と競合時の確定規則。E-01以外の順序は断定しない |
| cancel | unknown | authorization後にcancelが可能か、保存・復旧と競合した際の意味 |
| timeout・曖昧結果 | CI-07はunknown | 応答喪失と確定失敗を区別する手段、その結果が取得不能な場合の扱い |

idempotency keyが存在する根拠はE-02にある。ただし、DB保存が失敗した経路でもそのkeyを参照できるか、provider側にも同じ重複抑止があるかは未確認。新規のkey生成、保存先、outbox、補償処理などのmechanismは確定しない。

## 復旧選択gate

候補の列挙は採用を意味しない。確認ownerの役割候補は決済業務owner、provider連携担当、運用責任者。実担当の特定を含めて確認する。

| 未承認の候補 | 採用判断に必要なEvidence | 未解決時の影響 |
|---|---|---|
| void | 対象状態でproviderが受理する条件、成功・失敗・曖昧結果の意味、業務側が求める最終状態 | 取消可能・取消済みとは保証できない |
| refund | 対象状態でproviderが受理する条件、金銭上の意味、業務側の採用承認 | 保存失敗だけを理由に返金を開始できない |
| reconciliation | 照合の正本、識別方法、不一致時の意思決定と完了条件 | 整合済み・復旧完了とは保証できない |

共通gateは、選択方式の承認、CI-02〜09の確定、一意のrecovery owner、期限と期限超過時の扱い、意味reviewのaccepted Evidence。三候補の優先順や併用可否も未承認。期限の具体値、再試行回数、金額条件は補完しない。

## 契約test設計

`status: planned`、`execution: not_run`。以下は実行コードではなく現在成果物内のtest設計。

| Test | verifies | 入力・前提 | oracle |
|---|---|---|---|
| CT-01 | CI-01 | 既存契約上の同一key・異なるpayloadに該当する2要求を、既存の適用条件下で与える | 後続要求の公開結果がconflict。成功や同一結果の返却なら失敗 |

CT-01はpayload比較規則と既存の適用条件が入手できてからfixtureを具体化する。conflict時のprovider呼出し回数、HTTP status、DB状態はE-02にないためoracleへ追加しない。

未確定CIに対するtestは実在するrequired CIの`verifies`へ接続できない。次の検証obligationを残し、承認後にtestとoracleを作る。

- O-01: CI-02〜04がrequiredになったら、authorization成功後に保存失敗を注入し、公開結果・内部状態・外部状態を承認済みの各保証と照合する。commit前後を区別できるfailure injectionを用意する。
- O-02: CI-05、06がrequiredになったら、同一payloadの逐次retryと並行duplicateを与え、承認済みの結果・副作用・一意性を照合する。保存失敗直後のretryも含める。
- O-03: CI-07〜09がrequiredになったら、timeout、応答喪失、復旧失敗・重複実行を与え、未確定結果と確定結果、復旧完了と未完了を識別する。期限値が決まった後に直前・一致・直後を検証する。
- O-04: CI-10、11とcancel・順序の意味が決まったら、許可状態と禁止遷移、成功時保証を検証する。境界値は既存仕様から取得し、創作しない。

## Coverageと次phase

- 要件screening: 入力の4項目、4/4を台帳と復旧gateへ接続した。これは契約充足率ではない。
- required CI定義充足: 0/1。CI-01は一意のauthoritative owner未確認。
- required CIのoracle付きtest設計coverage: 1/1（CT-01）。具体fixtureは未確定。unknown CI-02〜11の10件をこの値で覆ったとはしない。
- test実行: CT-01は0/1実行、成功Evidenceなし。design依頼で対象code・test runnerも未提供のため`not_run`。
- required platforms: 入力は空。platformごとの実行Evidenceなし。0/0を成功率として表示しない。回答記録の保存は対象systemのplatform検証ではない。

次phaseでは、公開契約ownerが既存のkey / payload契約とCI-01の保証ownerを提示し、保存担当とprovider連携担当が失敗分類・状態確認のEvidenceを提供する。その上で権限ある決済業務ownerが復旧方式を採用し、運用責任者が担当と期限を確定する。確認先は役割候補であり、実担当者は未特定のまま残す。

実装・test実行へ進む場合の必要runnerは対象systemの既存契約test環境、DBの失敗注入手段、providerの非本番検証手段。repositoryとrunnerが未提供のため実行commandは未確定。公開契約ownerが実行担当を指定し、承認済みCIからoracleを固定して実行する。

残存riskは、外部承認と内部記録の不一致をいつ誰が収束させるか不明なこと、再試行が安全か不明なこと、失敗の公開結果が未決なこと。現在の条件付き設計は完成しているが、これらを保証済みとして対象実装を進めない。

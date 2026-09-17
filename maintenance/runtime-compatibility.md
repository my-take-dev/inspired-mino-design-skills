# Runtime compatibility

API requestまたはharness自体を変更するときだけ使う。通常の設計SkillにはAPI clientは不要である。特定モデルの識別子やparameter制約を固定で埋め込まず、現在の対象runtimeで確認できた能力と仕様を根拠に変更する。API request schemaとharnessの設定schemaは別契約であり、同名に見える項目も無検証で転記しない。

## Capability boundary

- 対象のAPIまたはharness、version、既存設定、実効設定、変更scope、実行権限を確認する。認証情報そのものを成果物へ複製しない。
- モデルの選択は呼出し側または実行環境の責務とする。このsuiteの文面からmodel識別子を組み立てたり、別のmodelを選んだと仮定したりしない。
- endpoint、tool calling、思考量、sampling、log probabilities、processing tier、data residencyの対応は対象ごとに判断する。別環境の制約をそのまま一般化しない。
- 動的な思考量変更、非同期tool、cache、並列委譲は、それぞれ利用harnessに実装・公開された場合だけ使う。API仕様の対応と、今回使えるtool・設定面の対応を別々に確認する。本suiteはこれらのadapterを実装していない。
- 通常の設計作業で外部仕様を読むことを必須にしない。API互換性そのものが今回の依頼なら、利用可能な確認手段で対象versionの仕様・設定schemaを確認し、確認結果を作業artifactのEvidenceへ保存する。確認できない変更だけを保留し、完成できる比較・設計は返す。

## Request migration

1. 現在成功しているrequestと実効設定をbaselineへ残す。model・endpoint移行と検証なしの思考量削減を同時に行って原因を混ぜない。
2. 変更候補を、対象runtimeでsupported、unsupported、unknownに分け、判断を支える仕様・schema・実行Evidenceを付ける。
3. 確認済みunsupported項目だけを削除・置換し、supportedな既存項目と業務入力を保持する。項目名だけを見て一律に削除しない。unknownをsupportedにもunsupportedにも丸めない。
4. 思考量を移行するときは、対応する値と実効設定を確認する。既存値が使用できない場合だけ、目的と検証計画を示して対応する候補へ移す。一般的なlow / medium / highという説明を、無条件に送信可能な設定値とは扱わない。
5. processing tierやdata residencyは対象region・endpoint・契約の確認結果へ従う。速度や価格のために未確認の地域制約を越えない。
6. APIで非同期toolを採用する場合、元のcall IDを保持して結果を対応付け、実行・待機・cancelをapplication側で所有する。待機中は独立した作業だけを進める。tool結果は実際のcall ID、対象revision、pending / completed / failed等の状態へ対応付ける。古い結果・timeout・未完了を成功として採用しない。非同期機能がなければ同期で処理する。

対応した設定更新機構を使うときは、その有効期間、既存prefix/cacheへの影響、復元方法を確認する。request-level設定の書換えを同等と推定しない。未確認なら現在設定で作業を続ける。

## Verification

requestの静的検査、mock、実API smokeを別Evidenceにする。認証・予算・許可のない実API実行をせず、未実行は必要runner・command・理由・ownerをcanonical unexecuted recordへ残す。

設定変更用toolがなければ差分案にとどめる。Skill文書の読取だけでAPI互換、model切替、思考量変更、非同期処理の成功を報告しない。実際の検証runでは再現に必要なmodel・実効設定をrunnerの記録へ残すが、この配布suiteの文章やdefault promptには特定のモデル名を固定しない。

# Requirements and traceability

## Catalog and ownership

非機械的な設計・実装・reviewで、自然言語の要求を独立に合否判定できる単位へ分ける。

曖昧な形容詞を観測可能な成功/拒否条件へ変換する。quality_constraint_idsはCoreの実在quality IDを参照し、分類語と目標数値を混ぜない。現行挙動はmust-preserve/intentional-change/unknownへ分け、既存codeを無条件に仕様としない。

| Authority | 意味 |
|---|---|
| semantic_owner | contextで用語・意味を定義する責任 |
| invariant_owner | modelの制約を守る責任 |
| contract_owner | 公開操作と互換性の責任 |
| state_authority | 状態遷移を許可する責任 |
| source_of_truth | authoritativeな状態の正本 |
| transition_owner | 移行中のauthority管理 |
| failure_recovery_owner | 曖昧結果・補償・復旧方針 |
| operational_owner | 検知・照合・復旧運用 |

writer/readerはアクセス経路でありauthority種別と同一ではない。同じsubjectとauthority種別の正本を一意にする。authority種別が違えば同じoperation内でも別ownerになり得る。

## Identity and downstream obligations

local IDは各artifact内で一意にする。別artifact間は`artifact_handle#local_id`で参照する。contractのT1とarchitectureのT1を文字列一致だけで同一視しない。handleには対象revisionを結び付け、同名artifactの古い結果を参照しない。

上流Functionが作れるのは自身のmodel IDやobligation IDである。将来作るcontract/testのIDを先取りしない。ContractがCI/T IDを発行した後にrouterがobligationとの接続を確定する。

| Scope | IDを発行する責任 |
|---|---|
| 問題・要件・未決 | Core/Framingの依頼成果物 |
| model・access path・gap・obligation | Completeness |
| condition・contract test | Contract |
| consumer操作・漏出・変更scenario | Boundary |
| option・target・transition・品質検証 | Architecture |
| package handle・統合edge・最終検証 | Router |

参照が未解決ならpartial/missingとし、名前の意味が似ているだけでcoveredにしない。

## Trace and coverage

各edgeに前段が後段を必要とする根拠と反証方法を残す。単にIDを並べたinventoryをtraceと呼ばない。専門Functionは固有成果物までを所有し、不要な後続成果物を充足のために作らない。

coverageは対象集合、除外と理由、分母、分子、未coverage IDを示す。未知を除外して100%を作らない。0件はN/Aの根拠を示し、0/0を100%と表現しない。screening、設計上のcoverage、実行成功のcoverageは別値である。

## Rejection criteria and gate

実装前に問題の取り違え、不正状態、契約/失敗/品質の欠落、技術漏出、scope外変更を拒否条件へ落とす。AIが作成した条件はproposedであり、承認Evidenceなしにfrozenにしない。

designではtest ID、oracle、実行条件、ownerのあるplanを成果物にできるが、実行済みとはしない。未知に依存する実装は止め、条件付きdesign/reviewの完成と分離する。schema欄を埋めただけでcoveredやverifiedにしない。

正本packageを作る場合だけ`skills/mino-core/schemas/requirements.md`を読み、要件・trace・拒否条件を保存する。

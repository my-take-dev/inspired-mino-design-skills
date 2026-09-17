---
name: mino-domain-model-completeness
description: 固定したユースケースで用語・概念・値制約・状態・遷移・失敗・時間・writer/reader・authorityの欠落を監査するときに使う。世界全体のモデル化、図だけ、一般DDD解説、単なるデータ項目一覧には使わない。
---

# Domain Model Completeness

## Outcome Contract

固定したuse caseの要件・model・経路の欠落と、契約・testへ渡すobligationを返す。screeningとmodelの実在coverageを分ける。
正本packageのrootは`completeness_package`。
対応mode: design, review。

## Reference Routing

- 初回は`skills/mino-core/references/shared-policies.md`を読み、Evidence・承認・判定を適用する。同じcontextで既読なら再読しない。通常の判断は本体とこの共通規則で行う。
- 用語・context・暗黙概念の欠落が判断を分けるときは`skills/mino-core/references/domain-discovery.md`を読み、同じ例で意味差を検証する。
- 対象systemのfile/process/test実行・複数OS要件がある場合は`skills/mino-core/references/platform-compatibility.md`を読み、host・対象・検証層を分ける。単なる回答記録の保存では追加読込しない。
- 正本packageの作成・更新・引継ぎを依頼された場合だけ`skills/mino-domain-model-completeness/schemas/package.md`を読み、必須fieldと実在参照を保持する。

## Workflow

1. actor、use case、context、要件、対象外を固定する。DB項目や既存名詞だけで必要概念を決めない。
2. 各要件のterm_context、concept、constraint、state、transition、behavior、relationship、failure、time、writer、reader、authorityの12観点を一度ずつscreenする。各cellをEvidence付きmodel elementへのlinkか理由付きN/Aにする。同じ理由・EvidenceのN/Aだけprofileを共有できる。
3. 必要だがない要素はmissing、未確認はunknown、矛盾はconflictingとして区別する。要件に定義があることと、対象modelに実在・保証されることを分ける。presentには監査対象の定義・code・観測へのEvidenceを要し、要求だけを根拠に充足へ数えない。未知はN/Aにしない。concept_kindはconceptだけに使う。
4. constructor/setter、serializer、永続化、API/event、batch/admin、import、migration、手作業を探索候補として、scopeへ到達するwriter / readerを追う。実在経路と未探索領域を分け、提供資料にない経路の存在・不在を捏造しない。
5. 意味のowner、不変条件のowner、状態遷移のauthority、状態の正本を区別する。各writerの迂回、readerの誤解釈、UI/adapterへの業務規則の漏出、関係ごとの失敗意味を確認する。system全体の選定は参照・obligationにとどめる。移行中の複数writerは期間・競合規則・照合・削除条件・ownerを要する。
6. 思考実験か使い捨てfixtureでentry→破壊入力・順序→伝播→業務影響→期待不変条件を追う。境界値、null、禁止組合せ、遷移skip/逆行、並行writer、stale reader、外部成功/内部失敗から該当する反例を選ぶ。観測結果と防御を独立判定する。
7. 必要な契約・testにはそれぞれCO / TO obligationを付ける。下流が未作成ならCI / T IDを発行せず、実在する場合だけ接続する。
8. screen分母=要件数×12、分子=根拠付きlink/N/Aで処遇を記録したcell数。未知もunknownなmodel elementへ接続し、何が未確認かを根拠付きで記録すればscreen済みに数える。model分母=N/A以外のcell数、分子=必要elementが全てpresentかつunknown/contradictionでないEvidenceを持つcell数。missing/unknown/conflictingをpresentへ数えない。

## Hard Gates

- 表が埋まったことをmodel completeとしない。未確認writer・readerや迂回経路を監査済みにしない。
- 本番dataへ破壊probeを行わない。未実行はnot_executedでありpreventedではない。必要なprobeは契約とtest両方のobligationへ接続する。
- 対象code・運用dataは変更しない。修正依頼は権限を保った引継ぎにする。

## Completion

固定scopeの必要modelと経路が根拠付きで揃えばcomplete、既知gapがあればincomplete、重要未確認で判断できなければindeterminate。既知gapと未知の併存はincompleteとして両方を返す。監査artifactは欠陥を報告してreadyになり得る。

---
name: mino-domain-model-completeness
description: 対象ユースケースに必要な業務用語・context・概念・値制約・状態・遷移・振る舞い・失敗・writer/readerの欠落と誤配置を監査するときに使う。現実全体のモデル化、図だけ、一般DDD解説には使わない。
---

# Domain Model Completeness

固定したuse-case scopeで正しい判断と状態維持に必要な意味が欠落せず、適切なownerへ置かれているかを監査する。DDD patternの数ではなく、要件coverage、不正状態、rule leakage、access pathで判定する。

## Outcome Contract

主成果物として`Completeness Package`を作る。通常は次の最小構成を返し、12 dimensionの詳細schemaはworkflow referenceへ置く。

- scope、actor、context、use case、requirement ID
- applicableなterminology / concept / constraint / state / transition / behavior / relationship / failure / time
- writer / readerのaccess path、invalid construction、model外rule、authority conflict
- scope-localなsemantic owner、invariant owner、state authority、source of truthの監査と、そのEvidence
- requirementごとのmodel coverage、gap、contract / test obligation
- 既存のdownstream成果物が入力にある場合だけ、その実在IDへのlink
- `subject_verdict: complete | incomplete | indeterminate`とcanonical `decision`
- platform差がwriter、reader、representation、failureを分岐させる場合だけ、Platform Contextとvalidation matrix

`subject_verdict`は固定したscope内の監査対象を表す。対象が`incomplete`でも監査artifact自体は`ready`になり得る。未作成のcontract IDやtest IDを予測しない。

## Reference Routing

- 内部pathは、配置先にかかわらず、インストールされた`skills/` directoryを参照rootとして解決する。
- 最初に`skills/mino-core/references/core.md`、`skills/mino-core/references/shared-policies.md`、`skills/mino-core/references/requirements-and-traceability.md`を読み、共通gateを再定義しない。
- inventory、writer / reader、gap、coverage、verdictでは`skills/mino-domain-model-completeness/references/workflow.md`を読む。
- terminology、bounded context、暗黙conceptの発見が必要なときだけ`skills/mino-core/references/domain-discovery.md`を読む。
- filesystem、process、path、encodingがaccess pathを変えるときだけ`skills/mino-core/references/platform-compatibility.md`を読む。
- standalone依頼が契約化、boundary設計、実装まで求める場合は、必要範囲に応じて`$mino-design-by-contract`、`$mino-interface-implementation-separation`、または`$mino-reproducible-development`へ一度hand offする。
- routerまたはpeer Skillからscoped artifactを依頼された場合は再routingせず、Completeness Packageと未解決obligationだけをcallerへ返す。
- 12 dimensionは公開資料の固定定義ではなくsuite operationalizationとして扱う。

## Authority Boundary

- このSkillが所有するのは、固定したuse-case / model scope内の意味、invariant、state change、writer / reader、既存source of truthの監査である。
- system-wideなdata authority、target architecture、transition中の複数writerを新たに決定しない。入力にArchitecture Strategy PackageがあればそのIDを参照し、なければsystem-wide decision obligationとして返す。
- contract conditionのauthoritative enforcementやconsumer operation boundaryを二重に確定しない。

## Workflow

1. actor、context、use case、success / failure、in / out-of-scopeを固定し、Evidence状態とdecision maturityを記録する。
2. 必要ならterm ledger、context boundary、invisible conceptを発見する。
3. requirementごとに12 dimensionのapplicabilityをscreeningし、結果を分岐させる観点だけを詳細化する。
4. code、schema、API、event、test、operationからwriter / readerの全access pathを追跡する。
5. scope-localなsemantic owner、invariant owner、state authority、source of truthを区別し、system-wide authorityとの整合を確認する。
6. primitive、nullable、flag combination、unvalidated construction、model外ruleを監査する。
7. 思考実験または使い捨てfixtureでdestruction probeを行い、entryから業務影響まで追跡する。
8. model coverageとgapを計算し、必要なcontract / test obligationを作る。
9. 対象の`subject_verdict`と、監査artifactのcanonical readiness、次phaseの可否を分けて返す。

## Platform Compatibility

- path separator、case sensitivity、line ending、permissionをdomain conceptと混同せず、representationまたはenvironment constraintとして扱う。
- file import、watcher、process連携等でOS差がstateやfailureを変える場合だけ、platform別writer / reader / failureをinventoryへ含める。
- 複数platform対応がrequiredなら、一部platformでのみ到達できるinvalid stateやalternate writerを未監査のままpassにしない。

## Hard Gates

以下のいずれかに該当する場合は`subject_verdict: complete`にせず、gap、確認方法、影響を返す。

- scopeが未定義、またはworld全体を対象にしている。
- 業務用語、state、ruleを一般知識で補完している。
- migration、serializer、ORM、admin、fixture等のalternate writerを無視している。
- required platformのwriter / readerを未監査のまま完全性をpassにしている。
- targetのauthority conflict、invalid construction、model外ruleを残している。
- matrixを空欄、根拠のないN/A、重複profile、未解決IDで埋めている。
- missing behavior / relationship / time / writer / readerを汎用gapへ潰す、またはEvidence不足を`present`や既知severityへ丸めている。
- term / context / translation / relationshipのcanonical ID参照が未解決または改名fieldへ圧縮され、applicableなrelationshipのretry、duplicate、ambiguous outcome、failure owner、unknownの確認方法・影響が欠けている。
- 未作成のcontract / test IDでtraceabilityを偽装している。
- 対象が`incomplete`であることを、完遂した監査artifactの`blocked`と自動的に同一視している。
- 本番dataへdestruction probeを実行している。

## Completion

- 全requirementで12 dimensionのapplicabilityがscreeningされ、applicableな観点はEvidence付きmodel elementへ、非該当は根拠付きprofileへ一度だけ接続される。
- writer / reader access pathとmodel-localなauthority種別が明示され、system-wide authorityとの関係が参照またはobligationとして残る。
- missing model elementはcontract / test obligationへ変換され、未作成IDで偽装されない。
- term、context、ambiguous meaning、translationのcanonical ID参照が解決し、reference integrityを保つ。
- applicableなcontext relationshipはupstream / downstream context、fact owner、integration、consistency、retry、duplicate、ambiguous outcome、failure ownerをEvidence付きで持ち、unknownには確認方法と影響がある。
- invalid stateを公開writerから生成できないか、gapとして報告される。
- discoveryがapplicableならcanonical Domain Discovery Packageを保持し、非適用またはunknownには理由、確認方法、影響、Evidenceがある。
- platform要件がある場合、Windows / Linux / macOS固有のrepresentation、writer、reader、failureを監査済みまたは未実行として分ける。
- `subject_verdict`、unknown、scope外、未実行検証を隠さず、canonical artifact readinessと分離する。

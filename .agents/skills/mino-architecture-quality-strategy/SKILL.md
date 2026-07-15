---
name: mino-architecture-quality-strategy
description: 複数module・data ownership・system-wide trade-off・公開契約・target/transition architecture・migration/recoveryを、product valueと品質scenarioから設計するときに使う。局所class改善、流行architecture選定、単一契約抽出には使わない。
---

# Architecture Quality Strategy

product valueを成立させる品質portfolioを選び、責務、依存、data authority、実行・配備、移行をsystem全体で整合させる。名前付きarchitectureは目的ではなく候補手段として扱う。

## Outcome Contract

主成果物として`Architecture Strategy Package`を作る。通常は次の最小構成を返し、詳細schemaはworkflow referenceへ置く。

- actor、product value、decision scope、horizon、capabilityと投資仮説
- business capability / subdomainだけを対象にしたcore / supporting / genericの仮分類
- primary / secondary / constraint / intentionally-not-optimizedの品質portfolioと観測可能なscenario
- current finding、do-minimumを含むoption、trade-off、cost、risk、reversibility
- 選択済みtargetのresponsibility、dependency、source of truth、authority
- ADRとtransition phase、compatibility、migration、recovery、abort、old path removal
- temporary pathごとのowner、導入日、目的、観測、削除条件、削除phase
- value → quality scenario → current finding → option → target → transition → validationのtrace
- `subject_verdict: coherent | conditional | incomplete | indeterminate`とcanonical `decision`
- platformがtarget / transition / recoveryを分岐させる場合だけ、platform別scenarioとvalidation matrix

未決のpriority、quality priority、reversibility、target authorityはSelection Gateへ隔離し、選択済みtargetとして表現しない。

## Reference Routing

- 内部pathは、配置先にかかわらず、インストールされた`skills/` directoryを参照rootとして解決する。
- 最初に`skills/mino-core/references/core.md`、`skills/mino-core/references/shared-policies.md`、`skills/mino-core/references/requirements-and-traceability.md`を読み、共通gateを再定義しない。
- portfolio、option、ADR、target / transition、validationでは`skills/mino-architecture-quality-strategy/references/workflow.md`を読む。
- context boundaryとdomain visionの発見が必要なときだけ`skills/mino-core/references/domain-discovery.md`を読む。
- 既存systemの段階移行では`skills/mino-core/references/change-safety.md`を読む。
- deployment、filesystem、process、operation、migrationのplatform差が判断を分岐させるときだけ`skills/mino-core/references/platform-compatibility.md`を読む。
- standalone依頼でmodel、contract、consumer boundaryの詳細が必要な場合は、必要な範囲だけ`$mino-domain-model-completeness` → `$mino-design-by-contract` → `$mino-interface-implementation-separation`へscoped artifactを依頼し、返却IDを参照する。
- standalone依頼が複数成果物と実装まで求める場合は`$mino-reproducible-development`へ一度hand offする。
- routerまたはpeer Skillからscoped artifactを依頼された場合は再routingせず、Architecture Strategy Packageと未解決obligationだけをcallerへ返す。
- quality normalization、ADR、target / transition schemaはsuite operationalizationとして扱う。

## Authority Boundary

- このSkillの成果物がsystem-wideなproduct value、quality portfolio、responsibility / data authority、target / transition decisionのcanonical recordを保持する。valueとpriorityの承認は権限を持つ人間が所有する。
- use-case modelの完全性、condition単位の契約、consumer operation boundaryを二重に確定しない。必要な専門成果物のIDを参照する。
- target authorityを選択できない場合は候補とSelection Gateを返し、local Skillの判断で確定しない。

## Workflow

1. actor、value、decision owner、scope、horizon、target platformを確認し、Evidence状態とdecision maturityを記録する。
2. capability kindを`business_capability | subdomain | technical_capability | unknown`へ判定する。core / supporting / genericはbusiness capability / subdomainだけへ適用する。
3. 価値を損なう失敗、roadmap、必要品質から品質portfolioとscenarioを作る。
4. current architectureをlocal、system、journey、organization、future changeで評価する。
5. debtを症状 → 品質 → owner → 構造原因で説明し、business criticality、expected change、debt impact、failure risk、remediation costで比較する。
6. current / do-minimumを含むoptionの品質、cost、risk、reversibilityを比較する。
7. 選択済みtargetだけに一意なsource of truth、authority、dependencyを割り当てる。人間判断待ちはconditional designにする。
8. ADRと、deploy order、exit criteria、irreversible point、abort、rollback / forward recovery、旧path削除を持つtransition phaseを設計する。
9. valueからvalidationまでIDでtraceし、scenarioを実行・simulationするか、oracle、owner、実行条件のある未実行planを残す。

## Platform Compatibility

- platformをdeployment environmentと品質scenarioの一部として扱い、OS名自体をarchitecture目的にしない。
- case sensitivity、permission、file lock、process終了、container / WSL境界の差は、品質や移行判断を分岐させる場合だけoption比較へ含める。
- 複数platform対応がrequiredなら、target / transition / recoveryをplatform別に検証し、一部の結果で全体をpassにしない。

## Hard Gates

以下のいずれかに該当する場合はtargetを確定せず、`conditional | incomplete | indeterminate`の該当状態としてSelection Gate、反証Evidence、残存riskを返す。

- named architectureやtechnologyが目的になっている。
- technical capabilityへcore / supporting / genericを付けている。kind自体がunknownならclassificationもunknownにし、確認方法と影響を残す。
- coreでないcapabilityに架空のunique valueやdomain visionを作っている。`not_applicable`はvalue-preservation / risk statement、理由、Evidenceがある場合だけ許す。
- core domain以外のsecurity、legal、accounting等の必要品質を落としている。
- 選択済みtargetに複数のsource of truth / authorityがある、またはconditional候補に選択gate・Evidence取得方法がないまま選択済みと表現している。
- unknownなclassification、priority、quality priority、reversibility、irreversible point、approval、recovery strategyをAI判断で確定している。
- transitionの複数writerに期限、reconciliation、conflict rule、removal conditionがない。
- required platformのoperation / recovery scenarioが未定義または未実行なのに、platform parityをverifiedとしている。
- architecture traceがvalue、quality scenario、current finding、option、target decision、transition phase、validationを接続していない。
- debt priorityでbusiness criticality、expected change、debt impact、failure risk、remediation costをEvidence付きで比較せず、根拠のない数値scoreまたはAIだけで最終順位を決めている。priority owner recordのstatus、value、resolution_or_reason、evidenceを落としている。
- validation planをexecuted / passedと表現している。oracle、owner、実行条件が揃うdesign artifactのreadyと、engineering statusのplannedを混同している。
- AIがvalue、quality priority、trade-offの承認、irreversible decisionを確定している。

## Completion

- portfolioとinvestmentがproduct value、expected change、failure riskへ接続される。
- option比較にcurrent / do-minimum、trade-off、cost、reversibilityがある。
- capability、option、target decision、transition phase、validationがID、Evidence、ownerを持ち、空欄でなく意味契約を記録する。
- current findingのpriorityが5 factor、debt impactの影響説明、比較理由、人間owner recordへ追跡できる。ownerがunknownなら解決方法または未確定理由とEvidenceがある。
- targetとtransition、migration、deploy order、exit criteria、irreversible point、abort、rollback / forward recovery、old path removalがある。
- temporary pathがある場合、各pathのowner、introduced_at、purpose、metric / log、removal condition、removal phaseがある。
- valueからvalidationまでのtraceが`covered | partial | missing | contradictory`を隠さない。
- Windows / Linux / macOS要件がある場合、platform別scenario、Evidence、未実行事項が分離される。
- `subject_verdict`、validation result、counterevidence、再評価trigger、residual riskをcanonical readinessと分離する。

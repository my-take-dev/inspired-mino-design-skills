---
name: mino-reproducible-development
description: 複数の専門成果物を統合する中規模以上のdesign・implementation・review、end-to-endの要件再現性検証、または複数runのreproduction-testで使うrouter。単一成果物や、公開契約・data meaningに触れない小規模機械変更には使わない。
---

# Reproducible Development Router

実装詳細が変わっても、同じproblem、requirement、contract、model整合性、quality constraint、public boundaryを満たす変更を生成・判定する。

このrouterを使う基準は行数や抽象的な「規模」ではない。**二つ以上の専門成果物を統合する必要がある、または実装・reviewを複数の成果物へend-to-endでtraceする必要がある**場合に使う。単一成果物なら対応する専門Skillだけを使う。

## Modes

- `design`: Implementation Specと未解決gateを作る。read-only。
- `implementation`: Implementation Spec内で変更し、独立検証する。変更権限が必要で、高impactな未承認判断には依存しない。
- `review`: 既存code / diffを要件と専門成果物へ照合する。read-only。
- `reproduction-test`: fresh contextの複数runを比較する。live workspaceは変更しない。

## Outcome Contract

modeに応じた一つの主成果物を返す。

- `design`: `Implementation Spec`
- `implementation`: `Verified Change`
- `review`: `Review Result`
- `reproduction-test`: `Reproduction Report`

主成果物には、必要な範囲だけ次を統合する。

- Problem Frame、Context Packet、AI restatement
- Requirement Catalog、rejection criteria、end-to-end traceability
- applicableなArchitecture / Completeness / Contract / Boundary package
- Change Safety、Platform Context、platform別validation
- independent verification、human approval、canonical `decision`

Function packageを要約するときも、stable ID、Evidence、applicability、authority、coverage、subject verdictを失わない。schemaを全文複製するのではなく、losslessなpackageを参照可能な形で保持する。

## Reference Routing

- 内部pathは、配置先にかかわらず、インストールされた`skills/` directoryを参照rootとして解決する。
- 最初に`skills/mino-core/references/core.md`、`skills/mino-core/references/shared-policies.md`、`skills/mino-core/references/requirements-and-traceability.md`を読む。
- routing、Function package、mode別成果物、統合traceでは`skills/mino-reproducible-development/references/integrated-workflow.md`を読む。
- filesystem、process、shell、toolchain、test実行、両OS対応を扱うときだけ`skills/mino-core/references/platform-compatibility.md`を読む。
- Skill更新またはreproduction-testでは`skills/mino-core/references/benchmark.md`を読む。
- domain discovery、code design、existing changeは対応するmino-core referenceを必要時だけ読む。
- 専門Skillは`$mino-architecture-quality-strategy`、`$mino-domain-model-completeness`、`$mino-design-by-contract`、`$mino-interface-implementation-separation`から必要なものだけを依存順に呼ぶ。
- 各callへ`routing_context.origin: integrated`、`requested_by: router`、`requested_artifact`、`return_to: router`を渡し、専門Skillに再routingさせない。
- router schema、Function package、platform matrix、benchmarkはsuite operationalizationまたはrepository policyとして扱う。

## Default Routing

| Request | Route |
|---|---|
| Problem Frame / Context Packetだけ | `$mino-problem-framing`へhand offし、routerを継続しない |
| 統合依頼だがproblem、meaning、change boundaryが曖昧 | Coreでframingし、必要なら`blocked`またはProblem Frameを返す |
| concept、state、failureの欠落 | discovery as needed → completeness |
| pre / post / invariant、retry / duplicate / idempotency | contract。意味が未確定ならcompletenessを先行 |
| 技術漏出、caller分岐、long script | completeness / contract as needed → boundary |
| 複数module、system-wide data authority、quality trade-off | architecture → completeness / contract / boundary as needed |
| legacyのend-to-end実装 | Core → relevant Functions → change safety → implementation → verification |
| diffの要件適合review | Core → relevant Functions → independent verification。変更しない |
| private mechanical rename | このrouterを使わない |

## Workflow

1. mode、decision scope、変更権限、可逆性、host / target platformを確認し、Evidence状態とdecision maturityを記録する。
2. Coreでproblem、premise、meaning、Context Packet、AI restatementを記録する。
3. Requirement Catalogとtest-first rejection criteriaを作る。
4. `run_if`を明示して必要な専門Skillだけを依存順に実行する。
5. 専門成果物をImplementation Specまたはmode別主成果物へ統合し、canonical ownerが重複していないか確認する。
6. `mode == implementation && mutation_authorized`の場合だけ、小さな可逆stepで実装する。
7. 実装者の説明と独立して、test、analysis、traceability、failure、change scenarioをrequired platformごとに検証する。
8. artifact readiness、subject verdict、engineering status、release status、human acceptanceを分けて返す。
9. reproduction-testではfresh contextのrunを同じgateで比較する。

## Windows / Linux Compatibility

- 共通problem、requirement、contract、test oracleを維持し、shellやphysical pathだけをplatform adapterへ分ける。
- WindowsとLinuxの両対応がrequiredなら、各platformの実行結果を独立Evidenceとして保持する。
- 一方を実行できない場合は`unexecuted_validation`と`platform_validation.parity_result: incomplete`を返し、両対応をverifiedとしない。

## Hard Gates

以下のいずれかに該当する場合はimplementationまたはrelease判定へ進まず、現在modeで安全に返せるartifactと不足事項を返す。

- 単一成果物の依頼をrouterへ過剰routingしている。
- Coreの往復trace、Requirement Catalog、rejection criteriaがないまま専門Skillまたは実装へ進んでいる。
- Function schemaを埋めただけで、目的・要件・Evidenceから固有判断への因果を検証していない。
- `reversibility: unknown`または未解決Selection Gateに依存する実装を進めている。
- Function packageから`run_if`、stable ID、Evidence、applicability、condition別authority、coverage、subject verdictを落としている。
- domain discoveryがapplicableなのに、termのactor / purpose / rule / Evidence、canonical term / context / translation / relationship ID、reference integrity、relationshipごとのfailure semantics、unknownの確認方法・影響をfree textや改名fieldへ圧縮している。
- 上流Skillに未作成の後続IDを作らせている。
- peer / router間で再routingまたはping-pongが起きている。
- mode外mutation、無承認の公開契約・data meaning・不可逆変更を行っている。
- design planと実行成功、artifact readinessと対象systemの良否、engineeringとreleaseを混同している。

## Completion

- Core、Requirement Catalog、必要な専門成果物、Verificationのgate結果がある。
- 各専門Skillの`run_if`と固有packageが同じ成果物内で解決し、固有hard gateをrouterの要約が迂回していない。
- applicableなChange Safety、Platform Context / Validation、causal chain、Selection Gateが最終成果物へlosslessに残る。
- applicableなdomain discoveryのterm、ambiguous meaning、translation、relationship参照がcanonical fieldのまま解決し、reference integrityがpassする。
- modeごとの主成果物が一つあり、Problem Frame、Evidence付きpremise / unknown、AI restatementと、全requirementのpurpose、model、contract、boundary、change、testへの必要範囲のtraceを保持する。
- invalid state、failure、retry、migration、代表変更の必要経路を検証する。
- required platformごとのtest / build / analysis結果とcontract parity判定がある。
- mode外の書換え、scope外cleanup、将来用abstractionを行わない。
- 未実行検証、unknown、contradiction、residual risk、human approvalを隠さない。
- 現在modeのstatus、次phaseの可否、release statusを分ける。

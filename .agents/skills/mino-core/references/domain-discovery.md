# Domain discovery viewpoints

既存scopeの完全性監査だけでは足りず、用語、目的、context、暗黙概念、model境界を発見する必要があるときに読む。

## Contents

- Actor and purpose
- Term ledger
- Context boundary
- Invisible concepts
- Invariant and destruction probes
- Output

## 1. Actor and purpose

`actor + context + purpose`の組を起点にする。同じ物理名詞でも目的、rule、lifecycle、authorityが異なるなら別modelまたは別bounded context候補とする。

## 2. Term ledger

```yaml
term:
  id: TERM1
  name: ""
  context_id: C1
  actors: []
  purpose: ""
  meaning: ""
  examples: []
  counterexamples: []
  rules: []
  related_meaning_term_ids: []
  evidence: []
ambiguous_term:
  id: AMB1
  surface_form: ""
  meaning_term_ids: []
  risk: ""
  evidence: []
translation:
  id: TR1
  source_context_id: C1
  target_context_id: C2
  source_term_id: TERM1
  target_term_id: TERM2
  mapping: ""
  evidence: []
```

一般定義や既存class名を業務上の意味として確定しない。意味が異なるcontext間では無理に統一せず、translationを定義する。ambiguous meaningへactor、purpose、ruleを複製せず、canonicalなterm IDを参照する。全context / term / translation参照は同じpackage内の実在IDへ解決する。

canonical recordでは`source_context_id`、`target_context_id`、`source_term_id`、`target_term_id`を個別fieldのまま保持する。`source: C1/TERM1`のような結合値、表の暗黙列、名前を変えたfree textは参照整合性を検査できないためtranslationの代用にしない。

## 3. Context boundary

意味、必須属性、rule、state transition、lifecycle、source of truthの変化点を境界候補にする。

```yaml
context:
  id: C1
  purpose: ""
  language_term_ids: []
  owned_rules: []
  owned_data: []
  out_of_scope: []
relationship:
  id: REL1
  upstream_context_id: C1
  downstream_context_id: C2
  exchanged_fact: ""
  fact_owner: ""
  integration: "api | event | batch | other"
  translation_ids: []
  consistency: ""
  evidence:
    status: confirmed | inferred | assumption | unknown | contradiction
    sources: []
  failure_semantics:
    failure_owner:
      status: identified | unknown | not_applicable
      owner: ""
      rationale: ""
      evidence: []
      confirmation_method: ""
      impact_if_unresolved: ""
    retry:
      applicability: required | not_applicable | unknown
      policy_or_reason: ""
      owner: ""
      evidence: []
      confirmation_method: ""
      impact_if_unresolved: ""
    duplicate:
      applicability: required | not_applicable | unknown
      result_or_reason: ""
      owner: ""
      evidence: []
      confirmation_method: ""
      impact_if_unresolved: ""
    ambiguous_outcome:
      applicability: required | not_applicable | unknown
      recovery_or_reason: ""
      owner: ""
      evidence: []
      confirmation_method: ""
      impact_if_unresolved: ""
```

同じIDやdataを交換してもmodelまで共有する必要はない。service分割は意味境界を発見した後の別判断とする。failure owner、retry、duplicate、ambiguous outcomeは関係ごとにEvidenceから適用性を判定し、`not_applicable`には理由、`unknown`には`confirmation_method`と`impact_if_unresolved`を残す。transport実装から業務上のretry可否やduplicate resultを推測しない。

relationshipでは`upstream_context_id`と`downstream_context_id`を個別fieldとして保持し、`upstream`、`downstream`、図中の矢印だけへ圧縮しない。`failure_owner`とretry / duplicate / ambiguous outcomeの各recordは、適用判定、owner、理由またはpolicy、Evidenceを省略しない。`unknown` recordでは確認方法と未解決時の影響も省略しない。

## 4. Invisible concepts

物理名詞だけでなく、目的、問題、判断、約束、資格、権利、責任、制約、出来事、失敗をconcept候補にする。

```text
actor → purpose → obstacle → decision / constraint → required information → model
```

既存名を一度伏せ、各候補へrequired information、behavior、invariant、lifecycle、`out_of_scope`を定義する。現行symbolを候補へmappingし、属さない要素を別目的、技術関心、不要のいずれかとして調べる。

## 5. Invariant and destruction probes

値、関係、state、順序、時間、並行性、原子性を壊す反例から、missing constraint、state、failure、ownerを発見する。既定は思考実験または使い捨てfixtureとし、本番dataへ破壊操作を行わない。

## Output

```yaml
domain_discovery:
  actors_and_purposes: []
  terms: []
  ambiguous_terms: []
  contexts: []
  relationships: []
  translations: []
  invisible_concepts: []
  current_symbol_mapping: []
  destruction_probes: []
  unknowns:
    - id: U1
      subject: ""
      confirmation_method: ""
      impact_if_unresolved: ""
      owner: ""
      evidence: []
  reference_integrity:
    checked_ids: []
    unresolved_ids: []
    status: pass | fail
```

packageをreadyにする前に、term、ambiguous term、context、translation、relationshipの全参照IDを`checked_ids`へ記録する。参照先がないIDは`unresolved_ids`へ残して`status: fail`とし、free textの意味一致でpassにしない。relationship自体のEvidenceをfailure semanticsの部分Evidenceで代用せず、未確定の関係、owner、policyは`unknowns`から該当recordへ追跡する。

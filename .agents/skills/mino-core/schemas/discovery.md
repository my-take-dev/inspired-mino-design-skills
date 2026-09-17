# 保存用schema

依頼された正本packageを作る場合だけ読む。既存artifactはhandleとrevisionで参照再利用する。未知は空欄で隠さず、非該当には理由を残す。

## Contents

- term
- relationship
- domain_discovery

## term

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
context:
  id: C1
  purpose: ""
  language_term_ids: []
  owned_rules: []
  owned_data: []
  out_of_scope: []
```

## relationship

```yaml
relationship:
  id: REL1
  upstream_context_id: C1
  downstream_context_id: C2
  exchanged_fact: ""
  fact_owner: ""
  integration: api | event | batch | other
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

## domain_discovery

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
  unknowns: []
  reference_integrity:
    checked_ids: []
    unresolved_ids: []
    status: pass | fail
```

invisible conceptにはrequired information、behavior、invariant、lifecycle、out_of_scope、Evidenceを残す。unknownは`skills/mino-core/schemas/core.md`のunknown recordを使う。term/context/translation/relationshipの個別ID fieldと参照整合を保持する。

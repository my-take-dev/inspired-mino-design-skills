# 技術の引力を点検し、具体と抽象を往復する

## このノウハウの核

エンジニアは、コード、DB、API、フレームワーク、性能、構成など、具体的な技術へ注意を向ける訓練を長く受けています。そのため、顧客要求や業務上の問題を聞いた瞬間に、既知の技術や既存コードへ置き換えて理解しようとしがちです。

この傾向を、ここでは **技術の引力** と呼びます。

技術の引力そのものは悪ではありません。要件を実装し、AI成果物の正しさを評価するには技術力が必要です。問題は、技術的な解決策へ早く落ちすぎて、次を失うことです。

- 誰の、どの問題を解くのか。
- なぜその問題が重要なのか。
- 何をもって解決と判定するのか。
- 技術以外の解決策があるか。
- 今見ている実装が、上位目的へ本当に寄与するか。

Skillは、実装から目的へ遡る **抽象化** と、目的から検証可能な要件・設計・実装へ戻る **具体化** を往復させます。

```text
具体: table / field / API / class / branch / library
  ↑  「つまり、何のためか」
抽象: system capability / use case / actor purpose / product value
  ↓  「たとえば、何がtrueならよいか」
具体: requirement / contract / quality scenario / architecture / code / test
```

## 解決する問題

次の症状があるときに使います。

- 要求を聞いた直後に、テーブル、カラム、API、フラグ、ライブラリの話になる。
- 問題文が「マイクロサービス化できていない」「キャッシュがない」など手段で書かれている。
- 既存コードから要件や顧客目的へ遡れない。
- AIへ詳細な実装指示は出せるが、成果物の価値や妥当性を判定できない。
- 技術的には正しい実装なのに、利用者が欲しかった結果と違う。
- 抽象的な理念だけを語り、具体的な成功条件やテストへ戻れない。
- `なぜ`を繰り返しすぎて、今回の意思決定に不要な事業目的まで広がる。

単純な機械的変更で、目的、契約、変更範囲が既に確認されている場合は、往復を最小限にします。

## 必要な入力

- 依頼原文、PRD、チケット、会話記録。
- 現在提案されている技術・実装案。
- 対象コード、schema、API、テスト、運用手順。
- 対象アクターと利用場面。
- 既知の顧客価値、事業目的、品質要求。
- 観測された症状、問い合わせ、障害、変更失敗。
- 維持契約、期限、法令、セキュリティなどの制約。

## 用語

### 技術の引力

顧客や業務の話を、無意識に自分が得意な技術の枠組みへ置き換えて理解し、解決策を早期固定する傾向です。

兆候:

- 問題文に特定技術名が含まれる。
- アクターや目的より、変更対象ファイルが先に確定する。
- 解決策の比較前に、既存構造の延長だけで設計する。
- 技術語を取り除くと、何が困っているか説明できない。

### 抽象化

具体的な実装や現象から、今回の目的にとって本質的な意味、役割、関係、制約を取り出します。

このSkillでは、`つまり`で上位へ遡ります。

```text
このカラムをNOT NULLにしたい。
→ つまり、どの無効状態を防ぎたいのか。
→ つまり、誰のどの業務判断を成立させたいのか。
→ つまり、利用者にどの結果を保証したいのか。
```

### 具体化

抽象的な目的や価値を、観測可能な目標、契約、品質シナリオ、設計、テストへ落とします。

このSkillでは、`たとえば`で下位へ戻ります。

```text
法人購買担当者が予算内で安全に一括購入できる。
→ たとえば、予算超過時は確定できない。
→ たとえば、承認済み見積と注文金額が一致する。
→ たとえば、契約テストで境界値と禁止遷移を検証する。
```

## 判断規則

### 1. 解決策を一度退避する

依頼に含まれる技術案を捨てませんが、最初は`candidate_means`へ移します。

```yaml
candidate_means:
  - proposal: "Redisを導入する"
    proposed_by: "依頼者"
    assumed_problem: "応答が遅い"
    status: unselected
```

問題定義と成功条件が決まる前に採用案へしません。

### 2. 技術語を除いて問題を説明する

次の形式で書けない場合、技術の引力が強く働いています。

```text
[アクター]は[文脈]で[目的]を達成したい。
しかし[観測可能な阻害要因]により[損失・失敗]が生じている。
```

技術名は原因仮説または解決候補として後から接続します。

### 3. `つまり`で一段ずつ遡る

一度に「会社の利益」まで飛ばず、次の階層を一段ずつ確認します。

1. 実装目的: このコード、field、APIは何を成立させるか。
2. 機能目的: どのsystem capabilityを支えるか。
3. ユースケース目的: アクターは何を達成するか。
4. プロダクト目的: どの価値・成果を改善するか。
5. 事業目的: どの競争力、収益、損失回避へ寄与するか。

今回の判断に必要な高さで止めます。

### 4. 上位目的には根拠を要求する

コードから推測した目的を確定事項にしません。

- `confirmed`: 仕様、担当者確認、実利用データなど根拠あり。
- `inferred`: コード、テスト、名称、履歴から推定。
- `assumption`: 作業を進めるための一時仮定。
- `unknown`: 結果を分岐させる不足。

### 5. `たとえば`で検証可能な形へ戻す

抽象化した目的を、次へ降ろします。

1. 成功条件。
2. 失敗・禁止条件。
3. 品質シナリオ。
4. ドメイン概念と契約。
5. 公開境界。
6. 実装候補。
7. テスト・計測。

下りられない抽象は、意思決定に使えないスローガンの可能性があります。

### 6. 往復で意味が変わらないか確認する

```text
実装A
→ 上位目的P
→ 目標G
→ 実装候補A/B/C
```

最初の実装Aだけが唯一の候補である根拠がなければ、他案を比較します。上位目的へ遡った結果、別の運用変更や機能削除で解ける場合があります。

### 7. 抽象化の停止条件を持つ

次のいずれかで止めます。

- 今回の選択肢を比較できる目的へ到達した。
- 成功条件と対象外を定義できる。
- それ以上遡っても採用案が変わらない。
- 権限外の事業判断へ入る。
- 根拠がなく仮説だけになる。

### 8. 人間とAIの役割を分ける

- 人間: 誰の価値を優先するか、どこまで遡るか、どのtrade-offを受容するかを決める。
- AI: 技術語抽出、目的階層候補、別解釈、代替手段、traceability欠落を提案する。
- 人間: AIの推定目的を根拠で検証し、最終問題定義と成功条件を承認する。

AIに目的や価値を自動確定させません。

## 実行手順

### Phase 0: 技術の引力を検出する

1. 依頼と会話から技術名、file、class、table、framework、patternを抽出する。
2. それぞれが問題、制約、解決策、単なる現状のどれかを分類する。
3. 技術語を削除した問題文を作れるか確認する。
4. 作れない場合は問題定義へ戻る。

### Phase 1: 具体から抽象へ遡る

5. 各技術要素について「つまり何のためか」を一段ずつ問う。
6. 実装目的、機能目的、ユースケース目的、プロダクト目的を接続する。
7. 各接続に根拠状態を付ける。
8. 目的の異なる要素が一つの手段へ混ざっていないか確認する。

### Phase 2: 問題と目的を検証する

9. アクター、文脈、阻害要因、損失を記述する。
10. 依頼者、利用者、運用者、事業担当の視座から別解釈を作る。
11. 上位目的が本当に必要か、反証条件を置く。
12. 今回のdecision scopeと対象外を確定する。

### Phase 3: 抽象から具体へ戻る

13. 各目的に観測可能な目標を付ける。
14. 目標を要件、契約、品質シナリオへ変換する。
15. 少なくとも二つの手段を比較する。
16. 実装候補、テスト、計測へtraceする。

### Phase 4: 往復整合性を監査する

17. 各実装変更がどの目標・目的を支えるか確認する。
18. 各目標に実装と検証があるか確認する。
19. 上位目的へ寄与しない作業を削除または別scopeへ分離する。
20. 問題定義と成功条件を人間が承認した後に実装へ渡す。

## 出力契約

```yaml
abstraction_navigation:
  decision_scope:
    decide: []
    not_decide: []
  technical_gravity_signals:
    - evidence: string
      type: solution_first | technology_language | existing_structure_bias | premature_detail
      impact: string
  candidate_means:
    - id: M1
      proposal: string
      status: unselected | selected | rejected
      rationale: string
  ladders:
    - concrete_item: string
      levels:
        - level: implementation
          statement: string
          evidence_status: confirmed | inferred | assumption | unknown
        - level: capability
          statement: string
          evidence_status: confirmed | inferred | assumption | unknown
        - level: actor_purpose
          statement: string
          evidence_status: confirmed | inferred | assumption | unknown
        - level: product_value
          statement: string
          evidence_status: confirmed | inferred | assumption | unknown
      stop_reason: decision_useful | authority_boundary | insufficient_evidence
  problem_definition:
    actor: string
    context: string
    desired_state: string
    observed_obstacle: string
    impact: string
  goals:
    - id: G1
      observable_condition: string
      supported_purposes: []
  means_comparison:
    - means: M1
      supports: []
      quality_effects: []
      constraints: []
      validation: []
  traceability:
    - purpose: string
      goal: string
      implementation: []
      tests: []
  open_questions: []
  gate:
    status: ready | blocked
    reasons: []
```

## 完了条件

- [ ] 技術語を使わず、対象アクターの問題を説明できる。
- [ ] 技術・実装要素が、少なくとも一段上の目的へ接続されている。
- [ ] 上位目的の根拠状態が明示されている。
- [ ] 目的が、観測可能な目標、契約、検証へ具体化されている。
- [ ] 最初に提示された技術案を唯一の解決策として扱っていない。
- [ ] 抽象化の停止理由が明示されている。
- [ ] 目的から実装とテストまでtraceabilityがある。
- [ ] 人間が問題定義、価値、trade-offを承認している。

## 失敗パターン

- 技術を避けること自体を目的にし、必要な技術判断を先送りする。
- `なぜ`を無制限に繰り返し、今回の権限・期限を越える。
- すべてを「顧客価値」「利益」の一語へ潰し、具体的な目的差を失う。
- コードから推定した目的を、関係者確認なしに`confirmed`とする。
- 抽象的な理念を作って満足し、要件、契約、テストへ戻らない。
- 既存構造を正しい問題モデルとして固定する。
- AIが出した目的階層を、人間の判断なしに採用する。

## Skill用プロンプト骨子

```text
依頼と対象コードに働いている「技術の引力」を監査してください。

1. 技術名、実装案、既存構造への早期固定を抽出する。
2. 技術語を使わず、アクター・文脈・目的・阻害要因で問題を記述する。
3. 各具体要素から「つまり何のためか」で、実装目的→機能目的→利用者目的→プロダクト価値へ遡る。
4. 各上位目的へ根拠状態を付け、推測を確定しない。
5. 「たとえば何がtrueなら達成か」で、目標→要件→契約→品質シナリオ→実装候補→テストへ戻る。
6. 複数の解決手段を比較し、目的から実装までtraceabilityを作る。
7. 抽象化の停止理由と、未決事項を明示する。
```

## 他資料との接続

- 問題定義と前提監査: `17-premise-checking-and-problem-definition.md`
- Context Packet: `16-ai-context-verbalization.md`
- 目的・目標・手段: `01-purpose-goal-means.md`
- 目的駆動の抽象化: `13-purpose-driven-abstraction.md`
- 品質特性: `02-quality-attributes-and-modifiability.md`
- アーキテクチャ全体最適: `27-architecture-quality-strategy.md`
- 統合AI開発: `23-reproducible-ai-development.md`

## 出典と操作的解釈

主な根拠:

- https://speakerdeck.com/minodriven/tech-gravity
- https://speakerdeck.com/minodriven/ai-philosophy-cognitive-science
- https://speakerdeck.com/minodriven/doubt-premise
- https://speakerdeck.com/minodriven/ai-refactoring-approach
- https://speakerdeck.com/minodriven/purpose-abstraction-design

公開資料では、技術観点へ留まる問題、具体化に比べ抽象化が苦手になりやすい傾向、`つまり`と`たとえば`による具体・抽象の往復、目的・目標・手段、認知バイアス、問題定義の重要性が説明されています。

この文書の`abstraction_navigation`成果物、停止条件、根拠状態、traceabilityは、それらをSkillとして反復可能にするための操作的解釈です。

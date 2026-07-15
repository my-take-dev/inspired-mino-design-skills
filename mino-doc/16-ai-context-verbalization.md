# AIへ目的・文脈・ルールを言語化する

## このノウハウの核

AIへ命令だけを渡しても、言葉の意味、優先順位、維持すべき制約を正確には共有できません。言葉は単独で意味が決まるのではなく、誰が、何のために、どの状況で使い、どのルールに従うかによって意味が変わります。

Skillは、作業命令の前に次の情報を `Context Packet` として明示します。

- **アクター**: 誰が利用し、誰が影響を受けるか。
- **目的**: アクターが実現したい状態と、その上位目的。
- **文脈**: 目的が生じる状況、業務、時点、利用場面。
- **ルール**: 文脈内で成立する制約、方針、禁止事項。
- **成功条件**: 目的達成を観測できる条件。
- **品質特性**: 今回特に高める、または維持する品質。
- **変更境界**: 変更してよいもの、維持するもの、対象外。
- **根拠状態**: 確認済み事実、推論、仮定、未決事項。

これは「あなたは優秀な設計者です」と役割だけを与える方法ではありません。AIが判断に使う世界の見方、つまり思考のレンズを、対象タスクの事実に基づいて設計する方法です。

## 解決する問題

次の症状があるときに使います。

- 同じ依頼をしても、AIの回答方針や品質が大きく揺れる。
- 「良いコード」「適切に」「類似するもの」など、意味が文脈依存の語がある。
- AIが関係のない全面改修を始める、または維持すべきコードを変更する。
- 技術手段は詳しく指示されているが、目的や成功条件が不明。
- 品質改善のつもりが、性能、変更容易性、セキュリティなど別の評価軸で実装される。
- 仕様、コード、会話の内容が食い違い、どれを優先すべきか分からない。

目的、意味、制約が既に形式化され、対象変更も機械的である場合は、Context Packetを必要最小限にします。

## 必要な入力

- 依頼文、PRD、ユーザーストーリー、受け入れ条件。
- アクター、利用場面、業務フロー、組織上の責任者。
- 用語集、ドメインモデル、API、schema、テスト。
- 維持すべき外部挙動、変更許容範囲、対象外。
- 性能、セキュリティ、信頼性、変更容易性などの品質要求。
- 既知の障害、失敗例、過去の意思決定、運用制約。

情報が不足していても、一般知識で業務要件を補完しません。作業継続に必要な低リスクの不足は仮定として明示し、結果を大きく分岐させる不足は未決事項として扱います。

## Context Packetの構造

### 1. Actor

「ユーザー」のような総称だけで終わらせず、目的やルールが異なる単位へ分けます。

```text
個人購入者: 自分で利用する商品を少量購入する
法人購買担当者: 組織の承認と予算制約の中で一括購入する
運用担当者: 失敗取引を追跡し、安全に再実行する
```

アクターが違えば、同じ「注文」「利用者」「承認」でも意味が変わる可能性があります。

### 2. Purpose

目的は、手段ではなく望ましい状態として書きます。

- 悪い例: `Redisを導入する`
- 改善例: `高頻度参照時にも応答時間を目標内に保つ`

上位目的と下位目的を分け、今回の作業がどの目的へ寄与するかを示します。

### 3. Context

文脈には、場所や環境だけでなく、状態、時点、直前の出来事、業務上の立場を含めます。

- 購入完了直後
- 取消可能期間内
- 法人契約の予算承認後
- 外部決済は成功したが内部保存は未完了
- 既存API互換性を維持した段階移行中

### 4. Rules

ルールは観測可能な条件へ変換します。

- 数量は1以上、販売上限以下である。
- 確定済み注文は明細変更できない。
- 同じ冪等キーの再要求で二重決済しない。
- 既存公開APIのレスポンス意味を変更しない。

「常識的に」「適切に」のような表現は、そのままルールとして採用しません。

### 5. Quality lens

「良い」の意味を品質特性へ変換します。

```text
definitions:
  Q-MOD = characteristic: maintainability / subcharacteristic: modifiability / display: 変更容易性
  Q-FCOR = characteristic: functional_suitability / subcharacteristic: functional_correctness / display: 機能正確性
primary_ids: [Q-MOD]
secondary_ids: [Q-FCOR]
constraint: p95 latencyを現状より悪化させない（対応quality IDとscenarioへ接続）
```

複数の品質特性が競合する場合、優先順位と許容するトレードオフを記述します。
品質characteristic、subcharacteristic、標準語彙、公開資料の表現、suite / project内表示名は`02-quality-attributes-and-modifiability.md`のschemaで分けます。

### 6. Change boundary

AIが自由に変更してよい範囲を明示します。

- `must_preserve`: 公開契約、データ意味、既存利用者の観測可能な挙動。
- `may_change`: private実装、内部データ構造、局所的な命名。
- `must_not_change`: 認可方針、課金計算、未承認のschema。
- `out_of_scope`: 別ユースケース、将来の最適化、無関係な整理。

## 判断規則

### 1. 命令より前に目的を置く

AIへの入力は、原則として次の順にします。

```text
目的 → アクター → 文脈 → ルール → 品質特性 → 変更境界 → 命令 → 検証条件
```

技術手段から始めると、手段が目的化しやすくなります。

### 2. 相手の文脈と自分の文脈を分ける

コードや依頼を読む人の経験だけで意味を確定しません。用語ごとに次を確認します。

- 誰がその語を使ったか。
- どの場面で使ったか。
- 何を実現したくて使ったか。
- その文脈でどの条件を満たす必要があるか。

### 3. 用語の一般定義より、対象文脈の意味を優先する

一般辞書やフレームワーク用語の定義は参考情報です。対象システムの意味は、アクター、目的、文脈、ルールによって確定します。

### 4. 事実と解釈を分ける

Context Packet内の各主張に、次の状態を付けます。

- `confirmed`: 仕様、コード、テスト、担当者確認などの根拠あり。
- `inferred`: 複数の根拠から推定したが明示されていない。
- `assumption`: 作業を進めるため一時的に置く。
- `unknown`: 結果を分岐させる不足。
- `contradiction`: 根拠同士が競合する。

### 5. AIに復唱させ、比較結果を独立reviewできるようにする

実装前に、AI自身に次を短く再構成させます。

- 誰の何を改善するのか。
- 維持する契約は何か。
- 変更してよい範囲はどこか。
- 成功と失敗を何で判定するか。
- 未決事項は何か。

復唱本文、比較に使ったContext Packet / requirement / change boundary、AIが提案する`matched | mismatched | blocked`、差分、review主体を分けます。AI自身の`matched`はEvidenceではありません。公開契約、data meaning、金銭、認可、安全、不可逆判断を分岐させる場合は、利用者、権限を持つowner、または独立evaluatorのaccepted reviewがなければ実装へ進みません。

### 6. 文脈を過剰投入しない

関係のない全社資料やリポジトリ全体を無条件に渡しません。判断に必要な根拠を選び、参照元を示します。長い文脈より、目的と判断規則が明確な文脈を優先します。

## 実行手順

1. 依頼、仕様、コードから名詞、動詞、制約語、品質語を抽出する。
2. アクターを目的やルールが異なる単位へ分ける。
3. 各アクターの現在の状況、困りごと、望む状態を記述する。
4. 上位目的と今回の作業目的を接続する。
5. 曖昧語、同音異義、一般定義と業務定義が違う語を列挙する。
6. 文脈内のルールを、事前条件、事後条件、不変条件、禁止事項へ変換する。
7. 優先する品質特性とトレードオフについて、確認可能な項目をEvidence状態付きで記録する。人間所有の選択は未承認ならproposedまたはunknownとして残す。
8. 維持、変更可、変更禁止、対象外を定義する。
9. 各主張へ根拠状態を付け、矛盾と未決事項を分離する。
10. Context PacketをAIへ渡し、解釈の復唱、comparison basis、proposed status、differencesを求める。
11. riskに応じたreview主体とEvidenceを記録し、mismatchまたは高impactな未review事項に依存する分析、設計、実装へ進まない。
12. 最終成果をContext Packetの成功条件と変更境界で検証する。

## 出力契約

```yaml
context_packet:
  task: string
  actors:
    - id: A1
      name: string
      situation: string
      evidence_status: confirmed | inferred | assumption
  purposes:
    - id: P1
      actor: A1
      desired_state: string
      parent_purpose: null
      success_conditions: []
  context:
    time_or_state: []
    business_background: []
    technical_background: []
  terminology:
    - term: string
      meaning_in_context: string
      alternative_meanings: []
      evidence: []
  rules:
    - id: R1
      statement: string
      kind: precondition | postcondition | invariant | policy | prohibition
      owner: string
      evidence_status: confirmed | inferred | assumption | unknown
  quality_lens:
    definitions: []
    primary_ids: []
    secondary_ids: []
    constraint_ids: []
    tradeoffs: []
  change_boundary:
    must_preserve: []
    may_change: []
    must_not_change: []
    out_of_scope: []
  contradictions: []
  unknowns: []
  ai_restatement:
    statement: string
    comparison_basis: []
    proposed_status: matched | mismatched | blocked
    differences: []
    reviewed_by:
      kind: user | human_owner | independent_evaluator | unresolved
      identity: string
      review_status: accepted | rejected | unresolved
      evidence: []
```

## 完了条件

- [ ] 主要アクターが、目的やルールの違いに基づいて分けられている。
- [ ] 各目的が特定のアクターと文脈へ結び付いている。
- [ ] 曖昧な重要語について、対象文脈での意味が定義されている。
- [ ] ルールが観測可能な条件として記述されている。
- [ ] 優先する品質特性とトレードオフが明示されている。
- [ ] 維持、変更可、変更禁止、対象外が区別されている。
- [ ] 確認済み事実、推論、仮定、未決事項が混同されていない。
- [ ] AIの復唱、comparison basis、提案status、差分が分離され、高impactな判断では許可されたreview主体のaccepted Evidenceがある。
- [ ] 最終成果が成功条件と変更境界に照合されている。

## 失敗パターン

- 役割指定だけで、目的、文脈、ルールを与えない。
- 大量の文書を無選別に渡し、重要な判断基準を埋没させる。
- 一般的な用語定義を、そのまま対象業務の定義とみなす。
- コードから推定した目的を確認済み事実として扱う。
- 「保守性を高める」など、成功判定できない品質指示を使う。
- AIの解釈確認をせず、いきなり実装させる。
- AI自身が付けた`matched`を、独立した理解確認または人間承認として扱う。
- Context Packetを固定仕様と誤解し、新しい根拠が出ても更新しない。
- Personaや本人の口調を再現することを、思考のレンズ設計と混同する。

## エージェント向けプロンプト骨子

```text
作業前にContext Packetを作成してください。

1. アクター、目的、文脈、ルールを抽出する。
2. 上位目的と今回の成功条件を示す。
3. 曖昧な重要語について、この文脈での意味と別解釈を列挙する。
4. 優先する品質特性、維持契約、変更可能範囲、対象外を示す。
5. 各主張をconfirmed、inferred、assumption、unknown、contradictionに分類する。
6. 実装前に、理解した目的、契約、変更境界、未決事項を復唱する。
7. 復唱が一致した後だけ実装し、最後にContext Packetへ照合する。
```

## 他スキルとの接続

- 目的階層を整理する: `01-purpose-goal-means.md`
- 品質の意味と語彙粒度を整理する: `02-quality-attributes-and-modifiability.md`
- 文脈ごとの用語を整える: `06-ubiquitous-language-and-context.md`
- 自分の前提を点検する: `17-premise-checking-and-problem-definition.md`
- 契約へ変換する: `20-design-by-contract.md`
- 統合実装へ渡す: `23-reproducible-ai-development.md`

## 出典と操作的解釈

- https://speakerdeck.com/minodriven/ai-context-verbalization
- https://speakerdeck.com/minodriven/ai-philosophy-cognitive-science
- https://speakerdeck.com/minodriven/doubt-premise
- https://speakerdeck.com/minodriven/purpose-driven-architecture

公開資料では、言葉の意味は文脈で変わり、AIへ目的を伝えること、アクター・目的・文脈・ルールを確認することが重要だと説明されています。本書のContext Packet、根拠状態、変更境界、AI復唱gateは、それらをSkillとして反復可能にするための操作的な再構成です。

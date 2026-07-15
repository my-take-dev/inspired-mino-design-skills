# 事業価値とコアドメインから設計投資を決める

## このノウハウの核

開発生産性は、単に実装速度や開発コストを下げることだけではありません。限られた開発資源を、顧客価値と競争優位性を高める領域へ集中し、その領域の機能性と変更容易性を高めることで、収益と費用の両面から利益へ寄与させます。

- **コアドメイン**: 他社との差別化や競争優位性を生む、事業上もっとも重要な領域。
- **サブドメイン**: 事業に必要だが、競争優位性の中心ではない領域。
- **機能性への投資**: 顧客の目的をよりよく満たし、価値と収益を高める。
- **変更容易性への投資**: 重要領域を継続的に改善する費用と失敗リスクを下げる。

Skillは、全領域を同じ密度で設計せず、重要性、変化、負債、リスクに応じて設計コストを配分します。

## 解決する問題

- 技術的に面白い領域へ投資が偏り、顧客価値との接続がない。
- 全モジュールへ同じアーキテクチャやDDDを適用し、過剰設計になる。
- 競争優位性の高い機能が、共通機能や補助機能と密結合して改善できない。
- 改善施策を「コードがきれいになる」以外の言葉で説明できない。
- ロードマップとアーキテクチャの優先順位が一致していない。

## 必要な入力

- 事業目標、プロダクト戦略、ロードマップ。
- 顧客が選ぶ理由、競合との差、失注・解約・利用継続の要因。
- 主要アクターと、その目的、困りごと、代替手段。
- 売上、損失、運用費、開発費に影響する仮説または実績。
- 変更頻度、今後の投資予定、障害・手戻りの履歴。
- 現在のドメイン境界、依存関係、チーム所有関係。

数値が得られない場合、定量値を捏造せず、定性的根拠と検証方法を記載します。

## 判断規則

### 1. 技術ではなく価値から開始する

「マイクロサービス化」「DDD導入」「フレームワーク刷新」は手段です。先に次を確認します。

- どの顧客または利用者の、どの目的を強化するのか。
- 競合や代替手段に対する優位性は何か。
- 成功時にどの行動、成果、収益、損失回避が変わるのか。
- 今後どの程度、仕様を磨き続ける必要があるのか。

### 2. コアは「重要そうな名詞」ではなく差別化能力で判定する

決済、アカウント、商品などの名詞だけでコアと断定しません。同じ機能でも、事業モデルによってコアか汎用かは変わります。

コア候補は次の問いで評価します。

- この能力がなくなると、顧客が自社を選ぶ理由が大きく失われるか。
- 独自の業務知識、判断、データ、試行錯誤が蓄積されているか。
- 今後も継続的な改良が競争力へ直結するか。
- 既製品へ置き換えても競争力が変わらないなら、本当にコアか。

`core | supporting | generic`の対象はbusiness capabilityまたはsubdomainです。logging、deployment、cache等のtechnical capabilityへ同じ分類を付けず、品質、failure risk、operation、costで評価します。対象種別が未確認なら、技術名からbusiness capabilityを推測しません。

### 3. コアドメインの価値を短い声明にする

関係者の判断軸として、ドメインビジョン声明を作ります。

```text
対象顧客:
解決する重要問題:
提供する独自価値:
競合・代替との差:
成功を示す観測結果:
対象外:
```

声明はスローガンではなく、機能要求、境界、投資判断を棄却できる具体性を持たせます。

### 4. コアとサブをアーキテクチャで分離する

ビジネス上「選択と集中」を宣言しても、コードが密結合していれば集中投資できません。

- コアのモデルへサブドメイン固有ルールを混ぜない。
- サブの変更がコアの内部へ波及しない依存方向を作る。
- 共通化によってコア固有の概念を薄めない。
- コアのチーム、テスト、デプロイ、観測を必要な範囲で独立させる。

分離単位は、必ずしも別サービスではありません。モジュール、パッケージ、プロセス、リポジトリのどこまで分けるかは、変更頻度、整合性、運用コストで決めます。

### 5. 設計の厳密さを投資効果で変える

- コアかつ変化が多い領域: 深いモデル、明確な境界、強い制約、手厚いテストへ投資する。
- サブだが高リスクな領域: セキュリティ、会計、法令など必要品質へ投資する。
- 汎用かつ差別化しない領域: 購入、外部サービス、単純実装を検討する。
- 変化も影響も小さい領域: 無理に再設計しない。

## 実行手順

1. 事業目標と主要顧客価値を整理する。
2. 主要なビジネス能力またはドメイン候補を列挙する。
3. 各候補について、差別化、収益影響、損失リスク、変更頻度、独自知識を評価する。
4. コア、支援的サブドメイン、汎用サブドメインとして仮分類する。
5. ドメインエキスパート、プロダクト責任者、運用担当と分類根拠を確認する。
6. コア候補のドメインビジョン声明を作る。
7. 現在のコード境界と依存が分類を支えられるか確認する。
8. 投資案を、機能性向上、変更費用低減、リスク低減へ結び付ける。
9. 分類が将来も固定とは限らないため、見直し条件を設定する。

## 出力契約

```yaml
capabilities:
  - id: D1
    name: "能力または領域"
    kind: "business_capability | subdomain | technical_capability | unknown"
    classification: "core | supporting | generic | not_applicable | unknown"
    classification_rationale: ""
    decision_maturity:
      status: "proposed | approved | frozen | unknown | contradiction"
      owner: ""
      approval_evidence: []
    actors: []
    value_hypothesis: "顧客・事業へもたらす価値"
    differentiation: "競合・代替との差"
    expected_change: "high | medium | low | unknown"
    risk: "失敗時の影響"
    evidence: []
    domain_vision:
      status: "applicable | not_applicable | unknown"
      not_applicable_reason: ""
      target_customer: ""
      critical_problem: ""
      unique_value: ""
      success_signals: []
architecture_implications:
  - capability_id: D1
    boundary: "望ましい責務境界"
    investment_level: "high | medium | low | unknown"
    build_buy_reuse: "build | buy | reuse | not_applicable | unknown"
    rationale: ""
review_triggers: []
```

`kind: technical_capability`では`classification: not_applicable`とし、`domain_vision.status`も根拠付き`not_applicable`にする。business capability / subdomainだけが`core | supporting | generic`とdomain visionの適用判定を持つ。

## 完了条件

- [ ] コア分類が、技術的重要度ではなく顧客価値と競争優位性から説明されている。
- [ ] technical capabilityへcore / supporting / genericを付けず、品質・risk・operation基準へ接続している。
- [ ] 各分類に確認可能な根拠または検証仮説がある。
- [ ] `classification: core`なら、その価値が短いdomain vision声明として共有可能である。supporting / generic / technicalなら、非適用理由とvalue-preservation / risk statementがある。
- [ ] コアへ集中投資できる責務・依存境界が示されている。
- [ ] サブドメインにも、法令、セキュリティ、運用上必要な品質を残している。
- [ ] すべてを自作、すべてをDDD化、すべてをサービス分割していない。
- [ ] 分類の見直し条件がある。

## 失敗パターン

- 売上金額だけでコアを決め、将来の競争能力や顧客価値を無視する。
- 「重要な基盤だから」という理由だけで共通基盤をコアにする。
- コアのロジックを共通化しすぎ、独自性を消す。
- サブドメインを低品質でよい領域と誤解する。
- アーキテクチャ分離を、即座にマイクロサービス化と同一視する。
- ROIを厳密な架空数値で装い、不確実性を隠す。

## エージェント向けプロンプト骨子

```text
事業目標、顧客目的、ロードマップ、現在のコード境界から、ビジネス能力をコア・支援的・汎用サブドメインへ仮分類してください。

- 顧客が選ぶ理由、競争上の差、独自知識、変更頻度、失敗影響を根拠にする。
- 技術名や既存モジュール名だけでコアと判断しない。
- コア候補ごとにドメインビジョン声明を作る。
- 集中投資を妨げる依存と責務混在を指摘する。
- build / buy / reuse と設計投資レベルを提案する。
- 事実、仮説、確認が必要な判断を区別する。
```

## 他スキルとの接続

- 目的の階層化: `01-purpose-goal-means.md`
- 投資対象の負債評価: `04-technical-debt-goal-and-prioritization.md`
- コアとサブの境界: `05-purpose-based-bounded-contexts.md`
- アーキテクチャの段階的分離: `14-legacy-refactoring-by-purpose.md`

## 出典

- https://speakerdeck.com/minodriven/architecture-and-productivity
- https://speakerdeck.com/minodriven/design-for-profit
- https://speakerdeck.com/minodriven/ddd-in-ai-era
- https://levtech.jp/media/article/interview/detail_369/
- https://tech.stmn.co.jp/entry/2023/09/27/115301

> 公開資料を基に、投資判断、分類出力、見直し条件をSkill化のため再構成しています。

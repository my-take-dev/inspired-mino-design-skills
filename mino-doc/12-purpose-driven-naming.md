# 目的駆動で名前を設計する

## このノウハウの核

名前は可読性の飾りではなく、開発者の認知、責務のまとまり、クラス境界を方向付けます。曖昧な名前は、異なる目的の処理を同じ場所へ集めます。目的と役割が明白な名前は、どこへ何を置くべきか、何を置いてはいけないかを示します。

Skill は、既存の名詞やクラス名に引っ張られず、次から名前を導きます。

- 誰が使うか。
- 何の目的を達成するか。
- どの状況で有効か。
- 何を判断・変更・提供するか。
- どの責務を持たないか。

名前を改善しても説明しきれない場合は、責務分割が必要な兆候として扱います。

## 解決する問題

- `Manager`、`Service`、`Util`、`Helper`、`Data`、`Info`など、責務が分からない名前が増える。
- `User`、`Product`、`Common`など、範囲が大きすぎる名詞へ処理が集まる。
- `process`、`handle`、`execute`など、何を達成するか不明なメソッドがある。
- 一つの名前が複数の意味・目的を含む。
- 名前の説明に「〜もする」「場合によっては」が続く。
- 既存名に引っ張られ、新しいドメイン概念を発見できない。
- AIの命名提案が一般的で、対象業務の目的を表さない。

## 必要な入力

- 対象symbolのコード、呼び出し側、テスト。
- アクター、目的、ユースケース、文脈。
- 入力、出力、副作用、失敗。
- 状態と不変条件。
- 業務で実際に使われる言葉。
- 変更理由と、同時に変更されるsymbol。
- 現在の名前が付いた経緯が分かる履歴。

## 判断規則

### 1. 名前を付ける前に主語と目的を特定する

```text
誰のためのものか
何を達成するものか
何を所有するものか
何を保証するものか
```

例:

- `Product` → `OrderItem` / `InventoryItem` / `ShippingItem`
- `UserManager` → `CorporateAccountRegistrar`、`CustomerEligibilityPolicy`など実際の目的へ分解。
- `process` → `confirmOrder`、`reserveStock`、`issueInvoice`。

### 2. 名前の文法を責務診断に使う

- `And`、`Or`が必要: 複数責務の可能性。
- `Manager`、`Service`: 具体的な目的を再調査。
- `Common`、`Base`: 意味ではなく実装都合で共通化している可能性。
- `Data`、`Info`: 業務上の役割や制約が隠れている可能性。
- `Util`、static関数群: 所有すべき状態・概念から離れている可能性。
- 非常に長い名前: 一つのsymbolが多くを担っている可能性。

ただし、フレームワーク上の慣例名や明確なApplication Serviceまで機械的に否定しません。

### 3. 現在の名前を隠して候補を出す

アンカリングを避けるため、既存クラス名・テーブル名を一時的に見ず、ユースケース、目的、振る舞いから候補を作ります。その後、現在名と比較します。

### 4. 名詞は役割、動詞は結果を表す

- クラス・型: 文脈内の役割、所有状態、概念。
- command method: 何を実現する操作か。
- query method: 何を答えるか。
- event: 何が完了・発生したかを過去形で表す。
- boolean: 肯定形で真の意味が明確になるようにする。

技術的な手順ではなく、業務上の結果を名前へ優先します。

### 5. 名前は適用範囲を狭める

良い名前は「ここへ追加してよいもの」を示すと同時に「ここへ追加してはいけないもの」を示します。候補ごとに `in_scope` と `out_of_scope` を書き、境界として機能するか確認します。

### 6. 名前変更を小さな設計実験として使う

名前を目的に合わせて仮置きすると、合わないfieldやmethodが浮かびます。合わない要素が多い場合、Renameだけで済ませず分割計画へ進みます。

実際の参照更新は、可能な限りIDE、language server、compilerのRename機能で行います。AIに文字列検索と置換を全面委任しません。

## 実行手順

1. 対象symbolの利用箇所、状態、操作、副作用を調べる。
2. アクター、目的、文脈、主要責務を一文で書く。
3. 現在名を伏せ、業務用語と目的から名前候補を複数作る。
4. 各候補について、伝わる目的、曖昧さ、対象範囲、誤解リスクを比較する。
5. 新しい名前の下で、fieldとmethodを `fits / does-not-fit` に分類する。
6. 合わない要素が少なければRename、合わない要素が多ければ責務分割を提案する。
7. API、イベント、テスト、ログ、ドキュメントとの用語一貫性を確認する。
8. IDE等の安全なRenameを実行する。
9. コンパイル、型検査、テスト、検索で参照漏れを確認する。
10. 用語集と設計文書を更新する。

## 出力契約

```yaml
symbol:
  current_name: "UserManager"
  location: "path:symbol"
  actor: ""
  context: ""
  purpose: ""
  owned_responsibility: ""
  out_of_scope: []
name_candidates:
  - name: "CorporateAccountRegistrar"
    expresses: []
    ambiguity: []
    convention_fit: ""
    recommendation: "preferred | alternative | reject"
fit_analysis:
  - member: ""
    fits_purpose: true
    target_if_not: ""
decision:
  type: "rename | split-then-rename | keep"
  rationale: ""
rename_plan:
  mechanical_tool: "IDE / language server"
  affected_contracts: []
  validation: []
```

## 完了条件

- [ ] 名前がアクター、目的、文脈、役割の少なくとも必要な要素を表している。
- [ ] 一般的な接尾辞を、具体的責務の代わりに使っていない。
- [ ] 既存名を伏せた候補検討を行い、アンカリングを弱めている。
- [ ] 新しい名前に合わないメンバが分類されている。
- [ ] Renameで済むか、分割が必要かを区別している。
- [ ] コード、テスト、API、イベント、会話の用語が整合している。
- [ ] 参照更新は安全な機械的ツールを使う。
- [ ] 名前の長さではなく、意味と境界の明確さで評価している。

## 失敗パターン

- 既存名へ接尾辞を追加しただけで意味を変えない。
- すべての名前を長文化し、読む負荷を増やす。
- 名前変更だけで、多目的な内部構造を残す。
- 業務用語を確認せず、AIの一般知識から名前を作る。
- コンテキストが違うのに、全社で一つの呼び名へ統一する。
- DBカラム名に引っ張られ、ドメイン上の役割を表さない。
- 手動置換で文字列、設定、別symbolを誤変更する。

## エージェント向けプロンプト骨子

```text
対象symbolの名前を、目的駆動で再設計してください。

1. コードと利用箇所から、アクター、文脈、目的、所有状態、主要操作、対象外を特定する。
2. 既存名を前提にせず、業務上の役割と結果から複数候補を作る。
3. Manager、Service、Util、Common、Data等の曖昧語を使う場合は必要性を説明する。
4. 候補ごとに、伝わる目的、適用範囲、誤解リスク、プロジェクト規約への適合を比較する。
5. 推奨名に合わないfield/methodを示し、Renameか責務分割かを判断する。
6. 実変更はIDE等のRenameを使う前提で、影響契約と検証を示す。
```

## 他スキルとの接続

- 文脈別用語: `06-ubiquitous-language-and-context.md`
- 見えない概念の発見: `07-invisible-driven-modeling.md`
- 抽象化: `13-purpose-driven-abstraction.md`
- AIとIDEの役割分担: `15-ai-assisted-refactoring.md`

## 出典

- https://speakerdeck.com/minodriven/effective-learning-of-good-code
- https://speakerdeck.com/minodriven/ai-refactoring-approach
- https://speakerdeck.com/minodriven/purpose-abstraction-design
- https://levtech.jp/media/article/interview/detail_369/

> 公開資料を基に、アンカリング回避、fit分析、Rename判定をSkill化のため再構成しています。

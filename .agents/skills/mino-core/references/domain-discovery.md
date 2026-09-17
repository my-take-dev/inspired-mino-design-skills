# Domain discovery viewpoints

## Scope and discovery

actor+context+purposeから始め、意味・rule・lifecycle・authorityの変化点をcontext候補にする。DB columnや既存class名から業務上の意味を確定しない。目的、判断、約束、権利、責任、制約、失敗のような見えない概念も対象とする。

結果を分岐させる用語を選び、同じ具体例と反例で解釈を比較する。業務ルール不明の例はassumptionとし、実在Evidenceに昇格しない。同じ名前で異なる意味を無理に統一せずtranslationを定義する。context発見とservice分割の採用は別判断である。

## Terms and translation

意味の別名をfree textで複製せず、canonical termへ参照する。source/targetのcontext/term IDは独立fieldのまま保持し、図や結合文字列で代用しない。

## Context relationships

failure owner、retry、duplicate、曖昧結果を関係ごとに独立判定する。transportの再送実装から業務上の再試行許可を推定しない。N/Aには理由とEvidence、unknownには確認方法と影響を残す。requiredな意味が未決なら後続へobligationを返す。

## Output and integrity

invisible conceptにはrequired information、behavior、invariant、lifecycle、out_of_scopeとEvidenceを残す。current symbolとのmappingを示し、別目的・技術関心・不要要素を分ける。destruction probeは思考実験か使い捨てfixtureに限定する。

term/context/translation/relationshipの全参照を実在IDへ解決する。未解決はfailであり、unknownの説明文章で参照切れを隠さない。正本packageを作る場合だけ`skills/mino-core/schemas/discovery.md`を読み、個別IDと未知を保存する。図は補助であって正本の代わりではない。

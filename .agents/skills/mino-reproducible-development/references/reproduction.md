# 再現性の比較

同じ問題・要件・契約・品質・公開境界を異なる実装が満たすかを比較する。code文字列の一致は求めない。

## 実行

1. 比較する入力、要求・契約、対象revision、oracle、required platform、成功・拒否条件を固定する。候補を承認済みbaselineと呼ばない。
2. 各solverをfresh contextと使い捨てworkspaceで実行する。raw request、必要な原資料、利用可能なSkillだけを渡し、採点oracle・期待回答・他runの結論を見せない。本番dataや外部副作用を操作しない。
3. runごとに入力・出力のexact bytesとdigest、使用したSkill一式とdigest、実効設定、workspaceと隔離方法、tool結果、実行/未実行を記録する。取得不能な値はunknownとする。
4. evaluatorは出力と原資料を照合してoracleで採点し、各失敗の再現条件と影響を残す。solverとevaluatorのcontextを分ける。同じ履歴のforkや自己reviewを独立評価へ数えない。
5. 複数回・required platformごとの結果を分ける。未実行runは0 run / not_executedとする。少数例の成功から安定性を主張せず、母数・除外理由・未実行を示す。

## 判定

構造検査、意味の充足、対象applicationのruntime成功を別に返す。token・時間・費用は実測した値だけを比較し、低費用を品質同等の根拠にしない。承認・baseline・設定・入力/出力・隔離のEvidenceが不足するrunは参考結果へ分離する。

報告はrun一覧、要求・契約・oracleへのtrace、欠陥と反例、未確認、必要な再実行条件を持つ。release採用は依頼範囲と権限あるownerのEvidenceへ分ける。

# 品質の定義

品質catalogはContext Packetのquality_lens.definitionsを正本にする。要件・Architectureは実在quality IDを参照し、同じ定義を再決定しない。

- characteristicではsubcharacteristicをnot_applicable、subcharacteristicでは両方を保持する。
- 規格を使う場合だけEvidenceのあるeditionをreference_modelへ記録する。根拠がなければproject_definedとし、未確認の規格対応を作らない。日本語表示と出典の語を区別する。
- latency thresholdやSLOは分類名ではなくscenario/constraint。刺激・対象・環境・期待応答・oracle・owner・Evidence・計測計画へ接続する。
- primary / secondary / constraint / intentionally_not_optimizedを選び、理由と再評価条件を持つ。local改善とsystem/journey/organization/future-changeへの影響を分ける。
- 正本catalogを新規保存する場合だけ`skills/mino-core/schemas/core.md`のquality_definitionとquality_lensを使う。

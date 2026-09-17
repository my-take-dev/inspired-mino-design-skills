# Platform compatibility

## Applicability and execution

file/path/permission、process/shell、test/build、migration、複数OSを扱う前に読む。意味と契約は共通、OS差はenvironment/adapterへ分離する。WindowsのPowerShell、Linux/macOSのBashを同じ入出力・検査・exit契約で用意する。共用Bash scriptは3.2 subsetとする。

論理pathはskills rootから解決し、外部入力をshell文字列へ連結しない。path引数をquoteし、drive、case、Unicode、reserved name、line ending、lock、permission、symlink/junction、atomic rename、終了signalを暗黙に同一視しない。固定physical pathをSkillに埋め込まない。

## Platform Context

host、process、保存先を別々に観測する。WSLでWindows processを実行した結果をnative NTFS検証へ流用しない。filesystem形式を観測せずAPFS等へ具体化しない。

## Validation layers

- structural_validator: package、metadata、logical path、UTF-8、validator自身の互換性。
- native_filesystem: native checkoutのcase、permission、link、lock、rename等。
- application_runtime: 同じ要求・契約・oracleによる対象applicationの実行。

層間でpassを継承しない。Linux上のBash3.2もnative macOSのEvidenceではない。未実行OSは必要runnerとcommandを記録する。

## Validation records and gate

trace_not_applicableはtarget_kind、target_id_or_scope、reason、evidenceを持つrecordで、IDの一括省略を正当化しない。未実行recordはrunnerとcommandを別fieldに保つ。

required platform/layerの一つでも失敗すればfail、失敗がなく未実行が残ればincompleteとする。全required platformで同じ対象IDとoracleが解決して成功した場合だけpass。N/Aは要求範囲と根拠付きの場合だけ使う。

正本packageを作る場合だけ`skills/mino-core/schemas/platform.md`を読み、host・process・保存先・実行/未実行を保存する。

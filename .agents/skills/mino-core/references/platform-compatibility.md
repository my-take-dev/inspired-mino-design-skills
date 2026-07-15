# Windows and Linux compatibility

filesystem、process、shell、toolchain、test実行を伴うFunctionは、WindowsとLinuxの差をimplementation detailとして管理し、同じ要件と契約を両platformで検証する。

## Contents

- Scope
- Platform Context
- Evidence layers
- Execution rules
- Cross-platform verification
- Output and gate

## Scope

次のいずれかを行う場合に使う。

- file、directory、path、permission、symlink、temporary resourceを扱う
- child process、signal、environment variable、shell commandを扱う
- formatter、test、build、static analysis、migrationを実行する
- WindowsとLinuxの両方で動作する成果物または運用手順を設計・検証する

業務ruleをOSごとに再定義するためには使わない。OS差分はCore、domain contract、public boundaryを上書きせず、implementationまたは明示されたenvironment conditionへ翻訳する。

## Platform Context

command実行前に、推測ではなくruntime evidenceから次を記録する。

```yaml
platform_context:
  host_platform: windows | linux | unknown
  process_platform: windows | linux | unknown
  artifact_filesystem: native_ntfs | linux_filesystem | wsl_linux_via_unc | other | unknown
  target_platforms: []
  shell: powershell | bash | other | none
  architecture: ""
  filesystem:
    case_sensitive: true | false | unknown
    path_style: windows | posix | unknown
    executable_bit: supported | unsupported | unknown
  toolchain:
    commands: []
    versions: []
  platform_requirements: []
  unknowns: []
```

- `host_platform`は作業をorchestrateする環境、`process_platform`は検証commandが動くruntime、`artifact_filesystem`は検査対象artifactの保存先を表す。同じ値と仮定しない。
- WindowsではPowerShellのruntime情報、Linuxでは`uname`など、その環境で取得可能な観測結果をEvidenceにする。
- WSL、container、remote runnerでは、操作対象のfilesystemとprocessが属するplatformをhost名だけで決めない。
- 実行を伴わないdesign / reviewでは、targetを記録し、hostで未確認の挙動を`unknown`または未実行検証として残す。

## Evidence layers

同じ「Windows / Linux検証」へ異なる強さのEvidenceを混ぜない。各validation recordへ次のlayerを付ける。

- `structural_validator`: package、metadata、logical path、text format、validator runtime compatibilityを検査する。Windows PowerShell processがWSL UNC上のartifactを読んだ結果はこのlayerであり、native NTFSまたはapplication runtime Evidenceではない。
- `native_filesystem`: native Windows checkout / NTFSまたはLinux filesystem上で、case、permission、junction / symlink、lock、rename、delete等のfilesystem behaviorを検査する。
- `application_runtime`: 対象applicationについて同じrequirement、contract、verification、oracleをWindows / Linuxで実行する。

あるlayerのpassを別layerへ継承しない。required layerが未実行なら、必要runner、artifact filesystem、command、ownerを`unexecuted`へ残す。

## Execution rules

1. Skill内部の論理pathは常に`skills/`をrootとし、物理pathへ解決するときだけruntimeのpath APIを使う。
2. pathを文字列連結しない。言語標準のpath API、PowerShellのpath cmdlet、またはLinux toolへ引数を分けて渡す。
3. 共通workflowへ一方のshell構文を埋め込まない。shellが必要ならWindows用PowerShellとLinux用Bashを分け、同じ入出力契約を持たせる。
4. shellを介さず実行可能なtoolchain commandを優先する。外部入力をcommand文字列へ連結しない。
5. path separator、drive / root、予約名、case sensitivity、Unicode、最大path長を暗黙に固定しない。
6. CRLF / LF、final newline、encodingを意味の差として扱わない。意味がある場合だけ契約へ昇格する。
7. Linuxのpermission / executable bit / symlinkと、WindowsのACL / file lock / junction等の差を必要範囲で検証する。
8. temporary directory、home directory、environment variableはruntime APIから取得し、固定physical pathを使わない。
9. process終了、signal、file locking、atomic replace、timezoneの差がfailure stateやrecoveryへ影響する場合は、platform別scenarioを作る。
10. platform固有scriptを対で提供する場合は、入力、検査項目、exit status、主要messageを同じ契約に保つ。

## Cross-platform verification

WindowsとLinuxの両対応を要件に含む場合、同じrequirement IDとtest oracleを使い、platformごとに実行結果を分ける。

各platform recordは、実行したcommandだけでなく、共通のrequirement、contract、verification、oracleへの参照を保持する。識別子を後から説明文で推測せず、実行前に記録したstable IDを使う。

最低限、対象に応じて次を確認する。

- clean checkoutまたは同等の隔離artifactからの起動
- path解決、case違い、separator違い
- text encodingとCRLF / LF
- test、build、static analysisのexit status
- scriptの実行権限とinterpreter選択
- file lock、rename、delete、temporary resource cleanup
- failure、retry、cancellation、recovery

一方のplatformだけで成功しても、両対応を`verified`にしない。利用できないplatformは、実行予定command、必要runner、owner、未実行理由を分離して`unexecuted`へ残す。platform非依存の静的確認は補助Evidenceであり、未実行platformのruntime Evidenceを代替しない。

## Output and gate

```yaml
platform_validation:
  required_platforms: []
  executed:
    - platform: windows | linux
      evidence_layer: structural_validator | native_filesystem | application_runtime
      process_platform: windows | linux | unknown
      artifact_filesystem: native_ntfs | linux_filesystem | wsl_linux_via_unc | other | unknown
      requirement_ids: []
      contract_ids: []
      verification_ids: []
      oracle_refs: []
      trace_not_applicable:
        - target_kind: requirement | contract | verification | oracle
          target_id_or_scope: ""
          reason: ""
          evidence: []
      commands: []
      result: pass | fail
      evidence: []
  unexecuted:
    - platform: windows | linux
      evidence_layer: structural_validator | native_filesystem | application_runtime
      process_platform: windows | linux | unknown
      artifact_filesystem: native_ntfs | linux_filesystem | wsl_linux_via_unc | other | unknown
      requirement_ids: []
      contract_ids: []
      verification_ids: []
      oracle_refs: []
      trace_not_applicable:
        - target_kind: requirement | contract | verification | oracle
          target_id_or_scope: ""
          reason: ""
          evidence: []
      reason: ""
      required_runner: ""
      planned_commands: []
      owner: ""
      evidence: []
  parity_result: pass | fail | incomplete | not_applicable
  platform_specific_risks: []
```

`trace_not_applicable`の各recordは`skills/mino-core/references/requirements-and-traceability.md`の`not_applicable`と同じく、`target_kind`、`target_id_or_scope`、`reason`、`evidence`を持つ。識別子の欠落を一括した空配列で正当化しない。

`unexecuted`は未実行を成功や失敗へ丸めないためのrecordである。`required_runner`と`planned_commands`を一つのfree textへ結合せず、再実行責任を持つ`owner`、未実行を確認できる`evidence`とともに保持する。

- required platformでcommandまたはtestが失敗した場合はverification gateをpassにしない。
- required platformが未実行なら`parity_result: incomplete`とし、両対応を検証済みと表現しない。
- `structural_validator`のpassを`native_filesystem`または`application_runtime`へ流用せず、Windows processが`wsl_linux_via_unc`上でpassした結果をnative NTFS Evidenceと表現しない。
- `parity_result: pass`は、全required platformがpassし、各recordの`requirement_ids`、`contract_ids`、`verification_ids`、`oracle_refs`を正規化した集合が一致する場合だけ許可する。applicableな識別子を空配列で省略せず、非該当なら対象と理由を`trace_not_applicable`へ残す。
- OS差分がpublic contractへ漏れる場合は、明示要件とownerがない限りboundary findingにする。
- OS差分から業務rule、data meaning、品質優先度を推測しない。

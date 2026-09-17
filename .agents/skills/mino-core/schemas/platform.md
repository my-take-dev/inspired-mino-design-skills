# 保存用schema

依頼された正本packageを作る場合だけ読む。既存artifactはhandleとrevisionで参照再利用する。未知は空欄で隠さず、非該当には理由を残す。

## Contents

- platform_context
- platform_validation

## platform_context

```yaml
platform_context:
  host_platform: windows | linux | macos | unknown
  process_platform: windows | linux | macos | unknown
  artifact_filesystem: native_ntfs | linux_filesystem | native_macos_filesystem | wsl_linux_via_unc | other | unknown
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

## platform_validation

```yaml
platform_validation:
  required_platforms: []
  executed:
    - platform: windows | linux | macos
      evidence_layer: structural_validator | native_filesystem | application_runtime
      process_platform: windows | linux | macos | unknown
      artifact_filesystem: native_ntfs | linux_filesystem | native_macos_filesystem | wsl_linux_via_unc | other | unknown
      requirement_ids: []
      contract_ids: []
      verification_ids: []
      oracle_refs: []
      trace_not_applicable: []
      commands: []
      result: pass | fail
      evidence: []
  unexecuted:
    - platform: windows | linux | macos
      evidence_layer: structural_validator | native_filesystem | application_runtime
      process_platform: windows | linux | macos | unknown
      artifact_filesystem: native_ntfs | linux_filesystem | native_macos_filesystem | wsl_linux_via_unc | other | unknown
      requirement_ids: []
      contract_ids: []
      verification_ids: []
      oracle_refs: []
      trace_not_applicable: []
      reason: ""
      required_runner: ""
      planned_commands: []
      owner: ""
      evidence: []
  parity_result: pass | fail | incomplete | not_applicable
  platform_specific_risks: []
```

trace_not_applicableはtarget_kind、target_id_or_scope、reason、evidenceを持つ。未実行はrequired_runnerとplanned_commandsを独立fieldで保持する。層とOSの判定は`skills/mino-core/references/platform-compatibility.md`へ照合する。

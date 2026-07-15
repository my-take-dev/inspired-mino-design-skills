#!/usr/bin/env bash

set -uo pipefail

usage() {
  cat <<'USAGE'
Usage: test-validator-fixtures.sh [--skills-root PATH]

Runs positive and negative validator fixtures with the Bash validator.
The active Bash executable is reused so Linux Bash 3.2 and macOS /bin/bash
exercise the same runtime as this fixture runner.
USAGE
}

skills_root=""
while (($# > 0)); do
  case "$1" in
    --skills-root)
      if (($# < 2)); then
        echo "Missing value for --skills-root" >&2
        exit 2
      fi
      skills_root=$2
      shift 2
      ;;
    -h | --help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 2
      ;;
  esac
done

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P) || exit 2
if [[ -z $skills_root ]]; then
  skill_dir=$(dirname "$script_dir")
  skills_root=$(dirname "$skill_dir")
  skills_root=$(cd "$skills_root" && pwd -P) || exit 2
elif [[ -d $skills_root ]]; then
  skills_root=$(cd "$skills_root" && pwd -P) || exit 2
else
  echo "Skills root not found: $skills_root" >&2
  exit 2
fi

manifest_file="$skills_root/mino-core/scripts/suite-manifest.txt"
suite_version_lines=()
while IFS= read -r suite_version_line || [[ -n $suite_version_line ]]; do
  suite_version_lines+=("$suite_version_line")
done < <(sed -n 's/^suite_version=//p' "$manifest_file")
if ((${#suite_version_lines[@]} != 1)) || [[ -z ${suite_version_lines[0]} ]]; then
  echo "Expected exactly one non-empty suite_version in $manifest_file" >&2
  exit 2
fi
suite_version=${suite_version_lines[0]}
fixture_root="mino-core/evaluations/fixtures/$suite_version"
case_relative="mino-core/evaluations/cases/$suite_version.md"

tmp_root=$(mktemp -d) || exit 2
trap 'rm -rf "$tmp_root"' EXIT

total=0
passed=0
failed=0
case_skills=""

prepare_case() {
  local name=$1
  local case_root="$tmp_root/$name"
  mkdir -p "$case_root" || exit 2
  case_skills="$case_root/skills"
  cp -R "$skills_root" "$case_skills" || exit 2
}

fixture_capability_failure() {
  printf 'Fixture runner prerequisite failure: %s\n' "$1" >&2
  exit 2
}

rewrite_fixture() {
  local path=$1
  local operation=$2
  local match=${3-}
  local replacement=${4-}
  local replacement_file=""
  local temporary
  local rewrite_status

  temporary=$(mktemp "$tmp_root/rewrite.XXXXXX") || \
    fixture_capability_failure "could not create a rewrite file"

  case $operation in
    insert-before-prefix | replace-first-prefix | replace-first-exact | replace-line)
      replacement_file=$(mktemp "$tmp_root/replacement.XXXXXX") || \
        fixture_capability_failure "could not create a replacement file"
      if ! printf '%s\n' "$replacement" >"$replacement_file"; then
        rm -f "$temporary" "$replacement_file"
        fixture_capability_failure "could not write a replacement file"
      fi
      ;;
  esac

  case $operation in
    insert-before-prefix)
      awk -v prefix="$match" -v replacement_file="$replacement_file" '
        function emit_replacement( line, status) {
          while ((status = getline line < replacement_file) > 0) print line
          close(replacement_file)
          if (status < 0) exit 43
        }
        !changed && index($0, prefix) == 1 {
          changed = 1
          emit_replacement()
        }
        { print }
        END { if (!changed) exit 42 }
      ' "$path" >"$temporary"
      rewrite_status=$?
      ;;
    replace-first-prefix)
      awk -v prefix="$match" -v replacement_file="$replacement_file" '
        function emit_replacement( line, status) {
          while ((status = getline line < replacement_file) > 0) print line
          close(replacement_file)
          if (status < 0) exit 43
        }
        !changed && index($0, prefix) == 1 {
          changed = 1
          emit_replacement()
          next
        }
        { print }
        END { if (!changed) exit 42 }
      ' "$path" >"$temporary"
      rewrite_status=$?
      ;;
    replace-first-exact)
      awk -v target="$match" -v replacement_file="$replacement_file" '
        function emit_replacement( line, status) {
          while ((status = getline line < replacement_file) > 0) print line
          close(replacement_file)
          if (status < 0) exit 43
        }
        !changed && $0 == target {
          changed = 1
          emit_replacement()
          next
        }
        { print }
        END { if (!changed) exit 42 }
      ' "$path" >"$temporary"
      rewrite_status=$?
      ;;
    replace-line)
      awk -v line_number="$match" -v replacement_file="$replacement_file" '
        function emit_replacement( line, status) {
          while ((status = getline line < replacement_file) > 0) print line
          close(replacement_file)
          if (status < 0) exit 43
        }
        NR == line_number {
          changed = 1
          emit_replacement()
          next
        }
        { print }
        END { if (!changed) exit 42 }
      ' "$path" >"$temporary"
      rewrite_status=$?
      ;;
    delete-first-exact)
      awk -v target="$match" '
        !changed && $0 == target { changed = 1; next }
        { print }
        END { if (!changed) exit 42 }
      ' "$path" >"$temporary"
      rewrite_status=$?
      ;;
    flatten-agent-metadata)
      awk '
        $0 == "interface:" || $0 == "policy:" { removed = 1; next }
        { sub(/^  /, ""); print }
        END { if (!removed) exit 42 }
      ' "$path" >"$temporary"
      rewrite_status=$?
      ;;
    replace-helper-with-failure)
      awk 'BEGIN { print "#!/usr/bin/env bash"; print "exit 2" }' >"$temporary"
      rewrite_status=$?
      ;;
    *)
      rm -f "$temporary"
      fixture_capability_failure "unknown rewrite operation: $operation"
      ;;
  esac

  if [[ -n $replacement_file ]] && ! rm -f "$replacement_file"; then
    rm -f "$temporary"
    fixture_capability_failure "could not remove a replacement file"
  fi

  if ((rewrite_status != 0)); then
    rm -f "$temporary"
    fixture_capability_failure "rewrite '$operation' failed for $path with exit $rewrite_status"
  fi
  if ! mv -f "$temporary" "$path"; then
    rm -f "$temporary"
    fixture_capability_failure "could not replace rewritten fixture: $path"
  fi
}

check_result() {
  local name=$1
  local expected_status=$2
  local expected_text=$3
  local manifest_relative=${4-}
  local expected_error_count=${5-}
  local forbidden_text=${6-}
  local expected_capability_count=${7-}
  local validator="$case_skills/mino-core/scripts/validate-suite.sh"
  local output
  local status
  local command=("$BASH" "$validator" --skills-root "$case_skills")
  if [[ -n $manifest_relative ]]; then
    command+=(--manifest-file "$case_skills/$manifest_relative")
  fi
  output=$("${command[@]}" 2>&1)
  status=$?
  ((total += 1))
  if ((status == expected_status)) &&
    { [[ -z $expected_text ]] || grep -Fq "$expected_text" <<<"$output"; } &&
    { [[ -z $expected_error_count ]] || grep -Fq "Errors: $expected_error_count;" <<<"$output"; } &&
    { [[ -z $forbidden_text ]] || ! grep -Fq "$forbidden_text" <<<"$output"; } &&
    { [[ -z $expected_capability_count ]] || grep -Fq "Capability errors: $expected_capability_count" <<<"$output"; }; then
    ((passed += 1))
    printf 'PASS %s\n' "$name"
  else
    ((failed += 1))
    printf 'FAIL %s: expected exit %d, text %q, error count %q, forbidden text %q, and capability count %q; got exit %d\n%s\n' \
      "$name" "$expected_status" "$expected_text" "$expected_error_count" \
      "$forbidden_text" "$expected_capability_count" "$status" "$output" >&2
  fi
}

prepare_case positive
check_result positive 0 ''

prepare_case unrelated-skill-ignored
mkdir -p -- "$case_skills/unrelated-skill"
printf 'not part of the mino suite\r\n' >"$case_skills/unrelated-skill/SKILL.md"
check_result unrelated-skill-ignored 0 ''

prepare_case unlisted-mino-skill
mkdir -p -- "$case_skills/mino-unlisted"
printf 'not listed in the suite manifest\n' >"$case_skills/mino-unlisted/SKILL.md"
check_result unlisted-mino-skill 1 \
  'Skill directory is not listed in suite manifest: skills/mino-unlisted' '' 1

missing_output=$("$BASH" "$skills_root/mino-core/scripts/validate-suite.sh" \
  --skills-root "$tmp_root/does-not-exist" 2>&1)
missing_status=$?
((total += 1))
if ((missing_status == 2)) && grep -Fq 'Skills root not found' <<<"$missing_output"; then
  ((passed += 1))
  printf 'PASS missing-skills-root\n'
else
  ((failed += 1))
  printf 'FAIL missing-skills-root: expected exit 2; got exit %d\n%s\n' \
    "$missing_status" "$missing_output" >&2
fi

unknown_output=$("$BASH" "$skills_root/mino-core/scripts/validate-suite.sh" --unknown 2>&1)
unknown_status=$?
((total += 1))
if ((unknown_status == 2)) && grep -Fq 'Unknown argument: --unknown' <<<"$unknown_output"; then
  ((passed += 1))
  printf 'PASS unknown-argument\n'
else
  ((failed += 1))
  printf 'FAIL unknown-argument: expected exit 2; got exit %d\n%s\n' \
    "$unknown_status" "$unknown_output" >&2
fi

missing_value_output=$("$BASH" "$skills_root/mino-core/scripts/validate-suite.sh" --skills-root 2>&1)
missing_value_status=$?
((total += 1))
if ((missing_value_status == 2)) && grep -Fq 'Missing value for --skills-root' <<<"$missing_value_output"; then
  ((passed += 1))
  printf 'PASS missing-option-value\n'
else
  ((failed += 1))
  printf 'FAIL missing-option-value: expected exit 2; got exit %d\n%s\n' \
    "$missing_value_status" "$missing_value_output" >&2
fi

for fixture_spec in \
  'empty-key|Invalid suite manifest line|manifest-empty-key.txt|' \
  'duplicate-suite-version|Duplicate suite_version|manifest-duplicate-suite-version.txt|1' \
  'duplicate-owner|Duplicate owner|manifest-duplicate-owner.txt|1' \
  'duplicate-skill|Duplicate suite skill|manifest-duplicate-skill.txt|1' \
  'invalid-version|Invalid suite_version|manifest-invalid-version.txt|' \
  'invalid-version-separator|Invalid suite_version|manifest-invalid-version-separator.txt|' \
  'leading-zero-version|Invalid suite_version|manifest-leading-zero-version.txt|' \
  'invalid-skill|Invalid suite skill name|manifest-invalid-skill.txt|'; do
  IFS='|' read -r name expected fixture expected_error_count <<<"$fixture_spec"
  prepare_case "$name"
  check_result "$name" 1 "$expected" "$fixture_root/$fixture" "$expected_error_count"
done

prepare_case solver-field-allowlist
rewrite_fixture "$case_skills/$case_relative" insert-before-prefix 'mode:' \
  'expected_skill: mino-core'
check_result solver-field-allowlist 1 'unsupported top-level field: expected_skill'

prepare_case solver-nested-metadata
rewrite_fixture "$case_skills/$case_relative" replace-first-prefix 'confirmed_evidence:' \
  $'confirmed_evidence:\n  expected_skill: mino-core'
check_result solver-nested-metadata 1 'nested mapping field: expected_skill'

prepare_case stale-version-heading
rewrite_fixture "$case_skills/$case_relative" replace-first-exact \
  "# Evaluation cases $suite_version" '# Evaluation cases 0.0.0'
check_result stale-version-heading 1 'heading does not match suite_version'

prepare_case malformed-frontmatter-delimiter
rewrite_fixture "$case_skills/mino-core/SKILL.md" replace-line 4 '---junk'
check_result malformed-frontmatter-delimiter 1 'Invalid frontmatter'

prepare_case frontmatter-name-trailing-garbage
rewrite_fixture "$case_skills/mino-core/SKILL.md" replace-first-exact \
  'name: mino-core' 'name: "mino-core" trailing'
check_result frontmatter-name-trailing-garbage 1 'Skill name must match folder'

prepare_case flattened-agent-metadata
rewrite_fixture "$case_skills/mino-core/agents/openai.yaml" flatten-agent-metadata
check_result flattened-agent-metadata 1 'Invalid agents/openai.yaml structure'

prepare_case prompt-token-wrong-field
rewrite_fixture "$case_skills/mino-core/agents/openai.yaml" replace-first-exact \
  '  display_name: "Shared Core"' '  display_name: "Shared Core $mino-core"'
rewrite_fixture "$case_skills/mino-core/agents/openai.yaml" replace-first-exact \
  '  default_prompt: "Use $mino-core only as the internal foundation of another mino skill; hand public Problem Frame requests to $mino-problem-framing."' \
  '  default_prompt: "Use mino-core only as the internal foundation of another mino skill; hand public Problem Frame requests to $mino-problem-framing."'
check_result prompt-token-wrong-field 1 'default_prompt must mention $mino-core'

prepare_case unicode-scalar-length
short_value="$(printf '%063s' '' | tr ' ' a)😀"
rewrite_fixture "$case_skills/mino-core/agents/openai.yaml" replace-first-prefix \
  '  short_description:' "  short_description: \"$short_value\""
check_result unicode-scalar-length 0 ''

prepare_case bare-runtime-path
invalid_asset='shared-policies'".md"
printf '\n`%s`\n' "$invalid_asset" >>"$case_skills/mino-core/references/core.md"
check_result bare-runtime-path 1 "Runtime asset path must start with 'skills/'"

prepare_case noncanonical-logical-path
invalid_logical_path='skills/'"/mino-core/SKILL.md"
printf '\n`%s`\n' "$invalid_logical_path" >>"$case_skills/mino-core/references/core.md"
check_result noncanonical-logical-path 1 'Invalid skills-rooted path'

prepare_case link-escape
outside_reference_dir="$tmp_root/link-escape-outside"
mkdir -p -- "$outside_reference_dir"
printf '# Outside probe\n' >"$outside_reference_dir/probe.md"
ln -s "$outside_reference_dir" "$case_skills/mino-core/references/external-link"
printf '\n`skills/mino-core/references/external-link/probe.md`\n' >>"$case_skills/mino-core/references/core.md"
check_result link-escape 1 'Skills-rooted path must not traverse a link'

prepare_case missing-contents
rewrite_fixture "$case_skills/mino-core/references/benchmark.md" delete-first-exact '## Contents'
check_result missing-contents 1 'Reference over 100 lines has no Contents section'

prepare_case uppercase-extension-format
printf 'no final newline' >"$case_skills/mino-core/references/Upper.MD"
check_result uppercase-extension-format 1 'Text file must end with a newline'

prepare_case utf8-valid-ascii
printf '%s\n' 'portable ASCII text' >"$case_skills/mino-core/scripts/utf8-probe.txt"
check_result utf8-valid-ascii 0 ''

prepare_case utf8-valid-japanese
printf '%s\n' '正しい日本語のUTF-8' >"$case_skills/mino-core/scripts/utf8-probe.txt"
check_result utf8-valid-japanese 0 ''

prepare_case utf8-valid-emoji
printf '%s\n' 'four-byte emoji 😀' >"$case_skills/mino-core/scripts/utf8-probe.txt"
check_result utf8-valid-emoji 0 ''

for invalid_utf8_spec in \
  'utf8-continuation-byte|\0200\n|1' \
  'utf8-truncated-sequence|\0342\0202|2' \
  'utf8-overlong-sequence|\0300\0200\n|1' \
  'utf8-surrogate-sequence|\0355\0240\0200\n|1' \
  'utf8-above-unicode-maximum|\0364\0220\0200\0200\n|1'; do
  IFS='|' read -r invalid_name invalid_bytes invalid_error_count <<<"$invalid_utf8_spec"
  prepare_case "$invalid_name"
  printf '%b' "$invalid_bytes" >"$case_skills/mino-core/scripts/utf8-probe.txt"
  check_result "$invalid_name" 1 'Text file is not valid UTF-8' '' "$invalid_error_count"
done

prepare_case utf8-bom
printf '%b' '\0357\0273\0277valid\n' >"$case_skills/mino-core/scripts/utf8-probe.txt"
check_result utf8-bom 1 'UTF-8 BOM is not allowed' '' 1

prepare_case crlf
printf '%b' 'line\r\n' >"$case_skills/mino-core/scripts/utf8-probe.txt"
check_result crlf 1 'CR or CRLF is not allowed' '' 1

prepare_case utf8-backend-failure
rewrite_fixture "$case_skills/mino-core/scripts/validate-utf8.sh" replace-helper-with-failure
check_result utf8-backend-failure 2 'UTF-8 validation is unavailable: backend self-test failed' \
  '' 0 'Text file is not valid UTF-8' 1

prepare_case utf8-backend-missing
if ! mv "$case_skills/mino-core/scripts/validate-utf8.sh" \
  "$case_skills/mino-core/scripts/validate-utf8.sh.missing"; then
  fixture_capability_failure 'could not remove the UTF-8 backend fixture'
fi
check_result utf8-backend-missing 2 'UTF-8 validation is unavailable: backend helper is missing' \
  '' 2 'Text file is not valid UTF-8' 1

prepare_case capability-priority
rewrite_fixture "$case_skills/mino-core/scripts/validate-utf8.sh" replace-helper-with-failure
check_result capability-priority 2 'Duplicate owner' \
  "$fixture_root/manifest-duplicate-owner.txt" 1 'Text file is not valid UTF-8' 1

printf 'Validator fixtures: %d passed, %d failed, %d total\n' "$passed" "$failed" "$total"
if ((failed > 0)); then
  exit 1
fi

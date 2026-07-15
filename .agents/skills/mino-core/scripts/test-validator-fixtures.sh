#!/usr/bin/env bash

set -uo pipefail

usage() {
  cat <<'USAGE'
Usage: test-validator-fixtures.sh [--skills-root PATH]

Runs positive and negative validator fixtures with the Linux validator.
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

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P) || exit 2
if [[ -z $skills_root ]]; then
  skill_dir=$(dirname -- "$script_dir")
  skills_root=$(dirname -- "$skill_dir")
  skills_root=$(cd -- "$skills_root" && pwd -P) || exit 2
elif [[ -d $skills_root ]]; then
  skills_root=$(cd -- "$skills_root" && pwd -P) || exit 2
else
  echo "Skills root not found: $skills_root" >&2
  exit 2
fi

manifest_file="$skills_root/mino-core/scripts/suite-manifest.txt"
mapfile -t suite_version_lines < <(sed -n 's/^suite_version=//p' "$manifest_file")
if ((${#suite_version_lines[@]} != 1)) || [[ -z ${suite_version_lines[0]} ]]; then
  echo "Expected exactly one non-empty suite_version in $manifest_file" >&2
  exit 2
fi
suite_version=${suite_version_lines[0]}
fixture_root="mino-core/evaluations/fixtures/$suite_version"
case_relative="mino-core/evaluations/cases/$suite_version.md"

tmp_root=$(mktemp -d) || exit 2
trap 'rm -rf -- "$tmp_root"' EXIT

total=0
passed=0
failed=0
case_skills=""

prepare_case() {
  local name=$1
  local case_root="$tmp_root/$name"
  mkdir -p -- "$case_root" || exit 2
  case_skills="$case_root/skills"
  cp -R -- "$skills_root" "$case_skills" || exit 2
}

check_result() {
  local name=$1
  local expected_status=$2
  local expected_text=$3
  local manifest_relative=${4-}
  local expected_error_count=${5-}
  local validator="$case_skills/mino-core/scripts/validate-suite.sh"
  local output
  local status
  local command=(bash "$validator" --skills-root "$case_skills")
  if [[ -n $manifest_relative ]]; then
    command+=(--manifest-file "$case_skills/$manifest_relative")
  fi
  output=$("${command[@]}" 2>&1)
  status=$?
  ((total += 1))
  if ((status == expected_status)) &&
    { [[ -z $expected_text ]] || grep -Fq "$expected_text" <<<"$output"; } &&
    { [[ -z $expected_error_count ]] || grep -Fq "Errors: $expected_error_count;" <<<"$output"; }; then
    ((passed += 1))
    printf 'PASS %s\n' "$name"
  else
    ((failed += 1))
    printf 'FAIL %s: expected exit %d, text %q, and error count %q; got exit %d\n%s\n' \
      "$name" "$expected_status" "$expected_text" "$expected_error_count" "$status" "$output" >&2
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

missing_output=$(bash "$skills_root/mino-core/scripts/validate-suite.sh" \
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

unknown_output=$(bash "$skills_root/mino-core/scripts/validate-suite.sh" --unknown 2>&1)
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

missing_value_output=$(bash "$skills_root/mino-core/scripts/validate-suite.sh" --skills-root 2>&1)
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
sed -i '0,/^mode:/{s/^mode:/expected_skill: mino-core\nmode:/}' \
  "$case_skills/$case_relative"
check_result solver-field-allowlist 1 'unsupported top-level field: expected_skill'

prepare_case solver-nested-metadata
sed -i '0,/^confirmed_evidence:/{s/^confirmed_evidence:/confirmed_evidence:\n  expected_skill: mino-core/}' \
  "$case_skills/$case_relative"
check_result solver-nested-metadata 1 'nested mapping field: expected_skill'

prepare_case stale-version-heading
sed -i '1c# Evaluation cases 0.0.0' "$case_skills/$case_relative"
check_result stale-version-heading 1 'heading does not match suite_version'

prepare_case malformed-frontmatter-delimiter
sed -i '4s/^---$/---junk/' "$case_skills/mino-core/SKILL.md"
check_result malformed-frontmatter-delimiter 1 'Invalid frontmatter'

prepare_case frontmatter-name-trailing-garbage
sed -i 's/^name: mino-core$/name: "mino-core" trailing/' "$case_skills/mino-core/SKILL.md"
check_result frontmatter-name-trailing-garbage 1 'Skill name must match folder'

prepare_case flattened-agent-metadata
sed -i '/^interface:$/d; /^policy:$/d; s/^  //' "$case_skills/mino-core/agents/openai.yaml"
check_result flattened-agent-metadata 1 'Invalid agents/openai.yaml structure'

prepare_case prompt-token-wrong-field
sed -i 's/display_name: "Shared Core"/display_name: "Shared Core $mino-core"/; s/Use \$mino-core/Use mino-core/' \
  "$case_skills/mino-core/agents/openai.yaml"
check_result prompt-token-wrong-field 1 'default_prompt must mention $mino-core'

prepare_case unicode-scalar-length
short_value="$(printf '%063s' '' | tr ' ' a)😀"
sed -i "s|^  short_description:.*|  short_description: \"$short_value\"|" \
  "$case_skills/mino-core/agents/openai.yaml"
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
ln -s -- "$outside_reference_dir" "$case_skills/mino-core/references/external-link"
printf '\n`skills/mino-core/references/external-link/probe.md`\n' >>"$case_skills/mino-core/references/core.md"
check_result link-escape 1 'Skills-rooted path must not traverse a link'

prepare_case missing-contents
sed -i '0,/^## Contents$/{/^## Contents$/d;}' "$case_skills/mino-core/references/benchmark.md"
check_result missing-contents 1 'Reference over 100 lines has no Contents section'

prepare_case uppercase-extension-format
printf 'no final newline' >"$case_skills/mino-core/references/Upper.MD"
check_result uppercase-extension-format 1 'Text file must end with a newline'

printf 'Validator fixtures: %d passed, %d failed, %d total\n' "$passed" "$failed" "$total"
if ((failed > 0)); then
  exit 1
fi

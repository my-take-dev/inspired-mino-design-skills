#!/usr/bin/env bash

set -uo pipefail

usage() {
  cat <<'USAGE'
Usage: validate-suite.sh [--skills-root PATH] [--manifest-file PATH]

Validates the mino skill suite from a Linux environment.
When --skills-root is omitted, the installed skills directory is inferred
from this script's location.
When --manifest-file is omitted, suite-manifest.txt beside this script is used.
Detailed validation is limited to manifest-listed suite skills. Other installed
skills are ignored, while unlisted mino-* skills are reported.
USAGE
}

skills_root=""
manifest_file=""
while (($# > 0)); do
  case "$1" in
    --skills-root | -SkillsRoot)
      if (($# < 2)); then
        echo "Missing value for --skills-root" >&2
        exit 2
      fi
      skills_root=$2
      shift 2
      ;;
    --manifest-file | -ManifestFile)
      if (($# < 2)); then
        echo "Missing value for --manifest-file" >&2
        exit 2
      fi
      manifest_file=$2
      shift 2
      ;;
    -h | --help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P) || exit 2
if [[ -z $skills_root ]]; then
  skill_dir=$(dirname -- "$script_dir")
  skills_root=$(dirname -- "$skill_dir")
fi

if [[ ! -d $skills_root ]]; then
  echo "Skills root not found: $skills_root" >&2
  exit 2
fi
skills_root=$(cd -- "$skills_root" && pwd -P) || exit 2

if command -v locale >/dev/null 2>&1; then
  utf8_locale=$(locale -a 2>/dev/null | awk 'tolower($0) == "c.utf8" || tolower($0) == "c.utf-8" { print; exit }')
  if [[ -n $utf8_locale ]]; then
    export LC_ALL=$utf8_locale
  fi
fi

errors=()
warnings=()

add_error() {
  errors+=("$1")
}

add_warning() {
  warnings+=("$1")
}

if [[ -z ${utf8_locale:-} ]]; then
  add_error "A UTF-8 locale is required for Unicode scalar length validation"
fi

trim() {
  local value=$1
  value=${value#"${value%%[![:space:]]*}"}
  value=${value%"${value##*[![:space:]]}"}
  printf '%s' "$value"
}

unquote() {
  local value
  value=$(trim "$1")
  if [[ $value == \"*\" && $value == *\" ]]; then
    value=${value:1:${#value}-2}
  elif [[ $value == \'*\' && $value == *\' ]]; then
    value=${value:1:${#value}-2}
  fi
  printf '%s' "$value"
}

validate_logical_path() {
  local logical_path=$1
  local source_file=$2

  if { [[ $logical_path != 'skills/' ]] && [[ ! $logical_path =~ ^skills(/[A-Za-z0-9._-]+)+/?$ ]]; } ||
    [[ $logical_path =~ (^|/)\.\.?(/|$) ]]; then
    add_error "Invalid skills-rooted path '$logical_path' in $source_file"
    return
  fi

  local relative_path=${logical_path#skills/}
  local target=$skills_root
  if [[ -n $relative_path ]]; then
    target="$skills_root/$relative_path"
  fi
  if [[ ! -e $target ]]; then
    add_error "Unresolved skills-rooted path '$logical_path' in $source_file"
    return
  fi

  # Dot segments are rejected above; rejecting every link component keeps containment independent of realpath.
  local current_path=$skills_root
  local segment
  local -a path_segments=()
  IFS='/' read -r -a path_segments <<<"$relative_path"
  for segment in "${path_segments[@]}"; do
    [[ -z $segment ]] && continue
    current_path="$current_path/$segment"
    if [[ -L $current_path ]]; then
      add_error "Skills-rooted path must not traverse a link '$logical_path' in $source_file"
      return
    fi
  done
}

if [[ -z $manifest_file ]]; then
  manifest_file="$script_dir/suite-manifest.txt"
fi
suite_version=""
suite_owner=""
suite_skill_names=()
suite_version_count=0
suite_owner_count=0
declare -A seen_skill_names=()
if [[ ! -f $manifest_file ]]; then
  add_error "Missing suite manifest: skills/mino-core/scripts/suite-manifest.txt"
else
  while IFS= read -r manifest_line || [[ -n $manifest_line ]]; do
    if [[ -z $(trim "$manifest_line") ]]; then
      continue
    fi
    if [[ $manifest_line != *=* ]]; then
      add_error "Invalid suite manifest line: $manifest_line"
      continue
    fi
    key=${manifest_line%%=*}
    value=${manifest_line#*=}
    key=$(trim "$key")
    value=$(trim "$value")
    if [[ -z $key ]]; then
      add_error "Invalid suite manifest line: $manifest_line"
      continue
    fi
    case "$key" in
      suite_version)
        ((suite_version_count += 1))
        if ((suite_version_count > 1)); then
          add_error "Duplicate suite_version in $manifest_file"
        else
          suite_version=$value
        fi
        ;;
      owner)
        ((suite_owner_count += 1))
        if ((suite_owner_count > 1)); then
          add_error "Duplicate owner in $manifest_file"
        else
          suite_owner=$value
        fi
        ;;
      skill)
        if [[ ! $value =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]]; then
          add_error "Invalid suite skill name '$value': $manifest_file"
        elif [[ ${seen_skill_names[$value]+present} ]]; then
          add_error "Duplicate suite skill '$value': $manifest_file"
        else
          seen_skill_names[$value]=true
          suite_skill_names+=("$value")
        fi
        ;;
      *) add_error "Unsupported suite manifest key '$key': $manifest_file" ;;
    esac
  done <"$manifest_file"
fi

if [[ -z $suite_version ]]; then
  add_error "Missing suite_version in $manifest_file"
elif [[ ! $suite_version =~ ^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)$ ]]; then
  add_error "Invalid suite_version '$suite_version': $manifest_file"
fi
if [[ -z $suite_owner ]]; then
  add_error "Missing owner in $manifest_file"
fi
if ((${#suite_skill_names[@]} == 0)); then
  add_error "Suite manifest contains no skills: $manifest_file"
fi

if [[ $suite_version =~ ^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)$ ]]; then
  current_case_logical="skills/mino-core/evaluations/cases/$suite_version.md"
  current_oracle_logical="skills/mino-core/evaluations/oracles/$suite_version.md"
  current_evaluation_logical="skills/mino-core/evaluations/$suite_version.md"
  current_case_file="$skills_root/${current_case_logical#skills/}"
  current_oracle_file="$skills_root/${current_oracle_logical#skills/}"
  current_evaluation_file="$skills_root/${current_evaluation_logical#skills/}"
  if [[ ! -f $current_case_file ]]; then
    add_error "Missing versioned solver case: $current_case_logical"
  else
    if [[ $(sed -n '1p' "$current_case_file") != "# Evaluation cases $suite_version" ]]; then
      add_error "Versioned solver case heading does not match suite_version: $current_case_logical"
    fi
    while IFS=$'\t' read -r result_type result_detail; do
      if [[ $result_type == ERROR ]]; then
        add_error "$result_detail: $current_case_logical"
      fi
    done < <(awk '
      BEGIN {
        split("mode required_platforms raw_request confirmed_evidence known_unknowns allowed_assumptions prohibited_changes", names, " ")
        for (i in names) allowed[names[i]] = 1
      }
      /^```yaml[[:space:]]*$/ {
        in_yaml = 1
        block_scalar = 0
        delete seen
        next
      }
      /^```[[:space:]]*$/ && in_yaml {
        for (key in allowed) {
          if (seen[key] != 1) print "ERROR\tSolver case field must appear exactly once: " key
        }
        in_yaml = 0
        block_scalar = 0
        next
      }
      in_yaml && /^[A-Za-z_][A-Za-z0-9_]*[[:space:]]*:/ {
        key = $0
        sub(/[[:space:]]*:.*/, "", key)
        block_scalar = ($0 ~ /:[[:space:]]*[>|][+-]?[[:space:]]*$/)
        if (!(key in allowed)) print "ERROR\tSolver case contains unsupported top-level field: " key
        seen[key]++
        if (seen[key] > 1) print "ERROR\tSolver case field appears more than once: " key
        next
      }
      in_yaml && !block_scalar && /^[[:space:]]+[A-Za-z_][A-Za-z0-9_]*[[:space:]]*:/ {
        line = $0
        sub(/^[[:space:]]+/, "", line)
        sub(/[[:space:]]*:.*/, "", line)
        print "ERROR\tSolver case contains nested mapping field: " line
      }
      END {
        if (in_yaml) print "ERROR\tSolver case has an unclosed yaml fence"
      }
    ' "$current_case_file")
  fi
  if [[ ! -f $current_oracle_file ]]; then
    add_error "Missing versioned evaluator oracle: $current_oracle_logical"
  else
    if [[ $(sed -n '1p' "$current_oracle_file") != "# Evaluator oracles $suite_version" ]]; then
      add_error "Versioned evaluator oracle heading does not match suite_version: $current_oracle_logical"
    fi
    if ! grep -Fxq '## Runner-only metadata' "$current_oracle_file"; then
      add_error "Evaluator oracle is missing runner-only metadata: $current_oracle_logical"
    fi
  fi
  if [[ ! -f $current_evaluation_file ]]; then
    add_error "Missing versioned evaluation record: $current_evaluation_logical"
  elif [[ $(sed -n '1p' "$current_evaluation_file") != "# Evaluation $suite_version" ]]; then
    add_error "Versioned evaluation heading does not match suite_version: $current_evaluation_logical"
  fi

  benchmark_file="$skills_root/mino-core/references/benchmark.md"
  for current_bundle_path in "$current_case_logical" "$current_oracle_logical" "$current_evaluation_logical"; do
    if [[ -f $benchmark_file ]] && ! grep -Fq "\`$current_bundle_path\`" "$benchmark_file"; then
      add_error "Benchmark does not reference current versioned artifact '$current_bundle_path': $benchmark_file"
    fi
  done
fi

for required_script in validate-suite.ps1 validate-suite.sh test-validator-fixtures.ps1 test-validator-fixtures.sh; do
  if [[ ! -f "$skills_root/mino-core/scripts/$required_script" ]]; then
    add_error "Missing platform validator: skills/mino-core/scripts/$required_script"
  fi
done

skill_dirs=()
for skill_name in "${suite_skill_names[@]}"; do
  skill_dir="$skills_root/$skill_name"
  if [[ ! -d $skill_dir ]]; then
    add_error "Missing suite skill: skills/$skill_name"
    continue
  fi
  resolved_skill_dir=$(cd -- "$skill_dir" && pwd -P) || {
    add_error "Cannot resolve suite skill: skills/$skill_name"
    continue
  }
  if [[ $resolved_skill_dir != "$skills_root/$skill_name" || ${resolved_skill_dir##*/} != "$skill_name" ]]; then
    add_error "Suite skill must resolve directly inside skills root: skills/$skill_name"
    continue
  fi
  skill_dirs+=("$skill_dir")
done

while IFS= read -r -d '' discovered_skill_file; do
  discovered_name=${discovered_skill_file%/SKILL.md}
  discovered_name=${discovered_name##*/}
  listed=false
  for skill_name in "${suite_skill_names[@]}"; do
    if [[ $skill_name == "$discovered_name" ]]; then
      listed=true
      break
    fi
  done
  if [[ $discovered_name == mino-* && $listed != true ]]; then
    add_error "Skill directory is not listed in suite manifest: skills/$discovered_name"
  fi
done < <(find "$skills_root" -mindepth 2 -maxdepth 2 -type f -name SKILL.md -print0)

platform_reference='skills/mino-core/references/platform-compatibility.md'

for skill_dir in "${skill_dirs[@]}"; do
  skill_name=${skill_dir##*/}
  if ((${#skill_name} > 64)) ||
    [[ ! $skill_name =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]]; then
    add_error "Invalid skill folder name: $skill_name"
  fi

  skill_file="$skill_dir/SKILL.md"
  if [[ ! -f $skill_file ]]; then
    add_error "Missing SKILL.md: skills/$skill_name"
    continue
  fi

  first_line=$(sed -n '1{s/\r$//;p;q;}' "$skill_file")
  frontmatter_end=$(awk 'NR > 1 { sub(/\r$/, ""); if ($0 == "---") { print NR; exit } }' "$skill_file")
  if [[ $first_line != '---' || -z $frontmatter_end ]]; then
    add_error "Invalid frontmatter: $skill_file"
    continue
  fi

  frontmatter=$(sed -n "2,$((frontmatter_end - 1))p" "$skill_file" | sed 's/\r$//')
  name_key_count=0
  description_key_count=0
  while IFS= read -r frontmatter_line; do
    if [[ ! $frontmatter_line =~ ^([A-Za-z0-9_-]+): ]]; then
      add_error "Invalid frontmatter line '$frontmatter_line': $skill_file"
      continue
    fi
    key=${BASH_REMATCH[1]}
    case "$key" in
      name) ((name_key_count += 1)) ;;
      description) ((description_key_count += 1)) ;;
      *) add_error "Unsupported frontmatter key '$key': $skill_file" ;;
    esac
  done <<<"$frontmatter"

  if ((name_key_count != 1)); then
    add_error "Frontmatter key 'name' must appear exactly once: $skill_file"
  fi
  if ((description_key_count != 1)); then
    add_error "Frontmatter key 'description' must appear exactly once: $skill_file"
  fi

  name_line=$(printf '%s\n' "$frontmatter" | grep -m 1 '^name:' || true)
  declared_name=$(unquote "${name_line#name:}")
  if [[ $declared_name != "$skill_name" ]]; then
    add_error "Skill name must match folder: $skill_file"
  fi

  description_line=$(printf '%s\n' "$frontmatter" | grep -m 1 '^description:' || true)
  description=$(trim "${description_line#description:}")
  if [[ -z $description ]]; then
    add_error "Skill description must not be empty: $skill_file"
  else
    if ((${#description} > 1024)); then
      add_error "Skill description exceeds 1024 characters: $skill_file"
    fi
    if [[ $description == *'<'* || $description == *'>'* ]]; then
      add_error "Skill description cannot contain angle brackets: $skill_file"
    fi
  fi

  line_count=$(wc -l <"$skill_file")
  if ((line_count > 500)); then
    add_error "SKILL.md exceeds 500 lines: $skill_file"
  fi

  if find "$skill_dir" -maxdepth 1 -type f -iname 'README.md' -print -quit | grep -q .; then
    add_error "README.md is not allowed in a skill directory: $skill_dir"
  fi

  for required_heading in '## Outcome Contract' '## Reference Routing' '## Workflow' '## Completion'; do
    if ! grep -Fxq "$required_heading" "$skill_file"; then
      add_error "Missing required section '$required_heading': $skill_file"
    fi
  done
  if ! grep -Eq '^## Hard Gates$' "$skill_file"; then
    add_error "Missing hard gate section: $skill_file"
  fi

  if ! grep -Fq "\`$platform_reference\`" "$skill_file"; then
    add_error "SKILL.md must route Windows/Linux compatibility reference '$platform_reference': $skill_file"
  fi

  agent_file="$skill_dir/agents/openai.yaml"
  if [[ ! -f $agent_file ]]; then
    add_error "Missing agents/openai.yaml: skills/$skill_name"
  else
    mapfile -t agent_lines <"$agent_file"
    display_name_pattern='^  display_name:[[:space:]]*"[^"]+"$'
    short_description_pattern='^  short_description:[[:space:]]*"[^"]+"$'
    default_prompt_pattern='^  default_prompt:[[:space:]]*"[^"]+"$'
    implicit_policy_pattern='^  allow_implicit_invocation:[[:space:]]*(true|false)$'
    if ((${#agent_lines[@]} != 6)) ||
      [[ ${agent_lines[0]-} != 'interface:' ]] ||
      [[ ! ${agent_lines[1]-} =~ $display_name_pattern ]] ||
      [[ ! ${agent_lines[2]-} =~ $short_description_pattern ]] ||
      [[ ! ${agent_lines[3]-} =~ $default_prompt_pattern ]] ||
      [[ ${agent_lines[4]-} != 'policy:' ]] ||
      [[ ! ${agent_lines[5]-} =~ $implicit_policy_pattern ]]; then
      add_error "Invalid agents/openai.yaml structure: $agent_file"
    fi
    display_name=$(sed -nE 's/^  display_name:[[:space:]]*"([^"]+)"$/\1/p' "$agent_file")
    short_description=$(sed -nE 's/^  short_description:[[:space:]]*"([^"]+)"$/\1/p' "$agent_file")
    default_prompt=$(sed -nE 's/^  default_prompt:[[:space:]]*"([^"]+)"$/\1/p' "$agent_file")
    if [[ -z $display_name ]]; then
      add_error "Quoted display_name not found: $agent_file"
    fi
    if [[ -z $short_description ]]; then
      add_error "Quoted short_description not found: $agent_file"
    else
      short_description_length=$(printf '%s' "$short_description" | wc -m | tr -d '[:space:]')
      if ((short_description_length < 25 || short_description_length > 64)); then
        add_error "short_description must be 25-64 Unicode scalar values: $agent_file"
      fi
    fi
    if [[ -z $default_prompt ]]; then
      add_error "Quoted default_prompt not found: $agent_file"
    elif [[ $default_prompt != *"\$$skill_name"* ]]; then
      add_error "default_prompt must mention \$$skill_name: $agent_file"
    fi
  fi

  reference_root="$skill_dir/references"
  if [[ -d $reference_root ]]; then
    while IFS= read -r -d '' reference_file; do
      reference_name=${reference_file##*/}
      logical_path="skills/$skill_name/references/$reference_name"
      if ! grep -Fq "\`$logical_path\`" "$skill_file"; then
        add_error "SKILL.md must directly route bundled reference '$logical_path': $skill_file"
      fi
    done < <(find "$reference_root" -maxdepth 1 -type f -iname '*.md' -print0)
  fi
done

text_files=()
for skill_dir in "${skill_dirs[@]}"; do
  while IFS= read -r -d '' text_file; do
    text_files+=("$text_file")
  done < <(find "$skill_dir" -type f \( \
    -iname '*.md' -o -iname '*.yaml' -o -iname '*.yml' -o -iname '*.json' -o \
    -iname '*.sh' -o -iname '*.ps1' -o -iname '*.py' -o -iname '*.txt' -o \
    -iname '*.toml' -o -iname '*.xml' -o -iname '*.csv' \
  \) -print0)
done

if ! command -v iconv >/dev/null 2>&1; then
  add_error "iconv is required to validate UTF-8 text files"
fi

forbidden_path_pattern='mino-doc''/|\.agents''/skills/|\$HOME/\.agents''/skills/|`\.\./|/home''/[^[:space:]`]*'
for text_file in "${text_files[@]}"; do
  if command -v iconv >/dev/null 2>&1 &&
    ! iconv -f UTF-8 -t UTF-8 "$text_file" >/dev/null 2>&1; then
    add_error "Text file is not valid UTF-8: $text_file"
  fi

  byte_prefix=$(od -An -tx1 -N3 "$text_file" | tr -d '[:space:]')
  if [[ $byte_prefix == efbbbf* ]]; then
    add_error "UTF-8 BOM is not allowed: $text_file"
  fi
  if LC_ALL=C grep -q $'\r' "$text_file"; then
    add_error "CR or CRLF is not allowed: $text_file"
  fi
  if [[ -s $text_file ]]; then
    final_byte=$(tail -c 1 "$text_file" | od -An -tu1 | tr -d '[:space:]')
    if [[ $final_byte != 10 ]]; then
      add_error "Text file must end with a newline: $text_file"
    fi
  fi
  if grep -Eq "$forbidden_path_pattern" "$text_file"; then
    add_error "Runtime skill text contains a repository-specific or physical path: $text_file"
  fi
done

markdown_files=()
for skill_dir in "${skill_dirs[@]}"; do
  while IFS= read -r -d '' markdown_file; do
    markdown_files+=("$markdown_file")
  done < <(find "$skill_dir" -type f -iname '*.md' -print0)
done

for markdown_file in "${markdown_files[@]}"; do
  while IFS= read -r skill_reference; do
    [[ -z $skill_reference ]] && continue
    referenced_name=${skill_reference#\$}
    if [[ ! -f "$skills_root/$referenced_name/SKILL.md" ]]; then
      add_error "Unresolved skill reference '$skill_reference' in $markdown_file"
    fi
  done < <(grep -oE '\$[a-z0-9]+(-[a-z0-9]+)*' "$markdown_file" | sort -u || true)

  while IFS= read -r line || [[ -n $line ]]; do
    remainder=$line
    while [[ $remainder =~ \`([^\`]*)\` ]]; do
      backtick_token=${BASH_REMATCH[1]}
      matched=${BASH_REMATCH[0]}
      if [[ $backtick_token == skills/* ]]; then
        validate_logical_path "$backtick_token" "$markdown_file"
      elif [[ $backtick_token =~ ^/ || $backtick_token =~ ^[A-Za-z]:[\\/] || $backtick_token =~ ^\\\\ ]] ||
        [[ $backtick_token =~ \.(md|sh|ps1|txt|yaml|yml|json|py|toml|xml|csv)$ ]]; then
        add_error "Runtime asset path must start with 'skills/': '$backtick_token' in $markdown_file"
      fi
      remainder=${remainder#*"$matched"}
    done
  done <"$markdown_file"

  if grep -Eq '`(references|scripts|evaluations)/[^`]+`' "$markdown_file"; then
    add_error "Internal path must start with 'skills/' in $markdown_file"
  fi

  if grep -Eq '`[^`[:space:]]+/skills/[^`]+`' "$markdown_file"; then
    add_error "Internal path must use 'skills/' as its top-level root in $markdown_file"
  fi

  while IFS= read -r markdown_match; do
    [[ -z $markdown_match ]] && continue
    target=${markdown_match#](}
    if [[ $target == \#* ]]; then
      continue
    fi
    if [[ $target != skills/* ]]; then
      add_error "Markdown link must start with 'skills/': '$target' in $markdown_file"
      continue
    fi
    validate_logical_path "$target" "$markdown_file"
  done < <(grep -oE '\]\([^[:space:])]+' "$markdown_file" || true)

  line_count=$(wc -l <"$markdown_file")
  if [[ ${markdown_file##*/} != 'SKILL.md' ]] &&
    ((line_count > 100)) &&
    ! awk '{ sub(/\r$/, "") } $0 == "## Contents" { found = 1 } END { exit !found }' "$markdown_file"; then
    add_error "Reference over 100 lines has no Contents section: $markdown_file"
  fi
done

for warning in "${warnings[@]}"; do
  printf 'WARNING: %s\n' "$warning" >&2
done
for error_message in "${errors[@]}"; do
  printf 'ERROR: %s\n' "$error_message" >&2
done

printf 'Validated %d suite skills and %d markdown files from: %s\n' \
  "${#skill_dirs[@]}" "${#markdown_files[@]}" "$skills_root"
printf 'Suite version: %s; Owner: %s\n' "$suite_version" "$suite_owner"
printf 'Errors: %d; Warnings: %d\n' "${#errors[@]}" "${#warnings[@]}"

if ((${#errors[@]} > 0)); then
  exit 1
fi

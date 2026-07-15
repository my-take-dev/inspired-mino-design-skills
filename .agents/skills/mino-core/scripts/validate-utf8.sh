#!/usr/bin/env bash

set -u

usage() {
  cat <<'USAGE'
Usage: validate-utf8.sh [--count-scalars] FILE

Validates one file as strict UTF-8 without relying on the process locale.
Use FILE '-' to read standard input. Exit 0 means valid UTF-8, exit 1 means
invalid input data, and exit 2 means the validation could not be completed.
USAGE
}

emit_count=false
input_file=""
while (($# > 0)); do
  case "$1" in
    --count-scalars)
      emit_count=true
      shift
      ;;
    -h | --help)
      usage
      exit 0
      ;;
    --)
      shift
      break
      ;;
    -)
      input_file=-
      shift
      break
      ;;
    -*)
      printf 'Unknown argument: %s\n' "$1" >&2
      usage >&2
      exit 2
      ;;
    *)
      input_file=$1
      shift
      break
      ;;
  esac
done

if [[ -z $input_file && $# -gt 0 ]]; then
  input_file=$1
  shift
fi
if [[ -z $input_file || $# -ne 0 ]]; then
  usage >&2
  exit 2
fi

for required_command in awk od mktemp rm; do
  if ! command -v "$required_command" >/dev/null 2>&1; then
    printf 'UTF-8 validator prerequisite is missing: %s\n' "$required_command" >&2
    exit 2
  fi
done

if [[ $input_file != - && ! -f $input_file ]]; then
  printf 'UTF-8 validator input is not a regular file: %s\n' "$input_file" >&2
  exit 2
fi
if [[ $input_file != - && ! -r $input_file ]]; then
  printf 'UTF-8 validator input is not readable: %s\n' "$input_file" >&2
  exit 2
fi

tmp_base=${TMPDIR:-/tmp}
tmp_root=$(mktemp -d "$tmp_base/mino-utf8.XXXXXX") || {
  printf 'UTF-8 validator could not create a temporary directory under: %s\n' "$tmp_base" >&2
  exit 2
}

cleanup() {
  rm -rf "$tmp_root"
}
trap cleanup EXIT HUP INT TERM

byte_file="$tmp_root/bytes.txt"
if [[ $input_file == - ]]; then
  if ! LC_ALL=C od -An -v -tu1 >"$byte_file"; then
    printf 'UTF-8 validator could not read standard input\n' >&2
    exit 2
  fi
elif ! LC_ALL=C od -An -v -tu1 "$input_file" >"$byte_file"; then
  printf 'UTF-8 validator could not read input: %s\n' "$input_file" >&2
  exit 2
fi

emit_count_value=0
if [[ $emit_count == true ]]; then
  emit_count_value=1
fi

LC_ALL=C awk -v emit_count="$emit_count_value" '
  function invalid_data() {
    invalid = 1
    exit 1
  }

  function backend_failure() {
    backend_error = 1
    exit 2
  }

  BEGIN {
    remaining = 0
    scalar_count = 0
  }

  {
    for (field = 1; field <= NF; field++) {
      if ($field !~ /^[0-9]+$/) {
        backend_failure()
      }
      byte = $field + 0
      if (byte < 0 || byte > 255) {
        backend_failure()
      }

      if (remaining > 0) {
        if (byte < next_minimum || byte > next_maximum) {
          invalid_data()
        }
        remaining--
        next_minimum = 128
        next_maximum = 191
        if (remaining == 0) {
          scalar_count++
        }
        continue
      }

      if (byte <= 127) {
        scalar_count++
      } else if (byte >= 194 && byte <= 223) {
        remaining = 1
        next_minimum = 128
        next_maximum = 191
      } else if (byte == 224) {
        remaining = 2
        next_minimum = 160
        next_maximum = 191
      } else if ((byte >= 225 && byte <= 236) || (byte >= 238 && byte <= 239)) {
        remaining = 2
        next_minimum = 128
        next_maximum = 191
      } else if (byte == 237) {
        remaining = 2
        next_minimum = 128
        next_maximum = 159
      } else if (byte == 240) {
        remaining = 3
        next_minimum = 144
        next_maximum = 191
      } else if (byte >= 241 && byte <= 243) {
        remaining = 3
        next_minimum = 128
        next_maximum = 191
      } else if (byte == 244) {
        remaining = 3
        next_minimum = 128
        next_maximum = 143
      } else {
        invalid_data()
      }
    }
  }

  END {
    if (backend_error) {
      exit 2
    }
    if (invalid || remaining != 0) {
      exit 1
    }
    if (emit_count == 1) {
      print scalar_count
    }
  }
' "$byte_file"

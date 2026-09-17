#!/usr/bin/env bash
# Bash 3.2-compatible launcher. Python is needed for validation, not Skill use.
set -uo pipefail
script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P) || exit 2
python_cmd=${MINO_PYTHON:-python3}
if ! command -v "$python_cmd" >/dev/null 2>&1; then
  printf 'E_PYTHON: Python 3.10+ is required for structural validation.\n' >&2
  exit 2
fi
if [[ ! -f "$script_dir/validate_suite.py" ]]; then
  printf 'E_ENGINE: structural validation engine is missing.\n' >&2
  exit 2
fi
exec "$python_cmd" -B "$script_dir/validate_suite.py" "$@"

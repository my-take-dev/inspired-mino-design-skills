#!/usr/bin/env python3
"""Regenerate evaluator-only Markdown from the active JSON oracle.

The solver cases and JSON oracle are never changed by this command.
Python 3.10+ standard library only.
"""
import argparse
import json
import re
import sys
from pathlib import Path

from validate_suite import render_oracle


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--maintenance-root', type=Path, default=Path(__file__).resolve().parents[1])
    args = parser.parse_args()
    registry = json.loads((args.maintenance_root / 'suite-contract.json').read_text(encoding='utf-8'))
    revision = registry['evaluation_revision']
    # Only a versioned filename directly inside this suite's oracle directory.
    if not re.fullmatch(re.escape(registry['suite_version']) + r'-r[1-9]\d*', revision):
        print('E_EVALUATION_REVISION: invalid active revision')
        return 1
    source = args.maintenance_root / 'evaluations/oracles' / (revision + '.json')
    oracle = json.loads(source.read_text(encoding='utf-8'))
    if oracle['evaluation_revision'] != revision or oracle['suite_version'] != registry['suite_version']:
        print('E_ORACLE_VERSION: oracle and registry do not match')
        return 1
    source.with_suffix('.md').write_text(render_oracle(oracle), encoding='utf-8', newline='\n')
    print('Rendered evaluator oracle: ' + revision)
    return 0


if __name__ == '__main__':
    if sys.version_info < (3, 10):
        print('E_PYTHON: Python 3.10+ is required')
        sys.exit(2)
    try:
        sys.exit(main())
    except (OSError, UnicodeError, ValueError, KeyError, TypeError) as exc:
        print('E_ORACLE: ' + str(exc))
        sys.exit(2)

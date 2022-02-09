#!/usr/bin/env bash

set -euo pipefail

# Keep in sync with //third_party/python/cpython:python.c.

# Make Backspace work.
# See: https://python-build-standalone.readthedocs.io/en/latest/quirks.html#backscape-key-doesn-t-work-in-python-repl
TERMINFO_DIRS=/etc/terminfo:/lib/terminfo:/usr/share/terminfo
export TERMINFO_DIRS

PYTHONNOUSERSITE=1
export PYTHONNOUSERSITE

exec "$( dirname "${BASH_SOURCE[0]}" )"/bin/python3 "$@"

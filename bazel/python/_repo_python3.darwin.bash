#!/usr/bin/env bash

set -euo pipefail

# Keep in sync with //third_party/python/cpython:python.c.

PYTHONNOUSERSITE=1
export PYTHONNOUSERSITE

exec "$( dirname "${BASH_SOURCE[0]}" )"/bin/python3 "$@"

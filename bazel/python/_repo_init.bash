#!/usr/bin/env bash

set -euo pipefail
set -x

python_workspace="$1"

python_dir="$(dirname "$python_workspace")"
cp -R "$python_dir"/python/install/{bin,include,lib} ./

# TODO: Consider downloading wheels with Bazel for integrity and caching.
for pylib in "${@:2}"; do
    ./python3 -m pip install --upgrade "$pylib"
done

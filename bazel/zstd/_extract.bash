#!/usr/bin/env bash

set -euo pipefail

zstd="$1"
file="$2"

"$zstd" --decompress --stdout --force "$file" | tar --extract

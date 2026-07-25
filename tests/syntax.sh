#!/usr/bin/env bash

set -Eeuo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

mapfile -d '' scripts < <(
    find "$ROOT" \
        -type f \
        \( -name '*.sh' -o -name guardian \) \
        -print0 |
    sort -z
)

for script in "${scripts[@]}"; do
    bash -n "$script"
done

printf 'Bash syntax is valid for %d files.\n' "${#scripts[@]}"

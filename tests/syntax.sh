#!/usr/bin/env bash

set -Eeuo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

bash -n "$ROOT/bin/aegis-guardian"

for file in "$ROOT"/lib/*.sh "$ROOT"/modules/*.sh; do
    bash -n "$file"
done

printf 'Syntaxe Bash valide.\n'

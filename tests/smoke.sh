#!/usr/bin/env bash

set -Eeuo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

version_output="$("$ROOT/guardian" version)"
[[ "$version_output" == "Aegis Guardian 0.2.0-dev" ]]

text_output="$("$ROOT/guardian" check system --format text || true)"
grep -q 'Aegis Guardian 0.2.0-dev' <<<"$text_output"
grep -q 'system.disk-root' <<<"$text_output"

json_output="$("$ROOT/guardian" check system --format json || true)"
python3 -c '
import json
import sys
data = json.load(sys.stdin)
assert data["guardian_version"] == "0.2.0-dev"
assert data["mode"] == "check"
assert any(item["module"] == "system" for item in data["results"])
' <<<"$json_output"

printf 'Smoke tests passed.\n'

#!/usr/bin/env bash

set -Eeuo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

version_output="$("$ROOT/guardian" version)"
[[ "$version_output" == "Aegis Guardian 1.0.0-rc1" ]]

text_output="$("$ROOT/guardian" check system --format text || true)"
grep -q 'Aegis Guardian 1.0.0-rc1' <<<"$text_output"
grep -q 'system.disk-root' <<<"$text_output"

diagnose_output="$("$ROOT/guardian" diagnose system --format text || true)"
grep -q 'Mode: diagnose' <<<"$diagnose_output"
grep -q 'system.operating-system' <<<"$diagnose_output"

json_output="$("$ROOT/guardian" diagnose system --format json || true)"
python3 -c '
import json
import sys

data = json.load(sys.stdin)
assert data["guardian_version"] == "1.0.0-rc1"
assert data["mode"] == "diagnose"
assert any(
    item["module"] == "system"
    and item["check"] == "operating-system"
    for item in data["results"]
)
' <<<"$json_output"

printf 'Smoke tests passed.\n'

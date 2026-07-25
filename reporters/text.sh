#!/usr/bin/env bash

set -Eeuo pipefail

guardian_status_symbol() {
    case "$1" in
        ok)       printf '[OK]' ;;
        info)     printf '[INFO]' ;;
        warning)  printf '[WARN]' ;;
        critical) printf '[CRIT]' ;;
        repaired) printf '[FIXED]' ;;
        unknown)  printf '[UNKNOWN]' ;;
        *)        printf '[?]' ;;
    esac
}

guardian_report_text() {
    local overall
    local result
    local status
    local symbol

    overall="$(guardian_overall_status)"

    printf 'Aegis Guardian %s\n' "$(guardian_read_version)"
    printf 'Host: %s\n' "$GUARDIAN_HOST"
    printf 'Instance: %s\n' "$INSTANCE_NAME"
    printf 'Mode: %s\n' "$GUARDIAN_RUN_MODE"
    printf 'Overall status: %s\n\n' "$overall"

    for result in "${GUARDIAN_RESULTS[@]}"; do
        status="$(
            python3 -c \
                'import json,sys; print(json.loads(sys.argv[1])["status"])' \
                "$result"
        )"
        symbol="$(guardian_status_symbol "$status")"

        python3 - "$symbol" "$result" <<'PY'
import json
import sys

symbol = sys.argv[1]
data = json.loads(sys.argv[2])

print(f'{symbol} {data["module"]}.{data["check"]}: {data["summary"]}')

if data.get("evidence"):
    evidence = ", ".join(
        f"{key}={value}"
        for key, value in data["evidence"].items()
    )
    print(f"       {evidence}")
PY
    done
}

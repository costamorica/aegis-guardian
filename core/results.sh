#!/usr/bin/env bash

set -Eeuo pipefail

declare -ag GUARDIAN_RESULTS=()
GUARDIAN_RUN_ID=""
GUARDIAN_RUN_STARTED_AT=""
GUARDIAN_RUN_FINISHED_AT=""
GUARDIAN_RUN_MODE=""
GUARDIAN_HOST=""

guardian_results_reset() {
    local mode="$1"

    GUARDIAN_RESULTS=()
    GUARDIAN_RUN_ID="$(date '+%Y%m%dT%H%M%S%z')"
    GUARDIAN_RUN_STARTED_AT="$(date --iso-8601=seconds)"
    GUARDIAN_RUN_FINISHED_AT=""
    GUARDIAN_RUN_MODE="$mode"
    GUARDIAN_HOST="$(hostname -f 2>/dev/null || hostname)"
}

guardian_result_add() {
    local module="$1"
    local check="$2"
    local status="$3"
    local summary="$4"
    local evidence_key="${5:-}"
    local evidence_value="${6:-}"
    local timestamp

    timestamp="$(date --iso-8601=seconds)"

    GUARDIAN_RESULTS+=(
        "$(
            python3 - \
                "$module" \
                "$check" \
                "$status" \
                "$summary" \
                "$evidence_key" \
                "$evidence_value" \
                "$timestamp" <<'PY'
import json
import sys

module, check, status, summary, evidence_key, evidence_value, timestamp = sys.argv[1:]

evidence = {}
if evidence_key:
    evidence[evidence_key] = evidence_value

print(json.dumps({
    "module": module,
    "check": check,
    "status": status,
    "summary": summary,
    "evidence": evidence,
    "repair_action": None,
    "timestamp": timestamp,
}, ensure_ascii=False, separators=(",", ":")))
PY
        )"
    )
}

guardian_status_rank() {
    case "$1" in
        ok)       printf '0' ;;
        info)     printf '1' ;;
        repaired) printf '2' ;;
        warning)  printf '3' ;;
        unknown)  printf '4' ;;
        critical) printf '5' ;;
        *)        printf '5' ;;
    esac
}

guardian_overall_status() {
    local overall="ok"
    local result
    local status

    for result in "${GUARDIAN_RESULTS[@]}"; do
        status="$(
            python3 -c \
                'import json,sys; print(json.loads(sys.argv[1])["status"])' \
                "$result"
        )"

        if (( $(guardian_status_rank "$status") > $(guardian_status_rank "$overall") )); then
            overall="$status"
        fi
    done

    printf '%s' "$overall"
}

guardian_exit_code_for_status() {
    case "$1" in
        ok|info|repaired) printf '0' ;;
        warning|unknown)  printf '1' ;;
        critical)         printf '2' ;;
        *)                printf '5' ;;
    esac
}

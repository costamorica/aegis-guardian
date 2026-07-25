#!/usr/bin/env bash

set -Eeuo pipefail

guardian_report_json() {
    local overall
    local results_file

    overall="$(guardian_overall_status)"
    results_file="$(mktemp)"

    printf '%s\n' "${GUARDIAN_RESULTS[@]}" > "$results_file"

    python3 - \
        "$(guardian_read_version)" \
        "$GUARDIAN_RUN_ID" \
        "$INSTANCE_NAME" \
        "$GUARDIAN_HOST" \
        "$GUARDIAN_RUN_MODE" \
        "$GUARDIAN_RUN_STARTED_AT" \
        "$GUARDIAN_RUN_FINISHED_AT" \
        "$overall" \
        "$results_file" <<'PY'
import json
import sys

(
    version,
    run_id,
    instance,
    host,
    mode,
    started_at,
    finished_at,
    overall,
    results_file,
) = sys.argv[1:]

with open(results_file, encoding="utf-8") as handle:
    results = [
        json.loads(line)
        for line in handle
        if line.strip()
    ]

print(json.dumps({
    "schema_version": 1,
    "guardian_version": version,
    "run_id": run_id,
    "instance": instance,
    "host": host,
    "mode": mode,
    "started_at": started_at,
    "finished_at": finished_at,
    "overall_status": overall,
    "results": results,
}, ensure_ascii=False, indent=2))
PY

    rm -f "$results_file"
}

#!/usr/bin/env bash

set -Eeuo pipefail

build_summary() {
    python3 - "$RUN_FILE" "$SUMMARY_FILE" "$HOST" "$INSTANCE_NAME" "$RUN_STARTED_AT" <<'PY'
import datetime
import json
import pathlib
import sys

run_file, summary_file, host, instance, started = sys.argv[1:]

results = []
with open(run_file, encoding="utf-8") as handle:
    for line in handle:
        line = line.strip()
        if line:
            results.append(json.loads(line))

rank = {
    "ok": 0,
    "repaired": 1,
    "warning": 2,
    "critical": 3,
}

overall = "ok"
for result in results:
    if rank.get(result["status"], 3) > rank.get(overall, 0):
        overall = result["status"]

summary = {
    "schema_version": 1,
    "instance": instance,
    "host": host,
    "started_at": started,
    "finished_at": datetime.datetime.now().astimezone().isoformat(),
    "overall_status": overall,
    "counts": {
        status: sum(1 for result in results if result["status"] == status)
        for status in rank
    },
    "results": results,
}

target = pathlib.Path(summary_file)
temporary = target.with_suffix(".tmp")
temporary.write_text(
    json.dumps(summary, ensure_ascii=False, indent=2) + "\n",
    encoding="utf-8",
)
temporary.replace(target)
PY
}

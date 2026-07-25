#!/usr/bin/env bash

set -Eeuo pipefail
umask 027

AG_CONFIG="${AG_CONFIG:-/etc/aegis-guardian/guardian.conf}"

if [[ ! -r "$AG_CONFIG" ]]; then
    printf 'Configuration absente : %s\n' "$AG_CONFIG" >&2
    exit 1
fi

# shellcheck source=/etc/aegis-guardian/guardian.conf
source "$AG_CONFIG"

HOST="$(hostname -f 2>/dev/null || hostname)"
RUN_ID="$(date '+%Y%m%dT%H%M%S')"
RUN_STARTED_AT="$(date --iso-8601=seconds)"

mkdir -p "$LOG_DIR" "$STATE_DIR" "$REPORT_DIR"

LOG_FILE="${LOG_DIR}/guardian-$(date +%F).log"
RUN_FILE="${REPORT_DIR}/run-${RUN_ID}.jsonl"
SUMMARY_FILE="${REPORT_DIR}/latest.json"

log() {
    printf '%s %s\n' "$(date '+%F %T')" "$*" | tee -a "$LOG_FILE"
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

json_escape() {
    python3 -c 'import json,sys; print(json.dumps(sys.stdin.read())[1:-1])'
}

emit_result() {
    local module="$1"
    local status="$2"
    local repaired="$3"
    local message="$4"
    local details="${5:-}"

    printf '{"module":"%s","status":"%s","repaired":%s,"message":"%s","details":"%s","timestamp":"%s"}\n' \
        "$(printf '%s' "$module" | json_escape)" \
        "$(printf '%s' "$status" | json_escape)" \
        "$repaired" \
        "$(printf '%s' "$message" | json_escape)" \
        "$(printf '%s' "$details" | json_escape)" \
        "$(date --iso-8601=seconds)" >> "$RUN_FILE"
}

service_exists() {
    systemctl list-unit-files "$1.service" --no-legend 2>/dev/null |
        grep -q "^$1\.service"
}

check_service() {
    local module="$1"
    local service="$2"

    if ! service_exists "$service"; then
        emit_result "$module" "warning" false "Service absent" "$service"
        return 0
    fi

    if systemctl is-active --quiet "$service"; then
        emit_result "$module" "ok" false "Service actif" "$service"
        return 0
    fi

    if [[ "$AUTO_REPAIR" == true ]]; then
        systemctl reset-failed "$service" >/dev/null 2>&1 || true
        systemctl restart "$service" >/dev/null 2>&1 || true
        sleep 3

        if systemctl is-active --quiet "$service"; then
            emit_result "$module" "repaired" true "Service redémarré" "$service"
            return 0
        fi
    fi

    emit_result "$module" "critical" false "Service indisponible" "$service"
}

docker_available() {
    command_exists docker && docker info >/dev/null 2>&1
}

check_container() {
    local module="$1"
    local container="$2"

    if ! docker_available; then
        emit_result "$module" "critical" false "Docker indisponible" ""
        return 0
    fi

    if ! docker inspect "$container" >/dev/null 2>&1; then
        emit_result "$module" "critical" false "Conteneur absent" "$container"
        return 0
    fi

    local status
    local health

    status="$(docker inspect --format '{{.State.Status}}' "$container" 2>/dev/null || true)"
    health="$(docker inspect --format '{{if .State.Health}}{{.State.Health.Status}}{{else}}none{{end}}' "$container" 2>/dev/null || true)"

    if [[ "$status" == "running" && "$health" != "unhealthy" ]]; then
        emit_result "$module" "ok" false "Conteneur actif" "${container}; health=${health}"
        return 0
    fi

    if [[ "$AUTO_REPAIR" == true ]]; then
        docker restart "$container" >/dev/null 2>&1 || true
        sleep 10

        status="$(docker inspect --format '{{.State.Status}}' "$container" 2>/dev/null || true)"

        if [[ "$status" == "running" ]]; then
            emit_result "$module" "repaired" true "Conteneur redémarré" "$container"
            return 0
        fi
    fi

    emit_result "$module" "critical" false "Conteneur indisponible" "${container}; status=${status}"
}

check_http_local() {
    local module="$1"
    local url="$2"
    local domain="$3"
    local attempt
    local code="000"

    for ((attempt = 1; attempt <= HTTP_RETRIES; attempt++)); do
        code="$(
            curl \
                --silent \
                --show-error \
                --location \
                --resolve "${domain}:443:127.0.0.1" \
                --max-time "$HTTP_TIMEOUT" \
                --output /dev/null \
                --write-out '%{http_code}' \
                "$url" 2>/dev/null || printf '000'
        )"

        case "$code" in
            200|204|301|302|303|307|308)
                emit_result "$module" "ok" false "Application accessible" "${url}; HTTP ${code}"
                return 0
                ;;
        esac

        sleep "$HTTP_RETRY_DELAY"
    done

    emit_result "$module" "critical" false "Application inaccessible" "${url}; HTTP ${code}"
}

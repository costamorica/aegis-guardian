#!/usr/bin/env bash

set -Eeuo pipefail

guardian_load_config() {
    if [[ -r "$GUARDIAN_CONFIG_FILE" ]]; then
        # shellcheck disable=SC1090
        source "$GUARDIAN_CONFIG_FILE"
    fi

    INSTANCE_NAME="${INSTANCE_NAME:-default}"
    AUTO_REPAIR="${AUTO_REPAIR:-false}"
    LOG_DIR="${LOG_DIR:-/var/log/aegis-guardian}"
    STATE_DIR="${STATE_DIR:-/var/lib/aegis-guardian}"
    REPORT_DIR="${REPORT_DIR:-/var/lib/aegis-guardian/reports}"

    if [[ "$AUTO_REPAIR" != "false" ]]; then
        printf 'Safety refusal: AUTO_REPAIR must remain false in 0.3.0-dev.\n' >&2
        return 4
    fi
}

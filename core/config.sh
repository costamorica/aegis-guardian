#!/usr/bin/env bash

set -Eeuo pipefail

guardian_load_config() {
    local system_config="/etc/aegis-guardian/guardian.conf"

    if [[ -r "$system_config" ]]; then
        GUARDIAN_CONFIG_FILE="$system_config"
    fi

    if [[ -r "$GUARDIAN_CONFIG_FILE" ]]; then
        # shellcheck disable=SC1090
        source "$GUARDIAN_CONFIG_FILE"
    fi

    INSTANCE_NAME="${INSTANCE_NAME:-default}"
    AUTO_REPAIR="${AUTO_REPAIR:-false}"
    LOG_DIR="${LOG_DIR:-/var/log/aegis-guardian}"
    STATE_DIR="${STATE_DIR:-/var/lib/aegis-guardian}"
    REPORT_DIR="${REPORT_DIR:-/var/lib/aegis-guardian/reports}"
    DEFAULT_FORMAT="${DEFAULT_FORMAT:-json}"

    if [[ "$AUTO_REPAIR" != "false" ]]; then
        printf 'Safety refusal: AUTO_REPAIR is unsupported in Guardian 1.0.\n' >&2
        return 4
    fi

    case "$DEFAULT_FORMAT" in
        text|json) ;;
        *)
            printf 'Invalid DEFAULT_FORMAT: %s\n' "$DEFAULT_FORMAT" >&2
            return 3
            ;;
    esac
}

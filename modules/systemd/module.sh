#!/usr/bin/env bash

set -Eeuo pipefail

module_check() {
    if ! command -v systemctl >/dev/null 2>&1; then
        guardian_result_add \
            "systemd" \
            "availability" \
            "unknown" \
            "systemctl is not available" \
            "command" \
            "systemctl"
        return 0
    fi

    local state
    local failed_count

    state="$(systemctl is-system-running 2>/dev/null || true)"
    failed_count="$(
        systemctl list-units \
            --state=failed \
            --no-legend \
            --plain 2>/dev/null |
        sed '/^[[:space:]]*$/d' |
        wc -l
    )"

    case "$state" in
        running)
            guardian_result_add \
                "systemd" \
                "system-state" \
                "ok" \
                "systemd reports a running system" \
                "state" \
                "$state"
            ;;
        degraded)
            guardian_result_add \
                "systemd" \
                "system-state" \
                "warning" \
                "systemd reports a degraded system" \
                "state" \
                "$state"
            ;;
        *)
            guardian_result_add \
                "systemd" \
                "system-state" \
                "unknown" \
                "systemd returned an unexpected state" \
                "state" \
                "${state:-unknown}"
            ;;
    esac

    if ((failed_count > 0)); then
        guardian_result_add \
            "systemd" \
            "failed-units" \
            "warning" \
            "Failed systemd units were detected" \
            "count" \
            "$failed_count"
    else
        guardian_result_add \
            "systemd" \
            "failed-units" \
            "ok" \
            "No failed systemd units were detected" \
            "count" \
            "0"
    fi
}

module_diagnose() {
    if ! command -v systemctl >/dev/null 2>&1; then
        guardian_result_add \
            "systemd" \
            "availability" \
            "unknown" \
            "systemctl is not available" \
            "command" \
            "systemctl"
        return 0
    fi

    local version
    local default_target
    local failed_units

    version="$(systemctl --version | head -n 1)"
    default_target="$(systemctl get-default 2>/dev/null || printf 'unknown')"
    failed_units="$(
        systemctl list-units \
            --state=failed \
            --no-legend \
            --plain 2>/dev/null |
        awk '{print $1}' |
        paste -sd ',' -
    )"

    guardian_result_add \
        "systemd" \
        "version" \
        "info" \
        "systemd version collected" \
        "version" \
        "$version"

    guardian_result_add \
        "systemd" \
        "default-target" \
        "info" \
        "Default systemd target collected" \
        "target" \
        "$default_target"

    if [[ -n "$failed_units" ]]; then
        guardian_result_add \
            "systemd" \
            "failed-unit-list" \
            "warning" \
            "Failed systemd unit names collected" \
            "units" \
            "$failed_units"
    else
        guardian_result_add \
            "systemd" \
            "failed-unit-list" \
            "ok" \
            "No failed systemd units were found" \
            "units" \
            ""
    fi
}

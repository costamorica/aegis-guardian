#!/usr/bin/env bash

set -Eeuo pipefail

module_check() {
    local kernel
    local architecture
    local uptime_seconds
    local disk_usage
    local memory_total
    local memory_available
    local memory_usage

    kernel="$(uname -r)"
    architecture="$(uname -m)"
    uptime_seconds="${UPTIME_SECONDS:-$(cut -d. -f1 /proc/uptime)}"
    disk_usage="$(df --output=pcent / | tail -n 1 | tr -dc '0-9')"

    memory_total="$(awk '/MemTotal/ {print $2}' /proc/meminfo)"
    memory_available="$(awk '/MemAvailable/ {print $2}' /proc/meminfo)"
    memory_usage=$((100 - memory_available * 100 / memory_total))

    guardian_result_add \
        "system" \
        "kernel" \
        "info" \
        "Kernel information collected" \
        "kernel" \
        "${kernel} (${architecture})"

    guardian_result_add \
        "system" \
        "uptime" \
        "info" \
        "System uptime collected" \
        "seconds" \
        "$uptime_seconds"

    if ((disk_usage >= 92)); then
        guardian_result_add \
            "system" \
            "disk-root" \
            "critical" \
            "Root filesystem usage is critical" \
            "usage_percent" \
            "$disk_usage"
    elif ((disk_usage >= 85)); then
        guardian_result_add \
            "system" \
            "disk-root" \
            "warning" \
            "Root filesystem usage is high" \
            "usage_percent" \
            "$disk_usage"
    else
        guardian_result_add \
            "system" \
            "disk-root" \
            "ok" \
            "Root filesystem usage is healthy" \
            "usage_percent" \
            "$disk_usage"
    fi

    if ((memory_usage >= 90)); then
        guardian_result_add \
            "system" \
            "memory" \
            "warning" \
            "Memory usage is high" \
            "usage_percent" \
            "$memory_usage"
    else
        guardian_result_add \
            "system" \
            "memory" \
            "ok" \
            "Memory usage is healthy" \
            "usage_percent" \
            "$memory_usage"
    fi
}

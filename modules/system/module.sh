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

module_diagnose() {
    local os_name
    local kernel
    local load
    local cpu_count
    local root_fs

    os_name="$(
        . /etc/os-release 2>/dev/null
        printf '%s' "${PRETTY_NAME:-unknown}"
    )"
    kernel="$(uname -srvmo)"
    load="$(cut -d' ' -f1-3 /proc/loadavg)"
    cpu_count="$(getconf _NPROCESSORS_ONLN 2>/dev/null || printf 'unknown')"
    root_fs="$(findmnt -n -o FSTYPE,OPTIONS / 2>/dev/null || printf 'unknown')"

    guardian_result_add \
        "system" \
        "operating-system" \
        "info" \
        "Operating system information collected" \
        "os" \
        "$os_name"

    guardian_result_add \
        "system" \
        "kernel-details" \
        "info" \
        "Detailed kernel information collected" \
        "kernel" \
        "$kernel"

    guardian_result_add \
        "system" \
        "load-average" \
        "info" \
        "Load average collected" \
        "load_1_5_15" \
        "$load"

    guardian_result_add \
        "system" \
        "cpu-count" \
        "info" \
        "Online CPU count collected" \
        "cpus" \
        "$cpu_count"

    guardian_result_add \
        "system" \
        "root-filesystem" \
        "info" \
        "Root filesystem details collected" \
        "filesystem" \
        "$root_fs"
}

module_name() {
    printf 'Système'
}

module_check() {
    local usage
    local total
    local available
    local memory
    local failed

    usage="$(df --output=pcent / | tail -n 1 | tr -dc '0-9')"

    if ((usage >= DISK_CRITICAL_PERCENT)); then
        emit_result "system.disk" "critical" false "Disque critique" "/=${usage}%"
    elif ((usage >= DISK_WARNING_PERCENT)); then
        emit_result "system.disk" "warning" false "Disque élevé" "/=${usage}%"
    else
        emit_result "system.disk" "ok" false "Disque sain" "/=${usage}%"
    fi

    total="$(awk '/MemTotal/ {print $2}' /proc/meminfo)"
    available="$(awk '/MemAvailable/ {print $2}' /proc/meminfo)"
    memory=$((100 - available * 100 / total))

    if ((memory >= MEMORY_WARNING_PERCENT)); then
        emit_result "system.memory" "warning" false "Mémoire élevée" "${memory}%"
    else
        emit_result "system.memory" "ok" false "Mémoire saine" "${memory}%"
    fi

    failed="$(
        systemctl list-units \
            --state=failed \
            --no-legend \
            --plain 2>/dev/null || true
    )"

    if [[ -n "$failed" ]]; then
        emit_result "system.systemd" "warning" false "Unités en échec" "$failed"
    else
        emit_result "system.systemd" "ok" false "Aucune unité en échec" ""
    fi
}

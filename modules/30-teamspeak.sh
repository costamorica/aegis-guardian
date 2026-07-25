module_name() {
    printf 'TeamSpeak'
}

module_check() {
    local voice_port
    local query_port
    local file_port

    check_container "teamspeak.container" "$TEAMSPEAK_CONTAINER"

    voice_port="$(
        docker port "$TEAMSPEAK_CONTAINER" 9987/udp 2>/dev/null || true
    )"

    query_port="$(
        docker port "$TEAMSPEAK_CONTAINER" 10011/tcp 2>/dev/null || true
    )"

    file_port="$(
        docker port "$TEAMSPEAK_CONTAINER" 30033/tcp 2>/dev/null || true
    )"

    if [[ -n "$voice_port" ]]; then
        emit_result "teamspeak.voice" "ok" false "Port vocal publié" "$voice_port"
    else
        emit_result "teamspeak.voice" "critical" false "Port vocal absent" "9987/udp"
    fi

    if [[ -n "$query_port" ]]; then
        emit_result "teamspeak.query" "ok" false "ServerQuery publié" "$query_port"
    else
        emit_result "teamspeak.query" "warning" false "ServerQuery non publié" "10011/tcp"
    fi

    if [[ -n "$file_port" ]]; then
        emit_result "teamspeak.files" "ok" false "Transfert publié" "$file_port"
    else
        emit_result "teamspeak.files" "warning" false "Transfert non publié" "30033/tcp"
    fi
}

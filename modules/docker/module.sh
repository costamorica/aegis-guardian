#!/usr/bin/env bash

set -Eeuo pipefail

docker_command_available() {
    command -v docker >/dev/null 2>&1
}

docker_daemon_available() {
    docker info >/dev/null 2>&1
}

module_check() {
    if ! docker_command_available; then
        guardian_result_add \
            "docker" \
            "cli" \
            "unknown" \
            "Docker CLI is not installed" \
            "command" \
            "docker"
        return 0
    fi

    local client_version
    client_version="$(docker version --format '{{.Client.Version}}' 2>/dev/null || printf 'unknown')"

    guardian_result_add \
        "docker" \
        "cli" \
        "info" \
        "Docker CLI is available" \
        "version" \
        "$client_version"

    if ! docker_daemon_available; then
        guardian_result_add \
            "docker" \
            "daemon" \
            "critical" \
            "Docker daemon is unavailable" \
            "socket" \
            "${DOCKER_HOST:-/var/run/docker.sock}"
        return 0
    fi

    local server_version
    local running
    local stopped

    server_version="$(docker version --format '{{.Server.Version}}' 2>/dev/null || printf 'unknown')"
    running="$(docker ps --quiet 2>/dev/null | wc -l)"
    stopped="$(docker ps --all --filter status=exited --quiet 2>/dev/null | wc -l)"

    guardian_result_add \
        "docker" \
        "daemon" \
        "ok" \
        "Docker daemon is available" \
        "version" \
        "$server_version"

    guardian_result_add \
        "docker" \
        "running-containers" \
        "info" \
        "Running container count collected" \
        "count" \
        "$running"

    if ((stopped > 0)); then
        guardian_result_add \
            "docker" \
            "stopped-containers" \
            "warning" \
            "Stopped containers were detected" \
            "count" \
            "$stopped"
    else
        guardian_result_add \
            "docker" \
            "stopped-containers" \
            "ok" \
            "No stopped containers were detected" \
            "count" \
            "0"
    fi
}

module_diagnose() {
    if ! docker_command_available; then
        guardian_result_add \
            "docker" \
            "cli" \
            "unknown" \
            "Docker CLI is not installed" \
            "command" \
            "docker"
        return 0
    fi

    local client_version
    client_version="$(docker version --format '{{.Client.Version}}' 2>/dev/null || printf 'unknown')"

    guardian_result_add \
        "docker" \
        "client-version" \
        "info" \
        "Docker client version collected" \
        "version" \
        "$client_version"

    if ! docker_daemon_available; then
        guardian_result_add \
            "docker" \
            "daemon" \
            "critical" \
            "Docker daemon is unavailable" \
            "socket" \
            "${DOCKER_HOST:-/var/run/docker.sock}"
        return 0
    fi

    local server_version
    local storage_driver
    local cgroup_driver
    local container_summary
    local image_count

    server_version="$(docker version --format '{{.Server.Version}}' 2>/dev/null || printf 'unknown')"
    storage_driver="$(docker info --format '{{.Driver}}' 2>/dev/null || printf 'unknown')"
    cgroup_driver="$(docker info --format '{{.CgroupDriver}}' 2>/dev/null || printf 'unknown')"
    container_summary="$(
        docker ps --all \
            --format '{{.Names}}={{.Status}}' 2>/dev/null |
        paste -sd ';' -
    )"
    image_count="$(docker image ls --quiet 2>/dev/null | sort -u | wc -l)"

    guardian_result_add \
        "docker" \
        "server-version" \
        "info" \
        "Docker server version collected" \
        "version" \
        "$server_version"

    guardian_result_add \
        "docker" \
        "storage-driver" \
        "info" \
        "Docker storage driver collected" \
        "driver" \
        "$storage_driver"

    guardian_result_add \
        "docker" \
        "cgroup-driver" \
        "info" \
        "Docker cgroup driver collected" \
        "driver" \
        "$cgroup_driver"

    guardian_result_add \
        "docker" \
        "containers" \
        "info" \
        "Docker container states collected" \
        "containers" \
        "${container_summary:-none}"

    guardian_result_add \
        "docker" \
        "images" \
        "info" \
        "Docker image count collected" \
        "count" \
        "$image_count"
}

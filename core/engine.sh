#!/usr/bin/env bash

set -Eeuo pipefail

guardian_read_version() {
    if [[ ! -r "$GUARDIAN_VERSION_FILE" ]]; then
        printf 'unknown'
        return
    fi

    tr -d '[:space:]' < "$GUARDIAN_VERSION_FILE"
}

guardian_command_version() {
    printf 'Aegis Guardian %s\n' "$(guardian_read_version)"
}

guardian_parse_format() {
    local format="text"

    while (($#)); do
        case "$1" in
            --format)
                shift
                format="${1:-}"
                ;;
            --format=*)
                format="${1#*=}"
                ;;
        esac
        shift || true
    done

    case "$format" in
        text|json)
            printf '%s' "$format"
            ;;
        *)
            printf 'Unsupported format: %s\n' "$format" >&2
            return 3
            ;;
    esac
}

guardian_execute_module() {
    local module_file="$1"
    local mode="$2"
    local function_name="module_${mode}"

    unset -f module_check module_diagnose 2>/dev/null || true

    # shellcheck disable=SC1090
    source "$module_file"

    if ! declare -F "$function_name" >/dev/null; then
        guardian_result_add \
            "registry" \
            "module-api" \
            "unknown" \
            "Module does not implement requested operation" \
            "operation" \
            "${mode}:$(basename "$(dirname "$module_file")")"
        unset -f module_check module_diagnose 2>/dev/null || true
        return 0
    fi

    local status=0

    set +e
    "$function_name"
    status=$?
    set -e

    if ((status != 0)); then
        guardian_result_add \
            "registry" \
            "module-runtime" \
            "critical" \
            "Module execution failed" \
            "module" \
            "$module_file"
    fi

    unset -f module_check module_diagnose 2>/dev/null || true
}

guardian_command_run() {
    local mode="$1"
    shift

    local requested_module=""
    local format="text"
    local argument

    while (($#)); do
        argument="$1"

        case "$argument" in
            --format)
                shift
                format="${1:-}"
                ;;
            --format=*)
                format="${argument#*=}"
                ;;
            -*)
                printf 'Unknown option: %s\n' "$argument" >&2
                return 3
                ;;
            *)
                if [[ -n "$requested_module" ]]; then
                    printf 'Only one module may be selected.\n' >&2
                    return 3
                fi
                requested_module="$argument"
                ;;
        esac

        shift || true
    done

    case "$format" in
        text|json) ;;
        *)
            printf 'Unsupported format: %s\n' "$format" >&2
            return 3
            ;;
    esac

    guardian_results_reset "$mode"
    guardian_registry_discover

    local module_file

    if [[ -n "$requested_module" ]]; then
        if ! module_file="$(guardian_registry_find "$requested_module")"; then
            printf 'Unknown module: %s\n' "$requested_module" >&2
            return 3
        fi

        guardian_execute_module "$module_file" "$mode"
    else
        for module_file in "${GUARDIAN_MODULE_PATHS[@]}"; do
            guardian_execute_module "$module_file" "$mode"
        done
    fi

    GUARDIAN_RUN_FINISHED_AT="$(date --iso-8601=seconds)"

    guardian_render "$format"

    local overall
    overall="$(guardian_overall_status)"
    return "$(guardian_exit_code_for_status "$overall")"
}

guardian_command_report() {
    local format
    format="$(guardian_parse_format "$@")"

    if ((${#GUARDIAN_RESULTS[@]} == 0)); then
        printf 'No in-memory report is available. Run guardian check or diagnose first.\n' >&2
        return 3
    fi

    guardian_render "$format"
}

guardian_render() {
    local format="$1"

    case "$format" in
        text) guardian_report_text ;;
        json) guardian_report_json ;;
    esac
}

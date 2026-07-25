#!/usr/bin/env bash

set -Eeuo pipefail

declare -ag GUARDIAN_MODULE_PATHS=()
declare -ag GUARDIAN_MODULE_IDS=()

guardian_registry_reset() {
    GUARDIAN_MODULE_PATHS=()
    GUARDIAN_MODULE_IDS=()
}

guardian_registry_discover() {
    guardian_registry_reset

    local module_file
    local metadata_file
    local module_id

    while IFS= read -r -d '' module_file; do
        metadata_file="${module_file%/module.sh}/metadata.sh"

        if [[ ! -r "$metadata_file" ]]; then
            guardian_result_add \
                "registry" \
                "metadata" \
                "warning" \
                "Module metadata is missing" \
                "module" \
                "$module_file"
            continue
        fi

        unset guardian_module_id guardian_module_version guardian_module_description

        # shellcheck disable=SC1090
        source "$metadata_file"

        module_id="${guardian_module_id:-}"

        if [[ -z "$module_id" ]]; then
            guardian_result_add \
                "registry" \
                "module-id" \
                "warning" \
                "Module identifier is missing" \
                "module" \
                "$module_file"
            continue
        fi

        GUARDIAN_MODULE_PATHS+=("$module_file")
        GUARDIAN_MODULE_IDS+=("$module_id")
    done < <(
        find "${GUARDIAN_ROOT}/modules" \
            -mindepth 2 \
            -maxdepth 2 \
            -type f \
            -name module.sh \
            -print0 |
        sort -z
    )
}

guardian_registry_find() {
    local requested="$1"
    local index

    for index in "${!GUARDIAN_MODULE_IDS[@]}"; do
        if [[ "${GUARDIAN_MODULE_IDS[$index]}" == "$requested" ]]; then
            printf '%s' "${GUARDIAN_MODULE_PATHS[$index]}"
            return 0
        fi
    done

    return 1
}

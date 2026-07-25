#!/usr/bin/env bash

set -Eeuo pipefail

GUARDIAN_ROOT="${GUARDIAN_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
GUARDIAN_VERSION_FILE="${GUARDIAN_ROOT}/VERSION"
GUARDIAN_CONFIG_FILE="${GUARDIAN_CONFIG_FILE:-${GUARDIAN_ROOT}/config/guardian.conf.example}"

# shellcheck source=core/config.sh
source "${GUARDIAN_ROOT}/core/config.sh"

# shellcheck source=core/results.sh
source "${GUARDIAN_ROOT}/core/results.sh"

# shellcheck source=core/registry.sh
source "${GUARDIAN_ROOT}/core/registry.sh"

# shellcheck source=core/engine.sh
source "${GUARDIAN_ROOT}/core/engine.sh"

# shellcheck source=reporters/text.sh
source "${GUARDIAN_ROOT}/reporters/text.sh"

# shellcheck source=reporters/json.sh
source "${GUARDIAN_ROOT}/reporters/json.sh"

guardian_main() {
    guardian_load_config

    local command="${1:-help}"
    shift || true

    case "$command" in
        version|--version|-V)
            guardian_command_version
            ;;
        check)
            guardian_command_check "$@"
            ;;
        report)
            guardian_command_report "$@"
            ;;
        help|--help|-h)
            guardian_print_help
            ;;
        *)
            printf 'Unknown command: %s\n\n' "$command" >&2
            guardian_print_help >&2
            return 3
            ;;
    esac
}

guardian_print_help() {
    cat <<'EOF'
Aegis Guardian

Usage:
  guardian version
  guardian check [module] [--format text|json]
  guardian report --format text|json
  guardian help

Commands:
  version   Print the Guardian version
  check     Run all checks or one module
  report    Render the latest in-memory result set
  help      Show this help

Guardian 0.2.0-dev is read-only.
EOF
}

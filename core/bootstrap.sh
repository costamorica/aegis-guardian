#!/usr/bin/env bash

set -Eeuo pipefail

GUARDIAN_ROOT="${GUARDIAN_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
GUARDIAN_VERSION_FILE="${GUARDIAN_ROOT}/VERSION"
GUARDIAN_CONFIG_FILE="${GUARDIAN_CONFIG_FILE:-${GUARDIAN_ROOT}/config/guardian.conf.example}"

source "${GUARDIAN_ROOT}/core/config.sh"
source "${GUARDIAN_ROOT}/core/results.sh"
source "${GUARDIAN_ROOT}/core/registry.sh"
source "${GUARDIAN_ROOT}/core/engine.sh"
source "${GUARDIAN_ROOT}/reporters/text.sh"
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
            guardian_command_run "check" "$@"
            ;;
        diagnose)
            guardian_command_run "diagnose" "$@"
            ;;
        modules)
            guardian_command_modules
            ;;
        info)
            guardian_command_info
            ;;
        doctor)
            guardian_command_doctor
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
  guardian info
  guardian modules
  guardian doctor
  guardian check [module] [--format text|json] [--save]
  guardian diagnose [module] [--format text|json] [--save]
  guardian help

Commands:
  version    Print the Guardian version
  info       Show runtime information
  modules    List discovered modules
  doctor     Validate Guardian prerequisites and configuration
  check      Run health checks
  diagnose   Collect extended diagnostic evidence
  help       Show this help

Guardian 1.0.0-rc1 is read-only.
EOF
}

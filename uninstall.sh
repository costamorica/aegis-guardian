#!/usr/bin/env bash

set -Eeuo pipefail

if [[ "$EUID" -ne 0 ]]; then
    printf 'Run this uninstaller as root.\n' >&2
    exit 1
fi

systemctl disable --now aegis-guardian.timer 2>/dev/null || true

rm -f /etc/systemd/system/aegis-guardian.service
rm -f /etc/systemd/system/aegis-guardian.timer
rm -f /usr/local/bin/guardian
rm -rf /usr/local/lib/aegis-guardian

systemctl daemon-reload

printf 'Aegis Guardian removed.\n'
printf 'Configuration and reports were preserved.\n'

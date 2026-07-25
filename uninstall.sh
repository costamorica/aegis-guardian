#!/usr/bin/env bash

set -Eeuo pipefail

if [[ "$EUID" -ne 0 ]]; then
    exit 1
fi

systemctl disable --now aegis-guardian.timer 2>/dev/null || true

rm -f /etc/systemd/system/aegis-guardian.service
rm -f /etc/systemd/system/aegis-guardian.timer

systemctl daemon-reload

rm -rf /opt/aegis-guardian

printf 'Moteur Aegis Guardian supprimé.\n'
printf 'Configuration et rapports conservés.\n'

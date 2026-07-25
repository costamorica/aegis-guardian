#!/usr/bin/env bash

set -Eeuo pipefail

if [[ "$EUID" -ne 0 ]]; then
    printf 'Mise à jour root requise.\n' >&2
    exit 1
fi

SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

systemctl stop aegis-guardian.timer 2>/dev/null || true

rm -rf \
    /opt/aegis-guardian/bin \
    /opt/aegis-guardian/lib \
    /opt/aegis-guardian/modules

cp -a \
    "$SOURCE_DIR/bin" \
    "$SOURCE_DIR/lib" \
    "$SOURCE_DIR/modules" \
    /opt/aegis-guardian/

chmod 750 /opt/aegis-guardian/bin/aegis-guardian
chmod 750 /opt/aegis-guardian/lib/*.sh

install \
    -o root \
    -g root \
    -m 644 \
    "$SOURCE_DIR/systemd/aegis-guardian.service" \
    /etc/systemd/system/aegis-guardian.service

install \
    -o root \
    -g root \
    -m 644 \
    "$SOURCE_DIR/systemd/aegis-guardian.timer" \
    /etc/systemd/system/aegis-guardian.timer

systemctl daemon-reload
systemctl start aegis-guardian.timer

printf 'Aegis Guardian mis à jour.\n'

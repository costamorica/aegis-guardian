#!/usr/bin/env bash

set -Eeuo pipefail
umask 027

if [[ "$EUID" -ne 0 ]]; then
    printf 'Run this installer as root.\n' >&2
    exit 1
fi

SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="/usr/local/lib/aegis-guardian"
CONFIG_DIR="/etc/aegis-guardian"

for command in bash python3 find sort hostname date systemctl; do
    if ! command -v "$command" >/dev/null 2>&1; then
        printf 'Missing required command: %s\n' "$command" >&2
        printf 'Guardian will not install packages automatically.\n' >&2
        exit 1
    fi
done

install -d -o root -g root -m 755 "$TARGET_DIR"
install -d -o root -g root -m 750 "$CONFIG_DIR"
install -d -o root -g root -m 750 /var/lib/aegis-guardian/reports
install -d -o root -g root -m 750 /var/log/aegis-guardian

rm -rf \
    "$TARGET_DIR/core" \
    "$TARGET_DIR/modules" \
    "$TARGET_DIR/reporters" \
    "$TARGET_DIR/config" \
    "$TARGET_DIR/tests"

cp -a \
    "$SOURCE_DIR/core" \
    "$SOURCE_DIR/modules" \
    "$SOURCE_DIR/reporters" \
    "$SOURCE_DIR/config" \
    "$SOURCE_DIR/tests" \
    "$TARGET_DIR/"

install -o root -g root -m 755 "$SOURCE_DIR/guardian" "$TARGET_DIR/guardian"
install -o root -g root -m 644 "$SOURCE_DIR/VERSION" "$TARGET_DIR/VERSION"

if [[ ! -f "$CONFIG_DIR/guardian.conf" ]]; then
    install \
        -o root \
        -g root \
        -m 640 \
        "$SOURCE_DIR/config/guardian.conf.example" \
        "$CONFIG_DIR/guardian.conf"
fi

ln -sfn "$TARGET_DIR/guardian" /usr/local/bin/guardian

install -o root -g root -m 644 \
    "$SOURCE_DIR/systemd/aegis-guardian.service" \
    /etc/systemd/system/aegis-guardian.service

install -o root -g root -m 644 \
    "$SOURCE_DIR/systemd/aegis-guardian.timer" \
    /etc/systemd/system/aegis-guardian.timer

"$TARGET_DIR/tests/syntax.sh"
"$TARGET_DIR/guardian" doctor

systemctl daemon-reload
systemctl enable --now aegis-guardian.timer

printf '\nAegis Guardian installed successfully.\n'
printf 'Run: guardian check\n'
printf 'Reports: /var/lib/aegis-guardian/reports\n'

#!/usr/bin/env bash

set -Eeuo pipefail
umask 027

if [[ "$EUID" -ne 0 ]]; then
    printf 'Installation root requise.\n' >&2
    exit 1
fi

SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

apt-get update

DEBIAN_FRONTEND=noninteractive apt-get install -y \
    bash \
    curl \
    docker.io \
    python3 \
    util-linux

install -d -o root -g root -m 750 /opt/aegis-guardian
install -d -o root -g root -m 750 /etc/aegis-guardian
install -d -o root -g root -m 750 /var/log/aegis-guardian
install -d -o root -g root -m 750 /var/lib/aegis-guardian/reports

rm -rf \
    /opt/aegis-guardian/bin \
    /opt/aegis-guardian/lib \
    /opt/aegis-guardian/modules

cp -a \
    "$SOURCE_DIR/bin" \
    "$SOURCE_DIR/lib" \
    "$SOURCE_DIR/modules" \
    /opt/aegis-guardian/

find /opt/aegis-guardian -type d -exec chmod 750 {} +
find /opt/aegis-guardian -type f -exec chmod 640 {} +

chmod 750 /opt/aegis-guardian/bin/aegis-guardian
chmod 750 /opt/aegis-guardian/lib/*.sh

if [[ ! -f /etc/aegis-guardian/guardian.conf ]]; then
    install \
        -o root \
        -g root \
        -m 640 \
        "$SOURCE_DIR/config/guardian.conf.example" \
        /etc/aegis-guardian/guardian.conf
fi

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

bash -n /opt/aegis-guardian/bin/aegis-guardian

for file in \
    /opt/aegis-guardian/lib/*.sh \
    /opt/aegis-guardian/modules/*.sh; do

    bash -n "$file"
done

systemctl daemon-reload

systemd-analyze verify \
    /etc/systemd/system/aegis-guardian.service \
    /etc/systemd/system/aegis-guardian.timer

systemctl enable --now aegis-guardian.timer

printf '\nAegis Guardian installé.\n'
printf 'Configuration : /etc/aegis-guardian/guardian.conf\n'
printf 'Test : systemctl start aegis-guardian.service\n'

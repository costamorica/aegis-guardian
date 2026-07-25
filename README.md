# Aegis Guardian

**Aegis Guardian** is an open-source Linux support, monitoring and diagnostic tool built around the **Aegis Method**.

It helps system administrators inspect hosts, understand failures and produce structured reports without silently taking ownership of the infrastructure.

> Observe first. Understand before acting. Change nothing without explicit authorization.

## Version 1.0

Aegis Guardian 1.0 is a stable, read-only foundation focused on:

* system health checks;
* extended diagnostics;
* modular Linux inspection;
* human-readable terminal output;
* machine-readable JSON reports;
* recurring systemd execution;
* safe, non-intrusive installation.

The first production validation was completed on the **CDDN Debian 13 infrastructure**. Development and cross-distribution testing were also performed on **Gentoo Linux**.

## Features

### Command-line interface

```bash
guardian version
guardian info
guardian modules
guardian doctor
guardian check
guardian diagnose
```

Checks and diagnostics may target a specific module:

```bash
guardian check system
guardian check systemd
guardian check docker

guardian diagnose system
guardian diagnose systemd
guardian diagnose docker
```

Reports are available as text or JSON:

```bash
guardian check --format text
guardian check --format json
guardian check --format json --save
```

### Included modules

| Module    | Checks                                   | Diagnostics                                                    |
| --------- | ---------------------------------------- | -------------------------------------------------------------- |
| `system`  | Kernel, uptime, disk usage, memory usage | OS, kernel details, load average, CPU count, root filesystem   |
| `systemd` | System state and failed units            | Version, default target and failed unit list                   |
| `docker`  | CLI, daemon and container state          | Versions, storage driver, cgroup driver, containers and images |

Docker is optional. If it is not installed, Guardian reports the module as unavailable without modifying the host.

### Persistent reports

Saved reports are written to:

```text
/var/lib/aegis-guardian/reports/
```

The most recent report is always available at:

```text
/var/lib/aegis-guardian/reports/latest.json
```

### Scheduled checks

The installer enables a systemd timer that runs Guardian every 15 minutes:

```bash
systemctl status aegis-guardian.timer
systemctl list-timers aegis-guardian.timer
```

The service is a `Type=oneshot` unit. An `inactive (dead)` state after a successful run is normal.

## Safety model

Aegis Guardian 1.0 is strictly read-only.

It does not:

* install, remove or upgrade packages;
* replace Docker or another package provider;
* restart services or containers;
* modify application configuration;
* alter storage, networking or firewall rules;
* perform automatic repairs.

The installer only deploys Guardian itself, its configuration and its systemd units.

Controlled recovery actions are planned for a later release and will require an explicit allow-list, risk classification and complete audit trail.

## Requirements

Required commands:

* Bash;
* Python 3;
* systemd;
* standard GNU/Linux utilities such as `find`, `sort`, `hostname` and `date`.

Docker is optional and only required for the Docker module.

Guardian does not install missing dependencies automatically.

## Installation

Clone the repository:

```bash
git clone https://github.com/costamorica/aegis-guardian.git
cd aegis-guardian
```

Run the local validation suite:

```bash
./tests/syntax.sh
./tests/smoke.sh
./guardian doctor
```

Install Guardian:

```bash
sudo ./install.sh
```

Verify the system-wide installation:

```bash
guardian version
guardian doctor
guardian check --format text
```

## Configuration

The system-wide configuration file is:

```text
/etc/aegis-guardian/guardian.conf
```

Example:

```bash
INSTANCE_NAME="my-server"
AUTO_REPAIR=false

LOG_DIR="/var/log/aegis-guardian"
STATE_DIR="/var/lib/aegis-guardian"
REPORT_DIR="/var/lib/aegis-guardian/reports"

DEFAULT_FORMAT="json"
```

`AUTO_REPAIR` must remain `false` in version 1.0.

## Uninstallation

```bash
sudo ./uninstall.sh
```

The uninstaller removes:

* the Guardian runtime;
* the command wrapper;
* the systemd service and timer.

Configuration and generated reports are preserved.

## Architecture

```text
aegis-guardian/
├── guardian
├── VERSION
├── core/
│   ├── bootstrap.sh
│   ├── config.sh
│   ├── engine.sh
│   ├── registry.sh
│   └── results.sh
├── modules/
│   ├── docker/
│   ├── system/
│   └── systemd/
├── reporters/
│   ├── json.sh
│   └── text.sh
├── config/
├── systemd/
├── tests/
└── docs/
```

Guardian discovers modules automatically. Each module provides metadata and implements one or more supported operations.

## Module contract

```bash
guardian_module_id="example"
guardian_module_version="1"
guardian_module_description="Example Guardian module"

module_check() {
    guardian_result_add \
        "example" \
        "health" \
        "ok" \
        "Example check passed" \
        "state" \
        "healthy"
}

module_diagnose() {
    guardian_result_add \
        "example" \
        "details" \
        "info" \
        "Diagnostic information collected" \
        "value" \
        "example"
}
```

## Exit codes

| Code | Meaning                                       |
| ---: | --------------------------------------------- |
|  `0` | Healthy, informational, or successful command |
|  `1` | Warning or unknown state                      |
|  `2` | Critical finding                              |
|  `3` | Invalid command or configuration              |
|  `4` | Safety or permission refusal                  |
|  `5` | Internal Guardian failure                     |

## Development

```bash
git clone https://github.com/costamorica/aegis-guardian.git
cd aegis-guardian

./tests/syntax.sh
./tests/smoke.sh
./guardian check
./guardian diagnose system
```

Before submitting changes:

* keep modules independent;
* preserve read-only behavior for the 1.0 branch;
* run the complete test suite;
* document new commands, modules and result fields;
* never add implicit package-management operations.

## Documentation

* [Manifesto](MANIFESTO.md)
* [Architecture](docs/ARCHITECTURE.md)
* [Specification](docs/SPECIFICATION.md)
* [Security model](docs/SECURITY-MODEL.md)
* [Version 1.0 release scope](docs/RELEASE-1.0.md)
* [Roadmap](ROADMAP.md)
* [Changelog](CHANGELOG.md)

## Project philosophy

Aegis Guardian is not intended to replace the system administrator.

It handles repetitive observation, evidence collection and reporting so that human attention can remain focused on decisions that require context and judgment.

The project follows a simple sequence:

```text
Observe → Understand → Report → Decide
```

## License

Aegis Guardian is released under the **GNU General Public License v3.0 or later**.

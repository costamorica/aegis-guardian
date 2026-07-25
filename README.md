# Aegis Guardian

Aegis Guardian is an open-source Linux support, monitoring and controlled recovery tool built around the **Aegis Method**.

It is designed to assist system administrators without silently taking ownership of their infrastructure.

> Observe first. Understand before acting. Repair only what is explicitly allowed.

## Project status

Current development version: **0.1.0-dev**

Aegis Guardian is not production-ready yet. Its command-line interface, module API and configuration format may change before version 1.0.

The CDDN infrastructure is the first real-world test environment, while the software itself remains distribution- and organization-agnostic.

## Core goals

- inspect Linux hosts without changing them;
- explain why a component is considered healthy or unhealthy;
- collect structured diagnostic information;
- perform only explicitly authorized, low-risk recovery actions;
- produce human-readable and machine-readable reports;
- remain lightweight, auditable and easy to extend.

## Non-goals

Aegis Guardian must not:

- install or replace Docker, Caddy, MariaDB, PHP or other infrastructure components;
- change package providers;
- rewrite application configuration without explicit approval;
- hide failed recovery attempts;
- treat automation as a substitute for system administration.

## Planned CLI

```bash
guardian check
guardian check docker
guardian diagnose discourse
guardian repair docker.restart
guardian report --format json
```

## Safety model

Guardian separates observation from modification:

| Mode | Changes the host | Purpose |
|---|---:|---|
| `check` | No | Health assessment |
| `diagnose` | No | Extended evidence collection |
| `repair` | Only allow-listed actions | Controlled recovery |

Automatic repair is disabled by default.

## Development

```bash
git clone https://github.com/costamorica/aegis-guardian.git
cd aegis-guardian
./tests/syntax.sh
```

Do not install development versions on a production host without reviewing the changes first.

## Documentation

- [Manifesto](MANIFESTO.md)
- [Architecture](docs/ARCHITECTURE.md)
- [Specification](docs/SPECIFICATION.md)
- [Security model](docs/SECURITY-MODEL.md)
- [Roadmap](ROADMAP.md)

## License

GPL-3.0-or-later.

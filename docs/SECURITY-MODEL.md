# Security Model

## Default posture

Aegis Guardian is read-only by default.

The installation process may copy Guardian files and install its own systemd units. It must not install, remove, upgrade or replace unrelated infrastructure packages.

## Repair policy

Repair actions are denied unless all conditions are met:

1. the action is declared by a loaded module;
2. the action has a known risk level;
3. the action is enabled in the local policy;
4. the runtime mode is `repair` or an explicitly enabled automatic-repair mode;
5. required confirmation has been obtained.

## Risk levels

| Level | Example | Default |
|---|---|---|
| `none` | Refresh a Guardian report | Allowed |
| `low` | Restart an existing service | Denied until enabled |
| `medium` | Reload an existing service configuration | Denied |
| `high` | Modify application configuration | Denied |
| `critical` | Install/remove packages, alter storage | Forbidden |

## Package management

Guardian must never automatically:

- install Docker;
- switch between Docker CE and distribution Docker packages;
- remove packages;
- run `autoremove`;
- change repositories;
- perform a distribution upgrade.

Package state may be inspected and reported.

## Auditability

Every repair attempt must record:

- requested action;
- policy decision;
- command executed;
- exit status;
- before and after state;
- duration;
- resulting Guardian status.

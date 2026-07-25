# Initial Specification

Status: Draft  
Target: `0.1.x`

## Command model

```text
guardian <command> [target] [options]
```

Initial commands:

```text
guardian check [module]
guardian diagnose [module]
guardian repair <action-id>
guardian report [--format text|json]
guardian version
```

## Exit codes

| Code | Meaning |
|---:|---|
| 0 | Healthy or command completed |
| 1 | Warning findings |
| 2 | Critical findings |
| 3 | Invalid command or configuration |
| 4 | Permission or safety-policy refusal |
| 5 | Internal Guardian failure |

## Result schema

```json
{
  "schema_version": 1,
  "run_id": "20260725T190000+0200",
  "host": "server.example.net",
  "mode": "check",
  "overall_status": "warning",
  "results": [
    {
      "module": "docker",
      "check": "daemon",
      "status": "ok",
      "summary": "Docker daemon is available",
      "evidence": {
        "service": "docker.service",
        "state": "active"
      },
      "repair_action": null,
      "timestamp": "2026-07-25T19:00:00+02:00"
    }
  ]
}
```

## Status values

- `ok`
- `info`
- `warning`
- `critical`
- `repaired`
- `unknown`

## Module contract

A module must declare metadata and expose supported operations.

```bash
guardian_module_id="docker"
guardian_module_version="1"
guardian_module_description="Docker Engine health checks"

module_check() {
    :
}

module_diagnose() {
    :
}

module_repair() {
    :
}
```

`module_repair` is optional.

## Repair action metadata

```bash
repair_id="docker.restart"
repair_risk="low"
repair_requires_confirmation="false"
repair_default_allowed="false"
```

Unknown repair actions are always denied.

# Architecture

## Overview

Aegis Guardian is composed of five layers:

```text
CLI
 │
 ▼
Core engine
 │
 ├── Configuration
 ├── Module registry
 ├── Safety policy
 ├── Result store
 └── Reporters
      │
      ▼
Modules
```

## Components

### CLI

Parses commands and selects an execution mode:

- `check`
- `diagnose`
- `repair`
- `report`
- `version`

### Core engine

Coordinates module discovery, execution, isolation and result aggregation.

A module failure must not stop unrelated modules.

### Module registry

Discovers installed modules and validates their metadata before execution.

### Safety policy

Controls whether a repair action may run.

Unknown actions are denied by default.

### Result store

Normalizes all findings into a shared result schema.

### Reporters

Render the same result set as:

- terminal text;
- JSON;
- e-mail;
- static HTML in a later release.

## Target source tree

```text
aegis-guardian/
├── guardian
├── VERSION
├── core/
│   ├── engine.sh
│   ├── config.sh
│   ├── registry.sh
│   ├── results.sh
│   └── safety.sh
├── modules/
├── reporters/
├── config/
├── systemd/
├── tests/
└── docs/
```

## Design constraints

- no implicit package installation;
- no package-provider replacement;
- no repair outside the allow-list;
- automatic repair disabled by default;
- modules isolated from one another;
- structured output available for every run.

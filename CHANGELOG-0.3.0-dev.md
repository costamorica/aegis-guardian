## [0.3.0-dev] - 2026-07-25

### Added

- `guardian diagnose`;
- extended system diagnostics;
- extended systemd diagnostics;
- read-only Docker module;
- Docker client and daemon checks;
- Docker container, image, storage and cgroup evidence;
- improved module-operation validation.

### Changed

- module execution failures are isolated and converted into Guardian results;
- result runs now record their actual mode.

### Security

- all Docker operations are read-only;
- no service, container, image, volume or package is modified;
- automatic repair remains disabled.

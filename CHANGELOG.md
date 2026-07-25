# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

### Changed

- reset the development version to `0.1.0-dev`;
- switched project documentation to English;
- redefined Guardian as a Linux support and controlled recovery tool;
- made read-only operation the default;
- documented the repair allow-list and risk model.

### Security

- package installation and package-provider replacement are now forbidden by design;
- automatic repair is disabled by default.

### Incident note

The initial prototype installer explicitly requested Debian's `docker.io` package on a host already using Docker CE. APT attempted to replace the existing Docker stack, causing a temporary service interruption and a Buildx package conflict.

No container data was lost, but the incident established a permanent design rule: Guardian must inspect infrastructure dependencies, never select or replace their package provider.

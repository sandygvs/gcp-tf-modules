# Changelog

All notable changes to this module will be documented in this file.

## [0.1.0] - 2022-10-17

### Added

- Cloud Scheduler job for stopping Vertex notebooks
- Cloud Scheduler job for starting Vertex notebooks
- Terraform outputs variables for describing schedulers details
- Changelog file for this module

### Changed

- Vertex notebook instance example related with Cloud Scheduler

### Removed

- {}

## [0.1.1] - 2022-11-17

### Added

- post_startup_script, kms and custom_gpu_driver_path optional attribute
- Changelog file for this module

### Changed

- Vertex notebook instance to have proxy setting enabled by default
- Vertex notebook instance example related with post startup script

### Removed

- {}

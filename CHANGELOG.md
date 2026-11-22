# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.0] - 2026-11-22

### Added

- Resize and center the active window on its current monitor (`Ctrl+Alt+R`).
- Move the active window to the next monitor, cycling through all monitors (`Ctrl+Alt+M`).
- Move the active window directly to monitor 1 or 2 (`Ctrl+Alt+1`, `Ctrl+Alt+2`).
- Move the active window by physical direction, left or right (`Ctrl+Alt+Left`, `Ctrl+Alt+Right`).
- Monitor detection based on the window's center point instead of `A_ScreenWidth`.
- Work-area aware sizing, so windows are never hidden behind the taskbar.
- Fullscreen state preservation when moving windows between monitors.
- Proportional downscaling when a window is larger than the target monitor.

[Unreleased]: https://github.com/<your-user>/window-helper/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/<your-user>/window-helper/releases/tag/v1.0.0

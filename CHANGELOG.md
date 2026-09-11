# Changelog

All notable changes to the Pulse SDK monorepo are documented here.
Each package maintains its own detailed changelog:

- [`pulse_dev` CHANGELOG](packages/pulse_dev/CHANGELOG.md)
- [`pulse_dev_flutter` CHANGELOG](packages/pulse_dev_flutter/CHANGELOG.md)
- [`pulse_dio` CHANGELOG](packages/pulse_dio/CHANGELOG.md)
- [`pulse_http` CHANGELOG](packages/pulse_http/CHANGELOG.md)

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## Unreleased

Post-release pub.dev score and code-quality pass across all 4 packages (no public API
changes). See each package's own CHANGELOG for details.

- Added a per-package `example/` so pub.dev scores each package's own usage example.
- Shortened `pulse_dev`, `pulse_dev_flutter`, and `pulse_http` pubspec descriptions to
  fit pub.dev's 60–180 character guidance.
- Completed dartdoc coverage on the remaining undocumented public API members.
- Removed a leftover `dart create` template stub (`lib/src/pulse_http_base.dart`,
  `lib/src/pulse_dio_base.dart`) that shipped unused in `pulse_http`/`pulse_dio`.
- Fixed a Flutter Web incompatibility in `pulse_dev_flutter` caused by a `dart:io`
  import in `FlutterContextCollector`.
- Added `.github/ISSUE_TEMPLATE/`, a PR template, and `.github/FUNDING.yml`.

---

## 0.1.0

### Highlights

Initial release of the full Pulse SDK suite — 4 packages covering 8 phases of development:

| Package             | Version | Description                                                                          |
|---------------------|---------|--------------------------------------------------------------------------------------|
| `pulse_dev`         | 0.1.0   | Pure Dart core — events, pipeline, sanitization, network, performance, offline queue |
| `pulse_dev_flutter` | 0.1.0   | Flutter integration — error capture, context, debug inspector                        |
| `pulse_dio`         | 0.1.0   | Dio interceptor for network monitoring                                               |
| `pulse_http`        | 0.1.0   | `package:http` wrapper for network monitoring                                        |

### pulse_dev

- Event system with 6 typed event types (`ErrorEvent`, `ExceptionEvent`, `BreadcrumbEvent`, `CustomEvent`, `NetworkEvent`, `TransactionEvent`)
- Composable `EventPipeline` with processors → sanitizer → transport
- `DefaultSanitizer` with recursive redaction of 20+ sensitive key patterns
- `PulseNetworkObserver` for framework-agnostic network monitoring
- `PulseTransaction` and `PulseSpan` for performance instrumentation
- `EventQueue` with FIFO ordering, exponential backoff, and event expiration
- `PulseEventObserver` for telemetry subscription

### pulse_dev_flutter

- `Pulse` static facade — `initialize`, `captureException`, `captureError`, `addBreadcrumb`, `track`, `startTransaction`, `run`
- `FlutterErrorIntegration` — hooks `FlutterError.onError` without breaking existing handlers
- `ZoneErrorIntegration` — captures unhandled async errors via `runZonedGuarded`
- `FlutterPerformanceIntegration` — startup time and slow frame detection
- `FlutterContextCollector` — platform device context collection
- `PulseInspector` — in-app debug overlay (development-only, zero cost in release)

### pulse_dio

- `PulseDioInterceptor` — automatic Dio HTTP monitoring with configurable redaction

### pulse_http

- `PulseHttpClient` — drop-in `BaseClient` wrapper for `package:http` monitoring

### Infrastructure

- Dart Pub Workspace monorepo with Melos scripting
- GitHub Actions CI — format, analyze, test all packages on every push and PR
- `dart pub publish --dry-run` validation step in CI
- Full architecture documentation in `docs/architecture.md`

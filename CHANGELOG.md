# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## Unreleased

_No unreleased changes._

---

## 0.1.0 — 2026-09-10

### pulse_dev

**Added**

- `PulseEvent` sealed base class with full serialization contract (`toJson`)
- `ErrorEvent`, `ExceptionEvent`, `BreadcrumbEvent`, `CustomEvent` event types
- `PulseEventType` enum for event categorization
- `PulseContext` immutable device/app metadata carrier
- `PulseConfig` immutable configuration value object with DSN validation
- `PulseTransport` abstract interface for pluggable event delivery
- `NoOpTransport` default no-operation transport for development/testing
- `PulseStorage` abstract interface for future offline queuing (no implementation)
- `PulseSanitizer` abstract interface for privacy-preserving event sanitization
- `DefaultSanitizer` with recursive redaction of 20+ sensitive key patterns
- `EventProcessor` abstract interface for composable event enrichment/filtering
- `SanitizingProcessor` convenience processor wrapping a `PulseSanitizer`
- `EventPipeline` orchestrating: processors → sanitizer → transport with error isolation
- `BreadcrumbBuffer` fixed-capacity ring buffer (configurable, default 100)
- `PulseLogger` abstract interface for SDK-internal diagnostics
- `NoOpLogger` default no-operation logger
- `Clock` interface and `SystemClock` production implementation
- `IdGenerator` interface and `UuidGenerator` UUID v4 implementation
- `PulsePlatform` string constants for standard platform identifiers
- `kPulseSdkVersion` SDK version constant

### pulse_dev_flutter

**Added**

- `Pulse` static facade with `initialize`, `captureException`, `captureError`,
  `addBreadcrumb`, `track`, `run`, `close`, and `isInitialized`
- `PulseClient` internal stateful coordinator
- `FlutterErrorIntegration` hooking `FlutterError.onError` (chains previous handler)
- `ZoneErrorIntegration` providing `runZonedGuarded`-based unhandled error capture
- `FlutterContextCollector` populating `PulseContext` from Flutter platform APIs
- `pulse_example` reference Flutter application

### Infrastructure

**Added**

- Melos monorepo with scripted format, analyze, test, and publish-dry-run
- Dart Pub Workspace root configuration
- GitHub Actions CI (format · analyze · test on every push and PR)
- GitHub Actions publish dry-run validation
- Full architecture documentation in `docs/architecture.md`

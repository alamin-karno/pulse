## Unreleased

### Changed
- Shortened the `pubspec.yaml` description to fit pub.dev's 60–180 character guidance.
- Added dartdoc to `PulseTransaction.create` (previously undocumented).
- Added `example/example.dart` demonstrating `PulseConfig`, `EventPipeline`, and a
  custom `PulseTransport` — needed for pub.dev's per-package example score.

## 0.1.0

Initial release of `pulse_dev` — the pure Dart core of the Pulse SDK.

### Added

#### Event System
- `PulseEvent` — sealed base class with unique ID, timestamp, and event type
- `ErrorEvent` — captures Dart `Error` instances with type, message, and stack trace
- `ExceptionEvent` — captures Dart `Exception` instances with type, message, and stack trace
- `BreadcrumbEvent` — structured breadcrumb with category, level, message, and metadata
- `CustomEvent` — arbitrary developer-defined events with typed properties
- `NetworkEvent` — HTTP request/response metric capture
- `TransactionEvent` — performance transaction with spans and duration measurement
- `PulseSpan` — lightweight child span within a transaction
- `PulseEventType` — enum for all event categories
- `BreadcrumbLevel` — severity levels for breadcrumbs (debug, info, warning, error)

#### Context
- `PulseContext` — immutable application/device metadata carrier (OS, locale, app version)

#### Configuration
- `PulseConfig` — immutable SDK configuration value object with DSN validation, sampling, and feature flags
- `PulseNetworkConfig` — network monitoring configuration (headers, body capture, URL redaction)
- `PulsePerformanceConfig` — performance monitoring configuration (sampling, slow operation detection)
- `PulseSanitizationConfig` — privacy sanitization configuration (additional redacted keys, string patterns)

#### Event Pipeline
- `EventPipeline` — orchestrates the full processing chain: processors → sanitizer → queue → transport
- `EventProcessor` — abstract interface for composable event enrichment and filtering
- `SanitizingProcessor` — convenience processor wrapping any `PulseSanitizer`
- `PulseEventObserver` — interface for telemetry event observation (used by the debug inspector)

#### Privacy & Sanitization
- `PulseSanitizer` — abstract interface for event sanitization
- `DefaultSanitizer` — production sanitizer with recursive redaction of 20+ sensitive key patterns including `password`, `token`, `authorization`, `api_key`, `cookie`, `secret`, `credit_card`, `ssn`, and more
- Recursive `Map` and `List` sanitization
- Configurable additional redacted keys via `PulseSanitizationConfig`
- String pattern sanitization via callbacks
- Maximum payload size protection

#### Network Monitoring
- `PulseNetworkObserver` — core network event capture abstraction
- Configurable URL parameter redaction
- Configurable header and body capture

#### Performance Monitoring
- `PulseTransaction` — abstract interface for performance transactions
- `ActivePulseSpan` — abstract interface for timing spans
- `RealPulseTransaction` — concrete transaction implementation with span tree support
- Configurable sampling rate

#### Transport
- `PulseTransport` — abstract interface for pluggable event delivery
- `PulseTransportResult` — delivery status enum (success, retryableFailure, permanentFailure)
- `NoOpTransport` — default no-operation transport for development and testing
- `InMemoryTransport` — in-memory transport for unit testing

#### Storage & Offline Queue
- `PulseStorage` — abstract storage interface for offline event persistence
- `InMemoryPulseStorage` — memory-backed storage implementation
- `EventQueue` — FIFO event queue with configurable retry, exponential backoff, max size, expiration, and duplicate protection

#### Breadcrumbs
- `BreadcrumbBuffer` — fixed-capacity circular ring buffer (configurable, default 100 entries)

#### Utilities
- `PulseLogger` — abstract interface for SDK-internal diagnostics
- `NoOpLogger` — default no-operation logger
- `Clock` — injectable clock interface for deterministic testing
- `SystemClock` — production wall-clock implementation
- `IdGenerator` — injectable ID generator interface
- `UuidGenerator` — UUID v4 implementation using `package:uuid`
- `kPulseSdkVersion` — SDK version constant
- `kPulseEventSchemaVersion` — event schema version constant
- `PulsePlatform` — string constants for standard platform identifiers

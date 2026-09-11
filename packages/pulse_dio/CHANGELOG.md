## Unreleased

### Changed
- Added dartdoc to `PulseDioInterceptor`'s constructor and `onRequest`/`onResponse`/
  `onError` overrides (previously undocumented).
- Added `example/example.dart` — needed for pub.dev's per-package example score.

### Removed
- Deleted `lib/src/pulse_dio_base.dart`, an unused leftover `dart create` template
  stub that was never exported.

## 0.1.0

Initial release of `pulse_dio` — Dio interceptor for the Pulse SDK.

### Added

- `PulseDioInterceptor` — `Interceptor` implementation for `package:dio`
  - Captures HTTP method, URL, status code, duration, request/response sizes
  - Respects `PulseNetworkConfig` for header, body, and URL parameter redaction
  - Integrates with the Pulse event pipeline via `PulseNetworkObserver`
  - Safe failure mode: interceptor errors never affect the underlying Dio client
  - Supports all Dio request types (GET, POST, PUT, DELETE, PATCH, etc.)

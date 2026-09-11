## Unreleased

### Changed
- Shortened the `pubspec.yaml` description to fit pub.dev's 60–180 character guidance.
- Added `example/example.dart` — needed for pub.dev's per-package example score.

### Removed
- Deleted `lib/src/pulse_http_base.dart`, an unused leftover `dart create` template
  stub that was never exported.

## 0.1.0

Initial release of `pulse_http` — `package:http` wrapper for the Pulse SDK.

### Added

- `PulseHttpClient` — `BaseClient` wrapper for `package:http`
  - Captures HTTP method, URL, status code, duration, request/response sizes
  - Respects `PulseNetworkConfig` for header, body, and URL parameter redaction
  - Integrates with the Pulse event pipeline via `PulseNetworkObserver`
  - Drop-in replacement: wraps any existing `http.Client`
  - Safe failure mode: capture errors never affect the underlying HTTP request
  - Properly delegates `close()` to the underlying client

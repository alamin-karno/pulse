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

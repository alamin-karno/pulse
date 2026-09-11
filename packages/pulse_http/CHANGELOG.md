# Changelog — pulse_http

All notable changes to this package will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## 0.1.0 — 2026-09-11

Initial release of `pulse_http` — `package:http` wrapper for the Pulse SDK.

### Added

- `PulseHttpClient` — `BaseClient` wrapper for `package:http`
  - Captures HTTP method, URL, status code, duration, request/response sizes
  - Respects `PulseNetworkConfig` for header, body, and URL parameter redaction
  - Integrates with the Pulse event pipeline via `PulseNetworkObserver`
  - Drop-in replacement: wraps any existing `http.Client`
  - Safe failure mode: capture errors never affect the underlying HTTP request
  - Properly delegates `close()` to the underlying client

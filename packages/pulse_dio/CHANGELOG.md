# Changelog — pulse_dio

All notable changes to this package will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## 0.1.0 — 2026-09-11

Initial release of `pulse_dio` — Dio interceptor for the Pulse SDK.

### Added

- `PulseDioInterceptor` — `Interceptor` implementation for `package:dio`
  - Captures HTTP method, URL, status code, duration, request/response sizes
  - Respects `PulseNetworkConfig` for header, body, and URL parameter redaction
  - Integrates with the Pulse event pipeline via `PulseNetworkObserver`
  - Safe failure mode: interceptor errors never affect the underlying Dio client
  - Supports all Dio request types (GET, POST, PUT, DELETE, PATCH, etc.)

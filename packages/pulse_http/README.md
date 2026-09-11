# pulse_http

[![pub.dev](https://img.shields.io/pub/v/pulse_http.svg?label=pulse_http)](https://pub.dev/packages/pulse_http)
[![CI](https://github.com/alamin-karno/pulse/actions/workflows/ci.yml/badge.svg)](https://github.com/alamin-karno/pulse/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

`package:http` wrapper for the **[Pulse](https://github.com/alamin-karno/pulse) Developer Intelligence SDK**.

`PulseHttpClient` is a drop-in `BaseClient` wrapper that automatically captures HTTP
request and response metrics and forwards them to the Pulse event pipeline.

---

## Features

- ✅ Drop-in replacement for any `http.Client`
- ✅ Captures HTTP method, URL, status code, duration, and sizes
- ✅ Integrates with `PulseNetworkConfig` — honour URL redaction, header/body capture settings
- ✅ Safe failure mode — capture errors never affect your HTTP requests
- ✅ Properly delegates `close()` to the underlying client
- ✅ Zero overhead when Pulse is disabled

---

## Installation

```yaml
dependencies:
  pulse_dev_flutter: ^0.1.0   # or pulse_dev for pure Dart
  pulse_http: ^0.1.0
  http: ^1.2.0
```

---

## Usage

### Flutter (with `pulse_dev_flutter`)

```dart
import 'package:http/http.dart' as http;
import 'package:pulse_dev_flutter/pulse_dev_flutter.dart';
import 'package:pulse_http/pulse_http.dart';

// After Pulse.initialize(...)

// Replace your existing http.Client with a monitored wrapper
final client = Pulse.network != null
    ? PulseHttpClient(http.Client(), observer: Pulse.network!)
    : http.Client();

// Use exactly like a normal http.Client
final response = await client.get(Uri.parse('https://api.example.com/users'));
```

### Pure Dart (with `pulse_dev`)

```dart
import 'package:http/http.dart' as http;
import 'package:pulse_dev/pulse_dev.dart';
import 'package:pulse_http/pulse_http.dart';

final config = PulseConfig(
  dsn: 'https://key@ingest.example.com/1',
  network: PulseNetworkConfig(enabled: true),
);
final pipeline = EventPipeline.fromConfig(config);
final observer = PulseNetworkObserver(pipeline: pipeline, config: config.network!);

final client = PulseHttpClient(http.Client(), observer: observer);

// Use exactly like a normal http.Client
final response = await client.get(Uri.parse('https://api.example.com/data'));
```

### With a custom base client

```dart
// Works with any BaseClient implementation
final client = PulseHttpClient(
  RetryClient(http.Client()),   // existing retry wrapper
  observer: Pulse.network!,
);
```

---

## Network Configuration

```dart
PulseConfig(
  // ...
  network: PulseNetworkConfig(
    enabled: true,
    captureHeaders: false,           // never capture request/response headers
    captureBody: false,              // never capture request/response body
    sampleRate: 1.0,                 // capture 100% of requests
    redactQueryParameters: const {   // redact these query param values
      'token',
      'api_key',
      'secret',
    },
  ),
)
```

> [!IMPORTANT]
> Authorization headers, cookies, and request bodies are **never captured** unless
> `captureHeaders` and `captureBody` are explicitly set to `true`.

---

## What is captured

| Field | Always | Configurable |
|-------|--------|-------------|
| HTTP method | ✅ | — |
| URL (path only) | ✅ | — |
| URL query parameters | ✅ | Redact specific keys |
| Status code | ✅ | — |
| Duration (ms) | ✅ | — |
| Request size | ✅ | — |
| Response size | ✅ | — |
| Request headers | ❌ | Enable via `captureHeaders: true` |
| Response headers | ❌ | Enable via `captureHeaders: true` |
| Request body | ❌ | Enable via `captureBody: true` |
| Response body | ❌ | Enable via `captureBody: true` |
| Authorization header | ❌ | Never captured |
| Cookie header | ❌ | Never captured |

---

## Related Packages

| Package | Description |
|---------|-------------|
| [`pulse_dev`](https://pub.dev/packages/pulse_dev) | Pure Dart core |
| [`pulse_dev_flutter`](https://pub.dev/packages/pulse_dev_flutter) | Flutter integration |
| [`pulse_dio`](https://pub.dev/packages/pulse_dio) | `package:dio` interceptor |

---

## Contributing

See [CONTRIBUTING.md](https://github.com/alamin-karno/pulse/blob/main/CONTRIBUTING.md).

## License

MIT — see [LICENSE](LICENSE).

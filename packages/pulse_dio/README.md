# pulse_dio

[![pub.dev](https://img.shields.io/pub/v/pulse_dio.svg?label=pulse_dio)](https://pub.dev/packages/pulse_dio)
[![CI](https://github.com/alamin-karno/pulse/actions/workflows/ci.yml/badge.svg)](https://github.com/alamin-karno/pulse/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

[Dio](https://pub.dev/packages/dio) interceptor for the **[Pulse](https://github.com/alamin-karno/pulse) Developer Intelligence SDK**.

Automatically captures HTTP request and response metrics from `package:dio` and
forwards them to the Pulse event pipeline — without touching your existing Dio configuration.

---

## Features

- ✅ Captures HTTP method, URL, status code, duration, and sizes
- ✅ Integrates with `PulseNetworkConfig` — honour URL redaction, header/body capture settings
- ✅ Safe failure mode — interceptor errors never affect your Dio requests
- ✅ Works alongside existing Dio interceptors
- ✅ Zero overhead when Pulse is disabled

---

## Installation

```yaml
dependencies:
  pulse_dev_flutter: ^0.1.0   # or pulse_dev for pure Dart
  pulse_dio: ^0.1.0
  dio: ^5.4.0
```

---

## Usage

### Flutter (with `pulse_dev_flutter`)

```dart
import 'package:dio/dio.dart';
import 'package:pulse_dev_flutter/pulse_dev_flutter.dart';
import 'package:pulse_dio/pulse_dio.dart';

// After Pulse.initialize(...)

final dio = Dio();

if (Pulse.network != null) {
  dio.interceptors.add(
    PulseDioInterceptor(observer: Pulse.network!),
  );
}
```

### Pure Dart (with `pulse_dev`)

```dart
import 'package:dio/dio.dart';
import 'package:pulse_dev/pulse_dev.dart';
import 'package:pulse_dio/pulse_dio.dart';

final config = PulseConfig(
  dsn: 'https://key@ingest.example.com/1',
  network: PulseNetworkConfig(enabled: true),
);
final pipeline = EventPipeline.fromConfig(config);
final observer = PulseNetworkObserver(pipeline: pipeline, config: config.network!);

final dio = Dio()
  ..interceptors.add(PulseDioInterceptor(observer: observer));
```

---

## Network Configuration

Control what is captured via `PulseNetworkConfig`:

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
| [`pulse_http`](https://pub.dev/packages/pulse_http) | `package:http` adapter |

---

## Contributing

See [CONTRIBUTING.md](https://github.com/alamin-karno/pulse/blob/main/CONTRIBUTING.md).

## License

MIT — see [LICENSE](LICENSE).

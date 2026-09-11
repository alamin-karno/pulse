# pulse_dev

[![pub.dev](https://img.shields.io/pub/v/pulse_dev.svg?label=pulse_dev)](https://pub.dev/packages/pulse_dev)
[![CI](https://github.com/alamin-karno/pulse/actions/workflows/ci.yml/badge.svg)](https://github.com/alamin-karno/pulse/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

Pure Dart core for the **[Pulse](https://github.com/alamin-karno/pulse) Developer Intelligence SDK**.

`pulse_dev` is Flutter-free and works in any Dart project — Flutter apps, CLI tools, or
server-side Dart. It provides the event model, processing pipeline, privacy engine, network
observer, performance instrumentation, and offline storage — all behind clean, replaceable interfaces.

For Flutter applications, use [`pulse_dev_flutter`](https://pub.dev/packages/pulse_dev_flutter)
which builds on this package and provides the `Pulse` static API.

---

## Features

- 📦 **Typed event model** — `ErrorEvent`, `ExceptionEvent`, `BreadcrumbEvent`, `CustomEvent`, `NetworkEvent`, `TransactionEvent`
- 🔀 **Composable pipeline** — pluggable `EventProcessor` chain → sanitizer → transport
- 🔒 **Privacy-first sanitization** — recursive PII redaction for 20+ sensitive key patterns out of the box
- 🌐 **Network monitoring** — framework-agnostic `PulseNetworkObserver`; adapters for `dio` and `package:http` sold separately
- ⚡ **Performance tracking** — transactions, spans, and slow operation detection
- 💾 **Offline queue** — FIFO event queue with exponential backoff, configurable retry, and expiration
- 🔌 **Pluggable transport** — implement `PulseTransport` to send events anywhere
- 🧪 **Fully testable** — injectable `Clock`, `IdGenerator`, `PulseTransport`, and `PulseStorage`

---

## Installation

```yaml
dependencies:
  pulse_dev: ^0.1.0
```

For Flutter projects, use `pulse_dev_flutter` instead — it re-exports everything from this package.

---

## Quick Start (pure Dart)

```dart
import 'package:pulse_dev/pulse_dev.dart';

final config = PulseConfig(
  dsn: 'https://key@ingest.example.com/1',
  environment: 'production',
  release: '1.0.0',
  transport: MyHttpTransport(),
);

final pipeline = EventPipeline.fromConfig(config);

try {
  await riskyOperation();
} catch (e, st) {
  await pipeline.process(ExceptionEvent(
    id: const UuidGenerator().newId(),
    timestamp: const SystemClock().now(),
    sdkVersion: kPulseSdkVersion,
    appVersion: config.release,
    environment: config.environment,
    platform: PulsePlatform.dart,
    context: PulseContext.empty,
    exceptionType: e.runtimeType.toString(),
    message: e.toString(),
    stackTrace: st.toString(),
    breadcrumbs: const [],
    handled: true,
  ));
}
```

---

## Custom Transport

Implement `PulseTransport` to deliver events to your backend:

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pulse_dev/pulse_dev.dart';

final class MyHttpTransport implements PulseTransport {
  final Uri _endpoint;
  final String _apiKey;

  MyHttpTransport({required Uri endpoint, required String apiKey})
      : _endpoint = endpoint,
        _apiKey = apiKey;

  @override
  Future<PulseTransportResult> send(PulseEvent event) async {
    try {
      final response = await http.post(
        _endpoint,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode(event.toJson()),
      );
      if (response.statusCode == 429 || response.statusCode >= 500) {
        return PulseTransportResult.retryableFailure;
      }
      if (response.statusCode >= 400) {
        return PulseTransportResult.permanentFailure;
      }
      return PulseTransportResult.success;
    } catch (_) {
      return PulseTransportResult.retryableFailure;
    }
  }

  @override
  Future<void> close() async {}
}
```

---

## Custom Sanitizer

Override sensitive data redaction for your organisation's needs:

```dart
import 'package:pulse_dev/pulse_dev.dart';

final class MyOrgSanitizer extends DefaultSanitizer {
  MyOrgSanitizer()
      : super(
          config: const PulseSanitizationConfig(
            additionalRedactedKeys: {
              'employee_id',
              'internal_project_code',
              'client_secret',
            },
          ),
        );
}
```

---

## Custom Event Processor

Enrich or filter events before transport:

```dart
import 'package:pulse_dev/pulse_dev.dart';

final class EnvironmentTagProcessor implements EventProcessor {
  final String region;

  const EnvironmentTagProcessor({required this.region});

  @override
  PulseEvent? process(PulseEvent event) {
    if (event is CustomEvent) {
      return CustomEvent(
        // copy fields and add region tag
        properties: {...event.properties, 'region': region},
        // ... other fields
      );
    }
    return event; // pass-through for other event types
  }
}
```

---

## Network Monitoring

```dart
import 'package:pulse_dev/pulse_dev.dart';

final observer = PulseNetworkObserver(
  pipeline: pipeline,
  config: PulseNetworkConfig(
    enabled: true,
    captureHeaders: false,          // never capture headers by default
    captureBody: false,             // never capture body by default
    redactQueryParameters: const {'token', 'api_key'},
  ),
);

// Use with an HTTP adapter:
// - package:pulse_http → PulseHttpClient
// - package:pulse_dio  → PulseDioInterceptor
```

---

## Performance Tracking

```dart
import 'package:pulse_dev/pulse_dev.dart';

final transaction = pipeline.startTransaction('checkout_flow');

try {
  final span = transaction.startSpan('validate_cart');
  await validateCart();
  span.finish();

  final paySpan = transaction.startSpan('process_payment');
  await processPayment();
  paySpan.finish();

  transaction.finish(status: 'ok');
} catch (e, st) {
  transaction.finish(status: 'error', error: e);
  rethrow;
}
```

---

## Configuration Reference

```dart
PulseConfig(
  dsn: 'https://key@ingest.example.com/1',   // required
  environment: 'staging',                     // default: 'production'
  release: '2.0.0+42',                        // app version string
  debug: true,                                // verbose SDK logging
  enabled: true,                              // global kill-switch
  sampleRate: 0.25,                           // drop 75% of events (0.0–1.0)
  maxBreadcrumbs: 50,                         // breadcrumb ring buffer size
  transport: MyHttpTransport(),               // your delivery implementation
  sanitizer: MyOrgSanitizer(),               // custom privacy sanitization
  logger: MyDebugLogger(),                    // custom SDK-internal logging
  processors: [EnvironmentTagProcessor()],   // event enrichment chain
  network: PulseNetworkConfig(...),           // network monitoring options
  performance: PulsePerformanceConfig(...),   // performance monitoring options
  sanitization: PulseSanitizationConfig(...), // sanitization options
)
```

---

## Related Packages

| Package | Description |
|---------|-------------|
| [`pulse_dev_flutter`](https://pub.dev/packages/pulse_dev_flutter) | Flutter integration — `Pulse` static API, error hooks, debug inspector |
| [`pulse_http`](https://pub.dev/packages/pulse_http) | `package:http` network adapter |
| [`pulse_dio`](https://pub.dev/packages/pulse_dio) | `package:dio` network interceptor |

---

## Contributing

See [CONTRIBUTING.md](https://github.com/alamin-karno/pulse/blob/main/CONTRIBUTING.md).

## License

MIT — see [LICENSE](LICENSE).

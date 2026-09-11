# pulse_dev_flutter

[![pub.dev](https://img.shields.io/pub/v/pulse_dev_flutter.svg?label=pulse_dev_flutter)](https://pub.dev/packages/pulse_dev_flutter)
[![CI](https://github.com/alamin-karno/pulse/actions/workflows/ci.yml/badge.svg)](https://github.com/alamin-karno/pulse/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

Flutter integration for the **[Pulse](https://github.com/alamin-karno/pulse) Developer Intelligence SDK**.

`pulse_dev_flutter` wraps the pure Dart [`pulse_dev`](https://pub.dev/packages/pulse_dev) core
and exposes the `Pulse` static façade — the single entry point for all SDK features in a Flutter app.

---

## Features

- 🚨 **Automatic error capture** — hooks `FlutterError.onError` and `runZonedGuarded` without breaking existing handlers
- 🍞 **Breadcrumbs** — record navigation, user actions, and custom context before a crash
- 📊 **Custom event tracking** — track any event with typed properties
- 🌐 **Network monitoring** — pairs with [`pulse_http`](https://pub.dev/packages/pulse_http) or [`pulse_dio`](https://pub.dev/packages/pulse_dio)
- ⚡ **Performance transactions** — measure startup, screen loads, and async operations
- 💾 **Offline queue** — events survive connectivity loss and are retried automatically
- 🔍 **In-app Debug Inspector** — floating overlay to inspect events live in development
- 🔒 **Privacy-first** — sanitization runs before every transport call; cannot be bypassed

---

## Installation

```yaml
dependencies:
  pulse_dev_flutter: ^0.1.0
```

---

## Quick Start

### 1. Initialize in `main.dart`

```dart
import 'package:flutter/material.dart';
import 'package:pulse_dev_flutter/pulse_dev_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Pulse.initialize(
    PulseConfig(
      dsn: 'https://your-key@ingest.example.com/your-project-id',
      environment: 'production',
      release: '1.0.0+1',
    ),
  );

  // Wraps runApp in a zone that captures all unhandled async errors
  Pulse.run(() => runApp(const MyApp()));
}
```

### 2. Capture exceptions manually

```dart
try {
  await loadUserProfile();
} catch (e, stackTrace) {
  Pulse.captureException(e, stackTrace: stackTrace);
}
```

### 3. Add breadcrumbs

```dart
Pulse.addBreadcrumb(
  'User tapped checkout',
  category: 'ui.action',
  data: {'screen': 'CartScreen', 'item_count': 3},
);
```

### 4. Track custom events

```dart
Pulse.track(
  'purchase_completed',
  properties: {
    'amount': 99.99,
    'currency': 'USD',
    'items': 3,
  },
);
```

### 5. Monitor network requests

With [`pulse_http`](https://pub.dev/packages/pulse_http):

```dart
import 'package:http/http.dart' as http;
import 'package:pulse_http/pulse_http.dart';

final client = Pulse.network != null
    ? PulseHttpClient(http.Client(), observer: Pulse.network!)
    : http.Client();
```

With [`pulse_dio`](https://pub.dev/packages/pulse_dio):

```dart
import 'package:dio/dio.dart';
import 'package:pulse_dio/pulse_dio.dart';

final dio = Dio();
if (Pulse.network != null) {
  dio.interceptors.add(PulseDioInterceptor(observer: Pulse.network!));
}
```

### 6. Track performance

```dart
final transaction = Pulse.startTransaction('dashboard_load');

try {
  final span = transaction.startSpan('fetch_user');
  final user = await api.fetchUser();
  span.finish();

  transaction.finish(status: 'ok');
} catch (e, st) {
  transaction.finish(status: 'error', error: e);
  Pulse.captureException(e, stackTrace: st);
  rethrow;
}
```

### 7. Pulse Debug Inspector (development only)

Wrap your `MaterialApp` with `PulseInspector.builder()` to get a floating
in-app overlay to inspect all captured telemetry without leaving your app:

```dart
MaterialApp(
  // Automatically disabled in release builds (kReleaseMode guard)
  builder: PulseInspector.builder(enabled: true),
  home: const MyHomePage(),
)
```

Tap the floating `💚` button to open the inspector. Browse errors, breadcrumbs,
network requests, performance transactions, and SDK status — all offline.

---

## Configuration Reference

```dart
PulseConfig(
  dsn: 'https://key@ingest.example.com/1',       // required
  environment: 'staging',                         // default: 'production'
  release: '2.0.0+42',                            // app version
  debug: true,                                    // verbose SDK logging
  enabled: true,                                  // global kill-switch
  sampleRate: 0.25,                               // event sampling 0.0–1.0
  maxBreadcrumbs: 100,                            // default breadcrumb capacity
  captureFlutterErrors: true,                     // hook FlutterError.onError
  captureUnhandledErrors: true,                   // hook runZonedGuarded
  transport: MyCustomTransport(),                 // custom delivery backend
  sanitizer: MyCustomSanitizer(),                 // custom privacy rules
  logger: MyDebugLogger(),                        // custom SDK logging
  processors: [MyEnrichmentProcessor()],          // event enrichment chain
  network: PulseNetworkConfig(
    enabled: true,
    captureHeaders: false,
    captureBody: false,
    sampleRate: 1.0,
    redactQueryParameters: const {'token', 'key'},
  ),
  performance: PulsePerformanceConfig(
    enabled: true,
    sampleRate: 0.1,
    detectSlowOperations: true,
    slowOperationThreshold: Duration(seconds: 2),
  ),
  sanitization: PulseSanitizationConfig(
    additionalRedactedKeys: const {'employee_id', 'org_secret'},
  ),
)
```

---

## Safe Failure Guarantee

The Pulse SDK **never crashes your application**. Every integration is isolated:

- SDK internal errors are swallowed and optionally logged via `PulseLogger`
- `FlutterError.onError` is chained — your existing handler is always called
- `runZonedGuarded` preserves any existing zone error handler
- The `PulseInspector` is a pure no-op in release mode

---

## Related Packages

| Package | Description |
|---------|-------------|
| [`pulse_dev`](https://pub.dev/packages/pulse_dev) | Pure Dart core — events, pipeline, interfaces |
| [`pulse_http`](https://pub.dev/packages/pulse_http) | `package:http` network adapter |
| [`pulse_dio`](https://pub.dev/packages/pulse_dio) | `package:dio` network interceptor |

---

## Contributing

See [CONTRIBUTING.md](https://github.com/alamin-karno/pulse/blob/main/CONTRIBUTING.md).

## License

MIT — see [LICENSE](LICENSE).

# Pulse

**Open-source Flutter/Dart Developer Intelligence SDK**

[![CI](https://github.com/pulse-dart/pulse/actions/workflows/ci.yml/badge.svg)](https://github.com/pulse-dart/pulse/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![pub.dev pulse_dev](https://img.shields.io/pub/v/pulse_dev.svg?label=pulse_dev)](https://pub.dev/packages/pulse_dev)
[![pub.dev pulse_dev_flutter](https://img.shields.io/pub/v/pulse_dev_flutter.svg?label=pulse_dev_flutter)](https://pub.dev/packages/pulse_dev_flutter)

---

## What is Pulse?

Pulse is an open-source developer intelligence SDK for Flutter and Dart applications.
It provides a unified, privacy-first observability layer that helps you understand
what is happening in your application without compromising your users' data.

Pulse is designed to be:

- **Developer-first** — minimal setup, clear API, excellent documentation
- **Privacy-first** — never collects PII, sanitization built into the pipeline
- **Vendor-neutral** — bring your own backend via the transport interface
- **Lightweight** — minimal dependencies, no unnecessary overhead
- **Extensible** — every component is replaceable via interfaces
- **Self-hostable** — no lock-in to any cloud service

---

## Why Pulse?

Most error tracking and observability tools are built around a SaaS model that:

- Sends all your data to a third-party cloud by default
- Requires vendor lock-in from the first line of code
- Has opaque data handling practices
- Is expensive at scale
- Is not designed for developer customization

Pulse is different. It is open-source infrastructure that you own and control.

---

## Packages

| Package | Description | Pub.dev |
|---------|-------------|---------|
| [`pulse_dev`](packages/pulse_dev) | Pure Dart core — events, pipeline, interfaces | [![pub](https://img.shields.io/pub/v/pulse_dev.svg)](https://pub.dev/packages/pulse_dev) |
| [`pulse_dev_flutter`](packages/pulse_dev_flutter) | Flutter integration — error capture, lifecycle | [![pub](https://img.shields.io/pub/v/pulse_dev_flutter.svg)](https://pub.dev/packages/pulse_dev_flutter) |

---

## Installation

Add `pulse_dev_flutter` to your Flutter application's `pubspec.yaml`:

```yaml
dependencies:
  pulse_dev_flutter: ^0.1.0
```

For pure Dart projects (CLI, server-side), use `pulse_dev` directly:

```yaml
dependencies:
  pulse_dev: ^0.1.0
```

---

## Quick Start

### 1. Initialize Pulse

In your `main.dart`, initialize Pulse before calling `runApp`:

```dart
import 'package:flutter/material.dart';
import 'package:pulse_dev_flutter/pulse_dev_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Pulse.initialize(
    const PulseConfig(
      dsn: 'https://your-key@ingest.example.com/your-project-id',
      environment: 'production',
      release: '1.0.0+1',
    ),
  );

  // Automatically captures unhandled errors in the zone
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

Breadcrumbs give context to errors by recording what happened before the crash:

```dart
Pulse.addBreadcrumb(
  'User tapped checkout button',
  category: 'ui.action',
  data: {'screen': 'CartScreen', 'item_count': 3},
);
```

### 4. Track custom events

```dart
Pulse.track(
  'payment_initiated',
  properties: {
    'amount': 99.99,
    'currency': 'USD',
    'payment_method': 'card',
  },
);
```

---

## Basic Usage

### Configuration options

```dart
PulseConfig(
  dsn: 'https://key@ingest.example.com/1',   // required
  environment: 'staging',                     // default: 'production'
  release: '2.0.0+42',                        // your app version
  debug: true,                                // verbose SDK logging
  enabled: true,                              // kill-switch
  maxBreadcrumbs: 50,                         // default: 100
  captureFlutterErrors: true,                 // FlutterError.onError
  captureUnhandledErrors: true,               // runZonedGuarded
  transport: MyCustomTransport(),             // bring your own transport
  sanitizer: MyCustomSanitizer(),             // bring your own sanitizer
  logger: MyDebugLogger(),                    // bring your own logger
  processors: [MyEnrichmentProcessor()],      // custom event processors
)
```

### Custom transport

Implement `PulseTransport` from `pulse_dev` to send events anywhere:

```dart
import 'package:pulse_dev/pulse_dev.dart';

final class MyTransport implements PulseTransport {
  @override
  Future<void> send(PulseEvent event) async {
    // Send to your backend, file, or any destination
    final json = event.toJson();
    await myBackend.post('/events', json);
  }

  @override
  Future<void> close() async {
    // Flush and clean up
  }
}
```

### Custom event processor

```dart
final class TaggingProcessor implements EventProcessor {
  @override
  PulseEvent? process(PulseEvent event) {
    // Return null to drop the event
    // Return a modified event to enrich it
    return event; // pass-through for now
  }
}
```

---

## Architecture

Pulse follows a clean layered architecture:

```
pulse_dev_flutter  (Flutter integration, public API)
      │
      ▼
pulse_dev     (Pure Dart, event pipeline, interfaces)
```

Every event flows through a mandatory pipeline:

```
Capture → [Processors] → Sanitizer → Transport
```

See [docs/architecture.md](docs/architecture.md) for the full architecture document.

---

## Privacy

Pulse is built privacy-first:

- **No PII is collected by default** — no email, name, location, or device identifiers
- **Sanitization is mandatory** — runs before every transport call, cannot be disabled
- **You control the data** — bring your own transport; nothing is sent without your code
- **Redaction by default** — known sensitive key patterns are automatically redacted
  (`password`, `token`, `authorization`, `api_key`, `credit_card`, `ssn`, etc.)
- **Recursive redaction** — nested maps are fully scanned
- **Custom sanitizer** — provide your own `PulseSanitizer` for full control

---

## Roadmap

| Phase | Scope | Status |
|-------|-------|--------|
| 0 | Architecture and planning | ✅ Complete |
| 1 | Error/exception capture, breadcrumbs, custom events | ✅ Complete |
| 2 | HTTP transport, DSN parsing, retry logic | 🔜 Planned |
| 3 | Offline queue, user identification, navigation tracking | 🔜 Planned |
| 4 | Performance monitoring, spans, transactions | 🔜 Planned |
| 5 | Network intelligence, HTTP interceptors | 🔜 Planned |
| 6 | Remote configuration, feature flags | 🔜 Planned |

---

## Contributing

We welcome contributions of all kinds — bug reports, feature requests, documentation
improvements, and code contributions.

Please read [CONTRIBUTING.md](CONTRIBUTING.md) before submitting a pull request.

---

## Code of Conduct

This project follows the [Contributor Covenant Code of Conduct](CODE_OF_CONDUCT.md).
By participating, you agree to uphold this code.

---

## Security

To report a security vulnerability, please read [SECURITY.md](SECURITY.md).
Do **not** open a public GitHub issue for security vulnerabilities.

---

## License

Pulse is released under the [MIT License](LICENSE).

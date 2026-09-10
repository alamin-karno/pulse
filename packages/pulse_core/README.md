# pulse_core

[![pub.dev](https://img.shields.io/pub/v/pulse_core.svg)](https://pub.dev/packages/pulse_core)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

Pure Dart core for the [Pulse](https://github.com/pulse-dart/pulse) Developer
Intelligence SDK.

`pulse_core` is Flutter-free and can be used in any Dart project — Flutter apps,
CLI tools, or server-side Dart.

---

## What this package provides

- **Event model** — `PulseEvent` sealed base class with typed subtypes
- **Event pipeline** — composable processor chain with mandatory sanitization
- **Transport interface** — `PulseTransport` for pluggable event delivery
- **Storage interface** — `PulseStorage` for future offline queuing
- **Sanitization** — `DefaultSanitizer` with recursive PII redaction
- **Breadcrumb buffer** — fixed-capacity ring buffer
- **Configuration** — `PulseConfig` value object
- **Utilities** — injectable `Clock` and `IdGenerator` for testability

---

## Usage

For Flutter applications, use [`pulse_flutter`](../pulse_flutter) which provides
the developer-facing `Pulse` static API built on top of this package.

For non-Flutter Dart projects:

```dart
import 'package:pulse_core/pulse_core.dart';

final config = PulseConfig(
  dsn: 'https://key@ingest.example.com/1',
  transport: MyCustomTransport(),
);

final pipeline = EventPipeline.fromConfig(config);

// Capture an error
final event = ExceptionEvent(
  id: const UuidGenerator().newId(),
  timestamp: const SystemClock().now(),
  sdkVersion: kPulseSdkVersion,
  environment: config.environment,
  appVersion: config.release,
  platform: 'dart',
  context: PulseContext.empty,
  exceptionType: 'MyException',
  message: 'Something went wrong',
  breadcrumbs: const [],
  handled: true,
);

await pipeline.process(event);
```

---

## Custom transport

```dart
final class FileTransport implements PulseTransport {
  final File file;
  FileTransport(this.file);

  @override
  Future<void> send(PulseEvent event) async {
    await file.writeAsString(
      '${jsonEncode(event.toJson())}\n',
      mode: FileMode.append,
    );
  }

  @override
  Future<void> close() async {}
}
```

---

## Custom sanitizer

```dart
final class MyOrganizationSanitizer implements PulseSanitizer {
  @override
  PulseEvent sanitize(PulseEvent event) {
    // Your custom sanitization logic
    return event;
  }
}
```

---

## License

MIT — see [LICENSE](../../LICENSE).

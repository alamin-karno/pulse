# pulse_flutter

[![pub.dev](https://img.shields.io/pub/v/pulse_flutter.svg)](https://pub.dev/packages/pulse_flutter)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

Flutter integration for the [Pulse](https://github.com/pulse-dart/pulse)
Developer Intelligence SDK.

This package provides:
- The `Pulse` static facade — the developer-facing API
- Automatic Flutter error capture (`FlutterError.onError`)
- Automatic unhandled error capture (`runZonedGuarded`)
- Flutter platform/device context collection

For the pure Dart core, see [`pulse_core`](../pulse_core).

---

## Installation

```yaml
dependencies:
  pulse_flutter: ^0.1.0
```

---

## Quick Start

```dart
import 'package:flutter/material.dart';
import 'package:pulse_flutter/pulse_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Pulse.initialize(
    const PulseConfig(
      dsn: 'https://your-key@ingest.example.com/your-project-id',
      environment: 'production',
      release: '1.0.0+1',
    ),
  );

  Pulse.run(() => runApp(const MyApp()));
}
```

## License

MIT — see [LICENSE](../../LICENSE).

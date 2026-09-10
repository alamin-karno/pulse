# pulse_dev_flutter

[![pub.dev](https://img.shields.io/pub/v/pulse_dev_flutter.svg)](https://pub.dev/packages/pulse_dev_flutter)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

Flutter integration for the [Pulse](https://github.com/pulse-dart/pulse)
Developer Intelligence SDK.

This package provides:
- The `Pulse` static facade — the developer-facing API
- Automatic Flutter error capture (`FlutterError.onError`)
- Automatic unhandled error capture (`runZonedGuarded`)
- Flutter platform/device context collection

For the pure Dart core, see [`pulse_dev`](../pulse_dev).

---

## Installation

```yaml
dependencies:
  pulse_dev_flutter: ^0.1.0
```

---

## Quick Start

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

  Pulse.run(() => runApp(const MyApp()));
}
```

## License

MIT — see [LICENSE](../../LICENSE).

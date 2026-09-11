# pulse_example

Reference Flutter application demonstrating all features of the **Pulse Developer Intelligence SDK**.

---

## What this example covers

| Screen | Features demonstrated |
|--------|-----------------------|
| **Error Capture** | `captureException`, `captureError`, `FlutterError.reportError`, unhandled async errors |
| **Breadcrumbs** | Navigation breadcrumbs, UI action breadcrumbs, warning-level breadcrumbs, attach trail to exception |
| **Custom Events** | `Pulse.track()` with typed properties (purchase, onboarding, search, feature flags) |
| **Network Monitoring** | `PulseHttpClient` (package:http), `PulseDioInterceptor` (Dio), GET/POST/error requests |
| **Performance** | Fast transaction, multi-span transaction, slow operation detection, error transaction |
| **Sanitization** | Automatic PII redaction demo — password, token, api_key, nested cookie |

The **Pulse Debug Inspector** floating button (💚) is also enabled — tap it to browse all
captured events in real-time without leaving the app.

---

## Running the example

```bash
cd examples/pulse_example
flutter run
```

All events are printed to the Flutter debug console via the included `_ConsoleTransport`.
No real backend is needed.

---

## Connecting to a real backend

Replace `_ConsoleTransport` in `lib/main.dart` with your own `PulseTransport` implementation
that sends events to your ingest endpoint.

See [`pulse_dev`](https://pub.dev/packages/pulse_dev) for the transport interface documentation.

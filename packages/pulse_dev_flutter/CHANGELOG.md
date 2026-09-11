

## 0.1.0

Initial release of `pulse_dev_flutter` — the Flutter integration layer for the Pulse SDK.

### Added

#### Public API
- `Pulse` — static facade providing the complete developer-facing SDK API
  - `Pulse.initialize(config)` — initialize the SDK with configuration
  - `Pulse.run(callback)` — wraps app in error-capturing zone
  - `Pulse.captureException(exception, {stackTrace})` — manually capture exceptions
  - `Pulse.captureError(error, {stackTrace})` — manually capture errors
  - `Pulse.addBreadcrumb(message, {category, level, data})` — record breadcrumbs
  - `Pulse.track(name, {properties})` — track custom events
  - `Pulse.startTransaction(name, {operation})` — start a performance transaction
  - `Pulse.network` — expose `PulseNetworkObserver` for adapter packages
  - `Pulse.close()` — gracefully shut down the SDK
  - `Pulse.isInitialized` — boolean guard for safe SDK usage

#### Internal Architecture
- `PulseClient` — internal stateful coordinator managing all SDK subsystems

#### Flutter Error Integrations
- `FlutterErrorIntegration` — hooks `FlutterError.onError` and chains existing handlers
- `ZoneErrorIntegration` — captures unhandled errors via `runZonedGuarded`
- `FlutterPerformanceIntegration` — captures app startup time and slow frame detection
- `FlutterContextCollector` — collects `PulseContext` from Flutter platform APIs (device info, locale, OS)

#### Debug Inspector (development-only)
- `PulseInspector` — floating overlay widget for in-app telemetry inspection
  - `PulseInspector.builder()` — convenience builder for `MaterialApp.builder`
  - Zero overhead in release mode via `kReleaseMode` guard
- `InspectorState` — in-memory circular buffer for captured events (development only)
- Tab views for: Errors, Breadcrumbs, Network, Performance, System
- JSON inspection with clipboard copy
- Event detail view for all event types
- Clear local events action

#### Safe Failure Behavior
- All integrations are isolated — SDK failures never propagate into the host application
- Existing `FlutterError.onError` handlers are always preserved (chained, not replaced)

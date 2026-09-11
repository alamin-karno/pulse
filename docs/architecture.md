# Pulse Architecture

This document describes the current implemented architecture (Phases 0–8). For what's
deferred (cloud, dashboard, feature flags), see [ROADMAP.md](ROADMAP.md).

## Package dependency graph

```
pulse_dio  ──┐
             ├──> pulse_dev   (pure Dart: events, pipeline, interfaces)
pulse_http ──┘          ▲
                        │
pulse_dev_flutter ──────┘  (Flutter: public API, error capture, inspector UI)
```

`pulse_dev` has no dependency on Flutter, `http`, or `dio`. `pulse_http` and `pulse_dio`
depend only on `pulse_dev` plus their respective HTTP client package — neither depends on
Flutter, so both work in pure-Dart (CLI/server) contexts too.

## Event pipeline

Every event — error, exception, breadcrumb, custom, network, transaction — flows through
the same mandatory pipeline before it can leave the process:

```
Capture ──> EventProcessor(s) ──> SanitizingProcessor ──> PulseTransport
```

- **Capture**: an integration point (`FlutterError.onError`, `runZonedGuarded`,
  `PulseHttpClient`, `PulseDioInterceptor`, or a manual `Pulse.captureException` /
  `Pulse.track` call) constructs a `PulseEvent` subclass.
- **EventProcessor**: user-supplied processors (`PulseConfig.processors`) may enrich or
  drop (`return null`) an event. Order is preserved.
- **SanitizingProcessor**: always runs last, unconditionally. Recursively redacts known
  sensitive keys (`password`, `token`, `authorization`, `api_key`, etc.) from event
  payloads, headers, and breadcrumb data. This stage cannot be disabled or bypassed —
  see [Privacy](#privacy) below.
- **PulseTransport**: the only place bytes leave the SDK. `PulseConfig.transport`
  defaults to a no-op/local implementation; real transport is entirely the
  developer's choice (self-hosted, third-party, or Pulse Cloud once it exists).

Every `PulseEvent` is immutable, carries a unique id, a timestamp, an SDK/app/environment
context, and serializes deterministically via `toJson()`.

## Offline queueing

`EventQueue` sits between the pipeline and the transport so that transport failures
(offline, backend down) don't drop events. The current implementation
(`InMemoryPulseStorage`) is **in-memory only** — it survives transient network failures
within a process lifetime but does **not** survive an app restart/kill. Persistent
(disk-backed) storage is an open item; see ROADMAP.md.

## Privacy

Sanitization is architecturally mandatory, not a configuration toggle:

- Default redaction covers common secret-shaped keys out of the box.
- `PulseSanitizationConfig.additionalRedactedKeys` lets consumers extend the list.
- A fully custom `PulseSanitizer` can be supplied, but every event — custom sanitizer or
  not — still passes through the pipeline's sanitizing stage before transport.
- The SDK never collects PII by default (no device identifiers, no user-entered values)
  unless the developer explicitly puts them into a breadcrumb/custom event payload.

## Network intelligence

`PulseNetworkObserver` (in `pulse_dev`) is transport-agnostic; `pulse_http` and
`pulse_dio` are thin adapters that call `observer.capture(...)` with method, URL,
duration, status, sizes, and error category. Headers/bodies are only captured when the
adapter explicitly passes them, and are still subject to sanitization + the
`PulseNetworkConfig` redaction options (`captureHeaders`, `captureBody`,
`redactQueryParameters`).

## Performance

`PulseTransaction` / spans are a manual instrumentation API (`Pulse.startTransaction`),
sampled via `PulsePerformanceConfig.sampleRate`. There is no automatic screen-render or
cold-start timing yet (open item, see ROADMAP.md).

## Debug Inspector

`pulse_dev_flutter`'s `PulseInspector` is a development-time overlay (wrapped via
`MaterialApp.builder`) that reads events already flowing through the local pipeline —
it does not talk to any backend, works fully offline, and is meant to disable itself
outside debug/profile builds when `enabled` is not explicitly forced.

## Failure isolation

The SDK is designed so an internal Pulse failure (a bad processor, a throwing
transport) is caught and logged through `PulseLogger`/`NoOpLogger`, never rethrown into
the host app's code path.

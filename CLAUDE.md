# Pulse — Project Instructions

Pulse is an open-source **Developer Intelligence SDK for Flutter/Dart** (error capture,
breadcrumbs, network intelligence, performance spans, offline queueing, an in-app debug
inspector). It is infrastructure, not a demo package — treat every change as something
thousands of downstream apps may eventually depend on.

Full narrative spec (product philosophy, phase-by-phase build order, cloud/dashboard
vision) lives only in prior planning conversations. This file plus `docs/architecture.md`
and `docs/ROADMAP.md` are the durable, up-to-date source of truth — prefer them over
memory of any past conversation.

## Current state (keep this section accurate — update it when phases/packages change)

- **Monorepo**, managed with **melos** (`melos.yaml`), 4 published packages + 1 example app.
- **Phases 0–8 are implemented** (architecture → foundation → event system → error
  capture → privacy/sanitization → network intelligence → performance → offline queue →
  debug inspector). See `docs/ROADMAP.md` for the full phase list and what's genuinely
  done vs. still open.
- **Cloud/backend (ingestion API, dashboard, error grouping, app health, feature flags)
  is intentionally NOT started.** Do not begin cloud work unless the user explicitly asks
  — see `docs/ROADMAP.md` for why and for the trigger conditions.

## Packages

| Package                      | Type        | Responsibility                                                                                                                                       |
|------------------------------|-------------|------------------------------------------------------------------------------------------------------------------------------------------------------|
| `packages/pulse_dev`         | Pure Dart   | Event models, pipeline, sanitization, transport/storage interfaces, breadcrumbs, performance primitives. No Flutter dependency — must stay that way. |
| `packages/pulse_dev_flutter` | Flutter     | Public `Pulse` API, `FlutterError.onError` + `runZonedGuarded` integration, Flutter context collection, the Debug Inspector overlay.                 |
| `packages/pulse_http`        | Dart        | `PulseHttpClient` — `package:http` wrapper that reports `NetworkEvent`s.                                                                             |
| `packages/pulse_dio`         | Dart        | `PulseDioInterceptor` — `package:dio` interceptor that reports `NetworkEvent`s.                                                                      |
| `examples/pulse_example`     | Flutter app | Reference app exercising all 4 packages. Not published.                                                                                              |

## Non-negotiable architecture rules

- **Vendor-neutral transport.** The SDK must never require Pulse's own backend.
  `PulseTransport` is the only integration point; a no-op/local transport must always work.
- **Sanitization is mandatory, not optional.** Every event passes through the sanitizer
  before reaching transport. Never add a code path that bypasses it.
- **The SDK must never crash or destabilize the host app.** Internal SDK failures are
  swallowed/logged, never rethrown into user code.
- **`pulse_dev` stays Flutter-free.** Platform/UI concerns belong in `pulse_dev_flutter`
  (or a future platform package) behind an interface defined in `pulse_dev`.
- **No `dart:io` in Flutter-facing code paths that must run on Web.** Use
  `package:flutter/foundation.dart` (`kIsWeb`, `defaultTargetPlatform`) instead of
  `dart:io Platform` for anything reachable when compiling for web. If you genuinely
  need a `dart:io`-only API, isolate it behind a conditional import/export (see
  `packages/pulse_dev_flutter/lib/src/context/os_version.dart` for the pattern).
- **No premature cloud coupling.** Don't add HTTP calls to a Pulse-owned backend, API
  keys, or dashboard concepts into the SDK packages while cloud is unstarted.
- **Minimal, deliberate public API.** Don't expose internal pipeline/processor classes
  through a package's top-level export unless a consumer genuinely needs them.
- **Semantic versioning across independently-versioned packages.** A public API change
  in `pulse_dev` that isn't backward compatible requires a major bump and a compatible
  constraint bump in every package that depends on it.

## Phase-gated workflow

Follow the phase discipline this project was built with — don't collapse it:

1. Propose the change/architecture for the phase or feature.
2. Implement only that scope.
3. Run the full check suite (below).
4. Update `CHANGELOG.md` (root + affected packages) and relevant `README.md` files.
5. Report what changed and what's still open. **Do not silently cascade into the next
   phase or an unrelated package.**

For any new SDK feature, new package, or pub.dev-readiness work, use the
`pulse-sdk-development` skill — it encodes the full checklist (public API rules, event
model rules, docs/example/pubspec requirements) so this doesn't have to be re-derived
each session.

## Required checks before considering work done

```bash
melos run format:check
melos run analyze
melos run analyze:flutter
melos run test
melos run test:flutter
```

Before tagging/publishing any package, also run per-package:

```bash
dart pub publish --dry-run
```

Never publish to pub.dev without the user's explicit go-ahead — publishing is
effectively permanent (packages can't be meaningfully unpublished once depended on).

## Where things live

- `docs/architecture.md` — event pipeline, package dependency graph, transport/storage
  abstractions.
- `docs/ROADMAP.md` — phase-by-phase status (0–8 done, 9+ deferred/cloud), and the
  open-items list for the current release.
- `.agents/AGENTS.md` — short pointer file for non-Claude agent tools; keep it in sync
  with this file's workflow rules, don't fork the content.

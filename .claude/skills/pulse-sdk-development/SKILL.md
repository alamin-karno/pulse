---
name: pulse-sdk-development
description: Use when implementing a new Pulse SDK feature/phase, adding or modifying a package under packages/, preparing a package for pub.dev publishing, or making an architecture decision in the Pulse monorepo (github.com/alamin-karno/pulse). Encodes the phase-gated build process, public API rules, and the pub.dev-readiness checklist so they don't have to be re-derived each session.
---

# Pulse SDK Development

Read `CLAUDE.md` and `docs/architecture.md` first if you haven't already this session —
this skill assumes that context and only adds the procedural checklist.

## 1. Phase-gated implementation

Pulse was built (and must continue to be built) as a sequence of scoped phases, not a
single sprawling change:

1. State the scope of the change in one or two sentences before touching code.
2. Implement only that scope — resist adding adjacent features "while you're in there."
3. Run the full check suite (below) before calling it done.
4. Update the `CHANGELOG.md` of every package you touched, plus its `README.md` if the
   public API or usage changed.
5. Stop and report. Do not automatically continue into the next phase, another package,
   or cloud-side work.

If a request is ambiguous about scope ("add feature flags", "add a dashboard"), assume
it means client-side only unless the user says otherwise — cloud/backend work is
explicitly deferred (see `docs/ROADMAP.md`) and requires an explicit go-ahead.

## 2. Public API rules

- The public API surface of `pulse_dev_flutter` is the `Pulse` class plus its config
  types (`PulseConfig`, `PulseNetworkConfig`, `PulsePerformanceConfig`,
  `PulseSanitizationConfig`). Keep new capabilities reachable through `Pulse.*` rather
  than requiring consumers to import internal pipeline/processor classes.
- Every new capability needs an interface in `pulse_dev` if it's something a consumer
  might reasonably want to replace (transport, storage, sanitizer, logger). Don't hard-code a 
  concrete implementation where an interface is the pattern elsewhere in the repo.
- Breaking an existing public API requires a major version bump in that package and a
  compatible constraint bump in every dependent package (`pulse_dev_flutter`,
  `pulse_http`, `pulse_dio` all pin `pulse_dev: ^0.x.0`).
- `pulse_dev` must never gain a Flutter, `http`, or `dio` dependency. If a feature needs
  one of those, it belongs in `pulse_dev_flutter`, `pulse_http`, or `pulse_dio` behind an
  interface defined in `pulse_dev`.

## 3. Event model rules

- New event types extend `PulseEvent`, are immutable, and carry an id/timestamp/type at
  minimum (see `packages/pulse_dev/lib/src/events/`).
- `toJson()` must be deterministic and side-effect-free; add a serialization test.
- Any new field that could plausibly contain a secret or PII must be sanitizable — run it
  through the existing sanitization path, don't add a new bypass.

## 4. New-package / pub.dev-readiness checklist

Run this whenever creating a new package under `packages/`, or when asked to fix pub.dev
score for an existing one. Each item maps to a real pub.dev scoring category — verify at
`https://pub.dev/packages/<name>/score` after publishing.

- [ ] `description:` in `pubspec.yaml` is **60–180 characters** (not longer — pub.dev
      docks points either side of that range). Count it; don't eyeball it.
- [ ] `repository`, `homepage`, `issue_tracker`, `funding` are set and point at the real
      repo (copy the pattern from an existing package's `pubspec.yaml`).
- [ ] `topics:` has up to 5 relevant, real pub.dev topics.
- [ ] The package has its **own** `example/` directory (a single `example/main.dart` or
      `example/lib/main.dart` showing the package's primary API in isolation). The
      shared `examples/pulse_example` app does not count toward an individual package's
      pub.dev score — each package needs its own.
- [ ] Every public class/member has a dartdoc comment. Aim for 100%, not just above the
      scoring threshold — check with `dart doc --validate-links` or by reading
      `dart analyze` output for missing-docs style lints if enabled.
- [ ] `dart format .` and `dart analyze --fatal-infos .` (or `flutter analyze
      --fatal-infos` for Flutter packages) are clean — zero warnings, zero infos.
- [ ] `CHANGELOG.md`, `README.md`, `LICENSE` exist in the package directory (not just at
      the repo root — pub.dev scores the package's own copies).
- [ ] Dependencies use current major versions; no unnecessary dependencies added.
- [ ] `dart pub publish --dry-run` passes from inside the package directory.
- [ ] If the package is Flutter-facing and might run on web, grep for `dart:io` importing
      `Platform` — that silently breaks web compatibility. Use
      `package:flutter/foundation.dart`'s `kIsWeb`/`defaultTargetPlatform` instead.

## 5. Required checks (same as CLAUDE.md — repeated here for a self-contained checklist)

```bash
melos run format:check
melos run analyze
melos run analyze:flutter
melos run test
melos run test:flutter
```

Then, per package being released:

```bash
cd packages/<name> && dart pub publish --dry-run
```

Never run `dart pub publish` for real without the maintainer's explicit confirmation —
publishing is effectively permanent.

# Pulse Roadmap

## Phases 0–8 — implemented (first public release)

| Phase | Scope                                                        | Status                                    |
|-------|--------------------------------------------------------------|-------------------------------------------|
| 0     | Architecture & planning                                      | Done                                      |
| 1     | Monorepo foundation (packages, CI, licensing, docs skeleton) | Done                                      |
| 2     | Event system & pipeline                                      | Done                                      |
| 3     | Error intelligence (Flutter + zone error capture)            | Done                                      |
| 4     | Privacy & sanitization engine                                | Done                                      |
| 5     | Network intelligence (`pulse_http`, `pulse_dio`)             | Done                                      |
| 6     | Performance intelligence (transactions/spans)                | Done                                      |
| 7     | Offline event queue                                          | Done, **in-memory only** (see open items) |
| 8     | Debug Inspector overlay                                      | Done                                      |

## Open items from the Phase 0–8 release (not cloud — fix these before/alongside a 1.0)

Found during a post-release audit. Fixed items are kept here (struck through) as a
record of what shipped in the pub.dev-readiness pass; only genuinely open items should
be pulled into GitHub issues.

- ~~`pulse_http`/`pulse_dio` ship a dead leftover template file~~ — **Fixed**: deleted
  `lib/src/pulse_http_base.dart` and `lib/src/pulse_dio_base.dart`.
- ~~`pulse_dev_flutter`'s `flutter_context_collector.dart` imports `dart:io Platform`,
  breaking Flutter Web~~ — **Fixed**: OS name now resolves via `defaultTargetPlatform`;
  OS version resolution moved behind a conditional import
  (`lib/src/context/os_version.dart`) so `dart:io` is never reachable on web.
- ~~No package has its own `example/` directory~~ — **Fixed**: each of the 4 packages
  now has `example/example.dart` (or `example/lib/main.dart` for
  `pulse_dev_flutter`), independent of the shared `examples/pulse_example` app.
- ~~`pubspec.yaml` `description:` exceeds pub.dev's 180-character guidance~~ —
  **Fixed** in `pulse_dev`, `pulse_dev_flutter`, and `pulse_http`.
- ~~`docs/architecture.md` was linked from the root README before it existed~~ —
  **Fixed**.
- ~~No `.github/ISSUE_TEMPLATE/`, PR template, or `.github/FUNDING.yml`~~ — **Fixed**.
- ~~A few public API members were undocumented~~ — **Fixed**: `PulseTransaction.create`,
  `PulseInspector`'s constructor, and `PulseDioInterceptor`'s constructor/overrides now
  have dartdoc.
- **Still open**: persistent (disk-backed) offline storage — the queue is in-memory
  only and does not survive an app restart. Needs a `PulseStorage` implementation
  backed by a file or lightweight embedded database; no dependency has been chosen yet.

## Phases 9+ — deferred (cloud, dashboard, ecosystem)

**Not started. Do not begin without an explicit go-ahead from the maintainer**, even if
a request seems to imply it (e.g. "add analytics", "add a dashboard"). Ask first.

Deferred scope, roughly in the order it would make sense to build:

1. **Ingestion API** — a real HTTP transport implementation + backend to receive events
   (separate repo/service, not inside the SDK packages).
2. **Dashboard** — project overview, error grouping/fingerprinting, event timelines.
3. **App Health score** — aggregate crash-free rate, API success rate, latency,
   startup time into a single trend/score.
4. **Feature flags / remote config** — `Pulse.feature(...)`, rollout percentages,
   kill switches.
5. **Self-hosting story** — docker-compose or similar for the ingestion API + dashboard.
6. **Sponsorship program** — sponsor tiers, funding page, README/website recognition.
   `pubspec.yaml` `funding:` already points at a GitHub Sponsors URL; nothing beyond
   that has been built.

### Why deferred

The SDK itself (Phases 0–8) is the product's credibility — a Flutter/Dart developer
intelligence SDK with hundreds of thousands of pub.dev packages to compete against only
earns adoption if the client-side library is excellent, dependency-light, and trustworthy
on its own, with zero cloud lock-in. Building ingestion/dashboard/billing before the SDK
has real users risks months of infrastructure work validated by nobody. Revisit this
list once: the 4 published packages have real external adoption (issues, stars,
non-maintainer PRs), or a specific user/customer need forces the question.

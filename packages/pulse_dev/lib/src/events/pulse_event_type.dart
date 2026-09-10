/// Categorizes the type of a [PulseEvent].
///
/// Used for routing, filtering, and display in downstream consumers.
///
/// > **Note for exhaustive switch users**: New event types will be added in
/// > future minor versions of `pulse_dev`. If you write exhaustive `switch`
/// > statements on [PulseEventType], add a `default` case or the wildcard `_`
/// > to avoid compilation errors after upgrades.
enum PulseEventType {
  /// An unhandled Dart [Error] (e.g., `AssertionError`, `RangeError`).
  ///
  /// Errors are typically programming mistakes that should not be caught in
  /// production. Captured via [Pulse.captureError].
  error,

  /// A caught or uncaught [Exception] or arbitrary thrown [Object].
  ///
  /// Captured via [Pulse.captureException].
  exception,

  /// A manual breadcrumb added via [Pulse.addBreadcrumb].
  ///
  /// Breadcrumbs record what happened before an error or exception to
  /// provide context during debugging.
  breadcrumb,

  /// A custom analytics-style event captured via [Pulse.track].
  custom,

  /// A network request/response captured via [PulseNetworkObserver].
  network,
}

/// Standard platform identifier strings used in [PulseEvent.platform].
///
/// Use these constants when constructing events manually to ensure consistent
/// platform values across the SDK ecosystem.
abstract final class PulsePlatform {
  /// Android mobile platform.
  static const String android = 'android';

  /// Apple iOS / iPadOS platform.
  static const String iOS = 'ios';

  /// Browser / Flutter Web platform.
  static const String web = 'web';

  /// Apple macOS desktop platform.
  static const String macOS = 'macos';

  /// Microsoft Windows desktop platform.
  static const String windows = 'windows';

  /// Linux desktop platform.
  static const String linux = 'linux';

  /// Pure Dart (non-Flutter) environment.
  static const String dart = 'dart';

  /// Platform could not be determined.
  static const String unknown = 'unknown';
}

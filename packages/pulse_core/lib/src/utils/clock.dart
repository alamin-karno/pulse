import 'package:meta/meta.dart';

/// An abstraction over time that allows deterministic testing.
///
/// Inject a [FakeClock] in tests to produce predictable timestamps:
///
/// ```dart
/// final clock = FakeClock(DateTime.utc(2024, 1, 1));
/// final event = ErrorEvent(..., timestamp: clock.now());
/// ```
///
/// Use [SystemClock] in production.
abstract interface class Clock {
  /// Returns the current time in UTC.
  DateTime now();
}

/// Production [Clock] implementation backed by [DateTime.now].
///
/// All returned timestamps are normalized to UTC.
@immutable
final class SystemClock implements Clock {
  /// Creates a [SystemClock].
  const SystemClock();

  @override
  DateTime now() => DateTime.now().toUtc();
}

/// A [Clock] with a fixed time, for use in tests.
///
/// ```dart
/// final clock = FakeClock(DateTime.utc(2024, 6, 15, 12, 0, 0));
/// expect(clock.now(), DateTime.utc(2024, 6, 15, 12, 0, 0));
/// ```
@visibleForTesting
@immutable
final class FakeClock implements Clock {
  /// The fixed time this clock always returns.
  final DateTime fixedTime;

  /// Creates a [FakeClock] that always returns [fixedTime].
  ///
  /// [fixedTime] is converted to UTC if it is not already.
  const FakeClock(this.fixedTime);

  @override
  DateTime now() => fixedTime.toUtc();
}

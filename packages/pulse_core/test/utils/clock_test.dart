import 'package:pulse_core/pulse_core.dart';
import 'package:test/test.dart';

void main() {
  group('SystemClock', () {
    test('now() returns a UTC datetime', () {
      final clock = const SystemClock();
      final now = clock.now();
      expect(now.isUtc, isTrue);
    });

    test('now() returns a time close to DateTime.now()', () {
      final clock = const SystemClock();
      final before = DateTime.now().toUtc();
      final result = clock.now();
      final after = DateTime.now().toUtc();

      expect(
          result.isAfter(before.subtract(const Duration(seconds: 1))), isTrue);
      expect(result.isBefore(after.add(const Duration(seconds: 1))), isTrue);
    });
  });

  group('FakeClock', () {
    test('always returns the fixed time', () {
      final fixed = DateTime.utc(2024, 6, 15, 12, 0, 0);
      final clock = FakeClock(fixed);

      expect(clock.now(), equals(fixed));
      expect(clock.now(), equals(fixed)); // deterministic
    });

    test('converts non-UTC time to UTC', () {
      final localTime = DateTime(2024, 6, 15, 12, 0, 0);
      final clock = FakeClock(localTime);

      expect(clock.now().isUtc, isTrue);
    });

    test('two calls return equal datetimes', () {
      final clock = FakeClock(DateTime.utc(2024, 1, 1));
      expect(clock.now(), equals(clock.now()));
    });
  });
}

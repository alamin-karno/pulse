import 'package:pulse_dev/pulse_dev.dart';
import 'package:test/test.dart';

void main() {
  group('PulseConfig — defaults', () {
    test('environment defaults to production', () {
      const config = PulseConfig(dsn: 'https://key@host.com/1');
      expect(config.environment, equals('production'));
    });

    test('release is null by default', () {
      const config = PulseConfig(dsn: 'https://key@host.com/1');
      expect(config.release, isNull);
    });

    test('debug defaults to false', () {
      const config = PulseConfig(dsn: 'https://key@host.com/1');
      expect(config.debug, isFalse);
    });

    test('enabled defaults to true', () {
      const config = PulseConfig(dsn: 'https://key@host.com/1');
      expect(config.enabled, isTrue);
    });

    test('maxBreadcrumbs defaults to 100', () {
      const config = PulseConfig(dsn: 'https://key@host.com/1');
      expect(config.maxBreadcrumbs, equals(100));
    });

    test('captureUnhandledErrors defaults to true', () {
      const config = PulseConfig(dsn: 'https://key@host.com/1');
      expect(config.captureUnhandledErrors, isTrue);
    });

    test('captureFlutterErrors defaults to true', () {
      const config = PulseConfig(dsn: 'https://key@host.com/1');
      expect(config.captureFlutterErrors, isTrue);
    });

    test('processors defaults to empty list', () {
      const config = PulseConfig(dsn: 'https://key@host.com/1');
      expect(config.processors, isEmpty);
    });

    test('transport defaults to NoOpTransport', () {
      const config = PulseConfig(dsn: 'https://key@host.com/1');
      expect(config.transport, isA<NoOpTransport>());
    });

    test('sanitizer defaults to DefaultSanitizer', () {
      const config = PulseConfig(dsn: 'https://key@host.com/1');
      expect(config.sanitizer, isA<DefaultSanitizer>());
    });

    test('logger defaults to NoOpLogger', () {
      const config = PulseConfig(dsn: 'https://key@host.com/1');
      expect(config.logger, isA<NoOpLogger>());
    });
  });

  group('PulseConfig — custom values', () {
    test('accepts custom environment', () {
      const config = PulseConfig(
        dsn: 'https://key@host.com/1',
        environment: 'staging',
      );
      expect(config.environment, equals('staging'));
    });

    test('accepts custom release', () {
      const config =
          PulseConfig(dsn: 'https://key@host.com/1', release: '2.0.0+42');
      expect(config.release, equals('2.0.0+42'));
    });

    test('accepts maxBreadcrumbs of 0', () {
      const config =
          PulseConfig(dsn: 'https://key@host.com/1', maxBreadcrumbs: 0);
      expect(config.maxBreadcrumbs, equals(0));
    });

    test('accepts disabled state', () {
      const config = PulseConfig(dsn: 'https://key@host.com/1', enabled: false);
      expect(config.enabled, isFalse);
    });
  });

  group('PulseConfig — assertions', () {
    test('throws AssertionError for negative maxBreadcrumbs', () {
      expect(
        () => PulseConfig(dsn: 'https://key@host.com/1', maxBreadcrumbs: -1),
        throwsA(isA<AssertionError>()),
      );
    });
  });

  group('PulseConfig — const constructibility', () {
    test('can be constructed as const', () {
      const config = PulseConfig(dsn: 'https://key@host.com/1');
      expect(config, isNotNull);
    });
  });
}

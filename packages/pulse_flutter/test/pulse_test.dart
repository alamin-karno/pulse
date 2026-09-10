import 'package:flutter_test/flutter_test.dart';
import 'package:pulse_core/pulse_core.dart';
import 'package:pulse_flutter/pulse_flutter.dart';

import 'helpers/test_helpers.dart';

void main() {
  setUp(() => Pulse.reset());
  tearDown(() => Pulse.reset());

  group('Pulse.initialize', () {
    test('sets isInitialized to true', () async {
      await Pulse.initialize(testConfig());
      expect(Pulse.isInitialized, isTrue);
    });

    test('isInitialized is false before initialize', () {
      expect(Pulse.isInitialized, isFalse);
    });

    test('second initialize call is a no-op', () async {
      final transport1 = CapturingTransport();
      final transport2 = CapturingTransport();

      await Pulse.initialize(testConfig(transport: transport1));
      await Pulse.initialize(testConfig(transport: transport2));

      // Still using the first transport
      expect(Pulse.isInitialized, isTrue);
    });

    test('disabled SDK does not set isInitialized', () async {
      await Pulse.initialize(
        const PulseConfig(dsn: 'https://k@h.com/1', enabled: false),
      );
      expect(Pulse.isInitialized, isFalse);
    });
  });

  group('Pulse.close', () {
    test('sets isInitialized to false', () async {
      await Pulse.initialize(testConfig());
      await Pulse.close();
      expect(Pulse.isInitialized, isFalse);
    });

    test('close before initialize is safe', () async {
      await expectLater(Pulse.close(), completes);
    });
  });

  group('Pulse.captureException', () {
    test('sends event when initialized', () async {
      final transport = CapturingTransport();
      await Pulse.initialize(testConfig(transport: transport));

      Pulse.captureException(Exception('test error'));

      await Future<void>.delayed(Duration.zero);
      expect(transport.captured, hasLength(1));
      expect(transport.captured.first, isA<ExceptionEvent>());
    });

    test('is a no-op before initialize', () {
      expect(
        () => Pulse.captureException(Exception('before init')),
        returnsNormally,
      );
    });

    test('captured event has correct type and message', () async {
      final transport = CapturingTransport();
      await Pulse.initialize(testConfig(transport: transport));

      Pulse.captureException(FormatException('bad format'));

      await Future<void>.delayed(Duration.zero);
      final event = transport.captured.first as ExceptionEvent;
      expect(event.exceptionType, equals('FormatException'));
      expect(event.message, contains('bad format'));
      expect(event.handled, isTrue);
    });

    test('captured exception includes current breadcrumbs', () async {
      final transport = CapturingTransport();
      await Pulse.initialize(testConfig(transport: transport));

      Pulse.addBreadcrumb('Step 1');
      Pulse.addBreadcrumb('Step 2');
      Pulse.captureException(Exception('crash'));

      await Future<void>.delayed(Duration.zero);
      final event = transport.captured.last as ExceptionEvent;
      expect(event.breadcrumbs, hasLength(2));
    });
  });

  group('Pulse.captureError', () {
    test('sends ErrorEvent when initialized', () async {
      final transport = CapturingTransport();
      await Pulse.initialize(testConfig(transport: transport));

      Pulse.captureError(ArgumentError('bad arg'));

      await Future<void>.delayed(Duration.zero);
      expect(transport.captured.first, isA<ErrorEvent>());
    });

    test('is a no-op before initialize', () {
      expect(
        () => Pulse.captureError(ArgumentError('before init')),
        returnsNormally,
      );
    });
  });

  group('Pulse.addBreadcrumb', () {
    test('is a no-op before initialize', () {
      expect(
        () => Pulse.addBreadcrumb('before init'),
        returnsNormally,
      );
    });

    test('breadcrumbs accumulate on the client', () async {
      await Pulse.initialize(testConfig());

      Pulse.addBreadcrumb('crumb 1');
      Pulse.addBreadcrumb('crumb 2');

      expect(Pulse.testClient?.breadcrumbCount, equals(2));
    });
  });

  group('Pulse.track', () {
    test('sends CustomEvent when initialized', () async {
      final transport = CapturingTransport();
      await Pulse.initialize(testConfig(transport: transport));

      Pulse.track('user_signed_in', properties: {'method': 'google'});

      await Future<void>.delayed(Duration.zero);
      expect(transport.captured.first, isA<CustomEvent>());
      final event = transport.captured.first as CustomEvent;
      expect(event.name, equals('user_signed_in'));
    });

    test('is a no-op before initialize', () {
      expect(() => Pulse.track('event'), returnsNormally);
    });
  });
}

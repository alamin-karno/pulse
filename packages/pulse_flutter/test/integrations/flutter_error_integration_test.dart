import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse_core/pulse_core.dart';
import 'package:pulse_flutter/src/integrations/flutter_error_integration.dart';
import 'package:pulse_flutter/src/pulse_client.dart';
import 'package:pulse_flutter/src/pulse.dart';

import '../helpers/test_helpers.dart';

void main() {
  setUp(() => Pulse.reset());
  tearDown(() => Pulse.reset());

  group('FlutterErrorIntegration — install/uninstall', () {
    test('install replaces FlutterError.onError', () {
      final transport = CapturingTransport();
      final context = const PulseContext(osName: 'TestOS');
      final client = PulseClient(
        config: testConfig(
          transport: transport,
          captureFlutterErrors: false,
        ),
        context: context,
      );

      final originalHandler = FlutterError.onError;
      final integration = FlutterErrorIntegration(client);
      integration.install();

      expect(FlutterError.onError, isNot(same(originalHandler)));

      integration.uninstall();
      expect(FlutterError.onError, same(originalHandler));
    });

    test('install is idempotent', () {
      final transport = CapturingTransport();
      final client = PulseClient(
        config: testConfig(transport: transport),
        context: const PulseContext(),
      );

      final integration = FlutterErrorIntegration(client);
      integration.install();
      final handlerAfterFirstInstall = FlutterError.onError;
      integration.install(); // second install — should be no-op

      expect(FlutterError.onError, same(handlerAfterFirstInstall));
      integration.uninstall();
    });

    test('uninstall is idempotent', () {
      final client = PulseClient(
        config: testConfig(),
        context: const PulseContext(),
      );
      final integration = FlutterErrorIntegration(client);
      integration.install();
      integration.uninstall();

      expect(
        () => integration.uninstall(),
        returnsNormally,
      );
    });
  });

  group('FlutterErrorIntegration — error capture', () {
    test('forwards Flutter errors to the client as unhandled exceptions',
        () async {
      final transport = CapturingTransport();
      final client = PulseClient(
        config: testConfig(transport: transport),
        context: const PulseContext(),
      );

      final integration = FlutterErrorIntegration(client);
      integration.install();

      final details = FlutterErrorDetails(
        exception: Exception('widget error'),
        stack: StackTrace.current,
      );

      FlutterError.reportError(details);
      await Future<void>.delayed(Duration.zero);

      final captured = transport.captured.whereType<ExceptionEvent>().toList();
      expect(captured, isNotEmpty);
      expect(captured.first.handled, isFalse);
      expect(captured.first.message, contains('widget error'));

      integration.uninstall();
    });

    test('calls previous handler in addition to Pulse capture', () async {
      bool previousHandlerCalled = false;
      final savedHandler = FlutterError.onError;
      FlutterError.onError = (_) => previousHandlerCalled = true;

      final client = PulseClient(
        config: testConfig(),
        context: const PulseContext(),
      );

      final integration = FlutterErrorIntegration(client);
      integration.install();

      FlutterError.reportError(
        FlutterErrorDetails(exception: Exception('test')),
      );

      expect(previousHandlerCalled, isTrue);

      integration.uninstall();
      FlutterError.onError = savedHandler;
    });
  });
}

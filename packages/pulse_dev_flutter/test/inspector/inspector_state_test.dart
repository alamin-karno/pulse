import 'package:flutter_test/flutter_test.dart';
import 'package:pulse_dev/pulse_dev.dart';
import 'package:pulse_dev_flutter/src/inspector/inspector_state.dart';

void main() {
  group('InspectorState', () {
    late InspectorState state;
    late PulseContext dummyContext;
    late DateTime now;

    setUp(() {
      state = InspectorState.instance;
      state.clear();
      now = DateTime.now();
      dummyContext = const PulseContext(
        appVersion: '1.0.0',
        osName: 'test',
        locale: 'en',
      );
    });

    test('maintains separate bounded queues', () {
      state.start();

      for (int i = 0; i < 150; i++) {
        state.onEvent(
          ErrorEvent(
            id: 'e$i',
            timestamp: now,
            sdkVersion: '1',
            appVersion: '1',
            environment: 'test',
            platform: 'test',
            context: dummyContext,
            errorType: 'TestError',
            message: 'Msg $i',
            breadcrumbs: const [],
          ),
        );
      }

      for (int i = 0; i < 120; i++) {
        state.onEvent(
          NetworkEvent(
            id: 'n$i',
            timestamp: now,
            sdkVersion: '1',
            appVersion: '1',
            environment: 'test',
            platform: 'test',
            context: dummyContext,
            url: 'https://example.com/$i',
            method: 'GET',
            success: true,
            duration: const Duration(milliseconds: 10),
          ),
        );
      }

      // Max capacity is 100
      expect(state.errors.length, 100);
      expect(state.networkEvents.length, 100);

      // Newest first
      expect(state.errors.first.id, 'e149');
      expect(state.networkEvents.first.id, 'n119');

      state.stop();
    });

    test('clear() resets all lists', () {
      state.start();

      state.onEvent(
        ErrorEvent(
          id: '1',
          timestamp: now,
          sdkVersion: '1',
          appVersion: '1',
          environment: 'test',
          platform: 'test',
          context: dummyContext,
          errorType: 'TestError',
          message: 'Msg',
          breadcrumbs: const [],
        ),
      );

      expect(state.errors.length, 1);
      state.clear();
      expect(state.errors.length, 0);

      state.stop();
    });
  });
}

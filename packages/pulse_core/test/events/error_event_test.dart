import 'package:pulse_core/pulse_core.dart';
import 'package:test/test.dart';

import '../helpers/event_factory.dart';

void main() {
  group('ErrorEvent — construction', () {
    test('type is PulseEventType.error', () {
      final event = EventFactory.errorEvent();
      expect(event.type, equals(PulseEventType.error));
    });

    test('stores errorType and message', () {
      final event = EventFactory.errorEvent(
          errorType: 'RangeError', message: 'Bad index');
      expect(event.errorType, equals('RangeError'));
      expect(event.message, equals('Bad index'));
    });

    test('stores empty breadcrumbs by default', () {
      final event = EventFactory.errorEvent();
      expect(event.breadcrumbs, isEmpty);
    });

    test('stores provided breadcrumbs', () {
      final crumb = EventFactory.breadcrumbEvent(message: 'Before crash');
      final event = EventFactory.errorEvent(breadcrumbs: [crumb]);
      expect(event.breadcrumbs, hasLength(1));
      expect(event.breadcrumbs.first.message, equals('Before crash'));
    });

    test('stackTrace is nullable', () {
      final event = EventFactory.errorEvent(stackTrace: null);
      expect(event.stackTrace, isNull);
    });

    test('schemaVersion defaults to kPulseEventSchemaVersion', () {
      final event = EventFactory.errorEvent();
      expect(event.schemaVersion, equals(kPulseEventSchemaVersion));
    });
  });

  group('ErrorEvent — serialization', () {
    test('toJson includes all required base fields', () {
      final timestamp = DateTime.utc(2024, 6, 15, 12, 0, 0);
      final event = EventFactory.errorEvent(
        id: 'test-id',
        timestamp: timestamp,
        errorType: 'AssertionError',
        message: 'Value is null',
        appVersion: '1.0.0',
        environment: 'production',
        platform: 'android',
      );

      final json = event.toJson();

      expect(json['id'], equals('test-id'));
      expect(json['timestamp'], equals('2024-06-15T12:00:00.000Z'));
      expect(json['type'], equals('error'));
      expect(json['sdk_version'], equals(kPulseSdkVersion));
      expect(json['app_version'], equals('1.0.0'));
      expect(json['environment'], equals('production'));
      expect(json['platform'], equals('android'));
      expect(json['schema_version'], equals(kPulseEventSchemaVersion));
      expect(json['context'], isA<Map<String, dynamic>>());
    });

    test('toJson includes error_type and message', () {
      final event =
          EventFactory.errorEvent(errorType: 'TypeError', message: 'Null ref');
      final json = event.toJson();
      expect(json['error_type'], equals('TypeError'));
      expect(json['message'], equals('Null ref'));
    });

    test('toJson omits app_version when null', () {
      final event = EventFactory.errorEvent(appVersion: null);
      expect(event.toJson().containsKey('app_version'), isFalse);
    });

    test('toJson includes stack_trace when present', () {
      final trace = StackTrace.current;
      final event = EventFactory.errorEvent(stackTrace: trace);
      final json = event.toJson();
      expect(json['stack_trace'], isA<String>());
      expect((json['stack_trace'] as String).isNotEmpty, isTrue);
    });

    test('toJson omits stack_trace when null', () {
      final event = EventFactory.errorEvent(stackTrace: null);
      expect(event.toJson().containsKey('stack_trace'), isFalse);
    });

    test('toJson includes breadcrumbs array', () {
      final crumbs = [
        EventFactory.breadcrumbEvent(message: 'Step 1'),
        EventFactory.breadcrumbEvent(message: 'Step 2'),
      ];
      final event = EventFactory.errorEvent(breadcrumbs: crumbs);
      final json = event.toJson();

      expect(json['breadcrumbs'], isA<List<dynamic>>());
      expect((json['breadcrumbs'] as List<dynamic>).length, equals(2));
    });
  });

  group('ErrorEvent — equality', () {
    test('events with the same id are equal', () {
      final event1 = EventFactory.errorEvent(id: 'same-id');
      final event2 = EventFactory.errorEvent(id: 'same-id');
      expect(event1, equals(event2));
    });

    test('events with different ids are not equal', () {
      final event1 = EventFactory.errorEvent(id: 'id-1');
      final event2 = EventFactory.errorEvent(id: 'id-2');
      expect(event1, isNot(equals(event2)));
    });
  });
}

import 'package:pulse_dev/pulse_dev.dart';
import 'package:test/test.dart';

import '../helpers/event_factory.dart';

void main() {
  group('ExceptionEvent — construction', () {
    test('type is PulseEventType.exception', () {
      final event = EventFactory.exceptionEvent();
      expect(event.type, equals(PulseEventType.exception));
    });

    test('stores exceptionType and message', () {
      final event = EventFactory.exceptionEvent(
        exceptionType: 'FormatException',
        message: 'Invalid format',
      );
      expect(event.exceptionType, equals('FormatException'));
      expect(event.message, equals('Invalid format'));
    });

    test('handled defaults to true (explicitly captured)', () {
      final event = EventFactory.exceptionEvent(handled: true);
      expect(event.handled, isTrue);
    });

    test('handled can be false (unhandled, caught by integration)', () {
      final event = EventFactory.exceptionEvent(handled: false);
      expect(event.handled, isFalse);
    });

    test('stores breadcrumbs', () {
      final crumbs = [
        EventFactory.breadcrumbEvent(),
        EventFactory.breadcrumbEvent(),
      ];
      final event = EventFactory.exceptionEvent(breadcrumbs: crumbs);
      expect(event.breadcrumbs, hasLength(2));
    });
  });

  group('ExceptionEvent — serialization', () {
    test('toJson includes type as "exception"', () {
      final event = EventFactory.exceptionEvent();
      expect(event.toJson()['type'], equals('exception'));
    });

    test('toJson includes exception_type, message, handled', () {
      final event = EventFactory.exceptionEvent(
        exceptionType: 'SocketException',
        message: 'Connection refused',
        handled: false,
      );
      final json = event.toJson();

      expect(json['exception_type'], equals('SocketException'));
      expect(json['message'], equals('Connection refused'));
      expect(json['handled'], isFalse);
    });

    test('toJson includes stack_trace string when provided', () {
      final trace = StackTrace.current;
      final event = EventFactory.exceptionEvent(stackTrace: trace);
      expect(event.toJson()['stack_trace'], isA<String>());
    });

    test('toJson omits stack_trace when null', () {
      final event = EventFactory.exceptionEvent(stackTrace: null);
      expect(event.toJson().containsKey('stack_trace'), isFalse);
    });

    test('toJson includes breadcrumbs as list', () {
      final event = EventFactory.exceptionEvent(
        breadcrumbs: [EventFactory.breadcrumbEvent()],
      );
      final breadcrumbs = event.toJson()['breadcrumbs'] as List<dynamic>;
      expect(breadcrumbs, hasLength(1));
    });
  });

  group('ExceptionEvent — equality', () {
    test('events with same id are equal', () {
      final e1 = EventFactory.exceptionEvent(id: 'eq-id');
      final e2 = EventFactory.exceptionEvent(id: 'eq-id');
      expect(e1, equals(e2));
    });

    test('events with different ids are not equal', () {
      final e1 = EventFactory.exceptionEvent(id: 'a');
      final e2 = EventFactory.exceptionEvent(id: 'b');
      expect(e1, isNot(equals(e2)));
    });
  });
}

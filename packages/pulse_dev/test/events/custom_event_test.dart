import 'package:pulse_dev/pulse_dev.dart';
import 'package:test/test.dart';

import '../helpers/event_factory.dart';

void main() {
  group('CustomEvent — construction', () {
    test('type is PulseEventType.custom', () {
      final event = EventFactory.customEvent();
      expect(event.type, equals(PulseEventType.custom));
    });

    test('stores event name', () {
      final event = EventFactory.customEvent(name: 'payment_initiated');
      expect(event.name, equals('payment_initiated'));
    });

    test('properties default to empty map', () {
      final event = EventFactory.customEvent();
      expect(event.properties, isEmpty);
    });

    test('stores provided properties', () {
      final event = EventFactory.customEvent(properties: {
        'amount': 99.99,
        'currency': 'USD',
      });
      expect(event.properties['amount'], equals(99.99));
      expect(event.properties['currency'], equals('USD'));
    });
  });

  group('CustomEvent — serialization', () {
    test('toJson includes type as "custom"', () {
      final event = EventFactory.customEvent();
      expect(event.toJson()['type'], equals('custom'));
    });

    test('toJson includes event name', () {
      final event = EventFactory.customEvent(name: 'checkout_completed');
      expect(event.toJson()['name'], equals('checkout_completed'));
    });

    test('toJson includes properties when non-empty', () {
      final event = EventFactory.customEvent(properties: {'key': 'value'});
      expect(event.toJson()['properties'], isA<Map<String, dynamic>>());
    });

    test('toJson omits properties when empty', () {
      final event = EventFactory.customEvent(properties: {});
      expect(event.toJson().containsKey('properties'), isFalse);
    });

    test('toJson round-trips all base fields', () {
      final timestamp = DateTime.utc(2024, 1, 1);
      final event = EventFactory.customEvent(
        id: 'custom-id',
        timestamp: timestamp,
        name: 'test_event',
        appVersion: '2.0.0',
        environment: 'staging',
        platform: 'ios',
      );
      final json = event.toJson();

      expect(json['id'], equals('custom-id'));
      expect(json['timestamp'], equals('2024-01-01T00:00:00.000Z'));
      expect(json['type'], equals('custom'));
      expect(json['environment'], equals('staging'));
      expect(json['platform'], equals('ios'));
      expect(json['app_version'], equals('2.0.0'));
    });
  });

  group('CustomEvent — copyWithSanitizedProperties', () {
    test('returns event with replaced properties', () {
      final event = EventFactory.customEvent(
        properties: {'password': 'secret', 'screen': 'Login'},
      );
      final copy = event.copyWithSanitizedProperties({
        'password': '[REDACTED]',
        'screen': 'Login',
      });

      expect(copy.properties['password'], equals('[REDACTED]'));
      expect(copy.properties['screen'], equals('Login'));
      expect(copy.name, equals(event.name));
      expect(copy.id, equals(event.id));
    });

    test('original properties are unchanged after copy', () {
      final event =
          EventFactory.customEvent(properties: {'password': 'secret'});
      event.copyWithSanitizedProperties({'password': '[REDACTED]'});

      expect(event.properties['password'], equals('secret'));
    });
  });

  group('CustomEvent — equality', () {
    test('events with same id and name are equal', () {
      final e1 = EventFactory.customEvent(id: 'my-id', name: 'event_a');
      final e2 = EventFactory.customEvent(id: 'my-id', name: 'event_a');
      expect(e1, equals(e2));
    });

    test('events with different ids are not equal', () {
      final e1 = EventFactory.customEvent(id: 'a');
      final e2 = EventFactory.customEvent(id: 'b');
      expect(e1, isNot(equals(e2)));
    });
  });
}

import 'package:pulse_dev/pulse_dev.dart';
import 'package:test/test.dart';

import '../helpers/event_factory.dart';

void main() {
  group('BreadcrumbEvent — construction', () {
    test('type is PulseEventType.breadcrumb', () {
      final event = EventFactory.breadcrumbEvent();
      expect(event.type, equals(PulseEventType.breadcrumb));
    });

    test('stores message and category', () {
      final event = EventFactory.breadcrumbEvent(
        message: 'User tapped button',
        category: 'ui.action',
      );
      expect(event.message, equals('User tapped button'));
      expect(event.category, equals('ui.action'));
    });

    test('level defaults to info', () {
      final event = EventFactory.breadcrumbEvent();
      expect(event.level, equals(BreadcrumbLevel.info));
    });

    test('level can be set to any BreadcrumbLevel', () {
      for (final level in BreadcrumbLevel.values) {
        final event = EventFactory.breadcrumbEvent(level: level);
        expect(event.level, equals(level));
      }
    });

    test('data is null by default', () {
      final event = EventFactory.breadcrumbEvent();
      expect(event.data, isNull);
    });

    test('stores structured data', () {
      final event = EventFactory.breadcrumbEvent(
        data: {'screen': 'Cart', 'item_count': 3},
      );
      expect(event.data!['screen'], equals('Cart'));
      expect(event.data!['item_count'], equals(3));
    });
  });

  group('BreadcrumbEvent — serialization', () {
    test('toJson includes type as "breadcrumb"', () {
      final event = EventFactory.breadcrumbEvent();
      expect(event.toJson()['type'], equals('breadcrumb'));
    });

    test('toJson includes message and level', () {
      final event = EventFactory.breadcrumbEvent(
        message: 'Navigation event',
        level: BreadcrumbLevel.warning,
      );
      final json = event.toJson();
      expect(json['message'], equals('Navigation event'));
      expect(json['level'], equals('warning'));
    });

    test('toJson includes category when set', () {
      final event = EventFactory.breadcrumbEvent(category: 'navigation');
      expect(event.toJson()['category'], equals('navigation'));
    });

    test('toJson omits category when null', () {
      final event = EventFactory.breadcrumbEvent(category: null);
      expect(event.toJson().containsKey('category'), isFalse);
    });

    test('toJson includes data when non-empty', () {
      final event = EventFactory.breadcrumbEvent(data: {'key': 'value'});
      final json = event.toJson();
      expect(json['data'], isA<Map<String, dynamic>>());
    });

    test('toJson omits data when null', () {
      final event = EventFactory.breadcrumbEvent(data: null);
      expect(event.toJson().containsKey('data'), isFalse);
    });
  });

  group('BreadcrumbEvent — copyWithSanitizedData', () {
    test('returns event with replaced data', () {
      final event = EventFactory.breadcrumbEvent(data: {'password': 'secret'});
      final copy = event.copyWithSanitizedData({'password': '[REDACTED]'});

      expect(copy.data!['password'], equals('[REDACTED]'));
      expect(copy.message, equals(event.message));
      expect(copy.id, equals(event.id));
    });

    test('original event is unchanged after copy', () {
      final event = EventFactory.breadcrumbEvent(
        data: {'password': 'secret', 'screen': 'Login'},
      );
      event
          .copyWithSanitizedData({'password': '[REDACTED]', 'screen': 'Login'});

      expect(event.data!['password'], equals('secret'));
    });
  });
}

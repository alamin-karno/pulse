import 'package:pulse_core/pulse_core.dart';
import 'package:test/test.dart';

import '../helpers/event_factory.dart';

void main() {
  group('BreadcrumbBuffer — capacity', () {
    test('starts empty', () {
      final buffer = BreadcrumbBuffer();
      expect(buffer.isEmpty, isTrue);
      expect(buffer.length, equals(0));
    });

    test('length increases with each add', () {
      final buffer = BreadcrumbBuffer(maxCapacity: 5);
      buffer.add(EventFactory.breadcrumbEvent(message: 'a'));
      buffer.add(EventFactory.breadcrumbEvent(message: 'b'));
      expect(buffer.length, equals(2));
    });

    test('does not exceed maxCapacity', () {
      final buffer = BreadcrumbBuffer(maxCapacity: 3);
      for (var i = 0; i < 10; i++) {
        buffer.add(EventFactory.breadcrumbEvent(message: 'crumb $i'));
      }
      expect(buffer.length, equals(3));
    });

    test('evicts oldest entry when at capacity', () {
      final buffer = BreadcrumbBuffer(maxCapacity: 3);
      buffer.add(EventFactory.breadcrumbEvent(message: 'first'));
      buffer.add(EventFactory.breadcrumbEvent(message: 'second'));
      buffer.add(EventFactory.breadcrumbEvent(message: 'third'));
      buffer.add(EventFactory.breadcrumbEvent(message: 'fourth'));

      final crumbs = buffer.breadcrumbs;
      expect(crumbs.map((c) => c.message).toList(),
          equals(['second', 'third', 'fourth']));
    });
  });

  group('BreadcrumbBuffer — maxCapacity 0', () {
    test('accepts maxCapacity of 0', () {
      expect(() => BreadcrumbBuffer(maxCapacity: 0), returnsNormally);
    });

    test('add is no-op when maxCapacity is 0', () {
      final buffer = BreadcrumbBuffer(maxCapacity: 0);
      buffer.add(EventFactory.breadcrumbEvent());
      expect(buffer.isEmpty, isTrue);
    });
  });

  group('BreadcrumbBuffer — breadcrumbs snapshot', () {
    test('returns unmodifiable list', () {
      final buffer = BreadcrumbBuffer(maxCapacity: 5);
      buffer.add(EventFactory.breadcrumbEvent());

      final snapshot = buffer.breadcrumbs;
      expect(
          () => snapshot.add(
                EventFactory.breadcrumbEvent(),
              ),
          throwsUnsupportedError);
    });

    test('snapshot is not affected by subsequent adds', () {
      final buffer = BreadcrumbBuffer(maxCapacity: 5);
      buffer.add(EventFactory.breadcrumbEvent(message: 'a'));
      final snapshot = buffer.breadcrumbs;

      buffer.add(EventFactory.breadcrumbEvent(message: 'b'));
      expect(snapshot.length, equals(1)); // snapshot not modified
    });

    test('preserves insertion order (oldest first)', () {
      final buffer = BreadcrumbBuffer(maxCapacity: 5);
      buffer.add(EventFactory.breadcrumbEvent(message: '1'));
      buffer.add(EventFactory.breadcrumbEvent(message: '2'));
      buffer.add(EventFactory.breadcrumbEvent(message: '3'));

      final messages = buffer.breadcrumbs.map((c) => c.message).toList();
      expect(messages, equals(['1', '2', '3']));
    });
  });

  group('BreadcrumbBuffer — clear', () {
    test('clear removes all breadcrumbs', () {
      final buffer = BreadcrumbBuffer(maxCapacity: 5);
      buffer.add(EventFactory.breadcrumbEvent());
      buffer.add(EventFactory.breadcrumbEvent());
      buffer.clear();

      expect(buffer.isEmpty, isTrue);
      expect(buffer.length, equals(0));
    });

    test('add works normally after clear', () {
      final buffer = BreadcrumbBuffer(maxCapacity: 5);
      buffer.add(EventFactory.breadcrumbEvent(message: 'before clear'));
      buffer.clear();
      buffer.add(EventFactory.breadcrumbEvent(message: 'after clear'));

      expect(buffer.length, equals(1));
      expect(buffer.breadcrumbs.first.message, equals('after clear'));
    });
  });

  group('BreadcrumbBuffer — assertions', () {
    test('throws AssertionError for negative maxCapacity', () {
      expect(
        () => BreadcrumbBuffer(maxCapacity: -1),
        throwsA(isA<AssertionError>()),
      );
    });
  });
}

import 'package:pulse_dev/pulse_dev.dart';
import 'package:test/test.dart';

import '../helpers/event_factory.dart';

void main() {
  late DefaultSanitizer sanitizer;

  setUp(() {
    sanitizer = const DefaultSanitizer();
  });

  group('DefaultSanitizer — CustomEvent properties', () {
    test('redacts exact sensitive keys', () {
      final event = EventFactory.customEvent(properties: {
        'password': 'secret123',
        'username': 'john',
      });

      final sanitized = sanitizer.sanitize(event) as CustomEvent;
      expect(sanitized.properties['password'], equals('[REDACTED]'));
      expect(sanitized.properties['username'], equals('john'));
    });

    test('redacts keys containing sensitive substrings (case-insensitive)', () {
      final event = EventFactory.customEvent(properties: {
        'auth_token': 'abc',
        'my_password_hash': 'xyz',
        'API_KEY': 'key123',
        'user_email': 'user@example.com',
      });

      final sanitized = sanitizer.sanitize(event) as CustomEvent;
      expect(sanitized.properties['auth_token'], equals('[REDACTED]'));
      expect(sanitized.properties['my_password_hash'], equals('[REDACTED]'));
      expect(sanitized.properties['API_KEY'], equals('[REDACTED]'));
      expect(sanitized.properties['user_email'], equals('user@example.com'));
    });

    test('redacts all known sensitive patterns', () {
      final sensitiveKeys = [
        'password',
        'passwd',
        'pwd',
        'secret',
        'token',
        'authorization',
        'auth',
        'api_key',
        'apikey',
        'private_key',
        'private',
        'credit_card',
        'card_number',
        'card_no',
        'cardnumber',
        'cvv',
        'cvc',
        'ssn',
        'social_security',
        'pin',
      ];

      for (final key in sensitiveKeys) {
        final event = EventFactory.customEvent(properties: {key: 'sensitive'});
        final sanitized = sanitizer.sanitize(event) as CustomEvent;
        expect(
          sanitized.properties[key],
          equals('[REDACTED]'),
          reason: 'Expected key "$key" to be redacted',
        );
      }
    });

    test('preserves non-sensitive properties unchanged', () {
      final event = EventFactory.customEvent(properties: {
        'amount': 99.99,
        'currency': 'USD',
        'screen': 'CartScreen',
        'item_count': 3,
      });

      final sanitized = sanitizer.sanitize(event) as CustomEvent;
      expect(sanitized.properties['amount'], equals(99.99));
      expect(sanitized.properties['currency'], equals('USD'));
      expect(sanitized.properties['screen'], equals('CartScreen'));
      expect(sanitized.properties['item_count'], equals(3));
    });

    test('redacts recursively in nested maps', () {
      final event = EventFactory.customEvent(properties: {
        'user': {
          'name': 'Alice',
          'password': 'secret',
          'preferences': {
            'token': 'nested-token',
            'theme': 'dark',
          },
        },
      });

      final sanitized = sanitizer.sanitize(event) as CustomEvent;
      final user = sanitized.properties['user'] as Map<String, dynamic>;
      expect(user['name'], equals('Alice'));
      expect(user['password'], equals('[REDACTED]'));

      final prefs = user['preferences'] as Map<String, dynamic>;
      expect(prefs['token'], equals('[REDACTED]'));
      expect(prefs['theme'], equals('dark'));
    });

    test('returns identical event when no sensitive data present', () {
      final event = EventFactory.customEvent(properties: {
        'screen': 'HomeScreen',
        'duration_ms': 42,
      });

      final sanitized = sanitizer.sanitize(event) as CustomEvent;
      expect(sanitized.properties, equals(event.properties));
    });

    test('handles empty properties without error', () {
      final event = EventFactory.customEvent(properties: {});
      final sanitized = sanitizer.sanitize(event) as CustomEvent;
      expect(sanitized.properties, isEmpty);
    });
  });

  group('DefaultSanitizer — BreadcrumbEvent data', () {
    test('redacts sensitive keys in breadcrumb data', () {
      final event = EventFactory.breadcrumbEvent(data: {
        'auth_token': 'secret',
        'screen': 'LoginScreen',
      });

      final sanitized = sanitizer.sanitize(event) as BreadcrumbEvent;
      expect(sanitized.data!['auth_token'], equals('[REDACTED]'));
      expect(sanitized.data!['screen'], equals('LoginScreen'));
    });

    test('returns unchanged event when breadcrumb data is null', () {
      final event = EventFactory.breadcrumbEvent();
      final sanitized = sanitizer.sanitize(event) as BreadcrumbEvent;
      expect(sanitized.data, isNull);
    });
  });

  group('DefaultSanitizer — ErrorEvent / ExceptionEvent', () {
    test('returns ErrorEvent unchanged (no structured payload to sanitize)',
        () {
      final event = EventFactory.errorEvent();
      final sanitized = sanitizer.sanitize(event);
      expect(sanitized, same(event));
    });

    test('returns ExceptionEvent unchanged', () {
      final event = EventFactory.exceptionEvent();
      final sanitized = sanitizer.sanitize(event);
      expect(sanitized, same(event));
    });
  });

  group('DefaultSanitizer — immutability', () {
    test('does not modify the original event', () {
      final original = EventFactory.customEvent(properties: {
        'password': 'secret',
      });

      sanitizer.sanitize(original);

      expect(original.properties['password'], equals('secret'));
    });
  });
}

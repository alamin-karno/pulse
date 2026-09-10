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

    test('recursively redacts nested maps and lists', () {
      final event = EventFactory.customEvent(
        properties: {
          'user': {
            'api_key': '123',
            'details': {
              'ssn': '000',
              'safe': true,
            },
            'items': [
              'abc',
              {'Auth': 'secret'}
            ]
          },
        },
      );

      final sanitized = sanitizer.sanitize(event) as CustomEvent;
      final user = sanitized.properties['user'] as Map<String, dynamic>;
      final details = user['details'] as Map<String, dynamic>;
      final items = user['items'] as List<dynamic>;

      expect(user['api_key'], equals('[REDACTED]'));
      expect(details['ssn'], equals('[REDACTED]'));
      expect(details['safe'], isTrue);
      expect(items[0], equals('abc'));
      expect((items[1] as Map<String, dynamic>)['Auth'], equals('[REDACTED]'));
    });

    test('respects additionalRedactedKeys from config', () {
      const config = PulseSanitizationConfig(
        additionalRedactedKeys: {'custom_secret', 'employee_id'},
      );
      const sanitizer = DefaultSanitizer(config: config);

      final event = EventFactory.customEvent(
        properties: {
          'custom_secret': '123',
          'employee_id': '456',
          'public_id': '789',
        },
      );

      final sanitized = sanitizer.sanitize(event) as CustomEvent;

      expect(sanitized.properties['custom_secret'], equals('[REDACTED]'));
      expect(sanitized.properties['employee_id'], equals('[REDACTED]'));
      expect(sanitized.properties['public_id'], equals('789'));
    });

    test('applies string redaction patterns', () {
      final config = PulseSanitizationConfig(
        stringRedactionPatterns: [
          RegExp(r'\d{3}-\d{2}-\d{4}'), // SSN format
        ],
      );
      final sanitizer = DefaultSanitizer(config: config);

      final event = EventFactory.customEvent(
        properties: {
          'bio': 'My SSN is 123-45-6789 and I live here.',
        },
      );

      final sanitized = sanitizer.sanitize(event) as CustomEvent;

      expect(
        sanitized.properties['bio'],
        equals('My SSN is [REDACTED] and I live here.'),
      );
    });

    test('evaluates custom callbacks', () {
      final config = PulseSanitizationConfig(
        customCallbacks: [
          (String key, Object? value) {
            if (key == 'dynamic_field' && value == 'drop_me') {
              return 'custom_redaction';
            }
            return null; // Fallback to default logic
          }
        ],
      );
      final sanitizer = DefaultSanitizer(config: config);

      final event = EventFactory.customEvent(
        properties: {
          'dynamic_field': 'drop_me',
          'password': '123',
        },
      );

      final sanitized = sanitizer.sanitize(event) as CustomEvent;

      expect(sanitized.properties['dynamic_field'], equals('custom_redaction'));
      expect(sanitized.properties['password'], equals('[REDACTED]'));
    });

    test('sanitizeHeaders redacts configured headers', () {
      const config = PulseSanitizationConfig(
        redactedHeaders: {'authorization', 'x-custom-auth'},
      );
      const sanitizer = DefaultSanitizer(config: config);

      final headers = {
        'Authorization': 'Bearer 123',
        'X-Custom-Auth': 'Secret',
        'Content-Type': 'application/json',
      };

      final sanitized = sanitizer.sanitizeHeaders(headers);

      expect(sanitized['Authorization'], equals('[REDACTED]'));
      expect(sanitized['X-Custom-Auth'], equals('[REDACTED]'));
      expect(sanitized['Content-Type'], equals('application/json'));
    });

    test('returns ExceptionEvent and ErrorEvent unchanged', () {
      const sanitizer = DefaultSanitizer();
      final exceptionEvent = EventFactory.exceptionEvent();
      expect(sanitizer.sanitize(exceptionEvent), equals(exceptionEvent));

      final errorEvent = EventFactory.errorEvent();
      expect(sanitizer.sanitize(errorEvent), equals(errorEvent));
    });
  });
}

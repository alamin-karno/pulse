import 'package:meta/meta.dart';

import '../events/pulse_event.dart';
import 'pulse_sanitizer.dart';

/// The default [PulseSanitizer] implementation.
///
/// Redacts values in structured event payloads whose keys match known sensitive
/// patterns. Redacted values are replaced with `'[REDACTED]'`. Matching is
/// **case-insensitive** and uses **substring matching** to catch variations
/// such as `auth_token`, `password_hash`, or `my_api_key`.
///
/// Redaction is applied **recursively** to nested [Map] values.
///
/// ## Redacted key patterns
///
/// The following substrings trigger redaction when found in a key name:
///
/// `password` · `passwd` · `pwd` · `secret` · `token` · `authorization` ·
/// `auth` · `api_key` · `apikey` · `private_key` · `private` · `credit_card` ·
/// `card_number` · `card_no` · `cardnumber` · `cvv` · `cvc` · `ssn` ·
/// `social_security` · `pin`
///
/// ## What is sanitized
///
/// Only structured map payloads are sanitized:
/// - [CustomEvent.properties]
/// - [BreadcrumbEvent.data]
///
/// Free-text fields (error messages, stack traces) are **not** modified by
/// this sanitizer. Avoid putting sensitive data in error messages.
///
/// ## Custom sanitization
///
/// To extend the default behavior, subclass [DefaultSanitizer]:
///
/// ```dart
/// final class MySanitizer extends DefaultSanitizer {
///   @override
///   PulseEvent sanitize(PulseEvent event) {
///     final base = super.sanitize(event);
///     // Apply additional custom redaction
///     return base;
///   }
/// }
/// ```
@immutable
final class DefaultSanitizer implements PulseSanitizer {
  /// The placeholder substituted for redacted values.
  static const String redactedValue = '[REDACTED]';

  static const List<String> _sensitivePatterns = [
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

  /// Creates a [DefaultSanitizer].
  const DefaultSanitizer();

  @override
  PulseEvent sanitize(PulseEvent event) {
    return switch (event) {
      CustomEvent() => event.copyWithSanitizedProperties(
          _sanitizeMap(event.properties),
        ),
      BreadcrumbEvent() => event.data != null
          ? event.copyWithSanitizedData(_sanitizeMap(event.data!))
          : event,
      _ => event,
    };
  }

  /// Recursively sanitizes a map, replacing sensitive values with
  /// [redactedValue].
  Map<String, dynamic> _sanitizeMap(Map<String, dynamic> map) {
    return {
      for (final entry in map.entries)
        entry.key: _isSensitiveKey(entry.key)
            ? redactedValue
            : _sanitizeValue(entry.value),
    };
  }

  Object? _sanitizeValue(Object? value) {
    if (value is Map<String, dynamic>) {
      return _sanitizeMap(value);
    }
    return value;
  }

  bool _isSensitiveKey(String key) {
    final lower = key.toLowerCase();
    return _sensitivePatterns.any(lower.contains);
  }
}

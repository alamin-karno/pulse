import 'package:meta/meta.dart';

import '../events/pulse_event.dart';
import 'pulse_sanitization_config.dart';
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
///   MySanitizer(super.config);
///
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

  /// The configuration providing additional redaction rules.
  final PulseSanitizationConfig config;

  /// Creates a [DefaultSanitizer].
  const DefaultSanitizer({this.config = const PulseSanitizationConfig()});

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
  /// [config.redactedValue].
  Map<String, dynamic> _sanitizeMap(Map<String, dynamic> map) {
    return {
      for (final entry in map.entries)
        entry.key: _sanitizeEntry(entry.key, entry.value),
    };
  }

  /// Sanitizes a list by iterating over all items recursively.
  List<dynamic> _sanitizeList(List<dynamic> list) {
    return [
      for (final item in list) _sanitizeValue(item),
    ];
  }

  /// Sanitizes a string using the regex patterns defined in the config.
  String _sanitizeString(String value) {
    if (config.stringRedactionPatterns.isEmpty) return value;
    var sanitized = value;
    for (final pattern in config.stringRedactionPatterns) {
      sanitized = sanitized.replaceAll(pattern, config.redactedValue);
    }
    return sanitized;
  }

  /// Applies custom callbacks and default sanitization logic to a key-value pair.
  Object? _sanitizeEntry(String key, Object? value) {
    for (final callback in config.customCallbacks) {
      final customResult = callback(key, value);
      if (customResult != null) {
        return customResult;
      }
    }

    if (_isSensitiveKey(key)) {
      return config.redactedValue;
    }

    return _sanitizeValue(value);
  }

  Object? _sanitizeValue(Object? value) {
    if (value is Map<String, dynamic>) {
      return _sanitizeMap(value);
    }
    if (value is List) {
      return _sanitizeList(value);
    }
    if (value is String) {
      return _sanitizeString(value);
    }
    return value;
  }

  bool _isSensitiveKey(String key) {
    final lower = key.toLowerCase();
    if (_sensitivePatterns.any(lower.contains)) {
      return true;
    }
    return config.additionalRedactedKeys.any(
      (k) => lower.contains(k.toLowerCase()),
    );
  }

  /// Abstraction for HTTP header sanitization.
  ///
  /// Can be used by transport layers before sending requests.
  Map<String, String> sanitizeHeaders(Map<String, String> headers) {
    final redacted = <String, String>{};
    for (final entry in headers.entries) {
      final keyLower = entry.key.toLowerCase();
      if (config.redactedHeaders.contains(keyLower)) {
        redacted[entry.key] = config.redactedValue;
      } else {
        redacted[entry.key] = entry.value;
      }
    }
    return redacted;
  }
}

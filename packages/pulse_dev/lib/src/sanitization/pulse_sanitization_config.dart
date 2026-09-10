import 'package:meta/meta.dart';

/// A callback used to provide custom sanitization logic for a specific key-value pair.
///
/// If the callback returns a non-null value, it replaces the original value.
/// If it returns `null`, the default sanitization rules apply.
typedef PulseSanitizerCallback = Object? Function(String key, Object? value);

/// Configuration for the Pulse Privacy and Sanitization Engine.
@immutable
final class PulseSanitizationConfig {
  /// Additional keys to redact beyond the default set.
  ///
  /// Keys are matched case-insensitively using substring matching.
  final Set<String> additionalRedactedKeys;

  /// The placeholder substituted for redacted values.
  final String redactedValue;

  /// Patterns to redact out of strings globally in the payload.
  final List<RegExp> stringRedactionPatterns;

  /// Custom callbacks evaluated for every key-value pair in a structured payload.
  final List<PulseSanitizerCallback> customCallbacks;

  /// HTTP headers to redact when sanitizing network requests.
  final Set<String> redactedHeaders;

  /// The maximum allowable size in bytes for a serialized event.
  ///
  /// If an event exceeds this size after sanitization, it is dropped to
  /// prevent SDK payload rejection and memory bloat.
  /// Defaults to 1 MB (1024 * 1024 bytes).
  final int maxPayloadSizeBytes;

  /// Creates a [PulseSanitizationConfig].
  const PulseSanitizationConfig({
    this.additionalRedactedKeys = const {},
    this.redactedValue = '[REDACTED]',
    this.stringRedactionPatterns = const [],
    this.customCallbacks = const [],
    this.redactedHeaders = const {
      'authorization',
      'cookie',
      'set-cookie',
      'x-api-key',
    },
    this.maxPayloadSizeBytes = 1024 * 1024,
  });
}

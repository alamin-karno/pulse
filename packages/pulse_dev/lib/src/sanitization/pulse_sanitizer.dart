import '../events/pulse_event.dart';

/// Defines the contract for sanitizing [PulseEvent]s before transport.
///
/// Sanitization is a **mandatory, non-skippable** step in the [EventPipeline].
/// It runs after all [EventProcessor]s and before [PulseTransport.send] is
/// called. Its purpose is to ensure that sensitive information is redacted
/// before events leave the device.
///
/// ## Contract
///
/// - **Must not modify the original event.** Events are immutable; return a
///   new instance with sensitive data removed or replaced.
/// - **Must not throw.** If sanitization fails, the pipeline drops the event
///   rather than sending unsanitized data.
/// - **Must be deterministic.** The same input event must always produce the
///   same sanitized output.
///
/// ## Default implementation
///
/// [DefaultSanitizer] provides out-of-the-box redaction of 20+ sensitive key
/// patterns (passwords, tokens, API keys, payment data, etc.).
///
/// ## Custom sanitizer
///
/// Replace [DefaultSanitizer] by providing your own implementation:
///
/// ```dart
/// PulseConfig(
///   dsn: '...',
///   sanitizer: MyOrganizationSanitizer(),
/// )
/// ```
///
/// To extend [DefaultSanitizer], subclass it and call `super.sanitize(event)`
/// before applying additional redaction.
abstract interface class PulseSanitizer {
  /// Returns a sanitized copy of [event].
  ///
  /// Sensitive fields must be redacted by replacing their values with a
  /// placeholder (typically `'[REDACTED]'`). Non-sensitive fields must be
  /// preserved unchanged.
  PulseEvent sanitize(PulseEvent event);
}

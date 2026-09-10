part of 'pulse_event.dart';

/// A [PulseEvent] representing a custom analytics-style event.
///
/// Custom events are captured via [Pulse.track] and carry an arbitrary
/// set of named properties. They are suitable for tracking business-level
/// events such as user actions, feature usage, or conversion funnels.
///
/// ## Example
///
/// ```dart
/// Pulse.track(
///   'payment_initiated',
///   properties: {
///     'amount': 99.99,
///     'currency': 'USD',
///     'payment_method': 'card',
///   },
/// );
/// ```
///
/// ## Privacy
///
/// All properties are passed through [DefaultSanitizer] before transport.
/// Avoid including sensitive data (passwords, tokens, payment details) in
/// properties — they will be redacted.
@immutable
final class CustomEvent extends PulseEvent {
  /// The name of this custom event (e.g., `'payment_initiated'`).
  ///
  /// Should be lowercase with underscores. Avoid spaces.
  final String name;

  /// Structured properties associated with this event.
  ///
  /// Values must be JSON-serializable. Sensitive keys are redacted by
  /// [DefaultSanitizer].
  final Map<String, dynamic> properties;

  /// Creates a [CustomEvent].
  const CustomEvent({
    required super.id,
    required super.timestamp,
    required super.sdkVersion,
    required super.appVersion,
    required super.environment,
    required super.platform,
    required super.context,
    required this.name,
    this.properties = const {},
    super.schemaVersion,
  }) : super(type: PulseEventType.custom);

  /// Returns a copy of this [CustomEvent] with [properties] replaced.
  ///
  /// Used internally by [DefaultSanitizer] to produce a sanitized copy
  /// without modifying the original event.
  CustomEvent copyWithSanitizedProperties(
    Map<String, dynamic> sanitizedProperties,
  ) =>
      CustomEvent(
        id: id,
        timestamp: timestamp,
        sdkVersion: sdkVersion,
        appVersion: appVersion,
        environment: environment,
        platform: platform,
        context: context,
        name: name,
        properties: sanitizedProperties,
        schemaVersion: schemaVersion,
      );

  @override
  Map<String, dynamic> toJson() => {
        ...baseJson(),
        'name': name,
        if (properties.isNotEmpty) 'properties': properties,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomEvent && id == other.id && name == other.name;

  @override
  int get hashCode => Object.hash(id, name);

  @override
  String toString() => 'CustomEvent(id: $id, name: $name)';
}

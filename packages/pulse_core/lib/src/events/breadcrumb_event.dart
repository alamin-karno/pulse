part of 'pulse_event.dart';

/// Severity level for a [BreadcrumbEvent].
enum BreadcrumbLevel {
  /// Verbose diagnostic information.
  debug,

  /// General informational message.
  info,

  /// A non-fatal warning.
  warning,

  /// An error that occurred but did not crash the app.
  error,
}

/// A [PulseEvent] representing a manual breadcrumb.
///
/// Breadcrumbs record a timeline of notable events that occurred before an
/// error or exception. They are captured via [Pulse.addBreadcrumb] and
/// stored in the [BreadcrumbBuffer]. When an [ErrorEvent] or [ExceptionEvent]
/// is captured, the current buffer contents are attached to it.
///
/// ## Example
///
/// ```dart
/// Pulse.addBreadcrumb(
///   'User tapped "Checkout"',
///   category: 'ui.action',
///   data: {'screen': 'CartScreen'},
/// );
/// ```
@immutable
final class BreadcrumbEvent extends PulseEvent {
  /// The human-readable breadcrumb message.
  final String message;

  /// An optional dot-separated category for grouping (e.g., `'ui.action'`,
  /// `'network.request'`, `'navigation'`).
  final String? category;

  /// The severity level of this breadcrumb.
  final BreadcrumbLevel level;

  /// Optional structured data associated with this breadcrumb.
  ///
  /// Values must be JSON-serializable. Keys containing sensitive patterns
  /// are redacted by [DefaultSanitizer].
  final Map<String, dynamic>? data;

  /// Creates a [BreadcrumbEvent].
  const BreadcrumbEvent({
    required super.id,
    required super.timestamp,
    required super.sdkVersion,
    required super.appVersion,
    required super.environment,
    required super.platform,
    required super.context,
    required this.message,
    this.category,
    this.level = BreadcrumbLevel.info,
    this.data,
    super.schemaVersion,
  }) : super(type: PulseEventType.breadcrumb);

  /// Returns a copy of this [BreadcrumbEvent] with [data] replaced.
  ///
  /// Used internally by [DefaultSanitizer] to produce a sanitized copy
  /// without modifying the original event.
  BreadcrumbEvent copyWithSanitizedData(Map<String, dynamic>? sanitizedData) =>
      BreadcrumbEvent(
        id: id,
        timestamp: timestamp,
        sdkVersion: sdkVersion,
        appVersion: appVersion,
        environment: environment,
        platform: platform,
        context: context,
        message: message,
        category: category,
        level: level,
        data: sanitizedData,
        schemaVersion: schemaVersion,
      );

  @override
  Map<String, dynamic> toJson() => {
        ...baseJson(),
        'message': message,
        if (category != null) 'category': category,
        'level': level.name,
        if (data != null && data!.isNotEmpty) 'data': data,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BreadcrumbEvent &&
          id == other.id &&
          message == other.message &&
          category == other.category;

  @override
  int get hashCode => Object.hash(id, message, category);

  @override
  String toString() =>
      'BreadcrumbEvent(id: $id, message: $message, category: $category)';
}

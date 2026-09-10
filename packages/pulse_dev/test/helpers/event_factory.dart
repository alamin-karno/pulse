import 'package:pulse_dev/pulse_dev.dart';

/// Factory for creating test [PulseEvent] instances with sensible defaults.
///
/// Use these helpers in tests to avoid repeating boilerplate event
/// construction. All fields have deterministic defaults.
abstract final class EventFactory {
  static final _clock = FakeClock(DateTime.utc(2024, 6, 15, 12, 0, 0));
  static final _idGen = FakeIdGenerator();

  static const _defaultContext = PulseContext(
    osName: 'TestOS',
    osVersion: '1.0',
  );

  /// Creates an [ErrorEvent] with overridable fields.
  static ErrorEvent errorEvent({
    String? id,
    DateTime? timestamp,
    String errorType = 'TestError',
    String message = 'Test error message',
    StackTrace? stackTrace,
    List<BreadcrumbEvent>? breadcrumbs,
    PulseContext? context,
    String environment = 'test',
    String platform = 'dart',
    String? appVersion,
  }) =>
      ErrorEvent(
        id: id ?? _idGen.newId(),
        timestamp: timestamp ?? _clock.now(),
        sdkVersion: kPulseSdkVersion,
        appVersion: appVersion,
        environment: environment,
        platform: platform,
        context: context ?? _defaultContext,
        errorType: errorType,
        message: message,
        stackTrace: stackTrace,
        breadcrumbs: breadcrumbs ?? const [],
      );

  /// Creates an [ExceptionEvent] with overridable fields.
  static ExceptionEvent exceptionEvent({
    String? id,
    DateTime? timestamp,
    String exceptionType = 'TestException',
    String message = 'Test exception message',
    StackTrace? stackTrace,
    List<BreadcrumbEvent>? breadcrumbs,
    bool handled = true,
    PulseContext? context,
    String environment = 'test',
    String platform = 'dart',
    String? appVersion,
  }) =>
      ExceptionEvent(
        id: id ?? _idGen.newId(),
        timestamp: timestamp ?? _clock.now(),
        sdkVersion: kPulseSdkVersion,
        appVersion: appVersion,
        environment: environment,
        platform: platform,
        context: context ?? _defaultContext,
        exceptionType: exceptionType,
        message: message,
        stackTrace: stackTrace,
        breadcrumbs: breadcrumbs ?? const [],
        handled: handled,
      );

  /// Creates a [BreadcrumbEvent] with overridable fields.
  static BreadcrumbEvent breadcrumbEvent({
    String? id,
    DateTime? timestamp,
    String message = 'Test breadcrumb',
    String? category = 'test',
    BreadcrumbLevel level = BreadcrumbLevel.info,
    Map<String, dynamic>? data,
    PulseContext? context,
    String environment = 'test',
    String platform = 'dart',
    String? appVersion,
  }) =>
      BreadcrumbEvent(
        id: id ?? _idGen.newId(),
        timestamp: timestamp ?? _clock.now(),
        sdkVersion: kPulseSdkVersion,
        appVersion: appVersion,
        environment: environment,
        platform: platform,
        context: context ?? _defaultContext,
        message: message,
        category: category,
        level: level,
        data: data,
      );

  /// Creates a [CustomEvent] with overridable fields.
  static CustomEvent customEvent({
    String? id,
    DateTime? timestamp,
    String name = 'test_event',
    Map<String, dynamic>? properties,
    PulseContext? context,
    String environment = 'test',
    String platform = 'dart',
    String? appVersion,
  }) =>
      CustomEvent(
        id: id ?? _idGen.newId(),
        timestamp: timestamp ?? _clock.now(),
        sdkVersion: kPulseSdkVersion,
        appVersion: appVersion,
        environment: environment,
        platform: platform,
        context: context ?? _defaultContext,
        name: name,
        properties: properties ?? const {},
      );
}

/// A [PulseTransport] that records all received events for test assertion.
final class CapturingTransport implements PulseTransport {
  /// All events that have been sent to this transport.
  final List<PulseEvent> captured = [];

  /// Whether [close] has been called.
  bool isClosed = false;

  @override
  Future<PulseTransportResult> send(PulseEvent event) async {
    captured.add(event);
    return PulseTransportResult.success;
  }

  @override
  Future<void> close() async => isClosed = true;

  /// Clears all captured events.
  void reset() {
    captured.clear();
    isClosed = false;
  }
}

/// A [PulseTransport] that always throws on [send].
final class ThrowingTransport implements PulseTransport {
  @override
  Future<PulseTransportResult> send(PulseEvent event) async {
    throw Exception('Transport failure');
  }

  @override
  Future<void> close() async {}
}

/// A [PulseSanitizer] that always throws.
final class ThrowingSanitizer implements PulseSanitizer {
  @override
  PulseEvent sanitize(PulseEvent event) {
    throw Exception('Sanitizer failure');
  }
}

/// An [EventProcessor] that always drops events (returns null).
final class DroppingProcessor implements EventProcessor {
  @override
  PulseEvent? process(PulseEvent event) => null;
}

/// An [EventProcessor] that always throws.
final class ThrowingProcessor implements EventProcessor {
  @override
  PulseEvent? process(PulseEvent event) {
    throw Exception('Processor failure');
  }
}

import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:pulse_dev/pulse_dev.dart';

import '../pulse_dev_flutter.dart' show Pulse;
import 'context/flutter_context_collector.dart';
import 'integrations/flutter_error_integration.dart';
import 'performance/flutter_performance_integration.dart';
import 'pulse.dart' show Pulse;

/// Internal stateful coordinator for the Pulse SDK.
///
/// [PulseClient] owns the [EventPipeline], [BreadcrumbBuffer], and
/// registered integrations. It is created by [Pulse.initialize] and
/// held in a private field.
///
/// Consumer code should not interact with [PulseClient] directly —
/// use the [Pulse] static facade instead. [PulseClient] is exposed
/// for advanced testing via `@visibleForTesting` accessors on [Pulse].
final class PulseClient {
  /// Creates a [PulseClient] from a [PulseConfig].
  ///
  /// Collects Flutter context and installs integrations.
  @visibleForTesting
  PulseClient({
    required PulseConfig config,
    required PulseContext context,
    Clock? clock,
    Random? random,
    IdGenerator? idGenerator,
    FlutterErrorIntegration? flutterErrorIntegration,
    FlutterPerformanceIntegration? flutterPerformanceIntegration,
  })  : _config = config,
        _pipeline = EventPipeline.fromConfig(config),
        _breadcrumbBuffer = BreadcrumbBuffer(
          maxCapacity: config.maxBreadcrumbs,
        ),
        _clock = clock ?? const SystemClock(),
        _idGenerator = idGenerator ?? const UuidGenerator(),
        _context = context,
        _flutterErrorIntegration = flutterErrorIntegration,
        _flutterPerformanceIntegration = flutterPerformanceIntegration,
        _networkObserver = PulseNetworkObserver(
          config: config,
          pipeline: EventPipeline.fromConfig(config),
          platform: kIsWeb
              ? PulsePlatform.web
              : (context.osName?.toLowerCase() ?? PulsePlatform.unknown),
          context: context,
          idGenerator: idGenerator,
          clock: clock,
        ),
        _random = random ?? Random();
  final PulseConfig _config;
  final EventPipeline _pipeline;
  final BreadcrumbBuffer _breadcrumbBuffer;
  final Clock _clock;
  final IdGenerator _idGenerator;
  final PulseContext _context;
  final FlutterErrorIntegration? _flutterErrorIntegration;
  final FlutterPerformanceIntegration? _flutterPerformanceIntegration;
  final PulseNetworkObserver _networkObserver;
  final Random _random;

  /// The active performance integration, if enabled.
  FlutterPerformanceIntegration? get flutterPerformanceIntegration =>
      _flutterPerformanceIntegration;

  /// Creates a [PulseClient] from a [PulseConfig], collecting Flutter context.
  ///
  /// This is the factory used by [Pulse.initialize].
  static PulseClient create(PulseConfig config) {
    final context = FlutterContextCollector.collect(
      appVersion: config.release,
    );

    final client = PulseClient(config: config, context: context);

    FlutterErrorIntegration? flutterErrorIntegration;
    if (config.captureFlutterErrors) {
      flutterErrorIntegration = FlutterErrorIntegration(client);
      flutterErrorIntegration.install();
    }

    FlutterPerformanceIntegration? flutterPerformanceIntegration;
    if (config.performance.enabled) {
      flutterPerformanceIntegration =
          FlutterPerformanceIntegration(config, client);
      flutterPerformanceIntegration.install();
    }

    if (flutterErrorIntegration != null ||
        flutterPerformanceIntegration != null) {
      return PulseClient(
        config: config,
        context: context,
        flutterErrorIntegration: flutterErrorIntegration,
        flutterPerformanceIntegration: flutterPerformanceIntegration,
      );
    }

    return client;
  }

  /// The resolved platform string for this client.
  String get _platform {
    if (kIsWeb) return PulsePlatform.web;
    return _context.osName?.toLowerCase() ?? PulsePlatform.unknown;
  }

  /// Captures an exception and sends it through the event pipeline.
  ///
  /// [exception] may be any [Object]. [stackTrace] is optional but strongly
  /// recommended.
  ///
  /// Set [handled] to `false` when calling from an error integration to
  /// indicate the exception was not explicitly caught by application code.
  void captureException(
    Object exception, {
    StackTrace? stackTrace,
    bool handled = true,
  }) {
    if (!_config.enabled) return;

    try {
      final event = ExceptionEvent(
        id: _idGenerator.newId(),
        timestamp: _clock.now(),
        sdkVersion: kPulseSdkVersion,
        appVersion: _config.release,
        environment: _config.environment,
        platform: _platform,
        context: _context,
        exceptionType: exception.runtimeType.toString(),
        message: exception.toString(),
        stackTrace: stackTrace,
        breadcrumbs: _breadcrumbBuffer.breadcrumbs,
        handled: handled,
      );

      _pipeline.process(event);
    } catch (e, st) {
      _config.logger.log(
        PulseLogLevel.error,
        'Internal SDK error during captureException',
        error: e,
        stackTrace: st,
      );
    }
  }

  /// Captures a Dart [Error] and sends it through the event pipeline.
  void captureError(Object error, {StackTrace? stackTrace}) {
    if (!_config.enabled) return;

    try {
      final event = ErrorEvent(
        id: _idGenerator.newId(),
        timestamp: _clock.now(),
        sdkVersion: kPulseSdkVersion,
        appVersion: _config.release,
        environment: _config.environment,
        platform: _platform,
        context: _context,
        errorType: error.runtimeType.toString(),
        message: error.toString(),
        stackTrace: stackTrace,
        breadcrumbs: _breadcrumbBuffer.breadcrumbs,
      );

      _pipeline.process(event);
    } catch (e, st) {
      _config.logger.log(
        PulseLogLevel.error,
        'Internal SDK error during captureError',
        error: e,
        stackTrace: st,
      );
    }
  }

  /// Records a breadcrumb and stores it in the buffer.
  void addBreadcrumb(
    String message, {
    String? category,
    BreadcrumbLevel level = BreadcrumbLevel.info,
    Map<String, dynamic>? data,
  }) {
    if (!_config.enabled) return;

    try {
      final event = BreadcrumbEvent(
        id: _idGenerator.newId(),
        timestamp: _clock.now(),
        sdkVersion: kPulseSdkVersion,
        appVersion: _config.release,
        environment: _config.environment,
        platform: _platform,
        context: _context,
        message: message,
        category: category,
        level: level,
        data: data,
      );

      _breadcrumbBuffer.add(event);
      _pipeline.process(event);
    } catch (e, st) {
      _config.logger.log(
        PulseLogLevel.error,
        'Internal SDK error during addBreadcrumb',
        error: e,
        stackTrace: st,
      );
    }
  }

  /// Captures a custom analytics-style event.
  void track(String name, {Map<String, dynamic>? properties}) {
    if (!_config.enabled) return;

    try {
      final event = CustomEvent(
        id: _idGenerator.newId(),
        timestamp: _clock.now(),
        sdkVersion: kPulseSdkVersion,
        appVersion: _config.release,
        environment: _config.environment,
        platform: _platform,
        context: _context,
        name: name,
        properties: properties ?? const {},
      );

      _pipeline.process(event);
    } catch (e, st) {
      _config.logger.log(
        PulseLogLevel.error,
        'Internal SDK error during track',
        error: e,
        stackTrace: st,
      );
    }
  }

  /// Closes the client, flushing the pipeline and uninstalling integrations.
  Future<void> close() async {
    _flutterErrorIntegration?.uninstall();
    await _pipeline.close();
    _breadcrumbBuffer.clear();
  }

  /// Starts a performance transaction.
  ///
  /// If performance monitoring is disabled or the transaction is dropped
  /// due to sampling, a lightweight No-Op transaction is returned.
  PulseTransaction startTransaction(String name) {
    if (!_config.performance.enabled) {
      return PulseTransaction.noOp(name);
    }

    // Evaluate sample rate
    final sampleRate = _config.performance.sampleRate;
    if (sampleRate < 1.0) {
      if (sampleRate <= 0.0 || _random.nextDouble() > sampleRate) {
        return PulseTransaction.noOp(name);
      }
    }

    return PulseTransaction.create(
      name: name,
      config: _config,
      pipeline: _pipeline,
      platform: kIsWeb
          ? PulsePlatform.web
          : (_context.osName?.toLowerCase() ?? PulsePlatform.unknown),
      context: _context,
      idGenerator: _idGenerator,
      clock: _clock,
    );
  }

  /// The network observer, used by HTTP adapters to dispatch network events.
  PulseNetworkObserver get networkObserver => _networkObserver;

  /// The current breadcrumb count (for testing/inspection).
  @visibleForTesting
  int get breadcrumbCount => _breadcrumbBuffer.length;
}

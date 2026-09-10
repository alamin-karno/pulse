import 'dart:math';

import '../config/pulse_config.dart';
import '../context/pulse_context.dart';
import '../events/pulse_event.dart';
import '../pipeline/event_pipeline.dart';
import '../utils/clock.dart';
import '../utils/id_generator.dart';

/// Intercepts and records HTTP requests as [NetworkEvent]s.
///
/// Third-party adapters (like `pulse_dio` or `pulse_http`) call into this
/// observer to construct and dispatch events safely.
class PulseNetworkObserver {
  final PulseConfig _config;
  final EventPipeline _pipeline;
  final String _platform;
  final PulseContext _context;
  final IdGenerator _idGenerator;
  final Clock _clock;
  final Random _random;

  /// Creates a [PulseNetworkObserver] linked to a configuration and pipeline.
  PulseNetworkObserver({
    required PulseConfig config,
    required EventPipeline pipeline,
    required String platform,
    required PulseContext context,
    IdGenerator? idGenerator,
    Clock? clock,
    Random? random,
  })  : _config = config,
        _pipeline = pipeline,
        _platform = platform,
        _context = context,
        _idGenerator = idGenerator ?? const UuidGenerator(),
        _clock = clock ?? const SystemClock(),
        _random = random ?? Random();

  /// Captures a completed or failed network request.
  void capture({
    required String method,
    required String url,
    required Duration duration,
    required bool success,
    int? statusCode,
    int? requestSize,
    int? responseSize,
    String? errorCategory,
    Map<String, String>? requestHeaders,
    Map<String, String>? responseHeaders,
    Object? requestBody,
    Object? responseBody,
  }) {
    final netConfig = _config.network;

    if (!netConfig.enabled) {
      return;
    }

    if (netConfig.sampleRate < 1.0) {
      if (_random.nextDouble() >= netConfig.sampleRate) {
        return; // Dropped by sampling
      }
    }

    // Redact URL query parameters
    final sanitizedUrl = _redactUrl(url, netConfig.redactQueryParameters);

    final event = NetworkEvent(
      id: _idGenerator.newId(),
      timestamp: _clock.now(),
      sdkVersion: kPulseSdkVersion,
      appVersion: _config.release,
      environment: _config.environment,
      platform: _platform,
      context: _context,
      method: method,
      url: sanitizedUrl,
      duration: duration,
      success: success,
      statusCode: statusCode,
      requestSize: requestSize,
      responseSize: responseSize,
      errorCategory: errorCategory,
      requestHeaders: netConfig.captureHeaders ? requestHeaders : null,
      responseHeaders: netConfig.captureHeaders ? responseHeaders : null,
      requestBody: netConfig.captureBody ? requestBody : null,
      responseBody: netConfig.captureBody ? responseBody : null,
    );

    _pipeline.process(event);
  }

  String _redactUrl(String urlString, Set<String> sensitiveKeys) {
    if (sensitiveKeys.isEmpty) return urlString;

    try {
      final uri = Uri.parse(urlString);
      if (uri.queryParameters.isEmpty) return urlString;

      final Map<String, dynamic> newQuery = Map.from(uri.queryParametersAll);
      bool modified = false;

      for (final key in uri.queryParameters.keys) {
        if (sensitiveKeys.contains(key.toLowerCase())) {
          newQuery[key] = ['[REDACTED]'];
          modified = true;
        }
      }

      if (!modified) return urlString;

      return uri.replace(queryParameters: newQuery).toString();
    } catch (_) {
      // If parsing fails, return original to avoid breaking app flow
      return urlString;
    }
  }
}

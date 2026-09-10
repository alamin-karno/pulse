import 'package:flutter/scheduler.dart';
import 'package:pulse_dev/pulse_dev.dart';

import '../pulse_client.dart';

/// Integrates Flutter-specific performance monitoring.
///
/// Automatically captures application startup time and slow UI operations
/// (e.g., slow raster or build frames).
class FlutterPerformanceIntegration {
  /// Creates a [FlutterPerformanceIntegration].
  FlutterPerformanceIntegration(this._config, this._client)
      : _initTime = DateTime.now();

  final PulseConfig _config;
  final PulseClient _client;
  final DateTime _initTime;

  bool _startupCaptured = false;

  /// Installs the performance hooks if enabled in the configuration.
  void install() {
    if (!_config.performance.enabled) return;

    if (_config.performance.captureStartupTime) {
      _captureStartupTime();
    }

    if (_config.performance.detectSlowOperations) {
      _captureSlowFrames();
    }
  }

  void _captureStartupTime() {
    // We use addPostFrameCallback to detect when the first frame has rendered.
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (_startupCaptured) return;
      _startupCaptured = true;

      final endTime = DateTime.now();
      final duration = endTime.difference(_initTime);

      final transaction = _client.startTransaction('app_startup');
      // For a startup transaction, the duration is effectively from _initTime
      // to endTime, but RealPulseTransaction takes time from startSpan.
      // A simple way is to log a custom event or a span.
      // For simplicity, we just use the transaction and finish it immediately.
      // But it will record duration as 0 if we start and finish instantly.
      // Let's add a breadcrumb or custom event for the actual startup metric since
      // transactions compute their own duration.

      _client.track('app_startup', properties: {
        'duration_ms': duration.inMilliseconds,
      });

      transaction.finish();
    });
  }

  void _captureSlowFrames() {
    SchedulerBinding.instance.addTimingsCallback((List<FrameTiming> timings) {
      final thresholdMs =
          _config.performance.slowOperationThreshold.inMilliseconds;

      for (final timing in timings) {
        final totalDuration = timing.totalSpan.inMilliseconds;
        if (totalDuration > thresholdMs) {
          // It's a slow frame.
          // Add a breadcrumb to help debug the slow frame.
          _client.addBreadcrumb(
            'Slow frame detected',
            category: 'ui.performance',
            data: {
              'duration_ms': totalDuration,
              'build_ms': timing.buildDuration.inMilliseconds,
              'raster_ms': timing.rasterDuration.inMilliseconds,
            },
            level: BreadcrumbLevel.warning,
          );
        }
      }
    });
  }
}

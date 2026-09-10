import 'package:meta/meta.dart';

/// Configuration for the Pulse Performance Intelligence subsystem.
///
/// Controls the capture of custom transactions, startup times, and slow operations.
@immutable
class PulsePerformanceConfig {
  /// Whether performance monitoring is globally enabled.
  /// Defaults to `true`.
  final bool enabled;

  /// The fraction of transactions to capture (0.0 to 1.0).
  /// Defaults to `1.0`.
  final double sampleRate;

  /// Whether to automatically capture app startup timing.
  /// Defaults to `true`.
  final bool captureStartupTime;

  /// Whether to automatically detect and capture slow UI operations (e.g. slow frames).
  /// Defaults to `true`.
  final bool detectSlowOperations;

  /// The threshold for an operation to be considered "slow".
  /// Defaults to 16 milliseconds (roughly equivalent to dropping below 60fps).
  final Duration slowOperationThreshold;

  /// Creates a [PulsePerformanceConfig].
  const PulsePerformanceConfig({
    this.enabled = true,
    this.sampleRate = 1.0,
    this.captureStartupTime = true,
    this.detectSlowOperations = true,
    this.slowOperationThreshold = const Duration(milliseconds: 16),
  }) : assert(sampleRate >= 0.0 && sampleRate <= 1.0,
            'sampleRate must be between 0.0 and 1.0');

  /// Returns a configuration with performance monitoring completely disabled.
  const PulsePerformanceConfig.disabled()
      : enabled = false,
        sampleRate = 0.0,
        captureStartupTime = false,
        detectSlowOperations = false,
        slowOperationThreshold = const Duration(milliseconds: 16);
}

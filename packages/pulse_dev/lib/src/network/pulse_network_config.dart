import 'package:meta/meta.dart';

/// Configuration for Pulse network telemetry.
///
/// Governs what network data is captured, how it is sampled, and which
/// parts of the request/response are sanitized.
@immutable
class PulseNetworkConfig {
  /// Whether network monitoring is enabled.
  ///
  /// Defaults to `true`.
  final bool enabled;

  /// The percentage of network requests to capture (0.0 to 1.0).
  ///
  /// Defaults to `1.0` (100%).
  final double sampleRate;

  /// A set of URL query parameters that should be redacted from captured URLs.
  ///
  /// By default, common sensitive parameters like `token`, `key`, `password`
  /// are redacted.
  final Set<String> redactQueryParameters;

  /// Whether to capture HTTP request and response headers.
  ///
  /// Defaults to `false`. Even if enabled, sensitive headers are stripped
  /// by the `PulseSanitizer`.
  final bool captureHeaders;

  /// Whether to capture HTTP request and response bodies.
  ///
  /// Defaults to `false`. Bodies can be very large and often contain PII.
  final bool captureBody;

  /// Creates a [PulseNetworkConfig].
  const PulseNetworkConfig({
    this.enabled = true,
    this.sampleRate = 1.0,
    this.redactQueryParameters = const {
      'token',
      'access_token',
      'refresh_token',
      'auth',
      'api_key',
      'password',
      'secret',
    },
    this.captureHeaders = false,
    this.captureBody = false,
  }) : assert(
          sampleRate >= 0.0 && sampleRate <= 1.0,
          'sampleRate must be between 0.0 and 1.0',
        );

  /// Default configuration for network capture.
  const PulseNetworkConfig.defaults() : this();
}

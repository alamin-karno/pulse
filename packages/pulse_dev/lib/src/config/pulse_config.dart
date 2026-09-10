import 'package:meta/meta.dart';

import '../logging/no_op_logger.dart';
import '../logging/pulse_logger.dart';
import '../network/pulse_network_config.dart';
import '../performance/pulse_performance_config.dart';
import '../pipeline/event_processor.dart';
import '../sanitization/default_sanitizer.dart';
import '../sanitization/pulse_sanitization_config.dart';
import '../sanitization/pulse_sanitizer.dart';
import '../storage/in_memory_pulse_storage.dart';
import '../storage/pulse_storage.dart';
import '../transport/no_op_transport.dart';
import '../transport/pulse_transport.dart';

/// Immutable configuration for the Pulse SDK.
///
/// Pass a [PulseConfig] instance to [Pulse.initialize] before capturing
/// any events. All fields have sensible defaults for production use.
///
/// ```dart
/// await Pulse.initialize(
///   const PulseConfig(
///     dsn: 'https://your-key@ingest.example.com/your-project-id',
///     environment: 'production',
///     release: '1.0.0+1',
///   ),
/// );
/// ```
///
/// ## DSN format
///
/// The [dsn] must be a URL of the form:
/// `https://{public-key}@{host}/{project-id}`
///
/// Examples:
/// - `https://abc123@ingest.pulse.dev/42`
/// - `https://abc123@localhost:8080/1` (self-hosted)
@immutable
final class PulseConfig {
  /// The Data Source Name identifying where events are sent.
  ///
  /// Must be a URL of the form `https://{key}@{host}/{project-id}`.
  /// Parsed by the active [PulseTransport] implementation.
  ///
  /// When using [NoOpTransport] (the default), this field is accepted but
  /// not used for any network requests.
  final String dsn;

  /// The deployment environment for captured events.
  ///
  /// Common values: `'production'`, `'staging'`, `'development'`.
  /// Defaults to `'production'`.
  final String environment;

  /// The application release identifier.
  ///
  /// Typically the version string from your `pubspec.yaml` build number,
  /// e.g., `'1.2.3+45'`. Used to correlate events with specific releases.
  final String? release;

  /// Whether the SDK should emit verbose diagnostic output.
  ///
  /// When `true`, the SDK logs internal pipeline events. This is useful
  /// during integration but should be disabled in production.
  /// Defaults to `false`.
  final bool debug;

  /// Whether the SDK is active.
  ///
  /// Set to `false` to globally disable all event capture without removing
  /// the SDK from your codebase. Useful for toggling via remote config.
  /// Defaults to `true`.
  final bool enabled;

  /// The fraction of events to send (0.0 to 1.0).
  ///
  /// When set to 1.0 (the default), all events are sent.
  /// When set to 0.5, approximately 50% of events are dropped randomly.
  /// When set to 0.0, all events are dropped (similar to `enabled = false`).
  final double sampleRate;

  /// The transport used to deliver events.
  ///
  /// Defaults to [NoOpTransport], which discards all events. Provide a
  /// real implementation for production use.
  final PulseTransport transport;

  /// The local storage used to queue events.
  ///
  /// Defaults to [InMemoryPulseStorage]. Provide a persistent implementation
  /// to ensure events survive application restarts.
  final PulseStorage? storage;

  /// The maximum number of events to hold in the queue.
  ///
  /// Defaults to 100. When exceeded, the oldest events are dropped.
  final int maxQueueSize;

  /// The privacy and sanitization rules.
  ///
  /// Passed to the default sanitizer to configure redaction logic.
  final PulseSanitizationConfig sanitization;

  /// The network telemetry configuration.
  ///
  /// Governs capture controls for URL redaction, payloads, headers, and sampling.
  final PulseNetworkConfig network;

  /// The performance telemetry configuration.
  ///
  /// Governs capture controls for transactions, spans, startup times, and sampling.
  final PulsePerformanceConfig performance;

  /// The sanitizer applied to every event before transport.
  ///
  /// Defaults to `null`, which causes the pipeline to automatically construct
  /// a [DefaultSanitizer] using the [sanitization] rules.
  /// Replace with a custom implementation if needed.
  final PulseSanitizer? sanitizer;

  /// The logger for SDK-internal diagnostics.
  ///
  /// Defaults to [NoOpLogger]. Provide a custom implementation to route
  /// SDK log output to your preferred logging system.
  final PulseLogger logger;

  /// The maximum number of breadcrumbs retained in memory.
  ///
  /// When the buffer is full, the oldest breadcrumb is evicted. Set to `0`
  /// to disable breadcrumb collection. Defaults to `100`.
  final int maxBreadcrumbs;

  /// Whether to automatically capture unhandled Dart errors and exceptions.
  ///
  /// When `true`, the SDK wraps the app in a `runZonedGuarded` zone via
  /// [Pulse.run] and captures any unhandled errors. Defaults to `true`.
  final bool captureUnhandledErrors;

  /// Whether to automatically capture Flutter framework errors.
  ///
  /// When `true`, the SDK replaces `FlutterError.onError` and captures
  /// widget tree and framework errors. The previous handler is still called.
  /// Defaults to `true`.
  final bool captureFlutterErrors;

  /// An ordered list of processors applied to every event before sanitization.
  ///
  /// Processors run in list order. A processor may return `null` to drop the
  /// event, or return a (possibly modified) event to continue the pipeline.
  ///
  /// Defaults to an empty list (no custom processors).
  final List<EventProcessor> processors;

  /// Creates a [PulseConfig].
  ///
  /// Only [dsn] is required. All other parameters have sensible defaults.
  const PulseConfig({
    required this.dsn,
    this.environment = 'production',
    this.release,
    this.debug = false,
    this.enabled = true,
    this.sampleRate = 1.0,
    this.sanitization = const PulseSanitizationConfig(),
    this.network = const PulseNetworkConfig.defaults(),
    this.performance = const PulsePerformanceConfig(),
    this.transport = const NoOpTransport(),
    this.storage,
    this.maxQueueSize = 100,
    this.sanitizer,
    this.logger = const NoOpLogger(),
    this.maxBreadcrumbs = 100,
    this.captureUnhandledErrors = true,
    this.captureFlutterErrors = true,
    this.processors = const [],
  })  : assert(maxBreadcrumbs >= 0, 'maxBreadcrumbs must be non-negative'),
        assert(maxQueueSize > 0, 'maxQueueSize must be positive'),
        assert(sampleRate >= 0.0 && sampleRate <= 1.0,
            'sampleRate must be between 0.0 and 1.0');

  @override
  String toString() => 'PulseConfig('
      'environment: $environment, '
      'release: $release, '
      'debug: $debug, '
      'enabled: $enabled, '
      'sampleRate: $sampleRate, '
      'maxBreadcrumbs: $maxBreadcrumbs'
      ')';
}

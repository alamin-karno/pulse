import 'package:flutter/widgets.dart';
import 'package:pulse_dev/pulse_dev.dart';

import 'integrations/zone_error_integration.dart';
import 'pulse_client.dart';

/// The primary developer-facing interface to the Pulse SDK.
///
/// All methods are static. Initialize the SDK once at application startup
/// using [Pulse.initialize], then call capture methods from anywhere in
/// your app.
///
/// ## Initialization
///
/// ```dart
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///
///   await Pulse.initialize(
///     const PulseConfig(
///       dsn: 'https://your-key@ingest.example.com/1',
///       environment: 'production',
///       release: '1.0.0+1',
///     ),
///   );
///
///   Pulse.run(() => runApp(const MyApp()));
/// }
/// ```
///
/// ## Safety guarantees
///
/// - Calling any method before [initialize] is a **safe no-op** — no
///   exception is thrown, no crash occurs.
/// - [initialize] is **idempotent** — calling it twice logs a warning and
///   returns without re-initializing.
/// - No method on [Pulse] throws or propagates internal SDK errors.
abstract final class Pulse {
  static PulseClient? _client;

  /// Whether the SDK has been initialized.
  ///
  /// `true` after [initialize] completes successfully.
  static bool get isInitialized => _client != null;

  /// Initializes the Pulse SDK with the given [config].
  ///
  /// Must be called before [WidgetsFlutterBinding.ensureInitialized] has
  /// been called. Call this once at the start of your `main` function.
  ///
  /// Calling [initialize] when [isInitialized] is `true` logs a warning
  /// and returns immediately without re-initializing.
  static Future<void> initialize(PulseConfig config) async {
    if (_client != null) {
      config.logger.log(
        PulseLogLevel.warning,
        'Pulse.initialize() called more than once. '
        'The SDK is already initialized. Ignoring.',
      );
      return;
    }

    if (!config.enabled) {
      config.logger.log(
        PulseLogLevel.info,
        'Pulse SDK is disabled via PulseConfig.enabled = false.',
      );
      return;
    }

    _client = PulseClient.create(config);

    config.logger.log(
      PulseLogLevel.info,
      'Pulse SDK initialized. '
      'Environment: ${config.environment}, '
      'Release: ${config.release ?? "unset"}.',
    );
  }

  /// Captures an exception and sends it through the event pipeline.
  ///
  /// [exception] may be any [Object] — [Exception], [Error], or custom type.
  /// [stackTrace] is strongly recommended; use `StackTrace.current` if the
  /// natural stack trace is unavailable.
  ///
  /// ```dart
  /// try {
  ///   await loadUserProfile();
  /// } catch (e, st) {
  ///   Pulse.captureException(e, stackTrace: st);
  /// }
  /// ```
  static void captureException(
    Object exception, {
    StackTrace? stackTrace,
  }) {
    _client?.captureException(exception, stackTrace: stackTrace);
  }

  /// Captures a Dart [Error] and sends it through the event pipeline.
  ///
  /// Use this method for [Error] subclasses (e.g., `AssertionError`,
  /// `RangeError`). For [Exception]s and general thrown objects, prefer
  /// [captureException].
  ///
  /// ```dart
  /// try {
  ///   riskyOperation();
  /// } on Error catch (e, st) {
  ///   Pulse.captureError(e, stackTrace: st);
  /// }
  /// ```
  static void captureError(
    Object error, {
    StackTrace? stackTrace,
  }) {
    _client?.captureError(error, stackTrace: stackTrace);
  }

  /// Adds a breadcrumb to the in-memory buffer.
  ///
  /// Breadcrumbs are attached to subsequent [ErrorEvent]s and
  /// [ExceptionEvent]s to provide context about what happened before
  /// the error.
  ///
  /// ```dart
  /// Pulse.addBreadcrumb(
  ///   'User tapped checkout',
  ///   category: 'ui.action',
  ///   data: {'screen': 'CartScreen', 'item_count': 3},
  /// );
  /// ```
  static void addBreadcrumb(
    String message, {
    String? category,
    BreadcrumbLevel level = BreadcrumbLevel.info,
    Map<String, dynamic>? data,
  }) {
    _client?.addBreadcrumb(
      message,
      category: category,
      level: level,
      data: data,
    );
  }

  /// Captures a custom analytics-style event.
  ///
  /// Use [track] to record business-level events such as user actions,
  /// feature usage, or conversion funnels.
  ///
  /// [name] should be lowercase with underscores (e.g., `'payment_initiated'`).
  /// [properties] must contain JSON-serializable values. Sensitive keys are
  /// automatically redacted by the configured [PulseSanitizer].
  ///
  /// ```dart
  /// Pulse.track(
  ///   'payment_initiated',
  ///   properties: {'amount': 99.99, 'currency': 'USD'},
  /// );
  /// ```
  static void track(
    String name, {
    Map<String, dynamic>? properties,
  }) {
    _client?.track(name, properties: properties);
  }

  /// Tracks a custom performance transaction.
  ///
  /// ```dart
  /// final tx = Pulse.startTransaction('load_dashboard');
  /// try {
  ///   await loadData();
  ///   tx.finish();
  /// } catch (e) {
  ///   tx.finish(error: e);
  /// }
  /// ```
  ///
  /// Returns a No-Op transaction if the SDK is uninitialized, disabled,
  /// or if the transaction is dropped due to sampling configuration.
  static PulseTransaction startTransaction(String name) {
    if (_client == null || !isInitialized) {
      return PulseTransaction.noOp(name);
    }
    return _client!.startTransaction(name);
  }

  /// Runs [body] inside a zone that captures unhandled errors.
  ///
  /// Wrap your `runApp` call with this method to automatically capture
  /// errors that escape the Flutter framework:
  ///
  /// ```dart
  /// Pulse.run(() => runApp(const MyApp()));
  /// ```
  ///
  /// This method is safe to call before [initialize] — unhandled errors
  /// will be captured if the SDK initializes before they occur.
  static void run(void Function() body) {
    ZoneErrorIntegration.run(body, _client);
  }

  /// The network observer, used by adapters to dispatch [NetworkEvent]s.
  ///
  /// Returns `null` if the SDK is not initialized.
  static PulseNetworkObserver? get network => _client?.networkObserver;

  /// Flushes pending events and shuts down the SDK.
  ///
  /// After calling [close], [isInitialized] returns `false` and all
  /// capture methods become no-ops. You may re-initialize by calling
  /// [initialize] again.
  static Future<void> close() async {
    await _client?.close();
    _client = null;
  }

  /// The underlying [PulseClient], exposed for advanced testing only.
  ///
  /// Do not use this in production code.
  @visibleForTesting
  static PulseClient? get testClient => _client;

  /// Resets the SDK to an uninitialized state.
  ///
  /// For use in tests only. Equivalent to calling [close] but synchronous.
  @visibleForTesting
  static void reset() {
    _client = null;
  }
}

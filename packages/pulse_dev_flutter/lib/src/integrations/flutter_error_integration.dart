import 'package:flutter/foundation.dart';

import '../pulse_client.dart';

/// Captures Flutter framework errors by hooking into [FlutterError.onError].
///
/// When installed, this integration replaces [FlutterError.onError] with
/// its own handler. The **previous handler is always called** after the
/// Pulse handler runs, ensuring no existing error reporting is disrupted.
///
/// Install via [install] and remove via [uninstall]. Both are idempotent.
///
/// This integration is installed automatically when
/// [PulseConfig.captureFlutterErrors] is `true` (the default).
final class FlutterErrorIntegration {
  final PulseClient _client;
  FlutterExceptionHandler? _previousHandler;
  bool _installed = false;

  /// Creates a [FlutterErrorIntegration] that reports errors via [client].
  FlutterErrorIntegration(this._client);

  /// Installs this integration by replacing [FlutterError.onError].
  ///
  /// Safe to call multiple times — subsequent calls are no-ops.
  void install() {
    if (_installed) return;
    _previousHandler = FlutterError.onError;
    FlutterError.onError = _handleError;
    _installed = true;
  }

  /// Uninstalls this integration and restores the previous error handler.
  ///
  /// Safe to call multiple times — subsequent calls are no-ops.
  void uninstall() {
    if (!_installed) return;
    FlutterError.onError = _previousHandler;
    _previousHandler = null;
    _installed = false;
  }

  void _handleError(FlutterErrorDetails details) {
    // Always call the previous handler — do not suppress it.
    _previousHandler?.call(details);

    _client.captureException(
      details.exception,
      stackTrace: details.stack,
      handled: false,
    );
  }
}

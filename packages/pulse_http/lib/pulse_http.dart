import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:pulse_dev/pulse_dev.dart';

/// A wrapper around [http.Client] that automatically captures network requests
/// and sends them to the Pulse pipeline as [NetworkEvent]s.
///
/// Ensure that Pulse is initialized and [observer] is provided.
///
/// ```dart
/// final innerClient = http.Client();
/// final observer = Pulse.network;
/// final client = observer != null
///   ? PulseHttpClient(innerClient, observer: observer)
///   : innerClient;
/// ```
class PulseHttpClient extends http.BaseClient {
  final http.Client _inner;
  final PulseNetworkObserver observer;

  /// Creates a [PulseHttpClient] wrapping [_inner].
  PulseHttpClient(this._inner, {required this.observer});

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final startTime = DateTime.now();
    final method = request.method;
    final url = request.url.toString();

    int? requestSize = request.contentLength;

    http.StreamedResponse response;
    try {
      response = await _inner.send(request);
    } catch (e) {
      final duration = DateTime.now().difference(startTime);
      observer.capture(
        method: method,
        url: url,
        duration: duration,
        success: false,
        requestSize: requestSize,
        errorCategory: _guessErrorCategory(e),
        requestHeaders: request.headers,
      );
      rethrow;
    }

    final duration = DateTime.now().difference(startTime);
    final statusCode = response.statusCode;
    final success = statusCode >= 200 && statusCode < 400;

    String? errorCategory;
    if (!success) {
      if (statusCode >= 500) {
        errorCategory = 'server_error';
      } else if (statusCode >= 400) {
        errorCategory = 'client_error';
      }
    }

    // Note: Streamed requests/responses do not easily expose bodies without
    // fully reading the streams, which alters the standard HTTP client behavior
    // and consumes excessive memory. Thus, we omit bodies for package:http.
    observer.capture(
      method: method,
      url: url,
      duration: duration,
      success: success,
      statusCode: statusCode,
      requestSize: requestSize,
      responseSize: response.contentLength,
      errorCategory: errorCategory,
      requestHeaders: request.headers,
      responseHeaders: response.headers,
    );

    return response;
  }

  @override
  void close() => _inner.close();

  String _guessErrorCategory(Object error) {
    final str = error.toString().toLowerCase();
    if (str.contains('timeout')) {
      return 'timeout';
    }
    if (str.contains('socket') || str.contains('connection')) {
      return 'connection';
    }
    return 'unknown';
  }
}

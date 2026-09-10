import 'package:dio/dio.dart';
import 'package:pulse_dev/pulse_dev.dart';

/// A [Interceptor] for [Dio] that automatically captures network requests
/// and sends them to the Pulse pipeline as [NetworkEvent]s.
///
/// Ensure that Pulse is initialized and [observer] is provided.
///
/// ```dart
/// final dio = Dio();
/// final observer = Pulse.network;
/// if (observer != null) {
///   dio.interceptors.add(PulseDioInterceptor(observer: observer));
/// }
/// ```
class PulseDioInterceptor extends Interceptor {
  /// The network observer that constructs and dispatches [NetworkEvent]s.
  final PulseNetworkObserver observer;

  /// Holds the start time for each request, keyed by the request object.
  final Map<RequestOptions, DateTime> _startTimes = {};

  /// Creates a [PulseDioInterceptor].
  PulseDioInterceptor({required this.observer});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _startTimes[options] = DateTime.now();
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _capture(
      options: response.requestOptions,
      response: response,
    );
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _capture(
      options: err.requestOptions,
      response: err.response,
      error: err,
    );
    super.onError(err, handler);
  }

  void _capture({
    required RequestOptions options,
    Response? response,
    DioException? error,
  }) {
    final startTime = _startTimes.remove(options);
    if (startTime == null) return;

    final duration = DateTime.now().difference(startTime);

    final method = options.method.toUpperCase();
    final url = options.uri.toString();
    final statusCode = response?.statusCode;

    // Convert headers safely
    Map<String, String>? reqHeaders;
    if (options.headers.isNotEmpty) {
      reqHeaders =
          options.headers.map((key, value) => MapEntry(key, value.toString()));
    }

    Map<String, String>? resHeaders;
    if (response?.headers != null) {
      resHeaders = {};
      response!.headers.forEach((key, values) {
        resHeaders![key] = values.join(', ');
      });
    }

    // Attempt to guess request/response sizes (approximate, since Dio doesn't give raw bytes easily)
    int? requestSize;
    if (options.data is String) {
      requestSize = (options.data as String).length;
    } else if (options.data is List<int>) {
      requestSize = (options.data as List<int>).length;
    }

    int? responseSize;
    if (response?.data is String) {
      responseSize = (response?.data as String).length;
    } else if (response?.data is List<int>) {
      responseSize = (response?.data as List<int>).length;
    }

    bool success = statusCode != null && statusCode >= 200 && statusCode < 400;
    if (error != null) {
      success = false;
    }

    String? errorCategory;
    if (error != null) {
      errorCategory = _mapDioErrorType(error.type);
    } else if (!success && statusCode != null) {
      if (statusCode >= 500) {
        errorCategory = 'server_error';
      } else if (statusCode >= 400) {
        errorCategory = 'client_error';
      }
    }

    observer.capture(
      method: method,
      url: url,
      duration: duration,
      success: success,
      statusCode: statusCode,
      requestSize: requestSize,
      responseSize: responseSize,
      errorCategory: errorCategory,
      requestHeaders: reqHeaders,
      responseHeaders: resHeaders,
      requestBody: options.data,
      responseBody: response?.data,
    );
  }

  String _mapDioErrorType(DioExceptionType type) {
    switch (type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'timeout';
      case DioExceptionType.badCertificate:
        return 'security';
      case DioExceptionType.badResponse:
        return 'server';
      case DioExceptionType.cancel:
        return 'cancelled';
      case DioExceptionType.connectionError:
        return 'connection';
      case DioExceptionType.unknown:
      default:
        return 'unknown';
    }
  }
}

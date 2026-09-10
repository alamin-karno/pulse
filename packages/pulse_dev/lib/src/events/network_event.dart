part of 'pulse_event.dart';

/// Represents an HTTP network request and response.
///
/// Captured by a `PulseNetworkObserver` or an integration like
/// `pulse_dio` / `pulse_http`.
@immutable
final class NetworkEvent extends PulseEvent {
  /// The HTTP method (e.g., 'GET', 'POST').
  final String method;

  /// The requested URL.
  ///
  /// Sensitive query parameters should be redacted prior to creating this event.
  final String url;

  /// The HTTP status code returned by the server (e.g., 200, 404, 500).
  ///
  /// Null if the request failed before a response was received (e.g., timeout).
  final int? statusCode;

  /// The duration of the network request.
  final Duration duration;

  /// The size of the request body in bytes, if available.
  final int? requestSize;

  /// The size of the response body in bytes, if available.
  final int? responseSize;

  /// Whether the request was successful.
  ///
  /// Typically `true` for 2xx and 3xx status codes, `false` otherwise.
  final bool success;

  /// A generalized category of the error if the request failed.
  ///
  /// Examples: 'timeout', 'connection', 'dns', 'server', 'client'.
  final String? errorCategory;

  /// The request HTTP headers.
  ///
  /// Only populated if explicitly enabled in configuration.
  final Map<String, String>? requestHeaders;

  /// The response HTTP headers.
  ///
  /// Only populated if explicitly enabled in configuration.
  final Map<String, String>? responseHeaders;

  /// The request body.
  ///
  /// Only populated if explicitly enabled in configuration and safe to capture.
  final Object? requestBody;

  /// The response body.
  ///
  /// Only populated if explicitly enabled in configuration and safe to capture.
  final Object? responseBody;

  /// Creates a [NetworkEvent].
  const NetworkEvent({
    required super.id,
    required super.timestamp,
    required super.sdkVersion,
    required super.appVersion,
    required super.environment,
    required super.platform,
    required super.context,
    required this.method,
    required this.url,
    required this.duration,
    required this.success,
    super.schemaVersion,
    this.statusCode,
    this.requestSize,
    this.responseSize,
    this.errorCategory,
    this.requestHeaders,
    this.responseHeaders,
    this.requestBody,
    this.responseBody,
  }) : super(type: PulseEventType.network);

  @override
  Map<String, dynamic> toJson() {
    return {
      ...baseJson(),
      'method': method,
      'url': url,
      'duration_ms': duration.inMilliseconds,
      'success': success,
      if (statusCode != null) 'status_code': statusCode,
      if (requestSize != null) 'request_size': requestSize,
      if (responseSize != null) 'response_size': responseSize,
      if (errorCategory != null) 'error_category': errorCategory,
      if (requestHeaders != null) 'request_headers': requestHeaders,
      if (responseHeaders != null) 'response_headers': responseHeaders,
      if (requestBody != null) 'request_body': requestBody,
      if (responseBody != null) 'response_body': responseBody,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NetworkEvent &&
        other.id == id &&
        other.method == method &&
        other.url == url &&
        other.duration == duration &&
        other.success == success;
  }

  @override
  int get hashCode => Object.hash(id, method, url, duration, success);
}

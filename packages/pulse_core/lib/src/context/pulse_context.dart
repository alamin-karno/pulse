import 'package:meta/meta.dart';

/// An immutable snapshot of device and application metadata at the time
/// an event was captured.
///
/// [PulseContext] is a pure data class defined in `pulse_core`. It is
/// populated by `pulse_flutter`'s `FlutterContextCollector` for Flutter
/// applications, and may be constructed manually for pure Dart usage.
///
/// Use [PulseContext.empty] when no context is available.
@immutable
final class PulseContext {
  /// The device model identifier (e.g., `'iPhone 15'`, `'Pixel 8'`).
  final String? deviceModel;

  /// The device manufacturer (e.g., `'Apple'`, `'Google'`).
  final String? deviceManufacturer;

  /// The operating system name (e.g., `'iOS'`, `'Android'`, `'web'`).
  final String? osName;

  /// The operating system version string (e.g., `'17.0'`, `'14'`).
  final String? osVersion;

  /// The application bundle or package identifier.
  final String? appId;

  /// The human-readable application name.
  final String? appName;

  /// The application version string (e.g., `'1.2.3'`).
  final String? appVersion;

  /// The device locale (e.g., `'en_US'`, `'fr_FR'`).
  final String? locale;

  /// Additional platform-specific or application-specific metadata.
  ///
  /// Keys should be lowercase with underscores. Values must be JSON-serializable.
  final Map<String, dynamic> extra;

  /// Creates a [PulseContext] with the given metadata.
  const PulseContext({
    this.deviceModel,
    this.deviceManufacturer,
    this.osName,
    this.osVersion,
    this.appId,
    this.appName,
    this.appVersion,
    this.locale,
    this.extra = const {},
  });

  /// An empty [PulseContext] with no metadata.
  ///
  /// Used as a default when context cannot be collected (e.g., in pure Dart
  /// environments without access to device APIs).
  static const empty = PulseContext();

  /// Serializes this context to a JSON-compatible map.
  Map<String, dynamic> toJson() => {
        if (deviceModel != null) 'device_model': deviceModel,
        if (deviceManufacturer != null)
          'device_manufacturer': deviceManufacturer,
        if (osName != null) 'os_name': osName,
        if (osVersion != null) 'os_version': osVersion,
        if (appId != null) 'app_id': appId,
        if (appName != null) 'app_name': appName,
        if (appVersion != null) 'app_version': appVersion,
        if (locale != null) 'locale': locale,
        if (extra.isNotEmpty) 'extra': extra,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PulseContext &&
          runtimeType == other.runtimeType &&
          deviceModel == other.deviceModel &&
          deviceManufacturer == other.deviceManufacturer &&
          osName == other.osName &&
          osVersion == other.osVersion &&
          appId == other.appId &&
          appName == other.appName &&
          appVersion == other.appVersion &&
          locale == other.locale;

  @override
  int get hashCode => Object.hash(
        deviceModel,
        deviceManufacturer,
        osName,
        osVersion,
        appId,
        appName,
        appVersion,
        locale,
      );

  @override
  String toString() => 'PulseContext('
      'osName: $osName, '
      'osVersion: $osVersion, '
      'deviceModel: $deviceModel'
      ')';
}

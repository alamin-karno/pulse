import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:pulse_core/pulse_core.dart';

/// Collects device and application metadata from Flutter platform APIs.
///
/// This class bridges the gap between Flutter's platform APIs and
/// `pulse_core`'s Flutter-free [PulseContext] data class.
///
/// Called once during [Pulse.initialize] to create a context snapshot
/// that is attached to every subsequent event.
abstract final class FlutterContextCollector {
  /// Collects the current platform and device context.
  ///
  /// [appVersion] is typically sourced from [PulseConfig.release].
  ///
  /// This method is safe to call from the main isolate after
  /// [WidgetsFlutterBinding.ensureInitialized] has been called.
  static PulseContext collect({String? appVersion}) {
    final osName = _resolveOsName();
    final osVersion = _resolveOsVersion();

    return PulseContext(
      osName: osName,
      osVersion: osVersion,
      appVersion: appVersion,
      locale: PlatformDispatcher.instance.locale.toString(),
    );
  }

  static String? _resolveOsName() {
    if (kIsWeb) return 'web';
    if (Platform.isAndroid) return 'Android';
    if (Platform.isIOS) return 'iOS';
    if (Platform.isMacOS) return 'macOS';
    if (Platform.isWindows) return 'Windows';
    if (Platform.isLinux) return 'Linux';
    return null;
  }

  static String? _resolveOsVersion() {
    if (kIsWeb) return null;
    try {
      return Platform.operatingSystemVersion;
    } catch (_) {
      return null;
    }
  }
}

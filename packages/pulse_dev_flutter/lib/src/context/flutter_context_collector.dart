import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' show WidgetsFlutterBinding;
import 'package:pulse_dev/pulse_dev.dart';

import '../pulse.dart' show Pulse;
import 'os_version.dart' as os_version;

/// Collects device and application metadata from Flutter platform APIs.
///
/// This class bridges the gap between Flutter's platform APIs and
/// `pulse_dev`'s Flutter-free [PulseContext] data class.
///
/// Called once during [Pulse.initialize] to create a context snapshot
/// that is attached to every subsequent event.
///
/// Fully compatible with Flutter Web: OS name resolves via
/// [defaultTargetPlatform] and OS version resolves to `null` (no
/// equivalent API exists in a browser).
abstract final class FlutterContextCollector {
  /// Collects the current platform and device context.
  ///
  /// [appVersion] is typically sourced from [PulseConfig.release].
  ///
  /// This method is safe to call from the main isolate after
  /// [WidgetsFlutterBinding.ensureInitialized] has been called.
  static PulseContext collect({String? appVersion}) {
    return PulseContext(
      osName: _resolveOsName(),
      osVersion: kIsWeb ? null : os_version.resolveOsVersion(),
      appVersion: appVersion,
      locale: PlatformDispatcher.instance.locale.toString(),
    );
  }

  static String? _resolveOsName() {
    if (kIsWeb) return 'web';
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'Android';
      case TargetPlatform.iOS:
        return 'iOS';
      case TargetPlatform.macOS:
        return 'macOS';
      case TargetPlatform.windows:
        return 'Windows';
      case TargetPlatform.linux:
        return 'Linux';
      case TargetPlatform.fuchsia:
        return 'Fuchsia';
    }
  }
}

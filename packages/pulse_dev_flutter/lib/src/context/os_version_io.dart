import 'dart:io' show Platform;

/// Resolves the OS version string via `dart:io`'s [Platform].
String? resolveOsVersion() {
  try {
    return Platform.operatingSystemVersion;
  } catch (_) {
    return null;
  }
}

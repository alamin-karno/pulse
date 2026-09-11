/// Fallback OS version resolver for platforms without `dart:io`
/// (currently: Flutter Web, where no equivalent API exists).
String? resolveOsVersion() => null;

// ignore_for_file: sort_constructors_first

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'inspector_state.dart';
import 'views/inspector_home_view.dart';

/// A wrapper widget that provides a floating button to access the
/// Pulse Debug Inspector.
///
/// Use [PulseInspector.builder] with `MaterialApp.builder` to inject
/// the inspector over all application routes.
///
/// In release mode (`kReleaseMode == true`), this widget evaluates to a
/// simple pass-through and has near-zero overhead.
class PulseInspector extends StatefulWidget {
  /// The child widget, typically the application's Navigator.
  final Widget child;

  /// Whether the inspector floating button is visible.
  final bool enabled;

  /// Creates a [PulseInspector] wrapping [child].
  ///
  /// Prefer [PulseInspector.builder] for typical `MaterialApp.builder` usage
  /// rather than constructing this widget directly.
  const PulseInspector({
    super.key,
    required this.child,
    this.enabled = true,
  });

  /// A builder function for `MaterialApp.builder`.
  ///
  /// ```dart
  /// MaterialApp(
  ///   builder: PulseInspector.builder(),
  ///   home: MyHomePage(),
  /// )
  /// ```
  static Widget Function(BuildContext, Widget?) builder({bool enabled = true}) {
    return (BuildContext context, Widget? child) {
      if (child == null) return const SizedBox.shrink();
      return PulseInspector(
        enabled: enabled,
        child: child,
      );
    };
  }

  @override
  State<PulseInspector> createState() => _PulseInspectorState();
}

class _PulseInspectorState extends State<PulseInspector> {
  Offset _position = const Offset(20, 100);
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    if (widget.enabled && !kReleaseMode) {
      InspectorState.instance.start();
    }
  }

  @override
  void didUpdateWidget(PulseInspector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!kReleaseMode) {
      if (widget.enabled && !oldWidget.enabled) {
        InspectorState.instance.start();
      } else if (!widget.enabled && oldWidget.enabled) {
        InspectorState.instance.stop();
      }
    }
  }

  @override
  void dispose() {
    if (!kReleaseMode) {
      InspectorState.instance.stop();
    }
    super.dispose();
  }

  void _openInspector() {
    setState(() {
      _isExpanded = true;
    });
  }

  void _closeInspector() {
    setState(() {
      _isExpanded = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 0 overhead in release mode.
    if (kReleaseMode || !widget.enabled) {
      return widget.child;
    }

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        children: [
          widget.child,
          if (_isExpanded)
            Positioned.fill(
              child: Material(
                child: HeroControllerScope.none(
                  child: Navigator(
                    onGenerateRoute: (_) => MaterialPageRoute<void>(
                      builder: (context) => InspectorHomeView(
                        onClose: _closeInspector,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          if (!_isExpanded)
            Positioned(
              left: _position.dx,
              top: _position.dy,
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    _position += details.delta;
                  });
                },
                onTap: _openInspector,
                child: Material(
                  elevation: 6,
                  shape: const CircleBorder(),
                  color: Colors.black87,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.monitor_heart,
                        color: Colors.greenAccent,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

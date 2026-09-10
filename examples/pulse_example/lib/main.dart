import 'package:flutter/material.dart';
import 'package:pulse_dev_flutter/pulse_dev_flutter.dart';

/// Pulse SDK Example Application
///
/// This app demonstrates every Phase 1 feature of the Pulse SDK:
/// - Initialization with PulseConfig
/// - Automatic unhandled error capture via Pulse.run()
/// - Manual exception capture
/// - Breadcrumb recording
/// - Custom event tracking
///
/// A [DebugTransport] is used here so events are printed to the console
/// rather than sent to a real backend.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Pulse.initialize(
    PulseConfig(
      dsn: 'https://example-key@ingest.example.com/demo-project',
      environment: 'development',
      release: '1.0.0+1',
      debug: true,
      transport: DebugTransport(),
      maxBreadcrumbs: 50,
    ),
  );

  // Pulse.run wraps the app in a zone that captures unhandled async errors.
  Pulse.run(() => runApp(const PulseExampleApp()));
}

/// A transport that prints events to the console for demonstration purposes.
///
/// Replace this with a real HTTP transport in production.
final class DebugTransport implements PulseTransport {
  @override
  Future<void> send(PulseEvent event) async {
    final json = event.toJson();
    debugPrint('──────────────────────────────────────────');
    debugPrint('[Pulse] Event sent:');
    debugPrint('  type      : ${json['type']}');
    debugPrint('  id        : ${json['id']}');
    debugPrint('  timestamp : ${json['timestamp']}');
    if (json.containsKey('name')) {
      debugPrint('  name      : ${json['name']}');
    }
    if (json.containsKey('message')) {
      debugPrint('  message   : ${json['message']}');
    }
    if (json.containsKey('exception_type')) {
      debugPrint('  type      : ${json['exception_type']}');
    }
    debugPrint('──────────────────────────────────────────');
  }

  @override
  Future<void> close() async {}
}

/// Root widget of the example app.
class PulseExampleApp extends StatelessWidget {
  const PulseExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pulse Example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ExampleHomePage(),
    );
  }
}

/// The main demonstration screen.
class ExampleHomePage extends StatefulWidget {
  const ExampleHomePage({super.key});

  @override
  State<ExampleHomePage> createState() => _ExampleHomePageState();
}

class _ExampleHomePageState extends State<ExampleHomePage> {
  final List<String> _log = [];

  void _appendLog(String message) {
    setState(() => _log.add(message));
  }

  void _captureException() {
    Pulse.addBreadcrumb(
      'User tapped Capture Exception',
      category: 'ui.action',
      data: {'screen': 'ExampleHomePage'},
    );
    try {
      throw FormatException('Simulated format error for demonstration');
    } catch (e, st) {
      Pulse.captureException(e, stackTrace: st);
      _appendLog('✅ captureException: ${e.runtimeType}');
    }
  }

  void _captureError() {
    Pulse.addBreadcrumb(
      'User tapped Capture Error',
      category: 'ui.action',
    );
    try {
      final list = <int>[];
      // ignore: avoid_print
      print(list[99]); // Triggers RangeError
    } on Error catch (e, st) {
      Pulse.captureError(e, stackTrace: st);
      _appendLog('✅ captureError: ${e.runtimeType}');
    }
  }

  void _addBreadcrumb() {
    Pulse.addBreadcrumb(
      'User tapped Add Breadcrumb',
      category: 'ui.action',
      data: {'timestamp': DateTime.now().toIso8601String()},
    );
    _appendLog('✅ addBreadcrumb recorded');
  }

  void _trackEvent() {
    Pulse.track(
      'demo_button_tapped',
      properties: {
        'screen': 'ExampleHomePage',
        'button': 'track_event',
        'count': _log.length,
      },
    );
    _appendLog('✅ track: demo_button_tapped');
  }

  void _triggerUnhandled() {
    Pulse.addBreadcrumb('About to trigger unhandled async error');
    // This error escapes the zone and is captured automatically
    Future<void>.error(
      StateError('Simulated unhandled async error'),
      StackTrace.current,
    );
    _appendLog('✅ Unhandled async error triggered — check console');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pulse SDK Example'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _DemoButton(
                  label: 'Capture Exception',
                  onPressed: _captureException,
                ),
                _DemoButton(
                  label: 'Capture Error',
                  onPressed: _captureError,
                ),
                _DemoButton(
                  label: 'Add Breadcrumb',
                  onPressed: _addBreadcrumb,
                ),
                _DemoButton(
                  label: 'Track Event',
                  onPressed: _trackEvent,
                ),
                _DemoButton(
                  label: 'Unhandled Error',
                  onPressed: _triggerUnhandled,
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _log.length,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  _log[_log.length - 1 - index],
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DemoButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _DemoButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(label),
    );
  }
}

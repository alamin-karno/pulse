import 'package:flutter/material.dart';
import 'package:pulse_dev_flutter/pulse_dev_flutter.dart';

/// Runs the Pulse Flutter usage example.
///
/// Demonstrates SDK initialization, error/breadcrumb/custom-event capture,
/// and the in-app Debug Inspector overlay described in the package README.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Pulse.initialize(
    const PulseConfig(
      dsn: 'https://your-key@ingest.example.com/your-project-id',
      environment: 'development',
      release: '1.0.0+1',
    ),
  );

  Pulse.run(() => runApp(const PulseExampleApp()));
}

/// A minimal Flutter app demonstrating the Pulse SDK's public API.
class PulseExampleApp extends StatelessWidget {
  /// Creates the example app.
  const PulseExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: PulseInspector.builder(),
      home: const _ExampleHomePage(),
    );
  }
}

class _ExampleHomePage extends StatelessWidget {
  const _ExampleHomePage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pulse example')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () {
                Pulse.addBreadcrumb('User tapped capture button');
                try {
                  throw StateError('Example error for Pulse');
                } catch (error, stackTrace) {
                  Pulse.captureException(error, stackTrace: stackTrace);
                }
              },
              child: const Text('Capture an example exception'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Pulse.track(
                'example_button_tapped',
                properties: const {'source': 'example_app'},
              ),
              child: const Text('Track a custom event'),
            ),
          ],
        ),
      ),
    );
  }
}

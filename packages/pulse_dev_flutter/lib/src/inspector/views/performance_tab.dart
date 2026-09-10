// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/material.dart';

import '../inspector_state.dart';
import 'event_detail_view.dart';

class PerformanceTab extends StatelessWidget {
  const PerformanceTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: InspectorState.instance,
      builder: (context, _) {
        final performance = InspectorState.instance.performanceEvents;

        if (performance.isEmpty) {
          return const Center(
              child: Text('No performance transactions captured yet.'));
        }

        return ListView.builder(
          itemCount: performance.length,
          itemBuilder: (context, index) {
            final event = performance[index];
            final isError = event.status == 'error';

            return ListTile(
              leading: Icon(
                Icons.speed,
                color: isError ? Colors.red : Colors.blue,
              ),
              title: Text(event.name),
              subtitle: Text(
                '${event.duration.inMilliseconds}ms | '
                '${event.spans.length} spans | '
                '${event.status}',
              ),
              trailing: Text(
                '${event.timestamp.hour}:${event.timestamp.minute.toString().padLeft(2, '0')}:${event.timestamp.second.toString().padLeft(2, '0')}',
                style: const TextStyle(fontSize: 12),
              ),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute<void>(
                  builder: (context) => EventDetailView(
                    event: event,
                    title: 'Transaction Details',
                  ),
                ));
              },
            );
          },
        );
      },
    );
  }
}

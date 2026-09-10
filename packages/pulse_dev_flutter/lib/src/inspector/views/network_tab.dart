// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/material.dart';

import '../inspector_state.dart';
import 'event_detail_view.dart';

class NetworkTab extends StatelessWidget {
  const NetworkTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: InspectorState.instance,
      builder: (context, _) {
        final network = InspectorState.instance.networkEvents;

        if (network.isEmpty) {
          return const Center(child: Text('No network events captured yet.'));
        }

        return ListView.builder(
          itemCount: network.length,
          itemBuilder: (context, index) {
            final event = network[index];
            final bool isError =
                (event.statusCode != null && event.statusCode! >= 400) ||
                    !event.success;

            return ListTile(
              leading: Icon(
                Icons.network_check,
                color: isError ? Colors.red : Colors.green,
              ),
              title: Text(
                '${event.method.toUpperCase()} ${Uri.tryParse(event.url)?.path ?? event.url}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                'Status: ${event.statusCode ?? "Unknown"} | '
                '${event.duration.inMilliseconds}ms',
              ),
              trailing: Text(
                '${event.timestamp.hour}:${event.timestamp.minute.toString().padLeft(2, '0')}:${event.timestamp.second.toString().padLeft(2, '0')}',
                style: const TextStyle(fontSize: 12),
              ),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute<void>(
                  builder: (context) => EventDetailView(
                    event: event,
                    title: 'Network Details',
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

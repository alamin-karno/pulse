// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/material.dart';
import 'package:pulse_dev/pulse_dev.dart';

import '../inspector_state.dart';
import 'event_detail_view.dart';

class ErrorTab extends StatelessWidget {
  const ErrorTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: InspectorState.instance,
      builder: (context, _) {
        final state = InspectorState.instance;
        final List<PulseEvent> errors = [
          ...state.errors,
          ...state.exceptions,
        ]..sort((a, b) => b.timestamp.compareTo(a.timestamp));

        if (errors.isEmpty) {
          return const Center(child: Text('No errors captured yet.'));
        }

        return ListView.builder(
          itemCount: errors.length,
          itemBuilder: (context, index) {
            final event = errors[index];
            final isException = event is ExceptionEvent;

            String title = 'Unknown Error';
            String message = '';

            if (event is ExceptionEvent) {
              title = event.exceptionType;
              message = event.message;
            } else if (event is ErrorEvent) {
              title = event.errorType;
              message = event.message;
            }

            return ListTile(
              leading: Icon(
                isException ? Icons.warning : Icons.error,
                color: isException ? Colors.orange : Colors.red,
              ),
              title: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                message,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Text(
                '${event.timestamp.hour}:${event.timestamp.minute.toString().padLeft(2, '0')}:${event.timestamp.second.toString().padLeft(2, '0')}',
                style: const TextStyle(fontSize: 12),
              ),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute<void>(
                  builder: (context) => EventDetailView(
                    event: event,
                    title: isException ? 'Exception Details' : 'Error Details',
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

// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/material.dart';
import 'package:pulse_dev/pulse_dev.dart';

import '../inspector_state.dart';
import 'event_detail_view.dart';

class BreadcrumbTab extends StatelessWidget {
  const BreadcrumbTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: InspectorState.instance,
      builder: (context, _) {
        final breadcrumbs = InspectorState.instance.breadcrumbs;

        if (breadcrumbs.isEmpty) {
          return const Center(child: Text('No breadcrumbs captured yet.'));
        }

        return ListView.builder(
          itemCount: breadcrumbs.length,
          itemBuilder: (context, index) {
            final event = breadcrumbs[index];

            IconData icon;
            Color color;
            switch (event.level) {
              case BreadcrumbLevel.debug:
                icon = Icons.bug_report;
                color = Colors.grey;
                break;
              case BreadcrumbLevel.info:
                icon = Icons.info;
                color = Colors.blue;
                break;
              case BreadcrumbLevel.warning:
                icon = Icons.warning;
                color = Colors.orange;
                break;
              case BreadcrumbLevel.error:
                icon = Icons.error;
                color = Colors.red;
                break;
            }

            return ListTile(
              leading: Icon(icon, color: color),
              title: Text(event.message),
              subtitle: Text(event.category ?? 'default'),
              trailing: Text(
                '${event.timestamp.hour}:${event.timestamp.minute.toString().padLeft(2, '0')}:${event.timestamp.second.toString().padLeft(2, '0')}',
                style: const TextStyle(fontSize: 12),
              ),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute<void>(
                  builder: (context) => EventDetailView(
                    event: event,
                    title: 'Breadcrumb Details',
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

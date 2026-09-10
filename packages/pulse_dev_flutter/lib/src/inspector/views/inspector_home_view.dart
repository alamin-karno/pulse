// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/material.dart';

import '../inspector_state.dart';
import 'breadcrumb_tab.dart';
import 'error_tab.dart';
import 'network_tab.dart';
import 'performance_tab.dart';
import 'system_tab.dart';

class InspectorHomeView extends StatelessWidget {
  final VoidCallback? onClose;

  const InspectorHomeView({super.key, this.onClose});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Pulse Inspector'),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              tooltip: 'Clear Events',
              onPressed: () {
                InspectorState.instance.clear();
              },
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                if (onClose != null) {
                  onClose!();
                } else {
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Errors'),
              Tab(text: 'Breadcrumbs'),
              Tab(text: 'Network'),
              Tab(text: 'Performance'),
              Tab(text: 'System'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            ErrorTab(),
            BreadcrumbTab(),
            NetworkTab(),
            PerformanceTab(),
            SystemTab(),
          ],
        ),
      ),
    );
  }
}

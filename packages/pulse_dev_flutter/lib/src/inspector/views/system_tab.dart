// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/material.dart';

import '../../pulse.dart';

class SystemTab extends StatelessWidget {
  const SystemTab({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Pulse.isInitialized) {
      return const Center(child: Text('Pulse SDK is not initialized.'));
    }

    // ignore: invalid_use_of_visible_for_testing_member
    final client = Pulse.testClient;

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildSectionHeader('SDK Status'),
        _buildInfoRow('Initialized', Pulse.isInitialized ? 'Yes' : 'No'),
        _buildInfoRow('Internal Client Ready', client != null ? 'Yes' : 'No'),
        const Divider(),
        _buildSectionHeader('Buffer Usage'),
        // ignore: invalid_use_of_visible_for_testing_member
        _buildInfoRow('Breadcrumbs Buffer', '${client?.breadcrumbCount ?? 0}'),
        const Divider(),
        _buildSectionHeader('Integrations'),
        _buildInfoRow(
            'Network Observer', Pulse.network != null ? 'Active' : 'Inactive'),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Colors.blueGrey,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:chamDTech_nrcs/features/stories/views/widgets/nrcs_layout.dart';
import 'package:chamDTech_nrcs/core/constants/app_constants.dart';
import 'package:chamDTech_nrcs/features/rundowns/services/rundown_service.dart';
import 'package:chamDTech_nrcs/features/rundowns/models/rundown_model.dart';
import 'package:chamDTech_nrcs/app/routes/app_routes.dart';

class AnchorDashboardScreen extends StatelessWidget {
  const AnchorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final rundownService = Get.put(RundownService());

    return NRCSAppShell(
      title: 'Anchor Dashboard',
      toolbar: const NRCSToolbar(),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Active Rundowns',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: NRCSColors.topNavBlue,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Real-time feed of today\'s news rundowns.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: StreamBuilder<List<RundownModel>>(
                stream: rundownService.getActiveRundowns(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error loading rundowns: ${snapshot.error}'));
                  }

                  final rundowns = snapshot.data ?? [];

                  if (rundowns.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.view_list_outlined, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('No active rundowns scheduled for today.', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: rundowns.length,
                    itemBuilder: (context, index) {
                      final rundown = rundowns[index];
                      return Card(
                        elevation: 1,
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: CircleAvatar(
                            backgroundColor: _getStatusColor(rundown.status).withOpacity(0.1),
                            child: Icon(Icons.schedule, color: _getStatusColor(rundown.status)),
                          ),
                          title: Text(
                            rundown.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          subtitle: Row(
                            children: [
                              Text(DateFormat('hh:mm a').format(rundown.scheduledTime)),
                              const SizedBox(width: 16),
                              Icon(Icons.article, size: 14, color: NRCSColors.topNavBlue),
                              const SizedBox(width: 4),
                              Text('${rundown.storyIds.length} Stories'),
                            ],
                          ),
                          trailing: _buildStatusBadge(rundown.status),
                          onTap: () {
                            Get.toNamed(AppRoutes.rundownBuilder, arguments: rundown.id);
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final color = _getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'on-air':
        return Colors.red;
      case 'locked':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}

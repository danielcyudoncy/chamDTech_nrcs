import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:chamDTech_nrcs/features/rundowns/controllers/rundown_builder_controller.dart';
import 'package:chamDTech_nrcs/core/constants/app_constants.dart';
import 'package:chamDTech_nrcs/features/dashboard/controllers/producer_dashboard_controller.dart'; 
import 'package:chamDTech_nrcs/features/stories/views/widgets/nrcs_layout.dart';

class RundownBuilderScreen extends StatelessWidget {
  const RundownBuilderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final rundownId = Get.arguments as String?;
    if (rundownId == null) {
      return const Scaffold(body: Center(child: Text('Error: No rundown provided')));
    }

    final controller = Get.put(RundownBuilderController(rundownId: rundownId));
    // We get the producer controller to access the story pool easily
    final producerController = Get.find<ProducerDashboardController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Rundown Builder'),
        backgroundColor: NRCSColors.topNavBlue,
        foregroundColor: Colors.white,
        actions: [
          Obx(() {
            final rundown = controller.rundown.value;
            if (rundown == null) return const SizedBox.shrink();

            if (rundown.status == 'draft') {
              return ElevatedButton.icon(
                onPressed: () => controller.changeStatus('locked'),
                icon: const Icon(Icons.lock, color: Colors.orange),
                label: const Text('Lock Rundown', style: TextStyle(color: Colors.orange)),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
              );
            } else if (rundown.status == 'locked') {
              return ElevatedButton.icon(
                onPressed: () => controller.changeStatus('on-air'),
                icon: const Icon(Icons.live_tv, color: Colors.red),
                label: const Text('Mark On-Air', style: TextStyle(color: Colors.red)),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
              );
            } else if (rundown.status == 'on-air') {
              return ElevatedButton.icon(
                onPressed: () => controller.changeStatus('completed'),
                icon: const Icon(Icons.check_circle, color: Colors.green),
                label: const Text('Complete Show', style: TextStyle(color: Colors.green)),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
              );
            }
            return const SizedBox.shrink();
          }),
          const SizedBox(width: 16),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value || controller.rundown.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final rundown = controller.rundown.value!;
        final isDraft = rundown.status == 'draft';

        return Column(
          children: [
            // Status Header
            Container(
              padding: const EdgeInsets.all(16),
              color: NRCSColors.subNavGray,
              child: Row(
                children: [
                  Text(
                    rundown.name,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(rundown.status).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _getStatusColor(rundown.status)),
                    ),
                    child: Text(
                      rundown.status.toUpperCase(),
                      style: TextStyle(
                        color: _getStatusColor(rundown.status),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  _buildDurationMonitor(controller),
                ],
              ),
            ),

            // Main Content Area
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Pool of available stories (Left side)
                  if (isDraft)
                    Container(
                      width: 400,
                      decoration: BoxDecoration(
                        border: Border(right: BorderSide(color: NRCSColors.borderGray)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text(
                              'Ready-to-Air Pool',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              itemCount: producerController.readyToAirStories.length,
                              itemBuilder: (context, index) {
                                final story = producerController.readyToAirStories[index];
                                final isAlreadyAdded = rundown.storyIds.contains(story.id);

                                return ListTile(
                                  title: Text(story.title.isEmpty ? 'Untitled' : story.title),
                                  subtitle: Text('Duration: ${controller.formatDuration(story.duration)}'),
                                  trailing: isAlreadyAdded
                                    ? const Icon(Icons.check_circle, color: Colors.green)
                                    : IconButton(
                                        icon: const Icon(Icons.add_circle_outline, color: Color(0xFF0F3A66)), // Replaced with static color or extracted
                                        onPressed: () => controller.addStory(story),
                                      ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                  // The Rundown (Right side / Center)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'Show Order (${rundown.storyIds.length} Stories)',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          child: isDraft
                              ? ReorderableListView.builder(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  itemCount: controller.stories.length,
                                  onReorder: controller.reorderStories,
                                  itemBuilder: (context, index) {
                                    final story = controller.stories[index];
                                    return Card(
                                      key: ValueKey(story.id),
                                      margin: const EdgeInsets.only(bottom: 8),
                                      child: ListTile(
                                        leading: const Icon(Icons.drag_handle),
                                        title: Text(story.title.isEmpty ? 'Untitled' : story.title),
                                        subtitle: Text(story.deskId ?? 'Unknown Desk'),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              controller.formatDuration(story.duration),
                                              style: const TextStyle(fontWeight: FontWeight.bold),
                                            ),
                                            const SizedBox(width: 8),
                                            IconButton(
                                              icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                                              onPressed: () => controller.removeStory(story),
                                            )
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  itemCount: controller.stories.length,
                                  itemBuilder: (context, index) {
                                    final story = controller.stories[index];
                                    return Card(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      child: ListTile(
                                        leading: CircleAvatar(
                                          backgroundColor: const Color(0xFF0F3A66),
                                          child: Text('${index + 1}', style: const TextStyle(color: Colors.white)),
                                        ),
                                        title: Text(story.title.isEmpty ? 'Untitled' : story.title),
                                        subtitle: Text(story.deskId ?? 'Unknown Desk'),
                                        trailing: Text(
                                          controller.formatDuration(story.duration),
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                        ),
                                      ),
                                    );
                                  }
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildDurationMonitor(RundownBuilderController controller) {
    final rundown = controller.rundown.value!;
    final current = controller.currentDurationSeconds.value;
    final target = rundown.targetDuration;
    
    final difference = target - current;
    final isOverrun = difference < 0;

    return Row(
      children: [
        _buildDurationBox('Current', controller.formatDuration(current), Colors.blueGrey),
        const SizedBox(width: 16),
        _buildDurationBox('Target', controller.formatDuration(target), Colors.black87),
        const SizedBox(width: 16),
        _buildDurationBox(
          isOverrun ? 'Overrun' : 'Remaining',
          controller.formatDuration(difference.abs()),
          isOverrun ? Colors.red : (difference < 120 ? Colors.orange : Colors.green),
        ),
      ],
    );
  }

  Widget _buildDurationBox(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'on-air': return Colors.red;
      case 'locked': return Colors.orange;
      case 'completed': return Colors.green;
      default: return Colors.grey;
    }
  }
}

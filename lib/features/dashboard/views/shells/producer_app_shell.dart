import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:chamDTech_nrcs/features/stories/views/widgets/nrcs_layout.dart';
import 'package:chamDTech_nrcs/core/constants/app_constants.dart';
import 'package:chamDTech_nrcs/app/routes/app_routes.dart';
import 'package:chamDTech_nrcs/features/dashboard/controllers/producer_dashboard_controller.dart';
import 'package:chamDTech_nrcs/features/rundowns/models/rundown_model.dart';
import 'package:chamDTech_nrcs/features/stories/models/story_model.dart';

class ProducerAppShell extends StatefulWidget {
  const ProducerAppShell({super.key});

  @override
  State<ProducerAppShell> createState() => _ProducerAppShellState();
}

class _ProducerAppShellState extends State<ProducerAppShell> {
  int _selectedIndex = 0;

  final List<String> _tabs = [
    'Operational Dashboard',
    'Rundowns',
    'Story Pool',
    'Reports',
    'Notifications'
  ];

  @override
  Widget build(BuildContext context) {
    // Initialize controller for the shell
    final controller = Get.put(ProducerDashboardController());

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const NRCSTopNav(),
          const NRCSSubNav(),
          // Sub-header displaying Summary
          Container(
            height: 40,
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: NRCSColors.borderGray, width: 0.5)),
            ),
            child: Row(
              children: [
                const SizedBox(width: 24),
                const Text(
                  'PRODUCER WORKSPACE',
                  style: TextStyle(
                    color: NRCSColors.textDark,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    letterSpacing: 1.1,
                  ),
                ),
                const Spacer(),
                Obx(() => Text(
                  'Today\'s Total Air Time: ${controller.formatDuration(controller.totalAirTimeSeconds.value)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: NRCSColors.topNavBlue,
                  ),
                )),
                const SizedBox(width: 24),
              ],
            ),
          ),
          const NRCSToolbar(),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Hardcoded Producer Sidebar
                Container(
                  width: 361,
                  decoration: const BoxDecoration(
                    border: Border(
                      right: BorderSide(color: NRCSColors.borderGray, width: 8),
                    ),
                  ),
                  child: ListView.builder(
                    itemCount: _tabs.length,
                    itemBuilder: (context, index) {
                      final tab = _tabs[index];
                      return ListTile(
                        title: Text(tab, style: const TextStyle(fontWeight: FontWeight.bold)),
                        selected: _selectedIndex == index,
                        selectedTileColor: NRCSColors.subNavGray,
                        onTap: () {
                          if (tab == 'Rundowns') {
                            Get.toNamed(AppRoutes.rundownList); // Future
                          } else {
                            setState(() {
                              _selectedIndex = index;
                            });
                          }
                        },
                      );
                    },
                  ),
                ),
                // Main Content Area
                Expanded(
                  child: _buildContentArea(controller),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentArea(ProducerDashboardController controller) {
    switch (_selectedIndex) {
      case 0: // Dashboard
        return _buildProducerHome(controller);
      case 2: // Story Pool
        return _buildStoryPoolViewer(controller);
      case 3: // Reports
        return const Center(child: Text('Reports'));
      case 4: // Notifications
        return const Center(child: Text('Notifications'));
      default:
        return _buildProducerHome(controller);
    }
  }

  Widget _buildProducerHome(ProducerDashboardController controller) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Operational Overview',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: NRCSColors.topNavBlue,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              ElevatedButton.icon(
                onPressed: () => controller.createNewRundown(context),
                icon: const Icon(Icons.add),
                label: const Text('Create Rundown'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: NRCSColors.topNavBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 2,
                  child: _buildRundownsSection(controller),
                ),
                const SizedBox(width: 24),
                Expanded(
                  flex: 1,
                  child: _buildMiniStoryPoolSection(controller),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRundownsSection(ProducerDashboardController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: NRCSColors.borderGray),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.view_list, color: NRCSColors.topNavBlue),
              const SizedBox(width: 8),
              const Text(
                'Today\'s Rundowns',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: NRCSColors.topNavBlue,
                ),
              ),
              const Spacer(),
              Obx(() => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: NRCSColors.topNavBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${controller.activeRundowns.length}',
                  style: const TextStyle(
                    color: NRCSColors.topNavBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.activeRundowns.isEmpty) {
                return const Center(
                  child: Text(
                    'No active rundowns today',
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }

              return ListView.builder(
                itemCount: controller.activeRundowns.length,
                itemBuilder: (context, index) {
                  final rundown = controller.activeRundowns[index];
                  return Card(
                    elevation: 1,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      title: Text(
                        rundown.name, 
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                      ),
                      subtitle: Row(
                        children: [
                          Icon(Icons.schedule, size: 14, color: NRCSColors.topNavBlue),
                          const SizedBox(width: 4),
                          Text(DateFormat('hh:mm a').format(rundown.scheduledTime)),
                          const SizedBox(width: 16),
                          Icon(Icons.article, size: 14, color: NRCSColors.topNavBlue),
                          const SizedBox(width: 4),
                          Text('${rundown.storyIds.length} Stories'),
                          const SizedBox(width: 16),
                          Icon(Icons.timer, size: 14, color: NRCSColors.topNavBlue),
                          const SizedBox(width: 4),
                          Text('Target: ${controller.formatDuration(rundown.targetDuration)}'),
                        ],
                      ),
                      trailing: _buildStatusBadge(rundown.status),
                      onTap: () {
                        controller.openRundownBuilder(rundown);
                      },
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'on-air':
        color = Colors.red;
        break;
      case 'locked':
        color = Colors.orange;
        break;
      case 'completed':
        color = Colors.green;
        break;
      default:
        color = Colors.grey;
    }

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

  Widget _buildMiniStoryPoolSection(ProducerDashboardController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: NRCSColors.borderGray),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.pool, color: NRCSColors.topNavBlue),
              const SizedBox(width: 8),
              const Text(
                'Ready-to-Air Pool',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: NRCSColors.topNavBlue,
                ),
              ),
              const Spacer(),
              Obx(() => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: NRCSColors.topNavBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${controller.readyToAirStories.length}',
                  style: const TextStyle(
                    color: NRCSColors.topNavBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Obx(() {
              if (controller.readyToAirStories.isEmpty && !controller.isLoading.value) {
                return const Center(
                  child: Text(
                    'No stories available',
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }

              return ListView.builder(
                itemCount: controller.readyToAirStories.length,
                itemBuilder: (context, index) {
                  final story = controller.readyToAirStories[index];
                  return Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            story.title.isEmpty ? 'Untitled Story' : story.title,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.timer, size: 14, color: NRCSColors.topNavBlue),
                              const SizedBox(width: 4),
                              Text('${(story.duration ~/ 60).toString().padLeft(2, '0')}:${(story.duration % 60).toString().padLeft(2, '0')}'),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  story.status.toUpperCase(),
                                  style: const TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                setState(() => _selectedIndex = 2); // Switch to Story Pool tab
              },
              child: const Text('View Full Story Pool'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoryPoolViewer(ProducerDashboardController controller) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Story Pool Explorer',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: NRCSColors.topNavBlue,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 24),
          // Simplified full view
          Expanded(
            child: _buildMiniStoryPoolSection(controller), 
            // In a real app we would build a much more complex data table/grid here with filters for desks, etc.
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:chamDTech_nrcs/features/stories/views/widgets/nrcs_layout.dart';
import 'package:chamDTech_nrcs/core/constants/app_constants.dart';
import 'package:chamDTech_nrcs/app/routes/app_routes.dart';
import 'package:chamDTech_nrcs/features/dashboard/controllers/reporter_dashboard_controller.dart';
import 'package:chamDTech_nrcs/features/stories/models/story_model.dart';
import 'package:chamDTech_nrcs/features/dashboard/views/widgets/my_stories_tab.dart';

class ReporterAppShell extends StatefulWidget {
  const ReporterAppShell({super.key});

  @override
  State<ReporterAppShell> createState() => _ReporterAppShellState();
}

class _ReporterAppShellState extends State<ReporterAppShell> {
  int _selectedIndex = 0;

  final List<String> _tabs = [
    'Dashboard',
    'My Stories',
    'Create Story',
    'Notifications',
  ];

  @override
  Widget build(BuildContext context) {
    // Initialize controller
    final controller = Get.put(ReporterDashboardController());

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const NRCSTopNav(),
          const NRCSSubNav(),
          // Sub-header
          Container(
            height: 40,
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: NRCSColors.borderGray, width: 0.5)),
            ),
            child: const Row(
              children: [
                SizedBox(width: 24),
                Text(
                  'REPORTER WORKSPACE',
                  style: TextStyle(
                    color: NRCSColors.textDark,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    letterSpacing: 1.1,
                  ),
                ),
              ],
            ),
          ),
          const NRCSToolbar(),
          Expanded(
            child: Row(
              children: [
                // Hardcoded Reporter Sidebar
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
                          if (tab == 'Create Story') {
                            controller.createNewStory();
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

  Widget _buildContentArea(ReporterDashboardController controller) {
    switch (_selectedIndex) {
      case 0: // Dashboard
        return _buildReporterHome(controller);
      case 1: // My Stories
        return MyStoriesTab(controller: controller);
      case 3: // Notifications
        return const Center(child: Text('Notifications'));
      default:
        return _buildReporterHome(controller);
    }
  }

  Widget _buildReporterHome(ReporterDashboardController controller) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'My Workspace',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: NRCSColors.topNavBlue,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              ElevatedButton.icon(
                onPressed: () => controller.createNewStory(),
                icon: const Icon(Icons.add),
                label: const Text('Create New Story'),
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
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              return Column(
                children: [
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildSection(
                            context: context,
                            controller: controller,
                            title: 'Draft Stories',
                            icon: Icons.edit_note,
                            stories: controller.draftStories,
                            isWarning: false,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildSection(
                            context: context,
                            controller: controller,
                            title: 'Recently Submitted',
                            icon: Icons.send_time_extension,
                            stories: controller.submittedStories,
                            isWarning: false,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildSection(
                            context: context,
                            controller: controller,
                            title: 'Rejected / Revision Required',
                            icon: Icons.error_outline,
                            stories: controller.rejectedStories,
                            isWarning: true,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildSection(
                            context: context,
                            controller: controller,
                            title: 'Approved Stories',
                            icon: Icons.verified,
                            stories: controller.approvedStories,
                            isWarning: false,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required BuildContext context,
    required ReporterDashboardController controller,
    required String title,
    required IconData icon,
    required List<StoryModel> stories,
    required bool isWarning,
  }) {
    final headerColor = isWarning ? Colors.red : NRCSColors.topNavBlue;
    final bgColor = isWarning ? Colors.red.withOpacity(0.05) : Colors.white;
    final borderColor = isWarning ? Colors.red.withOpacity(0.3) : NRCSColors.borderGray;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: headerColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: headerColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: headerColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${stories.length}',
                  style: TextStyle(
                    color: headerColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: stories.isEmpty
                ? const Center(
                    child: Text(
                      'No stories right now',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: stories.length,
                    itemBuilder: (context, index) {
                      final story = stories[index];
                      final timeFormat = DateFormat('HH:mm');
                      final dateFormat = DateFormat('MMM dd');
                      
                      return GestureDetector(
                        onSecondaryTapDown: (details) {
                          controller.showStoryMenu(context, story, details.globalPosition);
                        },
                        onLongPressStart: (details) {
                          controller.showStoryMenu(context, story, details.globalPosition);
                        },
                        child: NRCSStoryListItem(
                          title: story.title.isEmpty ? 'Untitled' : story.title,
                          author: story.authorName,
                          time: timeFormat.format(story.updatedAt),
                          date: dateFormat.format(story.updatedAt),
                          duration: '${(story.duration ~/ 60).toString().padLeft(2, '0')}:${(story.duration % 60).toString().padLeft(2, '0')}',
                          onTap: () {
                            controller.editStory(story);
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

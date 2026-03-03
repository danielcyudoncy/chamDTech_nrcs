import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:chamDTech_nrcs/features/dashboard/controllers/editor_dashboard_controller.dart';
import 'package:chamDTech_nrcs/features/stories/views/widgets/nrcs_layout.dart';
import 'package:chamDTech_nrcs/core/constants/app_constants.dart';
import 'package:chamDTech_nrcs/app/routes/app_routes.dart';
import 'package:chamDTech_nrcs/features/stories/models/story_model.dart';

class EditorAppShell extends StatefulWidget {
  const EditorAppShell({super.key});

  @override
  State<EditorAppShell> createState() => _EditorAppShellState();
}

class _EditorAppShellState extends State<EditorAppShell> {
  int _selectedIndex = 0;

  final List<String> _tabs = [
    'Dashboard',
    'Review Queue',
    'Desks',
    'Notifications'
  ];

  @override
  Widget build(BuildContext context) {
    // Initialize controller for the shell
    final controller = Get.put(EditorDashboardController());

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
                  'EDITOR WORKSPACE',
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
                // Hardcoded Editor Sidebar
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
                          if (tab == 'Desks') {
                            Get.toNamed(AppRoutes.adminDesks); // Uses admin route for desks conceptually
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

  Widget _buildContentArea(EditorDashboardController controller) {
    switch (_selectedIndex) {
      case 0: // Dashboard
        return _buildEditorHome(controller);
      case 1: // Review Queue
        return const Center(child: Text('Review Queue View'));
      case 3: // Notifications
        return const Center(child: Text('Notifications'));
      default:
        return _buildEditorHome(controller);
    }
  }

  Widget _buildEditorHome(EditorDashboardController controller) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Editorial Queue',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: NRCSColors.topNavBlue,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildSection(
                      context: context,
                      controller: controller,
                      title: 'Pending Review',
                      icon: Icons.priority_high,
                      stories: controller.pendingStories,
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: _buildSection(
                      context: context,
                      controller: controller,
                      title: 'In Copy Edit',
                      icon: Icons.edit_document,
                      stories: controller.copyEditStories,
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
    required EditorDashboardController controller,
    required String title,
    required IconData icon,
    required List<StoryModel> stories,
  }) {
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
              Icon(icon, color: NRCSColors.topNavBlue),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: NRCSColors.topNavBlue,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: NRCSColors.topNavBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${stories.length}',
                  style: const TextStyle(
                    color: NRCSColors.topNavBlue,
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
                      'No stories available',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: stories.length,
                    itemBuilder: (context, index) {
                      final story = stories[index];
                      // Format times
                      final timeFormat = DateFormat('HH:mm');
                      final dateFormat = DateFormat('MMM dd, yyyy');
                      
                      return GestureDetector(
                        onSecondaryTapDown: (details) {
                          controller.showStoryMenu(context, story, details.globalPosition);
                        },
                        // Long press for mobile/touch
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
                            controller.startCopyEdit(story);
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

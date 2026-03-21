// features/dashboard/views/editor_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:chamdtech_nrcs/features/dashboard/controllers/editor_dashboard_controller.dart';
import 'package:chamdtech_nrcs/features/stories/views/widgets/nrcs_layout.dart';
import 'package:chamdtech_nrcs/features/stories/models/story_model.dart';

class EditorDashboardScreen extends StatelessWidget {
  const EditorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EditorDashboardController());

    return NRCSAppShell(
      title: 'Editor Dashboard',
      toolbar: const NRCSToolbar(),
      body: Padding(
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
                  color: NRCSColors.topNavBlue.withValues(alpha:0.1),
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

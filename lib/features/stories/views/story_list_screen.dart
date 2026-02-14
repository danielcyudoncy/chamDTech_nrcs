import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chamDTech_nrcs/features/stories/controllers/story_controller.dart';
import 'package:chamDTech_nrcs/features/stories/models/story_model.dart';
import 'package:chamDTech_nrcs/features/auth/services/auth_service.dart';
import 'package:chamDTech_nrcs/core/constants/app_constants.dart';
import 'package:chamDTech_nrcs/core/utils/date_utils.dart' as core_date_utils;
import 'package:chamDTech_nrcs/core/utils/string_helpers.dart';

class StoryListScreen extends StatelessWidget {
  const StoryListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final StoryController controller = Get.put(StoryController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stories'),
        actions: [
          // Filter dropdown
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              controller.setFilter(value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'all',
                child: Text('All Stories'),
              ),
              const PopupMenuItem(
                value: 'my',
                child: Text('My Stories'),
              ),
              const PopupMenuItem(
                value: 'draft',
                child: Text('Drafts'),
              ),
              const PopupMenuItem(
                value: 'pending',
                child: Text('Pending Review'),
              ),
              const PopupMenuItem(
                value: 'approved',
                child: Text('Approved'),
              ),
            ],
          ),
          // User profile
          // User profile
          GestureDetector(
            onTap: () => controller.showUserMenu(context),
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              child: Obx(() {
                final user = Get.find<AuthService>().currentUser.value;
                return CircleAvatar(
                  radius: 16,
                  backgroundImage: user?.photoUrl != null
                      ? NetworkImage(user!.photoUrl!)
                      : null,
                  backgroundColor: Theme.of(context).primaryColorLight,
                  child: user?.photoUrl == null
                      ? Text(
                          user?.displayName.isNotEmpty == true
                              ? user!.displayName.substring(0, 1).toUpperCase()
                              : 'U',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                );
              }),
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.stories.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.article_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No stories yet',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Create your first story',
                  style: TextStyle(
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.stories.length,
          itemBuilder: (context, index) {
            final story = controller.stories[index];
            return _StoryCard(
              story: story,
              onTap: () => controller.openStory(story),
              onDelete: () => controller.deleteStory(story.id),
              onApprove: () => controller.approveStory(story.id),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: controller.createNewStory,
        icon: const Icon(Icons.add),
        label: const Text('New Story'),
      ),
    );
  }
}

class _StoryCard extends StatelessWidget {
  final StoryModel story;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onApprove;

  const _StoryCard({
    required this.story,
    required this.onTap,
    required this.onDelete,
    required this.onApprove,
  });

  Color _getStatusColor() {
    switch (story.status) {
      case AppConstants.statusApproved:
        return Colors.green;
      case AppConstants.statusPending:
        return Colors.orange;
      case AppConstants.statusRejected:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      StringHelpers.truncate(story.title, 60),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor().withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getStatusColor(),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      story.status.toUpperCase(),
                      style: TextStyle(
                        color: _getStatusColor(),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                story.slug,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.person_outline, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    story.authorName,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    core_date_utils.DateUtils.timeAgo(story.updatedAt),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.timer_outlined, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    core_date_utils.DateUtils.formatDuration(story.duration),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              if (story.tags.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: story.tags.take(3).map((tag) {
                    return Chip(
                      label: Text(tag),
                      labelStyle: const TextStyle(fontSize: 12),
                      padding: EdgeInsets.zero,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (story.status == AppConstants.statusPending)
                    TextButton.icon(
                      onPressed: onApprove,
                      icon: const Icon(Icons.check_circle_outline, size: 18),
                      label: const Text('Approve'),
                    ),
                  TextButton.icon(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('Delete'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

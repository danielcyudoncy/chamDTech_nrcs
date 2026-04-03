import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:chamdtech_nrcs/features/dashboard/controllers/story_pool_controller.dart';
import 'package:chamdtech_nrcs/features/stories/views/widgets/nrcs_layout.dart';
import 'package:chamdtech_nrcs/app/routes/app_routes.dart';

class StoryPoolWidget extends StatelessWidget {
  const StoryPoolWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(StoryPoolController());

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
                  color: NRCSColors.topNavBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${controller.poolStories.length}',
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
                return const Center(
                  child: SizedBox(
                    width: 20, 
                    height: 20, 
                    child: CircularProgressIndicator(strokeWidth: 2)
                  )
                );
              }

              if (controller.poolStories.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 48),
                    child: Text(
                      'Pool is Empty',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                );
              }

              return ListView.builder(
                itemCount: controller.poolStories.length,
                itemBuilder: (context, index) {
                  final story = controller.poolStories[index];
                  final timeFormat = DateFormat('HH:mm');
                  final dateFormat = DateFormat('MMM dd, yyyy');
                  
                  return NRCSStoryListItem(
                    title: story.title.isEmpty ? 'Untitled' : story.title,
                    author: story.authorName.isEmpty ? 'Unknown' : story.authorName,
                    time: timeFormat.format(story.updatedAt),
                    date: dateFormat.format(story.updatedAt),
                    duration: '${(story.duration ~/ 60).toString().padLeft(2, '0')}:${(story.duration % 60).toString().padLeft(2, '0')}',
                    onTap: () {
                       Get.toNamed(AppRoutes.storyEditor, arguments: story.id);
                    },
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

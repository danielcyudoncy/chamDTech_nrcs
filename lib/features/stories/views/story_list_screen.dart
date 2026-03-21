import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chamDTech_nrcs/features/stories/controllers/story_controller.dart';
import 'package:chamDTech_nrcs/features/stories/models/story_model.dart';
import 'package:chamDTech_nrcs/features/auth/services/auth_service.dart';
import 'package:chamDTech_nrcs/core/constants/app_constants.dart';
import 'package:chamDTech_nrcs/core/utils/date_utils.dart' as core_date_utils;
import 'package:chamDTech_nrcs/core/utils/string_helpers.dart';
import 'package:chamDTech_nrcs/features/stories/views/widgets/nrcs_layout.dart';

class StoryListScreen extends StatelessWidget {
  const StoryListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final StoryController controller = Get.put(StoryController());

    return NRCSAppShell(
      title: 'Workspace',
      toolbar: const NRCSToolbar(),
      sidebar: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            // Category Filter Bar
            Container(
              height: 48,
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: NRCSColors.borderGray)),
              ),
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: [
                  _CategoryFilterChip(
                    label: 'All',
                    isSelected: controller.categoryFilter.value == 'all',
                    onTap: () => controller.setCategoryFilter('all'),
                    color: Colors.grey.shade700,
                  ),
                  ...AppConstants.storyCategories.map((cat) => Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: _CategoryFilterChip(
                          label: cat,
                          isSelected: controller.categoryFilter.value == cat,
                          onTap: () => controller.setCategoryFilter(cat),
                          color: _getCategoryColor(cat),
                        ),
                      )),
                ],
              ),
            ),
            // Story List
            Expanded(
              child: ListView.builder(
                itemCount: controller.stories.length,
                itemBuilder: (context, index) {
                  final story = controller.stories[index];
                  return Obx(() => NRCSStoryListItem(
                    title: story.title,
                    author: story.authorName,
                    time: core_date_utils.DateUtils.formatTime(story.updatedAt),
                    date: core_date_utils.DateUtils.formatDate(story.updatedAt),
                    duration: core_date_utils.DateUtils.formatDuration(story.duration),
                    category: story.category, // Pass category to list item
                    isSelected: controller.selectedStoryId.value == story.id,
                    onTap: () {
                      controller.selectedStoryId.value = story.id;
                    },
                  ));
                },
              ),
            ),
          ],
        );
      }),
      body: Obx(() {
        final selectedStory = controller.selectedStory;
        if (selectedStory == null) {
          return const Center(
            child: Text(
              'Select a story to view details',
              style: TextStyle(color: const Color(0xFF757575), fontSize: 18),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DetailHeader(selectedStory: selectedStory),
              const SizedBox(height: 24),
              const Divider(color: NRCSColors.borderGray),
              const SizedBox(height: 24),
              _DetailMeta(selectedStory: selectedStory),
              const SizedBox(height: 32),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    selectedStory.content.isEmpty 
                        ? 'No content for this story.' 
                        : selectedStory.content,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _DetailHeader extends StatelessWidget {
  final StoryModel selectedStory;
  const _DetailHeader({required this.selectedStory});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            border: Border.all(color: NRCSColors.borderGray),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            selectedStory.title,
            style: const TextStyle(
              fontSize: 18, 
              fontWeight: FontWeight.bold,
              color: NRCSColors.topNavBlue,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Text(
              'MASTER: ',
              style: TextStyle(
                fontWeight: FontWeight.bold, 
                color: NRCSColors.topNavBlue,
                fontSize: 16,
              ),
            ),
            Checkbox(value: true, onChanged: (_) {}),
            const Text(
              'FIRST VERSION',
              style: TextStyle(
                fontWeight: FontWeight.bold, 
                color: NRCSColors.topNavBlue,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 32),
            _MiniBadge(label: '250'),
            const SizedBox(width: 16),
            _MiniBadge(label: core_date_utils.DateUtils.formatDuration(selectedStory.duration)),
          ],
        ),
      ],
    );
  }
}

class _MiniBadge extends StatelessWidget {
  final String label;
  const _MiniBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: NRCSColors.subNavGray,
        border: Border.all(color: Colors.black),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.bold, 
          color: NRCSColors.topNavBlue,
        ),
      ),
    );
  }
}

class _DetailMeta extends StatelessWidget {
  final StoryModel selectedStory;
  const _DetailMeta({required this.selectedStory});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _MetaItem(label: 'Author', value: selectedStory.authorName),
        const SizedBox(width: 24),
        _MetaItem(label: 'Status', value: selectedStory.status.toUpperCase()),
        const SizedBox(width: 24),
        _MetaItem(
          label: 'Updated', 
          value: core_date_utils.DateUtils.formatDateTime(selectedStory.updatedAt),
        ),
        const SizedBox(width: 24),
        if (selectedStory.category.isNotEmpty) ...[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Category',
                style: TextStyle(
                  fontSize: 12, 
                  color: NRCSColors.topNavBlue, 
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _getCategoryColor(selectedStory.category).withOpacity(0.1),
                  border: Border.all(color: _getCategoryColor(selectedStory.category)),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  selectedStory.category,
                  style: TextStyle(
                    fontSize: 12, 
                    fontWeight: FontWeight.w600,
                    color: _getCategoryColor(selectedStory.category),
                  ),
                ),
              ),
            ],
          ),
        ]
      ],
    );
  }
}

class _MetaItem extends StatelessWidget {
  final String label;
  final String value;
  const _MetaItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12, 
            color: NRCSColors.topNavBlue, 
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14, 
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _CategoryFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color color;

  const _CategoryFilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : Colors.transparent,
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade400,
            width: isSelected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (label != 'All') ...[
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(shape: BoxShape.circle, color: color),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : Colors.grey.shade700,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Color _getCategoryColor(String category) {
  switch (category) {
    case 'NEWS':      return Colors.blue;
    case 'POLITICS':  return Colors.purple;
    case 'SPORTS':    return Colors.green;
    case 'FOREIGN':   return Colors.orange;
    case 'BUSINESS':  return Colors.teal;
    default:          return Colors.grey;
  }
}

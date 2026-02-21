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

        return ListView.builder(
          itemCount: controller.stories.length,
          itemBuilder: (context, index) {
            final story = controller.stories[index];
            return Obx(() => NRCSStoryListItem(
              title: story.title,
              author: story.authorName,
              time: core_date_utils.DateUtils.formatTime(story.updatedAt),
              date: core_date_utils.DateUtils.formatDate(story.updatedAt),
              duration: core_date_utils.DateUtils.formatDuration(story.duration),
              isSelected: controller.selectedStoryId.value == story.id,
              onTap: () {
                controller.selectedStoryId.value = story.id;
              },
            ));
          },
        );
      }),
      body: Obx(() {
        final selectedStory = controller.selectedStory;
        if (selectedStory == null) {
          return const Center(
            child: Text(
              'Select a story to view details',
              style: TextStyle(color: Colors.grey, fontSize: 18),
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
          style: TextStyle(
            fontSize: 12, 
            color: Colors.grey[600], 
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

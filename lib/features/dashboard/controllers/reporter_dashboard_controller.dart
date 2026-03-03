import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:chamDTech_nrcs/features/stories/models/story_model.dart';
import 'package:chamDTech_nrcs/features/stories/services/story_service.dart';
import 'package:chamDTech_nrcs/core/constants/app_constants.dart';
import 'package:chamDTech_nrcs/app/routes/app_routes.dart';

class ReporterDashboardController extends GetxController {
  final StoryService _storyService = Get.put(StoryService());

  // 5 workflow groups — strict isolation (only current reporter's stories)
  final draftStories = <StoryModel>[].obs;       // draft
  final submittedStories = <StoryModel>[].obs;   // pending (under review)
  final rejectedStories = <StoryModel>[].obs;    // rejected (needs revision)
  final approvedStories = <StoryModel>[].obs;    // approved / verified / ready_to_air
  final archivedStories = <StoryModel>[].obs;    // archived / aired

  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadReporterStories();
  }

  void loadReporterStories() {
    _storyService.getMyStories().listen((stories) {
      draftStories.value = stories
          .where((s) => s.status == AppConstants.statusDraft)
          .toList();

      submittedStories.value = stories
          .where((s) => s.status == AppConstants.statusPending)
          .toList();

      rejectedStories.value = stories
          .where((s) => s.status == AppConstants.statusRejected)
          .toList();

      approvedStories.value = stories
          .where((s) =>
              s.status == AppConstants.statusApproved ||
              s.stage == AppConstants.stageReadyToAir ||
              s.stage == AppConstants.stageVerified ||
              s.stage == AppConstants.stageCopyEdited)
          .toList();

      archivedStories.value = stories
          .where((s) =>
              s.status == AppConstants.statusArchived ||
              s.stage == AppConstants.stageAired)
          .toList();

      isLoading.value = false;
    });
  }

  void createNewStory() {
    Get.toNamed(AppRoutes.storyEditor);
  }

  void editStory(StoryModel story) {
    Get.toNamed(AppRoutes.storyEditor, arguments: story);
  }

  Future<void> submitStory(StoryModel story) async {
    try {
      final updatedStory = story.copyWith(
        status: AppConstants.statusPending,
        updatedAt: DateTime.now(),
      );
      await _storyService.updateStory(updatedStory);
      Get.snackbar('Submitted', 'Story submitted for editorial review.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade50,
          colorText: Colors.green.shade900);
    } catch (e) {
      Get.snackbar('Error', 'Failed to submit story.',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> resubmitStory(StoryModel story) async {
    try {
      final updatedStory = story.copyWith(
        status: AppConstants.statusPending,
        updatedAt: DateTime.now(),
      );
      await _storyService.updateStory(updatedStory);
      Get.snackbar('Resubmitted', 'Story resubmitted for review.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.blue.shade50,
          colorText: Colors.blue.shade900);
    } catch (e) {
      Get.snackbar('Error', 'Failed to resubmit story.',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> deleteStory(BuildContext context, StoryModel story) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text(
            'Are you sure you want to delete this story? This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () => Get.back(result: true),
            child:
                const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _storyService.deleteStory(story.id);
    }
  }

  void showStoryMenu(BuildContext context, StoryModel story, Offset position) {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    showMenu(
      context: context,
      position: RelativeRect.fromRect(
        position & const Size(40, 40),
        Offset.zero & overlay.size,
      ),
      items: [
        if (story.status == AppConstants.statusDraft ||
            story.status == AppConstants.statusRejected)
          const PopupMenuItem(
            value: 'edit',
            child: Row(children: [
              Icon(Icons.edit, size: 18, color: Colors.blue),
              SizedBox(width: 8),
              Text('Edit Story'),
            ]),
          ),
        if (story.status == AppConstants.statusDraft ||
            story.status == AppConstants.statusRejected)
          PopupMenuItem(
            value: 'submit',
            child: Row(children: [
              Icon(Icons.send, size: 18,
                  color: story.status == AppConstants.statusRejected
                      ? Colors.blue
                      : Colors.green),
              const SizedBox(width: 8),
              Text(story.status == AppConstants.statusRejected
                  ? 'Resubmit for Review'
                  : 'Submit for Review'),
            ]),
          ),
        if (story.status == AppConstants.statusDraft)
          const PopupMenuItem(
            value: 'delete',
            child: Row(children: [
              Icon(Icons.delete, size: 18, color: Colors.red),
              SizedBox(width: 8),
              Text('Delete Story'),
            ]),
          ),
      ],
      elevation: 8.0,
    ).then((value) {
      if (value == null) return;
      switch (value) {
        case 'edit':
          editStory(story);
          break;
        case 'submit':
          if (story.status == AppConstants.statusRejected) {
            resubmitStory(story);
          } else {
            submitStory(story);
          }
          break;
        case 'delete':
          deleteStory(context, story);
          break;
      }
    });
  }
}


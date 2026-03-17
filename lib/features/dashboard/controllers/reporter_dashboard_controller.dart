import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:chamDTech_nrcs/features/stories/models/story_model.dart';
import 'package:chamDTech_nrcs/features/stories/services/story_service.dart';
import 'package:chamDTech_nrcs/features/rundowns/services/rundown_service.dart';
import 'package:chamDTech_nrcs/core/constants/app_constants.dart';
import 'package:chamDTech_nrcs/app/routes/app_routes.dart';

class ReporterDashboardController extends GetxController {
  final StoryService _storyService = Get.put(StoryService());
  final RundownService _rundownService = Get.put(RundownService());

  // 5 workflow groups — strict isolation (only current reporter's stories)
  final draftStories = <StoryModel>[].obs;       // draft
  final submittedStories = <StoryModel>[].obs;   // pending (under review)
  final rejectedStories = <StoryModel>[].obs;    // rejected (needs revision)
  final approvedStories = <StoryModel>[].obs;    // approved / verified / ready_to_air
  final archivedStories = <StoryModel>[].obs;    // archived / aired
 
  /// The story currently selected in the UI for toolbar actions.
  final selectedStory = Rxn<StoryModel>();

  /// Set of story IDs currently locked inside a locked/on-air rundown.
  /// Reactive — updates live as producers lock/unlock rundowns.
  final lockedStoryIds = <String>{}.obs;

  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadReporterStories();
    _listenForRundownLocks();
  }

  /// Subscribe to locked/on-air rundowns and keep lockedStoryIds up to date.
  void _listenForRundownLocks() {
    _rundownService.streamNonDraftRundowns().listen((rundowns) {
      final ids = <String>{};
      for (final r in rundowns) {
        ids.addAll(r.storyIds);
      }
      lockedStoryIds.assignAll(ids);
    });
  }

  /// Returns true if this story is inside a locked/on-air rundown.
  bool isStoryEditLocked(String storyId) => lockedStoryIds.contains(storyId);

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

  void selectStory(StoryModel? story) {
    if (selectedStory.value?.id == story?.id) {
      selectedStory.value = null;
    } else {
      selectedStory.value = story;
    }
  }

  void editStory(StoryModel story) {
    Get.toNamed(AppRoutes.storyEditor, arguments: story);
  }

  void editSelectedStory() {
    if (selectedStory.value != null) {
      editStory(selectedStory.value!);
    } else {
      Get.snackbar('Selection Required', 'Please select a story to edit.',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  /// For approved stories: checks rundown lock before opening editor.
  /// Shows a blocking dialog if the story is in a locked rundown.
  Future<void> tryEditApprovedStory(
      BuildContext context, StoryModel story) async {
    if (!isStoryEditLocked(story.id)) {
      // Not locked — allow edit directly
      editStory(story);
      return;
    }

    // Fetch the specific locked rundowns for a clear error message
    final lockedRundowns =
        await _rundownService.getLockedRundownsForStory(story.id);
    final rundownNames = lockedRundowns.map((r) => r.name).join(', ');

    if (!context.mounted) return;
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.lock, color: Colors.red, size: 20),
            SizedBox(width: 8),
            Text('Editing Blocked'),
          ],
        ),
        content: Text(
          'This story is currently part of a locked rundown'  
          '${rundownNames.isNotEmpty ? " ($rundownNames)" : "."}'  
          '\n\nEditing is disabled until the producer unlocks the rundown.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('View Only'),
          ),
        ],
      ),
    );
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
      try {
        await _storyService.deleteStory(story.id);
        if (selectedStory.value?.id == story.id) {
          selectedStory.value = null;
        }
      } catch (e) {
        Get.snackbar('Error', 'Failed to delete story.',
            snackPosition: SnackPosition.BOTTOM);
      }
    }
  }

  void deleteSelectedStory(BuildContext context) {
    if (selectedStory.value != null) {
      deleteStory(context, selectedStory.value!);
    } else {
      Get.snackbar('Selection Required', 'Please select a story to delete.',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> copySelectedStory() async {
    if (selectedStory.value == null) {
      Get.snackbar('Selection Required', 'Please select a story to copy.',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    try {
      final source = selectedStory.value!;
      final newStory = source.copyWith(
        id: '', // Service will generate new ID
        title: '${source.title} (Copy)',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        status: AppConstants.statusDraft,
      );
      await _storyService.createStory(newStory);
      Get.snackbar('Copied', 'Story duplicated successfully.',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', 'Failed to copy story.',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  void performAction(String action) {
    if (selectedStory.value == null && action != 'New') {
       Get.snackbar('Selection Required', 'Please select a story first.',
          snackPosition: SnackPosition.BOTTOM);
       return;
    }
    
    Get.snackbar(action, '$action feature is coming soon.',
        snackPosition: SnackPosition.BOTTOM);
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
          if (context.mounted) deleteStory(context, story);
          break;
      }
    });
  }
}


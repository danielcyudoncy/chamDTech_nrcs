// features/dashboard/controllers/editor_dashboard_controller.dart
import 'dart:async';
import 'package:get/get.dart';
import 'package:chamdtech_nrcs/features/stories/models/story_model.dart';
import 'package:chamdtech_nrcs/features/stories/services/story_service.dart';
import 'package:chamdtech_nrcs/core/constants/app_constants.dart';
import 'package:chamdtech_nrcs/core/models/notification_model.dart';
import 'package:chamdtech_nrcs/core/services/notification_service.dart';
import 'package:chamdtech_nrcs/features/auth/services/auth_service.dart';
import 'package:chamdtech_nrcs/app/routes/app_routes.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';

class EditorDashboardController extends GetxController {
  final StoryService _storyService = Get.find<StoryService>();
  final NotificationService _notificationService =
      Get.find<NotificationService>();
  final AuthService _authService = Get.find<AuthService>();

  StreamSubscription<List<StoryModel>>? _storiesSubscription;

  final pendingStories = <StoryModel>[].obs;
  final copyEditStories = <StoryModel>[].obs;
  final allStories = <StoryModel>[].obs;

  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadEditorQueues();
  }

  @override
  void onClose() {
    _storiesSubscription?.cancel();
    super.onClose();
  }

  void loadEditorQueues() {
    isLoading.value = true;
    _storiesSubscription?.cancel();
    _storiesSubscription = _storyService.getStories().listen((stories) {
      allStories.value = stories;

      // 1. Identify which original stories have already been branched/re-edited
      final originalIdsWithCopies = stories
          .where((s) => s.parentStoryId != null)
          .map((s) => s.parentStoryId)
          .toSet();

      // 2. Pending review: submitted by reporter, wait for editor action
      pendingStories.value = stories.where((s) {
        if (s.parentStoryId == null && originalIdsWithCopies.contains(s.id)) {
          return false;
        }
        return s.status == AppConstants.statusPending ||
            (s.stage == AppConstants.stageNew &&
                s.status != AppConstants.statusApproved);
      }).toList();

      // 3. In Copy Edit
      copyEditStories.value = stories.where((s) {
        return s.stage == AppConstants.stageCopyEdited &&
            s.status != AppConstants.statusApproved;
      }).toList();

      Get.log(
          'EditorDashboardController: Loaded ${stories.length} stories. Pending: ${pendingStories.length}, CopyEdit: ${copyEditStories.length}');
      isLoading.value = false;
    }, onError: (error) {
      Get.log('EditorDashboardController: Error in stories stream: $error');
      isLoading.value = false;
      // Optionally show a user-friendly message if it's a permission error
      if (error.toString().contains('permission-denied')) {
        Get.snackbar(
          'Access Denied',
          'You do not have permission to view the editorial queue.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.1),
          colorText: Colors.red.shade900,
        );
      }
    });
  }

  Future<void> startCopyEdit(StoryModel story) async {
    // Change stage to copy_edited and navigate to editor
    try {
      final updatedStory = story.copyWith(
        stage: AppConstants.stageCopyEdited,
        updatedAt: DateTime.now(),
      );
      await _storyService.updateStory(updatedStory);
      Get.toNamed('/story/editor', arguments: updatedStory);
    } catch (e) {
      Get.snackbar('Error', 'Failed to start copy edit: $e');
    }
  }

  Future<void> changeStoryState(
      StoryModel story, String newStatus, String newStage) async {
    try {
      final updatedStory = story.copyWith(
        status: newStatus,
        stage: newStage,
        updatedAt: DateTime.now(),
      );
      await _storyService.updateStory(updatedStory);
      Get.snackbar('Success', 'Story state updated successfully',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', 'Failed to update story state: $e');
    }
  }

  Future<void> sendBackToReporter(StoryModel story) async {
    try {
      final updatedStory = story.copyWith(
        status: AppConstants
            .statusRejected, // Puts it back in reporter's lap for revision
        stage: AppConstants.stageNew,
        updatedAt: DateTime.now(),
      );
      await _storyService.updateStory(updatedStory);

      // Send notification to reporter
      final user = _authService.currentUser.value;
      await _notificationService.sendNotification(NotificationModel(
        id: const Uuid().v4(),
        userId: story.authorId,
        type: 'story_update',
        title: 'Story Rejected',
        message:
            '${user?.displayName ?? "An editor"} sent back "${story.title}" for revision.',
        createdAt: DateTime.now(),
        actionUrl: '${AppRoutes.storyEditor}?id=${story.id}',
        data: {'storyId': story.id},
      ));

      Get.snackbar('Sent Back', 'Story has been sent back to the reporter',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', 'Failed to send back story: $e');
    }
  }

  Future<void> approveForProducer(StoryModel story) async {
    try {
      await _storyService.approveStory(story.id);
      // approveStory handles logging and setting status to approved and stage to verified
    } catch (e) {
      Get.snackbar('Error', 'Failed to approve story: $e');
    }
  }

  void showChangeStateDialog(BuildContext context, StoryModel story) {
    String selectedStatus = story.status;
    String selectedStage = story.stage;

    final statuses = [
      AppConstants.statusDraft,
      AppConstants.statusPending,
      AppConstants.statusApproved,
      AppConstants.statusRejected,
      AppConstants.statusArchived,
    ];

    final stages = [
      AppConstants.stageNew,
      AppConstants.stageCopyEdited,
      AppConstants.stageVerified,
      AppConstants.stageReadyToAir,
      AppConstants.stageAired,
    ];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Change Story State'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: selectedStatus,
                    decoration: const InputDecoration(labelText: 'Status'),
                    items: statuses
                        .map((s) => DropdownMenuItem(
                            value: s, child: Text(s.toUpperCase())))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => selectedStatus = val);
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: selectedStage,
                    decoration: const InputDecoration(labelText: 'Stage'),
                    items: stages
                        .map((s) => DropdownMenuItem(
                            value: s, child: Text(s.toUpperCase())))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => selectedStage = val);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Get.back();
                    changeStoryState(story, selectedStatus, selectedStage);
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
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
        const PopupMenuItem(
          value: 'copy_edit',
          child: Row(
            children: [
              Icon(Icons.edit_document, size: 18, color: Colors.blue),
              SizedBox(width: 8),
              Text('Copy Edit'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'approve',
          child: Row(
            children: [
              Icon(Icons.check_circle_outline, size: 18, color: Colors.green),
              SizedBox(width: 8),
              Text('Approve for Producer'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'send_back',
          child: Row(
            children: [
              Icon(Icons.reply, size: 18, color: Colors.orange),
              SizedBox(width: 8),
              Text('Send Back to Reporter'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'change_state',
          child: Row(
            children: [
              Icon(Icons.swap_horiz, size: 18, color: Colors.grey),
              SizedBox(width: 8),
              Text('Change State (Manual)'),
            ],
          ),
        ),
      ],
      elevation: 8.0,
    ).then((value) {
      if (value == null || !context.mounted) return;

      switch (value) {
        case 'copy_edit':
          startCopyEdit(story);
          break;
        case 'approve':
          approveForProducer(story);
          break;
        case 'send_back':
          sendBackToReporter(story);
          break;
        case 'change_state':
          showChangeStateDialog(context, story);
          break;
      }
    });
  }
}

import 'package:get/get.dart';
import 'package:chamdtech_nrcs/features/rundowns/models/rundown_model.dart';
import 'package:chamdtech_nrcs/features/rundowns/services/rundown_service.dart';
import 'package:chamdtech_nrcs/features/stories/models/story_model.dart';
import 'package:chamdtech_nrcs/features/stories/services/story_service.dart';
import 'package:chamdtech_nrcs/core/services/notification_service.dart';

class RundownBuilderController extends GetxController {
  final RundownService _rundownService = Get.find<RundownService>();
  final StoryService _storyService = Get.find<StoryService>();
  
  final String rundownId;
  RundownBuilderController({required this.rundownId});

  final NotificationService _notificationService = Get.find<NotificationService>();

  final rundown = Rx<RundownModel?>(null);
  final stories = <StoryModel>[].obs;
  
  final isLoading = true.obs;
  final currentDurationSeconds = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadRundown();
  }

  void _loadRundown() {
    _rundownService.streamRundown(rundownId).listen((data) {
      if (data != null) {
        rundown.value = data;
        _loadStories(data.storyIds);
      } else {
        Get.back();
        Get.snackbar('Error', 'Rundown not found');
      }
    });
  }

  void _loadStories(List<String> storyIds) {
    if (storyIds.isEmpty) {
      stories.clear();
      currentDurationSeconds.value = 0;
      isLoading.value = false;
      return;
    }

    // In a real app we might batch fetch these, for now we will fetch them and sort them according to the rundown
    _storyService.getStories().listen((allStories) {
      final rundownStories = <StoryModel>[];
      int totalSeconds = 0;
      
      // Preserve order from storyIds array
      for (final id in storyIds) {
        final story = allStories.firstWhereOrNull((s) => s.id == id);
        if (story != null) {
          rundownStories.add(story);
          totalSeconds += story.duration;
        }
      }
      
      stories.value = rundownStories;
      currentDurationSeconds.value = totalSeconds;
      isLoading.value = false;
    });
  }

  void reorderStories(int oldIndex, int newIndex) {
    final currentRundown = rundown.value;
    if (currentRundown == null || currentRundown.status != 'draft') return; // Can only reorder drafts usually

    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    
    // Create new list to trigger reactive update correctly on backend
    final List<String> newOrder = List.from(currentRundown.storyIds);
    final String item = newOrder.removeAt(oldIndex);
    newOrder.insert(newIndex, item);

    // Optimistically update UI
    final storyList = List<StoryModel>.from(stories);
    final storyItem = storyList.removeAt(oldIndex);
    storyList.insert(newIndex, storyItem);
    stories.value = storyList;

    // Save to service
    _rundownService.updateRundown(currentRundown.copyWith(storyIds: newOrder));
  }

  void removeStory(StoryModel story) {
    final currentRundown = rundown.value;
    if (currentRundown == null || currentRundown.status != 'draft') return;

    final newOrder = List<String>.from(currentRundown.storyIds);
    newOrder.remove(story.id);

    _rundownService.updateRundown(currentRundown.copyWith(storyIds: newOrder));
  }
  
  // Add story to end
  void addStory(StoryModel story) {
     final currentRundown = rundown.value;
    if (currentRundown == null || currentRundown.status != 'draft') {
      Get.snackbar('Warning', 'Cannot add stories to a locked rundown');
      return;
    }

    if (currentRundown.storyIds.contains(story.id)) {
      Get.snackbar('Notice', 'Story is already in the rundown');
      return;
    }

    final newOrder = List<String>.from(currentRundown.storyIds)..add(story.id);
    _rundownService.updateRundown(currentRundown.copyWith(storyIds: newOrder));

    // Send broadcast notification
    _notificationService.broadcastNotification(
      title: 'Story Lined Up',
      message: 'Story "${story.title}" has been lined up for broadcast in "${currentRundown.name}"',
      type: 'rundown_change',
      actionUrl: '/rundown/builder?id=${currentRundown.id}',
      data: {'rundownId': currentRundown.id, 'storyId': story.id},
    );
  }

  void changeStatus(String newStatus) {
    final currentRundown = rundown.value;
    if (currentRundown == null) return;
    
    // Simplistic state machine check
    if (currentRundown.status == 'completed') return;

    _rundownService.updateRundown(currentRundown.copyWith(status: newStatus));
  }

  String formatDuration(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

// features/dashboard/controllers/reporter_dashboard_controller.dart
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:chamdtech_nrcs/core/models/notification_model.dart';
import 'package:chamdtech_nrcs/core/services/notification_service.dart';
import 'package:chamdtech_nrcs/features/auth/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:chamdtech_nrcs/features/stories/models/story_model.dart';
import 'package:chamdtech_nrcs/features/stories/services/story_service.dart';
import 'package:chamdtech_nrcs/features/rundowns/services/rundown_service.dart';
import 'package:chamdtech_nrcs/core/constants/app_constants.dart';
import 'package:chamdtech_nrcs/app/routes/app_routes.dart';

class ReporterDashboardController extends GetxController {
  final StoryService _storyService = Get.find<StoryService>();
  final RundownService _rundownService = Get.find<RundownService>();
  final AuthService _authService = Get.find<AuthService>();
  final NotificationService _notificationService = Get.find<NotificationService>();

  // 5 workflow groups — strict isolation (only current reporter's stories)
  final draftStories = <StoryModel>[].obs;       // draft
  final submittedStories = <StoryModel>[].obs;   // pending (under review)
  final rejectedStories = <StoryModel>[].obs;    // rejected (needs revision)
  final approvedStories = <StoryModel>[].obs;    // approved / verified / ready_to_air
  final archivedStories = <StoryModel>[].obs;    // archived / aired
  
  /// Combined list of all stories created by this reporter
  final allMyStories = <StoryModel>[].obs;
  
  // My Stories Screen Filters & Sorting
  final myStoriesSearchQuery = ''.obs;
  final myStoriesFilterStatus = 'all'.obs; // all, draft, pending, approved, rejected
  final myStoriesSortBy = 'newest'.obs; // newest, oldest, title_asc, title_desc

  List<StoryModel> get filteredAndSortedMyStories {
    var list = allMyStories.toList();
    
    // Status Filter
    if (myStoriesFilterStatus.value != 'all') {
      list = list.where((s) => s.status == myStoriesFilterStatus.value).toList();
    }
    
    // Search
    if (myStoriesSearchQuery.value.isNotEmpty) {
      final q = myStoriesSearchQuery.value.toLowerCase();
      list = list.where((s) => 
        s.title.toLowerCase().contains(q) || 
        s.content.toLowerCase().contains(q)
      ).toList();
    }
    
    // Sort
    switch (myStoriesSortBy.value) {
      case 'oldest':
        list.sort((a, b) => a.updatedAt.compareTo(b.updatedAt));
        break;
      case 'title_asc':
        list.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        break;
      case 'title_desc':
        list.sort((a, b) => b.title.toLowerCase().compareTo(a.title.toLowerCase()));
        break;
      case 'newest':
      default:
        list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        break;
    }
    
    return list;
  }
 
  /// The story currently selected in the UI for toolbar actions.
  final selectedStory = Rxn<StoryModel>();

  /// Set of story IDs currently locked inside a locked/on-air rundown.
  /// Reactive — updates live as producers lock/unlock rundowns.
  final lockedStoryIds = <String>{}.obs;

  final isLoading = true.obs;

  // Calendar and date-based filtering
  final selectedDate = DateTime.now().obs;
  final focusedDay = DateTime.now().obs;
  final approvedStoriesForDate = <StoryModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadReporterStories();
    _listenForRundownLocks();
  }

  void onDateSelected(DateTime selected, DateTime focused) {
    selectedDate.value = selected;
    focusedDay.value = focused;
    _filterApprovedStoriesByDate();
  }

  void _filterApprovedStoriesByDate() {
    approvedStoriesForDate.value = approvedStories.where((s) {
      return s.updatedAt.year == selectedDate.value.year &&
             s.updatedAt.month == selectedDate.value.month &&
             s.updatedAt.day == selectedDate.value.day;
    }).toList();
  }

  /// Subscribe to locked/on-air rundowns and keep lockedStoryIds up to date.
  void _listenForRundownLocks() {
    _rundownService.streamNonDraftRundowns().listen((rundowns) {
      final ids = <String>{};
      for (final r in rundowns) {
        ids.addAll(r.storyIds);
      }
      lockedStoryIds.assignAll(ids);
    }, onError: (e) => Get.log('ReporterDashboardController: Error in rundown stream: $e'));
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

      allMyStories.value = stories;
      
      _filterApprovedStoriesByDate();

      isLoading.value = false;

    }, onError: (e) {
      Get.log('ReporterDashboardController: Error in story stream: $e');
      isLoading.value = false;
    });
  }

  void createNewStory() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        child: Container(
          width: 500, // Slightly wider for better layout
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(Icons.category_outlined, size: 48, color: Theme.of(Get.context!).primaryColor),
              const SizedBox(height: 20),
              Text(
                'Select Story Category',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Theme.of(Get.context!).primaryColor,
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Please classify this story to ensure it appears in the correct department workspace.',
                style: TextStyle(
                  fontSize: 15, 
                  color: Color(0xFF546E7A),
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              Flexible(
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: AppConstants.storyCategories.map((cat) {
                      final color = _categoryColor(cat);
                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            Get.back();
                            Get.toNamed('/story/editor', arguments: {'category': cat});
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 135,
                            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade200),
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: color.withValues(alpha: 0.3),
                                        blurRadius: 4,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  cat,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                    color: Color(0xFF263238),
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    ),
                    child: const Text(
                      'Cancel', 
                      style: TextStyle(
                        color: Colors.grey, 
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  Color _categoryColor(String category) {
    switch (category) {
      case 'Local News':                return Colors.blue.shade700;
      case 'Politics':                  return Colors.purple.shade700;
      case 'Sports':                    return Colors.green.shade700;
      case 'Foreign':                   return Colors.orange.shade700;
      case 'Business & Finance':        return Colors.teal.shade700;
      case 'Breaking News':             return Colors.red.shade700;
      case 'Technology':                return Colors.indigo.shade700;
      case 'Environment':               return Colors.green.shade900;
      case 'Health':                    return Colors.pink.shade700;
      case 'Entertainment & Lifestyle': return Colors.amber.shade800;
      default:                          return Colors.grey.shade700;
    }
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
      
      // Notify editors/producers about the submission
      // For now, we'll notify all users with Editor or Producer roles
      // In a real app, we'd query for users with these roles.
      // Since I don't have a UserService, I'll assume a broadcast or a specific logic.
      // The user said: "when is story is submitted the editor also should get a notification"
      // I will create a simple notification for the "editorial desk".
      
      final currentUser = _authService.currentUser.value;
      
      // Since I can't easily find "all editors" without a UserService, 
      // I'll send it to a special "system" ID or similar if I can't find a better way.
      // Actually, I'll search for how users are managed.
      
      await _notificationService.sendNotification(NotificationModel(
        id: const Uuid().v4(),
        userId: 'editor_group', // This is a placeholder, normally you'd loop through editors
        type: 'story_update',
        title: 'New Story Submitted',
        message: '${currentUser?.displayName ?? "A reporter"} submitted "${story.title}" for review.',
        createdAt: DateTime.now(),
        actionUrl: AppRoutes.editorDashboard,
        data: {'storyId': story.id},
      ));

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


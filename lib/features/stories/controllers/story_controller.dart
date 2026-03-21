// features/stories/controllers/story_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chamdtech_nrcs/features/stories/services/story_service.dart';
import 'package:chamdtech_nrcs/features/stories/models/story_model.dart';
import 'package:chamdtech_nrcs/features/auth/services/auth_service.dart';
import 'package:chamdtech_nrcs/core/constants/app_constants.dart';

class StoryController extends GetxController {
  final StoryService _storyService = Get.put(StoryService());
  final AuthService _authService = Get.find<AuthService>();
  
  final stories = <StoryModel>[].obs;
  final isLoading = false.obs;
  final currentFilter = 'all'.obs;
  final categoryFilter = 'all'.obs; // Category filter: 'all' or a specific category
  final selectedStoryId = ''.obs;

  StoryModel? get selectedStory => 
      stories.firstWhereOrNull((s) => s.id == selectedStoryId.value);
  
  @override
  void onInit() {
    super.onInit();
    loadStories();
  }
  
  void loadStories() {
    isLoading.value = true;
    
    Stream<List<StoryModel>> storyStream;
    
    switch (currentFilter.value) {
      case 'my':
        storyStream = _storyService.getMyStories();
        break;
      case 'draft':
        storyStream = _storyService.getStories();
        break;
      case 'approved':
        storyStream = _storyService.getStories();
        break;
      default:
        storyStream = _storyService.getStories();
    }
    
    storyStream.listen((storyList) {
      // Apply status filter
      List<StoryModel> filtered;
      if (currentFilter.value == 'draft') {
        filtered = storyList.where((s) => s.status == AppConstants.statusDraft).toList();
      } else if (currentFilter.value == 'approved') {
        filtered = storyList.where((s) => s.status == AppConstants.statusApproved).toList();
      } else if (currentFilter.value == 'pending') {
        filtered = storyList.where((s) => s.status == AppConstants.statusPending).toList();
      } else {
        filtered = storyList;
      }

      // Apply category filter
      if (categoryFilter.value != 'all') {
        filtered = filtered.where((s) => s.category == categoryFilter.value).toList();
      }

      stories.value = filtered;
      isLoading.value = false;
    });
  }
  
  void setFilter(String filter) {
    currentFilter.value = filter;
    loadStories();
  }

  void setCategoryFilter(String category) {
    categoryFilter.value = category;
    loadStories();
  }
  
  void createNewStory() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 400, // Constrain width for a nice popup appearance
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Select Story Category',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1976D2), // topNavBlue
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Please classify this story before proceeding.',
                style: TextStyle(fontSize: 15, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: AppConstants.storyCategories.map((cat) {
                  return InkWell(
                    onTap: () {
                      Get.back(); // Close dialog
                      // Navigate to editor with the selected category pre-filled
                      Get.toNamed('/story/editor', arguments: {'category': cat});
                    },
                    child: Container(
                      width: 140,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey.shade50,
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: _categoryColor(cat),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            cat,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('Cancel', style: TextStyle(color: Colors.grey, fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false, // Force them to close it directly
    );
  }

  Color _categoryColor(String category) {
    switch (category) {
      case 'NEWS':      return Colors.blue;
      case 'POLITICS':  return Colors.purple;
      case 'SPORTS':    return Colors.green;
      case 'FOREIGN':   return Colors.orange;
      case 'BUSINESS':  return Colors.teal;
      default:          return Colors.grey;
    }
  }
  
  void openStory(StoryModel story) {
    Get.toNamed('/story/editor', arguments: story);
  }
  
  Future<void> deleteStory(String storyId) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Story'),
        content: const Text('Are you sure you want to delete this story?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      await _storyService.deleteStory(storyId);
    }
  }
  
  Future<void> approveStory(String storyId) async {
    await _storyService.approveStory(storyId);
  }
  
  void showUserMenu(BuildContext context) {
    final user = _authService.currentUser.value;
    
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Theme.of(context).primaryColor,
                  child: Text(
                    user?.displayName.isNotEmpty == true 
                        ? user!.displayName.substring(0, 1).toUpperCase() 
                        : 'U',
                    style: const TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.displayName ?? 'User',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        user?.email ?? '',
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withValues(alpha:0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          user?.role.toUpperCase() ?? '',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                Get.back();
                Get.toNamed('/profile');
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Get.back();
                Get.toNamed('/settings');
              },
            ),
            const Divider(height: 16),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sign Out'),
              onTap: () {
                Get.back();
                _authService.signOut();
              },
            ),
          ],
        ),
      ),
    );
  }
}

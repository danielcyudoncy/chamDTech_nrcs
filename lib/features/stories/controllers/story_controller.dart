import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chamDTech_nrcs/features/stories/services/story_service.dart';
import 'package:chamDTech_nrcs/features/stories/models/story_model.dart';
import 'package:chamDTech_nrcs/features/auth/services/auth_service.dart';
import 'package:chamDTech_nrcs/core/constants/app_constants.dart';
import 'package:uuid/uuid.dart';

class StoryController extends GetxController {
  final StoryService _storyService = Get.put(StoryService());
  final AuthService _authService = Get.find<AuthService>();
  
  final stories = <StoryModel>[].obs;
  final isLoading = false.obs;
  final currentFilter = 'all'.obs;
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
      // Apply filter
      if (currentFilter.value == 'draft') {
        stories.value = storyList
            .where((s) => s.status == AppConstants.statusDraft)
            .toList();
      } else if (currentFilter.value == 'approved') {
        stories.value = storyList
            .where((s) => s.status == AppConstants.statusApproved)
            .toList();
      } else if (currentFilter.value == 'pending') {
        stories.value = storyList
            .where((s) => s.status == AppConstants.statusPending)
            .toList();
      } else {
        stories.value = storyList;
      }
      isLoading.value = false;
    });
  }
  
  void setFilter(String filter) {
    currentFilter.value = filter;
    loadStories();
  }
  
  void createNewStory() {
    Get.toNamed('/story/editor');
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
                          color: Theme.of(context).primaryColor.withOpacity(0.1),
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

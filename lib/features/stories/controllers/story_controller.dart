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
  final categoryFilter = 'all'.obs; 
  final showArchived = false.obs;
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
      
      // Filter by archive status
      final baseStories = storyList.where((s) {
        if (showArchived.value) {
          return s.status == AppConstants.statusArchived;
        } else {
          return s.status != AppConstants.statusArchived;
        }
      }).toList();

      if (currentFilter.value == 'draft') {
        filtered = baseStories.where((s) => s.status == AppConstants.statusDraft).toList();
      } else if (currentFilter.value == 'approved') {
        filtered = baseStories.where((s) => s.status == AppConstants.statusApproved).toList();
      } else if (currentFilter.value == 'pending') {
        filtered = baseStories.where((s) => s.status == AppConstants.statusPending).toList();
      } else {
        filtered = baseStories;
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        child: Container(
          width: 500, // Slightly wider for better layout
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.category_outlined, size: 48, color: Color(0xFF1A237E)),
              const SizedBox(height: 20),
              const Text(
                'Select Story Category',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A237E),
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
                      return InkWell(
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
  
  void openStory(StoryModel story) {
    Get.toNamed('/story/editor', arguments: story);
  }
  
  Future<void> archiveStory(String storyId) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Archive Story'),
        content: const Text('Are you sure you want to move this story to the archive? It will be removed from your active workspace.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            child: const Text('Archive'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      await _storyService.archiveStory(storyId);
      if (selectedStoryId.value == storyId) {
        selectedStoryId.value = '';
      }
    }
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

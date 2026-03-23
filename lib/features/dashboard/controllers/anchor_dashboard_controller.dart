// features/dashboard/controllers/anchor_dashboard_controller.dart
import 'package:get/get.dart';
import 'package:chamdtech_nrcs/features/stories/models/story_model.dart';
import 'package:chamdtech_nrcs/features/stories/services/story_service.dart';
import 'package:chamdtech_nrcs/core/constants/app_constants.dart';

class AnchorDashboardController extends GetxController {
  final StoryService _storyService = Get.find<StoryService>();

  final RxString selectedCategory = ''.obs;
  final RxList<StoryModel> stories = <StoryModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Select first category by default
    if (AppConstants.storyCategories.isNotEmpty) {
      selectCategory(AppConstants.storyCategories.first);
    }
  }

  void selectCategory(String category) {
    selectedCategory.value = category;
    _fetchStoriesByCategory(category);
  }

  void _fetchStoriesByCategory(String category) {
    isLoading.value = true;
    _storyService.getStoriesByCategory(category).listen((storyList) {
      stories.value = storyList;
      isLoading.value = false;
    }, onError: (error) {
      Get.log('Error fetching stories by category: $error');
      isLoading.value = false;
    });
  }
}

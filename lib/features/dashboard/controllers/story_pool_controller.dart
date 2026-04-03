import 'package:get/get.dart';
import 'package:chamdtech_nrcs/features/stories/services/story_service.dart';
import 'package:chamdtech_nrcs/features/stories/models/story_model.dart';
import 'package:chamdtech_nrcs/core/constants/app_constants.dart';

class StoryPoolController extends GetxController {
  final StoryService _storyService = Get.find<StoryService>();

  final poolStories = <StoryModel>[].obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadPoolStories();
  }

  void _loadPoolStories() {
    // Listen to stories that are not archived. For the pool, we show
    // stories that are ready or in progress (matching the producer dashboard's existing logic).
    _storyService.getStories().listen((stories) {
      poolStories.value = stories.where((s) {
        return s.status != AppConstants.statusArchived;
      }).toList();
      
      if (isLoading.value) {
        isLoading.value = false;
      }
    }, onError: (err) {
      Get.log('Error fetching pool stories: $err');
      isLoading.value = false;
    });
  }
}

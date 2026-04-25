import 'dart:async';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chamdtech_nrcs/core/constants/app_constants.dart';
import 'package:chamdtech_nrcs/core/services/firebase_service.dart';
import 'package:chamdtech_nrcs/features/stories/models/desk_model.dart';
import 'package:chamdtech_nrcs/features/stories/models/story_model.dart';
import 'package:chamdtech_nrcs/features/stories/services/story_service.dart';

class DeskController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseService.firestore;
  final StoryService _storyService = Get.find<StoryService>();
  
  final desks = <DeskModel>[].obs;
  final deskStories = <StoryModel>[].obs;
  final selectedDeskId = ''.obs;
  final isLoadingDesks = false.obs;
  final isLoadingDeskStories = false.obs;
  final deskStoryCounts = <String, int>{}.obs;
  
  final allStories = <StoryModel>[].obs;
  StreamSubscription? _storiesSubscription;

  @override
  void onInit() {
    super.onInit();
    // Use ever to ensure counts are updated whenever stories or desks change
    ever(allStories, (_) => _updateCounts());
    ever(desks, (_) => _updateCounts());
    
    loadDesks();
    _listenToStories();
  }

  @override
  void onClose() {
    _storiesSubscription?.cancel();
    super.onClose();
  }

  void _listenToStories() {
    _storiesSubscription?.cancel();
    _storiesSubscription = _storyService.getStories().listen(
      (stories) {
        Get.log('DeskController: Received ${stories.length} stories');
        allStories.value = stories;
        if (selectedDeskId.isNotEmpty) {
          _refreshDeskStories();
        }
      },
      onError: (error) {
        Get.log('DeskController: Error in stories stream: $error');
        if (error.toString().contains('permission-denied')) {
          // If permission denied, allStories remains empty which is safe
          allStories.clear();
        }
      },
    );
  }

  Future<void> loadDesks() async {
    isLoadingDesks.value = true;
    try {
      final snapshot = await _firestore.collection(AppConstants.desksCollection).get();
      final List<DeskModel> fetchedDesks = snapshot.docs.map((doc) => DeskModel.fromJson(doc.data())).toList();
      
      if (fetchedDesks.isEmpty) {
        desks.value = AppConstants.storyCategories.map((cat) => DeskModel(
          id: cat,
          name: cat,
          description: 'Editorial Desk for $cat stories',
          producerId: '',
        )).toList();
      } else {
        desks.value = fetchedDesks;
      }
      _updateCounts();
    } catch (e) {
      Get.log('DeskController: Error loading desks: $e');
      // Fallback to categories even on error to ensure UI is not empty
      if (desks.isEmpty) {
        desks.value = AppConstants.storyCategories.map((cat) => DeskModel(
          id: cat,
          name: cat,
          description: 'Editorial Desk for $cat stories',
          producerId: '',
        )).toList();
      }
    } finally {
      isLoadingDesks.value = false;
    }
  }

  void _updateCounts() {
    final counts = <String, int>{};
    for (final desk in desks) {
      if (AppConstants.storyCategories.contains(desk.id)) {
        counts[desk.id] = allStories.where((s) => s.category == desk.id && s.status != AppConstants.statusArchived).length;
      } else {
        counts[desk.id] = allStories.where((s) => s.deskId == desk.id && s.status != AppConstants.statusArchived).length;
      }
    }
    deskStoryCounts.value = counts;
  }

  void selectDesk(String deskId) {
    selectedDeskId.value = deskId;
    _refreshDeskStories();
  }

  void _refreshDeskStories() {
    final deskId = selectedDeskId.value;
    if (deskId.isEmpty) {
      deskStories.clear();
      return;
    }

    final isCategory = AppConstants.storyCategories.contains(deskId);
    deskStories.value = allStories.where((s) {
      if (s.status == AppConstants.statusArchived) return false;
      return isCategory ? s.category == deskId : s.deskId == deskId;
    }).toList()..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }
}

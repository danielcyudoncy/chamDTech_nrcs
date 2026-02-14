import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import 'package:chamDTech_nrcs/core/constants/app_constants.dart';
import 'package:chamDTech_nrcs/core/services/firebase_service.dart';
import 'package:chamDTech_nrcs/features/stories/models/story_model.dart';
import 'package:chamDTech_nrcs/features/auth/services/auth_service.dart';
import 'package:chamDTech_nrcs/core/models/activity_log_model.dart';
import 'package:chamDTech_nrcs/core/services/activity_log_service.dart';
import 'package:uuid/uuid.dart';
import 'package:chamDTech_nrcs/features/auth/models/user_model.dart';

class StoryService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseService.firestore;
  final FirebaseDatabase _database = FirebaseService.database;

  final AuthService _authService = Get.find<AuthService>();
  final ActivityLogService _activityLogService = Get.put(ActivityLogService());
  
  // Get all stories
  Stream<List<StoryModel>> getStories() {
    return _firestore
        .collection(AppConstants.storiesCollection)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => StoryModel.fromJson(doc.data()))
            .toList());
  }
  
  // Lock a story for editing
  Future<bool> lockStory(String storyId) async {
    final user = _authService.currentUser.value;
    if (user == null) return false;

    try {
      final lockRef = _database.ref('${AppConstants.storyLocksPath}/$storyId');
      final snapshot = await lockRef.get();

      if (snapshot.exists) {
        final lockData = Map<String, dynamic>.from(snapshot.value as Map);
        if (lockData['userId'] == user.id) return true; // Already locked by me

        // Potential takeover check
        // This is handled via takeoverStory specifically
        return false; 
      }

      await lockRef.set({
        'userId': user.id,
        'userName': user.displayName,
        'role': user.role,
        'lockedAt': ServerValue.timestamp,
      });

      // Also update Firestore for persistent state
      await _firestore.collection(AppConstants.storiesCollection).doc(storyId).update({
        'lockedBy': user.id,
        'lockedAt': FieldValue.serverTimestamp(),
      });

      // Cleanup on disconnect
      lockRef.onDisconnect().remove();

      return true;
    } catch (e) {
      return false;
    }
  }

  // Release story lock
  Future<void> releaseStory(String storyId) async {
    final user = _authService.currentUser.value;
    if (user == null) return;

    try {
      final lockRef = _database.ref('${AppConstants.storyLocksPath}/$storyId');
      final snapshot = await lockRef.get();

      if (snapshot.exists) {
        final lockData = Map<String, dynamic>.from(snapshot.value as Map);
        if (lockData['userId'] == user.id) {
          await lockRef.remove();
          await _firestore.collection(AppConstants.storiesCollection).doc(storyId).update({
            'lockedBy': null,
            'lockedAt': null,
          });
        }
      }
    } catch (e) {
      Get.log('Error releasing story lock: $e');
    }
  }

  // Hierarchical takeover
  Future<bool> takeoverStory(String storyId) async {
    final currentUser = _authService.currentUser.value;
    if (currentUser == null) return false;

    try {
      final lockRef = _database.ref('${AppConstants.storyLocksPath}/$storyId');
      final snapshot = await lockRef.get();

      if (snapshot.exists) {
        final lockData = Map<String, dynamic>.from(snapshot.value as Map);
        
        // Fetch current owner's role from Firestore or use the one in lockData
        final ownerRole = lockData['role'] ?? 'reporter';
        
        // Use a temp user model to compare hierarchy
        final ownerTemp = UserModel(
          id: lockData['userId'],
          email: '',
          displayName: lockData['userName'] ?? 'Unknown',
          role: ownerRole,
          createdAt: DateTime.now(),
        );

        if (currentUser.canTakeOver(ownerTemp)) {
          // Force lock
          await lockRef.set({
            'userId': currentUser.id,
            'userName': currentUser.displayName,
            'role': currentUser.role,
            'lockedAt': ServerValue.timestamp,
          });

          await _firestore.collection(AppConstants.storiesCollection).doc(storyId).update({
            'lockedBy': currentUser.id,
            'lockedAt': FieldValue.serverTimestamp(),
          });

          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Get stories by desk
  Stream<List<StoryModel>> getStoriesByDesk(String deskId) {
    return _firestore
        .collection(AppConstants.storiesCollection)
        .where('deskId', isEqualTo: deskId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => StoryModel.fromJson(doc.data()))
            .toList());
  }
  
  // Get my stories
  Stream<List<StoryModel>> getMyStories() {
    final userId = _authService.currentUser.value?.id;
    if (userId == null) return Stream.value([]);
    
    return _firestore
        .collection(AppConstants.storiesCollection)
        .where('authorId', isEqualTo: userId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => StoryModel.fromJson(doc.data()))
            .toList());
  }
  
  // Get story by ID
  Future<StoryModel?> getStoryById(String storyId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.storiesCollection)
          .doc(storyId)
          .get();
      
      if (doc.exists) {
        return StoryModel.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      Get.log('Error getting story: $e');
      return null;
    }
  }
  
  // Create story
  Future<String?> createStory(StoryModel story) async {
    try {
      final docRef = await _firestore
          .collection(AppConstants.storiesCollection)
          .add(story.toJson());
      
      // Update with document ID
      await docRef.update({'id': docRef.id});
      
      Get.snackbar(
        'Success',
        'Story created successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
      
      // Log creation
      final user = _authService.currentUser.value;
      if (user != null) {
        await _activityLogService.logActivity(ActivityLogModel.storyCreated(
          id: const Uuid().v4(),
          userId: user.id,
          userName: user.displayName,
          storyId: docRef.id,
          storyTitle: story.title,
        ));
      }
      
      return docRef.id;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to create story: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }
  }
  
  // Update story
  Future<bool> updateStory(StoryModel story) async {
    try {
      await _firestore
          .collection(AppConstants.storiesCollection)
          .doc(story.id)
          .update(story.toJson());
      
      // Log update (optional: could filter for significant updates only)
      // For now, we'll skip logging every save to avoid noise
      
      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update story: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }
  
  // Delete story
  Future<bool> deleteStory(String storyId) async {
    try {
      await _firestore
          .collection(AppConstants.storiesCollection)
          .doc(storyId)
          .delete();
      
      Get.snackbar(
        'Success',
        'Story deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
      
      // Log deletion
      final user = _authService.currentUser.value;
      if (user != null) {
        await _activityLogService.logActivity(ActivityLogModel(
          id: const Uuid().v4(),
          userId: user.id,
          userName: user.displayName,
          action: 'delete',
          entityType: 'story',
          entityId: storyId,
          description: 'Deleted story',
          timestamp: DateTime.now(),
        ));
      }
      
      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete story: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }
  
  // Approve story
  Future<bool> approveStory(String storyId) async {
    final userId = _authService.currentUser.value?.id;
    if (userId == null) return false;
    
    try {
      await _firestore
          .collection(AppConstants.storiesCollection)
          .doc(storyId)
          .update({
        'status': AppConstants.statusApproved,
        'stage': AppConstants.stageVerified,
        'approvedBy': userId,
        'approvedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      Get.snackbar(
        'Success',
        'Story approved',
        snackPosition: SnackPosition.BOTTOM,
      );
      
      // Log approval
      final user = _authService.currentUser.value!;
      
      // Fetch title for log if needed, or just log ID
        final storyDoc = await _firestore.collection(AppConstants.storiesCollection).doc(storyId).get();
        final title = storyDoc.data()?['title'] ?? 'Unknown Story';
        
        await _activityLogService.logActivity(ActivityLogModel.storyApproved(
          id: const Uuid().v4(),
          userId: user.id,
          userName: user.displayName,
          storyId: storyId,
          storyTitle: title,
        ));

      
      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to approve story: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }
}

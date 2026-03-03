import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:chamDTech_nrcs/core/services/firebase_service.dart';
import 'package:chamDTech_nrcs/features/rundowns/models/rundown_model.dart';

class RundownService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseService.firestore;
  static const String collectionName = 'rundowns';

  // Get active rundowns (today or future)
  Stream<List<RundownModel>> getActiveRundowns() {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);

    return _firestore
        .collection(collectionName)
        // Need composite index likely, or we filter client side to avoid index errors quickly
        .where('scheduledTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .orderBy('scheduledTime', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => RundownModel.fromJson(doc.data()))
            .toList());
  }

  // Get single rundown
  Stream<RundownModel?> streamRundown(String id) {
    return _firestore
        .collection(collectionName)
        .doc(id)
        .snapshots()
        .map((doc) {
      if (doc.exists && doc.data() != null) {
        return RundownModel.fromJson(doc.data()!);
      }
      return null;
    });
  }

  // Create
  Future<String?> createRundown(RundownModel rundown) async {
    try {
      final docRef = await _firestore.collection(collectionName).add(rundown.toJson());
      await docRef.update({'id': docRef.id});
      return docRef.id;
    } catch (e) {
      Get.log('Error creating rundown: $e');
      return null;
    }
  }

  // Update
  Future<bool> updateRundown(RundownModel rundown) async {
    if (rundown.id.isEmpty) return false;
    try {
      await _firestore
          .collection(collectionName)
          .doc(rundown.id)
          .update(rundown.toJson());
      return true;
    } catch (e) {
      Get.log('Error updating rundown: $e');
      return false;
    }
  }

  // Delete
  Future<bool> deleteRundown(String id) async {
    try {
      await _firestore.collection(collectionName).doc(id).delete();
      return true;
    } catch (e) {
      Get.log('Error deleting rundown: $e');
      return false;
    }
  }

  /// Returns locked/on-air rundowns that contain [storyId].
  /// Used to determine whether a reporter can edit an approved story.
  Future<List<RundownModel>> getLockedRundownsForStory(String storyId) async {
    try {
      final snapshot = await _firestore
          .collection(collectionName)
          .where('storyIds', arrayContains: storyId)
          .where('status', whereIn: ['locked', 'on-air'])
          .get();
      return snapshot.docs
          .map((doc) => RundownModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      Get.log('Error checking rundown lock for story $storyId: $e');
      return [];
    }
  }

  /// Live stream of all non-draft rundowns (locked, on-air, completed).
  /// Used by the reporter controller to reactively maintain a set of locked story IDs.
  Stream<List<RundownModel>> streamNonDraftRundowns() {
    return _firestore
        .collection(collectionName)
        .where('status', whereIn: ['locked', 'on-air'])
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => RundownModel.fromJson(doc.data()))
            .toList());
  }
}

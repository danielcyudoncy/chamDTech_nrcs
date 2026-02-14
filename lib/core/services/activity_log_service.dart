import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:chamDTech_nrcs/core/models/activity_log_model.dart';
import 'package:chamDTech_nrcs/core/constants/app_constants.dart';

class ActivityLogService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Log an activity
  Future<void> logActivity(ActivityLogModel log) async {
    try {
      await _firestore
          .collection('activity_logs')
          .doc(log.id)
          .set(log.toJson());
          
      // Also add to entity's subcollection for easier querying
      // e.g. stories/{storyId}/activity/{logId}
      if (log.entityType == 'story') {
        await _firestore
            .collection(AppConstants.storiesCollection)
            .doc(log.entityId)
            .collection('activity')
            .doc(log.id)
            .set(log.toJson());
      } else if (log.entityType == 'rundown') {
        await _firestore
            .collection(AppConstants.rundownsCollection)
            .doc(log.entityId)
            .collection('activity')
            .doc(log.id)
            .set(log.toJson());
      }
    } catch (e) {
      print('Error logging activity: $e');
      // Non-blocking error - we don't want to stop the main action if logging fails
    }
  }

  // Get activity logs for a specific entity
  Stream<List<ActivityLogModel>> getEntityLogs(String entityType, String entityId) {
    CollectionReference collection;
    
    if (entityType == 'story') {
      collection = _firestore
          .collection(AppConstants.storiesCollection)
          .doc(entityId)
          .collection('activity');
    } else if (entityType == 'rundown') {
      collection = _firestore
          .collection(AppConstants.rundownsCollection)
          .doc(entityId)
          .collection('activity');
    } else {
      // Fallback to main collection query
      return _firestore
          .collection('activity_logs')
          .where('entityType', isEqualTo: entityType)
          .where('entityId', isEqualTo: entityId)
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => ActivityLogModel.fromJson(doc.data()))
              .toList());
    }
    
    return collection
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ActivityLogModel.fromJson(doc.data() as Map<String, dynamic>))
            .toList());
  }

  // Get recent activity for a user
  Stream<List<ActivityLogModel>> getUserActivity(String userId, {int limit = 20}) {
    return _firestore
        .collection('activity_logs')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ActivityLogModel.fromJson(doc.data()))
            .toList());
  }
}

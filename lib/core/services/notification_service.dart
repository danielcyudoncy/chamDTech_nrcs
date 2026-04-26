import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:chamdtech_nrcs/core/models/notification_model.dart';
import 'package:chamdtech_nrcs/features/auth/services/auth_service.dart';
import 'package:uuid/uuid.dart';
import 'package:chamdtech_nrcs/core/constants/app_constants.dart';
import 'package:chamdtech_nrcs/features/stories/views/widgets/nrcs_layout.dart';

class NotificationService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = Get.find<AuthService>();
  final _uuid = const Uuid();

  // Send a notification to a specific user
  Future<void> sendNotification(NotificationModel notification) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notification.id)
          .set(notification.toJson());
    } catch (e) {
      Get.log('Error sending notification: $e');
    }
  }

  // Broadcast a notification to ALL users
  Future<void> broadcastNotification({
    required String title,
    required String message,
    String type = 'system',
    String? actionUrl,
    Map<String, dynamic>? data,
  }) async {
    try {
      final usersSnapshot = await _firestore.collection(AppConstants.usersCollection).get();
      final userIds = usersSnapshot.docs.map((doc) => doc.id).toList();
      
      await notifyRelevantUsers(
        userIds: userIds,
        title: title,
        message: message,
        type: type,
        actionUrl: actionUrl,
        data: data,
      );
    } catch (e) {
      Get.log('Error broadcasting notification: $e');
    }
  }

  // Notify a specific list of users
  Future<void> notifyRelevantUsers({
    required List<String> userIds,
    required String title,
    required String message,
    String type = 'system',
    String? actionUrl,
    Map<String, dynamic>? data,
  }) async {
    if (userIds.isEmpty) return;

    try {
      final currentUserId = _authService.currentUser.value?.id;
      final now = DateTime.now();
      final batch = _firestore.batch();
      
      int count = 0;
      for (final userId in userIds) {
        // Don't notify the person who triggered the event, unless specifically desired
        // (usually better to exclude them to avoid self-notification noise)
        if (userId == currentUserId) continue;

        final notification = NotificationModel(
          id: _uuid.v4(),
          userId: userId,
          type: type,
          title: title,
          message: message,
          createdAt: now,
          actionUrl: actionUrl,
          data: data,
        );

        final docRef = _firestore.collection('notifications').doc(notification.id);
        batch.set(docRef, notification.toJson());
        
        count++;
        // Firestore batch limit is 500
        if (count >= 490) {
          await batch.commit();
          // Reset batch if we have more
          // (Simplified for now, assuming user count < 500)
        }
      }
      
      if (count > 0) {
        await batch.commit();
      }
    } catch (e) {
      Get.log('Error notifying users: $e');
    }
  }

  // Stream notifications for the current user
  Stream<List<NotificationModel>> getNotifications() {
    final user = _authService.currentUser.value;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: user.id)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NotificationModel.fromJson(doc.data()))
            .toList());
  }

  // Mark a notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});
    } catch (e) {
      Get.log('Error marking notification as read: $e');
    }
  }

  // Mark all notifications for a user as read
  Future<void> markAllAsRead() async {
    final user = _authService.currentUser.value;
    if (user == null) return;

    try {
      final unread = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: user.id)
          .where('isRead', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (var doc in unread.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
    } catch (e) {
      Get.log('Error marking all notifications as read: $e');
    }
  }

  // Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .delete();
    } catch (e) {
      Get.log('Error deleting notification: $e');
    }
  }

  // Delete all notifications for the current user
  Future<void> deleteAllNotifications() async {
    final user = _authService.currentUser.value;
    if (user == null) return;

    try {
      final snapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: user.id)
          .get();

      if (snapshot.docs.isEmpty) return;

      final batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      
      Get.snackbar(
        'Success',
        'All notifications cleared',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: NRCSColors.topNavBlue.withValues(alpha: 0.1),
        colorText: NRCSColors.topNavBlue,
      );
    } catch (e) {
      Get.log('Error deleting all notifications: $e');
      Get.snackbar(
        'Error',
        'Failed to clear notifications',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}

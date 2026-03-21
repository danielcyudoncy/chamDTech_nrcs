import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:chamDTech_nrcs/core/models/notification_model.dart';
import 'package:chamDTech_nrcs/features/auth/services/auth_service.dart';

class NotificationService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = Get.find<AuthService>();

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
}

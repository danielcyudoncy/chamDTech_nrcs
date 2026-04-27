// features/notifications/views/widgets/notifications_tab.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chamdtech_nrcs/core/models/notification_model.dart';
import 'package:chamdtech_nrcs/core/services/notification_service.dart';
import 'package:chamdtech_nrcs/features/notifications/views/widgets/notification_card.dart';

class NotificationsTab extends StatelessWidget {
  const NotificationsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final notificationService = Get.find<NotificationService>();

    return Container(
      color: const Color(0xFFF8F9FA),
      child: StreamBuilder<List<NotificationModel>>(
        stream: notificationService.getNotifications(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final notifications = snapshot.data ?? [];
          final hasUnread = notifications.any((n) => !n.isRead);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(
                  context, notificationService, notifications, hasUnread),
              Expanded(
                child: notifications.isEmpty
                    ? _buildEmptyState()
                    : _buildNotificationList(notifications),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, NotificationService service,
      List<NotificationModel> notifications, bool hasUnread) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Notifications',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A237E),
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                'Stay updated with recent activities.',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
          Row(
            children: [
              if (notifications.isNotEmpty)
                TextButton.icon(
                  onPressed: () => _confirmClearAll(context, service),
                  icon: const Icon(Icons.delete_sweep_outlined,
                      size: 18, color: Colors.red),
                  label: const Text('Clear All',
                      style: TextStyle(color: Colors.red)),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                ),
              if (hasUnread) ...[
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => service.markAllAsRead(),
                  icon: const Icon(Icons.done_all, size: 18),
                  label: const Text('Mark all as read'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none, size: 64, color: Colors.grey.shade200),
          const SizedBox(height: 16),
          Text(
            'No notifications yet',
            style: TextStyle(
                color: Colors.grey.shade400, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationList(List<NotificationModel> notifications) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 8.0),
      itemCount: notifications.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return NotificationCard(notification: notifications[index]);
      },
    );
  }

  void _confirmClearAll(BuildContext context, NotificationService service) {
    Get.dialog(
      AlertDialog(
        title: const Text('Clear all notifications?'),
        content: const Text(
            'This will permanently delete all your notifications. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              service.deleteAllNotifications();
            },
            child: const Text('Clear All',
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

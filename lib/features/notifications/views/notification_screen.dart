import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chamdtech_nrcs/core/models/notification_model.dart';
import 'package:chamdtech_nrcs/core/services/notification_service.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:chamdtech_nrcs/features/auth/services/auth_service.dart';
import 'package:chamdtech_nrcs/app/routes/app_routes.dart';
import 'package:chamdtech_nrcs/core/constants/app_constants.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notificationService = Get.find<NotificationService>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back to Dashboard',
          onPressed: () {
            try {
              if (Navigator.of(context).canPop()) {
                Get.back();
              } else {
                final authService = Get.find<AuthService>();
                final role = authService.currentUser.value?.role ?? AppConstants.roleReporter;
                final homeRoute = AppRoutes.getRouteForRole(role);
                Get.offAllNamed(homeRoute);
              }
            } catch (e) {
              // Fail-safe: navigate to home if anything goes wrong
              Get.offAllNamed('/');
            }
          },
        ),
        title: const Text('Notifications', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () => notificationService.markAllAsRead(),
            child: const Text('Mark all as read'),
          ),
        ],
      ),
      body: StreamBuilder<List<NotificationModel>>(
        stream: notificationService.getNotifications(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final notifications = snapshot.data ?? [];

          if (notifications.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No notifications yet', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.separated(
            itemCount: notifications.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return _NotificationItem(notification: notification);
            },
          );
        },
      ),
    );
  }
}

class _NotificationItem extends StatelessWidget {
  final NotificationModel notification;

  const _NotificationItem({required this.notification});

  @override
  Widget build(BuildContext context) {
    final notificationService = Get.find<NotificationService>();

    return ListTile(
      tileColor: notification.isRead ? Colors.transparent : Colors.blue.withValues(alpha: 0.05),
      leading: CircleAvatar(
        backgroundColor: _getNotificationColor(notification.type).withValues(alpha: 0.2),
        child: Icon(_getNotificationIcon(notification.type), color: _getNotificationColor(notification.type)),
      ),
      title: Text(
        notification.title,
        style: TextStyle(
          fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(notification.message),
          const SizedBox(height: 4),
          Text(
            timeago.format(notification.createdAt),
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
      onTap: () {
        notificationService.markAsRead(notification.id);
        if (notification.actionUrl != null && notification.actionUrl!.isNotEmpty) {
          Get.toNamed(notification.actionUrl!);
        }
      },
      trailing: PopupMenuButton<String>(
        onSelected: (value) {
          if (value == 'delete') {
            notificationService.deleteNotification(notification.id);
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'delete',
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'story_update':
        return Icons.article_outlined;
      case 'rundown_change':
        return Icons.view_list_outlined;
      case 'mention':
        return Icons.alternate_email;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'story_update':
        return Colors.blue;
      case 'rundown_change':
        return Colors.orange;
      case 'mention':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
